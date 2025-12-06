import '../core/module_id.dart';
import 'restaurant_plan_unified.dart';

/// Feature flags pour un restaurant, permettant de vérifier rapidement
/// si un module est activé.
///
/// Cette classe est un PROXY vers RestaurantPlanUnified et ne stocke
/// AUCUNE donnée propre. Elle délègue tous les appels au plan unifié,
/// qui est la source unique de vérité pour les modules activés.
///
/// IMPORTANT: Ne plus créer cette classe à partir de Firestore.
/// Utilisez uniquement le constructeur principal avec RestaurantPlanUnified.
class RestaurantFeatureFlags {
  /// Plan unifié du restaurant (source unique de vérité).
  final RestaurantPlanUnified plan;

  /// Constructeur principal.
  /// 
  /// C'est le SEUL constructeur qui doit être utilisé.
  /// Le plan unifié est la source unique de vérité.
  const RestaurantFeatureFlags(this.plan);

  /// Identifiant du restaurant (délégué au plan).
  String get restaurantId => plan.restaurantId;

  /// DEPRECATED: Ne plus utiliser fromMap.
  /// 
  /// RestaurantFeatureFlags ne doit plus être construit à partir de Firestore.
  /// Utilisez RestaurantPlanUnified à la place.
  factory RestaurantFeatureFlags.fromMap(Map<String, dynamic> data) {
    throw UnimplementedError(
      'RestaurantFeatureFlags ne doit plus être construit à partir de Firestore. '
      'Utilisez RestaurantPlanUnified à la place.',
    );
  }

  /// DEPRECATED: Ne plus utiliser fromConfig.
  /// 
  /// RestaurantFeatureFlags ne doit plus être construit à partir de Firestore.
  /// Utilisez RestaurantPlanUnified à la place.
  factory RestaurantFeatureFlags.fromConfig(
    String restaurantId,
    List<dynamic> configs,
  ) {
    throw UnimplementedError(
      'RestaurantFeatureFlags ne doit plus être construit à partir de Firestore. '
      'Utilisez RestaurantPlanUnified à la place.',
    );
  }

  /// DEPRECATED: Ne plus utiliser fromModuleCodes.
  /// 
  /// RestaurantFeatureFlags ne doit plus être construit à partir de Firestore.
  /// Utilisez RestaurantPlanUnified à la place.
  factory RestaurantFeatureFlags.fromModuleCodes(
    String restaurantId,
    List<String> moduleCodes,
  ) {
    throw UnimplementedError(
      'RestaurantFeatureFlags ne doit plus être construit à partir de Firestore. '
      'Utilisez RestaurantPlanUnified à la place.',
    );
  }

  /// DEPRECATED: Ne plus utiliser fromModules.
  /// 
  /// RestaurantFeatureFlags ne doit plus être construit à partir de Firestore.
  /// Utilisez RestaurantPlanUnified à la place.
  factory RestaurantFeatureFlags.fromModules(
    String restaurantId,
    List<dynamic> modules,
  ) {
    throw UnimplementedError(
      'RestaurantFeatureFlags ne doit plus être construit à partir de Firestore. '
      'Utilisez RestaurantPlanUnified à la place.',
    );
  }

  // ========== Getters pour compatibilité avec l'ancien code ==========

  /// Vérifie si le module fidélité est activé.
  bool get loyaltyEnabled => plan.hasModule(ModuleId.loyalty);

  /// Vérifie si le module roulette est activé.
  bool get rouletteEnabled => plan.hasModule(ModuleId.roulette);

  /// Vérifie si le module promotions est activé.
  bool get promotionsEnabled => plan.hasModule(ModuleId.promotions);

  /// Vérifie si le module tablette cuisine est activé.
  bool get kitchenEnabled => plan.hasModule(ModuleId.kitchen_tablet);

  /// Vérifie si le module thème est activé.
  bool get themeEnabled => plan.hasModule(ModuleId.theme);

  /// Vérifie si le module livraison est activé.
  bool get deliveryEnabled => plan.hasModule(ModuleId.delivery);

  /// Vérifie si le module commandes en ligne est activé.
  bool get orderingEnabled => plan.hasModule(ModuleId.ordering);

  /// Vérifie si le module Click & Collect est activé.
  bool get clickAndCollectEnabled => plan.hasModule(ModuleId.clickAndCollect);

  /// Vérifie si le module newsletter est activé.
  bool get newsletterEnabled => plan.hasModule(ModuleId.newsletter);

  /// Vérifie si le module constructeur de pages est activé.
  bool get pagesBuilderEnabled => plan.hasModule(ModuleId.pagesBuilder);

  // ========== Méthodes publiques (délèguent au plan) ==========

  /// Vérifie si un module est activé.
  bool has(ModuleId id) {
    return plan.hasModule(id);
  }

  /// Vérifie si tous les modules spécifiés sont activés.
  bool hasAll(List<ModuleId> ids) {
    return ids.every((id) => plan.hasModule(id));
  }

  /// Vérifie si au moins un des modules spécifiés est activé.
  bool hasAny(List<ModuleId> ids) {
    return ids.any((id) => plan.hasModule(id));
  }

  /// Retourne la liste des modules activés.
  List<ModuleId> get enabledModules {
    return plan.enabledModuleIds;
  }

  /// Retourne la liste des modules désactivés.
  List<ModuleId> get disabledModules {
    return ModuleId.values
        .where((id) => !plan.hasModule(id))
        .toList();
  }

  @override
  String toString() {
    final enabledCount = plan.activeModules.length;
    return 'RestaurantFeatureFlags(restaurantId: $restaurantId, '
        'enabled: $enabledCount modules via RestaurantPlanUnified)';
  }
}
