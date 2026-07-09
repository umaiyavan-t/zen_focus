import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Zen Dark Palette
  static const Color primaryColor = Color(0xFF90A48E); // Sage Green
  static const Color secondaryColor = Color(0xFFB5A99C); // Stone/Stone Grey
  static const Color backgroundColor = Color(0xFF121212); // Deep Black
  static const Color surfaceColor = Color(0xFF1E1E1E); // Slate Grey
  static const Color accentColor = Color(0xFFD4A373); // Muted Sand
  static const Color textBodyColor = Color(0xFFAAAAAA);
  static const Color textHeadlineColor = Color(0xFFE0E0E0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: Color(0xFFCF6679),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        TextTheme(
          headlineLarge: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: textHeadlineColor,
            letterSpacing: 1.2,
          ),
          headlineMedium: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: textHeadlineColor,
            letterSpacing: 0.8,
          ),
          bodyLarge: GoogleFonts.outfit(
            fontSize: 16,
            color: textHeadlineColor,
            letterSpacing: 0.5,
          ),
          bodyMedium: GoogleFonts.outfit(
            fontSize: 14,
            color: textBodyColor,
            height: 1.5,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
          color: textHeadlineColor,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white24,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
