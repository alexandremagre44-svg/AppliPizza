// lib/src/services/banner_service.dart
// Service for managing multiple programmable banners in Firestore
//
// New Firestore structure:
// restaurants/{restaurantId}/builder_settings/banners/items/{bannerId}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_config.dart';
import '../core/firestore_paths.dart';

class BannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;

  BannerService({required this.appId});

  /// Get collection reference for banners
  CollectionReference<Map<String, dynamic>> get _bannersCollection =>
      FirestorePaths.banners(appId);

  /// Get all banners ordered by order field
  Future<List<BannerConfig>> getAllBanners() async {
    try {
      final snapshot = await _bannersCollection
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => BannerConfig.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting banners: $e');
      return [];
    }
  }

  /// Get active banners (currently scheduled and enabled)
  Future<List<BannerConfig>> getActiveBanners() async {
    try {
      final snapshot = await _bannersCollection
          .where('isEnabled', isEqualTo: true)
          .orderBy('order')
          .get();

      final banners = snapshot.docs
          .map((doc) => BannerConfig.fromJson(doc.data()))
          .where((banner) => banner.isCurrentlyActive)
          .toList();

      return banners;
    } catch (e) {
      print('Error getting active banners: $e');
      return [];
    }
  }

  /// Watch banners changes in real-time
  Stream<List<BannerConfig>> watchBanners() {
    return _bannersCollection
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BannerConfig.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get banner by ID
  Future<BannerConfig?> getBannerById(String id) async {
    try {
      final doc = await _bannersCollection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return BannerConfig.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting banner by ID: $e');
      return null;
    }
  }

  /// Create a new banner
  Future<bool> createBanner(BannerConfig banner) async {
    try {
      await _bannersCollection.doc(banner.id).set(banner.toJson());
      return true;
    } catch (e) {
      print('Error creating banner: $e');
      return false;
    }
  }

  /// Update an existing banner
  Future<bool> updateBanner(BannerConfig banner) async {
    try {
      final updatedBanner = banner.copyWith(updatedAt: DateTime.now());
      await _bannersCollection
          .doc(banner.id)
          .update(updatedBanner.toJson());
      return true;
    } catch (e) {
      print('Error updating banner: $e');
      return false;
    }
  }

  /// Delete a banner
  Future<bool> deleteBanner(String id) async {
    try {
      await _bannersCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting banner: $e');
      return false;
    }
  }

  /// Update order of multiple banners
  Future<bool> updateBannersOrder(List<BannerConfig> banners) async {
    try {
      final batch = _firestore.batch();
      
      for (int i = 0; i < banners.length; i++) {
        final banner = banners[i].copyWith(
          order: i,
          updatedAt: DateTime.now(),
        );
        final docRef = _bannersCollection.doc(banner.id);
        batch.update(docRef, {'order': i, 'updatedAt': DateTime.now().toIso8601String()});
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error updating banners order: $e');
      return false;
    }
  }

  /// Enable/disable a banner
  Future<bool> toggleBanner(String id, bool isEnabled) async {
    try {
      await _bannersCollection.doc(id).update({
        'isEnabled': isEnabled,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error toggling banner: $e');
      return false;
    }
  }

  /// Save all banners (batch operation for Studio V2)
  Future<void> saveAllBanners(List<BannerConfig> banners) async {
    try {
      final batch = _firestore.batch();
      
      // Get existing banners to delete removed ones
      final existing = await getAllBanners();
      final existingIds = existing.map((b) => b.id).toSet();
      final newIds = banners.map((b) => b.id).toSet();
      
      // Delete removed banners
      for (final id in existingIds) {
        if (!newIds.contains(id)) {
          final docRef = _bannersCollection.doc(id);
          batch.delete(docRef);
        }
      }
      
      // Create or update all banners
      for (final banner in banners) {
        final docRef = _bannersCollection.doc(banner.id);
        batch.set(docRef, banner.toJson());
      }
      
      await batch.commit();
    } catch (e) {
      print('Error saving all banners: $e');
      rethrow;
    }
  }
}
