// lib/src/studio/models/popup_v2_model.dart
// Enhanced popup model for Studio V2 - Ultimate version with advanced features

/// Popup display types
enum PopupTypeV2 {
  image,          // Image-based popup
  text,           // Text-only popup
  coupon,         // Coupon/promo code popup
  emojiReaction,  // Emoji reaction popup
  bigPromo,       // Large promotional popup
}

/// Popup appearance conditions
enum PopupTriggerCondition {
  delay,              // Show after X seconds
  firstVisit,         // Show only on first visit
  everyVisit,         // Show on every visit
  limitedPerDay,      // Limited to X times per day
  onScroll,           // Show when user scrolls
  onAction,           // Show after specific action
}

/// Enhanced popup configuration model - V2 Ultimate
class PopupV2Model {
  final String id;
  final String title;
  final String message;
  final PopupTypeV2 type;
  
  // Visual content
  final String? imageUrl;
  final String? emoji;          // For emoji reaction type
  final String? couponCode;     // For coupon type
  
  // Action buttons
  final String? buttonText;
  final String? buttonLink;     // GoRouter route
  final String? secondaryButtonText;
  final String? secondaryButtonLink;
  
  // Display conditions
  final PopupTriggerCondition triggerCondition;
  final int? delaySeconds;      // For delay trigger
  final int? maxPerDay;         // For limitedPerDay trigger
  
  // Scheduling
  final DateTime? startDate;
  final DateTime? endDate;
  
  // Targeting
  final List<String> targetAudience; // ['all', 'new', 'loyal', 'cart_abandoners']
  
  // State
  final bool isEnabled;
  final int priority;           // Higher priority shows first
  final int order;              // Manual ordering
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  PopupV2Model({
    required this.id,
    required this.title,
    required this.message,
    this.type = PopupTypeV2.text,
    this.imageUrl,
    this.emoji,
    this.couponCode,
    this.buttonText,
    this.buttonLink,
    this.secondaryButtonText,
    this.secondaryButtonLink,
    this.triggerCondition = PopupTriggerCondition.delay,
    this.delaySeconds,
    this.maxPerDay,
    this.startDate,
    this.endDate,
    this.targetAudience = const ['all'],
    this.isEnabled = true,
    this.priority = 0,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'imageUrl': imageUrl,
      'emoji': emoji,
      'couponCode': couponCode,
      'buttonText': buttonText,
      'buttonLink': buttonLink,
      'secondaryButtonText': secondaryButtonText,
      'secondaryButtonLink': secondaryButtonLink,
      'triggerCondition': triggerCondition.name,
      'delaySeconds': delaySeconds,
      'maxPerDay': maxPerDay,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'targetAudience': targetAudience,
      'isEnabled': isEnabled,
      'priority': priority,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  /// Create from Firestore document
  factory PopupV2Model.fromJson(Map<String, dynamic> json) {
    return PopupV2Model(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _parseType(json['type'] as String?),
      imageUrl: json['imageUrl'] as String?,
      emoji: json['emoji'] as String?,
      couponCode: json['couponCode'] as String?,
      buttonText: json['buttonText'] as String?,
      buttonLink: json['buttonLink'] as String?,
      secondaryButtonText: json['secondaryButtonText'] as String?,
      secondaryButtonLink: json['secondaryButtonLink'] as String?,
      triggerCondition: _parseTrigger(json['triggerCondition'] as String?),
      delaySeconds: json['delaySeconds'] as int?,
      maxPerDay: json['maxPerDay'] as int?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      targetAudience: (json['targetAudience'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['all'],
      isEnabled: json['isEnabled'] as bool? ?? true,
      priority: json['priority'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      updatedBy: json['updatedBy'] as String?,
    );
  }

  static PopupTypeV2 _parseType(String? value) {
    switch (value) {
      case 'image':
        return PopupTypeV2.image;
      case 'coupon':
        return PopupTypeV2.coupon;
      case 'emojiReaction':
        return PopupTypeV2.emojiReaction;
      case 'bigPromo':
        return PopupTypeV2.bigPromo;
      default:
        return PopupTypeV2.text;
    }
  }

  static PopupTriggerCondition _parseTrigger(String? value) {
    switch (value) {
      case 'firstVisit':
        return PopupTriggerCondition.firstVisit;
      case 'everyVisit':
        return PopupTriggerCondition.everyVisit;
      case 'limitedPerDay':
        return PopupTriggerCondition.limitedPerDay;
      case 'onScroll':
        return PopupTriggerCondition.onScroll;
      case 'onAction':
        return PopupTriggerCondition.onAction;
      default:
        return PopupTriggerCondition.delay;
    }
  }

  /// Create a copy with modified fields
  PopupV2Model copyWith({
    String? id,
    String? title,
    String? message,
    PopupTypeV2? type,
    String? imageUrl,
    String? emoji,
    String? couponCode,
    String? buttonText,
    String? buttonLink,
    String? secondaryButtonText,
    String? secondaryButtonLink,
    PopupTriggerCondition? triggerCondition,
    int? delaySeconds,
    int? maxPerDay,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? targetAudience,
    bool? isEnabled,
    int? priority,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return PopupV2Model(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      emoji: emoji ?? this.emoji,
      couponCode: couponCode ?? this.couponCode,
      buttonText: buttonText ?? this.buttonText,
      buttonLink: buttonLink ?? this.buttonLink,
      secondaryButtonText: secondaryButtonText ?? this.secondaryButtonText,
      secondaryButtonLink: secondaryButtonLink ?? this.secondaryButtonLink,
      triggerCondition: triggerCondition ?? this.triggerCondition,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      maxPerDay: maxPerDay ?? this.maxPerDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetAudience: targetAudience ?? this.targetAudience,
      isEnabled: isEnabled ?? this.isEnabled,
      priority: priority ?? this.priority,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// Check if popup is currently active based on schedule
  bool get isCurrentlyActive {
    if (!isEnabled) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  /// Create a default popup
  factory PopupV2Model.defaultPopup({int order = 0}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return PopupV2Model(
      id: 'popup_v2_$timestamp',
      title: 'Nouveau popup',
      message: '',
      type: PopupTypeV2.text,
      isEnabled: false,
      order: order,
      priority: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
