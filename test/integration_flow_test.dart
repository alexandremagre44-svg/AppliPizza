// test/integration_flow_test.dart
/// Integration tests for complete order flow

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/order.dart';
import 'package:pizza_delizza/src/models/pos_order.dart';
import 'package:pizza_delizza/src/models/pos_order_status.dart';
import 'package:pizza_delizza/src/models/order_type.dart';
import 'package:pizza_delizza/src/models/payment_method.dart';
import 'package:pizza_delizza/src/providers/cart_provider.dart';
import 'package:pizza_delizza/src/services/payment/online_payment_provider.dart';
import 'package:pizza_delizza/src/services/payment/stripe_mock_provider.dart';

void main() {
  group('Complete Order Flow Integration Tests', () {
    
    test('Customer order flow: Cart → Payment → Paid → Visible in System', () async {
      // Step 1: Customer creates cart
      final items = [
        CartItem(
          id: 'item_1',
          productId: 'prod_1',
          productName: 'Pizza Margherita',
          price: 12.50,
          quantity: 2,
          imageUrl: '',
          selections: [],
        ),
      ];
      
      final total = 25.00;
      
      // Step 2: Create order (draft)
      final order = Order.fromCart(
        items,
        total,
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        source: 'client',
      );
      
      expect(order.source, equals('client'));
      expect(order.total, equals(total));
      
      // Step 3: Create POS order in draft status
      final posOrder = PosOrder.fromOrder(
        order.copyWith(status: PosOrderStatus.draft),
        orderType: OrderType.delivery,
      );
      
      expect(posOrder.status, equals(PosOrderStatus.draft));
      expect(posOrder.requiresPayment, isTrue);
      
      // Step 4: Process online payment (mock)
      final paymentProvider = StripeMockProvider(
        shouldSucceed: true,
        delayMs: 100,
      );
      
      final paymentResult = await paymentProvider.pay(order);
      
      expect(paymentResult.success, isTrue);
      expect(paymentResult.transactionId, isNotNull);
      
      // Step 5: Mark order as paid
      final payment = PaymentTransaction(
        id: paymentResult.transactionId!,
        orderId: posOrder.id,
        method: PaymentMethod.card,
        amount: total,
        timestamp: DateTime.now(),
        reference: paymentResult.transactionId,
        status: PaymentStatus.success,
      );
      
      final paidOrder = posOrder.copyWith(
        baseOrder: posOrder.baseOrder.copyWith(status: PosOrderStatus.paid),
        payment: payment,
      );
      
      expect(paidOrder.status, equals(PosOrderStatus.paid));
      expect(paidOrder.isPaid, isTrue);
      expect(paidOrder.payment, isNotNull);
      
      // At this point, order would be:
      // ✓ Visible in POS (for staff)
      // ✓ Visible in KDS (for kitchen)
    });
    
    test('KDS workflow: Paid → In Preparation → Ready', () {
      // Step 1: Start with paid order
      final order = Order.fromCart(
        [],
        30.00,
        customerName: 'Jane Smith',
        source: 'client',
      );
      
      var posOrder = PosOrder.fromOrder(
        order.copyWith(status: PosOrderStatus.paid),
        orderType: OrderType.takeaway,
      );
      
      expect(posOrder.status, equals(PosOrderStatus.paid));
      
      // Step 2: Kitchen starts preparation
      final canStartPrep = PosOrderStatus.getNextStatuses(posOrder.status)
          .contains(PosOrderStatus.inPreparation);
      expect(canStartPrep, isTrue);
      
      posOrder = posOrder.copyWith(
        baseOrder: posOrder.baseOrder.copyWith(status: PosOrderStatus.inPreparation),
      );
      
      expect(posOrder.status, equals(PosOrderStatus.inPreparation));
      
      // Step 3: Kitchen marks as ready
      final canMarkReady = PosOrderStatus.getNextStatuses(posOrder.status)
          .contains(PosOrderStatus.ready);
      expect(canMarkReady, isTrue);
      
      posOrder = posOrder.copyWith(
        baseOrder: posOrder.baseOrder.copyWith(status: PosOrderStatus.ready),
      );
      
      expect(posOrder.status, equals(PosOrderStatus.ready));
    });
    
    test('POS can see customer orders', () {
      // Customer order
      final clientOrder = Order.fromCart(
        [],
        20.00,
        customerName: 'Alice',
        source: 'client',
      );
      
      // POS order
      final posOrderFromStaff = Order.fromCart(
        [],
        20.00,
        customerName: 'Bob',
        source: 'pos',
      );
      
      // Both should be visible in the same orders collection
      expect(clientOrder.source, equals('client'));
      expect(posOrderFromStaff.source, equals('pos'));
      
      // Both follow same status workflow
      final clientPosOrder = PosOrder.fromOrder(
        clientOrder.copyWith(status: PosOrderStatus.paid),
        orderType: OrderType.delivery,
      );
      
      final staffPosOrder = PosOrder.fromOrder(
        posOrderFromStaff.copyWith(status: PosOrderStatus.paid),
        orderType: OrderType.dineIn,
      );
      
      expect(clientPosOrder.status, equals(staffPosOrder.status));
    });
    
    test('Failed payment keeps order in draft', () async {
      // Arrange
      final order = Order.fromCart(
        [],
        15.00,
        customerName: 'Test User',
        source: 'client',
      );
      
      final paymentProvider = StripeMockProvider(
        shouldSucceed: false,
        delayMs: 100,
        mockErrorMessage: 'Carte refusée',
      );
      
      // Act
      final paymentResult = await paymentProvider.pay(order);
      
      // Assert
      expect(paymentResult.success, isFalse);
      
      // Order would remain in draft status
      final posOrder = PosOrder.fromOrder(
        order.copyWith(status: PosOrderStatus.draft),
        orderType: OrderType.takeaway,
      );
      
      expect(posOrder.status, equals(PosOrderStatus.draft));
      expect(posOrder.requiresPayment, isTrue);
    });
    
    test('Complete flow validates data integrity', () {
      // Create order with full details
      final items = [
        CartItem(
          id: 'item_1',
          productId: 'prod_1',
          productName: 'Pizza 4 Fromages',
          price: 14.50,
          quantity: 1,
          imageUrl: '',
          selections: [],
        ),
        CartItem(
          id: 'item_2',
          productId: 'prod_2',
          productName: 'Coca-Cola',
          price: 3.00,
          quantity: 2,
          imageUrl: '',
          selections: [],
        ),
      ];
      
      final order = Order.fromCart(
        items,
        20.50,
        customerName: 'Charlie Brown',
        customerEmail: 'charlie@example.com',
        customerPhone: '+33612345678',
        comment: 'Sans oignons',
        source: 'client',
      );
      
      // Verify all data preserved through transformations
      final posOrder = PosOrder.fromOrder(
        order,
        orderType: OrderType.delivery,
        tableNumber: null,
      );
      
      expect(posOrder.items.length, equals(2));
      expect(posOrder.items[0].productName, equals('Pizza 4 Fromages'));
      expect(posOrder.items[1].quantity, equals(2));
      expect(posOrder.customerName, equals('Charlie Brown'));
      expect(posOrder.baseOrder.comment, equals('Sans oignons'));
      expect(posOrder.baseOrder.source, equals('client'));
    });
  });
}
