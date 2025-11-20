// lib/src/studio/services/popup_v2_service.dart
// Service for managing V2 popups in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/popup_v2_model.dart';

/// Service for popup V2 CRUD operations
class PopupV2Service {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'config';
  final String _documentId = 'popups_v2';

  /// Get all popups
  Future<List<PopupV2Model>> getAllPopups() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_documentId).get();
      
      if (!doc.exists) {
        return [];
      }

      final data = doc.data();
      if (data == null || !data.containsKey('popups')) {
        return [];
      }

      final popupsList = data['popups'] as List<dynamic>;
      return popupsList
          .map((json) => PopupV2Model.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      print('Error loading popups: $e');
      return [];
    }
  }

  /// Get active popups (enabled and within date range)
  Future<List<PopupV2Model>> getActivePopups() async {
    final allPopups = await getAllPopups();
    return allPopups.where((popup) => popup.isCurrentlyActive).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority)); // Higher priority first
  }

  /// Get a specific popup by ID
  Future<PopupV2Model?> getPopupById(String id) async {
    final allPopups = await getAllPopups();
    try {
      return allPopups.firstWhere((popup) => popup.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Save all popups (batch operation)
  Future<void> saveAllPopups(List<PopupV2Model> popups) async {
    try {
      final popupsList = popups.map((popup) => popup.toJson()).toList();
      
      await _firestore.collection(_collection).doc(_documentId).set({
        'popups': popupsList,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving popups: $e');
      rethrow;
    }
  }

  /// Create a new popup
  Future<void> createPopup(PopupV2Model popup) async {
    final allPopups = await getAllPopups();
    allPopups.add(popup);
    await saveAllPopups(allPopups);
  }

  /// Update an existing popup
  Future<void> updatePopup(PopupV2Model updatedPopup) async {
    final allPopups = await getAllPopups();
    final index = allPopups.indexWhere((popup) => popup.id == updatedPopup.id);
    
    if (index != -1) {
      allPopups[index] = updatedPopup;
      await saveAllPopups(allPopups);
    } else {
      throw Exception('Popup not found: ${updatedPopup.id}');
    }
  }

  /// Delete a popup
  Future<void> deletePopup(String id) async {
    final allPopups = await getAllPopups();
    allPopups.removeWhere((popup) => popup.id == id);
    await saveAllPopups(allPopups);
  }

  /// Reorder popups
  Future<void> reorderPopups(List<String> orderedIds) async {
    final allPopups = await getAllPopups();
    
    // Create a map for quick lookup
    final popupMap = {for (var popup in allPopups) popup.id: popup};
    
    // Reorder and update order field
    final reorderedPopups = <PopupV2Model>[];
    for (int i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      if (popupMap.containsKey(id)) {
        reorderedPopups.add(popupMap[id]!.copyWith(order: i));
      }
    }
    
    // Add any popups that weren't in the ordered list
    for (var popup in allPopups) {
      if (!orderedIds.contains(popup.id)) {
        reorderedPopups.add(popup);
      }
    }
    
    await saveAllPopups(reorderedPopups);
  }

  /// Watch popups in real-time
  Stream<List<PopupV2Model>> watchPopups() {
    return _firestore
        .collection(_collection)
        .doc(_documentId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return <PopupV2Model>[];
      }

      final data = snapshot.data();
      if (data == null || !data.containsKey('popups')) {
        return <PopupV2Model>[];
      }

      final popupsList = data['popups'] as List<dynamic>;
      final popups = popupsList
          .map((json) => PopupV2Model.fromJson(json as Map<String, dynamic>))
          .toList();
      
      popups.sort((a, b) => a.order.compareTo(b.order));
      return popups;
    });
  }

  /// Toggle popup enabled state
  Future<void> togglePopup(String id, bool isEnabled) async {
    final popup = await getPopupById(id);
    if (popup != null) {
      await updatePopup(popup.copyWith(
        isEnabled: isEnabled,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Duplicate a popup
  Future<PopupV2Model> duplicatePopup(String id) async {
    final popup = await getPopupById(id);
    if (popup == null) {
      throw Exception('Popup not found: $id');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final duplicated = popup.copyWith(
      id: 'popup_v2_$timestamp',
      title: '${popup.title} (Copie)',
      isEnabled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await createPopup(duplicated);
    return duplicated;
  }
}
