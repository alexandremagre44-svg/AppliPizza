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
      
      expect(rules.cooldownHours, equals(24));
      expect(rules.maxPlaysPerDay, equals(1));
      expect(rules.weeklyLimit, equals(0));
      expect(rules.monthlyLimit, equals(0));
      expect(rules.allowedStartHour, equals(0));
      expect(rules.allowedEndHour, equals(23));
      expect(rules.isEnabled, isTrue);
      expect(rules.messageDisabled, equals('La roulette est actuellement désactivée'));
      expect(rules.messageUnavailable, equals('La roulette n\'est pas disponible'));
      expect(rules.messageCooldown, equals('Revenez demain pour retenter votre chance'));
    });
    
    test('RouletteRules.fromMap handles custom values', () {
      final rules = RouletteRules.fromMap({
        'cooldownHours': 12,
        'maxPlaysPerDay': 3,
        'weeklyLimit': 10,
        'monthlyLimit': 30,
        'allowedStartHour': 9,
        'allowedEndHour': 21,
        'isEnabled': false,
        'messageDisabled': 'Custom disabled message',
        'messageUnavailable': 'Custom unavailable message',
        'messageCooldown': 'Custom cooldown message',
      });
      
      expect(rules.cooldownHours, equals(12));
      expect(rules.maxPlaysPerDay, equals(3));
      expect(rules.weeklyLimit, equals(10));
      expect(rules.monthlyLimit, equals(30));
      expect(rules.allowedStartHour, equals(9));
      expect(rules.allowedEndHour, equals(21));
      expect(rules.isEnabled, isFalse);
      expect(rules.messageDisabled, equals('Custom disabled message'));
      expect(rules.messageUnavailable, equals('Custom unavailable message'));
      expect(rules.messageCooldown, equals('Custom cooldown message'));
    });
    
    test('RouletteRules.toMap creates correct map', () {
      const rules = RouletteRules(
        cooldownHours: 12,
        maxPlaysPerDay: 3,
        weeklyLimit: 10,
        monthlyLimit: 30,
        allowedStartHour: 9,
        allowedEndHour: 21,
        isEnabled: false,
        messageDisabled: 'Test disabled',
        messageUnavailable: 'Test unavailable',
        messageCooldown: 'Test cooldown',
      );
      
      final map = rules.toMap();
      
      expect(map['cooldownHours'], equals(12));
      expect(map['maxPlaysPerDay'], equals(3));
      expect(map['weeklyLimit'], equals(10));
      expect(map['monthlyLimit'], equals(30));
      expect(map['allowedStartHour'], equals(9));
      expect(map['allowedEndHour'], equals(21));
      expect(map['isEnabled'], isFalse);
      expect(map['messageDisabled'], equals('Test disabled'));
      expect(map['messageUnavailable'], equals('Test unavailable'));
      expect(map['messageCooldown'], equals('Test cooldown'));
    });
    
    test('RouletteRules.copyWith updates only specified fields', () {
      const original = RouletteRules(
        cooldownHours: 24,
        maxPlaysPerDay: 1,
        isEnabled: true,
      );
      
      final updated = original.copyWith(
        cooldownHours: 12,
        isEnabled: false,
      );
      
      expect(updated.cooldownHours, equals(12));
      expect(updated.maxPlaysPerDay, equals(1)); // unchanged
      expect(updated.isEnabled, isFalse);
    });
    
    test('RouletteRules.fromMap handles legacy field names', () {
      // Test backward compatibility with old field names
      final rules = RouletteRules.fromMap({
        'minDelayHours': 12,
        'dailyLimit': 3,
      });
      
      expect(rules.cooldownHours, equals(12));
      expect(rules.maxPlaysPerDay, equals(3));
    });
  });
}
