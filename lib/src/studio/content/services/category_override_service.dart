// lib/src/studio/content/services/category_override_service.dart
// Service for managing category display overrides

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_override_model.dart';

class CategoryOverrideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'home_category_overrides';

  /// Get all category overrides ordered by order field
  Future<List<CategoryOverride>> getAllOverrides() async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => CategoryOverride.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting category overrides: $e');
      return [];
    }
  }

  /// Get override for a specific category
  Future<CategoryOverride?> getOverride(String categoryId) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(categoryId)
          .get();

      if (!doc.exists) return null;
      return CategoryOverride.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting category override: $e');
      return null;
    }
  }

  /// Create or update category override
  Future<void> saveOverride(CategoryOverride override) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(override.categoryId)
          .set(override.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving category override: $e');
      rethrow;
    }
  }

  /// Update multiple overrides (batch update)
  Future<void> saveOverrides(List<CategoryOverride> overrides) async {
    try {
      final batch = _firestore.batch();
      for (final override in overrides) {
        batch.set(
          _firestore.collection(collectionName).doc(override.categoryId),
          override.toJson(),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    } catch (e) {
      print('Error saving category overrides: $e');
      rethrow;
    }
  }

  /// Toggle category visibility
  Future<void> toggleVisibility(String categoryId, bool isVisible) async {
    try {
      await _firestore.collection(collectionName).doc(categoryId).update({
        'isVisibleOnHome': isVisible,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error toggling category visibility: $e');
      rethrow;
    }
  }

  /// Initialize with defaults if missing
  Future<void> initIfMissing() async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      
      if (snapshot.docs.isEmpty) {
        final defaults = CategoryOverride.createDefaults();
        final batch = _firestore.batch();
        
        for (final override in defaults) {
          batch.set(
            _firestore.collection(collectionName).doc(override.categoryId),
            override.toJson(),
          );
        }
        
        await batch.commit();
      }
    } catch (e) {
      print('Error initializing category overrides: $e');
    }
  }
}
