// lib/src/services/popup_service.dart
// Service for managing popup configurations in Firestore
//
// New Firestore structure:
// restaurants/{restaurantId}/builder_settings/popups/items/{popupId}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/popup_config.dart';
import '../core/firestore_paths.dart';

class PopupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get collection reference for popups
  CollectionReference<Map<String, dynamic>> get _popupsCollection =>
      FirestorePaths.popups();

  // Get all popups
  Future<List<PopupConfig>> getAllPopups() async {
    try {
      final snapshot = await _popupsCollection
          .orderBy('priority', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PopupConfig.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting popups: $e');
      return [];
    }
  }

  // Get active popups
  Future<List<PopupConfig>> getActivePopups() async {
    try {
      final snapshot = await _popupsCollection
          .where('isEnabled', isEqualTo: true)
          .get();

      final popups = snapshot.docs
          .map((doc) => PopupConfig.fromFirestore(doc.data()))
          .where((popup) => popup.isCurrentlyActive)
          .toList();
      
      // Sort in Dart to avoid composite index requirement
      popups.sort((a, b) => b.priority.compareTo(a.priority));
      
      return popups;
    } catch (e) {
      print('Error getting active popups: $e');
      return [];
    }
  }

  // Get popup by ID
  Future<PopupConfig?> getPopupById(String id) async {
    try {
      final doc = await _popupsCollection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return PopupConfig.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting popup by ID: $e');
      return null;
    }
  }

  // Create popup
  Future<bool> createPopup(PopupConfig popup) async {
    try {
      await _popupsCollection.doc(popup.id).set(popup.toMap());
      return true;
    } catch (e) {
      print('Error creating popup: $e');
      return false;
    }
  }
  
  // Save popup (alias for backward compatibility)
  Future<bool> savePopup(PopupConfig popup) async {
    return await updatePopup(popup);
  }

  // Update popup
  Future<bool> updatePopup(PopupConfig popup) async {
    try {
      await _popupsCollection
          .doc(popup.id)
          .update(popup.toMap());
      return true;
    } catch (e) {
      print('Error updating popup: $e');
      return false;
    }
  }

  // Delete popup
  Future<bool> deletePopup(String id) async {
    try {
      await _popupsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting popup: $e');
      return false;
    }
  }

  // Stream for real-time updates
  Stream<List<PopupConfig>> watchPopups() {
    return _popupsCollection
        .orderBy('priority', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PopupConfig.fromFirestore(doc.data()))
          .toList();
    });
  }

  // Check if popup should be shown to user
  Future<bool> shouldShowPopup(
    PopupConfig popup,
    String userId,
  ) async {
    // Check if popup is currently active
    if (!popup.isCurrentlyActive) return false;

    // Check display condition
    try {
      final userPopupDoc = await _firestore
          .collection('user_popup_views')
          .doc('${userId}_${popup.id}')
          .get();

      final now = DateTime.now();

      switch (popup.displayCondition) {
        case 'always':
          return true;

        case 'onceEver':
          return !userPopupDoc.exists;

        case 'oncePerDay':
          if (!userPopupDoc.exists) return true;
          final lastView = DateTime.parse(
            userPopupDoc.data()!['lastViewedAt'] as String,
          );
          return now.difference(lastView).inDays >= 1;

        case 'oncePerSession':
          // This should be handled client-side with session storage
          return true;

        default:
          return true;
      }
    } catch (e) {
      print('Error checking popup display: $e');
      return false;
    }
  }

  // Record popup view
  Future<void> recordPopupView(String userId, String popupId) async {
    try {
      await _firestore
          .collection('user_popup_views')
          .doc('${userId}_$popupId')
          .set({
        'userId': userId,
        'popupId': popupId,
        'lastViewedAt': DateTime.now().toIso8601String(),
        'viewCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error recording popup view: $e');
    }
  }
}
