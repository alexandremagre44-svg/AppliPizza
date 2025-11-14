// lib/src/services/loyalty_settings_service.dart
// Service for managing loyalty program settings in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_delizza/src/features/loyalty/data/models/loyalty_settings.dart';

class LoyaltySettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'loyalty_settings';
  static const String _configDocId = 'main';

  // Get loyalty settings
  Future<LoyaltySettings> getLoyaltySettings() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_configDocId).get();
      if (doc.exists && doc.data() != null) {
        return LoyaltySettings.fromJson(doc.data()!);
      }
      return LoyaltySettings.defaultSettings();
    } catch (e) {
      print('Error getting loyalty settings: $e');
      return LoyaltySettings.defaultSettings();
    }
  }

  // Save loyalty settings
  Future<bool> saveLoyaltySettings(LoyaltySettings settings) async {
    try {
      await _firestore.collection(_collection).doc(_configDocId).set(
            settings.toJson(),
            SetOptions(merge: true),
          );
      return true;
    } catch (e) {
      print('Error saving loyalty settings: $e');
      return false;
    }
  }

  // Initialize with default settings if doesn't exist
  Future<bool> initializeDefaultSettings() async {
    try {
      final existing = await _firestore.collection(_collection).doc(_configDocId).get();
      if (existing.exists) return true;

      final defaultSettings = LoyaltySettings.defaultSettings();
      return await saveLoyaltySettings(defaultSettings);
    } catch (e) {
      print('Error initializing default settings: $e');
      return false;
    }
  }

  // Stream for real-time updates
  Stream<LoyaltySettings> watchLoyaltySettings() {
    return _firestore
        .collection(_collection)
        .doc(_configDocId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return LoyaltySettings.fromJson(snapshot.data()!);
      }
      return LoyaltySettings.defaultSettings();
    });
  }

  // Helper method to calculate loyalty level based on points
  String calculateLoyaltyLevel(int points, LoyaltySettings settings) {
    if (points >= settings.goldThreshold) {
      return 'Gold';
    } else if (points >= settings.silverThreshold) {
      return 'Silver';
    } else {
      return 'Bronze';
    }
  }
}
