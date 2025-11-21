// lib/src/services/theme_service.dart
// Service for managing theme configuration in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/theme_config.dart';

/// Service for managing theme configuration
/// 
/// Stores theme configuration in Firestore at config/theme
class ThemeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _collectionPath = 'config';
  static const String _documentId = 'theme';

  /// Get current theme configuration
  /// Returns default config if document doesn't exist
  Future<ThemeConfig> getThemeConfig() async {
    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(_documentId)
          .get();

      if (doc.exists && doc.data() != null) {
        return ThemeConfig.fromMap(doc.data()!);
      }
      
      // Return default config if document doesn't exist
      return ThemeConfig.defaultConfig();
    } catch (e) {
      print('Error getting theme config: $e');
      return ThemeConfig.defaultConfig();
    }
  }

  /// Update theme configuration
  Future<void> updateThemeConfig(ThemeConfig config) async {
    try {
      final updatedConfig = config.copyWith(updatedAt: DateTime.now());
      
      await _firestore
          .collection(_collectionPath)
          .doc(_documentId)
          .set(updatedConfig.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error updating theme config: $e');
      rethrow;
    }
  }

  /// Reset theme to default configuration
  Future<void> resetToDefaults() async {
    try {
      final defaultConfig = ThemeConfig.defaultConfig();
      await updateThemeConfig(defaultConfig);
    } catch (e) {
      print('Error resetting theme to defaults: $e');
      rethrow;
    }
  }

  /// Initialize theme config if missing
  Future<void> initIfMissing() async {
    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(_documentId)
          .get();

      if (!doc.exists) {
        final defaultConfig = ThemeConfig.defaultConfig();
        await _firestore
            .collection(_collectionPath)
            .doc(_documentId)
            .set(defaultConfig.toMap());
        print('Theme config initialized with defaults');
      }
    } catch (e) {
      print('Error initializing theme config: $e');
      rethrow;
    }
  }

  /// Stream for real-time theme updates
  Stream<ThemeConfig> watchThemeConfig() {
    return _firestore
        .collection(_collectionPath)
        .doc(_documentId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return ThemeConfig.fromMap(snapshot.data()!);
      }
      return ThemeConfig.defaultConfig();
    });
  }
}
