// lib/builder/services/system_pages_initializer.dart
// Service to initialize system pages in Firestore

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'builder_layout_service.dart';

/// System page configuration
class SystemPageConfig {
  final BuilderPageId pageId;
  final String title;
  final String route;
  final String icon;
  final String description;
  
  const SystemPageConfig({
    required this.pageId,
    required this.title,
    required this.route,
    required this.icon,
    required this.description,
  });
}

/// Service to automatically create system pages if they don't exist
/// 
/// System pages are essential pages that must exist in Firestore:
/// - profile: User profile page
/// - cart: Shopping cart page
/// - rewards: Rewards and tickets page
/// - roulette: Roulette game page
/// 
/// These pages are created with:
/// - Empty blocks array (can be customized later)
/// - displayLocation: "hidden" (not in bottom nav by default)
/// - isSystemPage: true (protected from deletion)
class SystemPagesInitializer {
  final BuilderLayoutService _layoutService;
  
  /// Configuration for all system pages
  /// 
  /// CRITICAL: Cart is NOT included here - it MUST NEVER be created in Builder (WL Doctrine)
  /// Cart page MUST bypass Builder completely and use CartScreen() directly
  static const List<SystemPageConfig> systemPages = [
    SystemPageConfig(
      pageId: BuilderPageId.profile,
      title: 'Profil',
      route: '/profile',
      icon: 'person',
      description: 'Page de profil utilisateur (page système)',
    ),
    // REMOVED: Cart - MUST NEVER be created as a Builder page
    // SystemPageConfig(
    //   pageId: BuilderPageId.cart,
    //   title: 'Panier',
    //   route: '/cart',
    //   icon: 'shopping_cart',
    //   description: 'Page panier (page système)',
    // ),
    SystemPageConfig(
      pageId: BuilderPageId.rewards,
      title: 'Récompenses',
      route: '/rewards',
      icon: 'card_giftcard',
      description: 'Page des récompenses (page système)',
    ),
    SystemPageConfig(
      pageId: BuilderPageId.roulette,
      title: 'Roulette',
      route: '/roulette',
      icon: 'casino',
      description: 'Page de la roue de la chance (page système)',
    ),
  ];
  
  SystemPagesInitializer({BuilderLayoutService? layoutService})
      : _layoutService = layoutService ?? BuilderLayoutService();
  
  /// Initialize all system pages for an app
  /// 
  /// Checks if each system page exists in Firestore.
  /// If a page doesn't exist, creates it with default structure.
  /// 
  /// Example:
  /// ```dart
  /// final initializer = SystemPagesInitializer();
  /// final created = await initializer.initSystemPages('pizza_delizza');
  /// print('Created ${created.length} system pages');
  /// ```
  Future<List<BuilderPageId>> initSystemPages(String appId) async {
    final createdPages = <BuilderPageId>[];
    
    for (final config in systemPages) {
      try {
        final created = await _initSystemPage(appId, config);
        if (created) {
          createdPages.add(config.pageId);
        }
      } catch (e, stackTrace) {
        debugPrint('Error initializing system page ${config.pageId.value}: $e');
        if (kDebugMode) {
          debugPrint('Stack trace: $stackTrace');
        }
      }
    }
    
    if (createdPages.isNotEmpty) {
      debugPrint('✅ Created ${createdPages.length} system pages: ${createdPages.map((p) => p.value).join(', ')}');
    }
    
    return createdPages;
  }
  
  /// Initialize a single system page
  /// 
  /// Returns true if the page was created, false if it already existed.
  Future<bool> _initSystemPage(String appId, SystemPageConfig config) async {
    // Check if page already exists (draft or published)
    final status = await _layoutService.getPageStatus(appId, config.pageId);
    
    if (status.exists) {
      debugPrint('System page ${config.pageId.value} already exists for app $appId');
      return false;
    }
    
    // Create the system page
    final page = BuilderPage(
      pageId: config.pageId,
      appId: appId,
      name: config.title,
      description: config.description,
      route: config.route,
      blocks: [],
      isEnabled: true,
      isDraft: true,
      displayLocation: 'hidden',
      icon: config.icon,
      order: 999,
      isSystemPage: true,
    );
    
    // Save as draft
    await _layoutService.saveDraft(page);
    
    // Also publish empty version for runtime
    final publishedPage = page.copyWith(isDraft: false);
    await _layoutService.publishPage(publishedPage, userId: 'system');
    
    debugPrint('✅ Created system page: ${config.pageId.value} for app $appId');
    return true;
  }
  
  /// Check if all system pages exist for an app
  /// 
  /// Returns a map of pageId -> exists status
  Future<Map<BuilderPageId, bool>> checkSystemPages(String appId) async {
    final result = <BuilderPageId, bool>{};
    
    for (final config in systemPages) {
      final status = await _layoutService.getPageStatus(appId, config.pageId);
      result[config.pageId] = status.exists;
    }
    
    return result;
  }
  
  /// Get list of missing system pages for an app
  Future<List<BuilderPageId>> getMissingSystemPages(String appId) async {
    final missing = <BuilderPageId>[];
    
    for (final config in systemPages) {
      final status = await _layoutService.getPageStatus(appId, config.pageId);
      if (!status.exists) {
        missing.add(config.pageId);
      }
    }
    
    return missing;
  }
  
  /// Get configuration for a system page
  static SystemPageConfig? getConfig(BuilderPageId pageId) {
    try {
      return systemPages.firstWhere((c) => c.pageId == pageId);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if a pageId is a system page
  static bool isSystemPageId(String pageId) {
    return BuilderPageId.systemPageIds.contains(pageId);
  }
}
