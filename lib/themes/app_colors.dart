import 'package:flutter/material.dart';

/// Premium Justice-Inspired Color System for Rightly
/// Designed for trust, authority, and legal professionalism
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // PRIMARY COLORS - Royal Justice Theme
  // ═══════════════════════════════════════════════════════════════
  
  /// Royal Justice Blue - Primary brand color
  static const Color primary = Color(0xFF1A237E);
  
  /// Legal Gold - Secondary accent for highlights
  static const Color secondary = Color(0xFFD4AF37);
  
  /// Sapphire Blue - Accent color for interactions
  static const Color accent = Color(0xFF1565C0);
  
  /// Justice White - Primary background
  static const Color background = Color(0xFFF8FAFC);
  
  /// Legal Black - Primary text color
  static const Color textPrimary = Color(0xFF0F172A);


  // ═══════════════════════════════════════════════════════════════
  // EXTENDED COLOR PALETTE
  // ═══════════════════════════════════════════════════════════════
  
  /// Deep Navy - For dark accents
  static const Color deepNavy = Color(0xFF283593);
  
  /// Light Blue - For subtle highlights
  static const Color lightBlue = Color(0xFF42A5F5);
  
  /// Pale Gold - For subtle gold tones
  static const Color paleGold = Color(0xFFE8D5A3);
  
  /// Warm White - Alternative background
  static const Color warmWhite = Color(0xFFFFFBF5);
  
  /// Cool Gray - For secondary text
  static const Color coolGray = Color(0xFF64748B);
  
  /// Light Gray - For borders and dividers
  static const Color lightGray = Color(0xFFE2E8F0);
  
  /// Ultra Light Gray - For card backgrounds
  static const Color ultraLightGray = Color(0xFFF1F5F9);


  // ═══════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════
  
  /// Success Green
  static const Color success = Color(0xFF10B981);
  
  /// Warning Amber
  static const Color warning = Color(0xFFF59E0B);
  
  /// Error Red
  static const Color error = Color(0xFFEF4444);
  
  /// Info Blue
  static const Color info = Color(0xFF3B82F6);


  // ═══════════════════════════════════════════════════════════════
  // GRADIENT COLORS
  // ═══════════════════════════════════════════════════════════════
  
  /// Primary gradient start
  static const Color gradientStart = Color(0xFF1A237E);
  
  /// Primary gradient middle
  static const Color gradientMiddle = Color(0xFF283593);
  
  /// Primary gradient end
  static const Color gradientEnd = Color(0xFF1565C0);
  
  /// Gold gradient start
  static const Color goldGradientStart = Color(0xFFD4AF37);
  
  /// Gold gradient end
  static const Color goldGradientEnd = Color(0xFFE8D5A3);


  // ═══════════════════════════════════════════════════════════════
  // GLASSMORPHISM COLORS
  // ═══════════════════════════════════════════════════════════════
  
  /// Glass white overlay
  static const Color glassWhite = Color(0x80FFFFFF);
  
  /// Glass border
  static const Color glassBorder = Color(0x40FFFFFF);
  
  /// Glass shadow
  static const Color glassShadow = Color(0x1A1A237E);


  // ═══════════════════════════════════════════════════════════════
  // CHAT BUBBLE COLORS
  // ═══════════════════════════════════════════════════════════════
  
  /// User message bubble
  static const Color userBubble = Color(0xFF1A237E);
  
  /// AI message bubble
  static const Color aiBubble = Color(0xFFFFFFFF);
  
  /// User message text
  static const Color userBubbleText = Color(0xFFFFFFFF);
  
  /// AI message text
  static const Color aiBubbleText = Color(0xFF0F172A);


  // ═══════════════════════════════════════════════════════════════
  // SHADOW COLORS
  // ═══════════════════════════════════════════════════════════════
  
  /// Primary shadow
  static const Color primaryShadow = Color(0x401A237E);
  
  /// Soft shadow
  static const Color softShadow = Color(0x1A000000);
  
  /// Gold shadow
  static const Color goldShadow = Color(0x40D4AF37);


  // ═══════════════════════════════════════════════════════════════
  // CONVENIENCE ALIASES
  // ═══════════════════════════════════════════════════════════════

  /// Legal Gold — alias for secondary
  static const Color legalGold = secondary;

  /// Secondary text color
  static const Color textSecondary = coolGray;

  /// Tertiary text color — lighter than secondary
  static const Color textTertiary = Color(0xFF94A3B8);

  /// Surface color — card/sheet backgrounds
  static const Color surface = ultraLightGray;

  /// Border color — dividers, outlines
  static const Color border = lightGray;
}


/// Premium Gradient Definitions
class AppGradients {
  AppGradients._();

  /// Primary Justice Gradient
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientStart,
      AppColors.gradientMiddle,
      AppColors.gradientEnd,
    ],
  );

  /// Vertical Primary Gradient
  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.gradientStart,
      AppColors.gradientMiddle,
      AppColors.gradientEnd,
    ],
  );

  /// Premium Legal Gradient (Blue to Gold)
  static const LinearGradient premiumLegal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.secondary,
    ],
  );

  /// Gold Shimmer Gradient
  static const LinearGradient goldShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.goldGradientStart,
      AppColors.goldGradientEnd,
      AppColors.goldGradientStart,
    ],
  );

  /// Subtle Background Gradient
  static const LinearGradient subtleBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.background,
      AppColors.ultraLightGray,
    ],
  );

  /// Glass Overlay Gradient
  static const LinearGradient glassOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF),
      Color(0x10FFFFFF),
    ],
  );

  /// Accent Button Gradient
  static const LinearGradient accentButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.accent,
      AppColors.primary,
    ],
  );

  /// Card Highlight Gradient
  static const LinearGradient cardHighlight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [
      Color(0x00FFFFFF),
      Color(0x20FFFFFF),
      Color(0x00FFFFFF),
    ],
  );

  /// Radial Glow Gradient
  static RadialGradient radialGlow({Color? color}) => RadialGradient(
    colors: [
      (color ?? AppColors.primary).withValues(alpha: 0.3),
      (color ?? AppColors.primary).withValues(alpha: 0.1),
      (color ?? AppColors.primary).withValues(alpha: 0.0),
    ],
  );

  /// Splash Screen Gradient
  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A237E),
      Color(0xFF283593),
      Color(0xFF303F9F),
      Color(0xFF1565C0),
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  /// Primary Gradient — alias for primary
  static const LinearGradient primaryGradient = primary;
}
