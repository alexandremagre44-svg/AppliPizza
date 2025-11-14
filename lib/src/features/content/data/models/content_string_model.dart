// lib/src/features/content/data/models/content_string_model.dart
// Immutable model for content strings with I18N support

import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable content string model for headless CMS
/// Supports internationalization with value map keyed by language codes
class ContentString {
  /// Unique key identifying this content string (e.g., "home_welcome_title")
  final String key;
  
  /// Map of language code to translated string (e.g., {"fr": "Bienvenue"})
  final Map<String, String> values;
  
  /// Metadata containing timestamps
  final Map<String, dynamic>? metadata;

  const ContentString({
    required this.key,
    required this.values,
    this.metadata,
  });

  /// Factory constructor to create ContentString from Firestore document
  /// Handles missing or malformed data robustly
  factory ContentString.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      // Return empty string if document has no data
      return ContentString(
        key: doc.id,
        values: const {},
        metadata: null,
      );
    }

    // Extract key - use document ID as fallback
    final key = data['key'] as String? ?? doc.id;
    
    // Extract values map - handle different possible formats
    Map<String, String> values = {};
    if (data['value'] != null) {
      final valueData = data['value'];
      if (valueData is Map) {
        // Convert all entries to String:String
        values = Map<String, String>.from(
          valueData.map((k, v) => MapEntry(k.toString(), v.toString())),
        );
      } else if (valueData is String) {
        // Fallback: if value is a plain string, use it for 'fr'
        values = {'fr': valueData};
      }
    }
    
    // Extract metadata
    final metadata = data['metadata'] as Map<String, dynamic>?;

    return ContentString(
      key: key,
      values: values,
      metadata: metadata,
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'key': key,
      'value': values,
      'metadata': metadata ?? {
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    };
  }

  /// Create a copy with updated values
  ContentString copyWith({
    String? key,
    Map<String, String>? values,
    Map<String, dynamic>? metadata,
  }) {
    return ContentString(
      key: key ?? this.key,
      values: values ?? this.values,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentString &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'ContentString(key: $key, values: $values)';
}
