/// Integration test for kitchen_tablet module
///
/// This test verifies the complete integration of the kitchen_tablet module
/// into the white-label architecture.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza_clean/white_label/core/module_id.dart';
import 'package:pizza_delizza_clean/white_label/core/module_registry.dart';
import 'package:pizza_delizza_clean/white_label/core/module_category.dart';
import 'package:pizza_delizza_clean/white_label/core/module_matrix.dart';
import 'package:pizza_delizza_clean/white_label/core/module_runtime_mapping.dart';
import 'package:pizza_delizza_clean/white_label/runtime/module_route_resolver.dart';
import 'package:pizza_delizza_clean/white_label/runtime/navbar_module_adapter.dart';
import 'package:pizza_delizza_clean/white_label/restaurant/restaurant_plan_unified.dart';

void main() {
  group('Kitchen Tablet Module Integration Tests', () {
    
    // Task 1: Module exists in ModuleRegistry
    test('kitchenTablet is registered in ModuleRegistry', () {
      final definition = ModuleRegistry.definitions[ModuleId.kitchen_tablet];
      
      expect(definition, isNotNull);
      expect(definition!.id, ModuleId.kitchen_tablet);
      expect(definition.name, 'Tablette cuisine');
      expect(definition.category, ModuleCategory.operations);
      expect(definition.isPremium, true);
      expect(definition.requiresConfiguration, true);
      expect(definition.dependencies, contains(ModuleId.ordering));
    });
    
    // Task 2: Module exists in module_matrix
    test('kitchen_tablet is in module_matrix with correct metadata', () {
      final meta = moduleMatrix['kitchen_tablet'];
      
      expect(meta, isNotNull);
      expect(meta!.id, 'kitchen_tablet');
      expect(meta.label, 'Tablette cuisine');
      expect(meta.category, ModuleCategory.operations);
      expect(meta.status, ModuleStatus.implemented);
      expect(meta.hasPage, true);
      expect(meta.hasBuilderBlock, false);
      expect(meta.premium, true);
      expect(meta.defaultRoute, '/kitchen');
      expect(meta.tags, contains('kitchen'));
      expect(meta.tags, contains('tablet'));
      expect(meta.tags, contains('operations'));
    });
    
    // Task 3: ModuleRuntimeMapping returns correct values
    test('ModuleRuntimeMapping provides correct kitchen_tablet data', () {
      // Route
      final route = ModuleRuntimeMapping.getRuntimeRoute(ModuleId.kitchen_tablet);
      expect(route, '/kitchen');
      
      // Has page
      final hasPage = ModuleRuntimeMapping.getRuntimePage(ModuleId.kitchen_tablet);
      expect(hasPage, true);
      
      // No builder block
      final hasBlock = ModuleRuntimeMapping.hasBuilderBlock(ModuleId.kitchen_tablet);
      expect(hasBlock, false);
      
      // Is implemented
      final isImplemented = ModuleRuntimeMapping.isImplemented(ModuleId.kitchen_tablet);
      expect(isImplemented, true);
      
      // Is premium
      final isPremium = ModuleRuntimeMapping.isPremium(ModuleId.kitchen_tablet);
      expect(isPremium, true);
      
      // Category
      final category = ModuleRuntimeMapping.getCategory(ModuleId.kitchen_tablet);
      expect(category, ModuleCategory.operations);
    });
    
    // Task 4: Route resolver maps /kitchen to kitchenTablet
    test('ModuleRouteResolver resolves /kitchen to kitchenTablet', () {
      final moduleId = ModuleRouteResolver.resolve('/kitchen');
      
      expect(moduleId, ModuleId.kitchen_tablet);
      expect(ModuleRouteResolver.belongsToModule('/kitchen', ModuleId.kitchen_tablet), true);
      expect(ModuleRouteResolver.isValidRoute('/kitchen'), true);
      expect(ModuleRouteResolver.isPhantomRoute('/kitchen'), false);
    });
    
    // Task 5: Navbar filtering ignores /kitchen
    test('NavbarModuleAdapter filters /kitchen from navbar when module inactive', () {
      // Create a plan without kitchen_tablet
      final plan = RestaurantPlanUnified(
        restaurantId: 'test',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: const ['ordering'], // No kitchen_tablet
      );
      
      // Create nav items including kitchen
      final items = [
        const NavItem(route: '/home', label: 'Home'),
        const NavItem(route: '/menu', label: 'Menu'),
        const NavItem(route: '/kitchen', label: 'Kitchen'),
        const NavItem(route: '/cart', label: 'Cart'),
      ];
      
      // Filter items
      final result = NavbarModuleAdapter.filterNavItemsByModules(items, plan);
      
      // Kitchen should be removed
      expect(result.items.length, 3);
      expect(result.removedCount, 1);
      expect(result.removedRoutes, contains('/kitchen'));
      expect(result.disabledModules, contains('kitchen_tablet'));
      
      // Verify kitchen is not in filtered items
      final hasKitchen = result.items.any((item) => item.route == '/kitchen');
      expect(hasKitchen, false);
    });
    
    test('NavbarModuleAdapter keeps /kitchen when module is active', () {
      // Create a plan WITH kitchen_tablet
      final plan = RestaurantPlanUnified(
        restaurantId: 'test',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: const ['ordering', 'kitchen_tablet'],
      );
      
      // Create nav items including kitchen
      final items = [
        const NavItem(route: '/home', label: 'Home'),
        const NavItem(route: '/kitchen', label: 'Kitchen'),
      ];
      
      // Filter items
      final result = NavbarModuleAdapter.filterNavItemsByModules(items, plan);
      
      // Kitchen should be kept (even though it shouldn't be in navbar normally)
      expect(result.items.length, 2);
      expect(result.removedCount, 0);
      
      // Verify kitchen is in filtered items
      final hasKitchen = result.items.any((item) => item.route == '/kitchen');
      expect(hasKitchen, true);
    });
    
    // Task 6: RestaurantPlanUnified integration
    test('RestaurantPlanUnified supports kitchen_tablet module', () {
      // Create a plan with kitchen_tablet
      final plan = RestaurantPlanUnified(
        restaurantId: 'test',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: const ['ordering', 'kitchen_tablet'],
      );
      
      // Check module is active
      expect(plan.activeModules, contains('kitchen_tablet'));
      expect(plan.hasModule(ModuleId.kitchen_tablet), true);
    });
    
    test('RestaurantPlanUnified hasModule returns false when module inactive', () {
      // Create a plan without kitchen_tablet
      final plan = RestaurantPlanUnified(
        restaurantId: 'test',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: const ['ordering'],
      );
      
      // Check module is not active
      expect(plan.hasModule(ModuleId.kitchen_tablet), false);
    });
    
    // Integration: All routes map correctly
    test('All module routes are correctly mapped', () {
      final allRoutes = ModuleRouteResolver.getAllModuleRoutes();
      
      // Kitchen should be in the map
      expect(allRoutes['/kitchen'], ModuleId.kitchen_tablet);
    });
    
    // Integration: Module exists in all systems
    test('kitchen_tablet module is consistently defined across systems', () {
      // 1. In ModuleId enum
      expect(ModuleId.values, contains(ModuleId.kitchen_tablet));
      
      // 2. In ModuleRegistry
      final registryDef = ModuleRegistry.definitions[ModuleId.kitchen_tablet];
      expect(registryDef, isNotNull);
      
      // 3. In module_matrix
      final matrixMeta = moduleMatrix['kitchen_tablet'];
      expect(matrixMeta, isNotNull);
      
      // 4. Has runtime mapping
      final route = ModuleRuntimeMapping.getRuntimeRoute(ModuleId.kitchen_tablet);
      expect(route, isNotNull);
      
      // 5. Route resolves correctly
      final resolvedModule = ModuleRouteResolver.resolve('/kitchen');
      expect(resolvedModule, ModuleId.kitchen_tablet);
    });
    
    // Completeness: Verify no phantom routes
    test('kitchen route is not a phantom route', () {
      expect(ModuleRouteResolver.isPhantomRoute('/kitchen'), false);
      
      final result = ModuleRouteResolver.resolveDetailed('/kitchen');
      expect(result.isResolved, true);
      expect(result.requiresModule, true);
      expect(result.moduleId, ModuleId.kitchen_tablet);
    });
  });
}
