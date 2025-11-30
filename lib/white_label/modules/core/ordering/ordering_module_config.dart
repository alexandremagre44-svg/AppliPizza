/// Configuration spécifique au module Commandes en ligne.
///
/// Cette classe contient les paramètres configurables pour le module
/// de commandes. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class OrderingModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const OrderingModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  OrderingModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return OrderingModuleConfig(
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
  factory OrderingModuleConfig.fromJson(Map<String, dynamic> json) {
    return OrderingModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'OrderingModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - bool allowOnSite (commandes sur place)
  // - bool allowTakeaway (à emporter)
  // - bool allowDelivery (livraison)
  // - int minOrderAmount (montant minimum)
  // - List<String> paymentMethods (méthodes de paiement acceptées)
}
