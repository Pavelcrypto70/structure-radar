import 'package:flutter/material.dart';

/// Brass terminal — institutional dark, warm accent, zero neon spam.
abstract final class SrColors {
  static const bg = Color(0xFF07080B);
  static const bgElevated = Color(0xFF0C0F14);
  static const surface = Color(0xFF12161D);
  static const surface2 = Color(0xFF181D26);
  static const surface3 = Color(0xFF1F2530);
  static const line = Color(0xFF2F3642);
  static const lineSoft = Color(0xFF222831);

  static const text = Color(0xFFF6F2EA);
  static const muted = Color(0xFFA8A194);
  static const faint = Color(0xFF6E675E);

  static const accent = Color(0xFFD7A45A);
  static const accentSoft = Color(0xFF2A2114);
  static const accentDim = Color(0xFF1A150E);
  static const onAccent = Color(0xFF1A140C);

  static const bull = Color(0xFF3CCF98);
  static const bullSoft = Color(0xFF0F2F26);
  static const bear = Color(0xFFE57266);
  static const bearSoft = Color(0xFF3A141C);

  static const warn = Color(0xFFD7A45A);
  static const info = Color(0xFF84A9C8);

  static const wick = Color(0xFF8A8378);
  static const grid = Color(0xFF161B22);
}

abstract final class SrSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class SrRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const sheet = 20.0;
}

abstract final class SrMotion {
  static const micro = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 260);
  static const emphasis = Duration(milliseconds: 400);
  static const curveIn = Curves.easeOutCubic;
  static const curveOut = Curves.easeInCubic;
  static const curveToggle = Curves.easeInOutCubic;
}

/// Back-compat aliases used across older screens.
abstract final class AppTokens {
  static const bg = SrColors.bg;
  static const bgElevated = SrColors.bgElevated;
  static const bgSoft = SrColors.surface2;
  static const bgPanel = SrColors.surface3;
  static const stroke = SrColors.line;
  static const strokeSoft = SrColors.lineSoft;
  static const textPrimary = SrColors.text;
  static const textSecondary = SrColors.muted;
  static const textMuted = SrColors.faint;
  static const accent = SrColors.accent;
  static const accentDeep = Color(0xFFA8742E);
  static const accentSoft = Color(0x33D7A45A);
  static const bull = SrColors.bull;
  static const bear = SrColors.bear;
  static const info = SrColors.info;
  static const warn = SrColors.warn;
  static const space4 = SrSpace.xs;
  static const space8 = SrSpace.sm;
  static const space12 = SrSpace.md;
  static const space16 = SrSpace.lg;
  static const space20 = 20.0;
  static const space24 = SrSpace.xl;
  static const space32 = SrSpace.xxl;
  static const radius12 = SrRadius.md;
  static const radius16 = SrRadius.lg;
  static const radius20 = SrRadius.xl;
}
