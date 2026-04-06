import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Brand palette
  static const Color deepNavy = Color(0xFF191E29);
  static const Color navyBlue = Color(0xFF132D46);
  static const Color teal = Color(0xFF01C38D);
  static const Color slate = Color(0xFF696E79);
  static const Color white = Color(0xFFFFFFFF);

  // Tinted surfaces
  static const Color _lightScaffold = Color(0xFFF0F4F8);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightTealCard = Color(0xFFF0FEFA); // teal-tinted card bg

  // Semantic aliases
  static const Color primary = teal;
  static const Color expense = Color(0xFFE05C6A);
  static const Color income = teal;

  // Shared text theme builder
  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.inter(
          fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: -1.5),
      displayMedium: GoogleFonts.inter(
          fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1),
      displaySmall: GoogleFonts.inter(
          fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineLarge: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w300),
      bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w300),
      bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w300),
      labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  }

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: teal,
      onPrimary: white,
      primaryContainer: _lightTealCard,
      onPrimaryContainer: Color(0xFF004D38),
      secondary: navyBlue,
      onSecondary: white,
      secondaryContainer: Color(0xFFD0E4F5),
      onSecondaryContainer: Color(0xFF0A1929),
      tertiary: slate,
      onTertiary: white,
      tertiaryContainer: Color(0xFFE8EAED),
      onTertiaryContainer: deepNavy,
      surface: _lightCard,
      onSurface: navyBlue,         // navy text, not black
      surfaceContainerHighest: Color(0xFFEBF0F5),
      onSurfaceVariant: slate,     // slate for secondary text
      outline: Color(0xFFCDD2DA),
      outlineVariant: Color(0xFFE4E8EE),
      error: Color(0xFFD32F2F),
      onError: white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      inverseSurface: navyBlue,
      onInverseSurface: white,
      inversePrimary: teal,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _lightScaffold,
      textTheme: _buildTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: navyBlue,
        displayColor: navyBlue,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: navyBlue,   // navy AppBar in light mode
        foregroundColor: white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          color: white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: white),
        actionsIconTheme: const IconThemeData(color: white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _lightCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE4E8EE)),
        ),
      ),
      iconTheme: const IconThemeData(color: teal),  // all icons teal
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F4F8),
        hintStyle: const TextStyle(color: slate),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E4EA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: teal, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navyBlue,
          side: const BorderSide(color: navyBlue),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: teal,
        foregroundColor: white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? teal : slate,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? teal.withValues(alpha: 0.35)
              : const Color(0xFFE0E4EA),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE4E8EE),
        thickness: 1,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: teal,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navyBlue,
        indicatorColor: teal.withValues(alpha: 0.25),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: teal);
          }
          return IconThemeData(color: white.withValues(alpha: 0.55));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w600, color: teal);
          }
          return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: white.withValues(alpha: 0.55));
        }),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: teal,
      onPrimary: deepNavy,
      primaryContainer: Color(0xFF003D2C),
      onPrimaryContainer: Color(0xFFCCF5EA),
      secondary: Color(0xFF1E3A54),
      onSecondary: white,
      secondaryContainer: navyBlue,
      onSecondaryContainer: Color(0xFFD0E4F5),
      tertiary: slate,
      onTertiary: white,
      tertiaryContainer: Color(0xFF252D3A),
      onTertiaryContainer: Color(0xFFB8BDC8),
      surface: navyBlue,
      onSurface: white,
      surfaceContainerHighest: Color(0xFF1A2D3F),
      onSurfaceVariant: Color(0xFFB0B8C8),
      outline: Color(0xFF2E3E50),
      outlineVariant: Color(0xFF243040),
      error: Color(0xFFCF6679),
      onError: deepNavy,
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      inverseSurface: white,
      onInverseSurface: deepNavy,
      inversePrimary: Color(0xFF00886A),
      shadow: Colors.black,
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: deepNavy,
      textTheme: _buildTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: white,
        displayColor: white,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: deepNavy,
        foregroundColor: white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          color: white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: white),
        actionsIconTheme: const IconThemeData(color: white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: navyBlue,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          // no visible border — rely on surface color contrast
          side: BorderSide(color: white.withValues(alpha: 0.04)),
        ),
      ),
      iconTheme: const IconThemeData(color: teal),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2D40),
        hintStyle: const TextStyle(color: slate),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E3E50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: teal, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: deepNavy,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: deepNavy,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: white,
          side: BorderSide(color: white.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: teal,
        foregroundColor: deepNavy,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? teal : slate,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? teal.withValues(alpha: 0.35)
              : const Color(0xFF2E3E50),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: DividerThemeData(
        color: white.withValues(alpha: 0.06),
        thickness: 1,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: teal,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navyBlue,
        indicatorColor: teal.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: teal);
          }
          return IconThemeData(color: white.withValues(alpha: 0.45));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w600, color: teal);
          }
          return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: white.withValues(alpha: 0.45));
        }),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
