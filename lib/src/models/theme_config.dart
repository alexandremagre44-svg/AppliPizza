// lib/src/models/theme_config.dart
// Theme configuration model for dynamic Server-Driven UI theme
//
// Stores theme configuration loaded from Firestore:
// restaurants/{appId}/config/theme

import 'package:flutter/material.dart';

/// Theme configuration model for dynamic theming
/// 
/// Supports loading theme colors, radius, and fonts from Firestore
/// Uses hex color strings for easy configuration in Firebase Console
class ThemeConfig {
  /// Primary color (hex string, e.g., "#D32F2F")
  final String primaryColor;
  
  /// Secondary color (hex string, e.g., "#8E4C4C")
  final String secondaryColor;
  
  /// Default border radius for UI components
  final double borderRadius;
  
  /// Font family name
  final String fontFamily;
  
  /// Additional optional colors
  final String? backgroundColor;
  final String? surfaceColor;
  final String? errorColor;
  final String? successColor;
  final String? warningColor;

  const ThemeConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.borderRadius,
    required this.fontFamily,
    this.backgroundColor,
    this.surfaceColor,
    this.errorColor,
    this.successColor,
    this.warningColor,
  });

  /// Default Delizza theme (Red/White)
  factory ThemeConfig.defaultConfig() {
    return const ThemeConfig(
      primaryColor: '#D32F2F',
      secondaryColor: '#8E4C4C',
      borderRadius: 12.0,
      fontFamily: 'Inter',
      backgroundColor: '#FAFAFA',
      surfaceColor: '#FFFFFF',
      errorColor: '#C62828',
      successColor: '#4CAF50',
      warningColor: '#FF9800',
    );
  }

  /// Create from Firestore document data
  factory ThemeConfig.fromMap(Map<String, dynamic> map) {
    return ThemeConfig(
      primaryColor: map['primaryColor'] as String? ?? '#D32F2F',
      secondaryColor: map['secondaryColor'] as String? ?? '#8E4C4C',
      borderRadius: (map['borderRadius'] as num?)?.toDouble() ?? 12.0,
      fontFamily: map['fontFamily'] as String? ?? 'Inter',
      backgroundColor: map['backgroundColor'] as String?,
      surfaceColor: map['surfaceColor'] as String?,
      errorColor: map['errorColor'] as String?,
      successColor: map['successColor'] as String?,
      warningColor: map['warningColor'] as String?,
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toMap() {
    return {
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'borderRadius': borderRadius,
      'fontFamily': fontFamily,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (surfaceColor != null) 'surfaceColor': surfaceColor,
      if (errorColor != null) 'errorColor': errorColor,
      if (successColor != null) 'successColor': successColor,
      if (warningColor != null) 'warningColor': warningColor,
    };
  }

  ThemeConfig copyWith({
    String? primaryColor,
    String? secondaryColor,
    double? borderRadius,
    String? fontFamily,
    String? backgroundColor,
    String? surfaceColor,
    String? errorColor,
    String? successColor,
    String? warningColor,
  }) {
    return ThemeConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      borderRadius: borderRadius ?? this.borderRadius,
      fontFamily: fontFamily ?? this.fontFamily,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // COLOR PARSING HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Parse hex color string to Color object
  /// Supports formats: "#RRGGBB", "#AARRGGBB", "RRGGBB"
  static Color parseHexColor(String hexString, {Color fallback = Colors.grey}) {
    try {
      String hex = hexString.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha if not present
      }
      if (hex.length != 8) {
        debugPrint('ThemeConfig: Invalid hex color format "$hexString", using fallback');
        return fallback;
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      debugPrint('ThemeConfig: Error parsing hex color "$hexString": $e, using fallback');
      return fallback;
    }
  }

  /// Get primary color as Color object
  Color get primary => parseHexColor(primaryColor, fallback: const Color(0xFFD32F2F));

  /// Get secondary color as Color object
  Color get secondary => parseHexColor(secondaryColor, fallback: const Color(0xFF8E4C4C));

  /// Get background color as Color object
  Color get background => parseHexColor(
    backgroundColor ?? '#FAFAFA',
    fallback: const Color(0xFFFAFAFA),
  );

  /// Get surface color as Color object
  Color get surface => parseHexColor(
    surfaceColor ?? '#FFFFFF',
    fallback: const Color(0xFFFFFFFF),
  );

  /// Get error color as Color object
  Color get error => parseHexColor(
    errorColor ?? '#C62828',
    fallback: const Color(0xFFC62828),
  );

  /// Get success color as Color object
  Color get success => parseHexColor(
    successColor ?? '#4CAF50',
    fallback: const Color(0xFF4CAF50),
  );

  /// Get warning color as Color object
  Color get warning => parseHexColor(
    warningColor ?? '#FF9800',
    fallback: const Color(0xFFFF9800),
  );

  /// Get border radius as BorderRadius
  BorderRadius get radiusMedium => BorderRadius.circular(borderRadius);
  BorderRadius get radiusSmall => BorderRadius.circular(borderRadius * 0.67);
  BorderRadius get radiusLarge => BorderRadius.circular(borderRadius * 1.33);
}
