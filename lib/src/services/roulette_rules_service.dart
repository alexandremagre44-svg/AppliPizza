// lib/src/services/roulette_rules_service.dart
// Service for managing roulette eligibility rules and validation

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/restaurant_provider.dart';

/// Status result for roulette eligibility check
class RouletteStatus {
  /// Whether the user can spin the roulette now
  final bool canSpin;
  
  /// Reason why user cannot spin (null if canSpin is true)
  final String? reason;
  
  /// Next time the user will be eligible (null if already eligible)
  final DateTime? nextEligibleAt;

  const RouletteStatus({
    required this.canSpin,
    this.reason,
    this.nextEligibleAt,
  });

  factory RouletteStatus.allowed() {
    return const RouletteStatus(canSpin: true);
  }

  factory RouletteStatus.denied(String reason, {DateTime? nextEligibleAt}) {
    return RouletteStatus(
      canSpin: false,
      reason: reason,
      nextEligibleAt: nextEligibleAt,
    );
  }
}

/// Rules configuration for the roulette
class RouletteRules {
  /// Minimum delay in hours between spins (cooldown)
  final int cooldownHours;
  
  /// Maximum spins per day (0 = unlimited)
  final int maxPlaysPerDay;
  
  /// Maximum spins per week (0 = unlimited) - legacy field
  final int weeklyLimit;
  
  /// Maximum spins per month (0 = unlimited) - legacy field
  final int monthlyLimit;
  
  /// Hour when roulette becomes available (0-23)
  final int allowedStartHour;
  
  /// Hour when roulette becomes unavailable (0-23)
  final int allowedEndHour;
  
  /// Global enable/disable flag
  final bool isEnabled;
  
  /// Message to display when roulette is disabled
  final String messageDisabled;
  
  /// Message to display when roulette is unavailable (no segments, not configured)
  final String messageUnavailable;
  
  /// Message to display when user is in cooldown period
  final String messageCooldown;

  const RouletteRules({
    this.cooldownHours = 24,
    this.maxPlaysPerDay = 1,
    this.weeklyLimit = 0,
    this.monthlyLimit = 0,
    this.allowedStartHour = 0,
    this.allowedEndHour = 23,
    this.isEnabled = true,
    this.messageDisabled = 'La roulette est actuellement désactivée',
    this.messageUnavailable = 'La roulette n\'est pas disponible',
    this.messageCooldown = 'Revenez demain pour retenter votre chance',
  });

  Map<String, dynamic> toMap() {
    return {
      'cooldownHours': cooldownHours,
      'maxPlaysPerDay': maxPlaysPerDay,
      'weeklyLimit': weeklyLimit,
      'monthlyLimit': monthlyLimit,
      'allowedStartHour': allowedStartHour,
      'allowedEndHour': allowedEndHour,
      'isEnabled': isEnabled,
      'messageDisabled': messageDisabled,
      'messageUnavailable': messageUnavailable,
      'messageCooldown': messageCooldown,
    };
  }

  factory RouletteRules.fromMap(Map<String, dynamic> map) {
    return RouletteRules(
      cooldownHours: map['cooldownHours'] as int? ?? map['minDelayHours'] as int? ?? 24,
      maxPlaysPerDay: map['maxPlaysPerDay'] as int? ?? map['dailyLimit'] as int? ?? 1,
      weeklyLimit: map['weeklyLimit'] as int? ?? 0,
      monthlyLimit: map['monthlyLimit'] as int? ?? 0,
      allowedStartHour: map['allowedStartHour'] as int? ?? 0,
      allowedEndHour: map['allowedEndHour'] as int? ?? 23,
      isEnabled: map['isEnabled'] as bool? ?? true,
      messageDisabled: map['messageDisabled'] as String? ?? 'La roulette est actuellement désactivée',
      messageUnavailable: map['messageUnavailable'] as String? ?? 'La roulette n\'est pas disponible',
      messageCooldown: map['messageCooldown'] as String? ?? 'Revenez demain pour retenter votre chance',
    );
  }

  RouletteRules copyWith({
    int? cooldownHours,
    int? maxPlaysPerDay,
    int? weeklyLimit,
    int? monthlyLimit,
    int? allowedStartHour,
    int? allowedEndHour,
    bool? isEnabled,
    String? messageDisabled,
    String? messageUnavailable,
    String? messageCooldown,
  }) {
    return RouletteRules(
      cooldownHours: cooldownHours ?? this.cooldownHours,
      maxPlaysPerDay: maxPlaysPerDay ?? this.maxPlaysPerDay,
      weeklyLimit: weeklyLimit ?? this.weeklyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      allowedStartHour: allowedStartHour ?? this.allowedStartHour,
      allowedEndHour: allowedEndHour ?? this.allowedEndHour,
      isEnabled: isEnabled ?? this.isEnabled,
      messageDisabled: messageDisabled ?? this.messageDisabled,
      messageUnavailable: messageUnavailable ?? this.messageUnavailable,
      messageCooldown: messageCooldown ?? this.messageCooldown,
    );
  }
}

