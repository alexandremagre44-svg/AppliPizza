// lib/src/services/theme_service.dart
// Service for managing theme configuration in Firestore
//
// New Firestore structure:
// restaurants/{restaurantId}/builder_settings/theme

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/theme_config.dart';
import '../core/firestore_paths.dart';

/// Service for managing theme configuration
/// 
/// Stores theme configuration in Firestore at:
/// restaurants/{restaurantId}/builder_settings/theme
class ThemeService {
  /// Get current theme configuration
  /// Returns default config if document doesn't exist
  Future<ThemeConfig> getThemeConfig() async {
    try {
      final doc = await FirestorePaths.themeDoc().get();

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
      
      await FirestorePaths.themeDoc()
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
      final doc = await FirestorePaths.themeDoc().get();

      if (!doc.exists) {
        final defaultConfig = ThemeConfig.defaultConfig();
        await FirestorePaths.themeDoc()
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
    return FirestorePaths.themeDoc()
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return ThemeConfig.fromMap(snapshot.data()!);
      }
      return ThemeConfig.defaultConfig();
    });
  }
}
