/// lib/superadmin/models/module_meta.dart
///
/// Modèle de métadonnées pour un module dans le système Super-Admin.
/// Ce modèle est isolé et indépendant du reste de l'application.
library;

/// Représente les métadonnées d'un module configurable pour le Super-Admin.
class ModuleMeta {
  /// Nom du module (ex: roulette, loyalty, kitchen).
  final String name;

  /// Indique si le module est activé ou non.
  final bool enabled;

  /// Constructeur principal.
  const ModuleMeta({
    required this.name,
    required this.enabled,
  });

  /// Crée une copie de l'objet avec des valeurs modifiées.
  ModuleMeta copyWith({
    String? name,
    bool? enabled,
  }) {
    return ModuleMeta(
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() {
    return 'ModuleMeta(name: $name, enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModuleMeta && other.name == name && other.enabled == enabled;
  }

  @override
  int get hashCode {
    return Object.hash(name, enabled);
  }
}
