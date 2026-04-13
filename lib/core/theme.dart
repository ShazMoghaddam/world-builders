import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colour palette ────────────────────────────────────────────────────────────

class WBColors {
  // Maths — warm amber
  static const mathAmber      = Color(0xFFFF9500);
  static const mathAmberDark  = Color(0xFFCC7700);
  static const mathAmberLight = Color(0xFFFFF4E0);

  // Literacy — vibrant blue
  static const litBlue        = Color(0xFF0A84FF);
  static const litBlueDark    = Color(0xFF0066CC);
  static const litBlueLight   = Color(0xFFE0F0FF);

  // Science — fresh green
  static const sciGreen       = Color(0xFF30D158);
  static const sciGreenDark   = Color(0xFF1E9E3E);
  static const sciGreenLight  = Color(0xFFDFF7E6);

  // Life Skills — rich purple
  static const lifePurple     = Color(0xFFBF5AF2);
  static const lifePurpleDark = Color(0xFF8E44AD);
  static const lifePurpleLight= Color(0xFFF5E8FF);

  // Feedback
  static const correct        = Color(0xFF30D158);
  static const wrong          = Color(0xFFFF3B30);
  static const hint           = Color(0xFFFFD60A);

  // Bricks
  static const brickOrange      = Color(0xFFFF6B35);
  static const brickOrangeDark  = Color(0xFFCC4F1A);
  static const brickOrangeLight = Color(0xFFFFF0EB);

  // Surfaces
  static const cardWhite    = Color(0xFFFFFFFF);
  static const surface      = Color(0xFFF4F2FD);   // slightly cooler lavender tint
  static const surfaceAlt   = Color(0xFFECEAFA);
  static const textPrimary  = Color(0xFF1A1040);
  static const textSecondary= Color(0xFF6E6A8A);
  static const locked       = Color(0xFFB8B5CC);
  static const lockedBg     = Color(0xFFEFEDF8);

  // Dark game surfaces
  static const gameBg       = Color(0xFF0D0B1A);
  static const gameSurface  = Color(0xFF18162A);
  static const gameBorder   = Color(0xFF2A2740);

  // Sky
  static const skyTop       = Color(0xFF1E90FF);
  static const skyBottom    = Color(0xFF87CEFA);

  // NEW: shimmer / glow helpers
  static const shimmerBase  = Color(0xFFE8E4FF);
  static const shimmerHighlight = Color(0xFFF8F6FF);
}

// ── Gradient helpers ──────────────────────────────────────────────────────────

class WBGradients {
  static const purple = LinearGradient(
    colors: [Color(0xFFBF5AF2), Color(0xFF8E44AD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purpleSoft = LinearGradient(
    colors: [Color(0xFFF5E8FF), Color(0xFFECE0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const brickWarm = LinearGradient(
    colors: [Color(0xFFFF8C55), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const sciGreen = LinearGradient(
    colors: [Color(0xFF4AE571), Color(0xFF30D158)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const mathAmber = LinearGradient(
    colors: [Color(0xFFFFAD33), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const litBlue = LinearGradient(
    colors: [Color(0xFF3DA0FF), Color(0xFF0A84FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient forZone(String zoneId) {
    switch (zoneId) {
      case 'maths':   return mathAmber;
      case 'literacy':return litBlue;
      case 'science': return sciGreen;
      default:        return purple;
    }
  }
}

// ── Shadow helpers ────────────────────────────────────────────────────────────

class WBShadows {
  static List<BoxShadow> card({Color? color, double elevation = 1.0}) => [
    BoxShadow(
      color: (color ?? WBColors.lifePurple).withValues(alpha: 0.10 * elevation),
      blurRadius: 20 * elevation,
      spreadRadius: 0,
      offset: Offset(0, 6 * elevation),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04 * elevation),
      blurRadius: 8 * elevation,
      offset: Offset(0, 2 * elevation),
    ),
  ];

  static List<BoxShadow> button(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.38),
      blurRadius: 18,
      offset: const Offset(0, 7),
    ),
    BoxShadow(
      color: color.withValues(alpha: 0.15),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> pill(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.28),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.45),
      blurRadius: 32,
      spreadRadius: 4,
    ),
  ];
}

// ── Typography ────────────────────────────────────────────────────────────────

class WBText {
  static TextStyle display(double size, {Color? color, double? height}) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: FontWeight.w700,          // bumped from w400 for more punch
        color: color ?? WBColors.textPrimary,
        height: height ?? 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle body(double size,
      {Color? color,
      FontWeight weight = FontWeight.w600,
      double? height}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: weight,
        color: color ?? WBColors.textPrimary,
        height: height,
      );
}

// Keep WBTextStyles for backward compat
class WBTextStyles {
  static TextStyle get displayLarge  => WBText.display(32, height: 1.1);
  static TextStyle get displayMedium => WBText.display(24);
  static TextStyle get titleLarge    => WBText.body(18, weight: FontWeight.w800);
  static TextStyle get titleMedium   => WBText.body(15, weight: FontWeight.w700);
  static TextStyle get body          => WBText.body(14, color: WBColors.textSecondary);
  static TextStyle get label         => WBText.body(12, color: WBColors.textSecondary, weight: FontWeight.w700);
}

// ── Theme ─────────────────────────────────────────────────────────────────────

class WBTheme {
  static ThemeData get theme => ThemeData(
    textTheme: GoogleFonts.nunitoTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: WBColors.lifePurple,
      surface: WBColors.surface,
    ),
    scaffoldBackgroundColor: WBColors.surface,
    useMaterial3: true,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
