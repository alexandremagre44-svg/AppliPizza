// lib/src/services/roulette_settings_service.dart
// Service for managing roulette rate limit settings (configurable from admin)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/restaurant_provider.dart';

/// Service to manage the roulette cooldown limit configuration
/// 
/// Stores a single configuration document in /restaurants/{appId}/config/roulette_settings
/// with the field limitSeconds (rate limit in seconds).
/// 
/// This value is used by Firestore security rules to enforce server-side
/// rate limiting on roulette spins, ensuring security cannot be bypassed.
class RouletteSettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;
  static const int _defaultLimitSeconds = 10;

  RouletteSettingsService({required this.appId});

  /// Get the scoped settings document reference
  DocumentReference get _settingsDoc =>
      _firestore.collection('restaurants').doc(appId).collection('config').doc('roulette_settings');

  /// Get the current rate limit in seconds
  /// Returns the configured limit from Firestore, or default (10 seconds) if not set
  Future<int> getLimitSeconds() async {
    try {
      final doc = await _settingsDoc.get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['limitSeconds'] as int? ?? _defaultLimitSeconds;
      }
      
      // Document doesn't exist, return default
      return _defaultLimitSeconds;
    } catch (e) {
      print('Error getting roulette limit seconds: $e');
      return _defaultLimitSeconds;
    }
  }

  /// Update the rate limit in seconds
  /// 
  /// [seconds] must be between 1 and 3600 (1 hour max)
  /// Updates the Firestore document that is read by security rules
  Future<void> updateLimitSeconds(int seconds) async {
    if (seconds < 1 || seconds > 3600) {
      throw ArgumentError('limitSeconds must be between 1 and 3600');
    }
    
    try {
      await _settingsDoc.set({
        'limitSeconds': seconds,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating roulette limit seconds: $e');
      rethrow;
    }
  }

  /// Watch the rate limit in real-time
  /// Emits the limit in seconds whenever it changes
  Stream<int> watchLimitSeconds() {
    return _settingsDoc.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data['limitSeconds'] as int? ?? _defaultLimitSeconds;
      }
      return _defaultLimitSeconds;
    });
  }

  /// Initialize the document with default value if it doesn't exist
  /// This is useful for first-time setup
  Future<void> initializeIfNeeded() async {
    try {
      final doc = await _settingsDoc.get();
      
      if (!doc.exists) {
        await updateLimitSeconds(_defaultLimitSeconds);
      }
    } catch (e) {
      print('Error initializing roulette settings: $e');
    }
  }
}

/// Provider for RouletteSettingsService scoped to the current restaurant
final rouletteSettingsServiceProvider = Provider<RouletteSettingsService>((ref) {
  final appId = ref.watch(currentRestaurantProvider).id;
  return RouletteSettingsService(appId: appId);
});
