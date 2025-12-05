// lib/src/services/theme_service.dart
// Service for loading theme configuration from Firestore
//
// Firestore path: restaurants/{appId}/config/theme

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme_config.dart';
import '../providers/restaurant_provider.dart';

/// Service for loading theme configuration from Firestore
/// 
/// Loads theme from: restaurants/{appId}/config/theme
/// Returns default Delizza theme if document doesn't exist
class ThemeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;

  ThemeService({required this.appId});

  /// Get the scoped theme document reference
  /// Path: restaurants/{appId}/config/theme
  DocumentReference get _themeDoc =>
      _firestore.collection('restaurants').doc(appId).collection('config').doc('theme');

  /// Load theme configuration from Firestore
  /// Returns ThemeConfig.defaultConfig() if document doesn't exist
  Future<ThemeConfig> loadTheme() async {
    try {
      final doc = await _themeDoc.get();

      if (doc.exists && doc.data() != null) {
        return ThemeConfig.fromMap(doc.data() as Map<String, dynamic>);
      }
      
      // Return default Delizza theme if document doesn't exist
      return ThemeConfig.defaultConfig();
    } catch (e) {
      debugPrint('ThemeService: Error loading theme config: $e');
      return ThemeConfig.defaultConfig();
    }
  }

  /// Save theme configuration to Firestore
  Future<void> saveTheme(ThemeConfig config) async {
    try {
      await _themeDoc.set(config.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('ThemeService: Error saving theme config: $e');
      rethrow;
    }
  }

  /// Reset theme to default configuration
  Future<void> resetToDefaults() async {
    try {
      final defaultConfig = ThemeConfig.defaultConfig();
      await saveTheme(defaultConfig);
    } catch (e) {
      debugPrint('ThemeService: Error resetting theme to defaults: $e');
      rethrow;
    }
  }

  /// Stream for real-time theme updates
  Stream<ThemeConfig> watchTheme() {
    return _themeDoc.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return ThemeConfig.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return ThemeConfig.defaultConfig();
    });
  }
}

/// Provider for ThemeService scoped to the current restaurant
final themeServiceProvider = Provider<ThemeService>(
  (ref) {
    final appId = ref.watch(currentRestaurantProvider).id;
    return ThemeService(appId: appId);
  },
  dependencies: [currentRestaurantProvider],
);
