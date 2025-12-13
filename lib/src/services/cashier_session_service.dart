// lib/src/services/cashier_session_service.dart
/// 
/// Service for managing cashier sessions
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/cashier_session.dart';
import '../models/payment_method.dart';
import '../core/firestore_paths.dart';

const _uuid = Uuid();

/// Cashier Session Service
class CashierSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;
  
  CashierSessionService({required this.appId});
  
  /// Sessions collection
  CollectionReference get _sessionsCollection => 
      _firestore.collection('restaurants').doc(appId).collection('cashier_sessions');
  
  /// Open a new cashier session
  Future<String> openSession({
    required String staffId,
    required String staffName,
    required double openingCash,
    String? notes,
  }) async {
    // Check if there's already an active session for this staff
    final activeSession = await getActiveSession(staffId);
    if (activeSession != null) {
      throw Exception('Une session est déjà ouverte pour cet utilisateur');
    }
    
    final session = CashierSession(
      id: _uuid.v4(),
      restaurantId: appId,
      staffId: staffId,
      staffName: staffName,
      openedAt: DateTime.now(),
      openingCash: openingCash,
      status: SessionStatus.open,
      notes: notes,
    );
    
    await _sessionsCollection.doc(session.id).set({
      ...session.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return session.id;
  }
  
  /// Close a cashier session
  Future<void> closeSession({
    required String sessionId,
    required double closingCash,
    String? notes,
  }) async {
    final sessionDoc = await _sessionsCollection.doc(sessionId).get();
    if (!sessionDoc.exists) {
      throw Exception('Session non trouvée');
    }
    
    final data = sessionDoc.data() as Map<String, dynamic>;
    final session = CashierSession.fromJson(data);
    
    if (session.status == SessionStatus.closed) {
      throw Exception('Cette session est déjà fermée');
    }
    
    // Calculate expected cash and variance
    final expectedCash = session.calculatedExpectedCash;
    final variance = closingCash - expectedCash;
    
    await _sessionsCollection.doc(sessionId).update({
      'closedAt': DateTime.now().toIso8601String(),
      'closingCash': closingCash,
      'expectedCash': expectedCash,
      'variance': variance,
      'status': SessionStatus.closed.name,
      'notes': notes ?? session.notes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  /// Add order to session
  Future<void> addOrderToSession({
    required String sessionId,
    required String orderId,
    required String paymentMethod,
    required double amount,
  }) async {
    final sessionDoc = await _sessionsCollection.doc(sessionId).get();
    if (!sessionDoc.exists) {
      throw Exception('Session non trouvée');
    }
    
    final data = sessionDoc.data() as Map<String, dynamic>;
    final session = CashierSession.fromJson(data);
    
    if (session.status == SessionStatus.closed) {
      throw Exception('Cette session est fermée');
    }
    
    // Update order list and payment totals
    final updatedOrderIds = [...session.orderIds, orderId];
    final updatedPaymentTotals = Map<String, double>.from(session.paymentTotals);
    updatedPaymentTotals[paymentMethod] = (updatedPaymentTotals[paymentMethod] ?? 0.0) + amount;
    
    await _sessionsCollection.doc(sessionId).update({
      'orderIds': updatedOrderIds,
      'paymentTotals': updatedPaymentTotals,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  /// Get active session for a staff member
  Future<CashierSession?> getActiveSession(String staffId) async {
    final snapshot = await _sessionsCollection
        .where('staffId', isEqualTo: staffId)
        .where('status', isEqualTo: SessionStatus.open.name)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) {
      return null;
    }
    
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return CashierSession.fromJson(data);
  }
  
  /// Get session by ID
  Future<CashierSession?> getSessionById(String sessionId) async {
    final doc = await _sessionsCollection.doc(sessionId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    return CashierSession.fromJson(data);
  }
  
  /// Watch active session for a staff member
  Stream<CashierSession?> watchActiveSession(String staffId) {
    return _sessionsCollection
        .where('staffId', isEqualTo: staffId)
        .where('status', isEqualTo: SessionStatus.open.name)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final data = snapshot.docs.first.data() as Map<String, dynamic>;
          return CashierSession.fromJson(data);
        });
  }
  
  /// Get session history for staff member
  Future<List<CashierSession>> getSessionHistory(String staffId, {int limit = 10}) async {
    final snapshot = await _sessionsCollection
        .where('staffId', isEqualTo: staffId)
        .orderBy('openedAt', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return CashierSession.fromJson(data);
    }).toList();
  }
  
  /// Generate session report
  SessionReport generateSessionReport(CashierSession session) {
    return SessionReport(
      session: session,
      totalOrders: session.orderCount,
      totalCollected: session.totalCollected,
      cashTotal: session.paymentTotals[PaymentMethod.cash] ?? 0.0,
      cardTotal: session.paymentTotals[PaymentMethod.card] ?? 0.0,
      offlineTotal: session.paymentTotals[PaymentMethod.offline] ?? 0.0,
      otherTotal: session.paymentTotals['other'] ?? 0.0, // Use string literal for 'other'
      expectedCash: session.expectedCash ?? session.calculatedExpectedCash,
      actualCash: session.closingCash ?? 0.0,
      variance: session.variance ?? 0.0,
    );
  }
}

/// Session report model
class SessionReport {
  final CashierSession session;
  final int totalOrders;
  final double totalCollected;
  final double cashTotal;
  final double cardTotal;
  final double offlineTotal;
  final double otherTotal;
  final double expectedCash;
  final double actualCash;
  final double variance;
  
  const SessionReport({
    required this.session,
    required this.totalOrders,
    required this.totalCollected,
    required this.cashTotal,
    required this.cardTotal,
    required this.offlineTotal,
    required this.otherTotal,
    required this.expectedCash,
    required this.actualCash,
    required this.variance,
  });
  
  bool get hasVariance => variance.abs() > 0.01;
  bool get isPositiveVariance => variance > 0.01;
  bool get isNegativeVariance => variance < -0.01;
}
