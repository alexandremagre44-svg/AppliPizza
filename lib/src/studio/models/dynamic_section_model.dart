// lib/src/studio/models/dynamic_section_model.dart
// Model for Dynamic Sections Builder PRO (Module 1)

import 'package:uuid/uuid.dart';

/// Section type - prebuilt and custom types
enum DynamicSectionType {
  hero('hero'),
  promoSimple('promo-simple'),
  promoAdvanced('promo-advanced'),
  text('text'),
  image('image'),
  grid('grid'),
  carousel('carousel'),
  categories('categories'),
  products('products'),
  freeLayout('free-layout');

  const DynamicSectionType(this.value);
  final String value;

  static DynamicSectionType fromString(String value) {
    return DynamicSectionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DynamicSectionType.text,
    );
  }
}

/// Layout type for sections
enum DynamicSectionLayout {
  full('full'),
  compact('compact'),
  grid2('grid-2'),
  grid3('grid-3'),
  row('row'),
  card('card'),
  overlay('overlay');

  const DynamicSectionLayout(this.value);
  final String value;

  static DynamicSectionLayout fromString(String value) {
    return DynamicSectionLayout.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DynamicSectionLayout.full,
    );
  }
}

/// Visibility conditions for sections
class SectionConditions {
  final List<int>? days; // 1=Monday, 7=Sunday
  final String? hoursStart; // HH:mm format
  final String? hoursEnd; // HH:mm format
  final bool requireLoggedIn;
  final int? requireOrdersMin;
  final double? requireCartMin;
  final bool applyOncePerSession;

  const SectionConditions({
    this.days,
    this.hoursStart,
    this.hoursEnd,
    this.requireLoggedIn = false,
    this.requireOrdersMin,
    this.requireCartMin,
    this.applyOncePerSession = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'hoursStart': hoursStart,
      'hoursEnd': hoursEnd,
      'requireLoggedIn': requireLoggedIn,
      'requireOrdersMin': requireOrdersMin,
      'requireCartMin': requireCartMin,
      'applyOncePerSession': applyOncePerSession,
    };
  }

  factory SectionConditions.fromJson(Map<String, dynamic> json) {
    return SectionConditions(
      days: (json['days'] as List<dynamic>?)?.map((e) => e as int).toList(),
      hoursStart: json['hoursStart'] as String?,
      hoursEnd: json['hoursEnd'] as String?,
      requireLoggedIn: json['requireLoggedIn'] as bool? ?? false,
      requireOrdersMin: json['requireOrdersMin'] as int?,
      requireCartMin: json['requireCartMin'] as double?,
      applyOncePerSession: json['applyOncePerSession'] as bool? ?? false,
    );
  }

  SectionConditions copyWith({
    List<int>? days,
    String? hoursStart,
    String? hoursEnd,
    bool? requireLoggedIn,
    int? requireOrdersMin,
    double? requireCartMin,
    bool? applyOncePerSession,
  }) {
    return SectionConditions(
      days: days ?? this.days,
      hoursStart: hoursStart ?? this.hoursStart,
      hoursEnd: hoursEnd ?? this.hoursEnd,
      requireLoggedIn: requireLoggedIn ?? this.requireLoggedIn,
      requireOrdersMin: requireOrdersMin ?? this.requireOrdersMin,
      requireCartMin: requireCartMin ?? this.requireCartMin,
      applyOncePerSession: applyOncePerSession ?? this.applyOncePerSession,
    );
  }
}

/// Dynamic Section model with full PRO features
class DynamicSection {
  final String id;
  final DynamicSectionType type;
  final DynamicSectionLayout layout;
  final int order;
  final bool active;
  final Map<String, dynamic> content;
  final SectionConditions conditions;
  final DateTime createdAt;
  final DateTime updatedAt;

