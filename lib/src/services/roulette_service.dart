// lib/src/services/roulette_service.dart
// Facade service that combines roulette rules and segments
// Uses the unified Firestore structure: config/roulette_rules + roulette_segments

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/roulette_config.dart';
import 'roulette_rules_service.dart';
import 'roulette_segment_service.dart';
import 'dart:math';

/// Facade service for roulette functionality
/// 
/// This service combines RouletteRulesService and RouletteSegmentService
/// to provide a unified interface for the roulette wheel.
/// 
/// DEPRECATED METHODS: getRouletteConfig(), saveRouletteConfig(), initializeDefaultConfig()
/// Use RouletteRulesService and RouletteSegmentService directly instead.
class RouletteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RouletteRulesService _rulesService = RouletteRulesService();
  final RouletteSegmentService _segmentService = RouletteSegmentService();

  // Record a spin (stores in user_roulette_spins for legacy tracking)
  Future<bool> recordSpin(
    String userId,
    RouletteSegment segment,
  ) async {
    try {
      await _firestore.collection('user_roulette_spins').add({
        'userId': userId,
        'segmentId': segment.id,
        'segmentType': segment.type ?? segment.rewardId,
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
}
