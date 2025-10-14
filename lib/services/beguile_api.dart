import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Handles all calls to the separate Beguile AI Scan + Council backend.
/// This talks exclusively to https://beguilebackend-production.up.railway.app/api/v1
/// and does not touch the other AI backends.
class BeguileApi {
  static String get _base => dotenv.env['BEGUILE_API_BASE'] ?? 'https://beguilebackend-production.up.railway.app/api/v1';

  /// --- INTERNAL POST HANDLER ---
  static Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_base$path');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body);
    if (data is! Map || data['ok'] != true) {
      throw Exception('Unexpected response: ${res.body}');
    }

    return data['data'] as Map<String, dynamic>;
  }

  /// 🔍 SCAN TAB — Manipulation Analysis
  static Future<Map<String, dynamic>> scan({
    required String text,
    required String perspective,
    String? mentorId,
  }) async {
    return _post('/scan', {
      'text': text,
      'perspective': perspective,
      if (mentorId != null) 'mentorId': mentorId,
    });
  }

  /// 🧠 COUNCIL TAB — Sequential Mentor Debate
  static Future<Map<String, dynamic>> council({
    required String mode,
    required int age,
    required int tone,
    required String scenario,
  }) async {
    return _post('/council/debate', {
      'mode': mode,
      'age': age,
      'tone': tone,
      'scenario': scenario,
    });
  }
}
