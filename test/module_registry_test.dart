/// Test for Module Registry
///
/// This test verifies that all modules are properly registered and have correct metadata.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza_clean/white_label/core/module_id.dart';
import 'package:pizza_delizza_clean/white_label/core/module_registry.dart';
import 'package:pizza_delizza_clean/white_label/core/module_category.dart';

void main() {
  group('ModuleRegistry Tests', () {
    test('Registry contains exactly 18 modules', () {
      expect(ModuleRegistry.definitions.length, 18);
    });

    test('All ModuleId enum values are registered', () {
      for (final moduleId in ModuleId.values) {
        final definition = ModuleRegistry.definitions[moduleId];
        expect(definition, isNotNull, reason: 'Module ${moduleId.code} should be registered');
        expect(definition!.id, moduleId);
      }
    });

    test('All registered modules have valid names', () {
      for (final definition in ModuleRegistry.definitions.values) {
        expect(definition.name.isNotEmpty, true);
      }
    });

    test('All registered modules have valid descriptions', () {
      for (final definition in ModuleRegistry.definitions.values) {
        expect(definition.description.isNotEmpty, true);
      }
    });

    test('Core modules are registered correctly', () {
      final coreModules = ModuleRegistry.byCategory(ModuleCategory.core);
      expect(coreModules.isNotEmpty, true);
      
      final coreModuleIds = coreModules.map((m) => m.id).toList();
      expect(coreModuleIds, contains(ModuleId.ordering));
      expect(coreModuleIds, contains(ModuleId.delivery));
      expect(coreModuleIds, contains(ModuleId.clickAndCollect));
    });

    test('Payment modules are registered correctly', () {
      final paymentModules = ModuleRegistry.byCategory(ModuleCategory.payment);
      expect(paymentModules.isNotEmpty, true);
      
      final paymentModuleIds = paymentModules.map((m) => m.id).toList();
      expect(paymentModuleIds, contains(ModuleId.payments));
      expect(paymentModuleIds, contains(ModuleId.paymentTerminal));
      expect(paymentModuleIds, contains(ModuleId.wallet));
    });

    test('Marketing modules are registered correctly', () {
      final marketingModules = ModuleRegistry.byCategory(ModuleCategory.marketing);
      expect(marketingModules.isNotEmpty, true);
      
      final marketingModuleIds = marketingModules.map((m) => m.id).toList();
      expect(marketingModuleIds, contains(ModuleId.loyalty));
      expect(marketingModuleIds, contains(ModuleId.roulette));
      expect(marketingModuleIds, contains(ModuleId.promotions));
      expect(marketingModuleIds, contains(ModuleId.newsletter));
      expect(marketingModuleIds, contains(ModuleId.campaigns));
    });

    test('Operations modules are registered correctly', () {
      final operationsModules = ModuleRegistry.byCategory(ModuleCategory.operations);
      expect(operationsModules.isNotEmpty, true);
      
      final operationsModuleIds = operationsModules.map((m) => m.id).toList();
      expect(operationsModuleIds, contains(ModuleId.kitchen_tablet));
      expect(operationsModuleIds, contains(ModuleId.staff_tablet));
      expect(operationsModuleIds, contains(ModuleId.timeRecorder));
    });

    test('Appearance modules are registered correctly', () {
      final appearanceModules = ModuleRegistry.byCategory(ModuleCategory.appearance);
      expect(appearanceModules.isNotEmpty, true);
      
      final appearanceModuleIds = appearanceModules.map((m) => m.id).toList();
      expect(appearanceModuleIds, contains(ModuleId.theme));
      expect(appearanceModuleIds, contains(ModuleId.pagesBuilder));
    });

    test('Analytics modules are registered correctly', () {
      final analyticsModules = ModuleRegistry.byCategory(ModuleCategory.analytics);
      expect(analyticsModules.isNotEmpty, true);
      
      final analyticsModuleIds = analyticsModules.map((m) => m.id).toList();
      expect(analyticsModuleIds, contains(ModuleId.reporting));
      expect(analyticsModuleIds, contains(ModuleId.exports));
    });

    test('Module dependencies are correctly defined', () {
      // Delivery depends on ordering
      final delivery = ModuleRegistry.of(ModuleId.delivery);
      expect(delivery.dependencies, contains(ModuleId.ordering));
      
      // Click and collect depends on ordering
      final clickAndCollect = ModuleRegistry.of(ModuleId.clickAndCollect);
      expect(clickAndCollect.dependencies, contains(ModuleId.ordering));
      
      // Kitchen tablet depends on ordering
      final kitchenTablet = ModuleRegistry.of(ModuleId.kitchen_tablet);
      expect(kitchenTablet.dependencies, contains(ModuleId.ordering));
      
      // Staff tablet depends on ordering
      final staffTablet = ModuleRegistry.of(ModuleId.staff_tablet);
      expect(staffTablet.dependencies, contains(ModuleId.ordering));
      
      // Payment terminal depends on payments
      final paymentTerminal = ModuleRegistry.of(ModuleId.paymentTerminal);
      expect(paymentTerminal.dependencies, contains(ModuleId.payments));
      
      // Wallet depends on payments
      final wallet = ModuleRegistry.of(ModuleId.wallet);
      expect(wallet.dependencies, contains(ModuleId.payments));
      
      // Exports depends on reporting
      final exports = ModuleRegistry.of(ModuleId.exports);
      expect(exports.dependencies, contains(ModuleId.reporting));
    });

    test('Premium modules are correctly marked', () {
      final premiumModules = ModuleRegistry.premiumModules;
      final premiumModuleIds = premiumModules.map((m) => m.id).toList();
      
      // Check some expected premium modules
      expect(premiumModuleIds, contains(ModuleId.roulette));
      expect(premiumModuleIds, contains(ModuleId.newsletter));
      expect(premiumModuleIds, contains(ModuleId.campaigns));
      expect(premiumModuleIds, contains(ModuleId.paymentTerminal));
      expect(premiumModuleIds, contains(ModuleId.wallet));
      expect(premiumModuleIds, contains(ModuleId.pagesBuilder));
      expect(premiumModuleIds, contains(ModuleId.kitchen_tablet));
      expect(premiumModuleIds, contains(ModuleId.staff_tablet));
      expect(premiumModuleIds, contains(ModuleId.timeRecorder));
      expect(premiumModuleIds, contains(ModuleId.exports));
    });

    test('Free modules are correctly marked', () {
      final freeModules = ModuleRegistry.freeModules;
      final freeModuleIds = freeModules.map((m) => m.id).toList();
      
      // Check some expected free modules
      expect(freeModuleIds, contains(ModuleId.ordering));
      expect(freeModuleIds, contains(ModuleId.delivery));
      expect(freeModuleIds, contains(ModuleId.clickAndCollect));
      expect(freeModuleIds, contains(ModuleId.payments));
      expect(freeModuleIds, contains(ModuleId.loyalty));
      expect(freeModuleIds, contains(ModuleId.promotions));
      expect(freeModuleIds, contains(ModuleId.theme));
      expect(freeModuleIds, contains(ModuleId.reporting));
    });

    test('ModuleRegistry.of() returns correct definition', () {
      final ordering = ModuleRegistry.of(ModuleId.ordering);
      expect(ordering.id, ModuleId.ordering);
      expect(ordering.name, 'Commandes en ligne');
      expect(ordering.category, ModuleCategory.core);
    });

    test('Campaigns module is properly registered', () {
      final campaigns = ModuleRegistry.of(ModuleId.campaigns);
      expect(campaigns.id, ModuleId.campaigns);
      expect(campaigns.name, 'Campagnes');
      expect(campaigns.category, ModuleCategory.marketing);
      expect(campaigns.isPremium, true);
    });
  });

  group('ModuleId Extension Tests', () {
    test('ModuleId.code returns correct values', () {
      expect(ModuleId.ordering.code, 'ordering');
      expect(ModuleId.delivery.code, 'delivery');
      expect(ModuleId.clickAndCollect.code, 'click_and_collect');
      expect(ModuleId.campaigns.code, 'campaigns');
    });

    test('ModuleId.label returns correct values', () {
      expect(ModuleId.ordering.label, 'Commandes en ligne');
      expect(ModuleId.delivery.label, 'Livraison');
      expect(ModuleId.clickAndCollect.label, 'Click & Collect');
      expect(ModuleId.campaigns.label, 'Campagnes');
    });

    test('ModuleId.category returns correct values', () {
      expect(ModuleId.ordering.category, ModuleCategory.core);
      expect(ModuleId.payments.category, ModuleCategory.payment);
      expect(ModuleId.loyalty.category, ModuleCategory.marketing);
      expect(ModuleId.kitchen_tablet.category, ModuleCategory.operations);
      expect(ModuleId.theme.category, ModuleCategory.appearance);
      expect(ModuleId.reporting.category, ModuleCategory.analytics);
    });
  });
}
