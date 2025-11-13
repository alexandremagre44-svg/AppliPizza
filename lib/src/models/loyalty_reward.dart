// lib/src/models/loyalty_reward.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Type de récompense disponible
class RewardType {
  static const String freePizza = 'free_pizza';
  static const String bonusPoints = 'bonus_points';
  static const String freeDrink = 'free_drink';
  static const String freeDessert = 'free_dessert';
}

/// Niveau VIP du client
class VipTier {
  static const String bronze = 'bronze';
  static const String silver = 'silver';
  static const String gold = 'gold';

  static String getTierFromLifetimePoints(int points) {
    if (points >= 5000) return gold;
    if (points >= 2000) return silver;
    return bronze;
  }

  static double getDiscount(String tier) {
    switch (tier) {
      case silver:
        return 0.05; // 5%
      case gold:
        return 0.10; // 10%
      default:
        return 0.0;
    }
  }
}

/// Récompense de fidélité
class LoyaltyReward {
  final String type;
  final int? value; // Utilisé pour bonus_points
  final bool used;
  final DateTime createdAt;
  final DateTime? usedAt;

  LoyaltyReward({
    required this.type,
    this.value,
    this.used = false,
    required this.createdAt,
    this.usedAt,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
        'used': used,
        'createdAt': Timestamp.fromDate(createdAt),
        'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      };

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    DateTime createdAt = DateTime.now();
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    }

    DateTime? usedAt;
    if (json['usedAt'] != null) {
      if (json['usedAt'] is Timestamp) {
        usedAt = (json['usedAt'] as Timestamp).toDate();
      } else if (json['usedAt'] is String) {
        usedAt = DateTime.parse(json['usedAt']);
      }
    }

    return LoyaltyReward(
      type: json['type'] as String,
      value: json['value'] as int?,
      used: json['used'] as bool? ?? false,
      createdAt: createdAt,
      usedAt: usedAt,
    );
  }

  LoyaltyReward copyWith({
    String? type,
    int? value,
    bool? used,
    DateTime? createdAt,
    DateTime? usedAt,
  }) {
    return LoyaltyReward(
      type: type ?? this.type,
      value: value ?? this.value,
      used: used ?? this.used,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
    );
  }
}
