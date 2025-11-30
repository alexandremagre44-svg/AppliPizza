/// Configuration spécifique au module Livraison.
///
/// Cette classe contient les paramètres configurables pour le module
/// de livraison. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class DeliveryModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const DeliveryModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  DeliveryModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return DeliveryModuleConfig(
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
  factory DeliveryModuleConfig.fromJson(Map<String, dynamic> json) {
    return DeliveryModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'DeliveryModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - List<DeliveryZone> zones (zones de livraison)
  // - double minimumOrderAmount (montant minimum pour livraison)
  // - double baseFee (frais de base)
  // - double feePerKm (frais par km)
  // - int estimatedDeliveryMinutes (temps estimé)
}
