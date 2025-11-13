// lib/src/models/promotion.dart
// Model for promotional offers with multi-channel targeting

class Promotion {
  final String id;
  final String name;
  final String description;
  final String type; // 'fixed_discount', 'percent_discount', 'x_for_y', 'bonus_points'
  final double? value; // Amount, percentage, or points
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  
  // Multi-channel targeting
  final bool showOnHomeBanner;
  final bool showInPromoBlock;
  final bool useInRoulette;
  final bool useInPopup;
  final bool useInMailing;
  
  // Optional conditions
  final double? minOrderAmount;
  final List<String>? applicableCategories; // Pizza, Menus, etc.
  
  final DateTime createdAt;
  final DateTime updatedAt;

  Promotion({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.value,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.showOnHomeBanner = false,
    this.showInPromoBlock = false,
    this.useInRoulette = false,
    this.useInPopup = false,
    this.useInMailing = false,
    this.minOrderAmount,
    this.applicableCategories,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'value': value,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'showOnHomeBanner': showOnHomeBanner,
      'showInPromoBlock': showInPromoBlock,
      'useInRoulette': useInRoulette,
      'useInPopup': useInPopup,
      'useInMailing': useInMailing,
      'minOrderAmount': minOrderAmount,
      'applicableCategories': applicableCategories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      value: (json['value'] as num?)?.toDouble(),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      showOnHomeBanner: json['showOnHomeBanner'] as bool? ?? false,
      showInPromoBlock: json['showInPromoBlock'] as bool? ?? false,
      useInRoulette: json['useInRoulette'] as bool? ?? false,
      useInPopup: json['useInPopup'] as bool? ?? false,
      useInMailing: json['useInMailing'] as bool? ?? false,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
      applicableCategories: (json['applicableCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Promotion copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    double? value,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? showOnHomeBanner,
    bool? showInPromoBlock,
    bool? useInRoulette,
    bool? useInPopup,
    bool? useInMailing,
    double? minOrderAmount,
    List<String>? applicableCategories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Promotion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      showOnHomeBanner: showOnHomeBanner ?? this.showOnHomeBanner,
      showInPromoBlock: showInPromoBlock ?? this.showInPromoBlock,
      useInRoulette: useInRoulette ?? this.useInRoulette,
      useInPopup: useInPopup ?? this.useInPopup,
      useInMailing: useInMailing ?? this.useInMailing,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  String get formattedValue {
    if (value == null) return '';
    switch (type) {
      case 'fixed_discount':
        return '${value!.toStringAsFixed(2)}€';
      case 'percent_discount':
        return '${value!.toStringAsFixed(0)}%';
      case 'bonus_points':
        return '${value!.toInt()} points';
      default:
        return value!.toString();
    }
  }
}
