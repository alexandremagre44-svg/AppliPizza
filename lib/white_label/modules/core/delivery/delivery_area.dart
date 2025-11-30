/// lib/white_label/modules/core/delivery/delivery_area.dart
///
/// Représente une zone de livraison avec ses paramètres.
library;

/// Zone de livraison avec son périmètre et ses frais.
///
/// Chaque zone peut avoir des frais différents et un temps de livraison
/// estimé différent.
class DeliveryArea {
  /// Identifiant unique de la zone.
  final String id;

  /// Nom de la zone (ex: "Centre-ville", "Périphérie Nord").
  final String name;

  /// Liste des codes postaux couverts par cette zone.
  final List<String> postalCodes;

  /// Rayon de la zone en kilomètres (si basée sur la distance).
  final double? radiusKm;

  /// Frais de livraison pour cette zone.
  final double deliveryFee;

  /// Montant minimum de commande pour cette zone.
  final double minimumOrderAmount;

  /// Temps de livraison estimé en minutes.
  final int estimatedMinutes;

  /// Indique si la zone est active.
  final bool isActive;

  /// Coordonnées du centre de la zone (latitude).
  final double? centerLat;

  /// Coordonnées du centre de la zone (longitude).
  final double? centerLng;

  /// Constructeur.
  const DeliveryArea({
    required this.id,
    required this.name,
    this.postalCodes = const [],
    this.radiusKm,
    this.deliveryFee = 0.0,
    this.minimumOrderAmount = 0.0,
    this.estimatedMinutes = 30,
    this.isActive = true,
    this.centerLat,
    this.centerLng,
  });

  /// Crée une copie de cette zone avec les champs modifiés.
  DeliveryArea copyWith({
    String? id,
    String? name,
    List<String>? postalCodes,
    double? radiusKm,
    double? deliveryFee,
    double? minimumOrderAmount,
    int? estimatedMinutes,
    bool? isActive,
    double? centerLat,
    double? centerLng,
  }) {
    return DeliveryArea(
      id: id ?? this.id,
      name: name ?? this.name,
      postalCodes: postalCodes ?? this.postalCodes,
      radiusKm: radiusKm ?? this.radiusKm,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isActive: isActive ?? this.isActive,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
    );
  }

  /// Sérialise la zone en JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'postalCodes': postalCodes,
      'radiusKm': radiusKm,
      'deliveryFee': deliveryFee,
      'minimumOrderAmount': minimumOrderAmount,
      'estimatedMinutes': estimatedMinutes,
      'isActive': isActive,
      'centerLat': centerLat,
      'centerLng': centerLng,
    };
  }

  /// Désérialise une zone depuis un JSON.
  factory DeliveryArea.fromJson(Map<String, dynamic> json) {
    return DeliveryArea(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      postalCodes: (json['postalCodes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      radiusKm: (json['radiusKm'] as num?)?.toDouble(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      minimumOrderAmount:
          (json['minimumOrderAmount'] as num?)?.toDouble() ?? 0.0,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 30,
      isActive: json['isActive'] as bool? ?? true,
      centerLat: (json['centerLat'] as num?)?.toDouble(),
      centerLng: (json['centerLng'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() {
    return 'DeliveryArea(id: $id, name: $name, deliveryFee: $deliveryFee, '
        'minimumOrderAmount: $minimumOrderAmount, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryArea && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
