// test/kds_workflow_test.dart
/// Tests for KDS (Kitchen Display System) workflow

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/order.dart';
import 'package:pizza_delizza/src/models/pos_order.dart';
import 'package:pizza_delizza/src/models/pos_order_status.dart';
import 'package:pizza_delizza/src/models/order_type.dart';
import 'package:pizza_delizza/src/models/order_option_selection.dart';
import 'package:pizza_delizza/src/providers/cart_provider.dart';
import 'package:pizza_delizza/src/services/selection_formatter.dart';

void main() {
  group('KDS Workflow Tests', () {
    
    test('Paid order should be visible in KDS', () {
      // Arrange
      final order = _createTestPosOrder(PosOrderStatus.paid);
      
      // Assert
      expect(order.status, equals(PosOrderStatus.paid));
      expect(order.requiresPayment, isFalse);
    });
    
    test('Order can transition from paid to in_preparation', () {
      // Arrange
      final order = _createTestPosOrder(PosOrderStatus.paid);
      
      // Act
      final nextStatuses = PosOrderStatus.getNextStatuses(order.status);
      
      // Assert
      expect(nextStatuses.contains(PosOrderStatus.inPreparation), isTrue);
    });
    
    test('Order can transition from in_preparation to ready', () {
      // Arrange
      final order = _createTestPosOrder(PosOrderStatus.inPreparation);
      
      // Act
      final nextStatuses = PosOrderStatus.getNextStatuses(order.status);
      
      // Assert
      expect(nextStatuses.contains(PosOrderStatus.ready), isTrue);
    });
    
    test('Order cannot transition from draft to in_preparation directly', () {
      // Arrange
      final order = _createTestPosOrder(PosOrderStatus.draft);
      
      // Act
      final nextStatuses = PosOrderStatus.getNextStatuses(order.status);
      
      // Assert
      expect(nextStatuses.contains(PosOrderStatus.inPreparation), isFalse);
    });
    
    test('KDS should display order with selections formatted', () {
      // Arrange
      final selections = [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Grande',
          priceDelta: 200,
        ),
        OrderOptionSelection(
          optionGroupId: 'supplements',
          optionId: 'extra-cheese',
          label: 'Extra fromage',
          priceDelta: 150,
        ),
        OrderOptionSelection(
          optionGroupId: 'supplements',
          optionId: 'olives',
          label: 'Olives',
          priceDelta: 100,
        ),
      ];
      
      final item = CartItem(
        id: 'item_1',
        productId: 'prod_1',
        productName: 'Pizza Margherita',
        price: 12.50,
        quantity: 2,
        imageUrl: '',
        selections: selections,
      );
      
      // Act
      final formatted = formatSelections(selections);
      
      // Assert
      expect(formatted, contains('Grande'));
      expect(formatted, contains('Extra fromage'));
      expect(formatted, contains('Olives'));
    });
    
    test('KDS should show order type correctly', () {
      // Test all order types
      expect(OrderType.getLabel(OrderType.dineIn), equals('Sur place'));
      expect(OrderType.getLabel(OrderType.takeaway), equals('À emporter'));
      expect(OrderType.getLabel(OrderType.delivery), equals('Livraison'));
      expect(OrderType.getLabel(OrderType.clickCollect), equals('Click & Collect'));
    });
    
    test('KDS should distinguish between POS and client orders', () {
      // Arrange
      final posOrder = _createTestPosOrder(PosOrderStatus.paid, source: 'pos');
      final clientOrder = _createTestPosOrder(PosOrderStatus.paid, source: 'client');
      
      // Assert
      expect(posOrder.baseOrder.source, equals('pos'));
      expect(clientOrder.baseOrder.source, equals('client'));
    });
    
    test('KDS should not modify order items', () {
      // Arrange
      final originalOrder = _createTestPosOrderWithItems();
      final originalItems = List.from(originalOrder.items);
      
      // Act - Simulate status change (KDS only changes status, not items)
      final updatedOrder = originalOrder.copyWith(
        baseOrder: originalOrder.baseOrder.copyWith(
          status: PosOrderStatus.inPreparation,
        ),
      );
      
      // Assert - Items should remain unchanged
      expect(updatedOrder.items.length, equals(originalItems.length));
      expect(updatedOrder.items[0].productName, equals(originalItems[0].productName));
      expect(updatedOrder.items[0].quantity, equals(originalItems[0].quantity));
    });
    
    test('Order should track status history', () {
      // Arrange
      final now = DateTime.now();
      final order = Order.fromCart(
        [],
        25.00,
        source: 'client',
      );
      
      // Assert
      expect(order.statusHistory, isNotNull);
      expect(order.statusHistory!.length, greaterThan(0));
      expect(order.statusHistory!.first.status, equals(OrderStatus.pending));
    });
    
    test('KDS statuses should have correct labels', () {
      // Assert
      expect(PosOrderStatus.getLabel(PosOrderStatus.paid), equals('Payée'));
      expect(PosOrderStatus.getLabel(PosOrderStatus.inPreparation), equals('En préparation'));
      expect(PosOrderStatus.getLabel(PosOrderStatus.ready), equals('Prête'));
    });
    
    test('Ready status can transition to served', () {
      // Act
      final nextStatuses = PosOrderStatus.getNextStatuses(PosOrderStatus.ready);
      
      // Assert
      expect(nextStatuses.contains(PosOrderStatus.served), isTrue);
    });
    
    test('Served status is terminal', () {
      // Act
      final isTerminal = PosOrderStatus.isTerminal(PosOrderStatus.served);
      
      // Assert
      expect(isTerminal, isTrue);
    });
    
    test('Order with table number should display correctly', () {
      // Arrange
      final order = Order.fromCart([], 30.00);
      final posOrder = PosOrder.fromOrder(
        order,
        orderType: OrderType.dineIn,
        tableNumber: '12',
      );
      
      // Assert
      expect(posOrder.tableNumber, equals('12'));
      expect(posOrder.orderType, equals(OrderType.dineIn));
    });
  });
}

/// Helper to create test PosOrder
PosOrder _createTestPosOrder(String status, {String source = 'client'}) {
  final order = Order.fromCart(
    [],
    25.00,
    customerName: 'Test Customer',
    source: source,
  );
  
  return PosOrder.fromOrder(
    order.copyWith(status: status),
    orderType: OrderType.takeaway,
  );
}

/// Helper to create test PosOrder with items
PosOrder _createTestPosOrderWithItems() {
  final items = [
    CartItem(
      id: 'item_1',
      productId: 'prod_1',
      productName: 'Pizza Margherita',
      price: 12.50,
      quantity: 2,
      imageUrl: '',
      selections: [
        OrderOptionSelection(
          optionGroupId: 'size',
          optionId: 'large',
          label: 'Grande',
          priceDelta: 200,
        ),
      ],
    ),
    CartItem(
      id: 'item_2',
      productId: 'prod_2',
      productName: 'Coca-Cola',
      price: 3.00,
      quantity: 1,
      imageUrl: '',
      selections: [],
    ),
  ];
  
  final order = Order.fromCart(
    items,
    27.50,
    customerName: 'Test Customer',
    source: 'client',
  );
  
  return PosOrder.fromOrder(
    order.copyWith(status: PosOrderStatus.paid),
    orderType: OrderType.takeaway,
  );
}
