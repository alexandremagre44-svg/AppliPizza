// lib/src/studio/content/services/content_section_service.dart
// Service for managing custom content sections

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_section_model.dart';

class ContentSectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'home_custom_sections';

  /// Get all custom sections ordered by order field
  Future<List<ContentSection>> getAllSections() async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => ContentSection.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error getting custom sections: $e');
      return [];
    }
  }

  /// Get a single section by ID
  Future<ContentSection?> getSection(String id) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(id).get();
      if (!doc.exists) return null;
      return ContentSection.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      print('Error getting section: $e');
      return null;
    }
  }

  /// Create a new section
  Future<void> createSection(ContentSection section) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(section.id)
          .set(section.toJson());
    } catch (e) {
      print('Error creating section: $e');
      rethrow;
    }
  }

  /// Update an existing section
  Future<void> updateSection(ContentSection section) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(section.id)
          .update(section.toJson());
    } catch (e) {
      print('Error updating section: $e');
      rethrow;
    }
  }

  /// Delete a section
  Future<void> deleteSection(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
    } catch (e) {
      print('Error deleting section: $e');
      rethrow;
    }
  }

  /// Update section order (batch update)
  Future<void> updateSectionsOrder(List<ContentSection> sections) async {
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
      print('Error updating sections order: $e');
      rethrow;
    }
  }

  /// Toggle section active state
  Future<void> toggleSectionActive(String id, bool isActive) async {
    try {
      await _firestore.collection(collectionName).doc(id).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error toggling section active: $e');
      rethrow;
    }
  }
}
