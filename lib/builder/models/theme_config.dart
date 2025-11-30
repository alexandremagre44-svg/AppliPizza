// lib/builder/models/theme_config.dart
// ThemeConfig model for Builder B3 system
//
// Allows customizing the visual appearance of builder blocks
// without modifying MaterialApp or global theme.

import 'package:flutter/material.dart';

/// Brightness mode for the theme
enum BrightnessMode {
  light,
  dark,
  auto;

  String toJson() => name;

  static BrightnessMode fromJson(String? value) {
    switch (value?.toLowerCase()) {
      case 'dark':
        return BrightnessMode.dark;
      case 'auto':
        return BrightnessMode.auto;
      case 'light':
      default:
        return BrightnessMode.light;
    }
  }
}

/// ThemeConfig model for Builder B3 theme customization
///
/// This class stores visual styling configuration that can be applied
/// to builder blocks at runtime. It does NOT modify MaterialApp or
/// the global MaterialTheme.
///
/// Features:
/// - White-label friendly: Each restaurant can have unique styling
/// - Draft/Published workflow: Like pages, theme has draft and published versions
/// - Fallback to defaults: Missing values gracefully fall back to safe defaults
///
/// Firestore structure:
/// - restaurants/{appId}/theme_draft (single document)
/// - restaurants/{appId}/theme_published (single document)
class ThemeConfig {
  /// Primary color (dominant color for buttons, accents)
  final Color primaryColor;

  /// Secondary color (complementary accent color)
  final Color secondaryColor;

  /// Background color (global background for builder pages)
  final Color backgroundColor;

  /// Button border radius
  final double buttonRadius;

  /// Card/Container border radius
  final double cardRadius;

  /// Heading text size (for titles)
  final double textHeadingSize;

  /// Body text size (for normal text)
  final double textBodySize;

  /// Vertical spacing between blocks
  final double spacing;

  /// Brightness mode (light/dark/auto)
  final BrightnessMode brightnessMode;

  /// Timestamp when config was last updated
  final DateTime updatedAt;

  /// User ID who last modified this config
  final String? lastModifiedBy;

