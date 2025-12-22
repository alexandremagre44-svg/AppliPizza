/// lib/domain/fulfillment_config.dart
///
/// Modèle minimal pour la configuration de fulfillment (modes de retrait/livraison).
/// Ce fichier est un stub temporaire pour satisfaire la compilation.
library;

/// Configuration des modes de fulfillment disponibles pour une application.
class FulfillmentConfig {
  /// Identifiant de l'application.
  final String appId;
  
  /// Indique si le retrait en magasin (pickup) est activé.
  final bool pickupEnabled;
  
  /// Indique si la livraison est activée.
  final bool deliveryEnabled;
  
  /// Indique si la consommation sur place est activée.
  final bool onSiteEnabled;
  
  /// Temps de préparation en minutes.
  final int preparationTimeMinutes;
  
  /// Frais de livraison en centimes.
  final int deliveryFeeInCents;
  
  /// Montant minimum de commande en centimes.
  final int minimumOrderInCents;

  /// Getter pour la compatibilité UI: dineInEnabled mappé sur onSiteEnabled.
  bool get dineInEnabled => onSiteEnabled;

  /// Constructeur principal.
  const FulfillmentConfig({
    required this.appId,
    this.pickupEnabled = false,
    this.deliveryEnabled = false,
    this.onSiteEnabled = false,
    this.preparationTimeMinutes = 30,
    this.deliveryFeeInCents = 0,
    this.minimumOrderInCents = 0,
  });

  /// Crée une configuration par défaut pour un appId donné.
  factory FulfillmentConfig.defaultConfig(String appId) {
    return FulfillmentConfig(
      appId: appId,
      pickupEnabled: true,
      deliveryEnabled: false,
      onSiteEnabled: false,
      preparationTimeMinutes: 30,
      deliveryFeeInCents: 0,
      minimumOrderInCents: 0,
    );
  }

  /// Crée une instance depuis un Map JSON.
  factory FulfillmentConfig.fromJson(Map<String, dynamic> json) {
    return FulfillmentConfig(
      appId: json['appId'] as String? ?? '',
      pickupEnabled: json['pickupEnabled'] as bool? ?? false,
      deliveryEnabled: json['deliveryEnabled'] as bool? ?? false,
      onSiteEnabled: json['onSiteEnabled'] as bool? ?? false,
      preparationTimeMinutes: json['preparationTimeMinutes'] as int? ?? 30,
      deliveryFeeInCents: json['deliveryFeeInCents'] as int? ?? 0,
      minimumOrderInCents: json['minimumOrderInCents'] as int? ?? 0,
    );
  }

  /// Convertit l'instance en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'pickupEnabled': pickupEnabled,
      'deliveryEnabled': deliveryEnabled,
      'onSiteEnabled': onSiteEnabled,
      'preparationTimeMinutes': preparationTimeMinutes,
      'deliveryFeeInCents': deliveryFeeInCents,
      'minimumOrderInCents': minimumOrderInCents,
    };
  }

  /// Crée une copie de l'objet avec des valeurs modifiées.
  FulfillmentConfig copyWith({
    String? appId,
    bool? pickupEnabled,
    bool? deliveryEnabled,
    bool? onSiteEnabled,
    int? preparationTimeMinutes,
    int? deliveryFeeInCents,
    int? minimumOrderInCents,
  }) {
    return FulfillmentConfig(
      appId: appId ?? this.appId,
      pickupEnabled: pickupEnabled ?? this.pickupEnabled,
      deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
      onSiteEnabled: onSiteEnabled ?? this.onSiteEnabled,
      preparationTimeMinutes: preparationTimeMinutes ?? this.preparationTimeMinutes,
      deliveryFeeInCents: deliveryFeeInCents ?? this.deliveryFeeInCents,
      minimumOrderInCents: minimumOrderInCents ?? this.minimumOrderInCents,
    );
  }

  @override
  String toString() {
    return 'FulfillmentConfig(appId: $appId, pickup: $pickupEnabled, '
        'delivery: $deliveryEnabled, onSite: $onSiteEnabled, '
        'prepTime: ${preparationTimeMinutes}min, '
        'deliveryFee: ${deliveryFeeInCents}¢, '
        'minOrder: ${minimumOrderInCents}¢)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FulfillmentConfig &&
        other.appId == appId &&
        other.pickupEnabled == pickupEnabled &&
        other.deliveryEnabled == deliveryEnabled &&
        other.onSiteEnabled == onSiteEnabled &&
        other.preparationTimeMinutes == preparationTimeMinutes &&
        other.deliveryFeeInCents == deliveryFeeInCents &&
        other.minimumOrderInCents == minimumOrderInCents;
  }

  @override
  int get hashCode => Object.hash(
        appId,
        pickupEnabled,
        deliveryEnabled,
        onSiteEnabled,
        preparationTimeMinutes,
        deliveryFeeInCents,
        minimumOrderInCents,
      );
}
