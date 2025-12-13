/// Test for Restaurant Wizard validation logic
///
/// This test verifies that the wizard validation system works correctly
/// for all steps and that the isReadyForCreation check is comprehensive.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/superadmin/pages/restaurant_wizard/wizard_state.dart';
import 'package:pizza_delizza/superadmin/models/restaurant_blueprint.dart';

void main() {
  group('RestaurantWizardState Validation Tests', () {
    test('isIdentityValid returns false when name is empty', () {
      final state = RestaurantWizardState(
        blueprint: RestaurantBlueprintLight.empty(),
      );
      expect(state.isIdentityValid, false);
    });

    test('isIdentityValid returns false when slug is empty', () {
      final state = RestaurantWizardState(
        blueprint: RestaurantBlueprintLight.empty().copyWith(
          name: 'Test Restaurant',
        ),
      );
      expect(state.isIdentityValid, false);
    });

    test('isIdentityValid returns true when name and slug are set', () {
      final state = RestaurantWizardState(
        blueprint: RestaurantBlueprintLight.empty().copyWith(
          name: 'Test Restaurant',
          slug: 'test-restaurant',
        ),
      );
      expect(state.isIdentityValid, true);
    });

    test('isBrandValid returns false when brand name is empty', () {
      final state = RestaurantWizardState(
        blueprint: RestaurantBlueprintLight.empty(),
      );
      expect(state.isBrandValid, false);
    });

    test('isBrandValid returns true when brand name is set', () {
      final state = RestaurantWizardState(
        blueprint: RestaurantBlueprintLight.empty().copyWith(
          brand: const RestaurantBrandLight(brandName: 'Test Brand'),
        ),
      );
      expect(state.isBrandValid, true);
    });

    test('isTemplateValid is always true', () {
      final state = RestaurantWizardState(
        blueprint: RestaurantBlueprintLight.empty(),
      );
      expect(state.isTemplateValid, true);
    });

    test('isModulesValid returns true with valid module dependencies', () {
      final state = RestaurantWizardState(
        blueprint: RestaurantBlueprintLight.empty(),
        enabledModuleIds: [
          'ordering',
          'delivery', // depends on ordering
        ],
      );
      expect(state.isModulesValid, true);
    });

    test('isModulesValid returns false with missing dependencies', () {
      final state = RestaurantWizardState(
        blueprint: RestaurantBlueprintLight.empty(),
        enabledModuleIds: [
          'delivery', // depends on ordering, which is not enabled
        ],
      );
      expect(state.isModulesValid, false);
    });

    test('isReadyForCreation returns false when identity is invalid', () {
      final state = RestaurantWizardState(
        blueprint: RestaurantBlueprintLight.empty(),
      );
      expect(state.isReadyForCreation, false);
    });

    test('isReadyForCreation returns true when all validations pass', () {
      final state = RestaurantWizardState(
        blueprint: RestaurantBlueprintLight.empty().copyWith(
          name: 'Test Restaurant',
          slug: 'test-restaurant',
          brand: const RestaurantBrandLight(brandName: 'Test Brand'),
        ),
        enabledModuleIds: [
          'ordering',
          'payments',
        ],
      );
      expect(state.isReadyForCreation, true);
    });

    test('validateModuleDependencies correctly identifies missing dependencies', () {
      final modules = ['delivery']; // missing ordering dependency
      final missingDeps = getMissingDependencies(modules);
      expect(missingDeps, contains('ordering'));
    });

    test('validateModuleDependencies passes when all dependencies are present', () {
      final modules = ['ordering', 'delivery'];
      final isValid = validateModuleDependencies(modules);
      expect(isValid, true);
    });
  });

  group('RestaurantWizardNotifier Tests', () {
    test('updateIdentity updates name and slug correctly', () {
      final notifier = RestaurantWizardNotifier();
      notifier.updateIdentity(name: 'New Name', slug: 'new-slug');
      
      expect(notifier.state.blueprint.name, 'New Name');
      expect(notifier.state.blueprint.slug, 'new-slug');
    });

    test('updateBrand updates brand properties correctly', () {
      final notifier = RestaurantWizardNotifier();
      notifier.updateBrand(
        brandName: 'Brand Name',
        primaryColor: '#FF0000',
      );
      
      expect(notifier.state.blueprint.brand.brandName, 'Brand Name');
      expect(notifier.state.blueprint.brand.primaryColor, '#FF0000');
    });

    test('toggleModule adds module when enabled', () {
      final notifier = RestaurantWizardNotifier();
      notifier.toggleModule('ordering', true);
      
      expect(notifier.state.enabledModuleIds, contains('ordering'));
    });

    test('toggleModule removes module when disabled', () {
      final notifier = RestaurantWizardNotifier();
      notifier.toggleModule('ordering', true);
      notifier.toggleModule('ordering', false);
      
      expect(notifier.state.enabledModuleIds, isNot(contains('ordering')));
    });

    test('toggleModule adds dependencies automatically', () {
      final notifier = RestaurantWizardNotifier();
      notifier.toggleModule('delivery', true);
      
      // delivery depends on ordering, so ordering should be added
      expect(notifier.state.enabledModuleIds, contains('ordering'));
      expect(notifier.state.enabledModuleIds, contains('delivery'));
    });

    test('toggleModule removes dependent modules when disabling', () {
      final notifier = RestaurantWizardNotifier();
      notifier.toggleModule('delivery', true);
      notifier.toggleModule('ordering', false);
      
      // disabling ordering should also disable delivery
      expect(notifier.state.enabledModuleIds, isNot(contains('ordering')));
      expect(notifier.state.enabledModuleIds, isNot(contains('delivery')));
    });
  });
}
