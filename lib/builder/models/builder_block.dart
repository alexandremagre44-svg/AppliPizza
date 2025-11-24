// lib/builder/models/builder_block.dart
// Base block model for Builder B3 system

import 'builder_enums.dart';

/// Base block class for all content blocks
/// 
/// This is the foundation for the modular block system.
/// Each block represents a distinct piece of content on a page.
/// 
/// Blocks are:
/// - Modular: Can be added, removed, and reordered
/// - Configurable: Each has specific settings via config map
/// - Reusable: Same block type can be used multiple times
/// - Multi-resto: Supports different configurations per restaurant
class BuilderBlock {
  /// Unique identifier for this block instance
  final String id;

  /// Type of block (hero, banner, text, etc.)
  final BlockType type;

  /// Position order on the page (0 = first, 1 = second, etc.)
  final int order;

  /// Configuration data specific to this block type
  /// 
  /// Examples:
  /// - Hero: {title, subtitle, imageUrl, ctaText, ctaAction}
  /// - Banner: {text, backgroundColor, textColor}
  /// - Text: {content, fontSize, color, alignment}
  /// - ProductList: {category, limit, layout}
  final Map<String, dynamic> config;

  /// Whether this block is currently active/visible
  final bool isActive;

  /// Visibility setting (always, mobile-only, desktop-only, hidden)
  final BlockVisibility visibility;

  /// Optional custom CSS/styling
  final String? customStyles;

  /// Timestamp when block was created
  final DateTime createdAt;

  /// Timestamp when block was last updated
  final DateTime updatedAt;

  BuilderBlock({
    required this.id,
    required this.type,
    required this.order,
    required this.config,
    this.isActive = true,
    this.visibility = BlockVisibility.visible,
    this.customStyles,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy with modified fields
  BuilderBlock copyWith({
    String? id,
    BlockType? type,
    int? order,
    Map<String, dynamic>? config,
    bool? isActive,
    BlockVisibility? visibility,
    String? customStyles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BuilderBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      order: order ?? this.order,
      config: config ?? Map<String, dynamic>.from(this.config),
      isActive: isActive ?? this.isActive,
      visibility: visibility ?? this.visibility,
      customStyles: customStyles ?? this.customStyles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'order': order,
      'config': config,
      'isActive': isActive,
      'visibility': visibility.toJson(),
      'customStyles': customStyles,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from Firestore JSON
  factory BuilderBlock.fromJson(Map<String, dynamic> json) {
    return BuilderBlock(
      id: json['id'] as String,
      type: BlockType.fromJson(json['type'] as String? ?? 'text'),
      order: json['order'] as int? ?? 0,
      config: (json['config'] as Map<String, dynamic>?) ?? {},
      isActive: json['isActive'] as bool? ?? true,
      visibility: BlockVisibility.fromJson(
        json['visibility'] as String? ?? 'visible',
      ),
      customStyles: json['customStyles'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Helper: Get a config value with type safety
  T? getConfig<T>(String key, [T? defaultValue]) {
    final value = config[key];
    if (value is T) return value;
    return defaultValue;
  }

  /// Helper: Update a config value
  BuilderBlock updateConfig(String key, dynamic value) {
    final newConfig = Map<String, dynamic>.from(config);
    newConfig[key] = value;
    return copyWith(
      config: newConfig,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'BuilderBlock(id: $id, type: ${type.value}, order: $order, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BuilderBlock && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
