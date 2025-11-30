/// Configuration spécifique au module Paiements.
///
/// Cette classe contient les paramètres configurables pour le module
/// de paiements. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class PaymentsModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const PaymentsModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  PaymentsModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return PaymentsModuleConfig(
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
  factory PaymentsModuleConfig.fromJson(Map<String, dynamic> json) {
    return PaymentsModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'PaymentsModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - String stripePublicKey
  // - String stripeSecretKey (à stocker côté serveur)
  // - List<String> acceptedPaymentMethods (card, apple_pay, google_pay)
  // - bool testMode (mode test / production)
  // - String currency (EUR, USD, etc.)
}
