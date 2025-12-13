/// Test for selection formatter service - Phase B
///
/// This test verifies the formatting of order selections into readable text.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/order_option_selection.dart';
import 'package:pizza_delizza/src/services/selection_formatter.dart';

void main() {
  group('formatSelections', () {
    test('formats single selection', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Grande',
          priceDelta: 300,
        ),
      ];

      final result = formatSelections(selections);
      expect(result, 'Grande');
    });

    test('formats multiple selections with bullet separator', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Grande',
          priceDelta: 300,
        ),
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'cheese',
          label: 'Extra Fromage',
          priceDelta: 150,
        ),
      ];

      final result = formatSelections(selections);
      expect(result, 'Grande • Extra Fromage');
    });

    test('returns null for empty selections', () {
      final result = formatSelections([]);
      expect(result, null);
    });

    test('formats many selections', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'xl',
          label: 'XL',
          priceDelta: 500,
        ),
        OrderOptionSelection(
          optionGroupId: 'crust',
          optionId: 'thick',
          label: 'Pâte épaisse',
          priceDelta: 50,
        ),
        OrderOptionSelection(
          optionGroupId: 'sauce',
          optionId: 'bbq',
          label: 'BBQ',
          priceDelta: 50,
        ),
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'cheese',
          label: 'Extra Fromage',
          priceDelta: 150,
        ),
      ];

      final result = formatSelections(selections);
      expect(result, 'XL • Pâte épaisse • BBQ • Extra Fromage');
    });
  });

  group('formatSelectionsWithFallback', () {
    test('returns formatted selections when selections exist', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Grande',
          priceDelta: 300,
        ),
      ];

      final result = formatSelectionsWithFallback(
        selections: selections,
        legacyDescription: 'Old description',
      );

      expect(result, 'Grande');
    });

    test('returns legacy description when selections is empty', () {
      final result = formatSelectionsWithFallback(
        selections: [],
        legacyDescription: 'Old style description',
      );

      expect(result, 'Old style description');
    });

    test('returns null when both are empty/null', () {
      final result = formatSelectionsWithFallback(
        selections: [],
        legacyDescription: null,
      );

      expect(result, null);
    });

    test('prefers selections over legacy description', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'New format',
          priceDelta: 300,
        ),
      ];

      final result = formatSelectionsWithFallback(
        selections: selections,
        legacyDescription: 'Old format',
      );

      expect(result, 'New format');
    });
  });

  group('formatSelectionsGrouped', () {
    test('formats single group', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Grande',
          priceDelta: 300,
        ),
      ];

      final result = formatSelectionsGrouped(selections);
      expect(result, 'Taille: Grande');
    });

    test('formats multiple groups with pipe separator', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Grande',
          priceDelta: 300,
        ),
        OrderOptionSelection(
          optionGroupId: 'crust',
          optionId: 'thick',
          label: 'Pâte épaisse',
          priceDelta: 50,
        ),
      ];

      final result = formatSelectionsGrouped(selections);
      expect(result, 'Taille: Grande | Pâte: Pâte épaisse');
    });

    test('groups multiple items from same group', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'toppings',
          optionId: 'cheese',
          label: 'Extra Fromage',
          priceDelta: 150,
        ),
        OrderOptionSelection(
          optionGroupId: 'toppings',
          optionId: 'olives',
          label: 'Olives',
          priceDelta: 100,
        ),
      ];

      final result = formatSelectionsGrouped(selections);
      expect(result, 'Suppléments: Extra Fromage, Olives');
    });

    test('returns null for empty selections', () {
      final result = formatSelectionsGrouped([]);
      expect(result, null);
    });
  });

  group('formatSelectionsCompact', () {
    test('formats size selection prominently', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Grande',
          priceDelta: 300,
        ),
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'cheese',
          label: 'Extra Fromage',
          priceDelta: 150,
        ),
      ];

      final result = formatSelectionsCompact(selections);
      expect(result, 'Grande • Extra Fromage');
    });

    test('limits to 3 non-size selections with counter', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'xl',
          label: 'XL',
          priceDelta: 500,
        ),
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'cheese',
          label: 'Fromage',
          priceDelta: 150,
        ),
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'olives',
          label: 'Olives',
          priceDelta: 100,
        ),
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'mushrooms',
          label: 'Champignons',
          priceDelta: 100,
        ),
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'peppers',
          label: 'Poivrons',
          priceDelta: 100,
        ),
      ];

      final result = formatSelectionsCompact(selections);
      expect(result, contains('XL'));
      expect(result, contains('+1')); // +1 more item
    });

    test('returns null for empty selections', () {
      final result = formatSelectionsCompact([]);
      expect(result, null);
    });

    test('handles selections without size', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'cheese',
          label: 'Extra Fromage',
          priceDelta: 150,
        ),
      ];

      final result = formatSelectionsCompact(selections);
      expect(result, 'Extra Fromage');
    });
  });

  group('calculateTotalPriceDelta', () {
    test('calculates sum of positive deltas', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Grande',
          priceDelta: 300,
        ),
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'cheese',
          label: 'Fromage',
          priceDelta: 150,
        ),
      ];

      final total = calculateTotalPriceDelta(selections);
      expect(total, 450); // 300 + 150
    });

    test('handles negative deltas', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'small',
          label: 'Petite',
          priceDelta: -100,
        ),
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'cheese',
          label: 'Fromage',
          priceDelta: 150,
        ),
      ];

      final total = calculateTotalPriceDelta(selections);
      expect(total, 50); // -100 + 150
    });

    test('returns zero for empty selections', () {
      final total = calculateTotalPriceDelta([]);
      expect(total, 0);
    });
  });

  group('formatPriceDelta', () {
    test('formats positive delta with plus sign', () {
      expect(formatPriceDelta(200), '+2.00€');
      expect(formatPriceDelta(150), '+1.50€');
      expect(formatPriceDelta(5), '+0.05€');
    });

    test('formats negative delta with minus sign', () {
      expect(formatPriceDelta(-100), '-1.00€');
      expect(formatPriceDelta(-50), '-0.50€');
    });

    test('returns empty string for zero', () {
      expect(formatPriceDelta(0), '');
    });

    test('formats cents correctly', () {
      expect(formatPriceDelta(1), '+0.01€');
      expect(formatPriceDelta(99), '+0.99€');
      expect(formatPriceDelta(1000), '+10.00€');
    });
  });
}
