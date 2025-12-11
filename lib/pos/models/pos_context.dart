/// POS Order Context - defines the type and location of the order
/// 
/// This model represents the context in which a POS order is taken,
/// including whether it's for a table, sur place (on-site takeaway),
/// or à emporter (takeaway).
library;

/// Type of POS order
enum PosOrderType {
  /// Order for a specific table number
  table,
  
  /// Sur place - eating on-site without table assignment
  surPlace,
  
  /// À emporter - takeaway order
  emporter,
}

/// POS Context model containing order type and table information
class PosContext {
  /// Type of order (table, sur place, or emporter)
  final PosOrderType type;
  
  /// Table number (required when type == table)
  final int? tableNumber;
  
  /// Customer name (optional)
  final String? customerName;
  
  const PosContext({
    required this.type,
    this.tableNumber,
    this.customerName,
  });
  
  /// Check if context is valid (table orders must have a table number)
  bool get isValid {
    if (type == PosOrderType.table) {
      return tableNumber != null && tableNumber! > 0;
    }
    return true;
  }
  
  /// Get display label for the context
  String get displayLabel {
    switch (type) {
      case PosOrderType.table:
        return 'Table ${tableNumber ?? '?'}';
      case PosOrderType.surPlace:
        return 'Sur place';
      case PosOrderType.emporter:
        return 'À emporter';
    }
  }
  
  /// Create a copy with modified fields
  PosContext copyWith({
    PosOrderType? type,
    int? tableNumber,
    String? customerName,
  }) {
    return PosContext(
      type: type ?? this.type,
      tableNumber: tableNumber ?? this.tableNumber,
      customerName: customerName ?? this.customerName,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'tableNumber': tableNumber,
      'customerName': customerName,
    };
  }
  
  /// Create from JSON
  factory PosContext.fromJson(Map<String, dynamic> json) {
    return PosContext(
      type: PosOrderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PosOrderType.surPlace,
      ),
      tableNumber: json['tableNumber'] as int?,
      customerName: json['customerName'] as String?,
    );
  }
}
