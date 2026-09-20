import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Premium Light Theme for Rightly
/// Following Material 3 Design System and Apple HIG
class AppTheme {
  AppTheme._();

  /// Main Light Theme
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.ultraLightGray,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.paleGold,
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.lightGray,
    ),
    
    // Scaffold Background
    scaffoldBackgroundColor: AppColors.background,
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      titleTextStyle: AppTypography.titleLarge,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: AppColors.primary, width: 2),
        textStyle: AppTypography.button,
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: AppTypography.button,
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 8,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.lightGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.lightGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.coolGray),
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.coolGray),
      errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
      prefixIconColor: AppColors.coolGray,
      suffixIconColor: AppColors.coolGray,
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.coolGray,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    
    // Navigation Bar Theme (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primary.withValues(alpha: 0.1),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.labelSmall.copyWith(color: AppColors.primary);
        }
        return AppTypography.labelSmall.copyWith(color: AppColors.coolGray);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return const IconThemeData(color: AppColors.coolGray, size: 24);
      }),
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      elevation: 24,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      titleTextStyle: AppTypography.headlineSmall,
      contentTextStyle: AppTypography.bodyMedium,
    ),
    
    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 16,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      showDragHandle: true,
      dragHandleColor: AppColors.lightGray,
    ),
    
    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      elevation: 8,
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.ultraLightGray,
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      labelStyle: AppTypography.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.lightGray,
      thickness: 1,
      space: 1,
    ),
    
    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: AppTypography.titleMedium,
      subtitleTextStyle: AppTypography.bodySmall,
      leadingAndTrailingTextStyle: AppTypography.bodyMedium,
    ),
    
    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return AppColors.coolGray;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.lightGray;
      }),
    ),
    
    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.lightGray,
      circularTrackColor: AppColors.lightGray,
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),
    
    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      displaySmall: AppTypography.displaySmall,
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      headlineSmall: AppTypography.headlineSmall,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    ),
    
    // Page Transitions
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}


/// Shadow Definitions for Premium UI
class AppShadows {
  AppShadows._();

  /// Soft elevation shadow
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.softShadow,
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Medium elevation shadow
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: AppColors.softShadow,
      blurRadius: 30,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Strong elevation shadow
  static List<BoxShadow> get strong => [
    BoxShadow(
      color: AppColors.primaryShadow,
      blurRadius: 40,
      offset: const Offset(0, 12),
      spreadRadius: 0,
    ),
  ];

  /// Card shadow
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  /// Floating button shadow
  static List<BoxShadow> get floating => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Gold glow shadow
  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color: AppColors.secondary.withValues(alpha: 0.4),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Glass shadow for glassmorphism
  static List<BoxShadow> get glass => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];
}


/// Animation Durations and Curves
class AppAnimations {
  AppAnimations._();

  // Durations
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 800);

  // Curves
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutQuart;
}


/// Spacing Constants
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}


/// Border Radius Constants
class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double round = 100;
}
