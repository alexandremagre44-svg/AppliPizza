// lib/src/studio/content/models/content_section_model.dart
// Model for custom sections on the home screen

/// Display type for custom sections
enum SectionDisplayType {
  carousel('carousel'),
  grid('grid'),
  largeBanner('large-banner');

  const SectionDisplayType(this.value);
  final String value;

  static SectionDisplayType fromString(String value) {
    return SectionDisplayType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SectionDisplayType.carousel,
    );
  }
}

/// Content mode for custom sections
enum SectionContentMode {
  manual('manual'),
  auto('auto');

  const SectionContentMode(this.value);
  final String value;

  static SectionContentMode fromString(String value) {
    return SectionContentMode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SectionContentMode.manual,
    );
  }
}

/// Auto sort type for automatic content mode
enum SectionAutoSortType {
  bestSeller('best-seller'),
  price('price'),
  newest('newest'),
  promo('promo');

  const SectionAutoSortType(this.value);
  final String value;

  static SectionAutoSortType fromString(String value) {
    return SectionAutoSortType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SectionAutoSortType.bestSeller,
    );
  }
}

/// Custom section model
class ContentSection {
  final String id;
  final String title;
  final String? subtitle;
  final SectionDisplayType displayType;
  final SectionContentMode contentMode;
  final SectionAutoSortType? autoSortType;
  final List<String> productIds; // For manual mode
  final String? backgroundColor;
  final bool isActive;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContentSection({
    required this.id,
    required this.title,
    this.subtitle,
    required this.displayType,
    required this.contentMode,
    this.autoSortType,
    this.productIds = const [],
    this.backgroundColor,
    this.isActive = true,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'displayType': displayType.value,
      'contentMode': contentMode.value,
      'autoSortType': autoSortType?.value,
      'productIds': productIds,
      'backgroundColor': backgroundColor,
      'isActive': isActive,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ContentSection.fromJson(Map<String, dynamic> json) {
    return ContentSection(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      displayType: SectionDisplayType.fromString(json['displayType'] as String? ?? 'carousel'),
      contentMode: SectionContentMode.fromString(json['contentMode'] as String? ?? 'manual'),
      autoSortType: json['autoSortType'] != null
          ? SectionAutoSortType.fromString(json['autoSortType'] as String)
          : null,
      productIds: (json['productIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      backgroundColor: json['backgroundColor'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  ContentSection copyWith({
    String? id,
    String? title,
    String? subtitle,
    SectionDisplayType? displayType,
    SectionContentMode? contentMode,
    SectionAutoSortType? autoSortType,
    List<String>? productIds,
    String? backgroundColor,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentSection(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      displayType: displayType ?? this.displayType,
      contentMode: contentMode ?? this.contentMode,
      autoSortType: autoSortType ?? this.autoSortType,
      productIds: productIds ?? this.productIds,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
