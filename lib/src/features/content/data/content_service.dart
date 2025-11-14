// lib/src/features/content/data/content_service.dart
// Service for managing content strings in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/content_string_model.dart';

/// Service for managing content strings in the headless CMS
/// Provides CRUD operations on the studio_content collection
/// 
/// Security: Firestore rules should restrict write access to admin users only
class ContentService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'studio_content';

  ContentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Update a specific language value for a content string
  /// Uses atomic merge operation to avoid overwriting other data
  /// 
  /// [key] - The content string key (document ID)
  /// [lang] - The language code (e.g., 'fr', 'en')
  /// [value] - The translated text
  Future<void> updateString(String key, String lang, String value) async {
    try {
      await _firestore.collection(_collection).doc(key).set({
        'key': key,
        'value': {
          lang: value,
        },
        'metadata': {
          'updatedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      // Re-throw with context for better error handling upstream
      throw Exception('Failed to update content string "$key": $e');
    }
  }

  /// Watch all content strings in real-time
  /// Returns a stream that emits the complete list whenever any string changes
  Stream<List<ContentString>> watchAllStrings() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ContentString.fromFirestore(doc))
          .toList();
    });
  }

  /// Get all content strings once (non-streaming)
  /// Useful for one-time initialization or testing
  Future<List<ContentString>> getAllStrings() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => ContentString.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch content strings: $e');
    }
  }

  /// Create a new content string
  /// Uses the key as the document ID for optimized reads
  Future<void> createString(String key, String lang, String value) async {
    try {
      await _firestore.collection(_collection).doc(key).set({
        'key': key,
        'value': {
          lang: value,
        },
        'metadata': {
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      throw Exception('Failed to create content string "$key": $e');
    }
  }

  /// Delete a content string
  Future<void> deleteString(String key) async {
    try {
      await _firestore.collection(_collection).doc(key).delete();
    } catch (e) {
      throw Exception('Failed to delete content string "$key": $e');
    }
  }

  /// Check if a content string exists
  Future<bool> exists(String key) async {
    try {
      final doc = await _firestore.collection(_collection).doc(key).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
