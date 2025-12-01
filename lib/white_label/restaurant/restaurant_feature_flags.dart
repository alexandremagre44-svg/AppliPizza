import '../core/module_config.dart';
import '../core/module_id.dart';

/// Feature flags pour un restaurant, permettant de vérifier rapidement
/// si un module est activé.
///
/// Cette classe offre une vue simplifiée des modules activés pour un
/// restaurant, optimisée pour les vérifications rapides à l'exécution.
class RestaurantFeatureFlags {
  /// Identifiant du restaurant.
  final String restaurantId;

  /// Map des modules et leur état d'activation.
  final Map<ModuleId, bool> enabled;

  /// Constructeur.
  const RestaurantFeatureFlags({
    required this.restaurantId,
    this.enabled = const {},
  });

  /// Crée des feature flags à partir d'une liste de configurations de modules.
  factory RestaurantFeatureFlags.fromConfig(
    String restaurantId,
    List<ModuleConfig> configs,
  ) {
    final enabledMap = <ModuleId, bool>{};
    for (final config in configs) {
      enabledMap[config.id] = config.enabled;
    }
    return RestaurantFeatureFlags(
      restaurantId: restaurantId,
      enabled: enabledMap,
    );
  }

  /// Crée des feature flags à partir d'une liste de codes de modules (String).
  /// 
  /// Utilisé avec RestaurantPlanUnified où activeModules est une List<String>.
  factory RestaurantFeatureFlags.fromModuleCodes(
    String restaurantId,
    List<String> moduleCodes,
  ) {
    final enabledMap = <ModuleId, bool>{};
    for (final code in moduleCodes) {
      try {
        final moduleId = ModuleId.values.firstWhere((m) => m.code == code);
        enabledMap[moduleId] = true;
      } catch (_) {
        // Ignorer les codes de modules inconnus
      }
    }
    return RestaurantFeatureFlags(
      restaurantId: restaurantId,
      enabled: enabledMap,
    );
  }

  /// Alias de [fromConfig] - crée des feature flags à partir des modules.
  factory RestaurantFeatureFlags.fromModules(
    String restaurantId,
    List<ModuleConfig> modules,
  ) {
    return RestaurantFeatureFlags.fromConfig(restaurantId, modules);
  }

  /// Vérifie si un module est activé.
  bool has(ModuleId id) {
    return enabled[id] ?? false;
  }

  /// Vérifie si tous les modules spécifiés sont activés.
  bool hasAll(List<ModuleId> ids) {
    return ids.every((id) => has(id));
  }

  /// Vérifie si au moins un des modules spécifiés est activé.
  bool hasAny(List<ModuleId> ids) {
    return ids.any((id) => has(id));
  }

  /// Retourne la liste des modules activés.
  List<ModuleId> get enabledModules {
    return enabled.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
  }

  /// Retourne la liste des modules désactivés.
  List<ModuleId> get disabledModules {
    return enabled.entries
        .where((e) => !e.value)
        .map((e) => e.key)
        .toList();
  }

  /// Crée une copie avec les champs modifiés.
  RestaurantFeatureFlags copyWith({
    String? restaurantId,
    Map<ModuleId, bool>? enabled,
  }) {
    return RestaurantFeatureFlags(
      restaurantId: restaurantId ?? this.restaurantId,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() {
    final enabledCount = enabled.values.where((v) => v).length;
    return 'RestaurantFeatureFlags(restaurantId: $restaurantId, '
        'enabled: $enabledCount/${enabled.length})';
  }

  // TODO: Ajouter une méthode pour sérialiser/désérialiser
  // TODO: Ajouter un cache local pour éviter les appels Firestore répétés
  // TODO: Ajouter un listener pour les changements en temps réel
}
