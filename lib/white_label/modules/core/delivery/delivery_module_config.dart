/// lib/white_label/modules/core/delivery/delivery_module_config.dart
///
/// Configuration spécifique au module Livraison.
library;

import 'delivery_settings.dart';

/// Configuration spécifique au module Livraison.
///
/// Cette classe contient les paramètres configurables pour le module
/// de livraison avec des settings typés.
class DeliveryModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres de livraison typés.
  final DeliverySettings settings;

  /// Constructeur.
  const DeliveryModuleConfig({
    this.enabled = false,
    this.settings = const DeliverySettings(),
  });

  /// Crée une copie de cette configuration avec les champs modifiés.
  DeliveryModuleConfig copyWith({
    bool? enabled,
    DeliverySettings? settings,
  }) {
    return DeliveryModuleConfig(
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
  factory DeliveryModuleConfig.fromJson(Map<String, dynamic> json) {
    final settingsJson = json['settings'] as Map<String, dynamic>? ?? {};
    return DeliveryModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: DeliverySettings.fromJson(settingsJson),
    );
  }

  /// Crée une configuration par défaut.
  factory DeliveryModuleConfig.defaults() {
    return DeliveryModuleConfig(
      enabled: false,
      settings: DeliverySettings.defaults(),
    );
  }

  @override
  String toString() {
    return 'DeliveryModuleConfig(enabled: $enabled, settings: $settings)';
  }
}
