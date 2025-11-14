// lib/src/services/roulette_service.dart
// Service for managing roulette (wheel) configuration in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pizza_delizza/src/features/roulette/data/models/roulette_config.dart';
import 'dart:math';

class RouletteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'app_roulette_config';
  static const String _configDocId = 'main';

  // Get roulette configuration
  Future<RouletteConfig?> getRouletteConfig() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_configDocId).get();
      if (doc.exists && doc.data() != null) {
        return RouletteConfig.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting roulette config: $e');
      return null;
    }
  }

  // Save roulette configuration
  Future<bool> saveRouletteConfig(RouletteConfig config) async {
    try {
      await _firestore.collection(_collection).doc(_configDocId).set(
            config.toMap(),
            SetOptions(merge: true),
          );
      return true;
    } catch (e) {
      print('Error saving roulette config: $e');
      return false;
    }
  }

  // Initialize with default config if doesn't exist
  Future<bool> initializeDefaultConfig() async {
    try {
      final existing = await getRouletteConfig();
      if (existing != null) return true;

      final defaultConfig = RouletteConfig(
        id: _configDocId,
        isActive: false,
        displayLocation: 'home',
        delaySeconds: 5,
        maxUsesPerDay: 1,
        segments: _getDefaultSegments(),
        updatedAt: DateTime.now(),
      );

      return await saveRouletteConfig(defaultConfig);
    } catch (e) {
      print('Error initializing default config: $e');
      return false;
    }
  }

  // Get default segments
  List<RouletteSegment> _getDefaultSegments() {
    return [
      RouletteSegment(
        id: '1',
        label: '+100 points',
        rewardId: 'bonus_points_100',
        probability: 30.0,
        color: const Color(0xFFFFD700), // Gold
        type: 'bonus_points',
        value: 100,
        weight: 30.0,
      ),
      RouletteSegment(
        id: '2',
        label: 'Pizza offerte',
        rewardId: 'free_pizza',
        probability: 5.0,
        color: const Color(0xFFFF6B6B), // Red
        type: 'free_pizza',
        weight: 5.0,
      ),
      RouletteSegment(
        id: '3',
        label: '+50 points',
        rewardId: 'bonus_points_50',
        probability: 25.0,
        color: const Color(0xFF4ECDC4), // Teal
        type: 'bonus_points',
        value: 50,
        weight: 25.0,
      ),
      RouletteSegment(
        id: '4',
        label: 'Raté !',
        rewardId: 'nothing',
        probability: 20.0,
        color: const Color(0xFF95A5A6), // Gray
        type: 'nothing',
        weight: 20.0,
      ),
      RouletteSegment(
        id: '5',
        label: 'Boisson offerte',
        rewardId: 'free_drink',
        probability: 10.0,
        color: const Color(0xFF3498DB), // Blue
        type: 'free_drink',
        weight: 10.0,
      ),
      RouletteSegment(
        id: '6',
        label: 'Dessert offert',
        rewardId: 'free_dessert',
        probability: 10.0,
        color: const Color(0xFF9B59B6), // Purple
        type: 'free_dessert',
        weight: 10.0,
      ),
    ];
  }

  // Check if user can spin today
  Future<bool> canUserSpinToday(String userId) async {
    try {
      final config = await getRouletteConfig();
      if (config == null || !config.isCurrentlyActive) return false;

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final snapshot = await _firestore
          .collection('user_roulette_spins')
          .where('userId', isEqualTo: userId)
          .where('spunAt', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .get();

      return snapshot.docs.length < config.maxUsesPerDay;
    } catch (e) {
      print('Error checking user spin availability: $e');
      return false;
    }
  }

  // Record a spin
  Future<bool> recordSpin(
    String userId,
    RouletteSegment segment,
  ) async {
    try {
      await _firestore.collection('user_roulette_spins').add({
        'userId': userId,
        'segmentId': segment.id,
        'segmentType': segment.type,
        'segmentLabel': segment.label,
        'value': segment.value,
        'spunAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error recording spin: $e');
      return false;
    }
  }

  // Get user's spin history
  Future<List<Map<String, dynamic>>> getUserSpinHistory(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('user_roulette_spins')
          .where('userId', isEqualTo: userId)
          .orderBy('spunAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting user spin history: $e');
      return [];
    }
  }

  // Spin the wheel (probability-based random selection)
  RouletteSegment spinWheel(List<RouletteSegment> segments) {
    if (segments.isEmpty) {
      throw Exception('No segments available');
    }

    final totalProbability = segments.fold<double>(
      0,
      (sum, segment) => sum + segment.probability,
    );

    final random = Random();
    double randomValue = random.nextDouble() * totalProbability;

    for (final segment in segments) {
      randomValue -= segment.probability;
      if (randomValue <= 0) {
        return segment;
      }
    }

    // Fallback (shouldn't happen)
    return segments.last;
  }

  // Stream for real-time updates
  Stream<RouletteConfig?> watchRouletteConfig() {
    return _firestore
        .collection(_collection)
        .doc(_configDocId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return RouletteConfig.fromMap(snapshot.data()!);
      }
      return null;
    });
  }
}
