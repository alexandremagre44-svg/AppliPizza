/// test/builder/builder_modules_mapping_test.dart
///
/// Tests unitaires pour le mapping des modules Builder vers ModuleId white-label.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/builder/utils/builder_modules.dart';
import 'package:pizza_delizza/builder/models/builder_block.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';

void main() {
  group('Builder Module Mapping Tests', () {
    test('All ModuleConfig have valid requiredModuleId', () {
      for (final module in availableModules) {
        if (module.requiredModuleId != null) {
          expect(ModuleId.values, contains(module.requiredModuleId),
              reason: 'Module ${module.id} has invalid requiredModuleId');
        }
      }
    });

    test('moduleIdMapping contains all builder modules', () {
      for (final module in availableModules) {
        if (module.requiredModuleId != null) {
          expect(moduleIdMapping.containsKey(module.id), isTrue,
              reason: 'Module ${module.id} should be in moduleIdMapping');
        }
      }
    });

    test('getModuleIdForBuilder returns correct ModuleId', () {
      expect(getModuleIdForBuilder('roulette_module'), ModuleId.roulette);
      expect(getModuleIdForBuilder('kitchen_module'), ModuleId.kitchen_tablet);
      expect(getModuleIdForBuilder('loyalty_module'), ModuleId.loyalty);
      expect(getModuleIdForBuilder('delivery_module'), ModuleId.delivery);
      expect(getModuleIdForBuilder('staff_module'), ModuleId.staff_tablet);
      expect(getModuleIdForBuilder('promotions_module'), ModuleId.promotions);
      expect(getModuleIdForBuilder('newsletter_module'), ModuleId.newsletter);
      expect(getModuleIdForBuilder('unknown'), isNull);
    });

    test('SystemBlock.availableModules matches builder_modules', () {
      for (final id in ['menu_catalog', 'cart_module', 'roulette_module', 
                        'loyalty_module', 'delivery_module', 'kitchen_module']) {
        expect(SystemBlock.availableModules, contains(id),
            reason: 'SystemBlock should contain $id');
      }
    });

    test('normalizeModuleType correctly maps aliases', () {
      expect(normalizeModuleType('roulette'), 'roulette_module');
      expect(normalizeModuleType('loyalty'), 'loyalty_module');
      expect(normalizeModuleType('rewards'), 'rewards_module');
      expect(normalizeModuleType('menu_catalog'), 'menu_catalog');
    });

    test('SystemBlock.normalizeModuleType correctly maps aliases', () {
      expect(SystemBlock.normalizeModuleType('roulette'), 'roulette_module');
      expect(SystemBlock.normalizeModuleType('loyalty'), 'loyalty_module');
      expect(SystemBlock.normalizeModuleType('rewards'), 'rewards_module');
      expect(SystemBlock.normalizeModuleType('menu_catalog'), 'menu_catalog');
    });

    test('All new modules have labels and icons', () {
      final newModules = [
        'loyalty_module',
        'rewards_module',
        'delivery_module',
        'click_collect_module',
        'kitchen_module',
        'staff_module',
        'promotions_module',
        'newsletter_module',
      ];
      
      for (final moduleType in newModules) {
        final label = SystemBlock.getModuleLabel(moduleType);
        final icon = SystemBlock.getModuleIcon(moduleType);
        
        expect(label, isNot('Module inconnu'),
            reason: 'Module $moduleType should have a proper label');
        expect(icon, isNot('❓'),
            reason: 'Module $moduleType should have a proper icon');
      }
    });

    // Legacy tests for backward compatibility
    group('Legacy API (deprecated)', () {
      test('getModuleIdCode retourne le code correct pour menu_catalog', () {
        final code = getModuleIdCode('menu_catalog');
        expect(code, equals('ordering'));
      });

      test('getModuleId retourne ModuleId.ordering pour cart_module', () {
        final moduleId = getModuleId('cart_module');
        expect(moduleId, equals(ModuleId.ordering));
      });

      test('tous les modules Builder sont mappés vers des ModuleId valides', () {
        for (final builderId in builderModules.keys) {
          final moduleId = getModuleId(builderId);
          expect(moduleId, isNotNull,
              reason: 'Builder module "$builderId" should map to a valid ModuleId');
        }
      });
    });

    test('availableModules includes all 12+ white-label modules', () {
      // Should have at least 12 modules (as mentioned in the problem statement)
      expect(availableModules.length, greaterThanOrEqualTo(12),
          reason: 'Should have at least 12 modules defined');
      
      // Verify key modules are present
      final moduleIds = availableModules.map((m) => m.id).toList();
      expect(moduleIds, contains('menu_catalog'));
      expect(moduleIds, contains('cart_module'));
      expect(moduleIds, contains('roulette_module'));
      expect(moduleIds, contains('loyalty_module'));
      expect(moduleIds, contains('rewards_module'));
      expect(moduleIds, contains('delivery_module'));
      expect(moduleIds, contains('click_collect_module'));
      expect(moduleIds, contains('kitchen_module'));
      expect(moduleIds, contains('staff_module'));
      expect(moduleIds, contains('promotions_module'));
      expect(moduleIds, contains('newsletter_module'));
    });
  });
}
