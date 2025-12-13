// lib/src/providers/customer_order_provider.dart
/// 
/// Provider for customer order state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/customer_order_service.dart';
import '../services/payment/stripe_mock_provider.dart';
import 'restaurant_provider.dart';

/// Provider for customer order service
final customerOrderServiceProvider = Provider<CustomerOrderService>((ref) {
  final appId = ref.watch(currentRestaurantProvider).id;
  
  // Create payment provider (mock for now)
  final paymentProvider = PaymentProviderFactory.create(
    useMock: true,
    mockShouldSucceed: true,
    mockDelayMs: 1000,
  );
  
  return CustomerOrderService(
    appId: appId,
    paymentProvider: paymentProvider,
  );
});

/// State for customer order process
class CustomerOrderState {
  final bool isProcessing;
  final String? orderId;
  final String? transactionId;
  final String? errorMessage;
  
  const CustomerOrderState({
    this.isProcessing = false,
    this.orderId,
    this.transactionId,
    this.errorMessage,
  });
  
  CustomerOrderState copyWith({
    bool? isProcessing,
    String? orderId,
    String? transactionId,
    String? errorMessage,
  }) {
    return CustomerOrderState(
      isProcessing: isProcessing ?? this.isProcessing,
      orderId: orderId ?? this.orderId,
      transactionId: transactionId ?? this.transactionId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// State notifier for customer order process
class CustomerOrderNotifier extends StateNotifier<CustomerOrderState> {
  final CustomerOrderService _service;
  
  CustomerOrderNotifier(this._service) : super(const CustomerOrderState());
  
  /// Reset state
  void reset() {
    state = const CustomerOrderState();
  }
  
  /// Get order status
  Future<void> refreshOrder(String orderId) async {
    final order = await _service.getOrderById(orderId);
    if (order != null) {
      state = state.copyWith(
        orderId: order.id,
        errorMessage: null,
      );
    }
  }
}

/// Provider for customer order state
final customerOrderStateProvider = 
    StateNotifierProvider<CustomerOrderNotifier, CustomerOrderState>((ref) {
  final service = ref.watch(customerOrderServiceProvider);
  return CustomerOrderNotifier(service);
});
