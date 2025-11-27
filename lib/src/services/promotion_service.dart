// lib/src/services/promotion_service.dart
// Service for managing promotions in Firestore
//
// New Firestore structure:
// restaurants/{restaurantId}/builder_settings/promotions/items/{promotionId}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promotion.dart';
import '../core/firestore_paths.dart';

class PromotionService {
  final String appId;

  PromotionService({required this.appId});

  /// Get collection reference for promotions
  CollectionReference<Map<String, dynamic>> get _promotionsCollection =>
      FirestorePaths.promotions(appId);

  // Get all promotions
  Future<List<Promotion>> getAllPromotions() async {
    try {
      final snapshot = await _promotionsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Promotion.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting promotions: $e');
      return [];
    }
  }

  // Get active promotions
  Future<List<Promotion>> getActivePromotions() async {
    try {
      final snapshot = await _promotionsCollection
          .where('isActive', isEqualTo: true)
          .get();

      final promotions = snapshot.docs
          .map((doc) => Promotion.fromJson(doc.data()))
          .where((promo) => promo.isCurrentlyActive)
          .toList();
      
      // Sort in Dart to avoid composite index requirement
      promotions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return promotions;
    } catch (e) {
      print('Error getting active promotions: $e');
      return [];
    }
  }

  // Get promotions for home banner
  Future<List<Promotion>> getHomeBannerPromotions() async {
    try {
      final snapshot = await _promotionsCollection
          .where('isActive', isEqualTo: true)
          .where('showOnHomeBanner', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Promotion.fromJson(doc.data()))
          .where((promo) => promo.isCurrentlyActive)
          .toList();
    } catch (e) {
      print('Error getting home banner promotions: $e');
      return [];
    }
  }

  // Get promotions for promo block
  Future<List<Promotion>> getPromoBlockPromotions() async {
    try {
      final snapshot = await _promotionsCollection
          .where('isActive', isEqualTo: true)
          .where('showInPromoBlock', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Promotion.fromJson(doc.data()))
          .where((promo) => promo.isCurrentlyActive)
          .toList();
    } catch (e) {
      print('Error getting promo block promotions: $e');
      return [];
    }
  }

  // Get promotions for roulette
  Future<List<Promotion>> getRoulettePromotions() async {
    try {
      final snapshot = await _promotionsCollection
          .where('isActive', isEqualTo: true)
          .where('useInRoulette', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Promotion.fromJson(doc.data()))
          .where((promo) => promo.isCurrentlyActive)
          .toList();
    } catch (e) {
      print('Error getting roulette promotions: $e');
      return [];
    }
  }

  // Get promotions for mailing
  Future<List<Promotion>> getMailingPromotions() async {
    try {
      final snapshot = await _promotionsCollection
          .where('isActive', isEqualTo: true)
          .where('useInMailing', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Promotion.fromJson(doc.data()))
          .where((promo) => promo.isCurrentlyActive)
          .toList();
    } catch (e) {
      print('Error getting mailing promotions: $e');
      return [];
    }
  }

  // Get promotion by ID
  Future<Promotion?> getPromotionById(String id) async {
    try {
      final doc = await _promotionsCollection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Promotion.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting promotion by ID: $e');
      return null;
    }
  }

  // Create promotion
  Future<bool> createPromotion(Promotion promotion) async {
    try {
      await _promotionsCollection
          .doc(promotion.id)
          .set(promotion.toJson());
      return true;
    } catch (e) {
      print('Error creating promotion: $e');
      return false;
    }
  }

  // Update promotion
  Future<bool> updatePromotion(Promotion promotion) async {
    try {
      final updatedPromotion = promotion.copyWith(
        updatedAt: DateTime.now(),
      );
      await _promotionsCollection
          .doc(promotion.id)
          .update(updatedPromotion.toJson());
      return true;
    } catch (e) {
      print('Error updating promotion: $e');
      return false;
    }
  }

  // Delete promotion
  Future<bool> deletePromotion(String id) async {
    try {
      await _promotionsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting promotion: $e');
      return false;
    }
  }

  // Toggle promotion active status
  Future<bool> togglePromotionStatus(String id) async {
    try {
      final promotion = await getPromotionById(id);
      if (promotion == null) return false;

      final updated = promotion.copyWith(
        isActive: !promotion.isActive,
        updatedAt: DateTime.now(),
      );

      return await updatePromotion(updated);
    } catch (e) {
      print('Error toggling promotion status: $e');
      return false;
    }
  }

  // Stream for real-time updates
  Stream<List<Promotion>> watchPromotions() {
    return _promotionsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Promotion.fromJson(doc.data()))
          .toList();
    });
  }
}
