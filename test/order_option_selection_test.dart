/// Test for OrderOptionSelection - Phase A data structure
///
/// This test verifies the new structured option selection model
/// for order item customization.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/order_option_selection.dart';

void main() {
  group('OrderOptionSelection', () {
    test('creates instance with all fields', () {
      final selection = OrderOptionSelection(
        optionGroupId: 'size',
        optionId: 'large',
        label: 'Large',
        priceDelta: 200,
      );

      expect(selection.optionGroupId, 'size');
      expect(selection.optionId, 'large');
      expect(selection.label, 'Large');
      expect(selection.priceDelta, 200);
    });

    test('serializes to JSON correctly', () {
      final selection = OrderOptionSelection(
        optionGroupId: 'toppings',
        optionId: 'extra-cheese',
        label: 'Extra Fromage',
        priceDelta: 150,
      );

      final json = selection.toJson();

      expect(json['optionGroupId'], 'toppings');
      expect(json['optionId'], 'extra-cheese');
      expect(json['label'], 'Extra Fromage');
      expect(json['priceDelta'], 150);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'optionGroupId': 'drink',
        'optionId': 'cola',
        'label': 'Coca-Cola',
        'priceDelta': 0,
      };

      final selection = OrderOptionSelection.fromJson(json);

      expect(selection.optionGroupId, 'drink');
      expect(selection.optionId, 'cola');
      expect(selection.label, 'Coca-Cola');
      expect(selection.priceDelta, 0);
    });

    test('handles negative price delta', () {
      final selection = OrderOptionSelection(
        optionGroupId: 'discount',
        optionId: 'small-size',
        label: 'Petite',
        priceDelta: -50,
      );

      expect(selection.priceDelta, -50);
      
      final json = selection.toJson();
      final deserialized = OrderOptionSelection.fromJson(json);
      expect(deserialized.priceDelta, -50);
    });

    test('handles zero price delta', () {
      final selection = OrderOptionSelection(
        optionGroupId: 'included',
        optionId: 'standard-sauce',
        label: 'Sauce Standard',
        priceDelta: 0,
      );

      expect(selection.priceDelta, 0);
    });

    test('copyWith creates new instance with changed fields', () {
      final original = OrderOptionSelection(
        optionGroupId: 'size',
        optionId: 'medium',
        label: 'Medium',
        priceDelta: 100,
      );

      final modified = original.copyWith(
        label: 'Moyenne',
        priceDelta: 120,
      );

      expect(modified.optionGroupId, 'size');
      expect(modified.optionId, 'medium');
      expect(modified.label, 'Moyenne');
      expect(modified.priceDelta, 120);
      
      // Original unchanged
      expect(original.label, 'Medium');
      expect(original.priceDelta, 100);
    });

    test('equality comparison works correctly', () {
      final selection1 = OrderOptionSelection(
        optionGroupId: 'size',
        optionId: 'large',
        label: 'Large',
        priceDelta: 200,
      );

      final selection2 = OrderOptionSelection(
        optionGroupId: 'size',
        optionId: 'large',
        label: 'Large',
        priceDelta: 200,
      );

      final selection3 = OrderOptionSelection(
        optionGroupId: 'size',
        optionId: 'small',
        label: 'Small',
        priceDelta: -100,
      );

      expect(selection1, equals(selection2));
      expect(selection1, isNot(equals(selection3)));
    });

    test('hashCode is consistent', () {
      final selection1 = OrderOptionSelection(
        optionGroupId: 'topping',
        optionId: 'mushrooms',
        label: 'Champignons',
        priceDelta: 100,
      );

      final selection2 = OrderOptionSelection(
        optionGroupId: 'topping',
        optionId: 'mushrooms',
        label: 'Champignons',
        priceDelta: 100,
      );

      expect(selection1.hashCode, equals(selection2.hashCode));
    });

    test('toString provides useful output', () {
      final selection = OrderOptionSelection(
        optionGroupId: 'size',
        optionId: 'large',
        label: 'Large',
        priceDelta: 200,
      );

      final str = selection.toString();
      
      expect(str, contains('size'));
      expect(str, contains('large'));
      expect(str, contains('Large'));
      expect(str, contains('200'));
    });

    test('round-trip serialization preserves data', () {
      final original = OrderOptionSelection(
        optionGroupId: 'crust',
        optionId: 'thin',
        label: 'Pâte Fine',
        priceDelta: 0,
      );

      final json = original.toJson();
      final deserialized = OrderOptionSelection.fromJson(json);

      expect(deserialized, equals(original));
    });

    test('works with multiple selections for a pizza', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Large',
          priceDelta: 200,
        ),
        OrderOptionSelection(
          optionGroupId: 'crust',
          optionId: 'thick',
          label: 'Pâte Épaisse',
          priceDelta: 50,
        ),
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'extra-cheese',
          label: 'Extra Fromage',
          priceDelta: 150,
        ),
      ];

      // Verify all selections are independent
      expect(selections.length, 3);
      expect(selections[0].optionGroupId, 'size');
      expect(selections[1].optionGroupId, 'crust');
      expect(selections[2].optionGroupId, 'topping');

      // Total price delta
      final totalDelta = selections.fold<int>(0, (sum, s) => sum + s.priceDelta);
      expect(totalDelta, 400); // 200 + 50 + 150
    });
  });
}
