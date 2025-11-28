// lib/builder/utils/firestore_parsing_helpers.dart
// Utility helpers for safely parsing Firestore data types
//
// TODO(builder-b3-safe-parsing) Shared parsing utilities

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper to safely parse a Map<String, dynamic> config field from Firestore
/// 
/// Handles multiple formats:
/// - Map<String, dynamic>: returned as-is
/// - Map (with different type params): converted to Map<String, dynamic>
/// - String: JSON-decoded if valid JSON, otherwise returns empty Map
/// - null or other types: returns empty Map
/// 
/// Example:
/// ```dart
/// final config = safeParseConfig(json['config']);
/// ```
Map<String, dynamic> safeParseConfig(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  
  if (value is Map) {
    // Handle Map with different type params
    return Map<String, dynamic>.from(value);
  }
  
  if (value is String) {
    // Try to decode JSON string
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      } else {
        print('⚠️ Warning: Config JSON decoded to non-Map: ${decoded.runtimeType}');
        return {};
      }
    } catch (e) {
      print('⚠️ Warning: Failed to decode config from JSON string: $e');
      return {};
    }
  }
  
  // null or other type - return empty Map
  return {};
}

/// Helper to safely parse DateTime from Firestore
/// 
/// Handles multiple types that Firestore may return:
/// - Timestamp: Firestore's native timestamp type → converted via toDate()
/// - String: ISO 8601 format date strings → parsed with DateTime.parse()
/// - int: Milliseconds since epoch → converted via fromMillisecondsSinceEpoch()
/// - null: Returns null (callers should provide fallback)
/// 
/// Example:
/// ```dart
/// final date = safeParseDateTime(json['createdAt']) ?? DateTime.now();
/// ```
DateTime? safeParseDateTime(dynamic value) {
  if (value == null) return null;
  
  // Handle Firestore Timestamp
  if (value is Timestamp) {
    return value.toDate();
  }
  
  // Handle String (ISO 8601 format)
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      print('⚠️ Warning: Could not parse date string: "$value". Error: $e');
      return null;
    }
  }
  
  // Handle int (milliseconds since epoch)
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  
  // Unknown type - log warning and return null
  print('⚠️ Warning: Unknown date type ${value.runtimeType} for value: $value');
  return null;
}

/// Helper to safely parse a String from Firestore
/// 
/// Returns null if value is not a string or is null.
/// Useful for fields that may have unexpected types.
/// 
/// Example:
/// ```dart
/// final name = safeParseString(json['name']) ?? 'Default';
/// ```
String? safeParseString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  
  // Try to convert to string for primitive types
  if (value is num || value is bool) {
    return value.toString();
  }
  
  print('⚠️ Warning: Expected String but got ${value.runtimeType}');
  return null;
}

/// Helper to safely parse an int from Firestore
/// 
/// Handles:
/// - int: returned as-is
/// - double: truncated to int
/// - String: parsed if numeric
/// - null: returns null
/// 
/// Example:
/// ```dart
/// final order = safeParseInt(json['order']) ?? 0;
/// ```
int? safeParseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      print('⚠️ Warning: Could not parse int from string: "$value"');
      return null;
    }
  }
  
  print('⚠️ Warning: Expected int but got ${value.runtimeType}');
  return null;
}

/// Helper to safely parse a bool from Firestore
/// 
/// Handles:
/// - bool: returned as-is
/// - String: 'true', '1', 'yes' → true; 'false', '0', 'no' → false
/// - int: 0 → false; non-zero → true
/// - null: returns null
/// 
/// Example:
/// ```dart
/// final isActive = safeParseBool(json['isActive']) ?? true;
/// ```
bool? safeParseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == '1' || lower == 'yes') return true;
    if (lower == 'false' || lower == '0' || lower == 'no') return false;
    print('⚠️ Warning: Could not parse bool from string: "$value"');
    return null;
  }
  
  if (value is int) return value != 0;
  
  print('⚠️ Warning: Expected bool but got ${value.runtimeType}');
  return null;
}
