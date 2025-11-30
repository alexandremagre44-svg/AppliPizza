/// Configuration spécifique au module Click & Collect.
///
/// Cette classe contient les paramètres configurables pour le module
/// Click & Collect. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
class ClickAndCollectModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const ClickAndCollectModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  ClickAndCollectModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return ClickAndCollectModuleConfig(
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
  factory ClickAndCollectModuleConfig.fromJson(Map<String, dynamic> json) {
    return ClickAndCollectModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'ClickAndCollectModuleConfig(enabled: $enabled, settings: $settings)';
  }

  // TODO: Ajouter des champs typés spécifiques :
  // - int preparationTimeMinutes (temps de préparation)
  // - List<TimeSlot> pickupSlots (créneaux de retrait)
  // - bool allowSameDayPickup (retrait le jour même)
  // - int maxOrdersPerSlot (commandes max par créneau)
}
