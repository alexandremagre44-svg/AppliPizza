// test/order_type_validator_test.dart
/// Tests for OrderTypeValidator service

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/order.dart';
import 'package:pizza_delizza/src/services/order_type_validator.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';
import 'package:pizza_delizza/white_label/runtime/module_gate.dart';

void main() {
  group('OrderTypeValidator - Basic Validation', () {
    test('allows base order types (dine_in, takeaway)', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: [],
        ),
      );
      final validator = OrderTypeValidator(gate);

      expect(() => validator.validateOrderType('dine_in'), returnsNormally);
      expect(() => validator.validateOrderType('takeaway'), returnsNormally);
    });

    test('rejects delivery when module disabled', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: [],
        ),
      );
      final validator = OrderTypeValidator(gate);

      expect(
        () => validator.validateOrderType('delivery'),
        throwsA(isA<OrderTypeNotAllowedException>()),
      );
    });

    test('allows delivery when module enabled', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['delivery'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      expect(() => validator.validateOrderType('delivery'), returnsNormally);
    });

    test('rejects click_collect when module disabled', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: [],
        ),
      );
      final validator = OrderTypeValidator(gate);

      expect(
        () => validator.validateOrderType('click_collect'),
        throwsA(isA<OrderTypeNotAllowedException>()),
      );
    });

    test('allows click_collect when module enabled', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['click_and_collect'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      expect(() => validator.validateOrderType('click_collect'), returnsNormally);
    });

    test('rejects unknown order types', () {
      final gate = ModuleGate.permissive();
      final validator = OrderTypeValidator(gate);

      expect(
        () => validator.validateOrderType('unknown'),
        throwsA(isA<OrderTypeNotAllowedException>()),
      );
    });
  });

  group('OrderTypeValidator - Delivery Validation', () {
    test('validates delivery order with all required fields', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['delivery'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      final order = Order(
        id: 'test-order',
        total: 25.0,
        date: DateTime.now(),
        items: [],
        deliveryMode: 'delivery',
        deliveryAddress: OrderDeliveryAddress(
          address: '123 Main St',
          postalCode: '75001',
        ),
        customerPhone: '+33123456789',
      );

      expect(
        () => validator.validateOrder(order, 'delivery'),
        returnsNormally,
      );
    });

    test('rejects delivery order without deliveryMode', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['delivery'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      final order = Order(
        id: 'test-order',
        total: 25.0,
        date: DateTime.now(),
        items: [],
        deliveryAddress: OrderDeliveryAddress(
          address: '123 Main St',
          postalCode: '75001',
        ),
        customerPhone: '+33123456789',
      );

      expect(
        () => validator.validateOrder(order, 'delivery'),
        throwsA(isA<OrderValidationException>()),
      );
    });

    test('rejects delivery order without address', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['delivery'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      final order = Order(
        id: 'test-order',
        total: 25.0,
        date: DateTime.now(),
        items: [],
        deliveryMode: 'delivery',
        customerPhone: '+33123456789',
      );

      expect(
        () => validator.validateOrder(order, 'delivery'),
        throwsA(isA<OrderValidationException>()),
      );
    });

    test('rejects delivery order with empty address', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['delivery'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      final order = Order(
        id: 'test-order',
        total: 25.0,
        date: DateTime.now(),
        items: [],
        deliveryMode: 'delivery',
        deliveryAddress: OrderDeliveryAddress(
          address: '',
          postalCode: '75001',
        ),
        customerPhone: '+33123456789',
      );

      expect(
        () => validator.validateOrder(order, 'delivery'),
        throwsA(isA<OrderValidationException>()),
      );
    });

    test('rejects delivery order without phone', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['delivery'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      final order = Order(
        id: 'test-order',
        total: 25.0,
        date: DateTime.now(),
        items: [],
        deliveryMode: 'delivery',
        deliveryAddress: OrderDeliveryAddress(
          address: '123 Main St',
          postalCode: '75001',
        ),
      );

      expect(
        () => validator.validateOrder(order, 'delivery'),
        throwsA(isA<OrderValidationException>()),
      );
    });
  });

  group('OrderTypeValidator - Click & Collect Validation', () {
    test('validates click_collect order with all required fields', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['click_and_collect'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      final order = Order(
        id: 'test-order',
        total: 25.0,
        date: DateTime.now(),
        items: [],
        pickupDate: '2024-01-15',
        pickupTimeSlot: '12:00-13:00',
        customerName: 'John Doe',
        customerPhone: '+33123456789',
      );

      expect(
        () => validator.validateOrder(order, 'click_collect'),
        returnsNormally,
      );
    });

    test('rejects click_collect order without pickupDate', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['click_and_collect'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      final order = Order(
        id: 'test-order',
        total: 25.0,
        date: DateTime.now(),
        items: [],
        pickupTimeSlot: '12:00-13:00',
        customerName: 'John Doe',
        customerPhone: '+33123456789',
      );

      expect(
        () => validator.validateOrder(order, 'click_collect'),
        throwsA(isA<OrderValidationException>()),
      );
    });

    test('rejects click_collect order without pickupTimeSlot', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['click_and_collect'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      final order = Order(
        id: 'test-order',
        total: 25.0,
        date: DateTime.now(),
        items: [],
        pickupDate: '2024-01-15',
        customerName: 'John Doe',
        customerPhone: '+33123456789',
      );

      expect(
        () => validator.validateOrder(order, 'click_collect'),
        throwsA(isA<OrderValidationException>()),
      );
    });

    test('rejects click_collect order without customerName', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['click_and_collect'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      final order = Order(
        id: 'test-order',
        total: 25.0,
        date: DateTime.now(),
        items: [],
        pickupDate: '2024-01-15',
        pickupTimeSlot: '12:00-13:00',
        customerPhone: '+33123456789',
      );

      expect(
        () => validator.validateOrder(order, 'click_collect'),
        throwsA(isA<OrderValidationException>()),
      );
    });

    test('rejects click_collect order without customerPhone', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['click_and_collect'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      final order = Order(
        id: 'test-order',
        total: 25.0,
        date: DateTime.now(),
        items: [],
        pickupDate: '2024-01-15',
        pickupTimeSlot: '12:00-13:00',
        customerName: 'John Doe',
      );

      expect(
        () => validator.validateOrder(order, 'click_collect'),
        throwsA(isA<OrderValidationException>()),
      );
    });
  });

  group('OrderTypeValidator - Helper Methods', () {
    test('isOrderTypeAllowed returns correct values', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['delivery'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      expect(validator.isOrderTypeAllowed('dine_in'), true);
      expect(validator.isOrderTypeAllowed('takeaway'), true);
      expect(validator.isOrderTypeAllowed('delivery'), true);
      expect(validator.isOrderTypeAllowed('click_collect'), false);
      expect(validator.isOrderTypeAllowed('unknown'), false);
    });

    test('getAllowedOrderTypes returns correct list', () {
      final gate = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['delivery', 'click_and_collect'],
        ),
      );
      final validator = OrderTypeValidator(gate);

      final types = validator.getAllowedOrderTypes();
      expect(types, containsAll(['dine_in', 'takeaway', 'delivery', 'click_collect']));
      expect(types.length, 4);
    });

    test('isDeliveryEnabled returns correct value', () {
      final gateWithDelivery = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['delivery'],
        ),
      );
      final gateWithoutDelivery = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: [],
        ),
      );

      expect(OrderTypeValidator(gateWithDelivery).isDeliveryEnabled(), true);
      expect(OrderTypeValidator(gateWithoutDelivery).isDeliveryEnabled(), false);
    });

    test('isClickAndCollectEnabled returns correct value', () {
      final gateWithCC = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: ['click_and_collect'],
        ),
      );
      final gateWithoutCC = ModuleGate(
        plan: RestaurantPlanUnified(
          restaurantId: 'test',
          name: 'Test',
          slug: 'test',
          activeModules: [],
        ),
      );

      expect(OrderTypeValidator(gateWithCC).isClickAndCollectEnabled(), true);
      expect(OrderTypeValidator(gateWithoutCC).isClickAndCollectEnabled(), false);
    });
  });
}
