/// POS Order Provider - manages order creation and submission
/// 
/// This provider handles the creation of orders from the POS system,
/// including validation and submission to the kitchen/backend.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/pos_order.dart';
import '../models/pos_cart_item.dart';
import '../models/pos_context.dart';
import '../models/pos_payment_method.dart';
import 'pos_cart_provider.dart';
import 'pos_context_provider.dart';
import 'pos_payment_provider.dart';

const _uuid = Uuid();

/// State for order submission
class PosOrderState {
  final bool isSubmitting;
  final String? error;
  final PosOrder? lastOrder;
  
  const PosOrderState({
    this.isSubmitting = false,
    this.error,
    this.lastOrder,
  });
  
  PosOrderState copyWith({
    bool? isSubmitting,
    String? error,
    PosOrder? lastOrder,
  }) {
    return PosOrderState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      lastOrder: lastOrder ?? this.lastOrder,
    );
  }
}

/// Provider for POS order operations
final posOrderProvider = StateNotifierProvider<PosOrderNotifier, PosOrderState>((ref) {
  return PosOrderNotifier(ref);
});

/// POS Order Notifier
class PosOrderNotifier extends StateNotifier<PosOrderState> {
  final Ref ref;
  
  PosOrderNotifier(this.ref) : super(const PosOrderState());
  
  /// Submit the current cart as an order
  Future<PosOrder?> submitOrder({
    String? staffId,
    String? notes,
  }) async {
    // Get current state from providers
    final cart = ref.read(posCartProvider);
    final context = ref.read(posContextProvider);
    final paymentMethod = ref.read(posPaymentProvider);
    
    // Validate
    if (cart.isEmpty) {
      state = state.copyWith(error: 'Le panier est vide');
      return null;
    }
    
    if (context == null || !context.isValid) {
      state = state.copyWith(error: 'Contexte de commande invalide');
      return null;
    }
    
    // Set submitting state
    state = state.copyWith(isSubmitting: true, error: null);
    
    try {
      // Create order
      final order = PosOrder(
        id: _uuid.v4(),
        items: cart.items,
        context: context,
        paymentMethod: paymentMethod,
        total: cart.total,
        status: PosOrderStatus.submitted,
        createdAt: DateTime.now(),
        staffId: staffId,
        notes: notes,
      );
      
      // TODO: Send to kitchen via gateway (Step 7)
      // await ref.read(kitchenGatewayProvider).sendOrder(order);
      
      // TODO: Save to Firestore
      // await ref.read(firebaseOrderServiceProvider).createPosOrder(order);
      
      // Simulate delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update state with success
      state = state.copyWith(
        isSubmitting: false,
        lastOrder: order,
        error: null,
      );
      
      // Clear cart and reset context after successful submission
      ref.read(posCartProvider.notifier).clearCart();
      ref.read(posContextProvider.notifier).clearContext();
      ref.read(posPaymentProvider.notifier).reset();
      
      return order;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Erreur lors de la soumission: $e',
      );
      return null;
    }
  }
  
  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}
