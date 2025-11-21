// lib/src/studio/services/dynamic_section_service.dart
// Service for managing dynamic sections in Firestore

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dynamic_section_model.dart';

class DynamicSectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'dynamic_sections_v3';

  /// Get all sections ordered by order field
  Future<List<DynamicSection>> getAllSections() async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => DynamicSection.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // TODO: Replace with proper logging framework (e.g., logger package)
      debugPrint('Error getting sections: $e');
      return [];
    }
  }

  /// Watch sections in real-time
  Stream<List<DynamicSection>> watchSections() {
    return _firestore
        .collection(collectionName)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DynamicSection.fromJson(doc.data()))
          .toList();
    });
  }

  /// Create a new section
  Future<void> createSection(DynamicSection section) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(section.id)
          .set(section.toJson());
    } catch (e) {
      debugPrint('Error creating section: $e');
      rethrow;
    }
  }

  /// Update an existing section
  Future<void> updateSection(DynamicSection section) async {
    try {
      final updatedSection = section.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _firestore
          .collection(collectionName)
          .doc(section.id)
          .update(updatedSection.toJson());
    } catch (e) {
      debugPrint('Error updating section: $e');
      rethrow;
    }
  }

  /// Delete a section
  Future<void> deleteSection(String sectionId) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(sectionId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting section: $e');
      rethrow;
    }
  }

  /// Update order for multiple sections
  Future<void> updateSectionsOrder(List<DynamicSection> sections) async {
    try {
      final batch = _firestore.batch();

      for (var i = 0; i < sections.length; i++) {
        final section = sections[i].copyWith(
          order: i,
          updatedAt: DateTime.now(),
        );

        batch.update(
          _firestore.collection(collectionName).doc(section.id),
          section.toJson(),
        );
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error updating sections order: $e');
      rethrow;
    }
  }

  /// Save all sections (used for publish workflow)
  Future<void> saveAllSections(List<DynamicSection> sections) async {
    try {
      final batch = _firestore.batch();

      // Get existing sections to know which ones to delete
      final existingSnapshot = await _firestore
          .collection(collectionName)
          .get();

      final existingIds = existingSnapshot.docs.map((doc) => doc.id).toSet();
      final newIds = sections.map((s) => s.id).toSet();

      // Delete sections that are not in the new list
      for (final id in existingIds) {
        if (!newIds.contains(id)) {
          batch.delete(_firestore.collection(collectionName).doc(id));
        }
      }

      // Create or update all sections
      for (final section in sections) {
        batch.set(
          _firestore.collection(collectionName).doc(section.id),
          section.toJson(),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error saving all sections: $e');
      rethrow;
    }
  }

  /// Duplicate a section
  Future<DynamicSection> duplicateSection(DynamicSection section) async {
    try {
      final duplicated = section.duplicate();
      await createSection(duplicated);
      return duplicated;
    } catch (e) {
      debugPrint('Error duplicating section: $e');
      rethrow;
    }
  }

  /// Toggle section active state
  Future<void> toggleSectionActive(String sectionId, bool active) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(sectionId)
          .update({
        'active': active,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error toggling section active state: $e');
      rethrow;
    }
  }

  /// Get section by ID
  Future<DynamicSection?> getSectionById(String sectionId) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(sectionId)
          .get();

      if (!doc.exists) return null;

      return DynamicSection.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error getting section by ID: $e');
      return null;
    }
  }

  /// Get sections by type
  Future<List<DynamicSection>> getSectionsByType(DynamicSectionType type) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('type', isEqualTo: type.value)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => DynamicSection.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting sections by type: $e');
      return [];
    }
  }

  /// Get active sections only
  Future<List<DynamicSection>> getActiveSections() async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('active', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => DynamicSection.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting active sections: $e');
      return [];
    }
  }
}
