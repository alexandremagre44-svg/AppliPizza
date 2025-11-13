// lib/src/services/popup_service.dart
// Service for managing popup configurations in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/popup_config.dart';

class PopupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'app_popups';

  // Get all popups
  Future<List<PopupConfig>> getAllPopups() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('priority', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PopupConfig.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting popups: $e');
      return [];
    }
  }

  // Get active popups
  Future<List<PopupConfig>> getActivePopups() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('priority', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PopupConfig.fromJson(doc.data()))
          .where((popup) => popup.isCurrentlyActive)
          .toList();
    } catch (e) {
      print('Error getting active popups: $e');
      return [];
    }
  }

  // Get popup by ID
  Future<PopupConfig?> getPopupById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return PopupConfig.fromJson(doc.data()!);
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
      await _firestore.collection(_collection).doc(popup.id).set(popup.toJson());
      return true;
    } catch (e) {
      print('Error creating popup: $e');
      return false;
    }
  }

  // Update popup
  Future<bool> updatePopup(PopupConfig popup) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(popup.id)
          .update(popup.toJson());
      return true;
    } catch (e) {
      print('Error updating popup: $e');
      return false;
    }
  }

  // Delete popup
  Future<bool> deletePopup(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting popup: $e');
      return false;
    }
  }

  // Stream for real-time updates
  Stream<List<PopupConfig>> watchPopups() {
    return _firestore
        .collection(_collection)
        .orderBy('priority', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PopupConfig.fromJson(doc.data()))
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