  const ThemeConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.buttonRadius,
    required this.cardRadius,
    required this.textHeadingSize,
    required this.textBodySize,
    required this.spacing,
    required this.brightnessMode,
    required this.updatedAt,
    this.lastModifiedBy,
  });

  /// Default theme configuration
  ///
  /// Used when no theme is configured or as fallback for missing values.
  static ThemeConfig get defaultConfig => ThemeConfig(
        primaryColor: const Color(0xFFD32F2F), // Deep red (pizza theme)
        secondaryColor: const Color(0xFF1976D2), // Blue accent
        backgroundColor: const Color(0xFFF5F5F5), // Light grey
        buttonRadius: 8.0,
        cardRadius: 12.0,
        textHeadingSize: 24.0,
        textBodySize: 16.0,
        spacing: 16.0,
        brightnessMode: BrightnessMode.light,
        updatedAt: DateTime.now(),
        lastModifiedBy: null,
      );

  /// Create a copy with modified fields
  ThemeConfig copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    double? buttonRadius,
    double? cardRadius,
    double? textHeadingSize,
    double? textBodySize,
    double? spacing,
    BrightnessMode? brightnessMode,
    DateTime? updatedAt,
    String? lastModifiedBy,
  }) {
    return ThemeConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      cardRadius: cardRadius ?? this.cardRadius,
      textHeadingSize: textHeadingSize ?? this.textHeadingSize,
      textBodySize: textBodySize ?? this.textBodySize,
      spacing: spacing ?? this.spacing,
      brightnessMode: brightnessMode ?? this.brightnessMode,
      updatedAt: updatedAt ?? this.updatedAt,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'primaryColor': _colorToHex(primaryColor),
      'secondaryColor': _colorToHex(secondaryColor),
      'backgroundColor': _colorToHex(backgroundColor),
      'buttonRadius': buttonRadius,
      'cardRadius': cardRadius,
      'textHeadingSize': textHeadingSize,
      'textBodySize': textBodySize,
      'spacing': spacing,
      'brightnessMode': brightnessMode.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastModifiedBy': lastModifiedBy,
    };
  }

  /// Create from Firestore JSON
  ///
  /// Uses fallback to default values for missing or invalid fields.
  factory ThemeConfig.fromMap(Map<String, dynamic> map) {
    final defaults = ThemeConfig.defaultConfig;

    return ThemeConfig(
      primaryColor: _parseColor(map['primaryColor']) ?? defaults.primaryColor,
      secondaryColor:
          _parseColor(map['secondaryColor']) ?? defaults.secondaryColor,
      backgroundColor:
          _parseColor(map['backgroundColor']) ?? defaults.backgroundColor,
      buttonRadius: _parseDouble(map['buttonRadius']) ?? defaults.buttonRadius,
      cardRadius: _parseDouble(map['cardRadius']) ?? defaults.cardRadius,
      textHeadingSize:
          _parseDouble(map['textHeadingSize']) ?? defaults.textHeadingSize,
      textBodySize: _parseDouble(map['textBodySize']) ?? defaults.textBodySize,
      spacing: _parseDouble(map['spacing']) ?? defaults.spacing,
      brightnessMode: BrightnessMode.fromJson(map['brightnessMode'] as String?),
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
      lastModifiedBy: map['lastModifiedBy'] as String?,
    );
  }

  /// Merge preview updates into this config
  ///
  /// Used in the Builder to preview theme changes before saving.
  /// Only non-null values in the updates map are applied.
  ThemeConfig mergeForPreview(Map<String, dynamic> updates) {
    return ThemeConfig(
      primaryColor:
          _parseColor(updates['primaryColor']) ?? primaryColor,
      secondaryColor:
          _parseColor(updates['secondaryColor']) ?? secondaryColor,
      backgroundColor:
          _parseColor(updates['backgroundColor']) ?? backgroundColor,
      buttonRadius: _parseDouble(updates['buttonRadius']) ?? buttonRadius,
      cardRadius: _parseDouble(updates['cardRadius']) ?? cardRadius,
      textHeadingSize:
          _parseDouble(updates['textHeadingSize']) ?? textHeadingSize,
      textBodySize: _parseDouble(updates['textBodySize']) ?? textBodySize,
      spacing: _parseDouble(updates['spacing']) ?? spacing,
      brightnessMode: updates['brightnessMode'] != null
          ? BrightnessMode.fromJson(updates['brightnessMode'] as String)
          : brightnessMode,
      updatedAt: DateTime.now(),
      lastModifiedBy: lastModifiedBy,
    );
  }

  // ==================== Helper Methods ====================

  /// Parse a color from hex string (e.g., "#D32F2F" or "D32F2F")
  static Color? _parseColor(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      try {
        final hex = value.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      } catch (_) {
        return null;
      }
    }

    if (value is int) {
      return Color(value);
    }

    return null;
  }

  /// Convert a Color to hex string (e.g., "#D32F2F")
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Parse a double from dynamic value
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse DateTime from various Firestore formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    // Handle Firestore Timestamp
    if (value.runtimeType.toString().contains('Timestamp')) {
      try {
        return (value as dynamic).toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    // Handle ISO 8601 string
    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ==================== Derived Getters ====================

  /// Get the effective brightness based on brightnessMode
  Brightness getEffectiveBrightness(BuildContext context) {
    switch (brightnessMode) {
      case BrightnessMode.light:
        return Brightness.light;
      case BrightnessMode.dark:
        return Brightness.dark;
      case BrightnessMode.auto:
        return MediaQuery.platformBrightnessOf(context);
    }
  }

  /// Get text color appropriate for the background
  Color getTextColor(BuildContext context) {
    final brightness = getEffectiveBrightness(context);
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }

  /// Get secondary text color (lighter)
  Color getSecondaryTextColor(BuildContext context) {
    final brightness = getEffectiveBrightness(context);
    return brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
  }

  @override
  String toString() {
    return 'ThemeConfig(primaryColor: ${_colorToHex(primaryColor)}, '
        'secondaryColor: ${_colorToHex(secondaryColor)}, '
        'buttonRadius: $buttonRadius, cardRadius: $cardRadius, '
        'spacing: $spacing, mode: ${brightnessMode.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeConfig &&
        other.primaryColor.value == primaryColor.value &&
        other.secondaryColor.value == secondaryColor.value &&
        other.backgroundColor.value == backgroundColor.value &&
        other.buttonRadius == buttonRadius &&
        other.cardRadius == cardRadius &&
        other.textHeadingSize == textHeadingSize &&
        other.textBodySize == textBodySize &&
        other.spacing == spacing &&
        other.brightnessMode == brightnessMode;
  }

  @override
  int get hashCode {
    return Object.hash(
      primaryColor.value,
      secondaryColor.value,
      backgroundColor.value,
      buttonRadius,
      cardRadius,
      textHeadingSize,
      textBodySize,
      spacing,
      brightnessMode,
    );
  }
}
