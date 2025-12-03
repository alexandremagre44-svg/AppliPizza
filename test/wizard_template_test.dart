/// Test for Restaurant Template System
///
/// This test verifies that templates correctly define and apply default modules.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza_clean/superadmin/pages/restaurant_wizard/wizard_step_template.dart';
import 'package:pizza_delizza_clean/superadmin/pages/restaurant_wizard/wizard_state.dart';
import 'package:pizza_delizza_clean/white_label/core/module_id.dart';

void main() {
  group('RestaurantTemplate Tests', () {
    test('availableTemplates contains exactly 4 templates', () {
      expect(availableTemplates.length, 4);
    });

    test('Pizzeria Classic template has correct modules', () {
      final template = availableTemplates.firstWhere(
        (t) => t.id == 'pizzeria-classic',
      );
      
      expect(template.name, 'Pizzeria Classic');
      expect(template.modules, contains(ModuleId.ordering));
      expect(template.modules, contains(ModuleId.delivery));
      expect(template.modules, contains(ModuleId.clickAndCollect));
      expect(template.modules, contains(ModuleId.loyalty));
      expect(template.modules, contains(ModuleId.roulette));
      expect(template.modules, contains(ModuleId.promotions));
      expect(template.modules, contains(ModuleId.kitchen_tablet));
    });

    test('Fast Food Express template has correct modules', () {
      final template = availableTemplates.firstWhere(
        (t) => t.id == 'fast-food-express',
      );
      
      expect(template.name, 'Fast Food Express');
      expect(template.modules, contains(ModuleId.ordering));
      expect(template.modules, contains(ModuleId.clickAndCollect));
      expect(template.modules, contains(ModuleId.staff_tablet));
      expect(template.modules, contains(ModuleId.promotions));
    });

    test('Restaurant Premium template has correct modules', () {
      final template = availableTemplates.firstWhere(
        (t) => t.id == 'restaurant-premium',
      );
      
      expect(template.name, 'Restaurant Premium');
      expect(template.modules, contains(ModuleId.ordering));
      expect(template.modules, contains(ModuleId.delivery));
      expect(template.modules, contains(ModuleId.clickAndCollect));
      expect(template.modules, contains(ModuleId.loyalty));
      expect(template.modules, contains(ModuleId.promotions));
      expect(template.modules, contains(ModuleId.campaigns));
      expect(template.modules, contains(ModuleId.timeRecorder));
      expect(template.modules, contains(ModuleId.reporting));
      expect(template.modules, contains(ModuleId.theme));
      expect(template.modules, contains(ModuleId.pagesBuilder));
    });

    test('Blank template has no modules', () {
      final template = availableTemplates.firstWhere(
        (t) => t.id == 'blank-template',
      );
      
      expect(template.name, 'Template Vide');
      expect(template.modules, isEmpty);
    });

    test('getTemplateById returns correct template', () {
      final template = getTemplateById('pizzeria-classic');
      expect(template, isNotNull);
      expect(template!.id, 'pizzeria-classic');
    });

    test('getTemplateById returns null for invalid ID', () {
      final template = getTemplateById('invalid-id');
      expect(template, isNull);
    });
  });

  group('Template Selection in Wizard', () {
    test('selectTemplate updates templateId and enables modules', () {
      final notifier = RestaurantWizardNotifier();
      final template = availableTemplates.firstWhere(
        (t) => t.id == 'pizzeria-classic',
      );
      
      notifier.selectTemplate(template);
      
      expect(notifier.state.blueprint.templateId, 'pizzeria-classic');
      expect(notifier.state.enabledModuleIds.length, greaterThan(0));
      expect(notifier.state.enabledModuleIds, contains(ModuleId.ordering));
      expect(notifier.state.enabledModuleIds, contains(ModuleId.delivery));
    });

    test('selectTemplate with blank template sets no modules', () {
      final notifier = RestaurantWizardNotifier();
      final template = availableTemplates.firstWhere(
        (t) => t.id == 'blank-template',
      );
      
      notifier.selectTemplate(template);
      
      expect(notifier.state.blueprint.templateId, 'blank-template');
      expect(notifier.state.enabledModuleIds, isEmpty);
    });

    test('switching templates updates module list', () {
      final notifier = RestaurantWizardNotifier();
      
      // First select Pizzeria Classic
      final pizzeriaTemplate = availableTemplates.firstWhere(
        (t) => t.id == 'pizzeria-classic',
      );
      notifier.selectTemplate(pizzeriaTemplate);
      final pizzeriaModuleCount = notifier.state.enabledModuleIds.length;
      
      // Then switch to Fast Food Express
      final fastFoodTemplate = availableTemplates.firstWhere(
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
