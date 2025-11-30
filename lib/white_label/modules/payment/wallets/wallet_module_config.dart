/// Configuration spécifique au module Portefeuille.
///
/// Cette classe contient les paramètres configurables pour le module
/// de portefeuille. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class WalletModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const WalletModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  WalletModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return WalletModuleConfig(
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
  factory WalletModuleConfig.fromJson(Map<String, dynamic> json) {
    return WalletModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'WalletModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - double maxBalance (solde maximum autorisé)
  // - double minTopUp (recharge minimum)
  // - double maxTopUp (recharge maximum)
  // - bool allowNegativeBalance (autoriser solde négatif)
  // - List<double> topUpPresets (montants prédéfinis de recharge)
}
