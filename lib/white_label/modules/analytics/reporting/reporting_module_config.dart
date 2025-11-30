/// Configuration spécifique au module Reporting.
///
/// Cette classe contient les paramètres configurables pour le module
/// reporting. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class ReportingModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const ReportingModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  ReportingModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return ReportingModuleConfig(
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
  factory ReportingModuleConfig.fromJson(Map<String, dynamic> json) {
    return ReportingModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'ReportingModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - String defaultDateRange (7days, 30days, 90days, year)
  // - List<String> dashboardWidgets (widgets affichés)
  // - bool showComparison (comparer aux périodes précédentes)
  // - String currency (devise pour les montants)
  // - bool sendWeeklyReport (envoyer rapport hebdomadaire)
}
