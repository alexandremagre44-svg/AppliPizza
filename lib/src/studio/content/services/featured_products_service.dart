// lib/src/studio/content/services/featured_products_service.dart
// Service for managing featured products configuration

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/featured_products_model.dart';

class FeaturedProductsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String documentId = 'home_featured_products';
  static const String collectionName = 'config';

  /// Get featured products configuration
  Future<FeaturedProductsConfig> getConfig() async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (!doc.exists) {
        return FeaturedProductsConfig.initial();
      }

      return FeaturedProductsConfig.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      print('Error getting featured products config: $e');
      return FeaturedProductsConfig.initial();
    }
  }

  /// Update featured products configuration
  Future<void> updateConfig(FeaturedProductsConfig config) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(documentId)
          .set(config.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error updating featured products config: $e');
      rethrow;
    }
  }

  /// Initialize with default config if missing
  Future<void> initIfMissing() async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (!doc.exists) {
        await _firestore
            .collection(collectionName)
            .doc(documentId)
            .set(FeaturedProductsConfig.initial().toJson());
      }
    } catch (e) {
      print('Error initializing featured products config: $e');
    }
  }

  /// Toggle featured products active state
  Future<void> toggleActive(bool isActive) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error toggling featured products: $e');
      rethrow;
    }
  }

  /// Update product IDs
  Future<void> updateProductIds(List<String> productIds) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).update({
        'productIds': productIds,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating product IDs: $e');
      rethrow;
    }
  }
}
