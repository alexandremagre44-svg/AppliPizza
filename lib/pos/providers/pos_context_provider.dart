/// POS Context Provider - manages the order context (Table/Sur place/À emporter)
/// 
/// This provider maintains the current order context state in the POS system.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pos_context.dart';

/// Provider for POS context state
final posContextProvider = StateNotifierProvider<PosContextNotifier, PosContext?>((ref) {
  return PosContextNotifier();
});

/// POS Context Notifier
class PosContextNotifier extends StateNotifier<PosContext?> {
  PosContextNotifier() : super(null);
  
  /// Set the order type (table, sur place, emporter)
  void setOrderType(PosOrderType type) {
    if (state == null) {
      state = PosContext(type: type);
    } else {
      state = state!.copyWith(type: type, tableNumber: null);
    }
  }
  
  /// Set table number (for table orders)
  void setTableNumber(int tableNumber) {
    if (state == null) {
      state = PosContext(
        type: PosOrderType.table,
        tableNumber: tableNumber,
      );
    } else {
      state = state!.copyWith(
        type: PosOrderType.table,
        tableNumber: tableNumber,
      );
    }
  }
  
  /// Set customer name (optional)
  void setCustomerName(String? customerName) {
    if (state != null) {
      state = state!.copyWith(customerName: customerName);
    }
  }
  
  /// Set full context
  void setContext(PosContext context) {
    state = context;
  }
  
  /// Clear context
  void clearContext() {
    state = null;
  }
  
  /// Check if current context is valid
  bool get isContextValid {
    return state != null && state!.isValid;
  }
}
