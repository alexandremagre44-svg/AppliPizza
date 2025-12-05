// lib/src/providers/theme_providers.dart
// Providers for dynamic Server-Driven UI theme
//
// Loads theme from Firestore and converts to Flutter ThemeData

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme_config.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import '../../white_label/runtime/theme_adapter.dart';
import 'restaurant_plan_provider.dart';

// Re-export themeServiceProvider from theme_service.dart
export '../services/theme_service.dart' show themeServiceProvider;

/// FutureProvider for loading theme configuration from Firestore
/// 
/// Usage:
/// ```dart
/// final themeAsync = ref.watch(themeConfigProvider);
/// themeAsync.when(
///   data: (config) => ...,
///   loading: () => ...,
///   error: (e, s) => ...,
/// );
/// ```
final themeConfigProvider = FutureProvider<ThemeConfig>((ref) async {
  final service = ref.watch(themeServiceProvider);
  return service.loadTheme();
});

/// StreamProvider for real-time theme updates
final themeConfigStreamProvider = StreamProvider<ThemeConfig>((ref) {
  final service = ref.watch(themeServiceProvider);
  return service.watchTheme();
});

/// Provider that converts ThemeConfig to Flutter ThemeData
/// 
/// Usage in MaterialApp:
/// ```dart
/// final themeAsync = ref.watch(themeConfigProvider);
/// return themeAsync.when(
///   data: (config) {
///     final themeData = ref.watch(currentThemeDataProvider(config));
///     return MaterialApp(theme: themeData, ...);
///   },
///   loading: () => ...,
///   error: (e, s) => ...,
/// );
/// ```
final currentThemeDataProvider = Provider.family<ThemeData, ThemeConfig>((ref, config) {
  return _buildThemeData(config);
});

/// Build Flutter ThemeData from ThemeConfig
ThemeData _buildThemeData(ThemeConfig config) {
  final primary = config.primary;
  final secondary = config.secondary;
  final background = config.background;
  final surface = config.surface;
  final error = config.error;
  final borderRadius = config.borderRadius;
  final fontFamily = config.fontFamily;

  // Compute contrast colors
  final onPrimary = _contrastColor(primary);
  final onSecondary = _contrastColor(secondary);
  final onBackground = _contrastColor(background);
  final onSurface = _contrastColor(surface);
  final onError = _contrastColor(error);

  return ThemeData(
    useMaterial3: true,
    
    // === Color Scheme ===
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primary.withOpacity(0.12),
      onPrimaryContainer: primary,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondary.withOpacity(0.12),
      onSecondaryContainer: secondary,
      surface: surface,
      onSurface: onSurface,
      error: error,
      onError: onError,
      outline: Colors.grey.shade400,
      outlineVariant: Colors.grey.shade200,
      shadow: Colors.black,
      scrim: Colors.black54,
      brightness: Brightness.light,
    ),
    
    // === Background ===
    scaffoldBackgroundColor: background,
    canvasColor: surface,
    
    // === AppBar Theme ===
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: primary,
      foregroundColor: onPrimary,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onPrimary,
      ),
      iconTheme: IconThemeData(color: onPrimary, size: 24),
      actionsIconTheme: IconThemeData(color: onPrimary, size: 24),
    ),
    
    // === Card Theme ===
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius + 4), // Cards slightly larger
      ),
      clipBehavior: Clip.antiAlias,
      color: surface,
      margin: EdgeInsets.zero,
    ),
    
    // === Button Themes ===
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        shadowColor: primary.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: Colors.grey.shade400),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ),
    
    // === Input Decoration Theme ===
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: error),
      ),
      labelStyle: TextStyle(
        fontFamily: fontFamily,
        color: Colors.grey.shade600,
      ),
      hintStyle: TextStyle(
        fontFamily: fontFamily,
        color: Colors.grey.shade500,
      ),
    ),
    
    // === Bottom Navigation Bar ===
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
      ),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    
    // === Dialog Theme ===
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius * 2), // Dialogs larger radius
      ),
    ),
    
    // === Snackbar Theme ===
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey.shade900,
      contentTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    
    // === Chip Theme ===
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade100,
      selectedColor: primary.withOpacity(0.12),
      labelStyle: TextStyle(fontFamily: fontFamily),
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    
    // === Divider Theme ===
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: 1,
    ),
    
    // === Typography ===
    fontFamily: fontFamily,
    fontFamilyFallback: const ['Roboto', 'sans-serif'],
    
    // === Colors ===
    splashColor: primary.withOpacity(0.1),
    highlightColor: primary.withOpacity(0.05),
    hoverColor: Colors.grey.shade50,
    focusColor: primary.withOpacity(0.1),
    disabledColor: Colors.grey.shade400,
  );
}

/// Calculate contrasting text color (black or white) based on background luminance
Color _contrastColor(Color background) {
  final luminance = background.computeLuminance();
  return luminance > 0.5 ? Colors.black : Colors.white;
}

/// State provider for draft theme config (local changes before publish)
final draftThemeConfigProvider = StateProvider<ThemeConfig?>((ref) => null);

/// State provider for tracking unsaved changes
final hasUnsavedThemeChangesProvider = StateProvider<bool>((ref) => false);

/// State provider for loading state
final themeLoadingProvider = StateProvider<bool>((ref) => false);

/// State provider for saving state
final themeSavingProvider = StateProvider<bool>((ref) => false);

// ========================================================================
// PHASE 4: Unified Theme Provider (WhiteLabel Integration)
// ========================================================================

/// Provider unifié pour le thème basé sur RestaurantPlanUnified.
///
/// Cette provider implémente la logique suivante:
/// 1. Si RestaurantPlanUnified absent → utiliser le thème legacy (AppTheme.lightTheme)
/// 2. Si module thème OFF → utiliser le thème par défaut du template
/// 3. Si module thème ON → utiliser ThemeAdapter.toAppTheme(plan.theme!)
///
/// Le thème legacy reste le fallback total si aucune configuration n'est disponible.
///
/// Usage dans MaterialApp:
/// ```dart
/// Widget build(BuildContext context, WidgetRef ref) {
///   final theme = ref.watch(unifiedThemeProvider);
///   return MaterialApp(
///     theme: theme,
///     ...
///   );
/// }
/// ```
final unifiedThemeProvider = Provider<ThemeData>(
  (ref) {
    // Charger le plan unifié du restaurant
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    
    // Extraire le plan si disponible
    final plan = planAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );
    
    // Cas 1: Pas de plan → fallback sur le thème legacy
    if (plan == null) {
      return AppTheme.lightTheme;
    }
    
    // Cas 2: Plan existe - vérifier le module thème
    final themeModule = plan.theme;
    
    // Cas 2a: Module thème absent ou désactivé → thème du template
    if (themeModule == null || !themeModule.enabled) {
      return ThemeAdapter.defaultThemeForTemplate(plan.templateId);
    }
    
    // Cas 2b: Module thème activé → utiliser la config WhiteLabel
    return ThemeAdapter.toAppTheme(themeModule);
  },
  dependencies: [restaurantPlanUnifiedProvider],
);
