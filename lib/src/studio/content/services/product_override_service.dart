// lib/src/studio/content/services/product_override_service.dart
// Service for managing product display overrides within categories

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_override_model.dart';

class ProductOverrideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'home_product_overrides';

  /// Get all product overrides
  Future<List<ProductOverride>> getAllOverrides() async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .get();

      return snapshot.docs
          .map((doc) => ProductOverride.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting product overrides: $e');
      return [];
    }
  }

  /// Get overrides for a specific category
  Future<List<ProductOverride>> getOverridesForCategory(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => ProductOverride.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting product overrides for category: $e');
      return [];
    }
  }

  /// Get override for a specific product
  Future<ProductOverride?> getOverride(String productId) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(productId)
          .get();

      if (!doc.exists) return null;
      return ProductOverride.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting product override: $e');
      return null;
    }
  }

  /// Create or update product override
  Future<void> saveOverride(ProductOverride override) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(override.productId)
          .set(override.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving product override: $e');
      rethrow;
    }
  }

  /// Update multiple overrides (batch update)
  Future<void> saveOverrides(List<ProductOverride> overrides) async {
    try {
      final batch = _firestore.batch();
      for (final override in overrides) {
        batch.set(
          _firestore.collection(collectionName).doc(override.productId),
          override.toJson(),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    } catch (e) {
      print('Error saving product overrides: $e');
      rethrow;
    }
  }

  /// Toggle product visibility on home
  Future<void> toggleVisibility(String productId, bool isVisible) async {
    try {
      await _firestore.collection(collectionName).doc(productId).update({
        'isVisibleOnHome': isVisible,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error toggling product visibility: $e');
      rethrow;
    }
  }

  /// Toggle product pinned state
  Future<void> togglePinned(String productId, bool isPinned) async {
    try {
      await _firestore.collection(collectionName).doc(productId).update({
        'isPinned': isPinned,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error toggling product pinned: $e');
      rethrow;
    }
  }

  /// Delete override
  Future<void> deleteOverride(String productId) async {
    try {
      await _firestore.collection(collectionName).doc(productId).delete();
    } catch (e) {
      print('Error deleting product override: $e');
      rethrow;
    }
  }
}
