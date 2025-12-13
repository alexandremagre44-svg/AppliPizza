// lib/src/models/cashier_session.dart
/// 
/// Cashier session model for POS operations
/// Tracks opening, closing, and all transactions during a shift
library;

import 'payment_method.dart';

/// Cashier session model
class CashierSession {
  final String id;
  final String restaurantId;
  final String staffId;
  final String staffName;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double openingCash;
  final double? closingCash;
  final double? expectedCash;
  final double? variance;
  final List<String> orderIds;
  final Map<String, double> paymentTotals; // method -> total amount
  final SessionStatus status;
  final String? notes;
  
  const CashierSession({
    required this.id,
    required this.restaurantId,
    required this.staffId,
    required this.staffName,
    required this.openedAt,
    this.closedAt,
    required this.openingCash,
    this.closingCash,
    this.expectedCash,
    this.variance,
    this.orderIds = const [],
    this.paymentTotals = const {},
    required this.status,
    this.notes,
  });
  
  /// Total number of orders in session
  int get orderCount => orderIds.length;
  
  /// Total amount collected in session
  double get totalCollected {
    return paymentTotals.values.fold(0.0, (sum, amount) => sum + amount);
  }
  
  /// Expected cash at closing
  double get calculatedExpectedCash {
    final cashTotal = paymentTotals[PaymentMethod.cash] ?? 0.0;
    return openingCash + cashTotal;
  }
  
  /// Session duration
  Duration? get duration {
    if (closedAt == null) {
      return DateTime.now().difference(openedAt);
    }
    return closedAt!.difference(openedAt);
  }
  
  /// Copy with
  CashierSession copyWith({
    String? id,
    String? restaurantId,
    String? staffId,
    String? staffName,
    DateTime? openedAt,
    DateTime? closedAt,
    double? openingCash,
    double? closingCash,
    double? expectedCash,
    double? variance,
    List<String>? orderIds,
    Map<String, double>? paymentTotals,
    SessionStatus? status,
    String? notes,
  }) {
    return CashierSession(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      openingCash: openingCash ?? this.openingCash,
      closingCash: closingCash ?? this.closingCash,
      expectedCash: expectedCash ?? this.expectedCash,
      variance: variance ?? this.variance,
      orderIds: orderIds ?? this.orderIds,
      paymentTotals: paymentTotals ?? this.paymentTotals,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'staffId': staffId,
    'staffName': staffName,
    'openedAt': openedAt.toIso8601String(),
    'closedAt': closedAt?.toIso8601String(),
    'openingCash': openingCash,
    'closingCash': closingCash,
    'expectedCash': expectedCash,
    'variance': variance,
    'orderIds': orderIds,
    'paymentTotals': paymentTotals,
    'status': status.name,
    'notes': notes,
  };
  
  factory CashierSession.fromJson(Map<String, dynamic> json) {
    return CashierSession(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      openedAt: DateTime.parse(json['openedAt'] as String),
      closedAt: json['closedAt'] != null ? DateTime.parse(json['closedAt'] as String) : null,
      openingCash: (json['openingCash'] as num).toDouble(),
      closingCash: (json['closingCash'] as num?)?.toDouble(),
      expectedCash: (json['expectedCash'] as num?)?.toDouble(),
      variance: (json['variance'] as num?)?.toDouble(),
      orderIds: List<String>.from(json['orderIds'] as List? ?? []),
      paymentTotals: Map<String, double>.from(
        (json['paymentTotals'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ) ?? {},
      ),
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.open,
      ),
      notes: json['notes'] as String?,
    );
  }
}

/// Session status enumeration
enum SessionStatus {
  open,
  closed,
}
