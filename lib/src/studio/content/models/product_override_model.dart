// lib/src/studio/content/models/product_override_model.dart
// Model for product display overrides within categories on the home screen

/// Product override for home screen display within a specific category
class ProductOverride {
  final String productId;
  final String categoryId; // Category this override applies to
  final bool isVisibleOnHome;
  final bool isPinned; // Pinned to top of category
  final int order; // Display order within category
  final DateTime updatedAt;

  ProductOverride({
    required this.productId,
    required this.categoryId,
    this.isVisibleOnHome = true,
    this.isPinned = false,
    this.order = 0,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'categoryId': categoryId,
      'isVisibleOnHome': isVisibleOnHome,
      'isPinned': isPinned,
      'order': order,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProductOverride.fromJson(Map<String, dynamic> json) {
    return ProductOverride(
      productId: json['productId'] as String,
      categoryId: json['categoryId'] as String,
      isVisibleOnHome: json['isVisibleOnHome'] as bool? ?? true,
      isPinned: json['isPinned'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  ProductOverride copyWith({
    String? productId,
    String? categoryId,
    bool? isVisibleOnHome,
    bool? isPinned,
    int? order,
    DateTime? updatedAt,
  }) {
    return ProductOverride(
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      isVisibleOnHome: isVisibleOnHome ?? this.isVisibleOnHome,
      isPinned: isPinned ?? this.isPinned,
      order: order ?? this.order,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
