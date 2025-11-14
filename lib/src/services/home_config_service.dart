// lib/src/services/home_config_service.dart
// Service for managing home page configuration in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_delizza/src/features/home/data/models/home_config.dart';

class HomeConfigService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'app_home_config';
  static const String _configDocId = 'main';

  // Get home configuration
  Future<HomeConfig?> getHomeConfig() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_configDocId).get();
      if (doc.exists && doc.data() != null) {
        return HomeConfig.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting home config: $e');
      return null;
    }
  }

  // Save home configuration
  Future<bool> saveHomeConfig(HomeConfig config) async {
    try {
      print('HomeConfigService: Saving config with ${config.blocks.length} blocks');
      final jsonData = config.toJson();
      print('HomeConfigService: JSON blocks: ${jsonData['blocks']}');
      
      await _firestore.collection(_collection).doc(_configDocId).set(
            jsonData,
            SetOptions(merge: true),
          );
      print('HomeConfigService: Save to Firestore successful');
      return true;
    } catch (e, stackTrace) {
      print('Error saving home config: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Update hero configuration
  Future<bool> updateHeroConfig(HeroConfig hero) async {
    try {
      await _firestore.collection(_collection).doc(_configDocId).update({
        'hero': hero.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating hero config: $e');
      return false;
    }
  }

  // Update promo banner configuration
  Future<bool> updatePromoBanner(PromoBannerConfig banner) async {
    try {
      await _firestore.collection(_collection).doc(_configDocId).update({
        'promoBanner': banner.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating promo banner: $e');
      return false;
    }
  }

  // Add content block
  Future<bool> addContentBlock(ContentBlock block) async {
    try {
      print('HomeConfigService: Starting addContentBlock for block ${block.id}');
      final config = await getHomeConfig();
      if (config == null) {
        print('HomeConfigService: ERROR - config is null');
        return false;
      }

      print('HomeConfigService: Current blocks count: ${config.blocks.length}');
      final updatedBlocks = List<ContentBlock>.from(config.blocks)..add(block);
      print('HomeConfigService: Updated blocks count: ${updatedBlocks.length}');
      
      final updatedConfig = config.copyWith(
        blocks: updatedBlocks,
        updatedAt: DateTime.now(),
      );

      final result = await saveHomeConfig(updatedConfig);
      print('HomeConfigService: Save result: $result');
      return result;
    } catch (e, stackTrace) {
      print('Error adding content block: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Update content block
  Future<bool> updateContentBlock(ContentBlock block) async {
    try {
      final config = await getHomeConfig();
      if (config == null) return false;

      final updatedBlocks = config.blocks.map((b) {
        return b.id == block.id ? block : b;
      }).toList();

      final updatedConfig = config.copyWith(
        blocks: updatedBlocks,
        updatedAt: DateTime.now(),
      );

      return await saveHomeConfig(updatedConfig);
    } catch (e) {
      print('Error updating content block: $e');
      return false;
    }
  }

  // Delete content block
  Future<bool> deleteContentBlock(String blockId) async {
    try {
      final config = await getHomeConfig();
      if (config == null) return false;

      final updatedBlocks =
          config.blocks.where((b) => b.id != blockId).toList();

      final updatedConfig = config.copyWith(
        blocks: updatedBlocks,
        updatedAt: DateTime.now(),
      );

      return await saveHomeConfig(updatedConfig);
    } catch (e) {
      print('Error deleting content block: $e');
      return false;
    }
  }

  // Reorder content blocks
  Future<bool> reorderBlocks(List<ContentBlock> blocks) async {
    try {
      final config = await getHomeConfig();
      if (config == null) return false;

      final updatedConfig = config.copyWith(
        blocks: blocks,
        updatedAt: DateTime.now(),
      );

      return await saveHomeConfig(updatedConfig);
    } catch (e) {
      print('Error reordering blocks: $e');
      return false;
    }
  }

  // Initialize with default config if doesn't exist
  Future<bool> initializeDefaultConfig() async {
    try {
      final existing = await getHomeConfig();
      if (existing != null) return true;

      final defaultConfig = HomeConfig(
        id: _configDocId,
        hero: HeroConfig(
          isActive: false,
          imageUrl: '',
          title: 'Bienvenue chez Pizza Deli\'Zza',
          subtitle: 'Les meilleures pizzas artisanales',
          ctaText: 'Découvrir',
          ctaAction: '/menu',
        ),
        promoBanner: PromoBannerConfig(
          isActive: false,
          text: '',
        ),
        blocks: [],
        updatedAt: DateTime.now(),
      );

      return await saveHomeConfig(defaultConfig);
    } catch (e) {
      print('Error initializing default config: $e');
      return false;
    }
  }

  // Stream for real-time updates
  Stream<HomeConfig?> watchHomeConfig() {
    return _firestore
        .collection(_collection)
        .doc(_configDocId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return HomeConfig.fromJson(snapshot.data()!);
      }
      return null;
    });
  }
}
