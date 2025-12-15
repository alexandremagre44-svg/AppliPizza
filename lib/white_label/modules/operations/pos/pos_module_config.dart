/// Configuration spécifique au module POS (Point de Vente).
///
/// Le module POS est un module système qui regroupe toutes les fonctionnalités
/// de point de vente, incluant:
/// - Interface staff / caisse
/// - Affichage cuisine (Kitchen Display System)
/// - Gestion des commandes et paiements
/// - Sessions de caisse
///
/// Cette classe contient les paramètres configurables pour le module POS complet.
class PosModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Configuration de l'interface staff/caisse
  final StaffTabletSettings? staffTabletSettings;

  /// Configuration de l'affichage cuisine
  final KitchenDisplaySettings? kitchenDisplaySettings;

  /// Constructeur.
  const PosModuleConfig({
    this.enabled = false,
    this.settings = const {},
    this.staffTabletSettings,
    this.kitchenDisplaySettings,
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  PosModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
    StaffTabletSettings? staffTabletSettings,
    KitchenDisplaySettings? kitchenDisplaySettings,
  }) {
    return PosModuleConfig(
      enabled: enabled ?? this.enabled,
      settings: settings ?? this.settings,
      staffTabletSettings: staffTabletSettings ?? this.staffTabletSettings,
      kitchenDisplaySettings: kitchenDisplaySettings ?? this.kitchenDisplaySettings,
    );
  }

  /// Sérialise la configuration en JSON.
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'settings': settings,
      'staffTabletSettings': staffTabletSettings?.toJson(),
      'kitchenDisplaySettings': kitchenDisplaySettings?.toJson(),
    };
  }

  /// Désérialise une configuration depuis un JSON.
  factory PosModuleConfig.fromJson(Map<String, dynamic> json) {
    return PosModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
      staffTabletSettings: json['staffTabletSettings'] != null
          ? StaffTabletSettings.fromJson(json['staffTabletSettings'] as Map<String, dynamic>)
          : null,
      kitchenDisplaySettings: json['kitchenDisplaySettings'] != null
          ? KitchenDisplaySettings.fromJson(json['kitchenDisplaySettings'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() {
    return 'PosModuleConfig(enabled: $enabled, staffTablet: ${staffTabletSettings != null}, kitchenDisplay: ${kitchenDisplaySettings != null})';
  }
}

/// Configuration pour l'interface staff/caisse
class StaffTabletSettings {
  /// Autoriser le paiement sans PIN
  final bool requirePinToOrder;

  /// Afficher le plan des tables
  final bool showTableMap;

  /// Autoriser l'addition séparée
  final bool allowSplitBill;

  /// Liste des tables configurées
  final List<String>? tables;

  /// Liste des zones de service
  final List<String>? zones;

  const StaffTabletSettings({
    this.requirePinToOrder = true,
    this.showTableMap = true,
    this.allowSplitBill = true,
    this.tables,
    this.zones,
  });

  Map<String, dynamic> toJson() {
    return {
      'requirePinToOrder': requirePinToOrder,
      'showTableMap': showTableMap,
      'allowSplitBill': allowSplitBill,
      'tables': tables,
      'zones': zones,
    };
  }

  factory StaffTabletSettings.fromJson(Map<String, dynamic> json) {
    return StaffTabletSettings(
      requirePinToOrder: json['requirePinToOrder'] as bool? ?? true,
      showTableMap: json['showTableMap'] as bool? ?? true,
      allowSplitBill: json['allowSplitBill'] as bool? ?? true,
      tables: (json['tables'] as List<dynamic>?)?.cast<String>(),
      zones: (json['zones'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

/// Configuration pour l'affichage cuisine
class KitchenDisplaySettings {
  /// Rafraîchissement automatique
  final bool autoRefresh;

  /// Intervalle de rafraîchissement (secondes)
  final int refreshIntervalSeconds;

  /// Jouer un son pour nouvelle commande
  final bool playSoundOnNewOrder;

  /// Afficher temps de préparation
  final bool showPreparationTime;

  /// Stations de travail (four, préparation, etc.)
  final List<String>? stations;

  const KitchenDisplaySettings({
    this.autoRefresh = true,
    this.refreshIntervalSeconds = 30,
    this.playSoundOnNewOrder = true,
    this.showPreparationTime = true,
    this.stations,
  });

  Map<String, dynamic> toJson() {
    return {
      'autoRefresh': autoRefresh,
      'refreshIntervalSeconds': refreshIntervalSeconds,
      'playSoundOnNewOrder': playSoundOnNewOrder,
      'showPreparationTime': showPreparationTime,
      'stations': stations,
    };
  }

  factory KitchenDisplaySettings.fromJson(Map<String, dynamic> json) {
    return KitchenDisplaySettings(
      autoRefresh: json['autoRefresh'] as bool? ?? true,
      refreshIntervalSeconds: json['refreshIntervalSeconds'] as int? ?? 30,
      playSoundOnNewOrder: json['playSoundOnNewOrder'] as bool? ?? true,
      showPreparationTime: json['showPreparationTime'] as bool? ?? true,
      stations: (json['stations'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
