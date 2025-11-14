// lib/src/services/app_texts_service.dart
// Service for managing configurable app texts in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_delizza/src/features/home/data/models/app_texts_config.dart';

class AppTextsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'app_texts_config';
  static const String _configDocId = 'main';

  // Get app texts configuration
  Future<AppTextsConfig> getAppTextsConfig() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_configDocId).get();
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
      await _firestore.collection(_collection).doc(_configDocId).set(
            config.toJson(),
            SetOptions(merge: true),
          );
      return true;
    } catch (e) {
      print('Error saving app texts config: $e');
      return false;
    }
  }

  // Update general texts
  Future<bool> updateGeneralTexts(GeneralTexts texts) async {
    try {
      await _firestore.collection(_collection).doc(_configDocId).update({
        'general': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating general texts: $e');
      return false;
    }
  }

  // Update order messages
  Future<bool> updateOrderMessages(OrderMessages messages) async {
    try {
      await _firestore.collection(_collection).doc(_configDocId).update({
        'orderMessages': messages.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating order messages: $e');
      return false;
    }
  }

  // Update error messages
  Future<bool> updateErrorMessages(ErrorMessages messages) async {
    try {
      await _firestore.collection(_collection).doc(_configDocId).update({
        'errorMessages': messages.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating error messages: $e');
      return false;
    }
  }

  // Update loyalty texts
  Future<bool> updateLoyaltyTexts(LoyaltyTexts texts) async {
    try {
      await _firestore.collection(_collection).doc(_configDocId).update({
        'loyaltyTexts': texts.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating loyalty texts: $e');
      return false;
    }
  }

  // Initialize with default config if doesn't exist
  Future<bool> initializeDefaultConfig() async {
    try {
      final existing = await _firestore.collection(_collection).doc(_configDocId).get();
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
    return _firestore
        .collection(_collection)
        .doc(_configDocId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return AppTextsConfig.fromJson(snapshot.data()!);
      }
      return AppTextsConfig.defaultConfig();
    });
  }
}
