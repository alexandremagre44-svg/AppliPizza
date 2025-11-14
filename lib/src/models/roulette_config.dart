// lib/src/models/roulette_config.dart
// Configuration model for the promotional wheel (roulette)

import 'package:flutter/material.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isActive': isActive,
      'displayLocation': displayLocation,
      'delaySeconds': delaySeconds,
      'maxUsesPerDay': maxUsesPerDay,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'segments': segments.map((s) => s.toMap()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  // Alias for backward compatibility
  Map<String, dynamic> toJson() => toMap();

  factory RouletteConfig.fromMap(Map<String, dynamic> data) {
    return RouletteConfig(
      id: data['id'] as String,
      isActive: data['isActive'] as bool? ?? false,
      displayLocation: data['displayLocation'] as String? ?? 'home',
      delaySeconds: data['delaySeconds'] as int? ?? 5,
      maxUsesPerDay: data['maxUsesPerDay'] as int? ?? 1,
      startDate: data['startDate'] != null
          ? DateTime.parse(data['startDate'] as String)
          : null,
      endDate: data['endDate'] != null
          ? DateTime.parse(data['endDate'] as String)
          : null,
      segments: (data['segments'] as List<dynamic>?)
              ?.map((s) => RouletteSegment.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'] as String)
          : DateTime.now(),
    );
  }
  
  // Alias for backward compatibility
  factory RouletteConfig.fromJson(Map<String, dynamic> json) => 
      RouletteConfig.fromMap(json);

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
  final String rewardId; // What the player wins
  final double probability; // Probability percentage (0-100)
  final Color color; // Segment color
  
  // Legacy fields for backward compatibility
  final String? type;
  final int? value;
  final double? weight;

  RouletteSegment({
    required this.id,
    required this.label,
    required this.rewardId,
    required this.probability,
    required this.color,
    // Legacy fields
    this.type,
    this.value,
    this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'rewardId': rewardId,
      'probability': probability,
      'colorHex': _colorToHex(color),
      // Legacy fields
      'type': type ?? rewardId,
      'value': value,
      'weight': weight ?? probability,
    };
  }
  
  // Alias for backward compatibility
  Map<String, dynamic> toJson() => toMap();
  
  // Convert Color to hex string
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  
  // Convert hex string to Color
  static Color _hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) {
      return Colors.blue; // Default color
    }
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  factory RouletteSegment.fromMap(Map<String, dynamic> data) {
    return RouletteSegment(
      id: data['id'] as String,
      label: data['label'] as String,
      rewardId: data['rewardId'] as String? ?? data['type'] as String? ?? '',
      probability: (data['probability'] as num?)?.toDouble() ?? 
                   (data['weight'] as num?)?.toDouble() ?? 0.0,
      color: _hexToColor(data['colorHex'] as String?),
      // Legacy fields
      type: data['type'] as String?,
      value: data['value'] as int?,
      weight: (data['weight'] as num?)?.toDouble(),
    );
  }
  
  // Alias for backward compatibility
  factory RouletteSegment.fromJson(Map<String, dynamic> json) => 
      RouletteSegment.fromMap(json);

  RouletteSegment copyWith({
    String? id,
    String? label,
    String? rewardId,
    double? probability,
    Color? color,
    // Legacy fields
    String? type,
    int? value,
    double? weight,
  }) {
    return RouletteSegment(
      id: id ?? this.id,
      label: label ?? this.label,
      rewardId: rewardId ?? this.rewardId,
      probability: probability ?? this.probability,
      color: color ?? this.color,
      // Legacy fields
      type: type ?? this.type,
      value: value ?? this.value,
      weight: weight ?? this.weight,
    );
  }
}
