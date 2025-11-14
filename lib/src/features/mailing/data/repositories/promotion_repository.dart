// lib/src/features/mailing/data/repositories/promotion_repository.dart
// Service for managing promotions in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_delizza/src/features/mailing/data/models/promotion.dart';

class PromotionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'promotions';

  // Get all promotions
  Future<List<Promotion>> getAllPromotions() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
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
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Promotion.fromJson(doc.data()))
          .where((promo) => promo.isCurrentlyActive)
          .toList();
    } catch (e) {
      print('Error getting active promotions: $e');
      return [];
    }
  }

  // Get promotions for home banner
  Future<List<Promotion>> getHomeBannerPromotions() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
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
      final snapshot = await _firestore
          .collection(_collection)
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
      final snapshot = await _firestore
          .collection(_collection)
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
      final snapshot = await _firestore
          .collection(_collection)
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
      final doc = await _firestore.collection(_collection).doc(id).get();
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
      await _firestore
          .collection(_collection)
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
      await _firestore
          .collection(_collection)
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
      await _firestore.collection(_collection).doc(id).delete();
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
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Promotion.fromJson(doc.data()))
          .toList();
    });
  }
}
