// lib/src/services/roulette_service.dart
// Facade service that combines roulette rules and segments
// Uses the unified Firestore structure: config/roulette_rules + roulette_segments

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/roulette_config.dart';
import '../providers/restaurant_provider.dart';
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
  final String appId;
  late final RouletteRulesService _rulesService;
  late final RouletteSegmentService _segmentService;

  RouletteService({required this.appId}) {
    _rulesService = RouletteRulesService(appId: appId);
    _segmentService = RouletteSegmentService(appId: appId);
  }

  /// Scoped collection for user roulette spins
  CollectionReference get _userRouletteSpinsCollection =>
      _firestore.collection('restaurants').doc(appId).collection('user_roulette_spins');

  /// Scoped collection for roulette rate limit
  CollectionReference get _rouletteRateLimitCollection =>
      _firestore.collection('restaurants').doc(appId).collection('roulette_rate_limit');

  // Record a spin (stores in user_roulette_spins)
  // Rate limiting is enforced server-side by Firestore security rules
  Future<bool> recordSpin(
    String userId,
    RouletteSegment segment,
  ) async {
    try {
      // IMPORTANT: Create the spin document FIRST
      // The Firestore security rule checks the OLD timestamp in roulette_rate_limit
      // If we update rate limit first, the rule would see the new timestamp and reject
      await _userRouletteSpinsCollection.add({
        'userId': userId,
        'segmentId': segment.id,
        'segmentType': segment.type ?? segment.rewardId,
        'segmentLabel': segment.label,
        'value': segment.value,
        'spunAt': DateTime.now().toIso8601String(),
      });
      
      // Update rate limit tracker AFTER successful spin creation
      // This timestamp will be checked on the NEXT spin attempt
      final rateLimitDoc = _rouletteRateLimitCollection.doc(userId);
      await rateLimitDoc.set({
        'lastActionAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('Error recording spin: $e');
      rethrow; // Rethrow to propagate Firestore errors (including rate limit violations)
    }
  }

  // Get user's spin history
  Future<List<Map<String, dynamic>>> getUserSpinHistory(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _userRouletteSpinsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('spunAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
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

/// Provider for RouletteService scoped to the current restaurant
final rouletteServiceProvider = Provider<RouletteService>((ref) {
  final appId = ref.watch(currentRestaurantProvider).id;
  return RouletteService(appId: appId);
});
