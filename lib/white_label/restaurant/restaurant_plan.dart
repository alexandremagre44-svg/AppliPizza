import '../core/module_config.dart';
import '../core/module_id.dart';

/// Plan de configuration d'un restaurant avec ses modules activés.
///
/// Cette classe représente la configuration complète d'un restaurant
/// en termes de modules activés et leurs paramètres.
///
/// Note : Ce modèle est proche du RestaurantBlueprintLight mais en version
/// "modules only", sans les informations de branding ou de contenu.
class RestaurantPlan {
  /// Identifiant unique du restaurant.
  final String restaurantId;

  /// Nom du restaurant.
  final String name;

  /// Slug URL-friendly du restaurant.
  final String slug;

  /// Liste des configurations de modules pour ce restaurant.
  final List<ModuleConfig> modules;

  /// Constructeur.
  const RestaurantPlan({
    required this.restaurantId,
    required this.name,
    required this.slug,
    this.modules = const [],
  });

  /// Crée une copie de ce plan avec les champs modifiés.
  RestaurantPlan copyWith({
    String? restaurantId,
    String? name,
    String? slug,
    List<ModuleConfig>? modules,
  }) {
    return RestaurantPlan(
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      modules: modules ?? this.modules,
    );
  }

  /// Sérialise le plan en JSON.
  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'slug': slug,
      'modules': modules.map((m) => m.toJson()).toList(),
    };
  }

  /// Désérialise un plan depuis un JSON.
  factory RestaurantPlan.fromJson(Map<String, dynamic> json) {
    final modulesJson = json['modules'] as List<dynamic>? ?? [];
    return RestaurantPlan(
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      modules: modulesJson
          .map((m) => ModuleConfig.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Vérifie si un module est activé pour ce restaurant.
  /// Accepte soit un String (ex: "delivery") soit un ModuleId enum.
  bool hasModule(dynamic id) {
    if (id is ModuleId) {
      return modules.any((m) => m.id == id.code && m.enabled);
    } else if (id is String) {
      return modules.any((m) => m.id == id && m.enabled);
    }
    throw ArgumentError('id must be either a ModuleId or String, got ${id.runtimeType}');
  }

  /// Retourne la configuration d'un module spécifique, ou null si non trouvé.
  /// Accepte soit un String (ex: "delivery") soit un ModuleId enum.
  ModuleConfig? getModuleConfig(dynamic id) {
    final String moduleId;
    if (id is ModuleId) {
      moduleId = id.code;
    } else if (id is String) {
      moduleId = id;
    } else {
      throw ArgumentError('id must be either a ModuleId or String, got ${id.runtimeType}');
    }
    
    for (final module in modules) {
      if (module.id == moduleId) {
        return module;
      }
    }
    return null;
  }

  /// Retourne la liste des modules activés.
  List<ModuleConfig> get enabledModules {
    return modules.where((m) => m.enabled).toList();
  }

  @override
  String toString() {
    return 'RestaurantPlan(restaurantId: $restaurantId, name: $name, '
        'slug: $slug, modules: ${modules.length})';
  }

  // TODO: Ajouter une méthode validate() pour vérifier les dépendances
  // TODO: Ajouter un champ "planType" (free, starter, pro, enterprise)
  // TODO: Ajouter des timestamps createdAt / updatedAt
}
