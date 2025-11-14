// lib/src/models/popup_config.dart
// Model for configurable popups in the app

enum PopupTrigger {
  onAppOpen,
  onHomeScroll,
}

enum PopupAudience {
  all,
  newUsers,
  loyalUsers,
}

class PopupConfig {
  final String id;
  final String title;
  final String message;
  final String? imageUrl;
  final String? buttonText;
  final String? buttonLink; // GoRouter route
  final PopupTrigger trigger;
  final PopupAudience audience;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isEnabled;
  final int priority; // Higher priority shows first
  final DateTime createdAt;
  
  // Legacy fields for backward compatibility
  final String? type; // 'promo', 'info', 'fidelite', 'systeme'
  final String? ctaText;
  final String? ctaAction;
  final String? displayCondition;
  final String? targetAudience;

  PopupConfig({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    this.buttonText,
    this.buttonLink,
    this.trigger = PopupTrigger.onAppOpen,
    this.audience = PopupAudience.all,
    this.startDate,
    this.endDate,
    this.isEnabled = true,
    this.priority = 0,
    required this.createdAt,
    // Legacy fields
    this.type,
    this.ctaText,
    this.ctaAction,
    this.displayCondition,
    this.targetAudience,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'buttonText': buttonText,
      'buttonLink': buttonLink,
      'trigger': trigger.name,
      'audience': audience.name,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isEnabled': isEnabled,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      // Legacy fields
      'type': type,
      'ctaText': ctaText,
      'ctaAction': ctaAction,
      'displayCondition': displayCondition,
      'targetAudience': targetAudience,
      'isActive': isEnabled, // For backward compatibility
    };
  }

  // Alias for backward compatibility
  Map<String, dynamic> toJson() => toMap();

  // Create from Firestore document
  factory PopupConfig.fromFirestore(Map<String, dynamic> data) {
    return PopupConfig(
      id: data['id'] as String,
      title: data['title'] as String,
      message: data['message'] as String,
      imageUrl: data['imageUrl'] as String?,
      buttonText: data['buttonText'] as String?,
      buttonLink: data['buttonLink'] as String?,
      trigger: _parseTrigger(data['trigger'] as String?),
      audience: _parseAudience(data['audience'] as String?),
      startDate: _parseDateTime(data['startDate']),
      endDate: _parseDateTime(data['endDate']),
      isEnabled: data['isEnabled'] as bool? ?? data['isActive'] as bool? ?? true,
      priority: data['priority'] as int? ?? 0,
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      // Legacy fields
      type: data['type'] as String?,
      ctaText: data['ctaText'] as String?,
      ctaAction: data['ctaAction'] as String?,
      displayCondition: data['displayCondition'] as String?,
      targetAudience: data['targetAudience'] as String?,
    );
  }
  
  // Parse DateTime from either String (ISO8601) or Firestore Timestamp
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date string: $e');
        return null;
      }
    }
    // Handle Firestore Timestamp (has toDate() method)
    if (value is Map && value.containsKey('_seconds')) {
      final seconds = value['_seconds'] as int;
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }
    // Try dynamic method call for Timestamp object
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (e) {
      print('Error converting Timestamp to DateTime: $e');
      return null;
    }
  }

  // Alias for backward compatibility
  factory PopupConfig.fromJson(Map<String, dynamic> json) => 
      PopupConfig.fromFirestore(json);

  static PopupTrigger _parseTrigger(String? value) {
    switch (value) {
      case 'onHomeScroll':
        return PopupTrigger.onHomeScroll;
      default:
        return PopupTrigger.onAppOpen;
    }
  }

  static PopupAudience _parseAudience(String? value) {
    switch (value) {
      case 'newUsers':
        return PopupAudience.newUsers;
      case 'loyalUsers':
        return PopupAudience.loyalUsers;
      default:
        return PopupAudience.all;
    }
  }

  PopupConfig copyWith({
    String? id,
    String? title,
    String? message,
    String? imageUrl,
    String? buttonText,
    String? buttonLink,
    PopupTrigger? trigger,
    PopupAudience? audience,
    DateTime? startDate,
    DateTime? endDate,
    bool? isEnabled,
    int? priority,
    DateTime? createdAt,
    // Legacy fields
    String? type,
    String? ctaText,
    String? ctaAction,
    String? displayCondition,
    String? targetAudience,
  }) {
    return PopupConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      buttonText: buttonText ?? this.buttonText,
      buttonLink: buttonLink ?? this.buttonLink,
      trigger: trigger ?? this.trigger,
      audience: audience ?? this.audience,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isEnabled: isEnabled ?? this.isEnabled,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      // Legacy fields
      type: type ?? this.type,
      ctaText: ctaText ?? this.ctaText,
      ctaAction: ctaAction ?? this.ctaAction,
      displayCondition: displayCondition ?? this.displayCondition,
      targetAudience: targetAudience ?? this.targetAudience,
    );
  }

  bool get isCurrentlyActive {
    if (!isEnabled) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }
  
  // Legacy getter for backward compatibility
  bool get isActive => isEnabled;
}
