// test/customer_ordering_test.dart
/// Tests for customer ordering system

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/order.dart';
import 'package:pizza_delizza/src/models/pos_order.dart';
import 'package:pizza_delizza/src/models/pos_order_status.dart';
import 'package:pizza_delizza/src/models/order_type.dart';

void main() {
  group('Customer Order Model Tests', () {
    
    test('PosOrder should be created from customer Order', () {
      // Arrange
      final order = Order.fromCart(
        [],
        25.50,
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        source: 'client',
      );
      
      // Act
      final posOrder = PosOrder.fromOrder(
        order,
        orderType: OrderType.delivery,
      );
      
      // Assert
      expect(posOrder.id, equals(order.id));
      expect(posOrder.total, equals(25.50));
      expect(posOrder.customerName, equals('John Doe'));
      expect(posOrder.orderType, equals(OrderType.delivery));
      expect(posOrder.baseOrder.source, equals('client'));
    });
    
    test('Customer order should start in draft status', () {
      // Arrange
      final order = Order.fromCart(
        [],
        30.00,
        source: 'client',
      );
      
      // Act
      final posOrder = PosOrder.fromOrder(
        order.copyWith(status: PosOrderStatus.draft),
        orderType: OrderType.takeaway,
      );
      
      // Assert
      expect(posOrder.status, equals(PosOrderStatus.draft));
      expect(posOrder.requiresPayment, isTrue);
    });
    
    test('Customer order workflow should follow POS statuses', () {
      // Arrange
      final order = Order.fromCart([], 20.00, source: 'client');
      
      // Act & Assert - Draft
      var posOrder = PosOrder.fromOrder(
        order.copyWith(status: PosOrderStatus.draft),
        orderType: OrderType.takeaway,
      );
      expect(posOrder.status, equals(PosOrderStatus.draft));
      
      // Paid
      posOrder = posOrder.copyWith(
        baseOrder: posOrder.baseOrder.copyWith(status: PosOrderStatus.paid),
      );
      expect(posOrder.status, equals(PosOrderStatus.paid));
      
      // In Preparation
      posOrder = posOrder.copyWith(
        baseOrder: posOrder.baseOrder.copyWith(status: PosOrderStatus.inPreparation),
      );
      expect(posOrder.status, equals(PosOrderStatus.inPreparation));
      
      // Ready
      posOrder = posOrder.copyWith(
        baseOrder: posOrder.baseOrder.copyWith(status: PosOrderStatus.ready),
      );
      expect(posOrder.status, equals(PosOrderStatus.ready));
      
      // Served
      posOrder = posOrder.copyWith(
        baseOrder: posOrder.baseOrder.copyWith(status: PosOrderStatus.served),
      );
      expect(posOrder.status, equals(PosOrderStatus.served));
    });
    
    test('Customer order should support delivery information', () {
      // Arrange
      final deliveryAddress = OrderDeliveryAddress(
        address: '123 Main St',
        postalCode: '75001',
        complement: 'Apt 5',
        driverInstructions: 'Ring bell',
      );
      
      final order = Order.fromCart(
        [],
        35.00,
        source: 'client',
        deliveryMode: OrderDeliveryMode.delivery,
        deliveryAddress: deliveryAddress,
        deliveryFee: 5.00,
      );
      
      // Assert
      expect(order.isDeliveryOrder, isTrue);
      expect(order.deliveryAddress, isNotNull);
      expect(order.deliveryAddress!.address, equals('123 Main St'));
      expect(order.deliveryFee, equals(5.00));
    });
    
    test('Customer order should support takeaway information', () {
      // Arrange
      final order = Order.fromCart(
        [],
        25.00,
        source: 'client',
        deliveryMode: OrderDeliveryMode.takeAway,
        pickupDate: '25/12/2024',
        pickupTimeSlot: '18:30',
      );
      
      // Assert
      expect(order.isTakeAwayOrder, isTrue);
      expect(order.pickupDate, equals('25/12/2024'));
      expect(order.pickupTimeSlot, equals('18:30'));
    });
    
    test('PosOrder serialization should preserve customer order data', () {
      // Arrange
      final order = Order.fromCart(
        [],
        40.00,
        customerName: 'Jane Smith',
        customerEmail: 'jane@example.com',
        customerPhone: '+33612345678',
        source: 'client',
      );
      
      final posOrder = PosOrder.fromOrder(
        order.copyWith(status: PosOrderStatus.paid),
        orderType: OrderType.delivery,
      );
      
      // Act
      final json = posOrder.toJson();
      final restored = PosOrder.fromJson(json);
      
      // Assert
      expect(restored.customerName, equals('Jane Smith'));
      expect(restored.baseOrder.customerEmail, equals('jane@example.com'));
      expect(restored.baseOrder.customerPhone, equals('+33612345678'));
      expect(restored.baseOrder.source, equals('client'));
      expect(restored.orderType, equals(OrderType.delivery));
      expect(restored.status, equals(PosOrderStatus.paid));
    });
    
    test('Order source should distinguish client from POS orders', () {
      // Arrange
      final clientOrder = Order.fromCart([], 20.00, source: 'client');
      final posOrder = Order.fromCart([], 20.00, source: 'pos');
      
      // Assert
      expect(clientOrder.source, equals('client'));
      expect(posOrder.source, equals('pos'));
    });
  });
}
