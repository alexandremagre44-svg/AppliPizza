// lib/src/services/payment/stripe_mock_provider.dart
/// 
/// Mock implementation of Stripe payment provider
/// NO real Stripe SDK or API calls - completely simulated
/// Can be replaced with real Stripe implementation later without refactoring
library;

import 'package:uuid/uuid.dart';
import '../../models/order.dart';
import 'online_payment_provider.dart';

const _uuid = Uuid();

/// Mock Stripe Payment Provider
/// 
/// IMPORTANT: This is a MOCK implementation
/// - NO real Stripe SDK imported
/// - NO real API calls made
/// - NO real payment processing
/// - Transaction IDs are fake but follow realistic format
/// 
/// This implementation is structurally identical to what a real
/// Stripe provider would be, allowing for easy replacement later.
class StripeMockProvider implements OnlinePaymentProvider {
  /// Control whether payments succeed or fail (for testing)
  final bool shouldSucceed;
  
  /// Simulated delay in milliseconds (to mimic API call)
  final int delayMs;
  
  /// Optional error message for failure scenarios
  final String? mockErrorMessage;
  
  const StripeMockProvider({
    this.shouldSucceed = true,
    this.delayMs = 1000,
    this.mockErrorMessage,
  });
  
  @override
  String get providerName => 'stripe_mock';
  
  @override
  Future<PaymentResult> pay(Order order) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: delayMs));
    
    // Validate order
    if (order.total <= 0) {
      return PaymentResult.failure(
        errorMessage: 'Le montant de la commande doit être supérieur à 0',
      );
    }
    
    // Simulate payment processing
    if (shouldSucceed) {
      return _processSuccessfulPayment(order);
    } else {
      return _processFailedPayment(order);
    }
  }
  
  /// Simulate successful payment
  PaymentResult _processSuccessfulPayment(Order order) {
    // Generate fake transaction ID (similar to Stripe format)
    final transactionId = 'pi_mock_${_uuid.v4().replaceAll('-', '')}';
    
    // Create mock payment intent
    final paymentIntent = PaymentIntent(
      id: transactionId,
      status: 'succeeded',
      amount: order.total,
      currency: 'eur',
      createdAt: DateTime.now(),
      metadata: {
        'orderId': order.id,
        'customerName': order.customerName,
        'source': 'mock',
      },
    );
    
    return PaymentResult.success(
      transactionId: transactionId,
      paymentIntent: paymentIntent,
    );
  }
  
  /// Simulate failed payment
  PaymentResult _processFailedPayment(Order order) {
    final errorMessage = mockErrorMessage ?? 
        'Paiement refusé - Carte bancaire invalide ou fonds insuffisants';
    
    return PaymentResult.failure(
      errorMessage: errorMessage,
    );
  }
}

/// Factory to create payment provider
/// This allows easy switching between mock and real implementations
class PaymentProviderFactory {
  /// Create a payment provider based on configuration
  /// 
  /// In production, this would check environment variables or
  /// configuration to decide whether to use mock or real Stripe
  static OnlinePaymentProvider create({
    bool useMock = true,
    bool mockShouldSucceed = true,
    int mockDelayMs = 1000,
    String? mockErrorMessage,
  }) {
    if (useMock) {
      return StripeMockProvider(
        shouldSucceed: mockShouldSucceed,
        delayMs: mockDelayMs,
        mockErrorMessage: mockErrorMessage,
      );
    }
    
    // TODO: When ready to integrate real Stripe, return real provider here
    // return StripeRealProvider(apiKey: ...);
    
    throw UnimplementedError(
      'Real Stripe provider not implemented yet. Use useMock: true',
    );
  }
}
