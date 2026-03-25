import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colour palette ────────────────────────────────────────────────────────────

class WBColors {
  static const mathAmber     = Color(0xFFFF9500);
  static const mathAmberDark = Color(0xFFCC7700);
  static const mathAmberLight= Color(0xFFFFF4E0);

  static const litBlue       = Color(0xFF0A84FF);
  static const litBlueDark   = Color(0xFF0066CC);
  static const litBlueLight  = Color(0xFFE0F0FF);

  static const sciGreen      = Color(0xFF30D158);
  static const sciGreenDark  = Color(0xFF1E9E3E);
  static const sciGreenLight = Color(0xFFDFF7E6);

  static const lifePurple    = Color(0xFFBF5AF2);
  static const lifePurpleDark= Color(0xFF8E44AD);
  static const lifePurpleLight=Color(0xFFF5E8FF);

  static const correct       = Color(0xFF30D158);
  static const wrong         = Color(0xFFFF3B30);
  static const hint          = Color(0xFFFFD60A);

  static const brickOrange     = Color(0xFFFF6B35);
  static const brickOrangeLight= Color(0xFFFFF0EB);

  static const cardWhite   = Color(0xFFFFFFFF);
  static const surface     = Color(0xFFF2F0FB);
  static const textPrimary = Color(0xFF1A1040);
  static const textSecondary=Color(0xFF6E6A8A);
  static const locked      = Color(0xFFB8B5CC);
  static const lockedBg    = Color(0xFFEFEDF8);

  static const gameBg      = Color(0xFF0D0B1A);
  static const gameSurface = Color(0xFF18162A);
  static const gameBorder  = Color(0xFF2A2740);

  static const skyTop    = Color(0xFF1E90FF);
  static const skyBottom = Color(0xFF87CEFA);
}

// ── Typography ─────────────────────────────────────────────────────────────────
// Fredoka One via GoogleFonts.poppins() — works on all platforms including Android.
// Nunito via GoogleFonts.nunito() — consistent with the theme-level text theme.

class WBText {
  static TextStyle display(double size, {Color? color, double? height}) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? WBColors.textPrimary,
        height: height,
        letterSpacing: -0.2,
      );

  static TextStyle body(double size, {Color? color, FontWeight weight = FontWeight.w600, double? height}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: weight,
        color: color ?? WBColors.textPrimary,
        height: height,
      );
}

// Keep WBTextStyles for backward compat with existing screens
class WBTextStyles {
  static TextStyle get displayLarge  => WBText.display(32, height: 1.1);
  static TextStyle get displayMedium => WBText.display(24);
  static TextStyle get titleLarge    => WBText.body(18, weight: FontWeight.w800);
  static TextStyle get titleMedium   => WBText.body(15, weight: FontWeight.w700);
  static TextStyle get body          => WBText.body(14, color: WBColors.textSecondary);
  static TextStyle get label         => WBText.body(12, color: WBColors.textSecondary, weight: FontWeight.w700);
}

class WBTheme {
  static ThemeData get theme => ThemeData(
    textTheme: GoogleFonts.nunitoTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: WBColors.lifePurple,
      background: WBColors.surface,
    ),
    scaffoldBackgroundColor: WBColors.surface,
    useMaterial3: true,
  );
}
