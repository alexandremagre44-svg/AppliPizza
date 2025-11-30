/// Configuration spécifique au module Constructeur de pages.
///
/// Cette classe contient les paramètres configurables pour le module
/// constructeur de pages. Elle peut être utilisée à la place de la
/// configuration générique ModuleConfig pour typer les settings.
class PagesBuilderModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const PagesBuilderModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  PagesBuilderModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return PagesBuilderModuleConfig(
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
  factory PagesBuilderModuleConfig.fromJson(Map<String, dynamic> json) {
    return PagesBuilderModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'PagesBuilderModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - int maxPages (nombre max de pages personnalisées)
  // - List<String> allowedBlockTypes (types de blocs autorisés)
  // - bool allowCustomCSS (autoriser CSS personnalisé)
  // - bool allowCustomJS (autoriser JS personnalisé)
  // - String defaultLayout (layout par défaut)
}
