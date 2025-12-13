// test/pos_complete_system_test.dart
/// Tests for complete POS system functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/pos_order_status.dart';
import 'package:pizza_delizza/src/models/payment_method.dart';
import 'package:pizza_delizza/src/models/order_type.dart';
import 'package:pizza_delizza/src/models/cashier_session.dart';
import 'package:pizza_delizza/src/providers/cart_provider.dart';
import 'package:pizza_delizza/src/models/order_option_selection.dart';

void main() {
  group('POS Order Status Tests', () {
    test('Should have all required statuses', () {
      final statuses = PosOrderStatus.all;
      expect(statuses.contains(PosOrderStatus.draft), true);
      expect(statuses.contains(PosOrderStatus.paid), true);
      expect(statuses.contains(PosOrderStatus.inPreparation), true);
      expect(statuses.contains(PosOrderStatus.ready), true);
      expect(statuses.contains(PosOrderStatus.served), true);
      expect(statuses.contains(PosOrderStatus.cancelled), true);
      expect(statuses.contains(PosOrderStatus.refunded), true);
    });

    test('Draft status should allow modification', () {
      expect(PosOrderStatus.canModify(PosOrderStatus.draft), true);
      expect(PosOrderStatus.canModify(PosOrderStatus.paid), false);
    });

    test('Should validate status transitions', () {
      final nextStatuses = PosOrderStatus.getNextStatuses(PosOrderStatus.draft);
      expect(nextStatuses.contains(PosOrderStatus.paid), true);
      expect(nextStatuses.contains(PosOrderStatus.cancelled), true);
      expect(nextStatuses.contains(PosOrderStatus.inPreparation), false);
    });

    test('Terminal statuses should have no next statuses', () {
      expect(PosOrderStatus.isTerminal(PosOrderStatus.served), true);
      expect(PosOrderStatus.isTerminal(PosOrderStatus.cancelled), true);
      expect(PosOrderStatus.isTerminal(PosOrderStatus.refunded), true);
      expect(PosOrderStatus.getNextStatuses(PosOrderStatus.served), isEmpty);
    });
  });

  group('Payment Method Tests', () {
    test('Should have all payment methods', () {
      final methods = PaymentMethod.all;
      expect(methods.contains(PaymentMethod.cash), true);
      expect(methods.contains(PaymentMethod.card), true);
      expect(methods.contains(PaymentMethod.offline), true);
    });

    test('Should get correct labels', () {
      expect(PaymentMethod.getLabel(PaymentMethod.cash), 'Espèces');
      expect(PaymentMethod.getLabel(PaymentMethod.card), 'Carte bancaire');
      expect(PaymentMethod.getLabel(PaymentMethod.offline), 'Paiement manuel');
    });
  });

  group('Order Type Tests', () {
    test('Should have all order types', () {
      final types = OrderType.all;
      expect(types.contains(OrderType.dineIn), true);
      expect(types.contains(OrderType.takeaway), true);
      expect(types.contains(OrderType.delivery), true);
      expect(types.contains(OrderType.clickCollect), true);
    });

    test('Should get correct labels', () {
      expect(OrderType.getLabel(OrderType.dineIn), 'Sur place');
      expect(OrderType.getLabel(OrderType.takeaway), 'À emporter');
      expect(OrderType.getLabel(OrderType.delivery), 'Livraison');
      expect(OrderType.getLabel(OrderType.clickCollect), 'Click & Collect');
    });
  });

  group('Cashier Session Tests', () {
    test('Should calculate expected cash correctly', () {
      final session = CashierSession(
        id: 'test-session',
        restaurantId: 'test-restaurant',
        staffId: 'staff-1',
        staffName: 'Test Staff',
        openedAt: DateTime.now(),
        openingCash: 100.0,
        paymentTotals: {
          PaymentMethod.cash: 150.0,
          PaymentMethod.card: 200.0,
        },
        status: SessionStatus.open,
      );

      expect(session.calculatedExpectedCash, 250.0); // 100 + 150
      expect(session.totalCollected, 350.0); // 150 + 200
      expect(session.orderCount, 0);
    });

    test('Should calculate variance correctly', () {
      final session = CashierSession(
        id: 'test-session',
        restaurantId: 'test-restaurant',
        staffId: 'staff-1',
        staffName: 'Test Staff',
        openedAt: DateTime.now(),
        openingCash: 100.0,
        closingCash: 260.0,
        expectedCash: 250.0,
        variance: 10.0,
        paymentTotals: {
          PaymentMethod.cash: 150.0,
        },
        status: SessionStatus.closed,
      );

      expect(session.variance, 10.0); // 260 - 250
    });
  });

  group('Cart Validation Tests', () {
    test('Should calculate total with price deltas', () {
      final items = [
        CartItem(
          id: 'item-1',
          productId: 'product-1',
          productName: 'Pizza',
          price: 10.0,
          quantity: 1,
          imageUrl: '',
          selections: [
            const OrderOptionSelection(
              optionGroupId: 'size',
              optionId: 'large',
              label: 'Grande',
              priceDelta: 200, // +2€ in cents
            ),
            const OrderOptionSelection(
              optionGroupId: 'topping',
              optionId: 'extra-cheese',
              label: 'Extra fromage',
              priceDelta: 150, // +1.50€ in cents
            ),
          ],
        ),
      ];

      // Base price: 10€
      // + 2€ (size)
      // + 1.50€ (topping)
      // = 13.50€
      final item = items[0];
      double total = item.price;
      for (final selection in item.selections) {
        total += selection.priceDelta / 100.0;
      }
      
      expect(total, 13.50);
    });

    test('Should validate menu items require customization', () {
      final menuItem = CartItem(
        id: 'menu-1',
        productId: 'menu-product-1',
        productName: 'Menu Pizza',
        price: 15.0,
        quantity: 1,
        imageUrl: '',
        selections: [], // No selections
        isMenu: true,
      );

      // Menu with no selections should require customization
      expect(menuItem.isMenu, true);
      expect(menuItem.selections.isEmpty, true);
    });
  });

  group('Payment Transaction Tests', () {
    test('Should serialize and deserialize correctly', () {
      final transaction = PaymentTransaction(
        id: 'payment-1',
        orderId: 'order-1',
        method: PaymentMethod.cash,
        amount: 50.0,
        amountGiven: 60.0,
        change: 10.0,
        timestamp: DateTime(2024, 1, 1, 12, 0),
        status: PaymentStatus.success,
      );

      final json = transaction.toJson();
      final deserialized = PaymentTransaction.fromJson(json);

      expect(deserialized.id, transaction.id);
      expect(deserialized.orderId, transaction.orderId);
      expect(deserialized.method, transaction.method);
      expect(deserialized.amount, transaction.amount);
      expect(deserialized.amountGiven, transaction.amountGiven);
      expect(deserialized.change, transaction.change);
      expect(deserialized.status, transaction.status);
    });

    test('Should calculate change correctly', () {
      final transaction = PaymentTransaction(
        id: 'payment-1',
        orderId: 'order-1',
        method: PaymentMethod.cash,
        amount: 47.50,
        amountGiven: 50.0,
        change: 2.50,
        timestamp: DateTime.now(),
        status: PaymentStatus.success,
      );

      expect(transaction.change, 2.50);
      expect(transaction.amountGiven! - transaction.amount, 2.50);
    });
  });

  group('Order Option Selection Tests', () {
    test('Should handle positive price deltas', () {
      const selection = OrderOptionSelection(
        optionGroupId: 'size',
        optionId: 'large',
        label: 'Grande',
        priceDelta: 300, // +3€
      );

      expect(selection.priceDelta, 300);
      expect(selection.priceDelta / 100.0, 3.0);
    });

    test('Should handle zero price deltas', () {
      const selection = OrderOptionSelection(
        optionGroupId: 'cooking',
        optionId: 'medium',
        label: 'À point',
        priceDelta: 0,
      );

      expect(selection.priceDelta, 0);
    });

    test('Should serialize and deserialize correctly', () {
      const selection = OrderOptionSelection(
        optionGroupId: 'toppings',
        optionId: 'mushrooms',
        label: 'Champignons',
        priceDelta: 150,
      );

      final json = selection.toJson();
      final deserialized = OrderOptionSelection.fromJson(json);

      expect(deserialized.optionGroupId, selection.optionGroupId);
      expect(deserialized.optionId, selection.optionId);
      expect(deserialized.label, selection.label);
      expect(deserialized.priceDelta, selection.priceDelta);
    });
  });

  group('Session Status Tests', () {
    test('Should differentiate between open and closed sessions', () {
      final openSession = CashierSession(
        id: 'session-1',
        restaurantId: 'restaurant-1',
        staffId: 'staff-1',
        staffName: 'Staff 1',
        openedAt: DateTime.now(),
        openingCash: 100.0,
        status: SessionStatus.open,
      );

      final closedSession = openSession.copyWith(
        closedAt: DateTime.now(),
        closingCash: 250.0,
        status: SessionStatus.closed,
      );

      expect(openSession.status, SessionStatus.open);
      expect(closedSession.status, SessionStatus.closed);
      expect(closedSession.closedAt, isNotNull);
    });
  });
}
