import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.lightSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      // Distinctive typography: Cinzel for headings (cinematic/imperial), Rubik for UI/body
      textTheme: GoogleFonts.rubikTextTheme().copyWith(
        displayLarge: GoogleFonts.cinzel(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 34,
          letterSpacing: 0.6,
        ),
        bodyLarge: GoogleFonts.rubik(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.rubik(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.lightSurface,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      // Distinctive typography: Cinzel for headings (cinematic/imperial), Rubik for UI/body
      textTheme: GoogleFonts.rubikTextTheme().copyWith(
        displayLarge: GoogleFonts.cinzel(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 36,
          letterSpacing: 0.8,
        ),
        bodyLarge: GoogleFonts.rubik(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.rubik(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            20,
          ), // Different radius as requested
        ),
        color: AppColors.darkSurface,
      ),
    );
  }
}
