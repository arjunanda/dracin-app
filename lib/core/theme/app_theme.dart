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
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.outfit(
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
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
      ),
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
