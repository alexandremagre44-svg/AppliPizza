/// lib/white_label/modules/core/delivery/delivery_settings.dart
///
/// Paramètres complets du module Livraison.
library;

import 'delivery_area.dart';

/// Paramètres de configuration du module Livraison.
///
/// Cette classe contient tous les paramètres nécessaires pour configurer
/// le module de livraison d'un restaurant.
class DeliverySettings {
  /// Montant minimum de commande pour la livraison (en euros).
  final double minimumOrderAmount;

  /// Frais de livraison de base (en euros).
  final double deliveryFee;

  /// Seuil à partir duquel la livraison est gratuite (en euros).
  /// Si null, pas de livraison gratuite.
  final double? freeDeliveryThreshold;

  /// Rayon de livraison par défaut en kilomètres.
  final double radiusKm;

  /// Frais par kilomètre supplémentaire (en euros).
  final double feePerKm;

  /// Permet aux clients de donner un pourboire.
  final bool allowTips;

  /// Permet aux clients de programmer une livraison différée.
  final bool allowDelayedOrders;

  /// Temps de préparation avant livraison (en minutes).
  final int preparationTimeMinutes;

  /// Temps de livraison estimé par défaut (en minutes).
  final int estimatedDeliveryMinutes;

  /// Délai maximum pour une commande programmée (en heures).
  final int maxScheduleAheadHours;

  /// Liste des zones de livraison.
  final List<DeliveryArea> areas;

  /// Horaires de livraison par jour de la semaine.
  /// Clé: jour (0=lundi, 6=dimanche), Valeur: {"open": "11:00", "close": "22:00"}
  final Map<int, Map<String, String>> schedule;

  /// Message personnalisé affiché lors de la livraison.
  final String? deliveryMessage;

  /// Nombre maximum de livraisons simultanées.
  final int? maxConcurrentDeliveries;

  /// Activer le suivi en temps réel des livreurs.
  final bool enableRealTimeTracking;

  /// Instructions par défaut pour le livreur.
  final String? defaultDriverInstructions;

  /// Constructeur.
  const DeliverySettings({
    this.minimumOrderAmount = 15.0,
    this.deliveryFee = 2.50,
    this.freeDeliveryThreshold,
    this.radiusKm = 5.0,
    this.feePerKm = 0.50,
    this.allowTips = true,
    this.allowDelayedOrders = true,
    this.preparationTimeMinutes = 15,
    this.estimatedDeliveryMinutes = 30,
    this.maxScheduleAheadHours = 48,
    this.areas = const [],
    this.schedule = const {},
    this.deliveryMessage,
    this.maxConcurrentDeliveries,
    this.enableRealTimeTracking = false,
    this.defaultDriverInstructions,
  });

  /// Crée une copie de ces paramètres avec les champs modifiés.
  DeliverySettings copyWith({
    double? minimumOrderAmount,
    double? deliveryFee,
    double? freeDeliveryThreshold,
    double? radiusKm,
    double? feePerKm,
    bool? allowTips,
    bool? allowDelayedOrders,
    int? preparationTimeMinutes,
    int? estimatedDeliveryMinutes,
    int? maxScheduleAheadHours,
    List<DeliveryArea>? areas,
    Map<int, Map<String, String>>? schedule,
    String? deliveryMessage,
    int? maxConcurrentDeliveries,
    bool? enableRealTimeTracking,
    String? defaultDriverInstructions,
  }) {
    return DeliverySettings(
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      freeDeliveryThreshold:
          freeDeliveryThreshold ?? this.freeDeliveryThreshold,
      radiusKm: radiusKm ?? this.radiusKm,
      feePerKm: feePerKm ?? this.feePerKm,
      allowTips: allowTips ?? this.allowTips,
      allowDelayedOrders: allowDelayedOrders ?? this.allowDelayedOrders,
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
      estimatedDeliveryMinutes:
          estimatedDeliveryMinutes ?? this.estimatedDeliveryMinutes,
      maxScheduleAheadHours:
          maxScheduleAheadHours ?? this.maxScheduleAheadHours,
      areas: areas ?? this.areas,
      schedule: schedule ?? this.schedule,
      deliveryMessage: deliveryMessage ?? this.deliveryMessage,
      maxConcurrentDeliveries:
          maxConcurrentDeliveries ?? this.maxConcurrentDeliveries,
      enableRealTimeTracking:
          enableRealTimeTracking ?? this.enableRealTimeTracking,
      defaultDriverInstructions:
          defaultDriverInstructions ?? this.defaultDriverInstructions,
    );
  }

