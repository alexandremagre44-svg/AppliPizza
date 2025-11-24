// lib/builder/utils/block_config_helper.dart
// Helper utilities for parsing block configurations

import 'package:flutter/material.dart';

/// Helper class for parsing block configuration values
/// 
/// Provides type-safe config value extraction with default values
class BlockConfigHelper {
  final Map<String, dynamic> config;
  final String? blockId;

  BlockConfigHelper(this.config, {this.blockId});

  /// Get string value from config
  String getString(String key, {String defaultValue = ''}) {
    final value = config[key];
    if (value is String) return value;
    if (value != null) {
      _logWarning('Expected String for key "$key", got ${value.runtimeType}');
    }
    return defaultValue;
  }

  /// Get double value from config
  double getDouble(String key, {double defaultValue = 0.0}) {
    final value = config[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value != null) {
      _logWarning('Expected number for key "$key", got ${value.runtimeType}');
    }
    return defaultValue;
  }

  /// Get int value from config
  int getInt(String key, {int defaultValue = 0}) {
    final value = config[key];
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value != null) {
      _logWarning('Expected int for key "$key", got ${value.runtimeType}');
    }
    return defaultValue;
  }

  /// Get bool value from config
  bool getBool(String key, {bool defaultValue = false}) {
    final value = config[key];
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is int) return value != 0;
    if (value != null) {
      _logWarning('Expected bool for key "$key", got ${value.runtimeType}');
    }
    return defaultValue;
  }

  /// Get Color from hex string
  Color? getColor(String key, {Color? defaultValue}) {
    final value = config[key];
    if (value == null) return defaultValue;
    
    if (value is! String) {
      _logWarning('Expected hex color string for key "$key", got ${value.runtimeType}');
      return defaultValue;
    }

    try {
      // Remove # if present
      final hex = value.replaceAll('#', '').trim();
      
      // Support 6-digit (RGB) and 8-digit (ARGB) hex colors
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      } else {
        _logWarning('Invalid hex color format for key "$key": $value');
        return defaultValue;
      }
    } catch (e) {
      _logWarning('Error parsing color for key "$key": $e');
      return defaultValue;
    }
  }

  /// Get EdgeInsets from config (padding or margin)
  EdgeInsets getEdgeInsets(String key, {EdgeInsets? defaultValue}) {
    final value = config[key];
    if (value == null) return defaultValue ?? EdgeInsets.zero;

    // If it's a number, apply to all sides
    if (value is num) {
      return EdgeInsets.all(value.toDouble());
    }

    // If it's a map with specific sides
    if (value is Map) {
      return EdgeInsets.only(
        top: (value['top'] as num?)?.toDouble() ?? 0,
        left: (value['left'] as num?)?.toDouble() ?? 0,
        right: (value['right'] as num?)?.toDouble() ?? 0,
        bottom: (value['bottom'] as num?)?.toDouble() ?? 0,
      );
    }

    // If it's a string like "16" or "16,8,16,8"
    if (value is String) {
      final parts = value.split(',').map((s) => double.tryParse(s.trim()) ?? 0).toList();
      if (parts.length == 1) {
        return EdgeInsets.all(parts[0]);
      } else if (parts.length == 2) {
        return EdgeInsets.symmetric(vertical: parts[0], horizontal: parts[1]);
      } else if (parts.length == 4) {
        return EdgeInsets.only(
          top: parts[0],
          right: parts[1],
          bottom: parts[2],
          left: parts[3],
        );
      }
    }

    _logWarning('Invalid EdgeInsets format for key "$key"');
    return defaultValue ?? EdgeInsets.zero;
  }

  /// Get TextAlign from config
  TextAlign getTextAlign(String key, {TextAlign defaultValue = TextAlign.left}) {
    final value = getString(key, defaultValue: '');
    switch (value.toLowerCase()) {
      case 'left':
        return TextAlign.left;
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      case 'start':
        return TextAlign.start;
      case 'end':
        return TextAlign.end;
      default:
        return defaultValue;
    }
  }

  /// Get FontWeight from config
  FontWeight getFontWeight(String key, {FontWeight defaultValue = FontWeight.normal}) {
    final value = getString(key, defaultValue: '');
    switch (value.toLowerCase()) {
      case 'thin':
      case '100':
        return FontWeight.w100;
      case 'extralight':
      case '200':
        return FontWeight.w200;
      case 'light':
      case '300':
        return FontWeight.w300;
      case 'normal':
      case 'regular':
      case '400':
        return FontWeight.w400;
      case 'medium':
      case '500':
        return FontWeight.w500;
      case 'semibold':
      case '600':
        return FontWeight.w600;
      case 'bold':
      case '700':
        return FontWeight.w700;
      case 'extrabold':
      case '800':
        return FontWeight.w800;
      case 'black':
      case '900':
        return FontWeight.w900;
      default:
        return defaultValue;
    }
  }

  /// Get BoxFit from config
  BoxFit getBoxFit(String key, {BoxFit defaultValue = BoxFit.cover}) {
    final value = getString(key, defaultValue: '');
    switch (value.toLowerCase()) {
      case 'fill':
        return BoxFit.fill;
      case 'contain':
        return BoxFit.contain;
      case 'cover':
        return BoxFit.cover;
      case 'fitwidth':
        return BoxFit.fitWidth;
      case 'fitheight':
        return BoxFit.fitHeight;
      case 'none':
        return BoxFit.none;
      case 'scaledown':
        return BoxFit.scaleDown;
      default:
        return defaultValue;
    }
  }

  /// Check if a key exists in config
  bool has(String key) => config.containsKey(key);

  /// Log warning for config issues
  void _logWarning(String message) {
    debugPrint('BuilderBlock [${blockId ?? 'unknown'}]: $message');
  }
}
