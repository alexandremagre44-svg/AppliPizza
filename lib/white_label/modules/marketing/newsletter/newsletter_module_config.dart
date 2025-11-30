/// Configuration spécifique au module Newsletter.
///
/// Cette classe contient les paramètres configurables pour le module
/// de newsletter. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class NewsletterModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const NewsletterModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  NewsletterModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return NewsletterModuleConfig(
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
  factory NewsletterModuleConfig.fromJson(Map<String, dynamic> json) {
    return NewsletterModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'NewsletterModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - String provider (mailchimp, sendinblue, etc.)
  // - String apiKey (clé API du service)
  // - String listId (identifiant de la liste)
  // - bool doubleOptIn (confirmation par email)
  // - String welcomeEmailTemplateId (template email de bienvenue)
}
