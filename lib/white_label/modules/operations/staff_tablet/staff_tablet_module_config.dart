/// Configuration spécifique au module Tablette staff.
///
/// Cette classe contient les paramètres configurables pour le module
/// tablette staff. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class StaffTabletModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const StaffTabletModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  StaffTabletModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return StaffTabletModuleConfig(
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
  factory StaffTabletModuleConfig.fromJson(Map<String, dynamic> json) {
    return StaffTabletModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'StaffTabletModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - List<Table> tables (tables du restaurant)
  // - List<Zone> zones (zones de service)
  // - bool requirePinToOrder (PIN pour valider commande)
  // - bool showTableMap (afficher plan des tables)
  // - bool allowSplitBill (autoriser addition séparée)
}
