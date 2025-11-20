// lib/src/models/banner_config.dart
// Model for multiple programmable banners

import 'package:flutter/material.dart';

/// Configuration for a programmable banner
/// Supports multiple banners with scheduling, colors, and icons
class BannerConfig {
  final String id;
  final String text;
  final String? icon; // Material icon name (e.g., 'campaign', 'star', 'local_fire_department')
  final String backgroundColor; // Hex color
  final String textColor; // Hex color
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isEnabled;
  final int order; // Display order (0, 1, 2...)
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  BannerConfig({
    required this.id,
    required this.text,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.startDate,
    this.endDate,
    required this.isEnabled,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'icon': icon,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isEnabled': isEnabled,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  factory BannerConfig.fromJson(Map<String, dynamic> json) {
    return BannerConfig(
      id: json['id'] as String,
      text: json['text'] as String? ?? '',
      icon: json['icon'] as String?,
      backgroundColor: json['backgroundColor'] as String? ?? '#D32F2F',
      textColor: json['textColor'] as String? ?? '#FFFFFF',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isEnabled: json['isEnabled'] as bool? ?? true,
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

  BannerConfig copyWith({
    String? id,
    String? text,
    String? icon,
    String? backgroundColor,
    String? textColor,
    DateTime? startDate,
    DateTime? endDate,
    bool? isEnabled,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return BannerConfig(
      id: id ?? this.id,
      text: text ?? this.text,
      icon: icon ?? this.icon,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isEnabled: isEnabled ?? this.isEnabled,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// Check if banner is currently active based on schedule and enabled state
  bool get isCurrentlyActive {
    if (!isEnabled) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  /// Create a default banner configuration
  factory BannerConfig.defaultBanner({int order = 0}) {
    return BannerConfig(
      id: 'banner_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Nouveau bandeau',
      icon: 'campaign',
      backgroundColor: '#D32F2F',
      textColor: '#FFFFFF',
      isEnabled: false,
      order: order,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Get Material IconData from icon name
  IconData? get iconData {
    if (icon == null) return null;
    
    // Map common icon names to IconData
    final iconMap = {
      'campaign': Icons.campaign,
      'star': Icons.star,
      'local_fire_department': Icons.local_fire_department,
      'local_offer': Icons.local_offer,
      'new_releases': Icons.new_releases,
      'notifications': Icons.notifications,
      'celebration': Icons.celebration,
      'info': Icons.info,
      'warning': Icons.warning,
      'announcement': Icons.announcement,
    };
    
    return iconMap[icon];
  }
}
