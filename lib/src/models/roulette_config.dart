// lib/src/models/roulette_config.dart
// Configuration model for the promotional wheel (roulette)

class RouletteConfig {
  final String id;
  final bool isActive;
  final String displayLocation; // 'home', 'profile', etc.
  final int delaySeconds; // Delay before showing
  final int maxUsesPerDay; // Max spins per user per day
  final DateTime? startDate;
  final DateTime? endDate;
  final List<RouletteSegment> segments;
  final DateTime updatedAt;

  RouletteConfig({
    required this.id,
    this.isActive = false,
    this.displayLocation = 'home',
    this.delaySeconds = 5,
    this.maxUsesPerDay = 1,
    this.startDate,
    this.endDate,
    this.segments = const [],
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isActive': isActive,
      'displayLocation': displayLocation,
      'delaySeconds': delaySeconds,
      'maxUsesPerDay': maxUsesPerDay,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'segments': segments.map((s) => s.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RouletteConfig.fromJson(Map<String, dynamic> json) {
    return RouletteConfig(
      id: json['id'] as String,
      isActive: json['isActive'] as bool? ?? false,
      displayLocation: json['displayLocation'] as String? ?? 'home',
      delaySeconds: json['delaySeconds'] as int? ?? 5,
      maxUsesPerDay: json['maxUsesPerDay'] as int? ?? 1,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      segments: (json['segments'] as List<dynamic>?)
              ?.map((s) => RouletteSegment.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  RouletteConfig copyWith({
    String? id,
    bool? isActive,
    String? displayLocation,
    int? delaySeconds,
    int? maxUsesPerDay,
    DateTime? startDate,
    DateTime? endDate,
    List<RouletteSegment>? segments,
    DateTime? updatedAt,
  }) {
    return RouletteConfig(
      id: id ?? this.id,
      isActive: isActive ?? this.isActive,
      displayLocation: displayLocation ?? this.displayLocation,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      maxUsesPerDay: maxUsesPerDay ?? this.maxUsesPerDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      segments: segments ?? this.segments,
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
}

// Individual segment on the wheel
class RouletteSegment {
  final String id;
  final String label; // Text displayed on wheel
  final String type; // 'free_pizza', 'free_drink', 'free_dessert', 'bonus_points', 'nothing'
  final int? value; // Number of points for bonus_points, null for others
  final double weight; // Probability weight (higher = more likely)
  final String? colorHex; // Optional color for the segment

  RouletteSegment({
    required this.id,
    required this.label,
    required this.type,
    this.value,
    this.weight = 1.0,
    this.colorHex,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type,
      'value': value,
      'weight': weight,
      'colorHex': colorHex,
    };
  }

  factory RouletteSegment.fromJson(Map<String, dynamic> json) {
    return RouletteSegment(
      id: json['id'] as String,
      label: json['label'] as String,
      type: json['type'] as String,
      value: json['value'] as int?,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      colorHex: json['colorHex'] as String?,
    );
  }

  RouletteSegment copyWith({
    String? id,
    String? label,
    String? type,
    int? value,
    double? weight,
    String? colorHex,
  }) {
    return RouletteSegment(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      value: value ?? this.value,
      weight: weight ?? this.weight,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
