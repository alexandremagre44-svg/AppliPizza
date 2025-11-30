import 'module_id.dart';

/// Configuration d'un module pour un restaurant spécifique.
///
/// Chaque restaurant peut activer/désactiver des modules et personnaliser
/// leurs paramètres via cette classe.
///
/// Cette classe est générique : chaque module peut avoir des settings
/// spécifiques stockés dans la Map [settings].
class ModuleConfig {
  /// Identifiant du module concerné.
  final ModuleId id;

  /// Indique si le module est activé pour ce restaurant.
  final bool enabled;

  /// Paramètres spécifiques au module (clé-valeur).
  /// Chaque module peut définir ses propres clés de configuration.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const ModuleConfig({
    required this.id,
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  ModuleConfig copyWith({
    ModuleId? id,
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return ModuleConfig(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      settings: settings ?? this.settings,
    );
  }

  /// Sérialise la configuration en JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id.code,
      'enabled': enabled,
      'settings': settings,
    };
  }

  /// Désérialise une configuration depuis un JSON.
  factory ModuleConfig.fromJson(Map<String, dynamic> json) {
    final idCode = json['id'] as String;
    final moduleId = ModuleId.values.firstWhere(
      (m) => m.code == idCode,
      orElse: () => throw ArgumentError('Unknown module id: $idCode'),
    );

    return ModuleConfig(
      id: moduleId,
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'ModuleConfig(id: ${id.code}, enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter une méthode validate() pour valider les settings
  // TODO: Plus tard, typer les settings par module avec des classes spécifiques
}
