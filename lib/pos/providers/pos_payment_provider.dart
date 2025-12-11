/// POS Payment Provider - manages payment method selection
/// 
/// This provider maintains the selected payment method in the POS system.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pos_payment_method.dart';

/// Provider for POS payment method state
final posPaymentProvider = StateNotifierProvider<PosPaymentNotifier, PosPaymentMethod>((ref) {
  return PosPaymentNotifier();
});

/// POS Payment Notifier
class PosPaymentNotifier extends StateNotifier<PosPaymentMethod> {
  PosPaymentNotifier() : super(PosPaymentMethod.cash);
  
  /// Set the payment method
  void setPaymentMethod(PosPaymentMethod method) {
    state = method;
  }
  
  /// Reset to default payment method (cash)
  void reset() {
    state = PosPaymentMethod.cash;
  }
}
