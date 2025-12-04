// lib/src/services/reward_service.dart
// Central service for managing reward tickets in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reward_action.dart';
import '../models/reward_ticket.dart';
import '../providers/restaurant_provider.dart';

/// Service for managing reward tickets
/// 
/// Handles CRUD operations for reward tickets in Firestore.
/// Tickets are stored in: restaurants/{appId}/reward_tickets/{userId}/tickets/{ticketId}
class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;

  RewardService({required this.appId});

  /// Create a new reward ticket for a user
  /// 
  /// Parameters:
  /// - [userId]: The user ID who will receive the ticket
  /// - [action]: The reward action (what the ticket grants)
  /// - [validity]: How long the ticket is valid (duration from now)
  /// 
  /// Returns the created ticket
  Future<RewardTicket> createTicket({
    required String userId,
    required RewardAction action,
    required Duration validity,
  }) async {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(validity);
      
      // Generate a new document reference (auto-generates ID) - scoped to restaurant
      final docRef = _firestore
          .collection('restaurants')
          .doc(appId)
          .collection('reward_tickets')
          .doc(userId)
          .collection('tickets')
          .doc();
      
      final ticket = RewardTicket(
        id: docRef.id,
        userId: userId,
        action: action,
        createdAt: now,
        expiresAt: expiresAt,
        isUsed: false,
        usedAt: null,
      );
      
      // Save to Firestore
      await docRef.set(ticket.toMap());
      
      return ticket;
    } catch (e) {
      print('Error creating reward ticket: $e');
      rethrow;
    }
  }

  /// Get all tickets for a user
  /// 
  /// Returns tickets ordered by creation date (most recent first)
  Future<List<RewardTicket>> getUserTickets(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('restaurants')
          .doc(appId)
          .collection('reward_tickets')
          .doc(userId)
          .collection('tickets')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => RewardTicket.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting user tickets: $e');
      return [];
    }
  }

  /// Mark a ticket as used
  /// 
  /// Sets isUsed to true and records the usedAt timestamp
  Future<void> markTicketUsed(String userId, String ticketId) async {
    try {
      await _firestore
          .collection('restaurants')
          .doc(appId)
          .collection('reward_tickets')
          .doc(userId)
          .collection('tickets')
          .doc(ticketId)
          .update({
        'isUsed': true,
        'usedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error marking ticket as used: $e');
      rethrow;
    }
  }

  /// Watch tickets in real-time for a user
  /// 
  /// Returns a stream that emits updated ticket lists whenever
  /// tickets are added, modified, or removed
  Stream<List<RewardTicket>> watchUserTickets(String userId) {
    return _firestore
        .collection('restaurants')
        .doc(appId)
        .collection('reward_tickets')
        .doc(userId)
        .collection('tickets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RewardTicket.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get a single ticket by ID
  Future<RewardTicket?> getTicket(String userId, String ticketId) async {
    try {
      final doc = await _firestore
          .collection('restaurants')
          .doc(appId)
          .collection('reward_tickets')
          .doc(userId)
          .collection('tickets')
          .doc(ticketId)
          .get();
      
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      
      return RewardTicket.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('Error getting ticket: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // EXTENSIBILITY HOOKS FOR FUTURE FEATURES
  // ═══════════════════════════════════════════════════════════════

  /// Create ticket from loyalty points redemption
  /// 
  /// TODO: Implement when loyalty system is ready
  /// This method will handle creating tickets when users redeem loyalty points
  Future<RewardTicket> createTicketFromLoyalty({
    required String userId,
    required int pointsCost,
    required RewardAction action,
    Duration validity = const Duration(days: 30),
  }) async {
    // TODO: Implement loyalty points deduction
    // TODO: Validate user has enough points
    // TODO: Record loyalty transaction
    
    // For now, just create the ticket
    return createTicket(
      userId: userId,
      action: action.copyWith(source: 'loyalty'),
      validity: validity,
    );
  }

  /// Create ticket from promotional campaign
  /// 
  /// TODO: Implement when promo system is ready
  /// This method will handle creating tickets from marketing campaigns
  Future<RewardTicket> createTicketFromPromo({
    required String userId,
    required String campaignId,
    required RewardAction action,
    Duration validity = const Duration(days: 15),
  }) async {
    // TODO: Implement campaign tracking
    // TODO: Validate campaign is active
    // TODO: Check user eligibility
    // TODO: Record campaign participation
    
    // For now, just create the ticket
    return createTicket(
      userId: userId,
      action: action.copyWith(source: 'promo'),
      validity: validity,
    );
  }

  /// Delete expired tickets (cleanup utility)
  /// 
  /// Can be called periodically to clean up old tickets
  Future<int> deleteExpiredTickets(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('restaurants')
          .doc(appId)
          .collection('reward_tickets')
          .doc(userId)
          .collection('tickets')
          .where('isUsed', isEqualTo: true)
          .get();
      
      int deleted = 0;
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        final ticket = RewardTicket.fromMap(doc.data(), doc.id);
        // Delete tickets used more than 90 days ago
        if (ticket.usedAt != null && 
            now.difference(ticket.usedAt!).inDays > 90) {
          batch.delete(doc.reference);
          deleted++;
        }
      }
      
      await batch.commit();
      return deleted;
    } catch (e) {
      print('Error deleting expired tickets: $e');
      return 0;
    }
  }
}

/// Provider for RewardService scoped to the current restaurant
final rewardServiceProvider = Provider<RewardService>(
  (ref) {
    final appId = ref.watch(currentRestaurantProvider).id;
    return RewardService(appId: appId);
  },
  dependencies: [currentRestaurantProvider],
);
