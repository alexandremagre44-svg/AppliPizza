/// Configuration spécifique au module Campagnes.
///
/// Cette classe contient les paramètres configurables pour le module
/// campagnes marketing. Elle peut être utilisée à la place de la
/// configuration générique ModuleConfig pour typer les settings.
class CampaignsModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const CampaignsModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  CampaignsModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return CampaignsModuleConfig(
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
  factory CampaignsModuleConfig.fromJson(Map<String, dynamic> json) {
    return CampaignsModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'CampaignsModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - List<String> targetSegments (segments de clientèle ciblés)
  // - String emailProvider (provider d'envoi d'emails)
  // - String smsProvider (provider d'envoi de SMS)
  // - bool enablePushNotifications (activer les notifications push)
  // - int maxCampaignsPerMonth (nombre max de campagnes par mois)
  // - String defaultSenderEmail (email expéditeur par défaut)
  // - String defaultSenderName (nom expéditeur par défaut)
}
