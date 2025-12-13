/// Test for Restaurant Template System
///
/// This test verifies that templates correctly define and apply default modules.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/superadmin/pages/restaurant_wizard/wizard_state.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_template.dart';

void main() {
  group('RestaurantTemplate Tests', () {
    test('RestaurantTemplates.all contains exactly 5 templates', () {
      expect(RestaurantTemplates.all.length, 5);
    });

    test('Pizzeria Classic template has correct modules', () {
      final template = RestaurantTemplates.all.firstWhere(
        (t) => t.id == 'pizzeria-classic',
      );
      
      expect(template.name, 'Pizzeria Classic');
      final moduleCodes = template.recommendedModules.map((m) => m.name).toList();
      expect(moduleCodes, contains('ordering'));
      expect(moduleCodes, contains('delivery'));
      expect(moduleCodes, contains('clickAndCollect'));
      expect(moduleCodes, contains('loyalty'));
      expect(moduleCodes, contains('roulette'));
      expect(moduleCodes, contains('promotions'));
      expect(moduleCodes, contains('kitchen_tablet'));
    });

    test('Fast Food Express template has correct modules', () {
      final template = RestaurantTemplates.all.firstWhere(
        (t) => t.id == 'fast-food-express',
      );
      
      expect(template.name, 'Fast Food Express');
      final moduleCodes = template.recommendedModules.map((m) => m.name).toList();
      expect(moduleCodes, contains('ordering'));
      expect(moduleCodes, contains('clickAndCollect'));
      expect(moduleCodes, contains('staff_tablet'));
      expect(moduleCodes, contains('promotions'));
    });

    test('Restaurant Premium template has correct modules', () {
      final template = RestaurantTemplates.all.firstWhere(
        (t) => t.id == 'restaurant-premium',
      );
      
      expect(template.name, 'Restaurant Premium');
      final moduleCodes = template.recommendedModules.map((m) => m.name).toList();
      expect(moduleCodes, contains('ordering'));
      expect(moduleCodes, contains('delivery'));
      expect(moduleCodes, contains('loyalty'));
      expect(moduleCodes, contains('promotions'));
      expect(moduleCodes, contains('campaigns'));
      expect(moduleCodes, contains('timeRecorder'));
      expect(moduleCodes, contains('reporting'));
      expect(moduleCodes, contains('theme'));
      expect(moduleCodes, contains('pagesBuilder'));
    });

    test('Blank template has no modules', () {
      final template = RestaurantTemplates.all.firstWhere(
        (t) => t.id == 'blank-template',
      );
      
      expect(template.name, 'Template Vide');
      expect(template.recommendedModules, isEmpty);
    });

    test('getTemplateById returns correct template', () {
      final template = RestaurantTemplates.getById('pizzeria-classic');
      expect(template, isNotNull);
      expect(template!.id, 'pizzeria-classic');
    });

    test('getTemplateById returns null for invalid ID', () {
      final template = RestaurantTemplates.getById('invalid-id');
      expect(template, isNull);
    });
  });

  group('Template Selection in Wizard', () {
    test('selectTemplate updates templateId and enables modules', () {
      final notifier = RestaurantWizardNotifier();
      final template = RestaurantTemplates.all.firstWhere(
        (t) => t.id == 'pizzeria-classic',
      );
      
      notifier.selectTemplate(template);
      
      expect(notifier.state.blueprint.templateId, 'pizzeria-classic');
      expect(notifier.state.enabledModuleIds.length, greaterThan(0));
      expect(notifier.state.enabledModuleIds, contains('ordering'));
      expect(notifier.state.enabledModuleIds, contains('delivery'));
      expect(notifier.state.enabledModuleIds, contains('clickAndCollect'));
    });

    test('selectTemplate with blank template sets no modules', () {
      final notifier = RestaurantWizardNotifier();
      final template = RestaurantTemplates.all.firstWhere(
        (t) => t.id == 'blank-template',
      );
      
      notifier.selectTemplate(template);
      
      expect(notifier.state.blueprint.templateId, 'blank-template');
      expect(notifier.state.enabledModuleIds, isEmpty);
    });

    test('switching templates updates module list', () {
      final notifier = RestaurantWizardNotifier();
      
      // First select Pizzeria Classic
      final pizzeriaTemplate = RestaurantTemplates.all.firstWhere(
        (t) => t.id == 'pizzeria-classic',
      );
      notifier.selectTemplate(pizzeriaTemplate);
      final pizzeriaModuleCount = notifier.state.enabledModuleIds.length;
      
      // Then switch to Fast Food Express
      final fastFoodTemplate = RestaurantTemplates.all.firstWhere(
        (t) => t.id == 'fast-food-express',
      );
      notifier.selectTemplate(fastFoodTemplate);
      final fastFoodModuleCount = notifier.state.enabledModuleIds.length;
      
      // Module counts should be different
      expect(pizzeriaModuleCount, isNot(equals(fastFoodModuleCount)));
      expect(notifier.state.blueprint.templateId, 'fast-food-express');
    });
  });
}
