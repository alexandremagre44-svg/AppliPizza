// lib/src/design_system/app_theme.dart
// Thème principal et configuration - Design System Pizza Deli'Zza

import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'spacing.dart';
import 'radius.dart';
import 'shadows.dart';

// Export all design system components
export 'colors.dart';
export 'text_styles.dart';
export 'spacing.dart';
export 'radius.dart';
export 'shadows.dart';
export 'buttons.dart';
export 'inputs.dart';
export 'cards.dart';
export 'badges.dart';
export 'tables.dart';
export 'dialogs.dart';
export 'sections.dart';

/// Configuration du thème de l'application Pizza Deli'Zza
/// 
/// Utilisation:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   ...
/// )
/// ```
class AppTheme {
  // ═══════════════════════════════════════════════════════════════
  // RÉTROCOMPATIBILITÉ - Aliases vers les nouvelles couleurs
  // ═══════════════════════════════════════════════════════════════
  
  static const Color primaryRed = AppColors.primary;
  static const Color primaryRedLight = AppColors.primaryLight;
  static const Color primaryRedDark = AppColors.primaryDark;
  static const Color surfaceWhite = AppColors.white;
  static const Color backgroundLight = AppColors.background;
  static const Color textDark = AppColors.textPrimary;
  static const Color textMedium = AppColors.textSecondary;
  static const Color textLight = AppColors.textTertiary;
  static const Color accentGold = AppColors.accentGold;
  static const Color accentGreen = AppColors.accentGreen;
  static const Color successGreen = AppColors.success;
  static const Color errorRed = AppColors.danger;
  static const Color warningOrange = AppColors.warning;
  static const Color infoBlue = AppColors.info;

  // ═══════════════════════════════════════════════════════════════
  // THEME PRINCIPAL - Light Theme
  // ═══════════════════════════════════════════════════════════════
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // === Color Scheme ===
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primaryLighter,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.white,
        tertiary: AppColors.accentGold,
        onTertiary: AppColors.textPrimary,
        error: AppColors.danger,
        onError: AppColors.white,
        errorContainer: AppColors.dangerLight,
        onErrorContainer: AppColors.dangerDark,
        surface: AppColors.white,
        onSurface: AppColors.textPrimary,
        surfaceVariant: AppColors.neutral100,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.borderSubtle,
        shadow: AppColors.black.withOpacity(0.15),
        scrim: AppColors.overlay,
        inverseSurface: AppColors.neutral900,
        onInverseSurface: AppColors.white,
        inversePrimary: AppColors.primaryLight,
        brightness: Brightness.light,
      ),
      
      // === Background Colors ===
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.white,
      
      // === AppBar Theme ===
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.white,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.white,
          size: 24,
        ),
      ),
      
      // === Card Theme ===
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: AppColors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
        clipBehavior: Clip.antiAlias,
        color: AppColors.white,
        margin: EdgeInsets.zero,
      ),
      
      // === Button Themes ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.3),
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTextStyles.button,
          disabledBackgroundColor: AppColors.neutral300,
          disabledForegroundColor: AppColors.neutral500,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonPaddingSmall,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primary,
          iconSize: 24,
        ),
      ),
      
      // === Input Decoration Theme ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: AppSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.neutral200),
        ),
        labelStyle: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: AppTextStyles.titleSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral500,
        ),
        helperStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.danger,
        ),
      ),
      
      // === Checkbox Theme ===
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.white;
        }),
        checkColor: MaterialStateProperty.all(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXS,
        ),
      ),
      
      // === Radio Theme ===
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.neutral600;
        }),
      ),
      
      // === Switch Theme ===
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.neutral400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary.withOpacity(0.5);
          }
          return AppColors.neutral300;
        }),
      ),
      
      // === Divider Theme ===
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      
      // === Bottom Navigation Bar Theme ===
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      
      // === Snackbar Theme ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral900,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.button,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 3,
      ),
      
      // === Dialog Theme ===
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialog,
        ),
        titleTextStyle: AppTextStyles.headlineMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),
      
      // === Tooltip Theme ===
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.neutral900,
          borderRadius: AppRadius.tooltip,
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      
      // === Chip Theme ===
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        deleteIconColor: AppColors.neutral600,
        disabledColor: AppColors.neutral200,
        selectedColor: AppColors.primaryLighter,
        secondarySelectedColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        labelStyle: AppTextStyles.labelMedium,
        secondaryLabelStyle: AppTextStyles.labelMedium,
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chip,
        ),
      ),
      
      // === Progress Indicator Theme ===
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.neutral200,
        circularTrackColor: AppColors.neutral200,
      ),
      
      // === Slider Theme ===
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.neutral300,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
        ),
      ),
      
      // === Typography ===
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      
      // === Font Family ===
      fontFamily: 'Poppins',
      
      // === Autres ===
      splashColor: AppColors.primary.withOpacity(0.1),
      highlightColor: AppColors.primary.withOpacity(0.05),
      hoverColor: AppColors.neutral50,
      focusColor: AppColors.primary.withOpacity(0.1),
      disabledColor: AppColors.neutral400,
      
      // === Material Banner Theme ===
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: AppColors.neutral100,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),
      
      // === Tab Bar Theme ===
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelLarge,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
          insets: EdgeInsets.zero,
        ),
      ),
      
      // === List Tile Theme ===
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.paddingHorizontalMD,
        minLeadingWidth: 40,
        iconColor: AppColors.neutral600,
        textColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.bodyMedium,
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // HELPERS - Fonctions utilitaires
  // ═══════════════════════════════════════════════════════════════
  
  /// Obtenir le thème actuel
  static ThemeData of(BuildContext context) {
    return Theme.of(context);
  }
  
  /// Obtenir le ColorScheme actuel
  static ColorScheme colorSchemeOf(BuildContext context) {
    return Theme.of(context).colorScheme;
  }
  
  /// Obtenir le TextTheme actuel
  static TextTheme textThemeOf(BuildContext context) {
    return Theme.of(context).textTheme;
  }
}
