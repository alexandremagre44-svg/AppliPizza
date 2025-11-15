// test/services/roulette_rules_service_test.dart
// Tests for RouletteRulesService to verify null handling and eligibility checks

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/services/roulette_rules_service.dart';

void main() {
  group('RouletteRulesService', () {
    test('RouletteStatus.allowed creates correct status', () {
      final status = RouletteStatus.allowed();
      
      expect(status.canSpin, isTrue);
      expect(status.reason, isNull);
      expect(status.nextEligibleAt, isNull);
    });
    
    test('RouletteStatus.denied creates correct status', () {
      final reason = 'Test reason';
      final nextTime = DateTime.now().add(const Duration(hours: 1));
      final status = RouletteStatus.denied(reason, nextEligibleAt: nextTime);
      
      expect(status.canSpin, isFalse);
      expect(status.reason, equals(reason));
      expect(status.nextEligibleAt, equals(nextTime));
    });
    
    test('RouletteRules.fromMap creates rules with defaults', () {
      final rules = RouletteRules.fromMap({});
      
      expect(rules.minDelayHours, equals(24));
      expect(rules.dailyLimit, equals(1));
      expect(rules.weeklyLimit, equals(0));
      expect(rules.monthlyLimit, equals(0));
      expect(rules.allowedStartHour, equals(0));
      expect(rules.allowedEndHour, equals(23));
      expect(rules.isEnabled, isTrue);
    });
    
    test('RouletteRules.fromMap handles custom values', () {
      final rules = RouletteRules.fromMap({
        'minDelayHours': 12,
        'dailyLimit': 3,
        'weeklyLimit': 10,
        'monthlyLimit': 30,
        'allowedStartHour': 9,
        'allowedEndHour': 21,
        'isEnabled': false,
      });
      
      expect(rules.minDelayHours, equals(12));
      expect(rules.dailyLimit, equals(3));
      expect(rules.weeklyLimit, equals(10));
      expect(rules.monthlyLimit, equals(30));
      expect(rules.allowedStartHour, equals(9));
      expect(rules.allowedEndHour, equals(21));
      expect(rules.isEnabled, isFalse);
    });
    
    test('RouletteRules.toMap creates correct map', () {
      const rules = RouletteRules(
        minDelayHours: 12,
        dailyLimit: 3,
        weeklyLimit: 10,
        monthlyLimit: 30,
        allowedStartHour: 9,
        allowedEndHour: 21,
        isEnabled: false,
      );
      
      final map = rules.toMap();
      
      expect(map['minDelayHours'], equals(12));
      expect(map['dailyLimit'], equals(3));
      expect(map['weeklyLimit'], equals(10));
      expect(map['monthlyLimit'], equals(30));
      expect(map['allowedStartHour'], equals(9));
      expect(map['allowedEndHour'], equals(21));
      expect(map['isEnabled'], isFalse);
    });
    
    test('RouletteRules.copyWith updates only specified fields', () {
      const original = RouletteRules(
        minDelayHours: 24,
        dailyLimit: 1,
        isEnabled: true,
      );
      
      final updated = original.copyWith(
        minDelayHours: 12,
        isEnabled: false,
      );
      
      expect(updated.minDelayHours, equals(12));
      expect(updated.dailyLimit, equals(1)); // unchanged
      expect(updated.isEnabled, isFalse);
    });
  });
}
