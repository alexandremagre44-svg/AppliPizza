// lib/src/services/roulette_segment_service.dart
// Service for managing individual roulette segments in Firestore

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/roulette_config.dart';
import '../providers/restaurant_provider.dart';

/// Service for CRUD operations on roulette segments
/// Uses a scoped Firestore collection 'restaurants/{appId}/roulette_segments'
/// 
/// This service manages roulette wheel segments with consistent Firestore structure:
/// - Generates default segments ONLY if collection is empty
/// - Supports add/edit/delete from admin interface
/// - Ensures proper rewardType and rewardId for each segment type
/// - Never uses "none" except for "nothing" type segments
class RouletteSegmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;

  RouletteSegmentService({required this.appId});

  /// Get the scoped collection for roulette segments
  CollectionReference get _segmentsCollection =>
      _firestore.collection('restaurants').doc(appId).collection('roulette_segments');

  /// Get all segments ordered by position
  /// 
  /// CRITICAL FIX: This method ensures segments are ALWAYS sorted by position
  /// to prevent desync between wheel display and reward selection.
  /// - Fetches all segments from Firestore
  /// - Assigns fallback position based on Firebase order for documents without position
  /// - Sorts by position ASCENDING to ensure consistent order
  Future<List<RouletteSegment>> getAllSegments() async {
    try {
      final snapshot = await _segmentsCollection.get();

      final List<RouletteSegment> segments = snapshot.docs
          .map((doc) => RouletteSegment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Assign fallback position based on Firebase order (for position == 0 or null)
      for (int i = 0; i < segments.length; i++) {
        if (segments[i].position == 0) {
          segments[i] = segments[i].copyWith(position: i + 1);
        }
      }

      // ALWAYS sort by position ASC -> this ensures consistent order
      segments.sort((a, b) => a.position.compareTo(b.position));

      // LOG: Verify segment order for debugging
      print('[ROULETTE ORDER] ${segments.map((s) => s.label).toList()}');

      return segments;
    } catch (e) {
      print('Error getting segments: $e');
      return [];
    }
  }

  /// Get active segments only, ordered by position
  /// 
  /// CRITICAL FIX: This method ensures segments are ALWAYS sorted by position
  /// to prevent desync between wheel display and reward selection.
  /// - Fetches only active segments from Firestore
  /// - Assigns fallback position based on Firebase order for documents without position
  /// - Sorts by position ASCENDING to ensure consistent order
  Future<List<RouletteSegment>> getActiveSegments() async {
    try {
      final snapshot = await _segmentsCollection
          .where('isActive', isEqualTo: true)
          .get();

      final List<RouletteSegment> segments = snapshot.docs
          .map((doc) => RouletteSegment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Assign fallback position based on Firebase order (for position == 0 or null)
      for (int i = 0; i < segments.length; i++) {
        if (segments[i].position == 0) {
          segments[i] = segments[i].copyWith(position: i + 1);
        }
      }

      // ALWAYS sort by position ASC -> this ensures wheel UI and reward logic use same order
      segments.sort((a, b) => a.position.compareTo(b.position));

      // LOG: Verify segment order for debugging
      print('[ROULETTE ORDER] ${segments.map((s) => s.label).toList()}');

      return segments;
    } catch (e) {
      print('Error getting active segments: $e');
      return [];
    }
  }

  /// Get segment by ID
  Future<RouletteSegment?> getSegmentById(String id) async {
    try {
      final doc = await _segmentsCollection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return RouletteSegment.fromMap(doc.data() as Map<String, dynamic>);
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
      final docSnapshot = await _segmentsCollection.doc(segment.id).get();
      
      if (docSnapshot.exists) {
        print('Segment ${segment.id} already exists, skipping creation');
        return true; // Return true as the segment exists (not an error)
      }
      
      // Validate and normalize segment before saving
      final normalizedSegment = _normalizeSegment(segment);
      await _segmentsCollection.doc(normalizedSegment.id).set(normalizedSegment.toMap());
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
      await _segmentsCollection.doc(normalizedSegment.id).update(normalizedSegment.toMap());
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
      await _segmentsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting segment: $e');
      return false;
    }
  }

  /// Stream for real-time updates
  /// 
  /// CRITICAL FIX: This stream ensures segments are ALWAYS sorted by position
  /// to prevent desync between wheel display and reward selection.
  Stream<List<RouletteSegment>> watchSegments() {
    return _segmentsCollection.snapshots().map((snapshot) {
      final List<RouletteSegment> segments = snapshot.docs
          .map((doc) => RouletteSegment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Assign fallback position based on Firebase order (for position == 0 or null)
      for (int i = 0; i < segments.length; i++) {
        if (segments[i].position == 0) {
          segments[i] = segments[i].copyWith(position: i + 1);
        }
      }

      // ALWAYS sort by position ASC -> this ensures consistent order
      segments.sort((a, b) => a.position.compareTo(b.position));

      // LOG: Verify segment order for debugging
      print('[ROULETTE ORDER] ${segments.map((s) => s.label).toList()}');

      return segments;
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
      normalizedRewardId = ''; // empty string for nothing type
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
        final segmentRef = _segmentsCollection.doc(segments[i].id);
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

  /// Pick a random segment index based on probability distribution
  /// 
  /// NEW INDEX-BASED ARCHITECTURE
  /// This is the single source of truth for segment selection.
  /// Returns the INDEX of the winning segment instead of the segment object.
  /// 
  /// Algorithm:
  /// 1. Calculate total probability of all segments
  /// 2. Generate random number between 0 and total probability
  /// 3. Find segment index where cumulative probability >= random number
  /// 
  /// Returns the winning segment index (0-based)
  int pickIndex(List<RouletteSegment> segments) {
    if (segments.isEmpty) {
      throw Exception('No active segments available for selection');
    }
    
    // Calculate total probability
    final totalProbability = segments.fold<double>(
      0.0,
      (sum, segment) => sum + segment.probability,
    );
    
    // Generate random number between 0 and total probability
    final random = math.Random().nextDouble() * totalProbability;
    
    // Find the segment index that matches the random value
    double cumulativeProbability = 0.0;
    for (int i = 0; i < segments.length; i++) {
      cumulativeProbability += segments[i].probability;
      if (random <= cumulativeProbability) {
        print('🎲 [SERVICE] Selected index: $i (${segments[i].label}, random: ${random.toStringAsFixed(2)}/$totalProbability)');
        return i;
      }
    }
    
    // Fallback to last segment index (should not happen with valid probabilities)
    print('⚠️ [SERVICE] Fallback to last segment index');
    return segments.length - 1;
  }

  /// Pick a random segment based on probability distribution
  /// 
  /// @deprecated Use pickIndex() instead for the new index-based architecture
  /// This method is kept for backward compatibility but should NOT be used
  /// 
  /// Returns the winning RouletteSegment
  @Deprecated('Use pickIndex(List<RouletteSegment>) instead')
  Future<RouletteSegment> pickRandomSegment() async {
    final segments = await getActiveSegments();
    final index = pickIndex(segments);
    return segments[index];
  }
}

/// Provider for RouletteSegmentService scoped to the current restaurant
final rouletteSegmentServiceProvider = Provider<RouletteSegmentService>(
  (ref) {
    final appId = ref.watch(currentRestaurantProvider).id;
    return RouletteSegmentService(appId: appId);
  },
  dependencies: [currentRestaurantProvider],
);
