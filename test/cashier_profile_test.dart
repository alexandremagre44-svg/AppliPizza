/// Test for CashierProfile enum and wizard integration
///
/// This test verifies that CashierProfile works correctly
/// with templates and the wizard flow.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/restaurant/cashier_profile.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_template.dart';
import 'package:pizza_delizza/superadmin/pages/restaurant_wizard/wizard_state.dart';

void main() {
  group('CashierProfile Enum Tests', () {
    test('CashierProfile has correct values', () {
      expect(CashierProfile.values.length, 5);
      expect(CashierProfile.generic, isNotNull);
      expect(CashierProfile.pizzeria, isNotNull);
      expect(CashierProfile.fastFood, isNotNull);
      expect(CashierProfile.restaurant, isNotNull);
      expect(CashierProfile.sushi, isNotNull);
    });

    test('CashierProfile.value returns correct string', () {
      expect(CashierProfile.generic.value, 'generic');
      expect(CashierProfile.pizzeria.value, 'pizzeria');
      expect(CashierProfile.fastFood.value, 'fastFood');
      expect(CashierProfile.restaurant.value, 'restaurant');
      expect(CashierProfile.sushi.value, 'sushi');
    });

    test('CashierProfile.displayName returns correct label', () {
      expect(CashierProfile.generic.displayName, 'Générique');
      expect(CashierProfile.pizzeria.displayName, 'Pizzeria');
      expect(CashierProfile.fastFood.displayName, 'Fast-food');
      expect(CashierProfile.restaurant.displayName, 'Restaurant');
      expect(CashierProfile.sushi.displayName, 'Sushi');
    });

    test('CashierProfile.description is not empty', () {
      for (final profile in CashierProfile.values) {
        expect(profile.description, isNotEmpty);
      }
    });

    test('CashierProfile.iconName is not empty', () {
      for (final profile in CashierProfile.values) {
        expect(profile.iconName, isNotEmpty);
      }
    });

    test('CashierProfileExtension.fromString parses correctly', () {
      expect(
        CashierProfileExtension.fromString('generic'),
        CashierProfile.generic,
      );
      expect(
        CashierProfileExtension.fromString('pizzeria'),
        CashierProfile.pizzeria,
      );
      expect(
        CashierProfileExtension.fromString('fastfood'),
        CashierProfile.fastFood,
      );
      expect(
        CashierProfileExtension.fromString('fast_food'),
        CashierProfile.fastFood,
      );
      expect(
        CashierProfileExtension.fromString('restaurant'),
        CashierProfile.restaurant,
      );
      expect(
        CashierProfileExtension.fromString('sushi'),
        CashierProfile.sushi,
      );
    });

    test('CashierProfileExtension.fromString handles null and invalid values', () {
      expect(
        CashierProfileExtension.fromString(null),
        CashierProfile.generic,
      );
      expect(
        CashierProfileExtension.fromString('invalid'),
        CashierProfile.generic,
      );
      expect(
        CashierProfileExtension.fromString(''),
        CashierProfile.generic,
      );
    });
  });

  group('Wizard Template Selection with CashierProfile', () {
    test('Pizzeria template sets pizzeria cashierProfile', () {
      final notifier = RestaurantWizardNotifier();
      final template = RestaurantTemplates.pizzeriaClassic;
      
      notifier.selectTemplate(template);
      
      expect(notifier.state.blueprint.templateId, 'pizzeria-classic');
      expect(notifier.state.blueprint.cashierProfile, CashierProfile.pizzeria);
    });

    test('Fast Food template sets fastFood cashierProfile', () {
      final notifier = RestaurantWizardNotifier();
      final template = RestaurantTemplates.fastFoodExpress;
      
      notifier.selectTemplate(template);
      
      expect(notifier.state.blueprint.templateId, 'fast-food-express');
      expect(notifier.state.blueprint.cashierProfile, CashierProfile.fastFood);
    });

    test('Restaurant Premium template sets restaurant cashierProfile', () {
      final notifier = RestaurantWizardNotifier();
      final template = RestaurantTemplates.restaurantPremium;
      
      notifier.selectTemplate(template);
      
      expect(notifier.state.blueprint.templateId, 'restaurant-premium');
      expect(notifier.state.blueprint.cashierProfile, CashierProfile.restaurant);
    });

    test('Sushi Bar template sets sushi cashierProfile', () {
      final notifier = RestaurantWizardNotifier();
      final template = RestaurantTemplates.sushiBar;
      
      notifier.selectTemplate(template);
      
      expect(notifier.state.blueprint.templateId, 'sushi-bar');
      expect(notifier.state.blueprint.cashierProfile, CashierProfile.sushi);
    });

    test('Blank template keeps generic cashierProfile', () {
      final notifier = RestaurantWizardNotifier();
      final template = RestaurantTemplates.blank;
      
      notifier.selectTemplate(template);
      
      expect(notifier.state.blueprint.templateId, 'blank-template');
      expect(notifier.state.blueprint.cashierProfile, CashierProfile.generic);
    });

    test('Manual cashierProfile update works', () {
      final notifier = RestaurantWizardNotifier();
      
      // Start with blank template
      notifier.selectTemplate(RestaurantTemplates.blank);
      expect(notifier.state.blueprint.cashierProfile, CashierProfile.generic);
      
      // Update manually
      notifier.updateCashierProfile(CashierProfile.pizzeria);
      expect(notifier.state.blueprint.cashierProfile, CashierProfile.pizzeria);
      
      // Update again
      notifier.updateCashierProfile(CashierProfile.sushi);
      expect(notifier.state.blueprint.cashierProfile, CashierProfile.sushi);
    });

    test('Switching templates updates cashierProfile correctly', () {
      final notifier = RestaurantWizardNotifier();
      
      // Select pizzeria template
      notifier.selectTemplate(RestaurantTemplates.pizzeriaClassic);
      expect(notifier.state.blueprint.cashierProfile, CashierProfile.pizzeria);
      
      // Switch to fast food template
      notifier.selectTemplate(RestaurantTemplates.fastFoodExpress);
      expect(notifier.state.blueprint.cashierProfile, CashierProfile.fastFood);
      
      // Switch to blank template
      notifier.selectTemplate(RestaurantTemplates.blank);
      expect(notifier.state.blueprint.cashierProfile, CashierProfile.generic);
    });
  });

  group('Wizard Step Conditional Logic', () {
    test('shouldShowCashierProfileStep is true for blank template', () {
      final notifier = RestaurantWizardNotifier();
      notifier.selectTemplate(RestaurantTemplates.blank);
      
      expect(notifier.state.shouldShowCashierProfileStep, isTrue);
    });

    test('shouldShowCashierProfileStep is false for pizzeria template', () {
      final notifier = RestaurantWizardNotifier();
      notifier.selectTemplate(RestaurantTemplates.pizzeriaClassic);
      
      expect(notifier.state.shouldShowCashierProfileStep, isFalse);
    });

    test('shouldShowCashierProfileStep is false for other business templates', () {
      final notifier = RestaurantWizardNotifier();
      
      notifier.selectTemplate(RestaurantTemplates.fastFoodExpress);
      expect(notifier.state.shouldShowCashierProfileStep, isFalse);
      
      notifier.selectTemplate(RestaurantTemplates.restaurantPremium);
      expect(notifier.state.shouldShowCashierProfileStep, isFalse);
      
      notifier.selectTemplate(RestaurantTemplates.sushiBar);
      expect(notifier.state.shouldShowCashierProfileStep, isFalse);
    });

    test('isCashierProfileValid is always true', () {
      final notifier = RestaurantWizardNotifier();
      
      // Default state
      expect(notifier.state.isCashierProfileValid, isTrue);
      
      // With blank template
      notifier.selectTemplate(RestaurantTemplates.blank);
      expect(notifier.state.isCashierProfileValid, isTrue);
      
      // With business template
      notifier.selectTemplate(RestaurantTemplates.pizzeriaClassic);
      expect(notifier.state.isCashierProfileValid, isTrue);
    });
  });

  group('Default CashierProfile', () {
    test('Initial wizard state has generic cashierProfile', () {
      final notifier = RestaurantWizardNotifier();
      
      expect(
        notifier.state.blueprint.cashierProfile,
        CashierProfile.generic,
      );
    });

    test('Blueprint default has generic cashierProfile', () {
      final notifier = RestaurantWizardNotifier();
      final state = notifier.state;
      
      expect(state.blueprint.cashierProfile, CashierProfile.generic);
    });
  });
}
