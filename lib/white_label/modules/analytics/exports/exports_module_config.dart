/// Configuration spécifique au module Exports.
///
/// Cette classe contient les paramètres configurables pour le module
/// exports. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class ExportsModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const ExportsModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  ExportsModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return ExportsModuleConfig(
      enabled: enabled ?? this.enabled,
      settings: settings ?? this.settings,
    );
  }

  /// Sérialise la configuration en JSON.
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'settings': settings,
    };
  }

  /// Désérialise une configuration depuis un JSON.
  factory ExportsModuleConfig.fromJson(Map<String, dynamic> json) {
    return ExportsModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'ExportsModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - List<String> allowedFormats (csv, xlsx, pdf)
  // - bool includeHeaders (inclure les en-têtes)
  // - String dateFormat (format des dates)
  // - String decimalSeparator (séparateur décimal)
  // - bool autoScheduleExports (exports automatiques planifiés)
  // - String exportEmail (email pour envoi automatique)
}
