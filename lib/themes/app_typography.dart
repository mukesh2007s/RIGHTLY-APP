import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Premium Typography System for Rightly
/// Following Material 3 and Apple HIG guidelines
class AppTypography {
  AppTypography._();

  // ═══════════════════════════════════════════════════════════════
  // FONT FAMILIES
  // ═══════════════════════════════════════════════════════════════
  
  static String get primaryFont => 'Inter';
  static String get displayFont => 'Poppins';

  // ═══════════════════════════════════════════════════════════════
  // DISPLAY STYLES - For large titles and hero text
  // ═══════════════════════════════════════════════════════════════
  
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 57,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.12,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.16,
    color: AppColors.textPrimary,
  );

  static TextStyle get displaySmall => GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.22,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════════════
  // HEADLINE STYLES - For section headers
  // ═══════════════════════════════════════════════════════════════
  
  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════════════
  // TITLE STYLES - For card titles and sub-headers
  // ═══════════════════════════════════════════════════════════════
  
  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════════════
  // BODY STYLES - For main content
  // ═══════════════════════════════════════════════════════════════
  
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.coolGray,
  );

  // ═══════════════════════════════════════════════════════════════
  // LABEL STYLES - For buttons and chips
  // ═══════════════════════════════════════════════════════════════
  
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColors.coolGray,
  );

  // ═══════════════════════════════════════════════════════════════
  // SPECIAL STYLES
  // ═══════════════════════════════════════════════════════════════
  
  /// Button text style
  static TextStyle get button => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Caption style for small text
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.coolGray,
  );

  /// Overline style for labels
  static TextStyle get overline => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.6,
    color: AppColors.coolGray,
  );

  /// Chat message style
  static TextStyle get chatMessage => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
    height: 1.5,
  );

  /// Code style for legal references
  static TextStyle get code => GoogleFonts.robotoMono(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.primary,
  );

  /// Logo style
  static TextStyle get logo => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.primary,
  );

  /// Gradient text style helper
  static TextStyle withGradient(TextStyle style) => style.copyWith(
    foreground: Paint()
      ..shader = AppGradients.primary.createShader(
        const Rect.fromLTWH(0, 0, 200, 70),
      ),
  );
}
