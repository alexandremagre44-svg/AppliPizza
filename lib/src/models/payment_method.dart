// lib/src/models/payment_method.dart
/// 
/// Payment method types for POS transactions
library;

/// Payment method enumeration
class PaymentMethod {
  /// Cash payment
  static const String cash = 'cash';
  
  /// Card payment (prepared for TPE integration)
  static const String card = 'card';
  
  /// Offline/Manual payment (for special cases)
  static const String offline = 'offline';
  
  /// Other payment methods
  static const String other = 'other';
  
  /// All available payment methods
  static List<String> get all => [cash, card, offline, other];
  
  /// Get display label
  static String getLabel(String method) {
    switch (method) {
      case cash:
        return 'Espèces';
      case card:
        return 'Carte bancaire';
      case offline:
        return 'Paiement manuel';
      case other:
        return 'Autre';
      default:
        return method;
    }
  }
  
  /// Get icon
  static String getIcon(String method) {
    switch (method) {
      case cash:
        return 'euro';
      case card:
        return 'credit_card';
      case offline:
        return 'receipt_long';
      case other:
        return 'more_horiz';
      default:
        return 'payment';
    }
  }
}

/// Payment transaction record
class PaymentTransaction {
  final String id;
  final String orderId;
  final String method;
  final double amount;
  final double? amountGiven; // For cash payments
  final double? change; // For cash payments
  final DateTime timestamp;
  final String? reference; // External reference (TPE transaction ID, etc.)
  final PaymentStatus status;
  final String? errorMessage;
  
  const PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.method,
    required this.amount,
    this.amountGiven,
    this.change,
    required this.timestamp,
    this.reference,
    required this.status,
    this.errorMessage,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'method': method,
    'amount': amount,
    'amountGiven': amountGiven,
    'change': change,
    'timestamp': timestamp.toIso8601String(),
    'reference': reference,
    'status': status.name,
    'errorMessage': errorMessage,
  };
  
  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      method: json['method'] as String,
      amount: (json['amount'] as num).toDouble(),
      amountGiven: (json['amountGiven'] as num?)?.toDouble(),
      change: (json['change'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      reference: json['reference'] as String?,
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

/// Payment status enumeration
enum PaymentStatus {
  pending,
  success,
  failed,
  cancelled,
}
