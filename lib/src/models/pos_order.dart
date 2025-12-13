// lib/src/models/pos_order.dart
/// 
/// POS-specific order model extending the base Order model
/// Adds POS-specific fields like order type, session ID, payment details
library;

import 'order.dart';
import 'pos_order_status.dart';
import 'order_type.dart';
import 'payment_method.dart';
import '../providers/cart_provider.dart';

/// Extended order model for POS operations
class PosOrder {
  final Order baseOrder;
  final String orderType; // dine_in, takeaway, delivery, click_collect
  final String? sessionId; // Link to cashier session
  final String? tableNumber; // For dine-in orders
  final PaymentTransaction? payment;
  final String? cancellationReason; // Required for cancelled orders
  final String? refundReason; // Required for refunded orders
  final String? staffNotes; // Internal notes
  
  const PosOrder({
    required this.baseOrder,
    required this.orderType,
    this.sessionId,
    this.tableNumber,
    this.payment,
    this.cancellationReason,
    this.refundReason,
    this.staffNotes,
  });
  
  /// Quick accessors to base order fields
  String get id => baseOrder.id;
  double get total => baseOrder.total;
  DateTime get date => baseOrder.date;
  List<CartItem> get items => baseOrder.items;
  String get status => baseOrder.status;
  String? get customerName => baseOrder.customerName;
  
  /// Check if order can be modified
  bool get canModify => PosOrderStatus.canModify(status);
  
  /// Check if order can be cancelled
  bool get canCancel => PosOrderStatus.canCancel(status);
  
  /// Check if order can be refunded
  bool get canRefund => PosOrderStatus.canRefund(status);
  
  /// Check if order requires payment
  bool get requiresPayment => PosOrderStatus.requiresPayment(status);
  
  /// Check if order is paid
  bool get isPaid => status != PosOrderStatus.draft && payment != null;
  
  /// Factory to create from base Order
  factory PosOrder.fromOrder(
    Order order, {
    required String orderType,
    String? sessionId,
    String? tableNumber,
    PaymentTransaction? payment,
    String? cancellationReason,
    String? refundReason,
    String? staffNotes,
  }) {
    return PosOrder(
      baseOrder: order,
      orderType: orderType,
      sessionId: sessionId,
      tableNumber: tableNumber,
      payment: payment,
      cancellationReason: cancellationReason,
      refundReason: refundReason,
      staffNotes: staffNotes,
    );
  }
  
  /// Copy with
  PosOrder copyWith({
    Order? baseOrder,
    String? orderType,
    String? sessionId,
    String? tableNumber,
    PaymentTransaction? payment,
    String? cancellationReason,
    String? refundReason,
    String? staffNotes,
  }) {
    return PosOrder(
      baseOrder: baseOrder ?? this.baseOrder,
      orderType: orderType ?? this.orderType,
      sessionId: sessionId ?? this.sessionId,
      tableNumber: tableNumber ?? this.tableNumber,
      payment: payment ?? this.payment,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      refundReason: refundReason ?? this.refundReason,
      staffNotes: staffNotes ?? this.staffNotes,
    );
  }
  
  Map<String, dynamic> toJson() => {
    ...baseOrder.toJson(),
    'orderType': orderType,
    'sessionId': sessionId,
    'tableNumber': tableNumber,
    'payment': payment?.toJson(),
    'cancellationReason': cancellationReason,
    'refundReason': refundReason,
    'staffNotes': staffNotes,
  };
  
  factory PosOrder.fromJson(Map<String, dynamic> json) {
    return PosOrder(
      baseOrder: Order.fromJson(json),
      orderType: json['orderType'] as String? ?? OrderType.takeaway,
      sessionId: json['sessionId'] as String?,
      tableNumber: json['tableNumber'] as String?,
      payment: json['payment'] != null
          ? PaymentTransaction.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      refundReason: json['refundReason'] as String?,
      staffNotes: json['staffNotes'] as String?,
    );
  }
}
