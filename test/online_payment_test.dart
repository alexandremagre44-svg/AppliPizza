// test/online_payment_test.dart
/// Tests for online payment mock provider

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/order.dart';
import 'package:pizza_delizza/src/providers/cart_provider.dart';
import 'package:pizza_delizza/src/services/payment/online_payment_provider.dart';
import 'package:pizza_delizza/src/services/payment/stripe_mock_provider.dart';

void main() {
  group('Online Payment Provider Tests', () {
    
    test('StripeMockProvider should process successful payment', () async {
      // Arrange
      final provider = StripeMockProvider(shouldSucceed: true, delayMs: 100);
      final order = _createTestOrder(total: 25.50);
      
      // Act
      final result = await provider.pay(order);
      
      // Assert
      expect(result.success, isTrue);
      expect(result.transactionId, isNotNull);
      expect(result.transactionId!.startsWith('pi_mock_'), isTrue);
      expect(result.paymentIntent, isNotNull);
      expect(result.paymentIntent!.amount, equals(25.50));
      expect(result.paymentIntent!.status, equals('succeeded'));
      expect(result.errorMessage, isNull);
    });
    
    test('StripeMockProvider should process failed payment', () async {
      // Arrange
      final provider = StripeMockProvider(
        shouldSucceed: false,
        delayMs: 100,
        mockErrorMessage: 'Carte refusée',
      );
      final order = _createTestOrder(total: 30.00);
      
      // Act
      final result = await provider.pay(order);
      
      // Assert
      expect(result.success, isFalse);
      expect(result.transactionId, isNull);
      expect(result.paymentIntent, isNull);
      expect(result.errorMessage, equals('Carte refusée'));
    });
    
    test('StripeMockProvider should reject zero amount', () async {
      // Arrange
      final provider = StripeMockProvider(shouldSucceed: true, delayMs: 100);
      final order = _createTestOrder(total: 0.0);
      
      // Act
      final result = await provider.pay(order);
      
      // Assert
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('montant'));
    });
    
    test('StripeMockProvider should have correct provider name', () {
      // Arrange
      final provider = StripeMockProvider();
      
      // Assert
      expect(provider.providerName, equals('stripe_mock'));
    });
    
    test('PaymentIntent should serialize to JSON correctly', () {
      // Arrange
      final now = DateTime.now();
      final intent = PaymentIntent(
        id: 'pi_test_123',
        status: 'succeeded',
        amount: 42.50,
        currency: 'eur',
        createdAt: now,
        metadata: {'orderId': 'order_123'},
      );
      
      // Act
      final json = intent.toJson();
      final restored = PaymentIntent.fromJson(json);
      
      // Assert
      expect(restored.id, equals(intent.id));
      expect(restored.status, equals(intent.status));
      expect(restored.amount, equals(intent.amount));
      expect(restored.currency, equals(intent.currency));
      expect(restored.metadata?['orderId'], equals('order_123'));
    });
    
    test('PaymentProviderFactory should create mock provider', () {
      // Act
      final provider = PaymentProviderFactory.create(useMock: true);
      
      // Assert
      expect(provider, isA<StripeMockProvider>());
      expect(provider.providerName, equals('stripe_mock'));
    });
    
    test('PaymentProviderFactory should throw for real provider', () {
      // Assert
      expect(
        () => PaymentProviderFactory.create(useMock: false),
        throwsA(isA<UnimplementedError>()),
      );
    });
    
    test('PaymentResult.success factory should create valid result', () {
      // Arrange
      final intent = PaymentIntent(
        id: 'pi_123',
        status: 'succeeded',
        amount: 100.0,
        createdAt: DateTime.now(),
      );
      
      // Act
      final result = PaymentResult.success(
        transactionId: 'txn_123',
        paymentIntent: intent,
      );
      
      // Assert
      expect(result.success, isTrue);
      expect(result.transactionId, equals('txn_123'));
      expect(result.paymentIntent, equals(intent));
      expect(result.errorMessage, isNull);
    });
    
    test('PaymentResult.failure factory should create valid result', () {
      // Act
      final result = PaymentResult.failure(
        errorMessage: 'Payment declined',
      );
      
      // Assert
      expect(result.success, isFalse);
      expect(result.transactionId, isNull);
      expect(result.paymentIntent, isNull);
      expect(result.errorMessage, equals('Payment declined'));
    });
  });
}

/// Helper to create test order
Order _createTestOrder({required double total}) {
  final items = [
    CartItem(
      id: 'item_1',
      productId: 'prod_1',
      productName: 'Pizza Margherita',
      price: total,
      quantity: 1,
      imageUrl: '',
      selections: [],
    ),
  ];
  
  return Order.fromCart(
    items,
    total,
    customerName: 'Test Customer',
    customerEmail: 'test@example.com',
  );
}
