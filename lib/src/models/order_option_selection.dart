/// lib/src/models/order_option_selection.dart
///
/// PHASE A: Data structure for order item customization.
/// 
/// This class represents a single option selection made by a customer
/// when customizing a product (e.g., pizza size, toppings, drink choice).
/// 
/// Design principles:
/// - Generic and business-agnostic
/// - Serializable for Firestore storage
/// - Immutable for data integrity
/// - Source of truth for business logic
library;

/// Represents a customer's selection for a product option.
/// 
/// Example usage:
/// ```dart
/// // Pizza size selection
/// OrderOptionSelection(
///   optionGroupId: 'size',
///   optionId: 'large',
///   label: 'Large',
///   priceDelta: 200, // +2.00€ in cents
/// )
/// 
/// // Extra topping
/// OrderOptionSelection(
///   optionGroupId: 'toppings',
///   optionId: 'extra-cheese',
///   label: 'Extra Fromage',
///   priceDelta: 150, // +1.50€ in cents
/// )
/// ```
class OrderOptionSelection {
  /// Identifier of the option group (e.g., 'size', 'toppings', 'drink')
  final String optionGroupId;
  
  /// Identifier of the specific option chosen (e.g., 'large', 'extra-cheese')
  final String optionId;
  
  /// Human-readable label for display (e.g., 'Large', 'Extra Fromage')
  final String label;
  
  /// Price delta in cents (can be positive, negative, or zero)
  /// Examples: 200 for +2.00€, -50 for -0.50€, 0 for no change
  final int priceDelta;

  const OrderOptionSelection({
    required this.optionGroupId,
    required this.optionId,
    required this.label,
    required this.priceDelta,
  });

  /// Serializes to JSON for Firestore storage
  Map<String, dynamic> toJson() => {
    'optionGroupId': optionGroupId,
    'optionId': optionId,
    'label': label,
    'priceDelta': priceDelta,
  };

  /// Deserializes from JSON
  factory OrderOptionSelection.fromJson(Map<String, dynamic> json) {
    return OrderOptionSelection(
      optionGroupId: json['optionGroupId'] as String,
      optionId: json['optionId'] as String,
      label: json['label'] as String,
      priceDelta: json['priceDelta'] as int,
    );
  }

  /// Creates a copy with optional field replacements
  OrderOptionSelection copyWith({
    String? optionGroupId,
    String? optionId,
    String? label,
    int? priceDelta,
  }) {
    return OrderOptionSelection(
      optionGroupId: optionGroupId ?? this.optionGroupId,
      optionId: optionId ?? this.optionId,
      label: label ?? this.label,
      priceDelta: priceDelta ?? this.priceDelta,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderOptionSelection &&
        other.optionGroupId == optionGroupId &&
        other.optionId == optionId &&
        other.label == label &&
        other.priceDelta == priceDelta;
  }

  @override
  int get hashCode {
    return Object.hash(optionGroupId, optionId, label, priceDelta);
  }

  @override
  String toString() {
    return 'OrderOptionSelection(group: $optionGroupId, option: $optionId, label: $label, delta: $priceDelta)';
  }
}
