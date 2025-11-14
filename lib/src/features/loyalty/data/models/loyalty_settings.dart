// lib/src/models/loyalty_settings.dart
// Model for loyalty program settings

class LoyaltySettings {
  final String id;
  final int pointsPerEuro;
  final int bronzeThreshold;
  final int silverThreshold;
  final int goldThreshold;
  final DateTime updatedAt;

  LoyaltySettings({
    required this.id,
    required this.pointsPerEuro,
    required this.bronzeThreshold,
    required this.silverThreshold,
    required this.goldThreshold,
    required this.updatedAt,
  });

  LoyaltySettings copyWith({
    String? id,
    int? pointsPerEuro,
    int? bronzeThreshold,
    int? silverThreshold,
    int? goldThreshold,
    DateTime? updatedAt,
  }) {
    return LoyaltySettings(
      id: id ?? this.id,
      pointsPerEuro: pointsPerEuro ?? this.pointsPerEuro,
      bronzeThreshold: bronzeThreshold ?? this.bronzeThreshold,
      silverThreshold: silverThreshold ?? this.silverThreshold,
      goldThreshold: goldThreshold ?? this.goldThreshold,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pointsPerEuro': pointsPerEuro,
      'bronzeThreshold': bronzeThreshold,
      'silverThreshold': silverThreshold,
      'goldThreshold': goldThreshold,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LoyaltySettings.fromJson(Map<String, dynamic> json) {
    return LoyaltySettings(
      id: json['id'] as String,
      pointsPerEuro: json['pointsPerEuro'] as int,
      bronzeThreshold: json['bronzeThreshold'] as int,
      silverThreshold: json['silverThreshold'] as int,
      goldThreshold: json['goldThreshold'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static LoyaltySettings defaultSettings() {
    return LoyaltySettings(
      id: 'main',
      pointsPerEuro: 1,
      bronzeThreshold: 0,
      silverThreshold: 500,
      goldThreshold: 1000,
      updatedAt: DateTime.now(),
    );
  }
}
