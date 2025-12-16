/// lib/white_label/theme/unified_theme_provider.dart
///
/// WHITE-LABEL V2 - Provider Unifié de Thème
///
/// Lit ThemeSettings depuis RestaurantPlanUnified et génère ThemeData.
/// Support hot reload Firestore et fallback automatique.
///
/// Responsabilités:
/// - Lecture depuis RestaurantPlanUnified.modules.theme.settings
/// - Conversion Map<String, dynamic> → ThemeSettings
/// - Fallback sur thème par défaut si module désactivé
/// - Support stream temps réel
/// - Garantie zéro crash
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_settings.dart';
import 'unified_theme_adapter.dart';
import '../restaurant/restaurant_plan_unified.dart';
import '../../src/providers/restaurant_plan_provider.dart';
import '../../src/design_system/app_theme.dart' show AppTheme;

/// Provider pour ThemeSettings depuis RestaurantPlanUnified.
///
/// Lit la configuration de thème depuis modules.theme.settings du plan unifié.
/// Retourne ThemeSettings.defaultConfig() si:
/// - Le plan n'est pas chargé
/// - Le module theme est désactivé
/// - Les settings sont invalides ou absents
///
/// Usage:
/// ```dart
/// final settings = ref.watch(themeSettingsProvider);
/// ```
final themeSettingsProvider = Provider<ThemeSettings>(
  (ref) {
    // Charger le plan unifié
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);

    // Extraire le plan si disponible
    final plan = planAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );

    // Cas 1: Pas de plan → utiliser config par défaut
    if (plan == null) {
      debugPrint('[ThemeSettings] No restaurant plan, using default config');
      return ThemeSettings.defaultConfig();
    }

    // Cas 2: Plan existe - vérifier le module thème
    final themeModule = plan.theme;

    // Cas 2a: Module thème absent ou désactivé → config par défaut
    if (themeModule == null || !themeModule.enabled) {
      debugPrint('[ThemeSettings] Theme module disabled, using default config');
      return ThemeSettings.defaultConfig();
    }

    // Cas 2b: Module thème activé → lire settings
    try {
      final settingsMap = themeModule.settings;
      if (settingsMap.isEmpty) {
        debugPrint('[ThemeSettings] Theme settings empty, using default config');
        return ThemeSettings.defaultConfig();
      }

      // Convertir Map → ThemeSettings
      final settings = ThemeSettings.fromJson(settingsMap);

      // Valider les settings
      if (!settings.validate()) {
        debugPrint('[ThemeSettings] Theme settings validation failed, using default config');
        return ThemeSettings.defaultConfig();
      }

      debugPrint('[ThemeSettings] Loaded custom theme: ${settings.primaryColor}');
      return settings;
    } catch (e, stackTrace) {
      debugPrint('[ThemeSettings] Error loading theme settings: $e');
      debugPrint('Stack trace: $stackTrace');
      return ThemeSettings.defaultConfig();
    }
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Provider unifié pour le thème Material 3.
///
/// CETTE PROVIDER EST LA SOURCE UNIQUE DE VÉRITÉ POUR LE THÈME.
///
/// Workflow:
/// 1. Lit ThemeSettings depuis themeSettingsProvider
/// 2. Convertit ThemeSettings → ThemeData via UnifiedThemeAdapter
/// 3. Fallback sur AppTheme.lightTheme en cas d'erreur critique
///
/// Garanties:
/// - Aucun crash possible
/// - Toujours un thème valide
/// - Hot reload Firestore automatique
/// - Contrastes minimum respectés
///
/// Usage dans MaterialApp:
/// ```dart
/// @override
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
    try {
      // Lire les settings
      final settings = ref.watch(themeSettingsProvider);

      // Convertir en ThemeData
      final themeData = UnifiedThemeAdapter.toThemeData(settings);

      debugPrint('[UnifiedTheme] Theme applied: ${settings.primaryColor}');
      return themeData;
    } catch (e, stackTrace) {
      debugPrint('[UnifiedTheme] Critical error, using AppTheme.lightTheme: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Fallback ultime sur le thème legacy
      return AppTheme.lightTheme;
    }
  },
  dependencies: [themeSettingsProvider],
);

/// Provider pour détecter les changements de thème.
///
/// Retourne true si le thème custom est chargé (module activé).
/// Retourne false si le thème par défaut est utilisé.
///
/// Utile pour l'UI admin pour montrer l'état de personnalisation.
final isCustomThemeActiveProvider = Provider<bool>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );

    if (plan == null) return false;

    final themeModule = plan.theme;
    return themeModule != null && themeModule.enabled;
  },
  dependencies: [restaurantPlanUnifiedProvider],
);
