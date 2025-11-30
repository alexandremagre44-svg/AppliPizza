/// Configuration spécifique au module Tablette cuisine.
///
/// Cette classe contient les paramètres configurables pour le module
/// tablette cuisine. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class KitchenTabletModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const KitchenTabletModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  KitchenTabletModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return KitchenTabletModuleConfig(
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
  factory KitchenTabletModuleConfig.fromJson(Map<String, dynamic> json) {
    return KitchenTabletModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'KitchenTabletModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - List<String> stations (four, préparation, emballage, etc.)
  // - bool autoRefresh (rafraîchissement automatique)
  // - int refreshIntervalSeconds (intervalle de rafraîchissement)
  // - bool playSoundOnNewOrder (son pour nouvelle commande)
  // - bool showPreparationTime (afficher temps de préparation)
}
