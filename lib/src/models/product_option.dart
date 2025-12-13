/// lib/src/models/product_option.dart
///
/// PHASE B: Generic product option models for structured customization.
/// 
/// These models provide a unified way to define and manage product options
/// (sizes, toppings, sauces, etc.) that can be applied to any product type.
/// They work in conjunction with OrderOptionSelection for order creation.
library;

/// Represents a group of related options for a product.
/// 
/// Example: A "Size" option group with options "Small", "Medium", "Large"
/// 
/// ```dart
/// OptionGroup(
///   id: 'size',
///   name: 'Choisir une taille',
///   required: true,
///   multiSelect: false,
///   displayOrder: 0,
///   options: [
///     OptionItem(id: 'small', label: 'Petite', priceDelta: -100, displayOrder: 0),
///     OptionItem(id: 'medium', label: 'Moyenne', priceDelta: 0, displayOrder: 1),
///     OptionItem(id: 'large', label: 'Grande', priceDelta: 200, displayOrder: 2),
///   ],
/// )
/// ```
class OptionGroup {
  /// Stable identifier for this option group (e.g., 'size', 'toppings')
  final String id;
  
  /// Display name shown to users
  final String name;
  
  /// Whether the user must select at least one option from this group
  final bool required;
  
  /// Whether multiple options can be selected
  /// If false, only one option can be selected (radio button behavior)
  /// If true, multiple options can be selected (checkbox behavior)
  final bool multiSelect;
  
  /// Maximum number of selections allowed (null = unlimited)
  /// Only relevant when multiSelect is true
  final int? maxSelections;
  
  /// Order in which this group should be displayed (lower = first)
  final int displayOrder;
  
  /// Available options in this group
  final List<OptionItem> options;

  const OptionGroup({
    required this.id,
    required this.name,
    required this.required,
    required this.multiSelect,
    this.maxSelections,
    required this.displayOrder,
    required this.options,
  });

  /// Serializes to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'required': required,
    'multiSelect': multiSelect,
    'maxSelections': maxSelections,
    'displayOrder': displayOrder,
    'options': options.map((o) => o.toJson()).toList(),
  };

  /// Deserializes from JSON
  factory OptionGroup.fromJson(Map<String, dynamic> json) {
    return OptionGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      required: json['required'] as bool,
      multiSelect: json['multiSelect'] as bool,
      maxSelections: json['maxSelections'] as int?,
      displayOrder: json['displayOrder'] as int,
      options: (json['options'] as List<dynamic>)
          .map((o) => OptionItem.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Creates a copy with optional field replacements
  OptionGroup copyWith({
    String? id,
    String? name,
    bool? required,
    bool? multiSelect,
    int? maxSelections,
    int? displayOrder,
    List<OptionItem>? options,
  }) {
    return OptionGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      required: required ?? this.required,
      multiSelect: multiSelect ?? this.multiSelect,
      maxSelections: maxSelections ?? this.maxSelections,
      displayOrder: displayOrder ?? this.displayOrder,
      options: options ?? this.options,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OptionGroup &&
        other.id == id &&
        other.name == name &&
        other.required == required &&
        other.multiSelect == multiSelect &&
        other.maxSelections == maxSelections &&
        other.displayOrder == displayOrder;
    // Note: options equality not checked for simplicity
  }

  @override
  int get hashCode {
    return Object.hash(id, name, required, multiSelect, maxSelections, displayOrder);
  }

  @override
  String toString() {
    return 'OptionGroup(id: $id, name: $name, required: $required, multiSelect: $multiSelect, options: ${options.length})';
  }
}

/// Represents a single option within an option group.
/// 
/// Example: "Large" size option with +2.00€ price delta
/// 
/// ```dart
/// OptionItem(
///   id: 'large',
///   label: 'Grande (40cm)',
///   priceDelta: 200,  // +2.00€ in cents
///   displayOrder: 2,
/// )
/// ```
class OptionItem {
  /// Stable identifier for this option (e.g., 'small', 'extra_cheese')
  final String id;
  
  /// Display label shown to users
  final String label;
  
  /// Price delta in cents (can be positive, negative, or zero)
  /// Examples: 200 for +2.00€, -50 for -0.50€, 0 for no change
  final int priceDelta;
  
  /// Order in which this option should be displayed (lower = first)
  final int displayOrder;

  const OptionItem({
    required this.id,
    required this.label,
    required this.priceDelta,
    required this.displayOrder,
  });

  /// Serializes to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'priceDelta': priceDelta,
    'displayOrder': displayOrder,
  };

  /// Deserializes from JSON
  factory OptionItem.fromJson(Map<String, dynamic> json) {
    return OptionItem(
      id: json['id'] as String,
      label: json['label'] as String,
      priceDelta: json['priceDelta'] as int,
      displayOrder: json['displayOrder'] as int,
    );
  }

  /// Creates a copy with optional field replacements
  OptionItem copyWith({
    String? id,
    String? label,
    int? priceDelta,
    int? displayOrder,
  }) {
    return OptionItem(
      id: id ?? this.id,
      label: label ?? this.label,
      priceDelta: priceDelta ?? this.priceDelta,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OptionItem &&
        other.id == id &&
        other.label == label &&
        other.priceDelta == priceDelta &&
        other.displayOrder == displayOrder;
  }

  @override
  int get hashCode {
    return Object.hash(id, label, priceDelta, displayOrder);
  }

  @override
  String toString() {
    return 'OptionItem(id: $id, label: $label, priceDelta: $priceDelta)';
  }
}