  /// Sérialise les paramètres en JSON.
  Map<String, dynamic> toJson() {
    return {
      'minimumOrderAmount': minimumOrderAmount,
      'deliveryFee': deliveryFee,
      'freeDeliveryThreshold': freeDeliveryThreshold,
      'radiusKm': radiusKm,
      'feePerKm': feePerKm,
      'allowTips': allowTips,
      'allowDelayedOrders': allowDelayedOrders,
      'preparationTimeMinutes': preparationTimeMinutes,
      'estimatedDeliveryMinutes': estimatedDeliveryMinutes,
      'maxScheduleAheadHours': maxScheduleAheadHours,
      'areas': areas.map((a) => a.toJson()).toList(),
      'schedule': schedule.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'deliveryMessage': deliveryMessage,
      'maxConcurrentDeliveries': maxConcurrentDeliveries,
      'enableRealTimeTracking': enableRealTimeTracking,
      'defaultDriverInstructions': defaultDriverInstructions,
    };
  }

  /// Désérialise les paramètres depuis un JSON.
  factory DeliverySettings.fromJson(Map<String, dynamic> json) {
    // Parse schedule map
    final scheduleJson = json['schedule'] as Map<String, dynamic>? ?? {};
    final schedule = <int, Map<String, String>>{};
    scheduleJson.forEach((key, value) {
      final dayIndex = int.tryParse(key);
      if (dayIndex != null && value is Map) {
        schedule[dayIndex] = Map<String, String>.from(value);
      }
    });

    // Parse areas list
    final areasJson = json['areas'] as List<dynamic>? ?? [];
    final areas = areasJson
        .map((a) => DeliveryArea.fromJson(a as Map<String, dynamic>))
        .toList();

    return DeliverySettings(
      minimumOrderAmount:
          (json['minimumOrderAmount'] as num?)?.toDouble() ?? 15.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 2.50,
      freeDeliveryThreshold:
          (json['freeDeliveryThreshold'] as num?)?.toDouble(),
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 5.0,
      feePerKm: (json['feePerKm'] as num?)?.toDouble() ?? 0.50,
      allowTips: json['allowTips'] as bool? ?? true,
      allowDelayedOrders: json['allowDelayedOrders'] as bool? ?? true,
      preparationTimeMinutes: json['preparationTimeMinutes'] as int? ?? 15,
      estimatedDeliveryMinutes: json['estimatedDeliveryMinutes'] as int? ?? 30,
      maxScheduleAheadHours: json['maxScheduleAheadHours'] as int? ?? 48,
      areas: areas,
      schedule: schedule,
      deliveryMessage: json['deliveryMessage'] as String?,
      maxConcurrentDeliveries: json['maxConcurrentDeliveries'] as int?,
      enableRealTimeTracking: json['enableRealTimeTracking'] as bool? ?? false,
      defaultDriverInstructions: json['defaultDriverInstructions'] as String?,
    );
  }

  /// Crée des paramètres par défaut.
  factory DeliverySettings.defaults() {
    return const DeliverySettings();
  }

  /// Calcule les frais de livraison pour une distance donnée.
  double calculateFee(double distanceKm) {
    if (distanceKm <= radiusKm) {
      return deliveryFee;
    }
    final extraKm = distanceKm - radiusKm;
    return deliveryFee + (extraKm * feePerKm);
  }

  /// Vérifie si la livraison est gratuite pour un montant donné.
  bool isFreeDelivery(double orderAmount) {
    if (freeDeliveryThreshold == null) return false;
    return orderAmount >= freeDeliveryThreshold!;
  }

  /// Vérifie si une adresse (code postal) est dans une zone de livraison.
  DeliveryArea? findAreaByPostalCode(String postalCode) {
    for (final area in areas) {
      if (area.isActive && area.postalCodes.contains(postalCode)) {
        return area;
      }
    }
    return null;
  }

  /// Retourne les zones actives uniquement.
  List<DeliveryArea> get activeAreas {
    return areas.where((a) => a.isActive).toList();
  }

  @override
  String toString() {
    return 'DeliverySettings(minimumOrderAmount: $minimumOrderAmount, '
        'deliveryFee: $deliveryFee, radiusKm: $radiusKm, '
        'areas: ${areas.length}, allowTips: $allowTips)';
  }
}
