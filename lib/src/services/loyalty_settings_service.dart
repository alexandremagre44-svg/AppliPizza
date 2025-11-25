// lib/src/services/loyalty_settings_service.dart
// Service for managing loyalty program settings in Firestore
//
// New Firestore structure:
// restaurants/{restaurantId}/builder_settings/loyalty_settings

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loyalty_settings.dart';
import '../core/firestore_paths.dart';

class LoyaltySettingsService {
  // Get loyalty settings
  Future<LoyaltySettings> getLoyaltySettings() async {
    try {
      final doc = await FirestorePaths.loyaltySettingsDoc().get();
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
      await FirestorePaths.loyaltySettingsDoc().set(
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
      final existing = await FirestorePaths.loyaltySettingsDoc().get();
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
    return FirestorePaths.loyaltySettingsDoc()
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
