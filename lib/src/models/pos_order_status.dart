// lib/src/models/pos_order_status.dart
/// 
/// Complete POS Order Status workflow model
/// Defines all possible order states in the POS system
library;

/// POS Order Status - Complete workflow for restaurant operations
class PosOrderStatus {
  /// Draft - Order is being built in the cart (not yet paid)
  static const String draft = 'draft';
  
  /// Paid - Payment has been received and validated
  static const String paid = 'paid';
  
  /// In Preparation - Order is being prepared in the kitchen
  static const String inPreparation = 'in_preparation';
  
  /// Ready - Order is ready for pickup/delivery/service
  static const String ready = 'ready';
  
  /// Served/Completed - Order has been delivered to customer
  static const String served = 'served';
  
  /// Cancelled - Order was cancelled (before or after payment)
  static const String cancelled = 'cancelled';
  
  /// Refunded - Order was paid but refunded to customer
  static const String refunded = 'refunded';
  
  /// All possible statuses
  static List<String> get all => [
    draft,
    paid,
    inPreparation,
    ready,
    served,
    cancelled,
    refunded,
  ];
  
  /// Get display label for status
  static String getLabel(String status) {
    switch (status) {
      case draft:
        return 'Brouillon';
      case paid:
        return 'Payée';
      case inPreparation:
        return 'En préparation';
      case ready:
        return 'Prête';
      case served:
        return 'Servie';
      case cancelled:
        return 'Annulée';
      case refunded:
        return 'Remboursée';
      default:
        return status;
    }
  }
  
  /// Get icon for status
  static String getIcon(String status) {
    switch (status) {
      case draft:
        return 'edit';
      case paid:
        return 'payment';
      case inPreparation:
        return 'restaurant';
      case ready:
        return 'check_circle';
      case served:
        return 'done_all';
      case cancelled:
        return 'cancel';
      case refunded:
        return 'currency_exchange';
      default:
        return 'info';
    }
  }
  
  /// Check if status allows modification
  static bool canModify(String status) {
    return status == draft;
  }
  
  /// Check if status allows cancellation
  static bool canCancel(String status) {
    return status == draft || status == paid || status == inPreparation;
  }
  
  /// Check if status allows refund
  static bool canRefund(String status) {
    return status == paid || status == inPreparation || status == ready;
  }
  
  /// Get next possible statuses
  static List<String> getNextStatuses(String currentStatus) {
    switch (currentStatus) {
      case draft:
        return [paid, cancelled];
      case paid:
        return [inPreparation, cancelled, refunded];
      case inPreparation:
        return [ready, cancelled, refunded];
      case ready:
        return [served, refunded];
      case served:
        return []; // Terminal state
      case cancelled:
        return []; // Terminal state
      case refunded:
        return []; // Terminal state
      default:
        return [];
    }
  }
  
  /// Check if status is terminal (no further transitions)
  static bool isTerminal(String status) {
    return status == served || status == cancelled || status == refunded;
  }
  
  /// Check if order requires payment
  static bool requiresPayment(String status) {
    return status == draft;
  }
}
