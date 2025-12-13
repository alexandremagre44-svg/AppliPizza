// lib/src/screens/admin/pos/providers/pos_state_provider.dart
/// 
/// Central state provider for POS operations
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/order_type.dart';

/// POS operation state
class PosState {
  final String selectedOrderType;
  final String? tableNumber;
  final String? customerName;
  final String? notes;
  final bool isProcessingOrder;
  
  const PosState({
    this.selectedOrderType = OrderType.takeaway,
    this.tableNumber,
    this.customerName,
    this.notes,
    this.isProcessingOrder = false,
  });
  
  PosState copyWith({
    String? selectedOrderType,
    String? tableNumber,
    String? customerName,
    String? notes,
    bool? isProcessingOrder,
  }) {
    return PosState(
      selectedOrderType: selectedOrderType ?? this.selectedOrderType,
      tableNumber: tableNumber ?? this.tableNumber,
      customerName: customerName ?? this.customerName,
      notes: notes ?? this.notes,
      isProcessingOrder: isProcessingOrder ?? this.isProcessingOrder,
    );
  }
}

/// POS state notifier
class PosStateNotifier extends StateNotifier<PosState> {
  PosStateNotifier() : super(const PosState());
  
  /// Set order type
  void setOrderType(String orderType) {
    state = state.copyWith(selectedOrderType: orderType);
  }
  
  /// Set table number (for dine-in orders)
  void setTableNumber(String? tableNumber) {
    state = state.copyWith(tableNumber: tableNumber);
  }
  
  /// Set customer name
  void setCustomerName(String? name) {
    state = state.copyWith(customerName: name);
  }
  
  /// Set notes
  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }
  
  /// Start processing order
  void startProcessing() {
    state = state.copyWith(isProcessingOrder: true);
  }
  
  /// Complete processing order
  void completeProcessing() {
    state = state.copyWith(isProcessingOrder: false);
  }
  
  /// Reset state after order completion
  void reset() {
    state = const PosState();
  }
}

/// Provider for POS state
final posStateProvider = StateNotifierProvider<PosStateNotifier, PosState>((ref) {
  return PosStateNotifier();
});
