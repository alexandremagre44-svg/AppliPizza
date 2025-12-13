/// Test for Order model Phase A refactoring
///
/// This test verifies backward compatibility and new structured data
/// for order items with selections.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/order.dart';
import 'package:pizza_delizza/src/models/order_option_selection.dart';
import 'package:pizza_delizza/src/providers/cart_provider.dart';

void main() {
  group('Order Phase A - CartItem with selections', () {
    test('CartItem can be created with selections', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Large',
          priceDelta: 200,
        ),
      ];

      final item = CartItem(
        id: 'item-1',
        productId: 'pizza-1',
        productName: 'Pizza Margherita',
        price: 10.0,
        quantity: 1,
        imageUrl: 'https://example.com/pizza.jpg',
        selections: selections,
        isMenu: false,
      );

      expect(item.selections.length, 1);
      expect(item.selections[0].label, 'Large');
      expect(item.legacyDescription, isNull);
    });

    test('CartItem backward compatibility with customDescription', () {
      final item = CartItem(
        id: 'item-1',
        productId: 'pizza-1',
        productName: 'Pizza Margherita',
        price: 10.0,
        quantity: 1,
        imageUrl: 'https://example.com/pizza.jpg',
        customDescription: 'Large, Extra Fromage',
        isMenu: false,
      );

      expect(item.selections, isEmpty);
      expect(item.legacyDescription, 'Large, Extra Fromage');
      // ignore: deprecated_member_use_from_same_package
      expect(item.customDescription, 'Large, Extra Fromage');
    });

    test('CartItem displayDescription works with selections', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Large',
          priceDelta: 200,
        ),
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'cheese',
          label: 'Extra Fromage',
          priceDelta: 150,
        ),
      ];

      final item = CartItem(
        id: 'item-1',
        productId: 'pizza-1',
        productName: 'Pizza Margherita',
        price: 10.0,
        quantity: 1,
        imageUrl: 'https://example.com/pizza.jpg',
        selections: selections,
        isMenu: false,
      );

      expect(item.displayDescription, 'Large, Extra Fromage');
    });

    test('CartItem displayDescription falls back to legacyDescription', () {
      final item = CartItem(
        id: 'item-1',
        productId: 'pizza-1',
        productName: 'Pizza Margherita',
        price: 10.0,
        quantity: 1,
        imageUrl: 'https://example.com/pizza.jpg',
        customDescription: 'Old style description',
        isMenu: false,
      );

      expect(item.selections, isEmpty);
      expect(item.displayDescription, 'Old style description');
    });

    test('Order serializes items with selections correctly', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Large',
          priceDelta: 200,
        ),
      ];

      final item = CartItem(
        id: 'item-1',
        productId: 'pizza-1',
        productName: 'Pizza Margherita',
        price: 10.0,
        quantity: 1,
        imageUrl: 'https://example.com/pizza.jpg',
        selections: selections,
        isMenu: false,
      );

      final order = Order.fromCart(
        [item],
        10.0,
        customerName: 'Test Customer',
      );

      final json = order.toJson();
      final itemsJson = json['items'] as List;
      
      expect(itemsJson.length, 1);
      expect(itemsJson[0]['selections'], isNotNull);
      expect(itemsJson[0]['selections'], isA<List>());
      expect((itemsJson[0]['selections'] as List).length, 1);
      expect((itemsJson[0]['selections'] as List)[0]['label'], 'Large');
    });

    test('Order deserializes new format with selections', () {
      final json = {
        'id': 'order-1',
        'total': 12.0,
        'date': DateTime.now().toIso8601String(),
        'items': [
          {
            'id': 'item-1',
            'productId': 'pizza-1',
            'productName': 'Pizza Margherita',
            'price': 10.0,
            'quantity': 1,
            'imageUrl': 'https://example.com/pizza.jpg',
            'selections': [
              {
                'optionGroupId': 'size',
                'optionId': 'large',
                'label': 'Large',
                'priceDelta': 200,
              },
            ],
            'customDescription': null,
            'isMenu': false,
          },
        ],
        'status': 'En attente',
      };

      final order = Order.fromJson(json);

      expect(order.items.length, 1);
      expect(order.items[0].selections.length, 1);
      expect(order.items[0].selections[0].label, 'Large');
      expect(order.items[0].legacyDescription, isNull);
    });

    test('Order deserializes old format without selections (backward compatibility)', () {
      final json = {
        'id': 'order-1',
        'total': 10.0,
        'date': DateTime.now().toIso8601String(),
        'items': [
          {
            'id': 'item-1',
            'productId': 'pizza-1',
            'productName': 'Pizza Margherita',
            'price': 10.0,
            'quantity': 1,
            'imageUrl': 'https://example.com/pizza.jpg',
            'customDescription': 'Large, Extra Fromage',
            'isMenu': false,
          },
        ],
        'status': 'En attente',
      };

      final order = Order.fromJson(json);

      expect(order.items.length, 1);
      expect(order.items[0].selections, isEmpty); // No selections in old format
      expect(order.items[0].legacyDescription, 'Large, Extra Fromage');
      expect(order.items[0].displayDescription, 'Large, Extra Fromage');
    });

    test('Order round-trip with selections preserves data', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Large',
          priceDelta: 200,
        ),
        OrderOptionSelection(
          optionGroupId: 'topping',
          optionId: 'mushrooms',
          label: 'Champignons',
          priceDelta: 100,
        ),
      ];

      final item = CartItem(
        id: 'item-1',
        productId: 'pizza-1',
        productName: 'Pizza Margherita',
        price: 10.0,
        quantity: 2,
        imageUrl: 'https://example.com/pizza.jpg',
        selections: selections,
        isMenu: false,
      );

      final order = Order.fromCart(
        [item],
        20.0,
        customerName: 'Test Customer',
      );

      final json = order.toJson();
      final deserialized = Order.fromJson(json);

      expect(deserialized.items.length, 1);
      expect(deserialized.items[0].selections.length, 2);
      expect(deserialized.items[0].selections[0].label, 'Large');
      expect(deserialized.items[0].selections[1].label, 'Champignons');
      expect(deserialized.items[0].selections[0].priceDelta, 200);
      expect(deserialized.items[0].selections[1].priceDelta, 100);
    });

    test('Order with mixed items (some with selections, some without)', () {
      final item1 = CartItem(
        id: 'item-1',
        productId: 'pizza-1',
        productName: 'Pizza Margherita',
        price: 10.0,
        quantity: 1,
        imageUrl: 'https://example.com/pizza.jpg',
        selections: [
          OrderOptionSelection(
            optionGroupId: 'size',
            optionId: 'large',
            label: 'Large',
            priceDelta: 200,
          ),
        ],
        isMenu: false,
      );

      final item2 = CartItem(
        id: 'item-2',
        productId: 'drink-1',
        productName: 'Coca-Cola',
        price: 2.5,
        quantity: 1,
        imageUrl: 'https://example.com/cola.jpg',
        selections: [], // Simple product, no customization
        isMenu: false,
      );

      final order = Order.fromCart(
        [item1, item2],
        12.5,
        customerName: 'Test Customer',
      );

      final json = order.toJson();
      final deserialized = Order.fromJson(json);

      expect(deserialized.items.length, 2);
      expect(deserialized.items[0].selections.length, 1);
      expect(deserialized.items[1].selections, isEmpty);
    });

    test('Empty selections list is properly serialized and deserialized', () {
      final item = CartItem(
        id: 'item-1',
        productId: 'drink-1',
        productName: 'Water',
        price: 1.0,
        quantity: 1,
        imageUrl: 'https://example.com/water.jpg',
        selections: [], // Explicitly empty
        isMenu: false,
      );

      final order = Order.fromCart([item], 1.0);
      final json = order.toJson();
      
      expect(json['items'][0]['selections'], isEmpty);
      
      final deserialized = Order.fromJson(json);
      expect(deserialized.items[0].selections, isEmpty);
    });
  });

  group('CartItem backward compatibility', () {
    test('existing code using customDescription still works', () {
      // Old code pattern that should still work
      final item = CartItem(
        id: 'item-1',
        productId: 'pizza-1',
        productName: 'Pizza',
        price: 10.0,
        quantity: 1,
        imageUrl: 'url',
        customDescription: 'Custom text',
      );

      // Old code accessing customDescription
      // ignore: deprecated_member_use_from_same_package
      expect(item.customDescription, 'Custom text');
      expect(item.selections, isEmpty);
    });

    test('new code should use selections, not legacyDescription', () {
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Large',
          priceDelta: 200,
        ),
      ];

      final item = CartItem(
        id: 'item-1',
        productId: 'pizza-1',
        productName: 'Pizza',
        price: 10.0,
        quantity: 1,
        imageUrl: 'url',
        selections: selections,
      );

      // New code should use selections as source of truth
      expect(item.selections.length, 1);
      expect(item.selections[0].priceDelta, 200);
      
      // NOT legacyDescription (which should be null)
      expect(item.legacyDescription, isNull);
    });
  });
}
