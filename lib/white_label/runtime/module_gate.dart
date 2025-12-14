/// lib/white_label/runtime/module_gate.dart
///
/// COUCHE CENTRALE DE MODULARITÉ (Module Gate)
///
/// Cette couche est la SOURCE UNIQUE DE VÉRITÉ pour déterminer :
/// - Quels modules sont actifs
/// - Quels types de commande sont autorisés
/// - Quelles fonctionnalités sont disponibles
///
/// RÈGLE ABSOLUE :
/// - Aucune UI, aucun service, aucun resolver ne lit directement RestaurantPlanUnified
/// - TOUT passe par ModuleGate
/// - Méthodes pures et testables
/// - Pas de logique dispersée dans l'application
library;

import '../core/module_id.dart';
import '../restaurant/restaurant_plan_unified.dart';

/// Service central de modularité - Module Gate.
///
/// Ce service expose des méthodes pures pour vérifier l'état des modules
/// et déterminer quelles fonctionnalités sont disponibles.
///
/// Usage:
/// ```dart
/// final gate = ModuleGate(plan);
/// if (gate.isModuleEnabled(ModuleId.delivery)) {
///   // Module livraison activé
/// }
/// 
/// final types = gate.allowedOrderTypes();
/// // Affiche uniquement les types de commande autorisés
/// ```
class ModuleGate {
  /// Plan restaurant utilisé pour la vérification des modules.
  final RestaurantPlanUnified? plan;

  /// Comportement par défaut quand le plan est null.
  /// - true: autorise tout (rétrocompatibilité)
  /// - false: refuse tout (mode strict)
  final bool allowWhenPlanNull;

  const ModuleGate({
    required this.plan,
    this.allowWhenPlanNull = true,
  });

  /// Vérifie si un module est activé.
  ///
  /// Retourne:
  /// - true si le module est dans activeModules du plan
  /// - false si le module n'est pas activé
  /// - allowWhenPlanNull si le plan est null
  ///
  /// Exemple:
  /// ```dart
  /// if (gate.isModuleEnabled(ModuleId.delivery)) {
  ///   // Afficher l'option livraison
  /// }
  /// ```
  bool isModuleEnabled(ModuleId moduleId) {
    if (plan == null) {
      return allowWhenPlanNull;
    }
    return plan!.hasModule(moduleId);
  }

  /// Vérifie si un type de commande est autorisé.
  ///
  /// Mapping OrderType -> ModuleId:
  /// - 'delivery' -> ModuleId.delivery
  /// - 'click_collect' -> ModuleId.clickAndCollect
  /// - 'dine_in' -> toujours autorisé (service de base)
  /// - 'takeaway' -> toujours autorisé (service de base)
  ///
  /// Retourne:
  /// - true si le type est un service de base OU si son module est activé
  /// - false sinon
  ///
  /// Exemple:
  /// ```dart
  /// if (gate.isOrderTypeAllowed('delivery')) {
  ///   // Afficher le formulaire de livraison
  /// }
  /// ```
  bool isOrderTypeAllowed(String orderType) {
    switch (orderType) {
      // Services de base - toujours autorisés
      case 'dine_in':
      case 'takeaway':
        return true;

      // Livraison - nécessite le module delivery
      case 'delivery':
        return isModuleEnabled(ModuleId.delivery);

      // Click & Collect - nécessite le module clickAndCollect
      case 'click_collect':
        return isModuleEnabled(ModuleId.clickAndCollect);

      // Type inconnu - refusé par défaut
      default:
        return false;
    }
  }

  /// Retourne la liste des types de commande autorisés.
  ///
  /// Filtre les types de commande en fonction des modules actifs.
  /// Les services de base (dine_in, takeaway) sont toujours inclus.
  ///
  /// Retourne une liste de codes OrderType (strings).
  ///
  /// Exemple:
  /// ```dart
  /// final types = gate.allowedOrderTypes();
  /// // ['dine_in', 'takeaway', 'delivery'] si delivery est activé
  /// ```
  List<String> allowedOrderTypes() {
    final types = <String>[];

    // Services de base - toujours autorisés
    types.add('dine_in');
    types.add('takeaway');

    // Livraison - si module activé
    if (isModuleEnabled(ModuleId.delivery)) {
      types.add('delivery');
    }

    // Click & Collect - si module activé
    if (isModuleEnabled(ModuleId.clickAndCollect)) {
      types.add('click_collect');
    }

    return types;
  }

  /// Retourne la liste des modules activés.
  ///
  /// Raccourci pour accéder aux modules actifs depuis le plan.
  ///
  /// Exemple:
  /// ```dart
  /// final modules = gate.enabledModules();
  /// print('Modules actifs: ${modules.length}');
  /// ```
  List<String> enabledModules() {
    if (plan == null) {
      return [];
    }
    return List<String>.from(plan!.activeModules);
  }

  /// Vérifie si tous les modules spécifiés sont activés.
  ///
  /// Retourne true seulement si TOUS les modules sont activés.
  ///
  /// Exemple:
  /// ```dart
  /// if (gate.hasAllModules([ModuleId.delivery, ModuleId.payments])) {
  ///   // Les deux modules sont activés
  /// }
  /// ```
  bool hasAllModules(List<ModuleId> moduleIds) {
    for (final moduleId in moduleIds) {
      if (!isModuleEnabled(moduleId)) {
        return false;
      }
    }
    return true;
  }

  /// Vérifie si au moins un des modules est activé.
  ///
  /// Retourne true si AU MOINS UN module est activé.
  ///
  /// Exemple:
  /// ```dart
  /// if (gate.hasAnyModule([ModuleId.delivery, ModuleId.clickAndCollect])) {
  ///   // Au moins une option de retrait/livraison disponible
  /// }
  /// ```
  bool hasAnyModule(List<ModuleId> moduleIds) {
    for (final moduleId in moduleIds) {
      if (isModuleEnabled(moduleId)) {
        return true;
      }
    }
    return false;
  }

  /// Crée un ModuleGate permissif (autorise tout).
  ///
  /// Utile pour les tests ou la rétrocompatibilité.
  factory ModuleGate.permissive() {
    return const ModuleGate(
      plan: null,
      allowWhenPlanNull: true,
    );
  }

  /// Crée un ModuleGate strict (refuse tout).
  ///
  /// Utile pour les tests de scénarios d'échec.
  factory ModuleGate.strict() {
    return const ModuleGate(
      plan: null,
      allowWhenPlanNull: false,
    );
  }

  @override
  String toString() {
    return 'ModuleGate(plan: ${plan?.restaurantId ?? 'null'}, '
        'modules: ${enabledModules().length})';
  }
}
