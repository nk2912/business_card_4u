import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.white,
      error: AppColors.errorBg,
    );

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF6AA4FF),
      onPrimary: Colors.white,
      secondary: Color(0xFF8C7DFF),
      onSecondary: Colors.white,
      error: Color(0xFFFF6B6B),
      onError: Colors.white,
      surface: Color(0xFF0A1020),
      onSurface: Color(0xFFEAF1FF),
      tertiary: Color(0xFF46D3FF),
      onTertiary: Color(0xFF04111E),
      primaryContainer: Color(0xFF12203D),
      onPrimaryContainer: Color(0xFFEAF1FF),
      secondaryContainer: Color(0xFF171C39),
      onSecondaryContainer: Color(0xFFEDE9FF),
      errorContainer: Color(0xFF5B1E1E),
      onErrorContainer: Color(0xFFFFDADA),
      surfaceContainerHighest: Color(0xFF1A2238),
      onSurfaceVariant: Color(0xFF9EACC7),
      outline: Color(0xFF33415C),
      outlineVariant: Color(0xFF1E2A44),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFEAF1FF),
      onInverseSurface: Color(0xFF0A1020),
      inversePrimary: AppColors.primary,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF060B16),
      canvasColor: const Color(0xFF0A1020),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF060B16),
        surfaceTintColor: Color(0xFF060B16),
      ),
    );
  }
}
