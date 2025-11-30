/// Configuration spécifique au module Promotions.
///
/// Cette classe contient les paramètres configurables pour le module
/// de promotions. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class PromotionsModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const PromotionsModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  PromotionsModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return PromotionsModuleConfig(
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
  factory PromotionsModuleConfig.fromJson(Map<String, dynamic> json) {
    return PromotionsModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'PromotionsModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - bool allowMultipleCodes (autoriser plusieurs codes)
  // - bool allowCombineWithLoyalty (cumuler avec fidélité)
  // - double maxDiscountPercent (réduction max en %)
  // - double maxDiscountAmount (réduction max en euros)
}
