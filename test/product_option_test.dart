/// Test for OptionGroup and OptionItem models - Phase B
///
/// This test verifies the product option models for structured customization.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/product_option.dart';

void main() {
  group('OptionItem', () {
    test('creates instance with all fields', () {
      final item = OptionItem(
        id: 'large',
        label: 'Grande (40cm)',
        priceDelta: 300,
        displayOrder: 2,
      );

      expect(item.id, 'large');
      expect(item.label, 'Grande (40cm)');
      expect(item.priceDelta, 300);
      expect(item.displayOrder, 2);
    });

    test('serializes to JSON correctly', () {
      final item = OptionItem(
        id: 'large',
        label: 'Grande',
        priceDelta: 200,
        displayOrder: 1,
      );

      final json = item.toJson();

      expect(json['id'], 'large');
      expect(json['label'], 'Grande');
      expect(json['priceDelta'], 200);
      expect(json['displayOrder'], 1);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': 'small',
        'label': 'Petite',
        'priceDelta': -100,
        'displayOrder': 0,
      };

      final item = OptionItem.fromJson(json);

      expect(item.id, 'small');
      expect(item.label, 'Petite');
      expect(item.priceDelta, -100);
      expect(item.displayOrder, 0);
    });

    test('copyWith creates new instance', () {
      final original = OptionItem(
        id: 'medium',
        label: 'Moyenne',
        priceDelta: 0,
        displayOrder: 1,
      );

      final modified = original.copyWith(
        label: 'Medium',
        priceDelta: 50,
      );

      expect(modified.id, 'medium');
      expect(modified.label, 'Medium');
      expect(modified.priceDelta, 50);
      expect(modified.displayOrder, 1);
    });

    test('equality works correctly', () {
      final item1 = OptionItem(
        id: 'large',
        label: 'Grande',
        priceDelta: 200,
        displayOrder: 2,
      );

      final item2 = OptionItem(
        id: 'large',
        label: 'Grande',
        priceDelta: 200,
        displayOrder: 2,
      );

      final item3 = OptionItem(
        id: 'small',
        label: 'Petite',
        priceDelta: -100,
        displayOrder: 0,
      );

      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
    });
  });

  group('OptionGroup', () {
    test('creates instance with all fields', () {
      final options = [
        OptionItem(id: 'small', label: 'Petite', priceDelta: -100, displayOrder: 0),
        OptionItem(id: 'medium', label: 'Moyenne', priceDelta: 0, displayOrder: 1),
      ];

      final group = OptionGroup(
        id: 'size',
        name: 'Choisir une taille',
        required: true,
        multiSelect: false,
        maxSelections: null,
        displayOrder: 0,
        options: options,
      );

      expect(group.id, 'size');
      expect(group.name, 'Choisir une taille');
      expect(group.required, true);
      expect(group.multiSelect, false);
      expect(group.maxSelections, null);
      expect(group.displayOrder, 0);
      expect(group.options.length, 2);
    });

    test('serializes to JSON correctly', () {
      final group = OptionGroup(
        id: 'size',
        name: 'Taille',
        required: true,
        multiSelect: false,
        displayOrder: 0,
        options: [
          OptionItem(id: 'small', label: 'Petite', priceDelta: -100, displayOrder: 0),
        ],
      );

      final json = group.toJson();

      expect(json['id'], 'size');
      expect(json['name'], 'Taille');
      expect(json['required'], true);
      expect(json['multiSelect'], false);
      expect(json['displayOrder'], 0);
      expect(json['options'], isA<List>());
      expect((json['options'] as List).length, 1);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': 'toppings',
        'name': 'Suppléments',
        'required': false,
        'multiSelect': true,
        'maxSelections': 5,
        'displayOrder': 1,
        'options': [
          {'id': 'cheese', 'label': 'Fromage', 'priceDelta': 150, 'displayOrder': 0},
          {'id': 'olives', 'label': 'Olives', 'priceDelta': 100, 'displayOrder': 1},
        ],
      };

      final group = OptionGroup.fromJson(json);

      expect(group.id, 'toppings');
      expect(group.name, 'Suppléments');
      expect(group.required, false);
      expect(group.multiSelect, true);
      expect(group.maxSelections, 5);
      expect(group.displayOrder, 1);
      expect(group.options.length, 2);
      expect(group.options[0].id, 'cheese');
      expect(group.options[1].id, 'olives');
    });

    test('handles null maxSelections', () {
      final json = {
        'id': 'toppings',
        'name': 'Suppléments',
        'required': false,
        'multiSelect': true,
        'maxSelections': null,
        'displayOrder': 1,
        'options': [],
      };

      final group = OptionGroup.fromJson(json);
      expect(group.maxSelections, null);
    });

    test('copyWith creates new instance', () {
      final original = OptionGroup(
        id: 'size',
        name: 'Taille',
        required: true,
        multiSelect: false,
        displayOrder: 0,
        options: [],
      );

      final modified = original.copyWith(
        name: 'Choisir la taille',
        required: false,
      );

      expect(modified.id, 'size');
      expect(modified.name, 'Choisir la taille');
      expect(modified.required, false);
      expect(modified.multiSelect, false);
    });

    test('round-trip serialization preserves data', () {
      final original = OptionGroup(
        id: 'crust',
        name: 'Type de pâte',
        required: false,
        multiSelect: false,
        maxSelections: 1,
        displayOrder: 1,
        options: [
          OptionItem(id: 'thin', label: 'Fine', priceDelta: 0, displayOrder: 0),
          OptionItem(id: 'thick', label: 'Épaisse', priceDelta: 50, displayOrder: 1),
        ],
      );

      final json = original.toJson();
      final deserialized = OptionGroup.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.name, original.name);
      expect(deserialized.required, original.required);
      expect(deserialized.multiSelect, original.multiSelect);
      expect(deserialized.maxSelections, original.maxSelections);
      expect(deserialized.displayOrder, original.displayOrder);
      expect(deserialized.options.length, original.options.length);
    });
  });
}
