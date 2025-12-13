// lib/src/screens/admin/pos/providers/pos_payment_provider.dart
/// 
/// Provider for managing payment state in POS
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/payment_method.dart';

/// Payment state for POS
class PaymentState {
  final String method;
  final double? amountGiven; // For cash payments
  final double? change; // Calculated change for cash
  final bool isProcessing;
  final String? errorMessage;
  
  const PaymentState({
    required this.method,
    this.amountGiven,
    this.change,
    this.isProcessing = false,
    this.errorMessage,
  });
  
  PaymentState copyWith({
    String? method,
    double? amountGiven,
    double? change,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return PaymentState(
      method: method ?? this.method,
      amountGiven: amountGiven ?? this.amountGiven,
      change: change ?? this.change,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Payment state notifier
class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(const PaymentState(method: PaymentMethod.cash));
  
  /// Set payment method
  void setPaymentMethod(String method) {
    state = PaymentState(
      method: method,
      amountGiven: null,
      change: null,
    );
  }
  
  /// Set amount given for cash payment
  void setAmountGiven(double amount, double orderTotal) {
    final change = amount - orderTotal;
    state = state.copyWith(
      amountGiven: amount,
      change: change >= 0 ? change : null,
    );
  }
  
  /// Start payment processing
  void startProcessing() {
    state = state.copyWith(isProcessing: true, errorMessage: null);
  }
  
  /// Complete payment successfully
  void completePayment() {
    state = state.copyWith(isProcessing: false);
  }
  
  /// Fail payment with error
  void failPayment(String error) {
    state = state.copyWith(
      isProcessing: false,
      errorMessage: error,
    );
  }
  
  /// Reset payment state
  void reset() {
    state = const PaymentState(method: PaymentMethod.cash);
  }
  
  /// Validate payment
  bool validate(double orderTotal) {
    if (state.method == PaymentMethod.cash) {
      if (state.amountGiven == null || state.amountGiven! < orderTotal) {
        return false;
      }
    }
    return true;
  }
}

/// Provider for payment state
final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier();
});
