// lib/src/services/payment/online_payment_provider.dart
/// 
/// Abstract interface for online payment providers
/// Allows for easy swapping between mock and real implementations
library;

import '../../models/order.dart';

/// Result of a payment attempt
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final PaymentIntent? paymentIntent;
  
  const PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    this.paymentIntent,
  });
  
  /// Factory for successful payment
  factory PaymentResult.success({
    required String transactionId,
    PaymentIntent? paymentIntent,
  }) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      paymentIntent: paymentIntent,
    );
  }
  
  /// Factory for failed payment
  factory PaymentResult.failure({
    required String errorMessage,
  }) {
    return PaymentResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Payment intent (mock structure similar to Stripe)
class PaymentIntent {
  final String id;
  final String status;
  final double amount;
  final String currency;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  
  const PaymentIntent({
    required this.id,
    required this.status,
    required this.amount,
    this.currency = 'eur',
    required this.createdAt,
    this.metadata,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'amount': amount,
    'currency': currency,
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
  };
  
  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      id: json['id'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'eur',
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Abstract payment provider interface
/// 
/// This interface defines the contract for all payment providers,
/// whether mock or real. Implementations must:
/// - Process payments for orders
/// - Return consistent PaymentResult objects
/// - Handle errors gracefully
abstract class OnlinePaymentProvider {
  /// Process a payment for the given order
  /// 
  /// Returns a PaymentResult indicating success or failure
  Future<PaymentResult> pay(Order order);
  
  /// Get the provider name (for logging/debugging)
  String get providerName;
}
