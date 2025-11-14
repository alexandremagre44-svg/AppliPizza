// lib/src/models/dynamic_block_model.dart
// Model for dynamic blocks on the home page as per Module 1 specifications

import 'package:uuid/uuid.dart';

/// DynamicBlock represents a configurable content block for the home page
/// Supports types: "featuredProducts", "categories", "bestSellers"
class DynamicBlock {
  final String id;
  final String type; // "featuredProducts", "categories", "bestSellers"
  final String title;
  final int maxItems;
  final int order;
  final bool isVisible;

  DynamicBlock({
    String? id,
    required this.type,
    required this.title,
    this.maxItems = 6,
    this.order = 0,
    this.isVisible = true,
  }) : id = id ?? const Uuid().v4();

  /// Create DynamicBlock from JSON
  factory DynamicBlock.fromJson(Map<String, dynamic> json) {
    return DynamicBlock(
      id: json['id'] as String? ?? const Uuid().v4(),
      type: json['type'] as String? ?? 'featuredProducts',
      title: json['title'] as String? ?? '',
      maxItems: json['maxItems'] as int? ?? 6,
      order: json['order'] as int? ?? 0,
      isVisible: json['isVisible'] as bool? ?? true,
    );
  }

  /// Convert DynamicBlock to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'maxItems': maxItems,
      'order': order,
      'isVisible': isVisible,
    };
  }

  /// Create a copy with updated fields
  DynamicBlock copyWith({
    String? id,
    String? type,
    String? title,
    int? maxItems,
    int? order,
    bool? isVisible,
  }) {
    return DynamicBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      maxItems: maxItems ?? this.maxItems,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  String toString() {
    return 'DynamicBlock(id: $id, type: $type, title: $title, maxItems: $maxItems, order: $order, isVisible: $isVisible)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DynamicBlock && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Validate block type
  static const List<String> validTypes = [
    'featuredProducts',
    'categories',
    'bestSellers',
  ];

  bool get isValidType => validTypes.contains(type);
}
