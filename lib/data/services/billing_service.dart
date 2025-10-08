import 'dart:async';
import 'dart:io' show Platform;

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'paywall_service.dart';

class BillingService {
  BillingService._();

  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  static bool _initialized = false;

  static const String _lastProductKey = 'iap_last_product_id_v1';

  // Provide product IDs via --dart-define at build time; defaults are placeholders
  static const String androidMonthlyId = String.fromEnvironment(
    'ANDROID_SUB_MONTHLY_ID',
    defaultValue: 'beguile_pro_monthly',
  );
  static const String androidYearlyId = String.fromEnvironment(
    'ANDROID_SUB_YEARLY_ID',
    defaultValue: 'beguile_pro_yearly',
  );

  static Completer<bool>? _pendingPurchaseCompleter;

  static Future<void> init() async {
    if (_initialized) return;
    final bool available = await _inAppPurchase.isAvailable();
    // Even if not available (web/desktop), mark initialized to avoid repeated work.
    _purchaseSub = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _purchaseSub?.cancel(),
      onError: (_) {},
    );
    _initialized = true;
    if (!available) {
      return;
    }
  }

  static Future<Map<String, ProductDetails>> loadProductsByPlan() async {
    final Set<String> productIds = {
      androidMonthlyId,
      androidYearlyId,
    }.where((id) => id.trim().isNotEmpty).toSet();

    if (productIds.isEmpty) return {};

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds);
    if (response.error != null || response.productDetails.isEmpty) {
      return {};
    }

    final Map<String, ProductDetails> byId = {
      for (final p in response.productDetails) p.id: p,
    };

    final Map<String, ProductDetails> plans = {};
    final monthly = byId[androidMonthlyId];
    final yearly = byId[androidYearlyId];
    if (monthly != null) plans['monthly'] = monthly;
    if (yearly != null) plans['yearly'] = yearly;
    return plans;
  }

  static Future<bool> buyPlan(String plan) async {
    final Map<String, ProductDetails> products = await loadProductsByPlan();
    final ProductDetails? product = products[plan];
    if (product == null) return false;

    _pendingPurchaseCompleter = Completer<bool>();

    // Subscriptions on Google Play require an offerToken. Pick the first available offer.
    if (Platform.isAndroid && product is GooglePlayProductDetails) {
      final offerDetails = product.billingClientProduct.subscriptionOfferDetails;
      final String? offerToken = (offerDetails != null && offerDetails.isNotEmpty)
          ? offerDetails.first.offerToken
          : null;

      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
        productDetails: product,
        changeSubscriptionParam: null,
        applicationUserName: null,
        productDetailsToken: null,
        offerToken: offerToken,
      );

      final bool submitted = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (!submitted) {
        _pendingPurchaseCompleter = null;
        return false;
      }
    } else {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      final bool submitted = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (!submitted) {
        _pendingPurchaseCompleter = null;
        return false;
      }
    }

    try {
      final bool result = await _pendingPurchaseCompleter!.future
          .timeout(const Duration(minutes: 5));
      if (result) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastProductKey, product.id);
      }
      return result;
    } catch (_) {
      return false;
    } finally {
      _pendingPurchaseCompleter = null;
    }
  }

  static Future<bool> restorePurchases() async {
    try {
      final QueryPurchaseDetailsResponse resp =
          await _inAppPurchase.queryPastPurchases();
      bool anyActive = false;
      for (final PurchaseDetails p in resp.pastPurchases) {
        if (p.status == PurchaseStatus.purchased ||
            p.status == PurchaseStatus.restored) {
          anyActive = true;
          if (p.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(p);
          }
        }
      }
      await PaywallService.setEntitled(anyActive);
      return anyActive;
    } catch (_) {
      return false;
    }
  }

  static Future<void> dispose() async {
    await _purchaseSub?.cancel();
    _purchaseSub = null;
    _initialized = false;
  }

  static Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchases) async {
    bool entitled = false;
    for (final PurchaseDetails purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          entitled = true;
          break;
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.canceled:
        case PurchaseStatus.error:
          break;
      }
      if (purchase.pendingCompletePurchase) {
        try {
          await _inAppPurchase.completePurchase(purchase);
        } catch (_) {}
      }
    }
    if (entitled) {
      await PaywallService.setEntitled(true);
      _pendingPurchaseCompleter?.complete(true);
    } else {
      _pendingPurchaseCompleter?.complete(false);
    }
  }
}
