// lib/src/models/popup_config.dart
// Model for configurable popups in the app

class PopupConfig {
  final String id;
  final String type; // 'promo', 'info', 'fidelite', 'systeme'
  final String title;
  final String message;
  final String? ctaText;
  final String? ctaAction; // Navigation action
  final String displayCondition; // 'always', 'oncePerSession', 'oncePerDay', 'onceEver'
  final String targetAudience; // 'all', 'new', 'loyal', 'gold'
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int priority; // Higher priority shows first
  final DateTime createdAt;

  PopupConfig({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.ctaText,
    this.ctaAction,
    this.displayCondition = 'oncePerDay',
    this.targetAudience = 'all',
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.priority = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'ctaText': ctaText,
      'ctaAction': ctaAction,
      'displayCondition': displayCondition,
      'targetAudience': targetAudience,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PopupConfig.fromJson(Map<String, dynamic> json) {
    return PopupConfig(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      ctaText: json['ctaText'] as String?,
      ctaAction: json['ctaAction'] as String?,
      displayCondition: json['displayCondition'] as String? ?? 'oncePerDay',
      targetAudience: json['targetAudience'] as String? ?? 'all',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      priority: json['priority'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  PopupConfig copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    String? ctaText,
    String? ctaAction,
    String? displayCondition,
    String? targetAudience,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? priority,
    DateTime? createdAt,
  }) {
    return PopupConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      ctaText: ctaText ?? this.ctaText,
      ctaAction: ctaAction ?? this.ctaAction,
      displayCondition: displayCondition ?? this.displayCondition,
      targetAudience: targetAudience ?? this.targetAudience,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }
}
