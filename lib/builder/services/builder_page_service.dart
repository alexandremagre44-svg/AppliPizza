// lib/builder/services/builder_page_service.dart
// Service for managing Builder pages with draft/publish workflow per page
//
// This service provides methods for:
// - Creating pages from templates or blank
// - Managing draft/published layouts per page
// - Toggling active status
// - Reordering bottom navigation
// - Managing modules on pages
// - Cleaning duplicate pages

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../utils/builder_modules.dart';
import '../exceptions/builder_exceptions.dart';
import 'builder_layout_service.dart';

/// Service for managing Builder pages with enhanced draft/publish workflow
/// 
/// Features:
/// - Create pages from templates or blank
/// - Per-page draft and published layouts
/// - Toggle active/inactive status
/// - Reorder bottom navigation
/// - Add/remove modules to pages
/// - Clean duplicate pages
class BuilderPageService {
  final BuilderLayoutService _layoutService;
  
  BuilderPageService({BuilderLayoutService? layoutService})
      : _layoutService = layoutService ?? BuilderLayoutService();

  // ==================== PAGE CREATION ====================

  /// Create a page from a predefined template
  /// 
  /// Templates are identified by their template ID:
  /// - 'home_template': Default home page with hero and products
  /// - 'menu_template': Menu page with product list
  /// - 'promo_template': Promotional page with banners
  /// - 'about_template': About page with text blocks
  /// - 'contact_template': Contact page with info
  /// 
  /// Example:
  /// ```dart
  /// final page = await service.createPageFromTemplate(
  ///   'home_template',
  ///   appId: 'delizza',
  ///   name: 'Nouvelle Page',
  /// );
  /// ```
  Future<BuilderPage> createPageFromTemplate(
    String templateId, {
    required String appId,
    required String name,
    String? description,
    String? route,
    String displayLocation = 'hidden',
    String icon = 'article',
    int order = 999,
  }) async {
    // Get template blocks based on templateId
    final templateBlocks = _getTemplateBlocks(templateId);
    
    // Generate unique pageKey for custom pages (this is the Firestore doc ID)
    final pageKeyValue = _generatePageId(name);
    
    // Try to get system page ID (null for custom pages)
    final systemId = BuilderPageId.tryFromString(pageKeyValue);
    
    final page = BuilderPage(
      pageKey: pageKeyValue,
      systemId: systemId,
      appId: appId,
      name: name,
      description: description ?? 'Page créée depuis le template $templateId',
      // Custom pages MUST use /page/<pageKey> route format
      route: route ?? '/page/$pageKeyValue',
      blocks: templateBlocks,
      isEnabled: true,
      isDraft: true,
      displayLocation: displayLocation,
      icon: icon,
      order: order,
      // New fields
      pageType: BuilderPageType.template,
      isActive: true,
      bottomNavIndex: order,
      modules: [],
      draftLayout: templateBlocks,
      publishedLayout: [],
      hasUnpublishedChanges: true,
    );
    
    // Save as draft
    await _layoutService.saveDraft(page);
    
    debugPrint('[BuilderPageService] ✅ Created page from template: $templateId → ${page.name} (pageKey: $pageKeyValue)');
    return page;
  }

  /// Create a blank/empty page
  /// 
  /// Creates a page with no blocks, ready for customization.
  /// 
  /// Example:
  /// ```dart
  /// final page = await service.createBlankPage(
  ///   appId: 'delizza',
  ///   name: 'Page Vierge',
  /// );
  /// ```
  Future<BuilderPage> createBlankPage({
    required String appId,
    required String name,
    String? description,
    String? route,
    String displayLocation = 'hidden',
    String icon = 'description',
    int order = 999,
  }) async {
    // Generate unique pageKey for custom pages (this is the Firestore doc ID)
    final pageKeyValue = _generatePageId(name);
    
    // Try to get system page ID (null for custom pages)
    final systemId = BuilderPageId.tryFromString(pageKeyValue);
    
    final page = BuilderPage(
      pageKey: pageKeyValue,
      systemId: systemId,
      appId: appId,
      name: name,
      description: description ?? 'Page vierge',
      // Custom pages MUST use /page/<pageKey> route format
      route: route ?? '/page/$pageKeyValue',
      blocks: [],
      isEnabled: true,
      isDraft: true,
      displayLocation: displayLocation,
      icon: icon,
      order: order,
      // New fields
      pageType: BuilderPageType.blank,
      isActive: true,
      bottomNavIndex: order,
      modules: [],
      draftLayout: [],
      publishedLayout: [],
      hasUnpublishedChanges: false,
    );
    
    // Save as draft
    await _layoutService.saveDraft(page);
    
    debugPrint('[BuilderPageService] ✅ Created blank page: ${page.name} (pageKey: $pageKeyValue)');
    return page;
  }

