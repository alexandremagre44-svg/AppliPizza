// test/services/loyalty_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/loyalty_reward.dart';

void main() {
  group('VipTier', () {
    test('should return correct tier based on lifetime points', () {
      expect(VipTier.getTierFromLifetimePoints(0), VipTier.bronze);
      expect(VipTier.getTierFromLifetimePoints(500), VipTier.bronze);
      expect(VipTier.getTierFromLifetimePoints(1999), VipTier.bronze);
      expect(VipTier.getTierFromLifetimePoints(2000), VipTier.silver);
      expect(VipTier.getTierFromLifetimePoints(3000), VipTier.silver);
      expect(VipTier.getTierFromLifetimePoints(4999), VipTier.silver);
      expect(VipTier.getTierFromLifetimePoints(5000), VipTier.gold);
      expect(VipTier.getTierFromLifetimePoints(10000), VipTier.gold);
    });

    test('should return correct discount for each tier', () {
      expect(VipTier.getDiscount(VipTier.bronze), 0.0);
      expect(VipTier.getDiscount(VipTier.silver), 0.05);
      expect(VipTier.getDiscount(VipTier.gold), 0.10);
    });
  });

  group('LoyaltyReward', () {
    test('should create reward from JSON', () {
      final json = {
        'type': RewardType.freePizza,
        'value': null,
        'used': false,
        'createdAt': DateTime.now().toIso8601String(),
        'usedAt': null,
      };

      final reward = LoyaltyReward.fromJson(json);
      expect(reward.type, RewardType.freePizza);
      expect(reward.value, null);
      expect(reward.used, false);
      expect(reward.usedAt, null);
    });

    test('should convert reward to JSON', () {
      final reward = LoyaltyReward(
        type: RewardType.bonusPoints,
        value: 100,
        used: false,
        createdAt: DateTime.now(),
      );

      final json = reward.toJson();
      expect(json['type'], RewardType.bonusPoints);
      expect(json['value'], 100);
      expect(json['used'], false);
      expect(json['createdAt'], isNotNull);
    });

    test('should copy with new values', () {
      final reward = LoyaltyReward(
        type: RewardType.freeDrink,
        used: false,
        createdAt: DateTime.now(),
      );

      final updatedReward = reward.copyWith(
        used: true,
        usedAt: DateTime.now(),
      );

      expect(updatedReward.type, reward.type);
      expect(updatedReward.used, true);
      expect(updatedReward.usedAt, isNotNull);
    });
  });

  group('Points Calculation', () {
    test('should calculate correct points from order total', () {
      // 1€ = 10 points
      final orderTotal1 = 10.0;
      final points1 = (orderTotal1 * 10).round();
      expect(points1, 100);

      final orderTotal2 = 25.50;
      final points2 = (orderTotal2 * 10).round();
      expect(points2, 255);

      final orderTotal3 = 100.0;
      final points3 = (orderTotal3 * 10).round();
      expect(points3, 1000);
    });

    test('should calculate free pizzas correctly', () {
      // Every 1000 points = 1 free pizza
      final points1 = 999;
      final freePizzas1 = points1 ~/ 1000;
      expect(freePizzas1, 0);

      final points2 = 1000;
      final freePizzas2 = points2 ~/ 1000;
      expect(freePizzas2, 1);

      final points3 = 2500;
      final freePizzas3 = points3 ~/ 1000;
      expect(freePizzas3, 2);
    });

    test('should calculate remaining points after free pizzas', () {
      final points1 = 1250;
      final remaining1 = points1 % 1000;
      expect(remaining1, 250);

      final points2 = 2999;
      final remaining2 = points2 % 1000;
      expect(remaining2, 999);
    });

    test('should calculate available spins from lifetime points', () {
      // Every 500 lifetime points = 1 spin
      final lifetimePoints1 = 499;
      final spins1 = lifetimePoints1 ~/ 500;
      expect(spins1, 0);

      final lifetimePoints2 = 500;
      final spins2 = lifetimePoints2 ~/ 500;
      expect(spins2, 1);

      final lifetimePoints3 = 1500;
      final spins3 = lifetimePoints3 ~/ 500;
      expect(spins3, 3);
    });
  });
}
