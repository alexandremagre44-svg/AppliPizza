// lib/src/services/app_texts_service.dart
// Service for managing configurable app texts in Firestore
//
// New Firestore structure:
// restaurants/{restaurantId}/builder_settings/app_texts

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_texts_config.dart';
import '../core/firestore_paths.dart';

class AppTextsService {
  final String appId;

  AppTextsService({required this.appId});

  // Get app texts configuration
  Future<AppTextsConfig> getAppTextsConfig() async {
    try {
      final doc = await FirestorePaths.appTextsDoc(appId).get();
      if (doc.exists && doc.data() != null) {
        return AppTextsConfig.fromJson(doc.data()!);
      }
      return AppTextsConfig.defaultConfig();
    } catch (e) {
      print('Error getting app texts config: $e');
      return AppTextsConfig.defaultConfig();
    }
  }

  // Save complete app texts configuration
  Future<bool> saveAppTextsConfig(AppTextsConfig config) async {
    try {
      await FirestorePaths.appTextsDoc(appId).set(
            config.toJson(),
            SetOptions(merge: true),
          );
      return true;
    } catch (e) {
      print('Error saving app texts config: $e');
      return false;
    }
  }

  // Update individual module texts
  Future<bool> updateHomeTexts(HomeTexts texts) async {
    try {
      await FirestorePaths.appTextsDoc(appId).update({
        'home': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating home texts: $e');
      return false;
    }
  }

  Future<bool> updateProfileTexts(ProfileTexts texts) async {
    try {
      await FirestorePaths.appTextsDoc(appId).update({
        'profile': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating profile texts: $e');
      return false;
    }
  }

  Future<bool> updateRewardsTexts(RewardsTexts texts) async {
    try {
      await FirestorePaths.appTextsDoc(appId).update({
        'rewards': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating rewards texts: $e');
      return false;
    }
  }

  Future<bool> updateRouletteTexts(RouletteTexts texts) async {
    try {
      await FirestorePaths.appTextsDoc(appId).update({
        'roulette': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating roulette texts: $e');
      return false;
    }
  }

  Future<bool> updateLoyaltyTexts(LoyaltyTexts texts) async {
    try {
      await FirestorePaths.appTextsDoc(appId).update({
        'loyalty': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating loyalty texts: $e');
      return false;
    }
  }

  Future<bool> updateCatalogTexts(CatalogTexts texts) async {
    try {
      await FirestorePaths.appTextsDoc(appId).update({
        'catalog': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating catalog texts: $e');
      return false;
    }
  }

  Future<bool> updateCartTexts(CartTexts texts) async {
    try {
      await FirestorePaths.appTextsDoc(appId).update({
        'cart': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating cart texts: $e');
      return false;
    }
  }

  Future<bool> updateCheckoutTexts(CheckoutTexts texts) async {
    try {
      await FirestorePaths.appTextsDoc(appId).update({
        'checkout': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating checkout texts: $e');
      return false;
    }
  }

  Future<bool> updateAuthTexts(AuthTexts texts) async {
    try {
      await FirestorePaths.appTextsDoc(appId).update({
        'auth': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating auth texts: $e');
      return false;
    }
  }

  Future<bool> updateAdminTexts(AdminTexts texts) async {
    try {
      await FirestorePaths.appTextsDoc(appId).update({
        'admin': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating admin texts: $e');
      return false;
    }
  }

  Future<bool> updateErrorTexts(ErrorTexts texts) async {
    try {
      await FirestorePaths.appTextsDoc(appId).update({
        'errors': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating error texts: $e');
      return false;
    }
  }

  Future<bool> updateNotificationTexts(NotificationTexts texts) async {
    try {
      await FirestorePaths.appTextsDoc(appId).update({
        'notifications': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating notification texts: $e');
      return false;
    }
  }

  // Initialize with default config if doesn't exist
  Future<bool> initializeDefaultConfig() async {
    try {
      final existing = await FirestorePaths.appTextsDoc(appId).get();
      if (existing.exists) return true;

      final defaultConfig = AppTextsConfig.defaultConfig();
      return await saveAppTextsConfig(defaultConfig);
    } catch (e) {
      print('Error initializing default config: $e');
      return false;
    }
  }

  // Stream for real-time updates
  Stream<AppTextsConfig> watchAppTextsConfig() {
    return FirestorePaths.appTextsDoc(appId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return AppTextsConfig.fromJson(snapshot.data()!);
      }
      return AppTextsConfig.defaultConfig();
    });
  }
}
