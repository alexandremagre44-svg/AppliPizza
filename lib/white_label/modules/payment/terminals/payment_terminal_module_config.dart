/// Configuration spécifique au module Terminal de paiement.
///
/// Cette classe contient les paramètres configurables pour le module
/// de terminal de paiement. Elle peut être utilisée à la place de la
/// configuration générique ModuleConfig pour typer les settings.
class PaymentTerminalModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const PaymentTerminalModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  PaymentTerminalModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return PaymentTerminalModuleConfig(
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
  factory PaymentTerminalModuleConfig.fromJson(Map<String, dynamic> json) {
    return PaymentTerminalModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'PaymentTerminalModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - String terminalProvider (stripe_terminal, sumup, zettle, etc.)
  // - String terminalId (identifiant du terminal)
  // - bool autoConnect (connexion automatique)
  // - int connectionTimeoutSeconds (timeout de connexion)
}