  // ==================== DRAFT/PUBLISH WORKFLOW ====================

  /// Update the draft layout of a page
  /// 
  /// This modifies the draftLayout which is what admins edit.
  /// Changes are not visible to clients until published.
  /// 
  /// Example:
  /// ```dart
  /// final updatedPage = await service.updateDraftLayout(
  ///   BuilderPageId.home,
  ///   'delizza',
  ///   newBlocks,
  /// );
  /// ```
  Future<BuilderPage?> updateDraftLayout(
    BuilderPageId pageId,
    String appId,
    List<BuilderBlock> layout,
  ) async {
    try {
      // Load existing page
      final page = await _layoutService.loadDraft(appId, pageId);
      if (page == null) {
        debugPrint('[BuilderPageService] ⚠️ Page not found: ${pageId.value}');
        return null;
      }
      
      // Update draft layout
      final updatedPage = page.updateDraftLayout(layout);
      
      // Save draft
      await _layoutService.saveDraft(updatedPage);
      
      debugPrint('[BuilderPageService] ✅ Updated draft layout for: ${pageId.value}');
      return updatedPage;
    } catch (e, stackTrace) {
      debugPrint('[BuilderPageService] ❌ Error updating draft layout: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Publish a page
  /// 
  /// Copies the draftLayout to publishedLayout and marks as published.
  /// The published layout becomes visible to clients.
  /// 
  /// Example:
  /// ```dart
  /// final publishedPage = await service.publishPage(
  ///   BuilderPageId.home,
  ///   'delizza',
  ///   userId: 'admin_123',
  /// );
  /// ```
  Future<BuilderPage?> publishPage(
    BuilderPageId pageId,
    String appId, {
    required String userId,
  }) async {
    try {
      // Load draft
      final draft = await _layoutService.loadDraft(appId, pageId);
      if (draft == null) {
        debugPrint('[BuilderPageService] ⚠️ No draft found to publish: ${pageId.value}');
        return null;
      }
      
      // Publish (copies draftLayout to publishedLayout)
      final publishedPage = draft.publish(userId: userId);
      
      // Save to published collection
      await _layoutService.publishPage(
        publishedPage,
        userId: userId,
        shouldDeleteDraft: false, // Keep draft for continued editing
      );
      
      // Also update draft with new published state
      await _layoutService.saveDraft(publishedPage.copyWith(isDraft: true));
      
      debugPrint('[BuilderPageService] ✅ Published page: ${pageId.value}');
      return publishedPage;
    } catch (e, stackTrace) {
      debugPrint('[BuilderPageService] ❌ Error publishing page: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  // ==================== PAGE STATUS ====================

  /// Toggle the active status of a page
  /// 
  /// Active pages are visible in navigation and accessible.
  /// Inactive pages are hidden from navigation but may still be accessible via direct links.
  /// 
  /// Example:
  /// ```dart
  /// final page = await service.toggleActiveStatus(
  ///   BuilderPageId.promo,
  ///   'delizza',
  ///   isActive: false, // Hide from nav
  /// );
  /// // Or with string pageId for custom pages:
  /// final page = await service.toggleActiveStatus(
  ///   'promo_noel',
  ///   'delizza',
  ///   isActive: true,
  /// );
  /// ```
  Future<BuilderPage?> toggleActiveStatus(
    dynamic pageId,
    String appId,
    bool isActive,
  ) async {
    try {
      // Determine the page key for logging
      final pageIdStr = pageId is BuilderPageId ? pageId.value : pageId.toString();
      
      // Load page (draft first, then published)
      var page = await _layoutService.loadDraft(appId, pageId);
      page ??= await _layoutService.loadPublished(appId, pageId);
      
      if (page == null) {
        debugPrint('[BuilderPageService] ⚠️ Page not found: $pageIdStr');
        return null;
      }
      
      // Update active status
      final updatedPage = page.copyWith(
        isActive: isActive,
        updatedAt: DateTime.now(),
      );
      
      // Save to both draft and published if published exists
      await _layoutService.saveDraft(updatedPage.copyWith(isDraft: true));
      
      if (await _layoutService.hasPublished(appId, pageId)) {
        await _layoutService.publishPage(
          updatedPage,
          userId: 'system',
          shouldDeleteDraft: false,
        );
      }
      
      debugPrint('[BuilderPageService] ✅ Set active=$isActive for: $pageIdStr');
      return updatedPage;
    } catch (e, stackTrace) {
      debugPrint('[BuilderPageService] ❌ Error toggling active status: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  // ==================== BOTTOM NAVIGATION ====================

  /// Reorder a page in the bottom navigation bar
  /// 
  /// Updates the bottomNavIndex and order fields to move the page
  /// to a new position in the bottom nav.
  /// 
  /// Accepts either a [BuilderPageId] enum for system pages or a String
  /// pageKey for custom pages.
  /// 
  /// Example:
  /// ```dart
  /// // Using BuilderPageId for system pages:
  /// await service.reorderBottomNav(
  ///   BuilderPageId.menu,
  ///   'delizza',
  ///   2, // Move to 3rd position (0-indexed)
  /// );
  /// // Or using String pageKey for custom pages:
  /// await service.reorderBottomNav(
  ///   'promo_noel',
  ///   'delizza',
  ///   3,
  /// );
  /// ```
  Future<BuilderPage?> reorderBottomNav(
    dynamic pageId,
    String appId,
    int newIndex,
  ) async {
    try {
      // Determine the page key for logging
      final pageIdStr = pageId is BuilderPageId ? pageId.value : pageId.toString();
      
      // Load page
      var page = await _layoutService.loadDraft(appId, pageId);
      page ??= await _layoutService.loadPublished(appId, pageId);
      
      if (page == null) {
        debugPrint('[BuilderPageService] ⚠️ Page not found: $pageIdStr');
        return null;
      }
      
      // Update order
      final updatedPage = page.copyWith(
        bottomNavIndex: newIndex,
        order: newIndex,
        updatedAt: DateTime.now(),
      );
      
      // Save to both draft and published if published exists
      await _layoutService.saveDraft(updatedPage.copyWith(isDraft: true));
      
      if (await _layoutService.hasPublished(appId, pageId)) {
        await _layoutService.publishPage(
          updatedPage,
          userId: 'system',
          shouldDeleteDraft: false,
        );
      }
      
      debugPrint('[BuilderPageService] ✅ Reordered $pageIdStr to index $newIndex');
      return updatedPage;
    } catch (e, stackTrace) {
      debugPrint('[BuilderPageService] ❌ Error reordering bottom nav: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  // ==================== NAVIGATION PARAMETERS ====================

  /// Update page navigation parameters (isActive and bottomNavIndex)
  /// 
  /// This method allows updating navigation settings without affecting
  /// draftLayout, publishedLayout, or modules.
  /// 
  /// Validation:
  /// - If isActive is true, bottomNavIndex must be between 0 and 4
  /// - No duplicate bottomNavIndex allowed for active pages
  /// - Minimum 2 active pages must remain in bottom bar
  /// - Updates both draft and published versions
  /// 
  /// Throws:
  /// - MinimumBottomNavItemsException if resulting config has < 2 active pages
  /// - BottomNavIndexConflictException if bottomNavIndex is already in use
  /// 
  /// Example:
  /// ```dart
  /// await service.updatePageNavigation(
  ///   pageId: BuilderPageId.promo,
  ///   appId: 'delizza',
  ///   isActive: true,
  ///   bottomNavIndex: 2,
  /// );
  /// ```
  Future<BuilderPage> updatePageNavigation({
    required BuilderPageId pageId,
    required String appId,
    required bool isActive,
    required int? bottomNavIndex,
  }) async {
    // Validation: if active, bottomNavIndex must be provided and valid
    if (isActive) {
      if (bottomNavIndex == null) {
        throw ArgumentError('bottomNavIndex required when isActive is true');
      }
      
      if (bottomNavIndex < 0 || bottomNavIndex > 4) {
        throw ArgumentError('bottomNavIndex must be between 0 and 4');
      }
    }
    
    // Load page
    var page = await _layoutService.loadDraft(appId, pageId);
    page ??= await _layoutService.loadPublished(appId, pageId);
    
    if (page == null) {
      throw StateError('Page not found: ${pageId.value}');
    }
    
    // Load all published pages to check validations
    final allPublishedPages = await _layoutService.loadAllPublishedPages(appId);
    
    // Check for duplicate bottomNavIndex among active pages (excluding current page)
    if (isActive && bottomNavIndex != null) {
      for (final entry in allPublishedPages.entries) {
        final otherPage = entry.value;
        if (otherPage.pageId != pageId && 
            otherPage.isActive && 
            otherPage.bottomNavIndex == bottomNavIndex) {
          debugPrint('[BuilderPageService] ❌ Duplicate bottomNavIndex $bottomNavIndex found on page ${otherPage.name}');
          throw BottomNavIndexConflictException(bottomNavIndex, otherPage.name);
        }
      }
    }
    
    // Simulate the new configuration to check minimum 2 pages rule
    // Count how many pages would be active after this change
    int activeCount = 0;
    for (final entry in allPublishedPages.entries) {
      final otherPage = entry.value;
      
      // For the page being modified, use the new values
      if (otherPage.pageId == pageId) {
        if (isActive && 
            bottomNavIndex != null && 
            bottomNavIndex >= 0 && 
            bottomNavIndex <= 4) {
          activeCount++;
        }
      } else {
        // For other pages, check if they're currently active
        if (otherPage.isActive && 
            otherPage.bottomNavIndex != null && 
            otherPage.bottomNavIndex >= 0 && 
            otherPage.bottomNavIndex <= 4) {
          activeCount++;
        }
      }
    }
    
    // Check minimum 2 pages rule
    if (activeCount < 2) {
      debugPrint('[BuilderPageService] ❌ Cannot configure less than 2 active pages (would result in $activeCount)');
      throw MinimumBottomNavItemsException();
    }
    
    // Update navigation parameters
    // When isActive is true:
    //   - Set isActive, bottomNavIndex, displayLocation="bottomBar", order=bottomNavIndex
    // When isActive is false:
    //   - Set isActive=false, bottomNavIndex=null, displayLocation="hidden", order=999
    final String displayLocation = isActive ? 'bottomBar' : 'hidden';
    final int finalOrder = isActive ? bottomNavIndex! : 999;
    final int? finalBottomNavIndex = isActive ? bottomNavIndex : null;
    
    final updatedPage = page.copyWith(
      isActive: isActive,
      bottomNavIndex: finalBottomNavIndex,
      displayLocation: displayLocation,
      order: finalOrder,
      updatedAt: DateTime.now(),
    );
    
    // Save to both draft and published if published exists
    await _layoutService.saveDraft(updatedPage.copyWith(isDraft: true));
    
    if (await _layoutService.hasPublished(appId, pageId)) {
      await _layoutService.publishPage(
        updatedPage,
        userId: 'system',
        shouldDeleteDraft: false,
      );
    }
    
    debugPrint('[BuilderPageService] ✅ Updated navigation for ${pageId.value}: isActive=$isActive, index=$bottomNavIndex');
    return updatedPage;
  }

  // ==================== MODULES ====================

  /// Add a module to a page
  /// 
  /// Modules are functional components like menu catalog, cart, etc.
  /// Available modules: menu_catalog, cart_module, profile_module, roulette_module
  /// 
  /// Example:
  /// ```dart
  /// await service.addModuleToPage(
  ///   BuilderPageId.home,
  ///   'delizza',
  ///   'menu_catalog',
  /// );
  /// ```
  Future<BuilderPage?> addModuleToPage(
    BuilderPageId pageId,
    String appId,
    String moduleId,
  ) async {
    try {
      // Validate module ID
      if (!isValidModuleId(moduleId)) {
        debugPrint('[BuilderPageService] ⚠️ Invalid module ID: $moduleId');
        return null;
      }
      
      // Load page
      var page = await _layoutService.loadDraft(appId, pageId);
      page ??= await _layoutService.loadPublished(appId, pageId);
      
      if (page == null) {
        debugPrint('[BuilderPageService] ⚠️ Page not found: ${pageId.value}');
        return null;
      }
      
      // Add module
      final updatedPage = page.addModule(moduleId);
      
      // Save draft
      await _layoutService.saveDraft(updatedPage.copyWith(isDraft: true));
      
      debugPrint('[BuilderPageService] ✅ Added module $moduleId to ${pageId.value}');
      return updatedPage;
    } catch (e, stackTrace) {
      debugPrint('[BuilderPageService] ❌ Error adding module: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Remove a module from a page
  /// 
  /// Example:
  /// ```dart
  /// await service.removeModuleFromPage(
  ///   BuilderPageId.home,
  ///   'delizza',
  ///   'roulette_module',
  /// );
  /// ```
  Future<BuilderPage?> removeModuleFromPage(
    BuilderPageId pageId,
    String appId,
    String moduleId,
  ) async {
    try {
      // Load page
      var page = await _layoutService.loadDraft(appId, pageId);
      page ??= await _layoutService.loadPublished(appId, pageId);
      
      if (page == null) {
        debugPrint('[BuilderPageService] ⚠️ Page not found: ${pageId.value}');
        return null;
      }
      
      // Remove module
      final updatedPage = page.removeModule(moduleId);
      
      // Save draft
      await _layoutService.saveDraft(updatedPage.copyWith(isDraft: true));
      
      debugPrint('[BuilderPageService] ✅ Removed module $moduleId from ${pageId.value}');
      return updatedPage;
    } catch (e, stackTrace) {
      debugPrint('[BuilderPageService] ❌ Error removing module: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  // ==================== CLEANUP ====================

  /// Clean duplicate pages
  /// 
  /// Removes duplicate pages that may have been created accidentally.
  /// Keeps the most recently updated version of each pageId.
  /// 
  /// Returns the number of duplicates removed.
  /// 
  /// Example:
  /// ```dart
  /// final removed = await service.cleanDuplicatePages('delizza');
  /// print('Removed $removed duplicate pages');
  /// ```
  Future<int> cleanDuplicatePages(String appId) async {
    try {
      // Load all draft and published pages
      final draftPages = await _layoutService.loadAllDraftPages(appId);
      final publishedPages = await _layoutService.loadAllPublishedPages(appId);
      
      int removedCount = 0;
      
      // Check for pages that exist in both draft and published
      // with the same pageId but different content
      final seenPageIds = <String>{};
      
      // Process draft pages - remove duplicates
      for (final entry in draftPages.entries) {
        final pageIdStr = entry.key; // entry.key is already a String
        
        if (seenPageIds.contains(pageIdStr)) {
          // This is a duplicate, remove it
          await _layoutService.deleteDraft(appId, entry.key);
          removedCount++;
          debugPrint('[BuilderPageService] Removed duplicate draft: $pageIdStr');
        } else {
          seenPageIds.add(pageIdStr);
        }
      }
      
      // Reset for published pages
      seenPageIds.clear();
      
      // Process published pages - remove duplicates
      for (final entry in publishedPages.entries) {
        final pageIdStr = entry.key; // entry.key is already a String
        
        if (seenPageIds.contains(pageIdStr)) {
          // This is a duplicate, remove it
          await _layoutService.deletePublished(appId, entry.key);
          removedCount++;
          debugPrint('[BuilderPageService] Removed duplicate published: $pageIdStr');
        } else {
          seenPageIds.add(pageIdStr);
        }
      }
      
      if (removedCount > 0) {
        debugPrint('[BuilderPageService] ✅ Cleaned $removedCount duplicate pages');
      } else {
        debugPrint('[BuilderPageService] ℹ️ No duplicate pages found');
      }
      
      return removedCount;
    } catch (e, stackTrace) {
      debugPrint('[BuilderPageService] ❌ Error cleaning duplicates: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return 0;
    }
  }

  /// Get pages with unpublished changes
  /// 
  /// Returns list of pages where draftLayout differs from publishedLayout.
  Future<List<BuilderPage>> getPagesWithUnpublishedChanges(String appId) async {
    try {
      final draftPages = await _layoutService.loadAllDraftPages(appId);
      
      return draftPages.values
          .where((page) => page.hasUnpublishedChanges)
          .toList();
    } catch (e, stackTrace) {
      debugPrint('[BuilderPageService] ❌ Error getting unpublished pages: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return [];
    }
  }

  // ==================== SYSTEM PAGE FIXES ====================

  /// Fix system pages with empty layouts by injecting their default modules
  /// 
  /// This method scans active system pages (cart, menu, profile, roulette)
  /// and injects their default module if both draftLayout and publishedLayout are empty.
  /// 
  /// It checks both pages_system AND pages_published collections to handle
  /// pages created during auto-initialization.
  /// 
  /// Returns the number of pages fixed.
  /// 
  /// Example:
  /// ```dart
  /// final fixed = await service.fixEmptySystemPages('delizza');
  /// print('Fixed $fixed system pages');
  /// ```
  Future<int> fixEmptySystemPages(String appId) async {
    try {
      int fixedCount = 0;
      
      // Collect all pages to check from both collections
      final pagesToCheck = <BuilderPage>[];
      
      // Load from pages_system collection
      final systemPages = await _layoutService.loadSystemPages(appId);
      pagesToCheck.addAll(systemPages);
      
      // Also load from pages_published collection (for auto-initialized pages)
      final publishedPages = await _layoutService.loadAllPublishedPages(appId);
      
      // Add published pages that are system pages and not already in the list
      for (final page in publishedPages.values) {
        if (page.systemId != null) {
          // Check if this page is already in pagesToCheck (by pageKey)
          final alreadyExists = pagesToCheck.any((p) => p.pageKey == page.pageKey);
          if (!alreadyExists) {
            pagesToCheck.add(page);
          }
        }
      }
      
      for (final page in pagesToCheck) {
        // Only fix active system pages with empty layouts
        if (!page.isActive) continue;
        
        // Check if page has content - use blocks field too for legacy pages
        final hasContent = page.draftLayout.isNotEmpty || 
                          page.publishedLayout.isNotEmpty ||
                          page.blocks.isNotEmpty;
        if (hasContent) continue;
        
        // Determine which module/blocks to inject based on systemId (for system pages)
        // Note: This block generation is similar to BuilderNavigationService._getDefaultBlocksForPage
        // but serves a different purpose - fixing existing empty pages vs creating new pages.
        // Both include SystemBlock modules for proper runtime rendering.
        final sysId = page.systemId;
        if (sysId == null) continue; // Skip custom pages
        
        List<BuilderBlock> defaultBlocks;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        switch (sysId) {
          case BuilderPageId.home:
            // Home page gets hero and product list blocks
            defaultBlocks = [
              BuilderBlock(
                id: 'hero_fix_$timestamp',
                type: BlockType.hero,
                order: 0,
                config: {
                  'title': 'Bienvenue',
                  'subtitle': 'Découvrez nos délicieuses pizzas',
                  'imageUrl': '',
                  'buttonLabel': 'Voir le menu',
                  'tapAction': 'openPage',
                  'tapActionTarget': '/menu',
                },
              ),
              BuilderBlock(
                id: 'product_list_fix_$timestamp',
                type: BlockType.productList,
                order: 1,
                config: {
                  'title': 'Nos spécialités',
                  'mode': 'featured',
                  'layout': 'grid',
                  'limit': 4,
                  'columns': 2,
                },
              ),
            ];
            break;
          case BuilderPageId.cart:
            defaultBlocks = [
              SystemBlock(
                id: 'cart_module_fix_$timestamp',
                moduleType: 'cart_module',
                order: 0,
              ),
            ];
            break;
          case BuilderPageId.menu:
            defaultBlocks = [
              SystemBlock(
                id: 'menu_catalog_fix_$timestamp',
                moduleType: 'menu_catalog',
                order: 0,
              ),
            ];
            break;
          case BuilderPageId.profile:
            defaultBlocks = [
              SystemBlock(
                id: 'profile_module_fix_$timestamp',
                moduleType: 'profile_module',
                order: 0,
              ),
            ];
            break;
          case BuilderPageId.roulette:
            defaultBlocks = [
              SystemBlock(
                id: 'roulette_module_fix_$timestamp',
                moduleType: 'roulette_module',
                order: 0,
              ),
            ];
            break;
          default:
            continue; // Skip non-applicable system pages
        }
        
        // Update the page with the default blocks in all layout fields
        final updatedPage = page.copyWith(
          blocks: defaultBlocks,
          draftLayout: defaultBlocks,
          publishedLayout: defaultBlocks,
          hasUnpublishedChanges: false,
          updatedAt: DateTime.now(),
        );
        
        // Save to both draft and published collections to ensure content is available
        await _layoutService.saveDraft(updatedPage.copyWith(isDraft: true));
        await _layoutService.publishPage(
          updatedPage,
          userId: 'system_fix',
          shouldDeleteDraft: false,
        );
        
        fixedCount++;
        debugPrint('[BuilderPageService] ✅ Fixed empty system page: ${page.pageKey} with ${defaultBlocks.length} default blocks');
      }
      
      if (fixedCount > 0) {
        debugPrint('[BuilderPageService] ✅ Fixed $fixedCount system pages with empty layouts');
      } else {
        debugPrint('[BuilderPageService] ℹ️ No system pages need fixing');
      }
      
      return fixedCount;
    } catch (e, stackTrace) {
      debugPrint('[BuilderPageService] ❌ Error fixing empty system pages: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return 0;
    }
  }

  // ==================== PRIVATE HELPERS ====================

  /// Generate a unique pageId from a name
  String _generatePageId(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '')
        .substring(0, name.length > 20 ? 20 : name.length);
  }

  /// Get template blocks based on template ID
  List<BuilderBlock> _getTemplateBlocks(String templateId) {
    switch (templateId) {
      case 'home_template':
        return _buildHomeTemplateBlocks();
      case 'menu_template':
      case 'menu':
        return _buildMenuTemplateBlocks();
      case 'cart':
      case 'cart_template':
        return _buildCartTemplateBlocks();
      case 'profile':
      case 'profile_template':
        return _buildProfileTemplateBlocks();
      case 'roulette':
      case 'roulette_template':
        return _buildRouletteTemplateBlocks();
      case 'promo_template':
        return _buildPromoTemplateBlocks();
      case 'about_template':
        return _buildAboutTemplateBlocks();
      case 'contact_template':
        return _buildContactTemplateBlocks();
      default:
        // Unknown template, return empty blocks
        return [];
    }
  }

  /// Home template blocks
  List<BuilderBlock> _buildHomeTemplateBlocks() {
    return [
      BuilderBlock(
        id: 'hero-1',
        type: BlockType.hero,
        order: 0,
        config: {
          'title': 'Bienvenue',
          'subtitle': 'Découvrez nos délicieuses pizzas',
          'imageUrl': '',
          'buttonLabel': 'Voir le menu',
          'tapAction': 'openPage',
          'tapActionTarget': '/menu',
        },
      ),
      BuilderBlock(
        id: 'product-list-1',
        type: BlockType.productList,
        order: 1,
        config: {
          'title': 'Nos spécialités',
          'mode': 'featured',
          'layout': 'grid',
          'limit': 4,
          'columns': 2,
        },
      ),
      BuilderBlock(
        id: 'info-1',
        type: BlockType.info,
        order: 2,
        config: {
          'title': 'Livraison gratuite à partir de 25€',
          'subtitle': '',
        },
      ),
    ];
  }

  /// Menu template blocks
  List<BuilderBlock> _buildMenuTemplateBlocks() {
    return [
      SystemBlock(
        id: 'menu-module-1',
        moduleType: 'menu_catalog',
        order: 0,
      ),
    ];
  }
  
  /// Cart template blocks
  List<BuilderBlock> _buildCartTemplateBlocks() {
    return [
      SystemBlock(
        id: 'cart-module-1',
        moduleType: 'cart_module',
        order: 0,
      ),
    ];
  }
  
  /// Profile template blocks
  List<BuilderBlock> _buildProfileTemplateBlocks() {
    return [
      SystemBlock(
        id: 'profile-module-1',
        moduleType: 'profile_module',
        order: 0,
      ),
    ];
  }
  
  /// Roulette template blocks
  List<BuilderBlock> _buildRouletteTemplateBlocks() {
    return [
      SystemBlock(
        id: 'roulette-module-1',
        moduleType: 'roulette_module',
        order: 0,
      ),
    ];
  }

  /// Promo template blocks
  List<BuilderBlock> _buildPromoTemplateBlocks() {
    return [
      BuilderBlock(
        id: 'banner-1',
        type: BlockType.banner,
        order: 0,
        config: {
          'text': 'Offres spéciales',
          'backgroundColor': '#FF5722',
          'textColor': '#FFFFFF',
        },
      ),
      BuilderBlock(
        id: 'text-1',
        type: BlockType.text,
        order: 1,
        config: {
          'content': 'Découvrez nos promotions du moment !',
          'fontSize': 18.0,
          'textAlign': 'center',
        },
      ),
      BuilderBlock(
        id: 'product-list-1',
        type: BlockType.productList,
        order: 2,
        config: {
          'mode': 'promo',
          'layout': 'grid',
          'limit': 6,
          'columns': 2,
          'title': 'En promotion',
        },
      ),
    ];
  }

  /// About template blocks
  List<BuilderBlock> _buildAboutTemplateBlocks() {
    return [
      BuilderBlock(
        id: 'text-1',
        type: BlockType.text,
        order: 0,
        config: {
          'content': 'À propos de nous',
          'fontSize': 28.0,
          'fontWeight': 'bold',
          'textAlign': 'center',
        },
      ),
      BuilderBlock(
        id: 'image-1',
        type: BlockType.image,
        order: 1,
        config: {
          'imageUrl': '',
          'alt': 'Notre restaurant',
        },
      ),
      BuilderBlock(
        id: 'text-2',
        type: BlockType.text,
        order: 2,
        config: {
          'content': 'Notre histoire commence ici. Ajoutez votre texte personnalisé.',
          'fontSize': 16.0,
          'textAlign': 'left',
        },
      ),
    ];
  }

  /// Contact template blocks
  List<BuilderBlock> _buildContactTemplateBlocks() {
    return [
      BuilderBlock(
        id: 'text-1',
        type: BlockType.text,
        order: 0,
        config: {
          'content': 'Contactez-nous',
          'fontSize': 28.0,
          'fontWeight': 'bold',
          'textAlign': 'center',
        },
      ),
      BuilderBlock(
        id: 'info-1',
        type: BlockType.info,
        order: 1,
        config: {
          'title': 'Nos coordonnées',
          'subtitle': '📍 Adresse: Votre adresse ici\n📞 Téléphone: +33 X XX XX XX XX\n✉️ Email: contact@example.com',
        },
      ),
      BuilderBlock(
        id: 'text-2',
        type: BlockType.text,
        order: 2,
        config: {
          'content': 'Horaires d\'ouverture:\nLundi - Vendredi: 11h - 22h\nSamedi - Dimanche: 11h - 23h',
          'fontSize': 16.0,
          'textAlign': 'center',
        },
      ),
    ];
  }
}
