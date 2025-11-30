/// Configuration spécifique au module Roulette.
///
/// Cette classe contient les paramètres configurables pour le module
/// roulette. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class RouletteModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const RouletteModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  RouletteModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return RouletteModuleConfig(
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
  factory RouletteModuleConfig.fromJson(Map<String, dynamic> json) {
    return RouletteModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'RouletteModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - int maxSpinsPerDay (tours max par jour)
  // - int maxSpinsPerWeek (tours max par semaine)
  // - List<RouletteSegment> segments (segments de la roulette)
  // - bool requirePurchase (nécessite un achat pour jouer)
  // - double minPurchaseAmount (montant minimum d'achat)
}
