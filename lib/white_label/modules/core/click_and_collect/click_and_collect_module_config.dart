/// Configuration spécifique au module Click & Collect.
///
/// Cette classe contient les paramètres configurables pour le module
/// Click & Collect avec des settings typés.
library;

import 'click_and_collect_settings.dart';

class ClickAndCollectModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres typés du module Click & Collect.
  final ClickAndCollectSettings settings;

  /// Constructeur.
  const ClickAndCollectModuleConfig({
    this.enabled = false,
    this.settings = const ClickAndCollectSettings(),
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  ClickAndCollectModuleConfig copyWith({
    bool? enabled,
    ClickAndCollectSettings? settings,
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
      'settings': settings.toJson(),
    };
  }

  /// Désérialise une configuration depuis un JSON.
  factory ClickAndCollectModuleConfig.fromJson(Map<String, dynamic> json) {
    final settingsJson = json['settings'] as Map<String, dynamic>? ?? {};
    return ClickAndCollectModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: ClickAndCollectSettings.fromJson(settingsJson),
    );
  }

  /// Crée une configuration par défaut.
  factory ClickAndCollectModuleConfig.defaults() {
    return ClickAndCollectModuleConfig(
      enabled: false,
      settings: ClickAndCollectSettings.defaults(),
    );
  }

  @override
  String toString() {
    return 'ClickAndCollectModuleConfig(enabled: $enabled, settings: $settings)';
  }
}
