// lib/src/services/home_layout_service.dart
// Service for managing home layout configuration in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/home_layout_config.dart';

/// Service to manage home layout configuration
/// Handles reading/writing layout settings to Firestore
class HomeLayoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'config';
  static const String _docId = 'home_layout';

  /// Get home layout configuration
  /// Returns null if document doesn't exist
  Future<HomeLayoutConfig?> getHomeLayout() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_docId).get();
      if (doc.exists && doc.data() != null) {
        return HomeLayoutConfig.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting home layout config: $e');
      return null;
    }
  }

  /// Watch home layout configuration changes
  /// Returns a stream that emits whenever the configuration changes
  Stream<HomeLayoutConfig?> watchHomeLayout() {
    return _firestore
        .collection(_collection)
        .doc(_docId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return HomeLayoutConfig.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  /// Save home layout configuration
  /// Creates or updates the document in Firestore
  Future<bool> saveHomeLayout(HomeLayoutConfig config) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(_docId)
          .set(config.toJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error saving home layout config: $e');
      return false;
    }
  }

  /// Initialize default layout configuration if none exists
  /// This ensures backward compatibility with existing installations
  Future<bool> initializeDefaultLayout() async {
    try {
      final existing = await getHomeLayout();
      if (existing == null) {
        final defaultConfig = HomeLayoutConfig.defaultConfig();
        return await saveHomeLayout(defaultConfig);
      }
      return true;
    } catch (e) {
      print('Error initializing default layout: $e');
      return false;
    }
  }

  /// Update only the studioEnabled flag
  Future<bool> updateStudioEnabled(bool enabled) async {
    try {
      await _firestore.collection(_collection).doc(_docId).update({
        'studioEnabled': enabled,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating studio enabled flag: $e');
      return false;
    }
  }

  /// Update sections order
  Future<bool> updateSectionsOrder(List<String> order) async {
    try {
      await _firestore.collection(_collection).doc(_docId).update({
        'sectionsOrder': order,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating sections order: $e');
      return false;
    }
  }

  /// Update enabled sections map
  Future<bool> updateEnabledSections(Map<String, bool> enabled) async {
    try {
      await _firestore.collection(_collection).doc(_docId).update({
        'enabledSections': enabled,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating enabled sections: $e');
      return false;
    }
  }

  /// Initialize home layout if missing
  /// Reads config/home_layout from Firestore
  /// If missing, creates document with default values
  /// This ensures backward compatibility with existing installations
  Future<void> initIfMissing() async {
    try {
      final existing = await getHomeLayout();
      if (existing == null) {
        final defaultConfig = HomeLayoutConfig(
          id: 'home_layout',
          studioEnabled: true,
          sectionsOrder: ['hero', 'banners', 'popups', 'texts'],
          enabledSections: {
            'hero': true,
            'banners': true,
            'popups': true,
            'texts': true,
          },
          updatedAt: DateTime.now(),
        );
        await saveHomeLayout(defaultConfig);
        print('Home layout initialized with default values');
      }
    } catch (e) {
      print('Error in initIfMissing: $e');
    }
  }
}
