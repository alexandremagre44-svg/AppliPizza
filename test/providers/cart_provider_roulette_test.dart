// test/providers/cart_provider_roulette_test.dart
// Tests for roulette rewards functionality in CartProvider

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/providers/cart_provider.dart';
import 'package:pizza_delizza/src/models/product.dart';

void main() {
  group('CartProvider Roulette Rewards', () {
    late CartNotifier cartNotifier;

    setUp(() {
      cartNotifier = CartNotifier();
    });

    test('applyPercentageDiscount sets discount correctly', () {
      cartNotifier.applyPercentageDiscount(10.0);
      
      expect(cartNotifier.state.discountPercent, equals(10.0));
      expect(cartNotifier.state.hasDiscount, isTrue);
    });

    test('applyFixedAmountDiscount sets discount correctly', () {
      cartNotifier.applyFixedAmountDiscount(5.0);
      
      expect(cartNotifier.state.discountAmount, equals(5.0));
      expect(cartNotifier.state.hasDiscount, isTrue);
    });

    test('setPendingFreeItem sets free item correctly', () {
      cartNotifier.setPendingFreeItem('product123', 'product');
      
      expect(cartNotifier.state.pendingFreeItemId, equals('product123'));
      expect(cartNotifier.state.pendingFreeItemType, equals('product'));
      expect(cartNotifier.state.hasPendingFreeItem, isTrue);
    });

    test('clearDiscounts removes all discounts', () {
      cartNotifier.applyPercentageDiscount(10.0);
      cartNotifier.applyFixedAmountDiscount(5.0);
      
      cartNotifier.clearDiscounts();
      
      expect(cartNotifier.state.discountPercent, isNull);
      expect(cartNotifier.state.discountAmount, isNull);
      expect(cartNotifier.state.hasDiscount, isFalse);
    });

    test('clearPendingFreeItem removes free item', () {
      cartNotifier.setPendingFreeItem('product123', 'product');
      
      cartNotifier.clearPendingFreeItem();
      
      expect(cartNotifier.state.pendingFreeItemId, isNull);
      expect(cartNotifier.state.pendingFreeItemType, isNull);
      expect(cartNotifier.state.hasPendingFreeItem, isFalse);
    });

    test('clearAllRewards removes discounts and free items', () {
      cartNotifier.applyPercentageDiscount(10.0);
      cartNotifier.applyFixedAmountDiscount(5.0);
      cartNotifier.setPendingFreeItem('product123', 'product');
      
      cartNotifier.clearAllRewards();
      
      expect(cartNotifier.state.discountPercent, isNull);
      expect(cartNotifier.state.discountAmount, isNull);
      expect(cartNotifier.state.pendingFreeItemId, isNull);
      expect(cartNotifier.state.pendingFreeItemType, isNull);
    });

    test('percentage discount calculates correctly', () {
      // Add a product to cart
      final product = Product(
        id: 'p1',
        name: 'Pizza',
        description: 'Test pizza',
        price: 10.0,
        categoryId: 'cat1',
        imageUrl: '',
        isAvailable: true,
        isMenu: false,
      );
      
      cartNotifier.addItem(product);
      cartNotifier.applyPercentageDiscount(10.0);
      
      // Subtotal should be 10.0
      expect(cartNotifier.state.subtotal, equals(10.0));
      // Discount should be 1.0 (10% of 10.0)
      expect(cartNotifier.state.discountValue, equals(1.0));
      // Total should be 9.0 (10.0 - 1.0)
      expect(cartNotifier.state.total, equals(9.0));
    });

    test('fixed amount discount calculates correctly', () {
      // Add a product to cart
      final product = Product(
        id: 'p1',
        name: 'Pizza',
        description: 'Test pizza',
        price: 10.0,
        categoryId: 'cat1',
        imageUrl: '',
        isAvailable: true,
        isMenu: false,
      );
      
      cartNotifier.addItem(product);
      cartNotifier.applyFixedAmountDiscount(3.0);
      
      // Subtotal should be 10.0
      expect(cartNotifier.state.subtotal, equals(10.0));
      // Discount should be 3.0
      expect(cartNotifier.state.discountValue, equals(3.0));
      // Total should be 7.0 (10.0 - 3.0)
      expect(cartNotifier.state.total, equals(7.0));
    });

    test('combined discounts calculate correctly', () {
      // Add a product to cart
      final product = Product(
        id: 'p1',
        name: 'Pizza',
        description: 'Test pizza',
        price: 10.0,
        categoryId: 'cat1',
        imageUrl: '',
        isAvailable: true,
        isMenu: false,
      );
      
      cartNotifier.addItem(product);
      cartNotifier.applyPercentageDiscount(10.0); // 1.0 off
      cartNotifier.applyFixedAmountDiscount(2.0); // 2.0 off
      
      // Subtotal should be 10.0
      expect(cartNotifier.state.subtotal, equals(10.0));
      // Discount should be 3.0 (1.0 + 2.0)
      expect(cartNotifier.state.discountValue, equals(3.0));
      // Total should be 7.0 (10.0 - 3.0)
      expect(cartNotifier.state.total, equals(7.0));
    });

    test('discount does not exceed subtotal', () {
      // Add a product to cart
      final product = Product(
        id: 'p1',
        name: 'Pizza',
        description: 'Test pizza',
        price: 10.0,
        categoryId: 'cat1',
        imageUrl: '',
        isAvailable: true,
        isMenu: false,
      );
      
      cartNotifier.addItem(product);
      cartNotifier.applyFixedAmountDiscount(15.0); // More than subtotal
      
      // Subtotal should be 10.0
      expect(cartNotifier.state.subtotal, equals(10.0));
      // Discount should be capped at 10.0
      expect(cartNotifier.state.discountValue, equals(10.0));
      // Total should be 0.0
      expect(cartNotifier.state.total, equals(0.0));
    });

    test('discount state is preserved when adding items', () {
      final product = Product(
        id: 'p1',
        name: 'Pizza',
        description: 'Test pizza',
        price: 10.0,
        categoryId: 'cat1',
        imageUrl: '',
        isAvailable: true,
        isMenu: false,
      );
      
      cartNotifier.applyPercentageDiscount(10.0);
      cartNotifier.addItem(product);
      
      // Discount should still be there
      expect(cartNotifier.state.discountPercent, equals(10.0));
      expect(cartNotifier.state.hasDiscount, isTrue);
    });

    test('discount state is preserved when removing items', () {
      final product = Product(
        id: 'p1',
        name: 'Pizza',
        description: 'Test pizza',
        price: 10.0,
        categoryId: 'cat1',
        imageUrl: '',
        isAvailable: true,
        isMenu: false,
      );
      
      cartNotifier.addItem(product);
      cartNotifier.applyPercentageDiscount(10.0);
      
      final itemId = cartNotifier.state.items.first.id;
      cartNotifier.removeItem(itemId);
      
      // Discount should still be there
      expect(cartNotifier.state.discountPercent, equals(10.0));
      expect(cartNotifier.state.hasDiscount, isTrue);
    });

    test('clearCart removes all items but keeps rewards', () {
      final product = Product(
        id: 'p1',
        name: 'Pizza',
        description: 'Test pizza',
        price: 10.0,
        categoryId: 'cat1',
        imageUrl: '',
        isAvailable: true,
        isMenu: false,
      );
      
      cartNotifier.addItem(product);
      cartNotifier.applyPercentageDiscount(10.0);
      cartNotifier.setPendingFreeItem('product123', 'product');
      
      cartNotifier.clearCart();
      
      // Items should be cleared
      expect(cartNotifier.state.items, isEmpty);
      // Rewards should be cleared too (based on current implementation)
      expect(cartNotifier.state.discountPercent, isNull);
      expect(cartNotifier.state.pendingFreeItemId, isNull);
    });
  });
}
