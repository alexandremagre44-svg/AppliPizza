// lib/builder/services/builder_autoinit_service.dart
// Service for managing auto-initialization flags for Builder B3

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service for managing auto-initialization state in Firestore
///
/// Tracks whether auto-initialization has been performed for an appId
/// to ensure default pages are only created once.
///
/// Firestore structure:
/// ```
/// builder/apps/{appId}/meta/autoInitDone: true
/// ```
class BuilderAutoInitService {
  final FirebaseFirestore _firestore;

  // Collection paths matching existing builder structure
  static const String _builderCollection = 'builder';
  static const String _appsSubcollection = 'apps';
  static const String _metaDoc = 'meta';

  BuilderAutoInitService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get document reference for meta document
  DocumentReference _getMetaRef(String appId) {
    return _firestore
        .collection(_builderCollection)
        .doc(_appsSubcollection)
        .collection(appId)
        .doc(_metaDoc);
  }

  /// Check if auto-initialization has already been done for this appId
  ///
  /// Returns true if autoInitDone flag exists and is true, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// final service = BuilderAutoInitService();
  /// final isDone = await service.isAutoInitDone('pizza_delizza');
  /// if (!isDone) {
  ///   // Perform auto-initialization
  /// }
  /// ```
  Future<bool> isAutoInitDone(String appId) async {
    try {
      final ref = _getMetaRef(appId);
      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.data() == null) {
        return false;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return data['autoInitDone'] == true;
    } catch (e, stackTrace) {
      debugPrint('[BuilderAutoInitService] Error checking autoInitDone for $appId: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  /// Mark auto-initialization as complete for this appId
  ///
  /// Sets autoInitDone = true in Firestore to prevent future auto-init.
  ///
  /// Example:
  /// ```dart
  /// final service = BuilderAutoInitService();
  /// await service.markAutoInitDone('pizza_delizza');
  /// ```
  Future<void> markAutoInitDone(String appId) async {
    try {
      final ref = _getMetaRef(appId);
      await ref.set({
        'autoInitDone': true,
        'autoInitAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[BuilderAutoInitService] ✓ Marked autoInitDone=true for appId: $appId');
    } catch (e, stackTrace) {
      debugPrint('[BuilderAutoInitService] Error marking autoInitDone for $appId: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Reset auto-initialization flag (for testing/admin purposes only)
  ///
  /// This should only be used in development or by admins.
  Future<void> resetAutoInitFlag(String appId) async {
    try {
      final ref = _getMetaRef(appId);
      final snapshot = await ref.get();
      
      // Only attempt to delete fields if document exists
      if (snapshot.exists) {
        await ref.update({
          'autoInitDone': FieldValue.delete(),
          'autoInitAt': FieldValue.delete(),
        });
        debugPrint('[BuilderAutoInitService] Reset autoInitDone flag for appId: $appId');
      } else {
        debugPrint('[BuilderAutoInitService] No meta document found for appId: $appId, nothing to reset');
      }
    } catch (e, stackTrace) {
      debugPrint('[BuilderAutoInitService] Error resetting autoInitDone for $appId: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }
}
