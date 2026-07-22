import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  static TextStyle get headlineStyle => GoogleFonts.playfairDisplay(
        color: AppColors.textDark,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      );

  static TextStyle get subtitleStyle => GoogleFonts.inter(
        color: AppColors.textLight,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.4,
      );

  static TextStyle get bodyStyle => GoogleFonts.inter(
        color: AppColors.textDark,
        fontWeight: FontWeight.normal,
        fontSize: 15,
      );

  static TextStyle get buttonStyle => GoogleFonts.inter(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: 0.8,
      );

  static TextStyle get cardTitleStyle => GoogleFonts.playfairDisplay(
        color: AppColors.textDark,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      );

  static TextStyle get labelStyle => GoogleFonts.inter(
        color: AppColors.textDark.withOpacity(0.8),
        fontWeight: FontWeight.w500,
        fontSize: 12,
      );

  static TextStyle get codeStyle => GoogleFonts.firaMono(
        color: AppColors.textDark,
        fontSize: 12,
      );
}
