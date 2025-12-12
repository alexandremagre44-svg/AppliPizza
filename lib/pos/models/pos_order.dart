/// POS Order - represents a complete order from the POS system
/// 
/// This model contains all information about a POS order including
/// items, context, payment method, and timestamps.
library;

import 'pos_cart_item.dart';
import 'pos_context.dart';
import 'pos_payment_method.dart';

/// POS Order status
enum PosOrderStatus {
  /// Order is pending/not yet submitted
  pending,
  
  /// Order has been submitted and is being prepared
  submitted,
  
  /// Order is ready for pickup/serving
  ready,
  
  /// Order has been completed/delivered
  completed,
  
  /// Order was cancelled
  cancelled,
}

/// POS Order model
class PosOrder {
  /// Unique order ID
  final String id;
  
  /// Order items
  final List<PosCartItem> items;
  
  /// Order context (table, sur place, emporter)
  final PosContext context;
  
  /// Payment method
  final PosPaymentMethod paymentMethod;
  
  /// Total amount
  final double total;
  
  /// Order status
  final PosOrderStatus status;
  
  /// Order creation timestamp
  final DateTime createdAt;
  
  /// Last update timestamp
  final DateTime? updatedAt;
  
  /// Staff member who took the order (optional)
  final String? staffId;
  
  /// Additional notes/comments
  final String? notes;
  
  const PosOrder({
    required this.id,
    required this.items,
    required this.context,
    required this.paymentMethod,
    required this.total,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.staffId,
    this.notes,
  });
  
  /// Create a copy with modified fields
  PosOrder copyWith({
    String? id,
    List<PosCartItem>? items,
    PosContext? context,
    PosPaymentMethod? paymentMethod,
    double? total,
    PosOrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? staffId,
    String? notes,
  }) {
    return PosOrder(
      id: id ?? this.id,
      items: items ?? this.items,
      context: context ?? this.context,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      staffId: staffId ?? this.staffId,
      notes: notes ?? this.notes,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'context': context.toJson(),
      'paymentMethod': paymentMethod.code,
      'total': total,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'staffId': staffId,
      'notes': notes,
    };
  }
  
  /// Create from JSON
  factory PosOrder.fromJson(Map<String, dynamic> json) {
    return PosOrder(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => PosCartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      context: PosContext.fromJson(json['context'] as Map<String, dynamic>),
      paymentMethod: PosPaymentMethodX.fromCode(json['paymentMethod'] as String),
      total: (json['total'] as num).toDouble(),
      status: PosOrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PosOrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      staffId: json['staffId'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
