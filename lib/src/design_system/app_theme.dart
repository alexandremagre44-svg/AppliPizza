// lib/src/design_system/app_theme.dart
// Thème principal et configuration - Design System Pizza Deli'Zza Material 3 (2025)

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
// Note: sections.dart is not exported to avoid conflicts with widgets/home/section_header.dart

/// Configuration du thème Material 3 de l'application Pizza Deli'Zza
/// 
/// Thème officiel Material 3 (2025) avec la palette Pizza Deli'Zza
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
  // THEME PRINCIPAL - Material 3 Light Theme
  // ═══════════════════════════════════════════════════════════════
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // === Color Scheme Material 3 ===
      colorScheme: const ColorScheme.light(
        // Primary
        primary: AppColors.primary, // #D32F2F
        onPrimary: AppColors.onPrimary, // #FFFFFF
        primaryContainer: AppColors.primaryContainer, // #F9DEDE
        onPrimaryContainer: AppColors.onPrimaryContainer, // #7A1212
        
        // Secondary
        secondary: AppColors.secondary, // #8E4C4C
        onSecondary: AppColors.onSecondary, // #FFFFFF
        secondaryContainer: AppColors.secondaryContainer, // #F5E3E3
        onSecondaryContainer: AppColors.onPrimaryContainer, // #7A1212
        
        // Tertiary
        tertiary: AppColors.accentGold,
        onTertiary: AppColors.textPrimary,
        
        // Error
        error: AppColors.error, // #C62828
        onError: AppColors.white,
        errorContainer: AppColors.errorContainer, // #F9DADA
        onErrorContainer: AppColors.dangerDark,
        
        // Surface & Background
        surface: AppColors.surface, // #FFFFFF
        onSurface: AppColors.onSurface, // #323232
        onSurfaceVariant: AppColors.onSurfaceVariant, // #5A5A5A
        
        // Outline
        outline: AppColors.outline, // #BEBEBE
        outlineVariant: AppColors.outlineVariant, // #E0E0E0
        
        // Shadow & Scrim
        shadow: AppColors.black,
        scrim: AppColors.overlay,
        
        // Inverse
        inverseSurface: AppColors.neutral900,
        onInverseSurface: AppColors.white,
        inversePrimary: AppColors.primaryLight,
        
        brightness: Brightness.light,
      ),
      
      // === Background Colors Material 3 ===
      scaffoldBackgroundColor: AppColors.background, // #FAFAFA
      canvasColor: AppColors.surface,
      
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
      
      // === Card Theme Material 3 ===
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: AppColors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card, // 16px
        ),
        clipBehavior: Clip.antiAlias,
        color: AppColors.surfaceContainerLow, // #F5F5F5
        margin: EdgeInsets.zero,
      ),
      
      // === Button Themes Material 3 ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // #D32F2F
          foregroundColor: AppColors.onPrimary, // #FFFFFF
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.3),
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button, // 12px
          ),
          textStyle: AppTextStyles.labelLarge,
          disabledBackgroundColor: AppColors.neutral300,
          disabledForegroundColor: AppColors.neutral500,
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button, // 12px
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonPaddingSmall,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button, // 12px
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outline, width: 1),
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button, // 12px
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primary,
          iconSize: 24,
        ),
      ),
      
      // === Input Decoration Theme Material 3 ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: AppSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input, // 12px
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.outline), // #BEBEBE
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        labelStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        floatingLabelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
        ),
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        helperStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
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
      
      // === Dialog Theme Material 3 ===
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialog, // 24px Material 3
        ),
        titleTextStyle: AppTextStyles.headlineMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),
      
      // === Bottom Sheet Theme Material 3 ===
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheet, // 24px Material 3
        ),
        clipBehavior: Clip.antiAlias,
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
      
      // === Chip Theme Material 3 ===
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        deleteIconColor: AppColors.onSurfaceVariant,
        disabledColor: AppColors.surfaceContainer,
        selectedColor: AppColors.primaryContainer, // #F9DEDE
        secondarySelectedColor: AppColors.secondaryContainer,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        side: const BorderSide(color: AppColors.outline), // Border primary pour Chips
        labelStyle: AppTextStyles.labelLarge,
        secondaryLabelStyle: AppTextStyles.labelLarge,
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chip, // 16px Material 3
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
      
      // === Font Family Material 3 ===
      fontFamily: 'Inter', // Material 3 - Inter with fallback to Roboto
      fontFamilyFallback: const ['Inter', 'Roboto'],
      
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
      tabBarTheme: TabBarThemeData(
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
