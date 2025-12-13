/// lib/white_label/modules/core/click_and_collect/click_and_collect_settings.dart
///
/// Paramètres complets du module Click & Collect.
library;

/// Point de retrait pour Click & Collect.
class PickupPoint {
  /// Identifiant unique du point de retrait.
  final String id;

  /// Nom du point de retrait.
  final String name;

  /// Adresse complète.
  final String address;

  /// Instructions spécifiques pour le retrait.
  final String? instructions;

  /// Indique si ce point est actif.
  final bool isActive;

  /// Coordonnées GPS (optionnel).
  final double? latitude;
  final double? longitude;

  const PickupPoint({
    required this.id,
    required this.name,
    required this.address,
    this.instructions,
    this.isActive = true,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'instructions': instructions,
      'isActive': isActive,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    return PickupPoint(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      instructions: json['instructions'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  PickupPoint copyWith({
    String? id,
    String? name,
    String? address,
    String? instructions,
    bool? isActive,
    double? latitude,
    double? longitude,
  }) {
    return PickupPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      instructions: instructions ?? this.instructions,
      isActive: isActive ?? this.isActive,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

/// Créneau horaire pour le retrait.
class TimeSlot {
  /// Heure de début (format HH:mm).
  final String startTime;

  /// Heure de fin (format HH:mm).
  final String endTime;

  /// Capacité maximale pour ce créneau (nombre de commandes).
  final int? capacity;

  /// Jours de la semaine où ce créneau est disponible.
  /// 0 = lundi, 6 = dimanche. Si vide, disponible tous les jours.
  final List<int> availableDays;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    this.capacity,
    this.availableDays = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'capacity': capacity,
      'availableDays': availableDays,
    };
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      capacity: json['capacity'] as int?,
      availableDays: (json['availableDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  TimeSlot copyWith({
    String? startTime,
    String? endTime,
    int? capacity,
    List<int>? availableDays,
  }) {
    return TimeSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      availableDays: availableDays ?? this.availableDays,
    );
  }

  /// Vérifie si ce créneau est disponible un jour donné.
  bool isAvailableOnDay(int dayIndex) {
    if (availableDays.isEmpty) return true;
    return availableDays.contains(dayIndex);
  }

  @override
  String toString() => '$startTime - $endTime';
}

/// Paramètres de configuration du module Click & Collect.
class ClickAndCollectSettings {
  /// Temps de préparation minimum en minutes.
  final int preparationTimeMinutes;

  /// Permet le retrait le jour même.
  final bool allowSameDayPickup;

  /// Nombre de jours maximum à l'avance pour réserver.
  final int maxDaysAhead;

  /// Points de retrait disponibles.
  final List<PickupPoint> pickupPoints;

  /// Créneaux horaires disponibles.
  final List<TimeSlot> timeSlots;

  /// Capacité maximale globale par créneau (si non spécifié par créneau).
  final int? defaultCapacityPerSlot;

  /// Montant minimum de commande pour le Click & Collect.
  final double? minimumOrderAmount;

  /// Message personnalisé affiché lors du Click & Collect.
  final String? pickupMessage;

  /// Permet aux clients d'ajouter des notes de retrait.
  final bool allowPickupNotes;

  /// Activer les notifications de confirmation.
  final bool enableConfirmationNotifications;

  /// Délai d'annulation en heures (0 = pas d'annulation possible).
  final int cancellationDeadlineHours;

  const ClickAndCollectSettings({
    this.preparationTimeMinutes = 30,
    this.allowSameDayPickup = true,
    this.maxDaysAhead = 7,
    this.pickupPoints = const [],
    this.timeSlots = const [],
    this.defaultCapacityPerSlot,
    this.minimumOrderAmount,
    this.pickupMessage,
    this.allowPickupNotes = true,
    this.enableConfirmationNotifications = true,
    this.cancellationDeadlineHours = 2,
  });

  Map<String, dynamic> toJson() {
    return {
      'preparationTimeMinutes': preparationTimeMinutes,
      'allowSameDayPickup': allowSameDayPickup,
      'maxDaysAhead': maxDaysAhead,
      'pickupPoints': pickupPoints.map((p) => p.toJson()).toList(),
      'timeSlots': timeSlots.map((t) => t.toJson()).toList(),
      'defaultCapacityPerSlot': defaultCapacityPerSlot,
      'minimumOrderAmount': minimumOrderAmount,
      'pickupMessage': pickupMessage,
      'allowPickupNotes': allowPickupNotes,
      'enableConfirmationNotifications': enableConfirmationNotifications,
      'cancellationDeadlineHours': cancellationDeadlineHours,
    };
  }

  factory ClickAndCollectSettings.fromJson(Map<String, dynamic> json) {
    final pickupPointsJson = json['pickupPoints'] as List<dynamic>? ?? [];
    final pickupPoints = pickupPointsJson
        .map((p) => PickupPoint.fromJson(p as Map<String, dynamic>))
        .toList();

    final timeSlotsJson = json['timeSlots'] as List<dynamic>? ?? [];
    final timeSlots = timeSlotsJson
        .map((t) => TimeSlot.fromJson(t as Map<String, dynamic>))
        .toList();

    return ClickAndCollectSettings(
      preparationTimeMinutes: json['preparationTimeMinutes'] as int? ?? 30,
      allowSameDayPickup: json['allowSameDayPickup'] as bool? ?? true,
      maxDaysAhead: json['maxDaysAhead'] as int? ?? 7,
      pickupPoints: pickupPoints,
      timeSlots: timeSlots,
      defaultCapacityPerSlot: json['defaultCapacityPerSlot'] as int?,
      minimumOrderAmount: (json['minimumOrderAmount'] as num?)?.toDouble(),
      pickupMessage: json['pickupMessage'] as String?,
      allowPickupNotes: json['allowPickupNotes'] as bool? ?? true,
      enableConfirmationNotifications:
          json['enableConfirmationNotifications'] as bool? ?? true,
      cancellationDeadlineHours: json['cancellationDeadlineHours'] as int? ?? 2,
    );
  }

  ClickAndCollectSettings copyWith({
    int? preparationTimeMinutes,
    bool? allowSameDayPickup,
    int? maxDaysAhead,
    List<PickupPoint>? pickupPoints,
    List<TimeSlot>? timeSlots,
    int? defaultCapacityPerSlot,
    double? minimumOrderAmount,
    String? pickupMessage,
    bool? allowPickupNotes,
    bool? enableConfirmationNotifications,
    int? cancellationDeadlineHours,
  }) {
    return ClickAndCollectSettings(
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
      allowSameDayPickup: allowSameDayPickup ?? this.allowSameDayPickup,
      maxDaysAhead: maxDaysAhead ?? this.maxDaysAhead,
      pickupPoints: pickupPoints ?? this.pickupPoints,
      timeSlots: timeSlots ?? this.timeSlots,
      defaultCapacityPerSlot:
          defaultCapacityPerSlot ?? this.defaultCapacityPerSlot,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      pickupMessage: pickupMessage ?? this.pickupMessage,
      allowPickupNotes: allowPickupNotes ?? this.allowPickupNotes,
      enableConfirmationNotifications: enableConfirmationNotifications ??
          this.enableConfirmationNotifications,
      cancellationDeadlineHours:
          cancellationDeadlineHours ?? this.cancellationDeadlineHours,
    );
  }

  factory ClickAndCollectSettings.defaults() {
    return const ClickAndCollectSettings();
  }

  /// Retourne les points de retrait actifs.
  List<PickupPoint> get activePickupPoints {
    return pickupPoints.where((p) => p.isActive).toList();
  }

  /// Retourne les créneaux disponibles pour un jour donné.
  List<TimeSlot> availableSlotsForDay(int dayIndex) {
    return timeSlots.where((slot) => slot.isAvailableOnDay(dayIndex)).toList();
  }

  /// Vérifie si un montant de commande est suffisant.
  bool isOrderAmountValid(double amount) {
    if (minimumOrderAmount == null) return true;
    return amount >= minimumOrderAmount!;
  }

  @override
  String toString() {
    return 'ClickAndCollectSettings('
        'preparationTime: ${preparationTimeMinutes}min, '
        'pickupPoints: ${pickupPoints.length}, '
        'timeSlots: ${timeSlots.length})';
  }
}
