import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTokens {
  static const bg = Color(0xFF08090C);
  static const bgElevated = Color(0xFF10131A);
  static const bgSoft = Color(0xFF171B22);
  static const bgPanel = Color(0xFF1B2028);
  static const stroke = Color(0xFF2E3540);
  static const strokeSoft = Color(0xFF242A33);
  static const textPrimary = Color(0xFFF6F2EA);
  static const textSecondary = Color(0xFFB0A99C);
  static const textMuted = Color(0xFF736C63);
  static const accent = Color(0xFFD7A45A);
  static const accentDeep = Color(0xFFA8742E);
  static const accentSoft = Color(0x33D7A45A);
  static const bull = Color(0xFF3CCF98);
  static const bear = Color(0xFFE57266);
  static const info = Color(0xFF84A9C8);
  static const warn = Color(0xFFD7A45A);

  static const space4 = 4.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space20 = 20.0;
  static const space24 = 24.0;
  static const space32 = 32.0;

  static const radius12 = 12.0;
  static const radius16 = 16.0;
  static const radius20 = 20.0;
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
          letterSpacing: -0.6,
        ),
        headlineLarge: display.headlineLarge?.copyWith(
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 30,
          height: 1.1,
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
        bodyLarge: body.bodyLarge?.copyWith(
          color: AppTokens.textPrimary,
          height: 1.4,
        ),
        bodyMedium: body.bodyMedium?.copyWith(
          color: AppTokens.textSecondary,
          height: 1.45,
        ),
        bodySmall: body.bodySmall?.copyWith(
          color: AppTokens.textMuted,
          height: 1.4,
        ),
        labelLarge: body.labelLarge?.copyWith(
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTokens.bg,
        foregroundColor: AppTokens.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppTokens.bgElevated,
        indicatorColor: AppTokens.accentSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppTokens.accent : AppTokens.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppTokens.accent : AppTokens.textMuted,
          );
        }),
      ),
      dividerColor: AppTokens.strokeSoft,
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppTokens.accent,
        thumbColor: AppTokens.accent,
        inactiveTrackColor: AppTokens.stroke,
        overlayColor: AppTokens.accentSoft,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.bgPanel,
        contentTextStyle:
            body.bodyMedium?.copyWith(color: AppTokens.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
