// lib/src/models/business_hours.dart
// Modèle pour les horaires d'ouverture

class BusinessHours {
  final String dayOfWeek; // 'Lundi', 'Mardi', etc.
  final String openTime; // '09:00'
  final String closeTime; // '22:00'
  final bool isClosed; // Fermé ce jour

  BusinessHours({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    this.isClosed = false,
  });

  BusinessHours copyWith({
    String? dayOfWeek,
    String? openTime,
    String? closeTime,
    bool? isClosed,
  }) {
    return BusinessHours(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }

  factory BusinessHours.fromJson(Map<String, dynamic> json) {
    return BusinessHours(
      dayOfWeek: json['dayOfWeek'] as String,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
      isClosed: json['isClosed'] as bool? ?? false,
    );
  }
}

class ExceptionalClosure {
  final String id;
  final DateTime date;
  final String reason;

  ExceptionalClosure({
    required this.id,
    required this.date,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'reason': reason,
    };
  }

  factory ExceptionalClosure.fromJson(Map<String, dynamic> json) {
    return ExceptionalClosure(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      reason: json['reason'] as String,
    );
  }
}
