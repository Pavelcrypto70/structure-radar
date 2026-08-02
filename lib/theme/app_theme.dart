import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTokens {
  static const bg = Color(0xFF0B0D10);
  static const bgElevated = Color(0xFF12151A);
  static const bgSoft = Color(0xFF181C22);
  static const stroke = Color(0xFF2A3038);
  static const strokeSoft = Color(0xFF22272E);
  static const textPrimary = Color(0xFFF3F0EA);
  static const textSecondary = Color(0xFFA8A297);
  static const textMuted = Color(0xFF6F6A63);
  static const accent = Color(0xFFD4A35C); // brass
  static const accentSoft = Color(0x33D4A35C);
  static const bull = Color(0xFF3DBE8B);
  static const bear = Color(0xFFE06A5C);
  static const info = Color(0xFF7FA3C5);
  static const warn = Color(0xFFD4A35C);

  static const space4 = 4.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space24 = 24.0;
  static const space32 = 32.0;

  static const radius12 = 12.0;
  static const radius16 = 16.0;
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppTokens.bg,
      colorScheme: const ColorScheme.dark(
        surface: AppTokens.bgElevated,
        primary: AppTokens.accent,
        onPrimary: Color(0xFF1A140C),
        secondary: AppTokens.info,
        error: AppTokens.bear,
      ),
    );

    final display = GoogleFonts.frauncesTextTheme(base.textTheme);
    final body = GoogleFonts.manropeTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: body.copyWith(
        displayLarge: display.displayLarge?.copyWith(
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        displayMedium: display.displayMedium?.copyWith(
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: display.headlineLarge?.copyWith(
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 28,
        ),
        headlineMedium: display.headlineMedium?.copyWith(
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        headlineSmall: display.headlineSmall?.copyWith(
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleLarge: body.titleLarge?.copyWith(
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: body.titleMedium?.copyWith(
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: body.bodyLarge?.copyWith(color: AppTokens.textPrimary, height: 1.35),
        bodyMedium: body.bodyMedium?.copyWith(color: AppTokens.textSecondary, height: 1.4),
        bodySmall: body.bodySmall?.copyWith(color: AppTokens.textMuted, height: 1.35),
        labelLarge: body.labelLarge?.copyWith(
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTokens.bg,
        foregroundColor: AppTokens.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: AppTokens.strokeSoft,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.bgSoft,
        contentTextStyle: body.bodyMedium?.copyWith(color: AppTokens.textPrimary),
      ),
    );
  }
}
