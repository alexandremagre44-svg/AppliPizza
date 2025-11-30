/// lib/superadmin/models/module_meta.dart
///
/// Modèle de métadonnées pour un module dans le système Super-Admin.
/// Ce modèle est isolé et indépendant du reste de l'application.
library;

/// Catégories de modules disponibles.
enum ModuleCategory {
  /// Modules de base (menu, commandes, etc.).
  core,
  /// Modules marketing (promotions, fidélité, etc.).
  marketing,
  /// Modules opérationnels (cuisine, caisse, etc.).
  operations,
  /// Modules d'intégration (paiement, livraison, etc.).
  integration,
  /// Modules avancés (analytics, IA, etc.).
  advanced,
}

/// Extension pour convertir ModuleCategory en/depuis String.
extension ModuleCategoryExtension on ModuleCategory {
  String get value {
    switch (this) {
      case ModuleCategory.core:
        return 'core';
      case ModuleCategory.marketing:
        return 'marketing';
      case ModuleCategory.operations:
        return 'operations';
      case ModuleCategory.integration:
        return 'integration';
      case ModuleCategory.advanced:
        return 'advanced';
    }
  }

  String get displayName {
    switch (this) {
      case ModuleCategory.core:
        return 'Core';
      case ModuleCategory.marketing:
        return 'Marketing';
      case ModuleCategory.operations:
        return 'Operations';
      case ModuleCategory.integration:
        return 'Integration';
      case ModuleCategory.advanced:
        return 'Advanced';
    }
  }

  static ModuleCategory fromString(String? value) {
    switch (value) {
      case 'core':
        return ModuleCategory.core;
      case 'marketing':
        return ModuleCategory.marketing;
      case 'operations':
        return ModuleCategory.operations;
      case 'integration':
        return ModuleCategory.integration;
      case 'advanced':
        return ModuleCategory.advanced;
      default:
        return ModuleCategory.core;
    }
  }
}

/// Représente les métadonnées d'un module configurable pour le Super-Admin.
class ModuleMeta {
  /// Identifiant unique du module (ex: "roulette", "loyalty").
  final String id;

  /// Nom d'affichage du module.
  final String name;

  /// Description du module.
  final String description;

  /// Catégorie du module.
  final ModuleCategory category;

  /// Indique si le module est activé ou non.
  final bool enabled;

  /// Indique si le module nécessite une configuration supplémentaire.
  final bool requiresSetup;

  /// Indique si le module est disponible (peut être désactivé globalement).
  final bool available;

  /// Icône du module (nom de l'icône Material).
  final String? iconName;

  /// Configuration spécifique du module (optionnel).
  final Map<String, dynamic>? config;

  /// Version du module.
  final String? version;

  /// Constructeur principal.
  const ModuleMeta({
    this.id = '',
    required this.name,
    this.description = '',
    this.category = ModuleCategory.core,
    required this.enabled,
    this.requiresSetup = false,
    this.available = true,
    this.iconName,
    this.config,
    this.version,
  });

  /// Crée une instance depuis un Map.
  factory ModuleMeta.fromMap(Map<String, dynamic> map) {
    return ModuleMeta(
      id: map['id'] as String? ?? map['name'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: ModuleCategoryExtension.fromString(map['category'] as String?),
      enabled: map['enabled'] as bool? ?? false,
      requiresSetup: map['requiresSetup'] as bool? ?? false,
      available: map['available'] as bool? ?? true,
      iconName: map['iconName'] as String?,
      config: map['config'] as Map<String, dynamic>?,
      version: map['version'] as String?,
    );
  }

  /// Convertit l'instance en Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.value,
      'enabled': enabled,
      'requiresSetup': requiresSetup,
      'available': available,
      if (iconName != null) 'iconName': iconName,
      if (config != null) 'config': config,
      if (version != null) 'version': version,
    };
  }

  /// Crée une copie de l'objet avec des valeurs modifiées.
  ModuleMeta copyWith({
    String? id,
    String? name,
    String? description,
    ModuleCategory? category,
    bool? enabled,
    bool? requiresSetup,
    bool? available,
    String? iconName,
    Map<String, dynamic>? config,
    String? version,
  }) {
    return ModuleMeta(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
      requiresSetup: requiresSetup ?? this.requiresSetup,
      available: available ?? this.available,
      iconName: iconName ?? this.iconName,
      config: config ?? this.config,
      version: version ?? this.version,
    );
  }

  /// Vérifie si le module peut être activé.
  bool get canBeEnabled => available && (!requiresSetup || config != null);

  @override
  String toString() {
    return 'ModuleMeta(id: $id, name: $name, category: ${category.value}, '
        'enabled: $enabled, available: $available)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModuleMeta &&
        other.id == id &&
        other.name == name &&
        other.category == category &&
        other.enabled == enabled &&
        other.available == available;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, category, enabled, available);
  }
}
