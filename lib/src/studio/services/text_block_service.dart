// lib/src/studio/services/text_block_service.dart
// Service for managing dynamic text blocks in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/text_block_model.dart';

/// Service for text block CRUD operations
class TextBlockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'config';
  final String _documentId = 'text_blocks';

  /// Get all text blocks
  Future<List<TextBlockModel>> getAllTextBlocks() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_documentId).get();
      
      if (!doc.exists) {
        return [];
      }

      final data = doc.data();
      if (data == null || !data.containsKey('blocks')) {
        return [];
      }

      final blocksList = data['blocks'] as List<dynamic>;
      return blocksList
          .map((json) => TextBlockModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading text blocks: $e');
      return [];
    }
  }

  /// Get text blocks by category
  Future<List<TextBlockModel>> getTextBlocksByCategory(String category) async {
    final allBlocks = await getAllTextBlocks();
    return allBlocks.where((block) => block.category == category).toList();
  }

  /// Get a specific text block by ID
  Future<TextBlockModel?> getTextBlockById(String id) async {
    final allBlocks = await getAllTextBlocks();
    try {
      return allBlocks.firstWhere((block) => block.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Save all text blocks (batch operation)
  Future<void> saveAllTextBlocks(List<TextBlockModel> blocks) async {
    try {
      final blocksList = blocks.map((block) => block.toJson()).toList();
      
      await _firestore.collection(_collection).doc(_documentId).set({
        'blocks': blocksList,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving text blocks: $e');
      rethrow;
    }
  }

  /// Create a new text block
  Future<void> createTextBlock(TextBlockModel block) async {
    final allBlocks = await getAllTextBlocks();
    allBlocks.add(block);
    await saveAllTextBlocks(allBlocks);
  }

  /// Update an existing text block
  Future<void> updateTextBlock(TextBlockModel updatedBlock) async {
    final allBlocks = await getAllTextBlocks();
    final index = allBlocks.indexWhere((block) => block.id == updatedBlock.id);
    
    if (index != -1) {
      allBlocks[index] = updatedBlock;
      await saveAllTextBlocks(allBlocks);
    } else {
      throw Exception('Text block not found: ${updatedBlock.id}');
    }
  }

  /// Delete a text block
  Future<void> deleteTextBlock(String id) async {
    final allBlocks = await getAllTextBlocks();
    allBlocks.removeWhere((block) => block.id == id);
    await saveAllTextBlocks(allBlocks);
  }

  /// Reorder text blocks
  Future<void> reorderTextBlocks(List<String> orderedIds) async {
    final allBlocks = await getAllTextBlocks();
    
    // Create a map for quick lookup
    final blockMap = {for (var block in allBlocks) block.id: block};
    
    // Reorder and update order field
    final reorderedBlocks = <TextBlockModel>[];
    for (int i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      if (blockMap.containsKey(id)) {
        reorderedBlocks.add(blockMap[id]!.copyWith(order: i));
      }
    }
    
    // Add any blocks that weren't in the ordered list
    for (var block in allBlocks) {
      if (!orderedIds.contains(block.id)) {
        reorderedBlocks.add(block);
      }
    }
    
    await saveAllTextBlocks(reorderedBlocks);
  }

  /// Watch text blocks in real-time
  Stream<List<TextBlockModel>> watchTextBlocks() {
    return _firestore
        .collection(_collection)
        .doc(_documentId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return <TextBlockModel>[];
      }

      final data = snapshot.data();
      if (data == null || !data.containsKey('blocks')) {
        return <TextBlockModel>[];
      }

      final blocksList = data['blocks'] as List<dynamic>;
      return blocksList
          .map((json) => TextBlockModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get text content by name (for easy lookup in client app)
  Future<String?> getTextContentByName(String name) async {
    final allBlocks = await getAllTextBlocks();
    try {
      final block = allBlocks.firstWhere((b) => b.name == name && b.isEnabled);
      return block.content;
    } catch (e) {
      return null;
    }
  }

  /// Initialize with default text blocks if none exist
  Future<void> initializeDefaultBlocks() async {
    final existing = await getAllTextBlocks();
    if (existing.isNotEmpty) return;

    final defaultBlocks = [
      TextBlockModel(
        id: 'text_home_welcome',
        name: 'home_welcome',
        displayName: 'Message de bienvenue',
        content: 'Bienvenue chez Pizza Deli\'Zza',
        type: TextBlockType.short,
        order: 0,
        category: 'home',
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TextBlockModel(
        id: 'text_home_slogan',
        name: 'home_slogan',
        displayName: 'Slogan',
        content: 'Les meilleures pizzas artisanales',
        type: TextBlockType.short,
        order: 1,
        category: 'home',
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    await saveAllTextBlocks(defaultBlocks);
  }
}
