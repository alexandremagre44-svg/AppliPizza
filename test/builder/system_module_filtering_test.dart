// test/builder/system_module_filtering_test.dart
// Tests for system module filtering - ensures system modules
// (POS, cart, ordering, payments) never appear in Builder

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/builder/models/builder_block.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/core/module_category.dart';

void main() {
  group('System Module Filtering', () {
    test('system modules are correctly identified', () {
      // Verify that system modules are categorized correctly
      // According to WL Doctrine: pos, ordering, cart, payments, kitchen_tablet, staff_tablet
      expect(ModuleId.pos.isSystemModule, true);
      expect(ModuleId.ordering.isSystemModule, true);
      expect(ModuleId.payments.isSystemModule, true);
      expect(ModuleId.paymentTerminal.isSystemModule, true);
      expect(ModuleId.kitchen_tablet.isSystemModule, true);
      expect(ModuleId.staff_tablet.isSystemModule, true);
    });

    test('business modules are NOT system modules', () {
      // Verify that business modules are NOT system modules
      // According to WL Doctrine: delivery, loyalty, promotions, wallet, etc.
      expect(ModuleId.delivery.isSystemModule, false);
      expect(ModuleId.clickAndCollect.isSystemModule, false);
      expect(ModuleId.loyalty.isSystemModule, false);
      expect(ModuleId.roulette.isSystemModule, false);
      expect(ModuleId.promotions.isSystemModule, false);
      expect(ModuleId.newsletter.isSystemModule, false);
      expect(ModuleId.wallet.isSystemModule, false); // wallet is BUSINESS per doctrine
    });

    test('visual modules are NOT system modules', () {
      // Verify that visual modules are NOT system modules
      expect(ModuleId.theme.isSystemModule, false);
      expect(ModuleId.pagesBuilder.isSystemModule, false);
    });

    test('system modules NEVER appear in getFilteredModules', () {
      // Create a plan with ALL modules enabled (including system modules)
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: [
          'pos',           // SYSTEM MODULE
          'ordering',      // SYSTEM MODULE
          'payments',      // SYSTEM MODULE
          'delivery',      // Business module
          'loyalty',       // Business module
          'roulette',      // Business module
        ],
      );

      // Get filtered modules
      final filteredModules = SystemBlock.getFilteredModules(plan);

      // CRITICAL: System modules should NEVER appear in Builder
      // Even though they are enabled in the plan
      expect(filteredModules.contains('cart_module'), false,
          reason: 'cart_module maps to ordering (system module)');
      
      // Business modules SHOULD appear if enabled
      // Note: delivery_module is currently a system page (not in builder_modules mapping)
      // but delivery is a business module, not a system module
      expect(filteredModules.contains('delivery_module'), false,
          reason: 'delivery_module is currently implemented as a system page');
      expect(filteredModules.contains('loyalty_module'), true,
          reason: 'loyalty is a business module');
      expect(filteredModules.contains('roulette_module'), true,
          reason: 'roulette is a business module');
    });

    test('POS enabled but not in Builder', () {
      // Create a plan with POS enabled
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['pos', 'ordering'], // POS + ordering enabled
      );

      // Get filtered modules
      final filteredModules = SystemBlock.getFilteredModules(plan);

      // POS-related modules should NOT appear in Builder
      // (POS doesn't map to any builder module, but we verify it doesn't leak)
      
      // Always-visible modules should still be there
      expect(filteredModules.contains('menu_catalog'), true);
      expect(filteredModules.contains('profile_module'), true);
      
      // cart_module should NOT appear (maps to ordering, which is system)
      expect(filteredModules.contains('cart_module'), false);
    });

    test('ModuleCategory.system is correctly assigned', () {
      // Verify category assignment per WL Doctrine
      expect(ModuleId.pos.category, ModuleCategory.system);
      expect(ModuleId.ordering.category, ModuleCategory.system);
      expect(ModuleId.payments.category, ModuleCategory.system);
      expect(ModuleId.paymentTerminal.category, ModuleCategory.system);
      expect(ModuleId.kitchen_tablet.category, ModuleCategory.system);
      expect(ModuleId.staff_tablet.category, ModuleCategory.system);
    });

    test('ModuleCategory.business is correctly assigned', () {
      // Verify business category assignment per WL Doctrine
      expect(ModuleId.delivery.category, ModuleCategory.business);
      expect(ModuleId.clickAndCollect.category, ModuleCategory.business);
      expect(ModuleId.loyalty.category, ModuleCategory.business);
      expect(ModuleId.roulette.category, ModuleCategory.business);
      expect(ModuleId.promotions.category, ModuleCategory.business);
      expect(ModuleId.wallet.category, ModuleCategory.business); // wallet is BUSINESS per doctrine
    });

    test('ModuleCategory.visual is correctly assigned', () {
      // Verify visual category assignment
      expect(ModuleId.theme.category, ModuleCategory.visual);
      expect(ModuleId.pagesBuilder.category, ModuleCategory.visual);
    });

    test('system module OFF does not affect Builder', () {
      // Create a plan with POS and ordering disabled
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['loyalty', 'roulette'], // NO system modules
      );

      // Get filtered modules
      final filteredModules = SystemBlock.getFilteredModules(plan);

      // System modules should NOT appear (they're disabled)
      expect(filteredModules.contains('cart_module'), false);
      
      // Business modules should appear
      expect(filteredModules.contains('loyalty_module'), true);
      expect(filteredModules.contains('roulette_module'), true);
      
      // Always-visible modules should still be there
      expect(filteredModules.contains('menu_catalog'), true);
      expect(filteredModules.contains('profile_module'), true);
    });

    test('business modules are filterable by plan', () {
      // Create a plan with only loyalty (no roulette)
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['loyalty'], // Only loyalty
      );

      // Get filtered modules
      final filteredModules = SystemBlock.getFilteredModules(plan);

      // Loyalty should appear
      expect(filteredModules.contains('loyalty_module'), true);
      
      // Roulette should NOT appear (disabled)
      expect(filteredModules.contains('roulette_module'), false);
    });

    test('payment core modules are system modules', () {
      // Verify payment CORE modules are system modules per WL Doctrine
      expect(ModuleId.payments.isSystemModule, true);
      expect(ModuleId.paymentTerminal.isSystemModule, true);
      
      // But wallet is a BUSINESS module per WL Doctrine
      expect(ModuleId.wallet.isSystemModule, false);
      
      // Payment CORE modules should never appear in Builder even if enabled
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['payments', 'payment_terminal', 'wallet'],
      );

      final filteredModules = SystemBlock.getFilteredModules(plan);
      
      // Payment core modules should not have builder equivalents
      // and should not appear in filtered modules
      expect(filteredModules.any((m) => m.contains('payment') && m != 'wallet'), false);
      
      // Wallet could appear in Builder if it has a builder module mapping
      // (wallet is business, not system)
    });
  });
}
