import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Custom User Color Palette
  static const Color primaryColor = Color(0xFF0F5B67);     // Teal Gelap
  static const Color secondaryColor = Color(0xFF45A1B2);   // Teal Muda
  static const Color accentColor = Color(0xFFF49D26);      // Oranye/Emas
  
  static const Color warningColor = Color(0xFFF49D26);
  static const Color errorColor = Color(0xFFEF4444);

  // Neutral Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceLight,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textPrimaryLight,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textPrimaryLight, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondaryLight, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: textPrimaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: secondaryColor,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: secondaryColor,
        secondary: primaryColor,
        tertiary: accentColor,
        surface: surfaceDark,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textPrimaryDark,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textPrimaryDark, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondaryDark, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: textPrimaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
