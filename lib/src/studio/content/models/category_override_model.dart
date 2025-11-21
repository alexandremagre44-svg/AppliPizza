// lib/src/studio/content/models/category_override_model.dart
// Model for category display overrides on the home screen

import '../../../models/product.dart';

/// Category override for home screen
class CategoryOverride {
  final String categoryId; // ProductCategory value
  final bool isVisibleOnHome;
  final int order; // Display order on home
  final DateTime updatedAt;

  CategoryOverride({
    required this.categoryId,
    this.isVisibleOnHome = true,
    this.order = 0,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'isVisibleOnHome': isVisibleOnHome,
      'order': order,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CategoryOverride.fromJson(Map<String, dynamic> json) {
    return CategoryOverride(
      categoryId: json['categoryId'] as String,
      isVisibleOnHome: json['isVisibleOnHome'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  CategoryOverride copyWith({
    String? categoryId,
    bool? isVisibleOnHome,
    int? order,
    DateTime? updatedAt,
  }) {
    return CategoryOverride(
      categoryId: categoryId ?? this.categoryId,
      isVisibleOnHome: isVisibleOnHome ?? this.isVisibleOnHome,
      order: order ?? this.order,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create default overrides for all categories
  static List<CategoryOverride> createDefaults() {
    final now = DateTime.now();
    return ProductCategory.values.asMap().entries.map((entry) {
      return CategoryOverride(
        categoryId: entry.value.value,
        isVisibleOnHome: true,
        order: entry.key,
        updatedAt: now,
      );
    }).toList();
  }
}
