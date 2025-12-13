// test/module_gate_integration_test.dart
/// Integration tests for ModuleGate with order creation workflow

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/order.dart';
import 'package:pizza_delizza/src/providers/cart_provider.dart';
import 'package:pizza_delizza/src/services/order_type_validator.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';
import 'package:pizza_delizza/white_label/runtime/module_gate.dart';

void main() {
  group('ModuleGate Integration - Order Creation Workflow', () {
    test('Full delivery order creation when module is enabled', () {
      // Setup: Restaurant with delivery enabled
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['delivery'],
      );

      final gate = ModuleGate(plan: plan);
      final validator = OrderTypeValidator(gate);

      // Create a complete delivery order
      final items = [
        CartItem(
          id: 'item-1',
          productId: 'pizza-1',
          productName: 'Margherita',
          price: 12.50,
          quantity: 2,
          imageUrl: '',
        ),
      ];

      final order = Order.fromCart(
        items,
        25.0,
        customerName: 'John Doe',
        customerPhone: '+33123456789',
        deliveryMode: 'delivery',
        deliveryAddress: OrderDeliveryAddress(
          address: '123 Main Street',
          postalCode: '75001',
        ),
        deliveryFee: 2.50,
      );

      // Validation should pass
      expect(
        () => validator.validateOrder(order, 'delivery'),
        returnsNormally,
      );
    });

    test('Delivery order rejected when module is disabled', () {
      // Setup: Restaurant WITHOUT delivery
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: [], // No delivery module
      );

      final gate = ModuleGate(plan: plan);
      final validator = OrderTypeValidator(gate);

      // Attempt to create delivery order
      final items = [
        CartItem(
          id: 'item-1',
          productId: 'pizza-1',
          productName: 'Margherita',
          price: 12.50,
          quantity: 1,
          imageUrl: '',
        ),
      ];

      final order = Order.fromCart(
        items,
        12.50,
        deliveryMode: 'delivery',
        deliveryAddress: OrderDeliveryAddress(
          address: '123 Main Street',
          postalCode: '75001',
        ),
      );

      // Validation should fail - module disabled
      expect(
        () => validator.validateOrder(order, 'delivery'),
        throwsA(isA<OrderTypeNotAllowedException>()),
      );
    });

    test('Full Click & Collect order creation when module is enabled', () {
      // Setup: Restaurant with click & collect enabled
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['click_and_collect'],
      );

      final gate = ModuleGate(plan: plan);
      final validator = OrderTypeValidator(gate);

      // Create a complete click & collect order
      final items = [
        CartItem(
          id: 'item-1',
          productId: 'pizza-1',
          productName: 'Margherita',
          price: 12.50,
          quantity: 1,
          imageUrl: '',
        ),
      ];

      final order = Order.fromCart(
        items,
        12.50,
        customerName: 'Jane Smith',
        customerPhone: '+33987654321',
        pickupDate: '2024-01-15',
        pickupTimeSlot: '14:00-15:00',
      );

      // Validation should pass
      expect(
        () => validator.validateOrder(order, 'click_collect'),
        returnsNormally,
      );
    });

    test('Click & Collect order rejected when module is disabled', () {
      // Setup: Restaurant WITHOUT click & collect
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: [], // No click_and_collect module
      );

      final gate = ModuleGate(plan: plan);
      final validator = OrderTypeValidator(gate);

      // Attempt to create click & collect order
      final items = [
        CartItem(
          id: 'item-1',
          productId: 'pizza-1',
          productName: 'Margherita',
          price: 12.50,
          quantity: 1,
          imageUrl: '',
        ),
      ];

      final order = Order.fromCart(
        items,
        12.50,
        customerName: 'Jane Smith',
        customerPhone: '+33987654321',
        pickupDate: '2024-01-15',
        pickupTimeSlot: '14:00-15:00',
      );

      // Validation should fail - module disabled
      expect(
        () => validator.validateOrder(order, 'click_collect'),
        throwsA(isA<OrderTypeNotAllowedException>()),
      );
    });

    test('Base order types (dine_in, takeaway) always work', () {
      // Setup: Restaurant with NO modules
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: [], // No modules
      );

      final gate = ModuleGate(plan: plan);
      final validator = OrderTypeValidator(gate);

      final items = [
        CartItem(
          id: 'item-1',
          productId: 'pizza-1',
          productName: 'Margherita',
          price: 12.50,
          quantity: 1,
          imageUrl: '',
        ),
      ];

      // Create orders for base types
      final dineInOrder = Order.fromCart(items, 12.50);
      final takeawayOrder = Order.fromCart(items, 12.50);

      // Both should validate without issues
      expect(
        () => validator.validateOrder(dineInOrder, 'dine_in'),
        returnsNormally,
      );
      expect(
        () => validator.validateOrder(takeawayOrder, 'takeaway'),
        returnsNormally,
      );
    });

    test('Multiple modules can be active simultaneously', () {
      // Setup: Restaurant with both delivery and click_collect
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['delivery', 'click_and_collect'],
      );

      final gate = ModuleGate(plan: plan);
      final validator = OrderTypeValidator(gate);

      // Verify all order types are available
      final allowedTypes = validator.getAllowedOrderTypes();
      expect(allowedTypes, containsAll([
        'dine_in',
        'takeaway',
        'delivery',
        'click_collect',
      ]));

      // Verify each type can be validated
      expect(validator.isOrderTypeAllowed('dine_in'), true);
      expect(validator.isOrderTypeAllowed('takeaway'), true);
      expect(validator.isOrderTypeAllowed('delivery'), true);
      expect(validator.isOrderTypeAllowed('click_collect'), true);
    });

    test('Incomplete delivery order is rejected even with module enabled', () {
      // Setup: Restaurant with delivery enabled
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['delivery'],
      );

      final gate = ModuleGate(plan: plan);
      final validator = OrderTypeValidator(gate);

      final items = [
        CartItem(
          id: 'item-1',
          productId: 'pizza-1',
          productName: 'Margherita',
          price: 12.50,
          quantity: 1,
          imageUrl: '',
        ),
      ];

      // Create delivery order WITHOUT address (invalid)
      final orderWithoutAddress = Order.fromCart(
        items,
        12.50,
        deliveryMode: 'delivery',
        customerPhone: '+33123456789',
      );

      // Should fail validation - missing address
      expect(
        () => validator.validateOrder(orderWithoutAddress, 'delivery'),
        throwsA(isA<OrderValidationException>()),
      );

      // Create delivery order WITHOUT phone (invalid)
      final orderWithoutPhone = Order.fromCart(
        items,
        12.50,
        deliveryMode: 'delivery',
        deliveryAddress: OrderDeliveryAddress(
          address: '123 Main Street',
          postalCode: '75001',
        ),
      );

      // Should fail validation - missing phone
      expect(
        () => validator.validateOrder(orderWithoutPhone, 'delivery'),
        throwsA(isA<OrderValidationException>()),
      );
    });

    test('Incomplete Click & Collect order is rejected even with module enabled', () {
      // Setup: Restaurant with click & collect enabled
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['click_and_collect'],
      );

      final gate = ModuleGate(plan: plan);
      final validator = OrderTypeValidator(gate);

      final items = [
        CartItem(
          id: 'item-1',
          productId: 'pizza-1',
          productName: 'Margherita',
          price: 12.50,
          quantity: 1,
          imageUrl: '',
        ),
      ];

      // Missing pickup date
      final orderWithoutDate = Order.fromCart(
        items,
        12.50,
        customerName: 'John Doe',
        customerPhone: '+33123456789',
        pickupTimeSlot: '14:00-15:00',
      );

      expect(
        () => validator.validateOrder(orderWithoutDate, 'click_collect'),
        throwsA(isA<OrderValidationException>()),
      );

      // Missing time slot
      final orderWithoutSlot = Order.fromCart(
        items,
        12.50,
        customerName: 'John Doe',
        customerPhone: '+33123456789',
        pickupDate: '2024-01-15',
      );

      expect(
        () => validator.validateOrder(orderWithoutSlot, 'click_collect'),
        throwsA(isA<OrderValidationException>()),
      );

      // Missing customer name
      final orderWithoutName = Order.fromCart(
        items,
        12.50,
        customerPhone: '+33123456789',
        pickupDate: '2024-01-15',
        pickupTimeSlot: '14:00-15:00',
      );

      expect(
        () => validator.validateOrder(orderWithoutName, 'click_collect'),
        throwsA(isA<OrderValidationException>()),
      );
    });
  });
}
