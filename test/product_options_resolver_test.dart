/// Test for product options resolver - Phase B
///
/// This test verifies the option resolution logic for different product types.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/product.dart';
import 'package:pizza_delizza/src/services/product_options_resolver.dart';
import 'package:pizza_delizza/white_label/restaurant/cashier_profile.dart';

void main() {
  group('resolveOptionGroupsForProduct - Pizza', () {
    test('pizza product returns size, crust, sauce, and toppings groups', () {
      final pizza = Product(
        id: 'pizza-1',
        name: 'Margherita',
        description: 'Classic pizza',
        price: 10.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
      );

      final groups = resolveOptionGroupsForProduct(product: pizza);

      expect(groups.length, greaterThanOrEqualTo(3)); // At least size, crust, sauce
      
      // Check size group
      final sizeGroup = groups.firstWhere((g) => g.id == 'size');
      expect(sizeGroup.name, 'Choisir une taille');
      expect(sizeGroup.required, true);
      expect(sizeGroup.multiSelect, false);
      expect(sizeGroup.options.length, 4); // small, medium, large, xl
      
      // Check crust group
      final crustGroup = groups.firstWhere((g) => g.id == 'crust');
      expect(crustGroup.name, 'Type de pâte');
      expect(crustGroup.required, false);
      expect(crustGroup.multiSelect, false);
      
      // Check sauce group
      final sauceGroup = groups.firstWhere((g) => g.id == 'sauce');
      expect(sauceGroup.name, 'Sauce de base');
      expect(sauceGroup.required, false);
    });

    test('pizza size options have correct price deltas', () {
      final pizza = Product(
        id: 'pizza-1',
        name: 'Margherita',
        description: 'Classic pizza',
        price: 10.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
      );

      final groups = resolveOptionGroupsForProduct(product: pizza);
      final sizeGroup = groups.firstWhere((g) => g.id == 'size');

      final small = sizeGroup.options.firstWhere((o) => o.id == 'small');
      expect(small.priceDelta, -100); // -1.00€

      final medium = sizeGroup.options.firstWhere((o) => o.id == 'medium');
      expect(medium.priceDelta, 0); // Base price

      final large = sizeGroup.options.firstWhere((o) => o.id == 'large');
      expect(large.priceDelta, 300); // +3.00€

      final xl = sizeGroup.options.firstWhere((o) => o.id == 'xl');
      expect(xl.priceDelta, 500); // +5.00€
    });

    test('pizza with allowed supplements creates toppings group', () {
      final pizza = Product(
        id: 'pizza-1',
        name: 'Margherita',
        description: 'Classic pizza',
        price: 10.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
        allowedSupplements: ['cheese', 'olives', 'mushrooms'],
      );

      final groups = resolveOptionGroupsForProduct(product: pizza);
      final toppingsGroup = groups.firstWhere((g) => g.id == 'toppings');

      expect(toppingsGroup.multiSelect, true);
      expect(toppingsGroup.required, false);
      expect(toppingsGroup.options.length, 3);
    });

    test('pizza with ingredients creates detailed toppings group', () {
      final ingredients = [
        Ingredient(
          id: 'cheese',
          name: 'Extra Fromage',
          extraCost: 1.50,
          category: IngredientCategory.fromage,
          order: 0,
        ),
        Ingredient(
          id: 'olives',
          name: 'Olives',
          extraCost: 1.00,
          category: IngredientCategory.legume,
          order: 1,
        ),
      ];

      final pizza = Product(
        id: 'pizza-1',
        name: 'Margherita',
        description: 'Classic pizza',
        price: 10.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
        allowedSupplements: ['cheese', 'olives'],
      );

      final groups = resolveOptionGroupsForProduct(
        product: pizza,
        availableIngredients: ingredients,
      );

      final toppingsGroup = groups.firstWhere((g) => g.id == 'toppings');
      expect(toppingsGroup.options.length, 2);
      
      final cheeseOption = toppingsGroup.options.firstWhere((o) => o.id == 'cheese');
      expect(cheeseOption.label, 'Extra Fromage');
      expect(cheeseOption.priceDelta, 150); // 1.50€ -> 150 cents
      
      final olivesOption = toppingsGroup.options.firstWhere((o) => o.id == 'olives');
      expect(olivesOption.label, 'Olives');
      expect(olivesOption.priceDelta, 100); // 1.00€ -> 100 cents
    });

    test('groups are sorted by displayOrder', () {
      final pizza = Product(
        id: 'pizza-1',
        name: 'Margherita',
        description: 'Classic pizza',
        price: 10.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
      );

      final groups = resolveOptionGroupsForProduct(product: pizza);

      // Verify groups are in order
      expect(groups[0].id, 'size'); // displayOrder: 0
      expect(groups[1].id, 'crust'); // displayOrder: 1
      expect(groups[2].id, 'sauce'); // displayOrder: 2
    });
  });

  group('resolveOptionGroupsForProduct - Menu', () {
    test('menu product with drink returns drink selection group', () {
      final menu = Product(
        id: 'menu-1',
        name: 'Menu Classic',
        description: 'Pizza + Drink',
        price: 15.0,
        imageUrl: 'url',
        category: ProductCategory.menus,
        isMenu: true,
        pizzaCount: 1,
        drinkCount: 1,
      );

      final groups = resolveOptionGroupsForProduct(product: menu);

      final drinkGroup = groups.firstWhere((g) => g.id == 'drink');
      expect(drinkGroup.name, 'Choisir une boisson');
      expect(drinkGroup.required, true);
      expect(drinkGroup.multiSelect, false);
      expect(drinkGroup.options.length, greaterThan(0));
    });

    test('menu without drink does not return drink group', () {
      final menu = Product(
        id: 'menu-1',
        name: 'Menu Pizza Only',
        description: 'Just pizza',
        price: 12.0,
        imageUrl: 'url',
        category: ProductCategory.menus,
        isMenu: true,
        pizzaCount: 1,
        drinkCount: 0,
      );

      final groups = resolveOptionGroupsForProduct(product: menu);

      expect(groups.where((g) => g.id == 'drink'), isEmpty);
    });
  });

  group('resolveOptionGroupsForProduct - Other Products', () {
    test('drink product returns empty list', () {
      final drink = Product(
        id: 'drink-1',
        name: 'Coca-Cola',
        description: 'Refreshing drink',
        price: 2.5,
        imageUrl: 'url',
        category: ProductCategory.boissons,
      );

      final groups = resolveOptionGroupsForProduct(product: drink);

      expect(groups, isEmpty);
    });

    test('dessert product returns empty list', () {
      final dessert = Product(
        id: 'dessert-1',
        name: 'Tiramisu',
        description: 'Italian dessert',
        price: 5.0,
        imageUrl: 'url',
        category: ProductCategory.desserts,
      );

      final groups = resolveOptionGroupsForProduct(product: dessert);

      expect(groups, isEmpty);
    });
  });

  group('calculatePriceWithOptions', () {
    test('calculates correct price with single option', () {
      final basePrice = 10.0;
      final selectedOptions = [
        OptionItem(id: 'large', label: 'Grande', priceDelta: 300, displayOrder: 0),
      ];

      final finalPrice = calculatePriceWithOptions(
        basePrice: basePrice,
        selectedOptions: selectedOptions,
      );

      expect(finalPrice, 13.0); // 10 + 3
    });

    test('calculates correct price with multiple options', () {
      final basePrice = 10.0;
      final selectedOptions = [
        OptionItem(id: 'large', label: 'Grande', priceDelta: 300, displayOrder: 0),
        OptionItem(id: 'cheese', label: 'Extra Fromage', priceDelta: 150, displayOrder: 1),
        OptionItem(id: 'olives', label: 'Olives', priceDelta: 100, displayOrder: 2),
      ];

      final finalPrice = calculatePriceWithOptions(
        basePrice: basePrice,
        selectedOptions: selectedOptions,
      );

      expect(finalPrice, 15.5); // 10 + 3 + 1.5 + 1
    });

    test('handles negative price deltas', () {
      final basePrice = 10.0;
      final selectedOptions = [
        OptionItem(id: 'small', label: 'Petite', priceDelta: -100, displayOrder: 0),
      ];

      final finalPrice = calculatePriceWithOptions(
        basePrice: basePrice,
        selectedOptions: selectedOptions,
      );

      expect(finalPrice, 9.0); // 10 - 1
    });

    test('handles zero price delta', () {
      final basePrice = 10.0;
      final selectedOptions = [
        OptionItem(id: 'medium', label: 'Moyenne', priceDelta: 0, displayOrder: 0),
      ];

      final finalPrice = calculatePriceWithOptions(
        basePrice: basePrice,
        selectedOptions: selectedOptions,
      );

      expect(finalPrice, 10.0);
    });

    test('handles empty selections', () {
      final basePrice = 10.0;
      final selectedOptions = <OptionItem>[];

      final finalPrice = calculatePriceWithOptions(
        basePrice: basePrice,
        selectedOptions: selectedOptions,
      );

      expect(finalPrice, 10.0);
    });
  });

  group('Ingredient label formatting (fallback)', () {
    test('formats ingredient IDs with underscores', () {
      final pizza = Product(
        id: 'pizza-1',
        name: 'Custom',
        description: 'Test',
        price: 10.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
        allowedSupplements: ['extra_cheese', 'black_olives'],
      );

      final groups = resolveOptionGroupsForProduct(product: pizza);
      final toppingsGroup = groups.firstWhere((g) => g.id == 'toppings');

      expect(toppingsGroup.options[0].label, 'Extra Cheese');
      expect(toppingsGroup.options[1].label, 'Black Olives');
    });

    test('formats ingredient IDs with hyphens', () {
      final pizza = Product(
        id: 'pizza-1',
        name: 'Custom',
        description: 'Test',
        price: 10.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
        allowedSupplements: ['sun-dried-tomatoes'],
      );

      final groups = resolveOptionGroupsForProduct(product: pizza);
      final toppingsGroup = groups.firstWhere((g) => g.id == 'toppings');

      expect(toppingsGroup.options[0].label, 'Sun Dried Tomatoes');
    });

    test('formats simple ingredient IDs', () {
      final pizza = Product(
        id: 'pizza-1',
        name: 'Custom',
        description: 'Test',
        price: 10.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
        allowedSupplements: ['mushrooms'],
      );

      final groups = resolveOptionGroupsForProduct(product: pizza);
      final toppingsGroup = groups.firstWhere((g) => g.id == 'toppings');

      expect(toppingsGroup.options[0].label, 'Mushrooms');
    });
  });

  group('PHASE C2: Cooking options for restaurant profile', () {
    test('restaurant with meat product includes cooking group', () {
      final steak = Product(
        id: 'steak-1',
        name: 'Entrecôte',
        description: 'Premium steak',
        price: 18.0,
        imageUrl: 'url',
        category: ProductCategory.pizza, // Any category
        isMeat: true,
      );

      final groups = resolveOptionGroupsForProduct(
        product: steak,
        cashierProfile: CashierProfile.restaurant,
      );

      // Should have cooking group
      final cookingGroup = groups.firstWhere((g) => g.id == 'cooking');
      expect(cookingGroup.name, 'Cuisson');
      expect(cookingGroup.required, true);
      expect(cookingGroup.multiSelect, false);
      expect(cookingGroup.options.length, 4);
      
      // Check cooking options
      expect(cookingGroup.options[0].id, 'rare');
      expect(cookingGroup.options[0].label, 'Bleu');
      expect(cookingGroup.options[1].id, 'medium_rare');
      expect(cookingGroup.options[1].label, 'Saignant');
      expect(cookingGroup.options[2].id, 'medium');
      expect(cookingGroup.options[2].label, 'À point');
      expect(cookingGroup.options[3].id, 'well_done');
      expect(cookingGroup.options[3].label, 'Bien cuit');
    });

    test('restaurant with non-meat product does NOT include cooking', () {
      final salad = Product(
        id: 'salad-1',
        name: 'Salade César',
        description: 'Fresh salad',
        price: 8.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
        isMeat: false,
      );

      final groups = resolveOptionGroupsForProduct(
        product: salad,
        cashierProfile: CashierProfile.restaurant,
      );

      // Should NOT have cooking group
      expect(groups.where((g) => g.id == 'cooking'), isEmpty);
    });

    test('pizzeria with meat product does NOT include cooking', () {
      final meatPizza = Product(
        id: 'pizza-1',
        name: 'Pizza Carnivore',
        description: 'Meat lovers pizza',
        price: 12.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
        isMeat: true, // Has meat but it's pizza, not steak
      );

      final groups = resolveOptionGroupsForProduct(
        product: meatPizza,
        cashierProfile: CashierProfile.pizzeria,
      );

      // Pizzeria should NOT have cooking options
      expect(groups.where((g) => g.id == 'cooking'), isEmpty);
    });

    test('generic profile with meat does NOT include cooking', () {
      final burger = Product(
        id: 'burger-1',
        name: 'Burger',
        description: 'Tasty burger',
        price: 10.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
        isMeat: true,
      );

      final groups = resolveOptionGroupsForProduct(
        product: burger,
        cashierProfile: CashierProfile.generic,
      );

      // Generic profile should NOT have cooking options
      expect(groups.where((g) => g.id == 'cooking'), isEmpty);
    });

    test('cooking options have zero price delta', () {
      final steak = Product(
        id: 'steak-1',
        name: 'Entrecôte',
        description: 'Premium steak',
        price: 18.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
        isMeat: true,
      );

      final groups = resolveOptionGroupsForProduct(
        product: steak,
        cashierProfile: CashierProfile.restaurant,
      );

      final cookingGroup = groups.firstWhere((g) => g.id == 'cooking');
      
      // All cooking options should have no extra cost
      for (final option in cookingGroup.options) {
        expect(option.priceDelta, 0);
      }
    });
  });
}