/// Service for managing roulette rules and eligibility
class RouletteRulesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;

  RouletteRulesService({required this.appId});

  /// Scoped collection for config
  DocumentReference get _rulesDoc => 
      _firestore.collection('restaurants').doc(appId).collection('config').doc('roulette_rules');

  /// Scoped collection for users
  CollectionReference get _usersCollection =>
      _firestore.collection('restaurants').doc(appId).collection('users');

  /// Scoped collection for roulette history
  CollectionReference get _rouletteHistoryCollection =>
      _firestore.collection('restaurants').doc(appId).collection('roulette_history');

  /// Scoped collection for user roulette spins (legacy)
  CollectionReference get _userRouletteSpinsCollection =>
      _firestore.collection('restaurants').doc(appId).collection('user_roulette_spins');

  /// Get current roulette rules from Firestore
  /// Returns null if document doesn't exist (not configured)
  Future<RouletteRules?> getRules() async {
    try {
      final doc = await _rulesDoc.get();
      
      if (doc.exists && doc.data() != null) {
        return RouletteRules.fromMap(doc.data() as Map<String, dynamic>);
      }
      
      // Return null if not configured (document doesn't exist)
      return null;
    } catch (e) {
      print('Error getting roulette rules: $e');
      return null;
    }
  }

  /// Save roulette rules to Firestore
  Future<void> saveRules(RouletteRules rules) async {
    try {
      await _rulesDoc.set(rules.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving roulette rules: $e');
      rethrow;
    }
  }

  /// Check if user is eligible to spin the roulette
  Future<RouletteStatus> checkEligibility(String userId) async {
    try {
      // Get rules
      final rules = await getRules();
      
      // Check if roulette is configured
      if (rules == null) {
        return RouletteStatus.denied('La roulette n\'est pas encore configurée.');
      }
      
      // Check if roulette is globally enabled
      if (!rules.isEnabled) {
        return RouletteStatus.denied(rules.messageDisabled);
      }
      
      // Check time slot restrictions
      final now = DateTime.now();
      final currentHour = now.hour;
      
      if (!_isWithinAllowedHours(currentHour, rules)) {
        final nextAvailable = _getNextAllowedTime(now, rules);
        return RouletteStatus.denied(
          'La roulette est disponible de ${rules.allowedStartHour}h à ${rules.allowedEndHour}h',
          nextEligibleAt: nextAvailable,
        );
      }
      
      // Get user document (scoped)
      final userDoc = await _usersCollection.doc(userId).get();
      
      if (!userDoc.exists) {
        return RouletteStatus.denied('Utilisateur non trouvé');
      }
      
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      
      // Check if user is banned
      if (userData['isBanned'] == true) {
        return RouletteStatus.denied('Compte suspendu');
      }
      
      // Check cooldown (lastSpinAt)
      final lastSpinAt = _parseDateTime(userData['lastSpinAt']);
      if (lastSpinAt != null) {
        final hoursSinceLastSpin = now.difference(lastSpinAt).inHours;
        if (hoursSinceLastSpin < rules.cooldownHours) {
          final nextAvailable = lastSpinAt.add(Duration(hours: rules.cooldownHours));
          final hoursRemaining = rules.cooldownHours - hoursSinceLastSpin;
          return RouletteStatus.denied(
            'Prochain tirage disponible dans $hoursRemaining heure${hoursRemaining > 1 ? 's' : ''}',
            nextEligibleAt: nextAvailable,
          );
        }
      }
      
      // Check daily limit
      if (rules.maxPlaysPerDay > 0) {
        final todayCount = await _getSpinCount(userId, _getStartOfDay(now));
        if (todayCount >= rules.maxPlaysPerDay) {
          final tomorrow = now.add(const Duration(days: 1));
          final nextAvailable = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, rules.allowedStartHour);
          return RouletteStatus.denied(
            'Vous avez déjà joué aujourd\'hui',
            nextEligibleAt: nextAvailable,
          );
        }
      }
      
      // Check weekly limit
      if (rules.weeklyLimit > 0) {
        final weekStart = _getStartOfWeek(now);
        final weekCount = await _getSpinCount(userId, weekStart);
        if (weekCount >= rules.weeklyLimit) {
          final nextWeek = weekStart.add(const Duration(days: 7));
          return RouletteStatus.denied(
            'Limite hebdomadaire atteinte',
            nextEligibleAt: nextWeek,
          );
        }
      }
      
      // Check monthly limit
      if (rules.monthlyLimit > 0) {
        final monthStart = _getStartOfMonth(now);
        final monthCount = await _getSpinCount(userId, monthStart);
        if (monthCount >= rules.monthlyLimit) {
          final nextMonth = DateTime(now.year, now.month + 1, 1, rules.allowedStartHour);
          return RouletteStatus.denied(
            'Limite mensuelle atteinte',
            nextEligibleAt: nextMonth,
          );
        }
      }
      
      // All checks passed
      return RouletteStatus.allowed();
    } catch (e) {
      print('Error checking eligibility: $e');
      return RouletteStatus.denied('Erreur lors de la vérification');
    }
  }

  /// Record a spin in audit trail
  Future<void> recordSpinAudit({
    required String userId,
    required String segmentId,
    required String resultType,
    String? ticketId,
    DateTime? expiration,
    String? deviceInfo,
  }) async {
    try {
      final now = DateTime.now();
      final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      // Create entry in audit trail (scoped)
      await _rouletteHistoryCollection
          .doc(userId)
          .collection(dateKey)
          .add({
        'hour': now.hour,
        'resultType': resultType,
        'segmentId': segmentId,
        'ticketId': ticketId,
        'expiration': expiration?.toIso8601String(),
        'deviceInfo': deviceInfo ?? 'unknown',
        'usedAt': null,
        'createdAt': now.toIso8601String(),
      });
      
      // Update user's lastSpinAt (scoped)
      await _usersCollection.doc(userId).set({
        'lastSpinAt': now.toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error recording spin audit: $e');
    }
  }

  /// Get count of spins since a specific date
  Future<int> _getSpinCount(String userId, DateTime since) async {
    try {
      final sinceStr = since.toIso8601String();
      
      // Count from roulette_history collections (scoped)
      // This is a simplified approach - in production you might want to use aggregation
      final userHistoryRef = _rouletteHistoryCollection.doc(userId);
      
      final snapshot = await userHistoryRef
          .collection('_count')
          .where('timestamp', isGreaterThanOrEqualTo: sinceStr)
          .get();
      
      // Fallback: count from user_roulette_spins (legacy, scoped)
      if (snapshot.docs.isEmpty) {
        final legacySnapshot = await _userRouletteSpinsCollection
            .where('userId', isEqualTo: userId)
            .where('spunAt', isGreaterThanOrEqualTo: sinceStr)
            .get();
        return legacySnapshot.docs.length;
      }
      
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting spin count: $e');
      // Fallback to checking user_roulette_spins (scoped)
      try {
        final snapshot = await _userRouletteSpinsCollection
            .where('userId', isEqualTo: userId)
            .where('spunAt', isGreaterThanOrEqualTo: since.toIso8601String())
            .get();
        return snapshot.docs.length;
      } catch (e2) {
        print('Error in fallback spin count: $e2');
        return 0;
      }
    }
  }

  /// Check if current hour is within allowed hours
  bool _isWithinAllowedHours(int currentHour, RouletteRules rules) {
    if (rules.allowedStartHour <= rules.allowedEndHour) {
      // Normal case: 11h - 22h
      return currentHour >= rules.allowedStartHour && 
             currentHour <= rules.allowedEndHour;
    } else {
      // Crosses midnight: 22h - 2h
      return currentHour >= rules.allowedStartHour || 
             currentHour <= rules.allowedEndHour;
    }
  }

  /// Get next allowed time based on rules
  DateTime _getNextAllowedTime(DateTime now, RouletteRules rules) {
    final currentHour = now.hour;
    
    if (rules.allowedStartHour <= rules.allowedEndHour) {
      // Normal case
      if (currentHour < rules.allowedStartHour) {
        // Same day
        return DateTime(now.year, now.month, now.day, rules.allowedStartHour);
      } else {
        // Next day
        final tomorrow = now.add(const Duration(days: 1));
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, rules.allowedStartHour);
      }
    } else {
      // Crosses midnight
      if (currentHour <= rules.allowedEndHour) {
        // We're in the early morning allowed period, next is tonight
        return DateTime(now.year, now.month, now.day, rules.allowedStartHour);
      } else if (currentHour < rules.allowedStartHour) {
        // We're in the forbidden middle period, next is tonight
        return DateTime(now.year, now.month, now.day, rules.allowedStartHour);
      } else {
        // We're in the late night allowed period, next is early morning
        final tomorrow = now.add(const Duration(days: 1));
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0);
      }
    }
  }

  /// Parse DateTime from various formats
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    
    if (value is Timestamp) {
      return value.toDate();
    }
    
    return null;
  }

  /// Get start of current day
  DateTime _getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get start of current week (Monday)
  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    final daysToSubtract = weekday - 1;
    final monday = date.subtract(Duration(days: daysToSubtract));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Get start of current month
  DateTime _getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Watch rules in real-time
  /// Emits null if document doesn't exist (not configured)
  Stream<RouletteRules?> watchRules() {
    return _rulesDoc.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return RouletteRules.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}

/// Provider for RouletteRulesService scoped to the current restaurant
final rouletteRulesServiceProvider = Provider<RouletteRulesService>((ref) {
  final appId = ref.watch(currentRestaurantProvider).id;
  return RouletteRulesService(appId: appId);
});
