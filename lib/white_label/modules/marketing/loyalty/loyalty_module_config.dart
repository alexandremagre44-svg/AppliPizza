/// Configuration spécifique au module Fidélité.
///
/// Cette classe contient les paramètres configurables pour le module
/// de fidélité. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class LoyaltyModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const LoyaltyModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  LoyaltyModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return LoyaltyModuleConfig(
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
  factory LoyaltyModuleConfig.fromJson(Map<String, dynamic> json) {
    return LoyaltyModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'LoyaltyModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - int pointsPerEuro (points gagnés par euro dépensé)
  // - int pointsForReward (points nécessaires pour une récompense)
  // - double rewardValue (valeur de la récompense en euros)
  // - int pointsExpirationDays (durée de validité des points)
  // - List<LoyaltyTier> tiers (niveaux de fidélité)
}
