import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // -- Color Tokens -------------------------------------------------------------
  static const Color accent      = Color(0xFF5CC1B5);
  static const Color accentLight = Color(0xFF7DD6CB);
  static const Color accentDark  = Color(0xFF3AA89B);
  static const Color error       = Color(0xFFEF7261);

  // Dark palette
  static const Color background      = Color(0xFF0F1929);
  static const Color surface         = Color(0xFF1A2E4A);
  static const Color surfaceElevated = Color(0xFF1F3655);
  static const Color textPrimary     = Color(0xFFE8EDF2);
  static const Color textSecondary   = Color(0xFF8FA8C8);
  static const Color border          = Color(0xFF263D5C);

  // Light palette
  static const Color lightBackground    = Color(0xFFF0F4F8);
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color lightTextPrimary   = Color(0xFF0F1929);
  static const Color lightTextSecondary = Color(0xFF5A7A9E);
  static const Color lightBorder        = Color(0xFFDDE5EF);
  static const Color lightError         = Color(0xFFE53E3E);

  // -- Radius Tokens -------------------------------------------------------------
  static const double radiusSm   = 12.0;
  static const double radiusMd   = 16.0;
  static const double radiusLg   = 20.0;
  static const double radiusXl   = 28.0;
  static const double radiusFull = 100.0;

  // -- Shadow Helpers ------------------------------------------------------------
  static List<BoxShadow> get shadowSm => [
    BoxShadow(color: const Color(0xFF000D1A).withValues(alpha: 0.04), blurRadius: 12,  offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> get shadowMd => [
    BoxShadow(color: const Color(0xFF000D1A).withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
  ];
  static List<BoxShadow> get shadowLg => [
    BoxShadow(color: const Color(0xFF000D1A).withValues(alpha: 0.10), blurRadius: 40, offset: const Offset(0, 12)),
  ];
  static List<BoxShadow> get shadowAccent => [
    BoxShadow(color: accent.withValues(alpha: 0.20), blurRadius: 24, offset: const Offset(0, 8)),
  ];

  // -- Gradient Helpers ----------------------------------------------------------
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // -- Dark Theme ----------------------------------------------------------------
  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentLight,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSurface: textPrimary,
        onSecondary: Colors.white,
        surfaceContainerHighest: surfaceElevated,
        outline: border,
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: Color(0x265CC1B5),
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 22);
          }
          return const IconThemeData(color: textSecondary, size: 22);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: const Color(0x265CC1B5),
        side: const BorderSide(color: border, width: 0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusFull)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIconColor: textSecondary,
      ),
    );
    return base.copyWith(textTheme: _buildTextTheme(base.textTheme, dark: true));
  }

  // -- Light Theme ---------------------------------------------------------------
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accentLight,
        surface: lightSurface,
        error: lightError,
        onPrimary: Colors.white,
        onSurface: lightTextPrimary,
        onSecondary: Colors.white,
        outline: lightBorder,
        surfaceContainerHighest: Color(0xFFF5F8FC),
      ),
      dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: Color(0x1E5CC1B5),
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 22);
          }
          return const IconThemeData(color: lightTextSecondary, size: 22);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F4F8),
        selectedColor: const Color(0x1E5CC1B5),
        side: const BorderSide(color: lightBorder, width: 0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusFull)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightTextPrimary,
          side: const BorderSide(color: lightBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F8FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: lightError, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIconColor: lightTextSecondary,
      ),
    );
    return base.copyWith(textTheme: _buildTextTheme(base.textTheme, dark: false));
  }

  // -- Shared text theme builder --------------------------------------------------
  static TextTheme _buildTextTheme(TextTheme base, {required bool dark}) {
    final primary   = dark ? textPrimary   : lightTextPrimary;
    final secondary = dark ? textSecondary : lightTextSecondary;
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge:   GoogleFonts.inter(color: primary,   fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineLarge:  GoogleFonts.inter(color: primary,   fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.4),
      headlineMedium: GoogleFonts.inter(color: primary,   fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleLarge:     GoogleFonts.inter(color: primary,   fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.1),
      titleMedium:    GoogleFonts.inter(color: primary,   fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall:     GoogleFonts.inter(color: primary,   fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge:      GoogleFonts.inter(color: primary,   fontSize: 16, height: 1.6),
      bodyMedium:     GoogleFonts.inter(color: secondary, fontSize: 14, height: 1.5),
      bodySmall:      GoogleFonts.inter(color: secondary, fontSize: 12, height: 1.4),
      labelLarge:     GoogleFonts.inter(color: accent,    fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium:    GoogleFonts.inter(color: secondary, fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall:     GoogleFonts.inter(color: secondary, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    );
  }
}
