import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';
export 'tokens.dart';

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SrColors.bg,
      colorScheme: const ColorScheme.dark(
        surface: SrColors.surface,
        primary: SrColors.accent,
        onPrimary: SrColors.onAccent,
        secondary: SrColors.info,
        error: SrColors.bear,
      ),
    );

    final display = GoogleFonts.spaceGroteskTextTheme(base.textTheme);
    final body = GoogleFonts.ibmPlexSansTextTheme(base.textTheme);
    final mono = GoogleFonts.jetBrainsMonoTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: body.copyWith(
        displayLarge: display.displayLarge?.copyWith(
          color: SrColors.text,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.8,
        ),
        headlineLarge: display.headlineLarge?.copyWith(
          color: SrColors.text,
          fontWeight: FontWeight.w600,
          fontSize: 30,
          height: 1.05,
          letterSpacing: -0.6,
        ),
        headlineMedium: display.headlineMedium?.copyWith(
          color: SrColors.text,
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: -0.3,
        ),
        headlineSmall: display.headlineSmall?.copyWith(
          color: SrColors.text,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleLarge: body.titleLarge?.copyWith(
          color: SrColors.text,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: body.titleMedium?.copyWith(
          color: SrColors.text,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: body.bodyLarge?.copyWith(color: SrColors.text, height: 1.4),
        bodyMedium: body.bodyMedium?.copyWith(
          color: SrColors.muted,
          height: 1.45,
        ),
        bodySmall: body.bodySmall?.copyWith(color: SrColors.faint, height: 1.4),
        labelLarge: mono.labelLarge?.copyWith(
          color: SrColors.text,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          fontSize: 12,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        labelMedium: mono.labelMedium?.copyWith(
          color: SrColors.muted,
          letterSpacing: 1.1,
          fontSize: 11,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        labelSmall: mono.labelSmall?.copyWith(
          color: SrColors.faint,
          letterSpacing: 1.3,
          fontSize: 10,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SrColors.bg,
        foregroundColor: SrColors.text,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      dividerColor: SrColors.lineSoft,
      sliderTheme: const SliderThemeData(
        activeTrackColor: SrColors.accent,
        thumbColor: SrColors.accent,
        inactiveTrackColor: SrColors.line,
        overlayColor: SrColors.accentSoft,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: SrColors.accent,
          foregroundColor: SrColors.onAccent,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SrRadius.md),
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SrColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SrRadius.sheet),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SrColors.surface3,
        contentTextStyle: body.bodyMedium?.copyWith(color: SrColors.text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