  DynamicSection({
    String? id,
    required this.type,
    required this.layout,
    this.order = 0,
    this.active = true,
    Map<String, dynamic>? content,
    SectionConditions? conditions,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        content = content ?? {},
        conditions = conditions ?? const SectionConditions(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'layout': layout.value,
      'order': order,
      'active': active,
      'content': content,
      'conditions': conditions.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DynamicSection.fromJson(Map<String, dynamic> json) {
    return DynamicSection(
      id: json['id'] as String,
      type: DynamicSectionType.fromString(json['type'] as String? ?? 'text'),
      layout: DynamicSectionLayout.fromString(json['layout'] as String? ?? 'full'),
      order: json['order'] as int? ?? 0,
      active: json['active'] as bool? ?? true,
      content: json['content'] as Map<String, dynamic>? ?? {},
      conditions: json['conditions'] != null
          ? SectionConditions.fromJson(json['conditions'] as Map<String, dynamic>)
          : const SectionConditions(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  DynamicSection copyWith({
    String? id,
    DynamicSectionType? type,
    DynamicSectionLayout? layout,
    int? order,
    bool? active,
    Map<String, dynamic>? content,
    SectionConditions? conditions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DynamicSection(
      id: id ?? this.id,
      type: type ?? this.type,
      layout: layout ?? this.layout,
      order: order ?? this.order,
      active: active ?? this.active,
      content: content ?? Map<String, dynamic>.from(this.content),
      conditions: conditions ?? this.conditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create a duplicate of this section with a new ID
  DynamicSection duplicate() {
    return DynamicSection(
      type: type,
      layout: layout,
      order: order + 1,
      active: active,
      content: Map<String, dynamic>.from(content),
      conditions: conditions,
    );
  }

  /// Check if section should be visible based on conditions
  bool shouldBeVisible({
    required DateTime now,
    bool isLoggedIn = false,
    int userOrdersCount = 0,
    double cartTotal = 0.0,
    bool hasSeenInSession = false,
  }) {
    // Check if active
    if (!active) return false;

    // Check day of week (1=Monday, 7=Sunday)
    if (conditions.days != null && conditions.days!.isNotEmpty) {
      final weekday = now.weekday; // 1=Monday, 7=Sunday
      if (!conditions.days!.contains(weekday)) return false;
    }

    // Check time range
    if (conditions.hoursStart != null && conditions.hoursEnd != null) {
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      if (currentTime.compareTo(conditions.hoursStart!) < 0 ||
          currentTime.compareTo(conditions.hoursEnd!) > 0) {
        return false;
      }
    }

    // Check logged in requirement
    if (conditions.requireLoggedIn && !isLoggedIn) return false;

    // Check minimum orders
    if (conditions.requireOrdersMin != null &&
        userOrdersCount < conditions.requireOrdersMin!) {
      return false;
    }

    // Check minimum cart value
    if (conditions.requireCartMin != null &&
        cartTotal < conditions.requireCartMin!) {
      return false;
    }

    // Check once per session
    if (conditions.applyOncePerSession && hasSeenInSession) {
      return false;
    }

    return true;
  }
}

/// Field type for custom/free layout sections
enum CustomFieldType {
  textShort('text-short'),
  textLong('text-long'),
  image('image'),
  color('color'),
  cta('cta'),
  list('list'),
  json('json');

  const CustomFieldType(this.value);
  final String value;

  static CustomFieldType fromString(String value) {
    return CustomFieldType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CustomFieldType.textShort,
    );
  }
}

/// Custom field definition for free layout sections
class CustomField {
  final String key;
  final String label;
  final CustomFieldType type;
  final dynamic value;

  const CustomField({
    required this.key,
    required this.label,
    required this.type,
    this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'type': type.value,
      'value': value,
    };
  }

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      key: json['key'] as String,
      label: json['label'] as String,
      type: CustomFieldType.fromString(json['type'] as String),
      value: json['value'],
    );
  }

  CustomField copyWith({
    String? key,
    String? label,
    CustomFieldType? type,
    dynamic value,
  }) {
    return CustomField(
      key: key ?? this.key,
      label: label ?? this.label,
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }
}
