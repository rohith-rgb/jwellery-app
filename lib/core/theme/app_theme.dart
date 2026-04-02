import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colors ────────────────────────────────────────────
  static const Color primary        = Color(0xFF1565C0); // deep blue
  static const Color primaryLight   = Color(0xFF1E88E5);
  static const Color primaryDark    = Color(0xFF0D47A1);
  static const Color accent         = Color(0xFF2196F3);
  static const Color accentLight    = Color(0xFFBBDEFB);

  static const Color background     = Color(0xFFF5F8FF);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8F0FE);

  static const Color textPrimary    = Color(0xFF0D1B3E);
  static const Color textSecondary  = Color(0xFF5C6B8A);
  static const Color textHint       = Color(0xFF9EACC7);

  static const Color success        = Color(0xFF2E7D32);
  static const Color successLight   = Color(0xFFE8F5E9);
  static const Color error          = Color(0xFFC62828);
  static const Color errorLight     = Color(0xFFFFEBEE);
  static const Color warning        = Color(0xFFE65100);
  static const Color warningLight   = Color(0xFFFFF3E0);

  static const Color divider        = Color(0xFFDDE3F0);
  static const Color cardShadow     = Color(0x1A1565C0);

  // ── Spacing ─────────────────────────────────────────────────
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;

  // ── Border Radius ───────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // ── ThemeData ───────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary:          primary,
        onPrimary:        Colors.white,
        primaryContainer: accentLight,
        onPrimaryContainer: primaryDark,
        secondary:        accent,
        onSecondary:      Colors.white,
        secondaryContainer: surfaceVariant,
        onSecondaryContainer: textPrimary,
        surface:          surface,
        onSurface:        textPrimary,
        error:            error,
        onError:          Colors.white,
      ),
      scaffoldBackgroundColor: background,
    );

    return base.copyWith(
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge:  GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
        displayMedium: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.w600, color: textPrimary),
        headlineLarge: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium:GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge:     GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary),
        bodyMedium:    GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
        labelLarge:    GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
        labelMedium:   GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: primary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: textHint),
        labelStyle: GoogleFonts.dmSans(fontSize: 14, color: textSecondary),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: accentLight,
        labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }
}