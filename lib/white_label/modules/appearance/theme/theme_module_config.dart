/// Configuration spécifique au module Thème.
///
/// Cette classe contient les paramètres configurables pour le module
/// thème. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class ThemeModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const ThemeModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  ThemeModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return ThemeModuleConfig(
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
  factory ThemeModuleConfig.fromJson(Map<String, dynamic> json) {
    return ThemeModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'ThemeModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - String primaryColor (couleur principale)
  // - String secondaryColor (couleur secondaire)
  // - String backgroundColor (couleur de fond)
  // - String fontFamily (police de caractères)
  // - double borderRadius (arrondi des coins)
  // - bool useDarkMode (mode sombre)
}
