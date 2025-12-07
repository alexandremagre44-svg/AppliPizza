// test/restaurant_plan_provider_test.dart
// Tests for Restaurant Plan Provider with modules[] structure

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';
import 'package:pizza_delizza/white_label/core/module_config.dart';

void main() {
  group('RestaurantPlanUnified with modules[] structure', () {
    test('fromJson correctly parses modules and computes activeModules', () {
      final json = {
        'restaurantId': 'test_resto',
        'name': 'Test Restaurant',
        'slug': 'test-resto',
        'modules': [
          {'id': 'ordering', 'enabled': true, 'settings': {}},
          {'id': 'delivery', 'enabled': false, 'settings': {}},
          {'id': 'roulette', 'enabled': true, 'settings': {}},
        ],
        'branding': {
          'brandName': 'Pizza DeliZza',
          'primaryColor': '#FFF',
        }
      };

      final plan = RestaurantPlanUnified.fromJson(json);

      expect(plan.restaurantId, 'test_resto');
      expect(plan.modules.length, 3);
      expect(plan.activeModules, ['ordering', 'roulette']);
      expect(plan.branding?.brandName, 'Pizza DeliZza');
    });

    test('activeModules only includes enabled modules', () {
      final json = {
        'restaurantId': 'test_resto',
        'name': 'Test Restaurant',
        'slug': 'test-resto',
        'modules': [
          {'id': 'ordering', 'enabled': true, 'settings': {}},
          {'id': 'delivery', 'enabled': false, 'settings': {}},
          {'id': 'roulette', 'enabled': false, 'settings': {}},
          {'id': 'loyalty', 'enabled': true, 'settings': {}},
        ],
      };

      final plan = RestaurantPlanUnified.fromJson(json);

      expect(plan.activeModules, ['ordering', 'loyalty']);
      expect(plan.activeModules, isNot(contains('delivery')));
      expect(plan.activeModules, isNot(contains('roulette')));
    });

    test('hasModule works with string ID', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['ordering', 'roulette'],
      );

      expect(plan.hasModule('ordering'), true);
      expect(plan.hasModule('roulette'), true);
      expect(plan.hasModule('delivery'), false);
      expect(plan.hasModule('loyalty'), false);
    });

    test('empty modules array returns empty activeModules', () {
      final json = {
        'restaurantId': 'test_resto',
        'name': 'Test Restaurant',
        'slug': 'test-resto',
        'modules': [],
      };

      final plan = RestaurantPlanUnified.fromJson(json);

      expect(plan.modules, isEmpty);
      expect(plan.activeModules, isEmpty);
    });

    test('missing modules field defaults to empty', () {
      final json = {
        'restaurantId': 'test_resto',
        'name': 'Test Restaurant',
        'slug': 'test-resto',
      };

      final plan = RestaurantPlanUnified.fromJson(json);

      expect(plan.modules, isEmpty);
      expect(plan.activeModules, isEmpty);
    });

    test('toJson includes modules array', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        modules: [
          ModuleConfig(id: 'ordering', enabled: true),
          ModuleConfig(id: 'delivery', enabled: false),
        ],
        activeModules: ['ordering'],
      );

      final json = plan.toJson();

      expect(json['modules'], isA<List>());
      expect((json['modules'] as List).length, 2);
      expect(json['activeModules'], ['ordering']);
    });

    test('BrandingConfig.empty() creates empty branding', () {
      final branding = BrandingConfig.empty();

      expect(branding.brandName, isNull);
      expect(branding.primaryColor, isNull);
      expect(branding.darkModeEnabled, false);
    });

    test('plan with all modules disabled has empty activeModules', () {
      final json = {
        'restaurantId': 'test_resto',
        'name': 'Test Restaurant',
        'slug': 'test-resto',
        'modules': [
          {'id': 'ordering', 'enabled': false, 'settings': {}},
          {'id': 'delivery', 'enabled': false, 'settings': {}},
          {'id': 'roulette', 'enabled': false, 'settings': {}},
        ],
      };

      final plan = RestaurantPlanUnified.fromJson(json);

      expect(plan.modules.length, 3);
      expect(plan.activeModules, isEmpty);
    });

    test('module settings are preserved in fromJson/toJson', () {
      final json = {
        'restaurantId': 'test_resto',
        'name': 'Test Restaurant',
        'slug': 'test-resto',
        'modules': [
          {
            'id': 'ordering',
            'enabled': true,
            'settings': {'maxItems': 10, 'allowGuest': true}
          },
        ],
      };

      final plan = RestaurantPlanUnified.fromJson(json);
      final moduleConfig = plan.modules.first;

      expect(moduleConfig.settings['maxItems'], 10);
      expect(moduleConfig.settings['allowGuest'], true);

      // Verify round-trip
      final jsonOut = plan.toJson();
      final modulesOut = jsonOut['modules'] as List;
      final firstModule = modulesOut.first as Map<String, dynamic>;
      
      expect(firstModule['settings']['maxItems'], 10);
      expect(firstModule['settings']['allowGuest'], true);
    });
  });

  group('ModuleConfig', () {
    test('fromJson correctly parses module config', () {
      final json = {
        'id': 'ordering',
        'enabled': true,
        'settings': {'test': 'value'}
      };

      final config = ModuleConfig.fromJson(json);

      expect(config.id, 'ordering');
      expect(config.enabled, true);
      expect(config.settings['test'], 'value');
    });

    test('fromJson handles missing fields', () {
      final json = {'id': 'ordering'};

      final config = ModuleConfig.fromJson(json);

      expect(config.id, 'ordering');
      expect(config.enabled, false);
      expect(config.settings, isEmpty);
    });

    test('toJson produces correct structure', () {
      final config = ModuleConfig(
        id: 'ordering',
        enabled: true,
        settings: {'key': 'value'},
      );

      final json = config.toJson();

      expect(json['id'], 'ordering');
      expect(json['enabled'], true);
      expect(json['settings']['key'], 'value');
    });
  });
}
