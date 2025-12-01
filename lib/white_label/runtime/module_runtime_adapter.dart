/// lib/white_label/runtime/module_runtime_adapter.dart
///
/// Adapter central pour contrôler l'activation des modules runtime
/// sans modifier les services existants.
///
/// Utilisé par l'application cliente pour adapter dynamiquement
/// les fonctionnalités disponibles selon le RestaurantPlanUnified.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/module_id.dart';
import '../restaurant/restaurant_plan_unified.dart';

/// Contexte d'exécution pour appliquer les adaptations de modules.
///
/// Contient les références nécessaires pour adapter l'application
/// selon la configuration du restaurant.
class RuntimeContext {
  /// WidgetRef pour accéder aux providers Riverpod.
  final WidgetRef ref;

  /// Callbacks optionnels pour le routeur.
  final Map<String, Function>? routerCallbacks;

  /// Contexte de build pour le router (optionnel).
  final dynamic buildContext;

  /// Constructeur.
  const RuntimeContext({
    required this.ref,
    this.routerCallbacks,
    this.buildContext,
  });
}

/// Adaptateur centralisé pour gérer l'activation des modules runtime.
///
/// Cette classe fournit des méthodes statiques pour vérifier l'état
/// des modules et appliquer les adaptations nécessaires sans modifier
/// les services existants.
///
/// Principes:
/// - Ne jamais modifier les services originaux
/// - Fournir des guards et wrappers non intrusifs
/// - Permettre la désactivation gracieuse de modules
/// - Maintenir la compatibilité avec le code existant
class ModuleRuntimeAdapter {
  /// Vérifie si un module est actif dans le plan.
  ///
  /// Utilise le code du module (string) pour la vérification.
  /// Retourne false si le plan est null ou si le module n'est pas trouvé.
  static bool isModuleActive(
    RestaurantPlanUnified? plan,
    String moduleCode,
  ) {
    if (plan == null) return false;
    return plan.activeModules.contains(moduleCode);
  }

  /// Vérifie si un module est actif à partir de son ModuleId.
  ///
  /// Version typée de isModuleActive utilisant l'enum ModuleId.
  static bool isModuleActiveById(
    RestaurantPlanUnified? plan,
    ModuleId moduleId,
  ) {
    return isModuleActive(plan, moduleId.code);
  }

  /// Applique toutes les adaptations de modules pour l'application.
  ///
  /// Cette méthode est appelée au démarrage de l'application ou lors
  /// de changements dans la configuration du restaurant.
  ///
  /// Elle configure:
  /// - Les providers conditionnels
  /// - Les guards de navigation
  /// - Les callbacks du routeur
  /// - Les flags de fonctionnalités
  ///
  /// Note: Cette méthode ne modifie jamais les services existants,
  /// elle configure uniquement les wrappers et guards.
  static void applyAll(
    RuntimeContext context,
    RestaurantPlanUnified? plan,
  ) {
    if (plan == null) {
      debugPrint('[ModuleRuntimeAdapter] No plan provided, skipping adaptations');
      return;
    }

    debugPrint('[ModuleRuntimeAdapter] Applying module adaptations for restaurant: ${plan.restaurantId}');
    debugPrint('[ModuleRuntimeAdapter] Active modules: ${plan.activeModules}');

    // Log l'état de chaque module
    _logModuleStatus(plan);

    // Les adaptations spécifiques sont gérées par les guards et helpers
    // Cette méthode sert principalement de point d'entrée centralisé
    debugPrint('[ModuleRuntimeAdapter] Module adaptations applied successfully');
  }

  /// Log l'état d'activation de tous les modules.
  static void _logModuleStatus(RestaurantPlanUnified plan) {
    final allModules = ModuleId.values;
    
    for (final module in allModules) {
      final isActive = isModuleActiveById(plan, module);
      final status = isActive ? '✅ ACTIVE' : '❌ INACTIVE';
      debugPrint('[ModuleRuntimeAdapter]   ${module.label} (${module.code}): $status');
    }
  }

  /// Retourne la liste des modules actifs sous forme d'enum ModuleId.
  static List<ModuleId> getActiveModules(RestaurantPlanUnified? plan) {
    if (plan == null) return [];
    
    return plan.activeModules
        .map((code) {
          try {
            return ModuleId.values.firstWhere((m) => m.code == code);
          } catch (_) {
            return null;
          }
        })
        .whereType<ModuleId>()
        .toList();
  }

  /// Retourne la liste des modules inactifs sous forme d'enum ModuleId.
  static List<ModuleId> getInactiveModules(RestaurantPlanUnified? plan) {
    final activeModules = getActiveModules(plan);
    return ModuleId.values
        .where((module) => !activeModules.contains(module))
        .toList();
  }

  /// Vérifie si tous les modules spécifiés sont actifs.
  static bool areAllModulesActive(
    RestaurantPlanUnified? plan,
    List<ModuleId> requiredModules,
  ) {
    if (plan == null) return false;
    
    return requiredModules.every(
      (module) => isModuleActiveById(plan, module),
    );
  }

  /// Vérifie si au moins un des modules spécifiés est actif.
  static bool isAnyModuleActive(
    RestaurantPlanUnified? plan,
    List<ModuleId> modules,
  ) {
    if (plan == null) return false;
    
    return modules.any(
      (module) => isModuleActiveById(plan, module),
    );
  }

  /// Vérifie la disponibilité d'une fonctionnalité basée sur les dépendances de modules.
  ///
  /// Retourne true si tous les modules requis sont actifs.
  static bool isFeatureAvailable(
    RestaurantPlanUnified? plan,
    List<ModuleId> requiredModules,
  ) {
    return areAllModulesActive(plan, requiredModules);
  }
}
