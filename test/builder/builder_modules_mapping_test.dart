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
      // Expected: 3 core + 4 marketing + 2 operations + 2 admin = 11 main modules
      // Plus profile_module (always available) = 12 modules minimum
      // Plus click_collect_module = 13 modules total
      expect(availableModules.length, greaterThanOrEqualTo(12),
          reason: 'Should have at least 12 modules (core + marketing + operations + admin)');
      
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

  group('Module Filtering by Plan Tests', () {
    test('isBuilderModuleAvailableForPlan returns true when plan is null (fallback safe)', () {
      expect(isBuilderModuleAvailableForPlan('roulette_module', null), isTrue);
      expect(isBuilderModuleAvailableForPlan('loyalty_module', null), isTrue);
      expect(isBuilderModuleAvailableForPlan('unknown_module', null), isTrue);
    });

    test('isBuilderModuleAvailableForPlan returns true for unmapped modules (legacy)', () {
      // Create a mock plan with no modules
      final mockPlan = createMockPlan([]);
      expect(isBuilderModuleAvailableForPlan('accountActivity', mockPlan), isTrue,
          reason: 'Unmapped modules should always be available for backward compatibility');
    });

    test('isBuilderModuleAvailableForPlan checks module correctly', () {
      // Create a plan with only roulette enabled
      final planWithRoulette = createMockPlan(['roulette']);
      expect(isBuilderModuleAvailableForPlan('roulette_module', planWithRoulette), isTrue);
      expect(isBuilderModuleAvailableForPlan('loyalty_module', planWithRoulette), isFalse);
    });

    test('getAvailableModulesForPlan returns all modules when plan is null', () {
      final filtered = getAvailableModulesForPlan(null);
      expect(filtered.length, equals(availableModules.length));
    });

    test('getAvailableModulesForPlan filters modules correctly', () {
      final planWithRouletteOnly = createMockPlan(['roulette']);
      final filtered = getAvailableModulesForPlan(planWithRouletteOnly);
      
      // Should contain profile_module (no requiredModuleId) and roulette_module
      final filteredIds = filtered.map((m) => m.id).toList();
      expect(filteredIds, contains('profile_module'));
      expect(filteredIds, contains('roulette_module'));
      
      // Should NOT contain loyalty_module (requires loyalty ModuleId)
      expect(filteredIds, isNot(contains('loyalty_module')));
    });

    test('SystemBlock.getFilteredModules returns only always-visible modules when plan is null', () {
      final filtered = SystemBlock.getFilteredModules(null);
      // Should contain always-visible modules
      expect(filtered, contains('menu_catalog'));
      expect(filtered, contains('profile_module'));
      // Should NOT contain WL modules
      expect(filtered, isNot(contains('loyalty_module')));
      expect(filtered, isNot(contains('roulette_module')));
    });

    test('SystemBlock.getFilteredModules filters correctly with plan', () {
      final mockPlanData = _MockRestaurantPlanWithModules(['roulette']);
      final filtered = SystemBlock.getFilteredModules(mockPlanData);
      
      // Should contain always-visible modules
      expect(filtered, contains('menu_catalog'));
      expect(filtered, contains('profile_module'));
      
      // Should contain roulette_module (enabled in plan)
      expect(filtered, contains('roulette_module'));
      
      // Should NOT contain loyalty_module (not enabled in plan)
      expect(filtered, isNot(contains('loyalty_module')));
    });

    test('SystemBlock.getFilteredModules handles loyalty module correctly', () {
      final mockPlanData = _MockRestaurantPlanWithModules(['loyalty']);
      final filtered = SystemBlock.getFilteredModules(mockPlanData);
      
      // Should contain always-visible modules
      expect(filtered, contains('menu_catalog'));
      expect(filtered, contains('profile_module'));
      
      // Should contain both loyalty_module AND rewards_module (1-to-many mapping)
      expect(filtered, contains('loyalty_module'));
      expect(filtered, contains('rewards_module'));
      
      // Should NOT contain roulette_module
      expect(filtered, isNot(contains('roulette_module')));
    });
  });
}

/// Helper function to create a mock RestaurantPlanUnified for testing
/// 
/// Note: This is a simplified mock. In real implementation, you would use
/// a proper mocking library or test fixtures.
dynamic createMockPlan(List<String> activeModuleCodes) {
  // Create a minimal mock that implements hasModule()
  return _MockRestaurantPlan(activeModuleCodes);
}

class _MockRestaurantPlan {
  final List<String> activeModules;
  
  _MockRestaurantPlan(this.activeModules);
  
  bool hasModule(dynamic moduleId) {
    // Handle both ModuleId enum and String
    String code;
    if (moduleId is String) {
      code = moduleId;
    } else {
      // Try to get code property safely
      try {
        code = (moduleId as dynamic).code as String;
      } catch (e) {
        // If we can't get the code, treat as not found
        return false;
      }
    }
    return activeModules.contains(code);
  }
}

/// Mock RestaurantPlanUnified with modules list for testing new implementation
class _MockRestaurantPlanWithModules {
  final List<String> activeModuleIds;
  
  _MockRestaurantPlanWithModules(this.activeModuleIds);
  
  // Create mock ModuleConfig objects for each enabled module
  List<dynamic> get modules {
    return activeModuleIds.map((id) => _MockModuleConfig(id, true)).toList();
  }
  
  bool hasModule(dynamic moduleId) {
    String code;
    if (moduleId is String) {
      code = moduleId;
    } else {
      try {
        code = (moduleId as dynamic).code as String;
      } catch (e) {
        return false;
      }
    }
    return activeModuleIds.contains(code);
  }
}

/// Mock ModuleConfig for testing
class _MockModuleConfig {
  final String id;
  final bool enabled;
  
  _MockModuleConfig(this.id, this.enabled);
}
