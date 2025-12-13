/// Test for cart item builder service - Phase C1
///
/// This test verifies the CartItem building logic with selections.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/product.dart';
import 'package:pizza_delizza/src/models/product_option.dart';
import 'package:pizza_delizza/src/services/cart_item_builder.dart';

void main() {
  group('buildCartItemWithSelections', () {
    test('builds cart item with single selection (size)', () {
      final pizza = Product(
        id: 'pizza-1',
        name: 'Margherita',
        description: 'Classic pizza',
        price: 10.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
      );

      final sizeOption = OptionItem(
        id: 'large',
        label: 'Grande',
        priceDelta: 300,
        displayOrder: 2,
      );

      final selectedOptions = <String, dynamic>{
        'size': sizeOption,
      };

      final cartItem = buildCartItemWithSelections(
        product: pizza,
        selectedOptions: selectedOptions,
        quantity: 1,
      );

      expect(cartItem.selections.length, 1);
      expect(cartItem.selections[0].optionGroupId, 'size');
      expect(cartItem.selections[0].optionId, 'large');
      expect(cartItem.selections[0].label, 'Grande');
      expect(cartItem.selections[0].priceDelta, 300);
      expect(cartItem.price, 13.0); // 10 + 3
    });

    test('builds cart item with multiple selections', () {
      final pizza = Product(
        id: 'pizza-1',
        name: 'Margherita',
        description: 'Classic pizza',
        price: 10.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
      );

      final sizeOption = OptionItem(
        id: 'large',
        label: 'Grande',
        priceDelta: 300,
        displayOrder: 0,
      );

      final toppingOptions = [
        OptionItem(
          id: 'cheese',
          label: 'Extra Fromage',
          priceDelta: 150,
          displayOrder: 0,
        ),
        OptionItem(
          id: 'olives',
          label: 'Olives',
          priceDelta: 100,
          displayOrder: 1,
        ),
      ];

      final selectedOptions = <String, dynamic>{
        'size': sizeOption,
        'toppings': toppingOptions,
      };

      final cartItem = buildCartItemWithSelections(
        product: pizza,
        selectedOptions: selectedOptions,
        quantity: 1,
      );

      expect(cartItem.selections.length, 3); // 1 size + 2 toppings
      expect(cartItem.selections[0].optionGroupId, 'size');
      expect(cartItem.selections[1].optionGroupId, 'toppings');
      expect(cartItem.selections[2].optionGroupId, 'toppings');
      expect(cartItem.price, 15.5); // 10 + 3 + 1.5 + 1
    });

    test('builds cart item with cooking selection (Phase C2)', () {
      final steak = Product(
        id: 'steak-1',
        name: 'Entrecôte',
        description: 'Premium steak',
        price: 18.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
        isMeat: true,
      );

      final cookingOption = OptionItem(
        id: 'medium',
        label: 'À point',
        priceDelta: 0,
        displayOrder: 2,
      );

      final selectedOptions = <String, dynamic>{
        'cooking': cookingOption,
      };

      final cartItem = buildCartItemWithSelections(
        product: steak,
        selectedOptions: selectedOptions,
        quantity: 1,
      );

      expect(cartItem.selections.length, 1);
      expect(cartItem.selections[0].optionGroupId, 'cooking');
      expect(cartItem.selections[0].optionId, 'medium');
      expect(cartItem.selections[0].label, 'À point');
      expect(cartItem.price, 18.0); // No price change for cooking
    });

    test('generates legacy description as fallback', () {
      final pizza = Product(
        id: 'pizza-1',
        name: 'Margherita',
        description: 'Classic pizza',
        price: 10.0,
        imageUrl: 'url',
        category: ProductCategory.pizza,
      );

      final sizeOption = OptionItem(
        id: 'large',
        label: 'Grande',
        priceDelta: 300,
        displayOrder: 0,
      );

      final selectedOptions = <String, dynamic>{
        'size': sizeOption,
      };

      final cartItem = buildCartItemWithSelections(
        product: pizza,
        selectedOptions: selectedOptions,
        quantity: 1,
      );

      expect(cartItem.legacyDescription, isNotNull);
      expect(cartItem.legacyDescription, contains('Grande'));
    });

    test('handles empty selections', () {
      final drink = Product(
        id: 'drink-1',
        name: 'Coca-Cola',
        description: 'Refreshing',
        price: 2.5,
        imageUrl: 'url',
        category: ProductCategory.boissons,
      );

      final selectedOptions = <String, dynamic>{};

      final cartItem = buildCartItemWithSelections(
        product: drink,
        selectedOptions: selectedOptions,
        quantity: 1,
      );

      expect(cartItem.selections, isEmpty);
      expect(cartItem.price, 2.5); // No change
    });
  });

  group('validateRequiredSelections', () {
    test('validates required single selection is present', () {
      final optionGroups = [
        OptionGroup(
          id: 'size',
          name: 'Taille',
          required: true,
          multiSelect: false,
          displayOrder: 0,
          options: [],
        ),
      ];

      final selectedOptions = <String, dynamic>{
        'size': OptionItem(id: 'large', label: 'Grande', priceDelta: 300, displayOrder: 0),
      };

      final error = validateRequiredSelections(
        optionGroups: optionGroups,
        selectedOptions: selectedOptions,
      );

      expect(error, isNull); // Valid
    });

    test('validates required selection is missing', () {
      final optionGroups = [
        OptionGroup(
          id: 'cooking',
          name: 'Cuisson',
          required: true,
          multiSelect: false,
          displayOrder: 0,
          options: [],
        ),
      ];

      final selectedOptions = <String, dynamic>{}; // Missing cooking

      final error = validateRequiredSelections(
        optionGroups: optionGroups,
        selectedOptions: selectedOptions,
      );

      expect(error, isNotNull);
      expect(error, contains('Cuisson'));
      expect(error, contains('requis'));
    });

    test('validates optional selection can be missing', () {
      final optionGroups = [
        OptionGroup(
          id: 'toppings',
          name: 'Suppléments',
          required: false,
          multiSelect: true,
          displayOrder: 0,
          options: [],
        ),
      ];

      final selectedOptions = <String, dynamic>{}; // No toppings

      final error = validateRequiredSelections(
        optionGroups: optionGroups,
        selectedOptions: selectedOptions,
      );

      expect(error, isNull); // Valid, optional can be empty
    });

    test('validates required multi-select with empty list fails', () {
      final optionGroups = [
        OptionGroup(
          id: 'sides',
          name: 'Accompagnements',
          required: true,
          multiSelect: true,
          displayOrder: 0,
          options: [],
        ),
      ];

      final selectedOptions = <String, dynamic>{
        'sides': <OptionItem>[], // Empty list
      };

      final error = validateRequiredSelections(
        optionGroups: optionGroups,
        selectedOptions: selectedOptions,
      );

      expect(error, isNotNull);
      expect(error, contains('Accompagnements'));
    });
  });

  group('selectSingleOption', () {
    test('sets single option in map', () {
      final selectedOptions = <String, dynamic>{};
      final sizeOption = OptionItem(
        id: 'large',
        label: 'Grande',
        priceDelta: 300,
        displayOrder: 0,
      );

      selectSingleOption(selectedOptions, 'size', sizeOption);

      expect(selectedOptions['size'], equals(sizeOption));
    });

    test('replaces previous single option', () {
      final selectedOptions = <String, dynamic>{};
      final mediumOption = OptionItem(
        id: 'medium',
        label: 'Moyenne',
        priceDelta: 0,
        displayOrder: 0,
      );
      final largeOption = OptionItem(
        id: 'large',
        label: 'Grande',
        priceDelta: 300,
        displayOrder: 1,
      );

      selectSingleOption(selectedOptions, 'size', mediumOption);
      selectSingleOption(selectedOptions, 'size', largeOption);

      expect(selectedOptions['size'], equals(largeOption));
    });
  });

  group('toggleMultiSelectOption', () {
    test('adds option to empty list', () {
      final selectedOptions = <String, dynamic>{};
      final cheeseOption = OptionItem(
        id: 'cheese',
        label: 'Fromage',
        priceDelta: 150,
        displayOrder: 0,
      );

      toggleMultiSelectOption(selectedOptions, 'toppings', cheeseOption);

      final toppings = selectedOptions['toppings'] as List<OptionItem>;
      expect(toppings.length, 1);
      expect(toppings[0].id, 'cheese');
    });

    test('adds second option to list', () {
      final selectedOptions = <String, dynamic>{
        'toppings': <OptionItem>[
          OptionItem(id: 'cheese', label: 'Fromage', priceDelta: 150, displayOrder: 0),
        ],
      };
      final olivesOption = OptionItem(
        id: 'olives',
        label: 'Olives',
        priceDelta: 100,
        displayOrder: 1,
      );

      toggleMultiSelectOption(selectedOptions, 'toppings', olivesOption);

      final toppings = selectedOptions['toppings'] as List<OptionItem>;
      expect(toppings.length, 2);
      expect(toppings[1].id, 'olives');
    });

    test('removes option when toggled again', () {
      final cheeseOption = OptionItem(
        id: 'cheese',
        label: 'Fromage',
        priceDelta: 150,
        displayOrder: 0,
      );
      final selectedOptions = <String, dynamic>{
        'toppings': <OptionItem>[cheeseOption],
      };

      toggleMultiSelectOption(selectedOptions, 'toppings', cheeseOption);

      final toppings = selectedOptions['toppings'] as List<OptionItem>;
      expect(toppings, isEmpty);
    });
  });
}
