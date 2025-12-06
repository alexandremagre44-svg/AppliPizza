/// lib/white_label/runtime/module_enabled_provider.dart
///
/// Provider global pour contrôler strictement l'activation des modules White-Label.
///
/// Quand un module est désactivé par le SuperAdmin dans RestaurantPlanUnified,
/// il doit être totalement supprimé pour le restaurant :
/// – côté client
/// – côté admin
/// – côté builder
/// – dans les routes
/// – dans les services runtime.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../src/providers/restaurant_plan_provider.dart';
import '../core/module_id.dart';

/// Provider global pour vérifier si un module est activé pour le restaurant courant.
///
/// Ce provider est la source de vérité unique pour tous les contrôles de modules
/// dans l'application. Il utilise le `RestaurantPlanUnified` comme source de données.
///
/// **Usage dans les widgets:**
/// ```dart
/// final isRouletteEnabled = ref.watch(moduleEnabledProvider(ModuleId.roulette));
/// if (isRouletteEnabled) {
///   // Afficher le contenu du module roulette
/// }
/// ```
///
/// **Usage dans les guards de routes:**
/// ```dart
/// final isModuleEnabled = ref.read(moduleEnabledProvider(moduleId));
/// if (!isModuleEnabled) {
///   return '/home'; // Rediriger si module désactivé
/// }
/// ```
///
/// **Usage dans le Builder B3:**
/// ```dart
/// // Dans les blocs runtime
/// final isLoyaltyEnabled = ref.watch(moduleEnabledProvider(ModuleId.loyalty));
/// if (!isLoyaltyEnabled) {
///   return const SizedBox.shrink(); // Masquer le bloc
/// }
/// ```
///
/// **Avantages:**
/// - Source de vérité unique
/// - Réactivité automatique (rebuild quand le plan change)
/// - Type-safe avec enum ModuleId
/// - Compatible avec .family pour performance
/// - Gestion automatique des états loading/error
///
/// **Retourne:**
/// - `true` si le module est dans la liste activeModules du plan
/// - `false` si le module n'est pas activé
/// - `false` si le plan n'est pas encore chargé (loading)
/// - `false` si une erreur s'est produite lors du chargement
final moduleEnabledProvider = Provider.family<bool, ModuleId>(
  (ref, moduleId) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    
    return planAsync.when(
      data: (plan) {
        if (plan == null) return false;
        return plan.hasModule(moduleId);
      },
      loading: () => false,
      error: (_, __) => false,
    );
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Provider pour vérifier si plusieurs modules sont tous activés.
///
/// Retourne true seulement si TOUS les modules spécifiés sont activés.
///
/// **Usage:**
/// ```dart
/// final allEnabled = ref.watch(allModulesEnabledProvider([
///   ModuleId.loyalty,
///   ModuleId.roulette,
/// ]));
/// if (allEnabled) {
///   // Les deux modules sont activés
/// }
/// ```
final allModulesEnabledProvider = Provider.family<bool, List<ModuleId>>(
  (ref, moduleIds) {
    for (final moduleId in moduleIds) {
      final isEnabled = ref.watch(moduleEnabledProvider(moduleId));
      if (!isEnabled) {
        return false;
      }
    }
    return true;
  },
  dependencies: [moduleEnabledProvider],
);

/// Provider pour vérifier si au moins un des modules est activé.
///
/// Retourne true si AU MOINS UN des modules spécifiés est activé.
///
/// **Usage:**
/// ```dart
/// final anyEnabled = ref.watch(anyModuleEnabledProvider([
///   ModuleId.delivery,
///   ModuleId.clickAndCollect,
/// ]));
/// if (anyEnabled) {
///   // Au moins une option de retrait/livraison est disponible
/// }
/// ```
final anyModuleEnabledProvider = Provider.family<bool, List<ModuleId>>(
  (ref, moduleIds) {
    for (final moduleId in moduleIds) {
      final isEnabled = ref.watch(moduleEnabledProvider(moduleId));
      if (isEnabled) {
        return true;
      }
    }
    return false;
  },
  dependencies: [moduleEnabledProvider],
);

/// Provider pour obtenir la liste de tous les modules activés.
///
/// Retourne une liste de tous les ModuleId activés pour le restaurant courant.
///
/// **Usage:**
/// ```dart
/// final enabledModules = ref.watch(enabledModulesListProvider);
/// print('${enabledModules.length} modules activés');
/// for (final moduleId in enabledModules) {
///   print('Module activé: ${moduleId.label}');
/// }
/// ```
final enabledModulesListProvider = Provider<List<ModuleId>>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    
    return planAsync.when(
      data: (plan) {
        if (plan == null) return [];
        return plan.enabledModuleIds;
      },
      loading: () => [],
      error: (_, __) => [],
    );
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Provider pour obtenir le nombre total de modules activés.
///
/// **Usage:**
/// ```dart
/// final count = ref.watch(enabledModulesCountProvider);
/// Text('$count modules activés');
/// ```
final enabledModulesCountProvider = Provider<int>(
  (ref) {
    final enabledModules = ref.watch(enabledModulesListProvider);
    return enabledModules.length;
  },
  dependencies: [enabledModulesListProvider],
);

/// Helper function pour vérifier un module de manière synchrone (non-reactive).
///
/// À utiliser uniquement dans les cas où vous ne pouvez pas utiliser ref.watch
/// (par exemple, dans des fonctions utilitaires ou des callbacks).
///
/// **Préférez utiliser moduleEnabledProvider dans les widgets pour la réactivité.**
///
/// **Usage:**
/// ```dart
/// bool checkModule(WidgetRef ref, ModuleId id) {
///   return isModuleEnabledSync(ref, id);
/// }
/// ```
bool isModuleEnabledSync(WidgetRef ref, ModuleId moduleId) {
  return ref.read(moduleEnabledProvider(moduleId));
}

/// Helper function pour vérifier plusieurs modules de manière synchrone.
///
/// **Usage:**
/// ```dart
/// bool checkModules(WidgetRef ref) {
///   return areModulesEnabledSync(ref, [ModuleId.loyalty, ModuleId.roulette]);
/// }
/// ```
bool areModulesEnabledSync(WidgetRef ref, List<ModuleId> moduleIds) {
  for (final moduleId in moduleIds) {
    if (!ref.read(moduleEnabledProvider(moduleId))) {
      return false;
    }
  }
  return true;
}

/// Helper function pour vérifier si au moins un module est activé (synchrone).
///
/// **Usage:**
/// ```dart
/// bool checkAnyModule(WidgetRef ref) {
///   return isAnyModuleEnabledSync(ref, [ModuleId.delivery, ModuleId.clickAndCollect]);
/// }
/// ```
bool isAnyModuleEnabledSync(WidgetRef ref, List<ModuleId> moduleIds) {
  for (final moduleId in moduleIds) {
    if (ref.read(moduleEnabledProvider(moduleId))) {
      return true;
    }
  }
  return false;
}
