// lib/builder/services/default_page_creator.dart
// Service to create default Builder pages when missing

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'builder_layout_service.dart';

/// Service to create default Builder pages
/// 
/// When a Builder page doesn't exist (e.g., home, menu), this service
/// can create a minimal default page to prevent the app from breaking.
/// 
/// This ensures graceful handling of missing content.
class DefaultPageCreator {
  final BuilderLayoutService _layoutService;
  
  DefaultPageCreator({BuilderLayoutService? layoutService})
      : _layoutService = layoutService ?? BuilderLayoutService();

  /// Create a default page for a given pageId
  /// 
  /// Creates a minimal page with a welcome message and basic structure.
  /// The page is saved as a draft and can be edited in the Builder.
  /// 
  /// Example:
  /// ```dart
  /// final creator = DefaultPageCreator();
  /// await creator.createDefaultPage(BuilderPageId.home, 'pizza_delizza');
  /// ```
  Future<BuilderPage> createDefaultPage(
    BuilderPageId pageId,
    String appId, {
    bool publish = false,
  }) async {
    try {
      // Create a minimal default page
      final page = _buildDefaultPage(pageId, appId);
      
      // Save as draft
      await _layoutService.saveDraft(page);
      
      // Optionally publish
      if (publish) {
        await _layoutService.publishPage(
          page,
          userId: 'system',
          shouldDeleteDraft: false,
        );
      }
      
      debugPrint('Created default page for ${pageId.value}');
      return page;
    } catch (e, stackTrace) {
      debugPrint('Error creating default page for ${pageId.value}: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Ensure a page exists, creating a default if needed
  /// 
  /// Checks if a published page exists. If not, creates and publishes a default.
  /// Returns the existing page or newly created page.
  /// 
  /// Example:
  /// ```dart
  /// final page = await creator.ensurePageExists(BuilderPageId.home, 'pizza_delizza');
  /// ```
  Future<BuilderPage> ensurePageExists(
    BuilderPageId pageId,
    String appId,
  ) async {
    try {
      // Check if published page exists
      final existing = await _layoutService.loadPublished(appId, pageId);
      
      if (existing != null && existing.isEnabled) {
        return existing;
      }
      
      // Create and publish default page
      return await createDefaultPage(pageId, appId, publish: true);
    } catch (e, stackTrace) {
      debugPrint('Error ensuring page exists for ${pageId.value}: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Create default pages for all standard page types
  /// 
  /// Useful for initializing a new restaurant/app with basic pages.
  /// Returns a map of successfully created pages and a list of failures.
  /// 
  /// Example:
  /// ```dart
  /// final result = await creator.createAllDefaultPages('new_resto');
  /// print('Created ${result.pages.length} pages');
  /// print('Failed: ${result.failures.length}');
  /// ```
  Future<DefaultPagesResult> createAllDefaultPages(
    String appId, {
    bool publish = false,
  }) async {
    final pages = <BuilderPageId, BuilderPage>{};
    final failures = <BuilderPageId, String>{};
    
    for (final pageId in BuilderPageId.values) {
      try {
        final page = await createDefaultPage(pageId, appId, publish: publish);
        pages[pageId] = page;
      } catch (e) {
        final errorMsg = 'Failed to create default page for ${pageId.value}: $e';
        debugPrint(errorMsg);
        failures[pageId] = e.toString();
      }
    }
    
    return DefaultPagesResult(pages: pages, failures: failures);
  }

  // ==================== PRIVATE HELPERS ====================

  /// Build a default page with minimal content
  BuilderPage _buildDefaultPage(BuilderPageId pageId, String appId) {
    final metadata = _getPageMetadata(pageId);
    
    return BuilderPage(
      pageId: pageId,
      appId: appId,
      name: metadata['name'] as String,
      description: metadata['description'] as String,
      route: metadata['route'] as String,
      blocks: _buildDefaultBlocks(pageId),
      isEnabled: true,
      isDraft: true,
      displayLocation: metadata['displayLocation'] as String,
      icon: metadata['icon'] as String,
      order: metadata['order'] as int,
    );
  }

  /// Get metadata for a page type
  Map<String, dynamic> _getPageMetadata(BuilderPageId pageId) {
    switch (pageId) {
      case BuilderPageId.home:
        return {
          'name': 'Accueil',
          'description': 'Page d\'accueil par défaut',
          'route': '/home',
          'displayLocation': 'bottomBar',
          'icon': 'home',
          'order': 1,
        };
      case BuilderPageId.menu:
        return {
          'name': 'Menu',
          'description': 'Page menu par défaut',
          'route': '/menu',
          'displayLocation': 'bottomBar',
          'icon': 'restaurant_menu',
          'order': 2,
        };
      case BuilderPageId.promo:
        return {
          'name': 'Promotions',
          'description': 'Page promotions par défaut',
          'route': '/promo',
          'displayLocation': 'hidden',
          'icon': 'local_offer',
          'order': 10,
        };
      case BuilderPageId.about:
        return {
          'name': 'À propos',
          'description': 'Page à propos par défaut',
          'route': '/about',
          'displayLocation': 'hidden',
          'icon': 'info',
          'order': 20,
        };
      case BuilderPageId.contact:
        return {
          'name': 'Contact',
          'description': 'Page contact par défaut',
          'route': '/contact',
          'displayLocation': 'hidden',
          'icon': 'contact_page',
          'order': 30,
        };
    }
  }

  /// Build default blocks for a page
  List<BuilderBlock> _buildDefaultBlocks(BuilderPageId pageId) {
    switch (pageId) {
      case BuilderPageId.home:
        return _buildHomeBlocks();
      case BuilderPageId.menu:
        return _buildMenuBlocks();
      case BuilderPageId.promo:
        return _buildPromoBlocks();
      case BuilderPageId.about:
        return _buildAboutBlocks();
      case BuilderPageId.contact:
        return _buildContactBlocks();
    }
  }

  /// Default blocks for home page
  List<BuilderBlock> _buildHomeBlocks() {
    return [
      BuilderBlock(
        id: 'hero-1',
        type: BlockType.hero,
        order: 0,
        config: {
          'title': 'Bienvenue',
          'subtitle': 'Page configurée par le Builder',
          'imageUrl': '',
        },
      ),
      BuilderBlock(
        id: 'text-1',
        type: BlockType.text,
        order: 1,
        config: {
          'content': 'Cette page a été créée automatiquement. Vous pouvez la personnaliser dans le Builder.',
          'fontSize': 16.0,
          'textAlign': 'center',
        },
      ),
    ];
  }

  /// Default blocks for menu page
  List<BuilderBlock> _buildMenuBlocks() {
    return [
      BuilderBlock(
        id: 'text-1',
        type: BlockType.text,
        order: 0,
        config: {
          'content': 'Menu',
          'fontSize': 24.0,
          'fontWeight': 'bold',
          'textAlign': 'center',
        },
      ),
      BuilderBlock(
        id: 'product-list-1',
        type: BlockType.productList,
        order: 1,
        config: {
          'mode': 'featured',
          'layout': 'grid',
          'title': 'Nos produits',
          'limit': 6,
        },
      ),
    ];
  }

  /// Default blocks for promo page
  List<BuilderBlock> _buildPromoBlocks() {
    return [
      BuilderBlock(
        id: 'text-1',
        type: BlockType.text,
        order: 0,
        config: {
          'content': 'Promotions',
          'fontSize': 24.0,
          'fontWeight': 'bold',
          'textAlign': 'center',
        },
      ),
      BuilderBlock(
        id: 'info-1',
        type: BlockType.info,
        order: 1,
        config: {
          'message': 'Découvrez nos promotions du moment !',
          'type': 'info',
        },
      ),
    ];
  }

  /// Default blocks for about page
  List<BuilderBlock> _buildAboutBlocks() {
    return [
      BuilderBlock(
        id: 'text-1',
        type: BlockType.text,
        order: 0,
        config: {
          'content': 'À propos',
          'fontSize': 24.0,
          'fontWeight': 'bold',
          'textAlign': 'center',
        },
      ),
      BuilderBlock(
        id: 'text-2',
        type: BlockType.text,
        order: 1,
        config: {
          'content': 'Informations sur notre restaurant.',
          'fontSize': 16.0,
        },
      ),
    ];
  }

  /// Default blocks for contact page
  List<BuilderBlock> _buildContactBlocks() {
    return [
      BuilderBlock(
        id: 'text-1',
        type: BlockType.text,
        order: 0,
        config: {
          'content': 'Contact',
          'fontSize': 24.0,
          'fontWeight': 'bold',
          'textAlign': 'center',
        },
      ),
      BuilderBlock(
        id: 'text-2',
        type: BlockType.text,
        order: 1,
        config: {
          'content': 'Contactez-nous pour toute question.',
          'fontSize': 16.0,
        },
      ),
    ];
  }
}

/// Result of creating multiple default pages
class DefaultPagesResult {
  final Map<BuilderPageId, BuilderPage> pages;
  final Map<BuilderPageId, String> failures;
  
  DefaultPagesResult({
    required this.pages,
    required this.failures,
  });
  
  bool get hasFailures => failures.isNotEmpty;
  int get successCount => pages.length;
  int get failureCount => failures.length;
  
  @override
  String toString() {
    return 'DefaultPagesResult(success: $successCount, failures: $failureCount)';
  }
}
