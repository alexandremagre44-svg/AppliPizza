// lib/builder/services/builder_autoinit_service.dart
// Service for managing auto-initialization flags for Builder B3
//
// New Firestore structure:
// restaurants/{restaurantId}/builder_settings/meta

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../src/core/firestore_paths.dart';

/// Service for managing auto-initialization state in Firestore
///
/// Tracks whether auto-initialization has been performed for a restaurant
/// to ensure default pages are only created once.
///
/// Firestore structure:
/// ```
/// restaurants/{restaurantId}/builder_settings/meta
///   - autoInitDone: true
///   - autoInitAt: timestamp
/// ```
class BuilderAutoInitService {
  final FirebaseFirestore _firestore;

  BuilderAutoInitService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get document reference for meta document
  /// Path: restaurants/{appId}/builder_settings/meta
  DocumentReference _getMetaRef(String appId) {
    return FirestorePaths.metaDoc(appId);
  }

  /// Check if auto-initialization has already been done for this restaurant
  ///
  /// Returns true if autoInitDone flag exists and is true, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// final service = BuilderAutoInitService();
  /// final isDone = await service.isAutoInitDone('delizza');
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

  /// Mark auto-initialization as complete for this restaurant
  ///
  /// Sets autoInitDone = true in Firestore to prevent future auto-init.
  ///
  /// Example:
  /// ```dart
  /// final service = BuilderAutoInitService();
  /// await service.markAutoInitDone('delizza');
  /// ```
  Future<void> markAutoInitDone(String appId) async {
    try {
      final ref = _getMetaRef(appId);
      await ref.set({
        'autoInitDone': true,
        'autoInitAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[BuilderAutoInitService] ✓ Marked autoInitDone=true for restaurantId: $appId');
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
        debugPrint('[BuilderAutoInitService] Reset autoInitDone flag for restaurantId: $appId');
      } else {
        debugPrint('[BuilderAutoInitService] No meta document found for restaurantId: $appId, nothing to reset');
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
