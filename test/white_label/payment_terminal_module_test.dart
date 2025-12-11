/// test/white_label/payment_terminal_module_test.dart
///
/// Tests unitaires pour le module payment_terminal.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/core/module_config.dart';
import 'package:pizza_delizza/white_label/modules/payment/terminals/payment_terminal_module_config.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_feature_flags.dart';
import 'package:pizza_delizza/white_label/runtime/module_runtime_adapter.dart';

void main() {
  group('PaymentTerminal Module - ModuleId', () {
    test('ModuleId.paymentTerminal existe dans l\'enum', () {
      expect(ModuleId.values, contains(ModuleId.paymentTerminal));
    });

    test('ModuleId.paymentTerminal a le bon code', () {
      expect(ModuleId.paymentTerminal.code, equals('payment_terminal'));
    });

    test('ModuleId.paymentTerminal a le bon label', () {
      expect(ModuleId.paymentTerminal.label, equals('Terminal de paiement'));
    });

    test('ModuleId.paymentTerminal a la bonne catégorie', () {
      expect(ModuleId.paymentTerminal.category.toString(), contains('payment'));
    });
  });

  group('PaymentTerminal Module - ModuleConfig', () {
    test('ModuleConfig peut être créé pour payment_terminal', () {
      final config = ModuleConfig(
        id: 'payment_terminal',
        enabled: true,
        settings: {'provider': 'stripe'},
      );

      expect(config.id, equals('payment_terminal'));
      expect(config.enabled, isTrue);
      expect(config.settings['provider'], equals('stripe'));
    });

    test('ModuleConfig supporte la sérialisation JSON', () {
      final config = ModuleConfig(
        id: 'payment_terminal',
        enabled: true,
        settings: {},
      );

      final json = config.toJson();
      final restored = ModuleConfig.fromJson(json);

      expect(restored.id, equals('payment_terminal'));
      expect(restored.enabled, isTrue);
      expect(restored.settings, isEmpty);
    });
  });

  group('PaymentTerminal Module - PaymentTerminalModuleConfig', () {
    test('PaymentTerminalModuleConfig peut être créé', () {
      final config = PaymentTerminalModuleConfig(
        enabled: true,
        settings: {'terminalId': 'term_123'},
      );

      expect(config.enabled, isTrue);
      expect(config.settings['terminalId'], equals('term_123'));
    });

    test('PaymentTerminalModuleConfig supporte JSON', () {
      final config = PaymentTerminalModuleConfig(
        enabled: true,
        settings: {'provider': 'stripe'},
      );

      final json = config.toJson();
      final restored = PaymentTerminalModuleConfig.fromJson(json);

      expect(restored.enabled, isTrue);
      expect(restored.settings['provider'], equals('stripe'));
    });

    test('PaymentTerminalModuleConfig a des valeurs par défaut correctes', () {
      const config = PaymentTerminalModuleConfig();

      expect(config.enabled, isFalse);
      expect(config.settings, isEmpty);
    });
  });

  group('PaymentTerminal Module - RestaurantPlanUnified', () {
    test('RestaurantPlanUnified accepte paymentTerminal config', () {
      final config = PaymentTerminalModuleConfig(enabled: true);
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['payment_terminal'],
        paymentTerminal: config,
      );

      expect(plan.paymentTerminal, isNotNull);
      expect(plan.paymentTerminal!.enabled, isTrue);
      expect(plan.hasModule(ModuleId.paymentTerminal), isTrue);
    });

    test('RestaurantPlanUnified gère payment_terminal dans fromJson', () {
      final json = {
        'restaurantId': 'test_123',
        'name': 'Test Restaurant',
        'slug': 'test-restaurant',
        'modules': [
          {
            'id': 'payment_terminal',
            'enabled': true,
            'settings': {},
          }
        ],
        'paymentTerminal': {
          'enabled': true,
          'settings': {'provider': 'stripe'},
        },
      };

      final plan = RestaurantPlanUnified.fromJson(json);

      expect(plan.paymentTerminal, isNotNull);
      expect(plan.paymentTerminal!.enabled, isTrue);
      expect(plan.paymentTerminal!.settings['provider'], equals('stripe'));
      expect(plan.activeModules, contains('payment_terminal'));
    });

    test('RestaurantPlanUnified gère l\'absence de paymentTerminal', () {
      final json = {
        'restaurantId': 'test_123',
        'name': 'Test Restaurant',
        'slug': 'test-restaurant',
        'modules': [],
      };

      final plan = RestaurantPlanUnified.fromJson(json);

      expect(plan.paymentTerminal, isNull);
      expect(plan.hasModule(ModuleId.paymentTerminal), isFalse);
    });

    test('RestaurantPlanUnified sérialise paymentTerminal correctement', () {
      final config = PaymentTerminalModuleConfig(
        enabled: true,
        settings: {'terminalId': 'term_456'},
      );
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        paymentTerminal: config,
      );

      final json = plan.toJson();

      expect(json['paymentTerminal'], isNotNull);
      expect(json['paymentTerminal']['enabled'], isTrue);
      expect(json['paymentTerminal']['settings']['terminalId'], equals('term_456'));
    });
  });

  group('PaymentTerminal Module - RestaurantFeatureFlags', () {
    test('paymentTerminalEnabled retourne true si module activé', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['payment_terminal'],
      );
      final flags = RestaurantFeatureFlags(plan);

      expect(flags.paymentTerminalEnabled, isTrue);
      expect(flags.has(ModuleId.paymentTerminal), isTrue);
    });

    test('paymentTerminalEnabled retourne false si module désactivé', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: [],
      );
      final flags = RestaurantFeatureFlags(plan);

      expect(flags.paymentTerminalEnabled, isFalse);
      expect(flags.has(ModuleId.paymentTerminal), isFalse);
    });

    test('has() fonctionne avec ModuleId.paymentTerminal', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['payment_terminal', 'staff_tablet'],
      );
      final flags = RestaurantFeatureFlags(plan);

      expect(flags.has(ModuleId.paymentTerminal), isTrue);
      expect(flags.has(ModuleId.staff_tablet), isTrue);
      expect(flags.has(ModuleId.wallet), isFalse);
    });
  });

  group('PaymentTerminal Module - ModuleRuntimeAdapter', () {
    test('isModuleActive détecte payment_terminal', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['payment_terminal'],
      );

      expect(
        ModuleRuntimeAdapter.isModuleActive(plan, 'payment_terminal'),
        isTrue,
      );
    });

    test('isModuleActiveById fonctionne avec ModuleId.paymentTerminal', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['payment_terminal', 'payments'],
      );

      expect(
        ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.paymentTerminal),
        isTrue,
      );
      expect(
        ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.payments),
        isTrue,
      );
    });

    test('getActiveModules inclut payment_terminal', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['payment_terminal', 'delivery'],
      );

      final activeModules = ModuleRuntimeAdapter.getActiveModules(plan);

      expect(activeModules, contains(ModuleId.paymentTerminal));
      expect(activeModules, contains(ModuleId.delivery));
      expect(activeModules.length, equals(2));
    });

    test('getInactiveModules exclut payment_terminal si activé', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['payment_terminal'],
      );

      final inactiveModules = ModuleRuntimeAdapter.getInactiveModules(plan);

      expect(inactiveModules, isNot(contains(ModuleId.paymentTerminal)));
      expect(inactiveModules, contains(ModuleId.delivery));
    });

    test('isAnyModuleActive fonctionne avec payment_terminal', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['payment_terminal'],
      );

      expect(
        ModuleRuntimeAdapter.isAnyModuleActive(
          plan,
          [ModuleId.paymentTerminal, ModuleId.wallet],
        ),
        isTrue,
      );

      expect(
        ModuleRuntimeAdapter.isAnyModuleActive(
          plan,
          [ModuleId.wallet, ModuleId.loyalty],
        ),
        isFalse,
      );
    });
  });

  group('PaymentTerminal Module - Firestore Compatibility', () {
    test('accepte la config Firestore standard', () {
      final json = {
        'restaurantId': 'test_123',
        'name': 'Test Restaurant',
        'slug': 'test-restaurant',
        'modules': [
          {
            'id': 'payment_terminal',
            'enabled': true,
            'settings': {},
          }
        ],
      };

      final plan = RestaurantPlanUnified.fromJson(json);

      expect(plan.activeModules, contains('payment_terminal'));
      expect(plan.hasModule('payment_terminal'), isTrue);
    });

    test('est backward-compatible si module manquant', () {
      final json = {
        'restaurantId': 'test_123',
        'name': 'Test Restaurant',
        'slug': 'test-restaurant',
        'modules': [
          {
            'id': 'payments',
            'enabled': true,
            'settings': {},
          }
        ],
      };

      final plan = RestaurantPlanUnified.fromJson(json);

      expect(plan.hasModule('payment_terminal'), isFalse);
      expect(plan.paymentTerminal, isNull);
      // Ne doit pas planter
    });
  });

  group('PaymentTerminal Module - POS Integration', () {
    test('POS accessible si staff_tablet OU payment_terminal activé', () {
      final plan1 = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['payment_terminal'],
      );
      final flags1 = RestaurantFeatureFlags(plan1);

      expect(
        flags1.has(ModuleId.payment_terminal) || flags1.has(ModuleId.staff_tablet),
        isTrue,
      );

      final plan2 = RestaurantPlanUnified(
        restaurantId: 'test_456',
        name: 'Test Restaurant 2',
        slug: 'test-restaurant-2',
        activeModules: ['staff_tablet'],
      );
      final flags2 = RestaurantFeatureFlags(plan2);

      expect(
        flags2.has(ModuleId.payment_terminal) || flags2.has(ModuleId.staff_tablet),
        isTrue,
      );
    });
  });
}
