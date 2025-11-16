// lib/src/services/roulette_segment_service.dart
// Service for managing individual roulette segments in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/roulette_config.dart';

/// Service for CRUD operations on roulette segments
/// Uses a dedicated Firestore collection 'roulette_segments'
/// 
/// This service manages roulette wheel segments with consistent Firestore structure:
/// - Generates default segments ONLY if collection is empty
/// - Supports add/edit/delete from admin interface
/// - Ensures proper rewardType and rewardId for each segment type
/// - Never uses "none" except for "nothing" type segments
class RouletteSegmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'roulette_segments';

  /// Get all segments ordered by position
  Future<List<RouletteSegment>> getAllSegments() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('position')
          .get();

      return snapshot.docs
          .map((doc) => RouletteSegment.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting segments: $e');
      return [];
    }
  }

  /// Get active segments only, ordered by position
  Future<List<RouletteSegment>> getActiveSegments() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('position')
          .get();

      return snapshot.docs
          .map((doc) => RouletteSegment.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting active segments: $e');
      return [];
    }
  }

  /// Get segment by ID
  Future<RouletteSegment?> getSegmentById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return RouletteSegment.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting segment by ID: $e');
      return null;
    }
  }

  /// Create a new segment with validation
  /// 
  /// Validates segment fields according to business rules:
  /// - bonus_points: requires value, sets rewardId="bonus_points_<value>"
  /// - free_pizza/drink/dessert: requires productId, sets rewardType="free_product"
  /// - nothing: sets rewardType="none", rewardId=null
  /// 
  /// NEVER overwrites an existing segment. Only creates if it doesn't exist.
  Future<bool> createSegment(RouletteSegment segment) async {
    try {
      // Check if segment already exists
      final docSnapshot = await _firestore
          .collection(_collection)
          .doc(segment.id)
          .get();
      
      if (docSnapshot.exists) {
        print('Segment ${segment.id} already exists, skipping creation');
        return true; // Return true as the segment exists (not an error)
      }
      
      // Validate and normalize segment before saving
      final normalizedSegment = _normalizeSegment(segment);
      await _firestore
          .collection(_collection)
          .doc(normalizedSegment.id)
          .set(normalizedSegment.toMap());
      return true;
    } catch (e) {
      print('Error creating segment: $e');
      return false;
    }
  }

  /// Update an existing segment with validation
  Future<bool> updateSegment(RouletteSegment segment) async {
    try {
      // Validate and normalize segment before updating
      final normalizedSegment = _normalizeSegment(segment);
      await _firestore
          .collection(_collection)
          .doc(normalizedSegment.id)
          .update(normalizedSegment.toMap());
      return true;
    } catch (e) {
      print('Error updating segment: $e');
      return false;
    }
  }

  /// Save segment (create or update)
  /// 
  /// Checks if segment exists and calls appropriate method
  Future<bool> saveSegment(RouletteSegment segment) async {
    try {
      final exists = await getSegmentById(segment.id);
      if (exists != null) {
        return await updateSegment(segment);
      } else {
        return await createSegment(segment);
      }
    } catch (e) {
      print('Error saving segment: $e');
      return false;
    }
  }

  /// Delete a segment
  Future<bool> deleteSegment(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting segment: $e');
      return false;
    }
  }

  /// Stream for real-time updates
  Stream<List<RouletteSegment>> watchSegments() {
    return _firestore
        .collection(_collection)
        .orderBy('position')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RouletteSegment.fromMap(doc.data()))
          .toList();
    });
  }

  /// Ensure default segments exist if collection is empty
  /// 
  /// This is the main entry point to initialize segments.
  /// Call this at app startup to ensure segments are ready.
  /// - If collection is empty: creates default segments
  /// - If collection has segments: does nothing
  Future<bool> ensureDefaultsIfNeeded() async {
    try {
      final existing = await getAllSegments();
      if (existing.isNotEmpty) {
        print('Segments already exist, skipping default creation');
        return true;
      }

      print('Collection is empty, creating default segments');
      return await createDefaultSegments();
    } catch (e) {
      print('Error ensuring defaults: $e');
      return false;
    }
  }

  /// Create default segments
  /// 
  /// Creates the 6 default segments according to specifications:
  /// 1. +100 points (30%)
  /// 2. +50 points (25%)
  /// 3. Pizza offerte (5%)
  /// 4. Boisson offerte (10%)
  /// 5. Dessert offert (10%)
  /// 6. Raté! (20%)
  Future<bool> createDefaultSegments() async {
    try {
      final defaultSegments = _getDefaultSegments();
      for (final segment in defaultSegments) {
        await createSegment(segment);
      }
      print('Successfully created ${defaultSegments.length} default segments');
      return true;
    } catch (e) {
      print('Error creating default segments: $e');
      return false;
    }
  }

  /// Get default segments for initialization
  /// 
  /// Returns properly configured default segments following business rules
  /// Segments are created with EXACT values as specified:
  /// - seg_1: +100 points (30%)
  /// - seg_2: Pizza offerte (5%)
  /// - seg_3: +50 points (25%)
  /// - seg_4: Raté (20%)
  /// - seg_5: Boisson offerte (10%)
  /// - seg_6: Dessert offert (10%)
  List<RouletteSegment> _getDefaultSegments() {
    return [
      // Segment 1: +100 points (30%)
      RouletteSegment(
        id: 'seg_1',
        label: '+100 points',
        rewardId: 'bonus_points_100',
        probability: 30.0,
        color: const Color(0xFFFFD700), // Gold
        description: 'Gagnez 100 points de fidélité',
        rewardType: RewardType.bonusPoints,
        rewardValue: 100.0,
        iconName: 'stars',
        isActive: true,
        position: 1,
        type: 'bonus_points',
        value: 100,
        weight: 30.0,
        productId: null,
      ),
      // Segment 2: Pizza offerte (5%)
      RouletteSegment(
        id: 'seg_2',
        label: 'Pizza offerte',
        rewardId: 'free_pizza',
        probability: 5.0,
        color: const Color(0xFFFF6B6B), // Red
        description: 'Une pizza gratuite',
        rewardType: RewardType.freePizza,
        rewardValue: null,
        iconName: 'local_pizza',
        isActive: true,
        position: 2,
        type: 'free_product',
        value: null,
        weight: 5.0,
        productId: null,
      ),
      // Segment 3: +50 points (25%)
      RouletteSegment(
        id: 'seg_3',
        label: '+50 points',
        rewardId: 'bonus_points_50',
        probability: 25.0,
        color: const Color(0xFF4ECDC4), // Turquoise
        description: 'Gagnez 50 points de fidélité',
        rewardType: RewardType.bonusPoints,
        rewardValue: 50.0,
        iconName: 'stars',
        isActive: true,
        position: 3,
        type: 'bonus_points',
        value: 50,
        weight: 25.0,
        productId: null,
      ),
      // Segment 4: Raté! (20%)
      RouletteSegment(
        id: 'seg_4',
        label: 'Raté !',
        rewardId: '',
        probability: 20.0,
        color: const Color(0xFF95A5A6), // Gray
        description: 'Dommage, réessayez demain',
        rewardType: RewardType.none,
        rewardValue: null,
        iconName: 'close',
        isActive: true,
        position: 4,
        type: 'nothing',
        value: null,
        weight: 20.0,
        productId: null,
      ),
      // Segment 5: Boisson offerte (10%)
      RouletteSegment(
        id: 'seg_5',
        label: 'Boisson offerte',
        rewardId: 'free_drink',
        probability: 10.0,
        color: const Color(0xFF3498DB), // Blue
        description: 'Une boisson gratuite',
        rewardType: RewardType.freeDrink,
        rewardValue: null,
        iconName: 'local_drink',
        isActive: true,
        position: 5,
        type: 'free_product',
        value: null,
        weight: 10.0,
        productId: null,
      ),
      // Segment 6: Dessert offert (10%)
      RouletteSegment(
        id: 'seg_6',
        label: 'Dessert offert',
        rewardId: 'free_dessert',
        probability: 10.0,
        color: const Color(0xFF9B59B6), // Purple
        description: 'Un dessert gratuit',
        rewardType: RewardType.freeDessert,
        rewardValue: null,
        iconName: 'cake',
        isActive: true,
        position: 6,
        type: 'free_product',
        value: null,
        weight: 10.0,
        productId: null,
      ),
    ];
  }

  /// Normalize segment fields according to business rules
  /// 
  /// Ensures rewardId, rewardType, and other fields are consistent:
  /// - bonus_points: rewardId="bonus_points_<value>", rewardType=bonusPoints
  /// - free_product with rewardType=freePizza: rewardId="free_pizza"
  /// - free_product with rewardType=freeDrink: rewardId="free_drink"
  /// - free_product with rewardType=freeDessert: rewardId="free_dessert"
  /// - nothing: rewardId=null, rewardType=none
  RouletteSegment _normalizeSegment(RouletteSegment segment) {
    String? normalizedRewardId;
    RewardType normalizedRewardType = segment.rewardType;
    String normalizedType = segment.type ?? 'nothing';

    // Normalize based on type or rewardType
    if (segment.type == 'bonus_points') {
      final points = segment.value ?? segment.rewardValue?.toInt() ?? 0;
      normalizedRewardId = 'bonus_points_$points';
      normalizedRewardType = RewardType.bonusPoints;
      normalizedType = 'bonus_points';
    } else if (segment.type == 'free_product') {
      // For free_product, use specific rewardType
      normalizedType = 'free_product';
      switch (segment.rewardType) {
        case RewardType.freePizza:
          normalizedRewardId = 'free_pizza';
          normalizedRewardType = RewardType.freePizza;
          break;
        case RewardType.freeDrink:
          normalizedRewardId = 'free_drink';
          normalizedRewardType = RewardType.freeDrink;
          break;
        case RewardType.freeDessert:
          normalizedRewardId = 'free_dessert';
          normalizedRewardType = RewardType.freeDessert;
          break;
        default:
          // Keep existing rewardId if already set correctly
          normalizedRewardId = segment.rewardId;
          break;
      }
    } else if (segment.type == 'nothing') {
      normalizedRewardId = null; // null for nothing type
      normalizedRewardType = RewardType.none;
      normalizedType = 'nothing';
    } else {
      // Keep existing values if type is not recognized
      normalizedRewardId = segment.rewardId;
      normalizedRewardType = segment.rewardType;
      normalizedType = segment.type ?? 'nothing';
    }

    // Return normalized segment
    return segment.copyWith(
      rewardId: normalizedRewardId ?? segment.rewardId,
      rewardType: normalizedRewardType,
      type: normalizedType,
    );
  }

  /// Update segment positions after reordering
  /// 
  /// Updates position field for multiple segments in a batch
  Future<bool> updateSegmentPositions(List<RouletteSegment> segments) async {
    try {
      final batch = _firestore.batch();
      for (int i = 0; i < segments.length; i++) {
        final segmentRef = _firestore.collection(_collection).doc(segments[i].id);
        batch.update(segmentRef, {'position': i + 1});
      }
      await batch.commit();
      return true;
    } catch (e) {
      print('Error updating segment positions: $e');
      return false;
    }
  }

  /// Initialize with default segments (backward compatibility)
  /// 
  /// @deprecated Use ensureDefaultsIfNeeded() instead
  Future<bool> initializeDefaultSegments() async {
    return await ensureDefaultsIfNeeded();
  }
}
