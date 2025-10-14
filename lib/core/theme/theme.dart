export 'colors.dart';
export 'text_styles.dart';
export 'dimensions.dart';
export 'shadows.dart';
export 'gradients.dart';

import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class WFTheme {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: WFColors.base,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: WFColors.primary,
          secondary: WFColors.secondary,
          surface: WFColors.base,
          onPrimary: WFColors.textPrimary,
          onSecondary: WFColors.textPrimary,
          onSurface: WFColors.textPrimary,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: WFColors.textSecondary),
          bodySmall: TextStyle(color: WFColors.textTertiary),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: WFColors.textPrimary),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: WFColors.textPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: WFColors.primary,
            foregroundColor: WFColors.textPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
}
