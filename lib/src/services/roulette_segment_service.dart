// lib/src/services/roulette_segment_service.dart
// Service for managing individual roulette segments in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/roulette_config.dart';

/// Service for CRUD operations on roulette segments
/// Uses a dedicated Firestore collection 'roulette_segments'
class RouletteSegmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'roulette_segments';

  /// Get all segments
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

  /// Get active segments only
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

  /// Create a new segment
  Future<bool> createSegment(RouletteSegment segment) async {
    try {
      await _firestore.collection(_collection).doc(segment.id).set(segment.toMap());
      return true;
    } catch (e) {
      print('Error creating segment: $e');
      return false;
    }
  }

  /// Update an existing segment
  Future<bool> updateSegment(RouletteSegment segment) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(segment.id)
          .update(segment.toMap());
      return true;
    } catch (e) {
      print('Error updating segment: $e');
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

  /// Initialize with default segments if collection is empty
  Future<bool> initializeDefaultSegments() async {
    try {
      final existing = await getAllSegments();
      if (existing.isNotEmpty) return true;

      final defaultSegments = _getDefaultSegments();
      for (final segment in defaultSegments) {
        await createSegment(segment);
      }
      return true;
    } catch (e) {
      print('Error initializing default segments: $e');
      return false;
    }
  }

  /// Get default segments for initialization
  List<RouletteSegment> _getDefaultSegments() {
    return [
      RouletteSegment(
        id: 'seg_1',
        label: '+100 points',
        rewardId: 'bonus_points_100',
        probability: 30.0,
        color: const Color(0xFFFFD700),
        description: 'Gagnez 100 points de fidélité',
        rewardType: RewardType.bonusPoints,
        rewardValue: 100,
        iconName: 'stars',
        isActive: true,
        position: 1,
        type: 'bonus_points',
        value: 100,
        weight: 30.0,
      ),
      RouletteSegment(
        id: 'seg_2',
        label: 'Pizza offerte',
        rewardId: 'free_pizza',
        probability: 5.0,
        color: const Color(0xFFFF6B6B),
        description: 'Une pizza gratuite',
        rewardType: RewardType.freeProduct,
        iconName: 'local_pizza',
        isActive: true,
        position: 2,
        type: 'free_pizza',
        weight: 5.0,
      ),
      RouletteSegment(
        id: 'seg_3',
        label: '+50 points',
        rewardId: 'bonus_points_50',
        probability: 25.0,
        color: const Color(0xFF4ECDC4),
        description: 'Gagnez 50 points de fidélité',
        rewardType: RewardType.bonusPoints,
        rewardValue: 50,
        iconName: 'stars',
        isActive: true,
        position: 3,
        type: 'bonus_points',
        value: 50,
        weight: 25.0,
      ),
      RouletteSegment(
        id: 'seg_4',
        label: 'Raté !',
        rewardId: 'nothing',
        probability: 20.0,
        color: const Color(0xFF95A5A6),
        description: 'Dommage, réessayez demain',
        rewardType: RewardType.none,
        iconName: 'close',
        isActive: true,
        position: 4,
        type: 'nothing',
        weight: 20.0,
      ),
      RouletteSegment(
        id: 'seg_5',
        label: 'Boisson offerte',
        rewardId: 'free_drink',
        probability: 10.0,
        color: const Color(0xFF3498DB),
        description: 'Une boisson gratuite',
        rewardType: RewardType.freeDrink,
        iconName: 'local_drink',
        isActive: true,
        position: 5,
        type: 'free_drink',
        weight: 10.0,
      ),
      RouletteSegment(
        id: 'seg_6',
        label: 'Dessert offert',
        rewardId: 'free_dessert',
        probability: 10.0,
        color: const Color(0xFF9B59B6),
        description: 'Un dessert gratuit',
        rewardType: RewardType.freeProduct,
        iconName: 'cake',
        isActive: true,
        position: 6,
        type: 'free_dessert',
        weight: 10.0,
      ),
    ];
  }

  /// Update segment positions after reordering
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
}
