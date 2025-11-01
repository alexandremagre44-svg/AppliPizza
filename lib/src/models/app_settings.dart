// lib/src/models/app_settings.dart
// Modèle pour les paramètres de l'application

class AppSettings {
  final double deliveryFee;
  final double minimumOrderAmount;
  final int estimatedDeliveryTime; // en minutes
  final String deliveryZone;

  AppSettings({
    this.deliveryFee = 3.0,
    this.minimumOrderAmount = 15.0,
    this.estimatedDeliveryTime = 30,
    this.deliveryZone = 'Paris et banlieue proche',
  });

  AppSettings copyWith({
    double? deliveryFee,
    double? minimumOrderAmount,
    int? estimatedDeliveryTime,
    String? deliveryZone,
  }) {
    return AppSettings(
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      deliveryZone: deliveryZone ?? this.deliveryZone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryFee': deliveryFee,
      'minimumOrderAmount': minimumOrderAmount,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'deliveryZone': deliveryZone,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 3.0,
      minimumOrderAmount: (json['minimumOrderAmount'] as num?)?.toDouble() ?? 15.0,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] as int? ?? 30,
      deliveryZone: json['deliveryZone'] as String? ?? 'Paris et banlieue proche',
    );
  }
}
