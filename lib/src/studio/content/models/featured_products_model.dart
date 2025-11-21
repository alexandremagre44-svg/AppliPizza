// lib/src/studio/content/models/featured_products_model.dart
// Model for featured products section on the home screen

/// Display type for featured products
enum FeaturedDisplayType {
  carousel('carousel'),
  hero('hero'),
  horizontalCards('horizontal-cards');

  const FeaturedDisplayType(this.value);
  final String value;

  static FeaturedDisplayType fromString(String value) {
    return FeaturedDisplayType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeaturedDisplayType.carousel,
    );
  }
}

/// Position of featured products section relative to categories
enum FeaturedPosition {
  beforeCategories('before'),
  afterCategories('after');

  const FeaturedPosition(this.value);
  final String value;

  static FeaturedPosition fromString(String value) {
    return FeaturedPosition.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeaturedPosition.beforeCategories,
    );
  }
}

/// Featured products configuration
class FeaturedProductsConfig {
  final String id;
  final bool isActive;
  final List<String> productIds;
  final FeaturedDisplayType displayType;
  final FeaturedPosition position;
  final bool autoFill; // Auto-fill with featured products if empty
  final String? title;
  final String? subtitle;
  final DateTime updatedAt;

  FeaturedProductsConfig({
    required this.id,
    this.isActive = true,
    this.productIds = const [],
    this.displayType = FeaturedDisplayType.carousel,
    this.position = FeaturedPosition.beforeCategories,
    this.autoFill = true,
    this.title,
    this.subtitle,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isActive': isActive,
      'productIds': productIds,
      'displayType': displayType.value,
      'position': position.value,
      'autoFill': autoFill,
      'title': title,
      'subtitle': subtitle,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FeaturedProductsConfig.fromJson(Map<String, dynamic> json) {
    return FeaturedProductsConfig(
      id: json['id'] as String? ?? 'home_featured_products',
      isActive: json['isActive'] as bool? ?? true,
      productIds: (json['productIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      displayType: FeaturedDisplayType.fromString(json['displayType'] as String? ?? 'carousel'),
      position: FeaturedPosition.fromString(json['position'] as String? ?? 'before'),
      autoFill: json['autoFill'] as bool? ?? true,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  FeaturedProductsConfig copyWith({
    String? id,
    bool? isActive,
    List<String>? productIds,
    FeaturedDisplayType? displayType,
    FeaturedPosition? position,
    bool? autoFill,
    String? title,
    String? subtitle,
    DateTime? updatedAt,
  }) {
    return FeaturedProductsConfig(
      id: id ?? this.id,
      isActive: isActive ?? this.isActive,
      productIds: productIds ?? this.productIds,
      displayType: displayType ?? this.displayType,
      position: position ?? this.position,
      autoFill: autoFill ?? this.autoFill,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FeaturedProductsConfig.initial() {
    return FeaturedProductsConfig(
      id: 'home_featured_products',
      isActive: true,
      productIds: [],
      displayType: FeaturedDisplayType.carousel,
      position: FeaturedPosition.beforeCategories,
      autoFill: true,
      updatedAt: DateTime.now(),
    );
  }
}
