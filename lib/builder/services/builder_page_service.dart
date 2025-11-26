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
    
    // Generate unique pageId for custom pages
    final pageIdValue = _generatePageId(name);
    final pageId = BuilderPageId.fromString(pageIdValue);
    
    final page = BuilderPage(
      pageId: pageId,
      appId: appId,
      name: name,
      description: description ?? 'Page créée depuis le template $templateId',
      route: route ?? '/${pageIdValue}',
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
    
    debugPrint('[BuilderPageService] ✅ Created page from template: $templateId → ${page.name}');
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
    // Generate unique pageId for custom pages
    final pageIdValue = _generatePageId(name);
    final pageId = BuilderPageId.fromString(pageIdValue);
    
    final page = BuilderPage(
      pageId: pageId,
      appId: appId,
      name: name,
      description: description ?? 'Page vierge',
      route: route ?? '/${pageIdValue}',
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
    
    debugPrint('[BuilderPageService] ✅ Created blank page: ${page.name}');
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
  /// ```
  Future<BuilderPage?> toggleActiveStatus(
    BuilderPageId pageId,
    String appId,
    bool isActive,
  ) async {
    try {
      // Load page (draft first, then published)
      var page = await _layoutService.loadDraft(appId, pageId);
      page ??= await _layoutService.loadPublished(appId, pageId);
      
      if (page == null) {
        debugPrint('[BuilderPageService] ⚠️ Page not found: ${pageId.value}');
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
      
      debugPrint('[BuilderPageService] ✅ Set active=$isActive for: ${pageId.value}');
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
  /// Example:
  /// ```dart
  /// await service.reorderBottomNav(
  ///   BuilderPageId.menu,
  ///   'delizza',
  ///   newIndex: 2, // Move to 3rd position (0-indexed)
  /// );
  /// ```
  Future<BuilderPage?> reorderBottomNav(
    BuilderPageId pageId,
    String appId,
    int newIndex,
  ) async {
    try {
      // Load page
      var page = await _layoutService.loadDraft(appId, pageId);
      page ??= await _layoutService.loadPublished(appId, pageId);
      
      if (page == null) {
        debugPrint('[BuilderPageService] ⚠️ Page not found: ${pageId.value}');
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
      
      debugPrint('[BuilderPageService] ✅ Reordered ${pageId.value} to index $newIndex');
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
  /// - Updates both draft and published versions
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
  Future<BuilderPage?> updatePageNavigation({
    required BuilderPageId pageId,
    required String appId,
    required bool isActive,
    required int? bottomNavIndex,
  }) async {
    try {
      // Validation: if active, bottomNavIndex must be provided and valid
      if (isActive) {
        if (bottomNavIndex == null) {
          debugPrint('[BuilderPageService] ❌ bottomNavIndex required when isActive is true');
          return null;
        }
        
        if (bottomNavIndex < 0 || bottomNavIndex > 4) {
          debugPrint('[BuilderPageService] ❌ bottomNavIndex must be between 0 and 4');
          return null;
        }
      }
      
      // Check for duplicate bottomNavIndex among active pages
      if (isActive && bottomNavIndex != null) {
        final allDraftPages = await _layoutService.loadAllDraftPages(appId);
        
        // Check for duplicates (excluding current page)
        for (final entry in allDraftPages.entries) {
          final otherPage = entry.value;
          if (otherPage.pageId != pageId && 
              otherPage.isActive && 
              otherPage.bottomNavIndex == bottomNavIndex) {
            debugPrint('[BuilderPageService] ❌ Duplicate bottomNavIndex $bottomNavIndex found on page ${otherPage.pageId.value}');
            return null;
          }
        }
      }
      
      // Load page
      var page = await _layoutService.loadDraft(appId, pageId);
      page ??= await _layoutService.loadPublished(appId, pageId);
      
      if (page == null) {
        debugPrint('[BuilderPageService] ⚠️ Page not found: ${pageId.value}');
        return null;
      }
      
      // Update navigation parameters
      final updatedPage = page.copyWith(
        isActive: isActive,
        bottomNavIndex: bottomNavIndex ?? page.bottomNavIndex,
        order: bottomNavIndex ?? page.order,
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
    } catch (e, stackTrace) {
      debugPrint('[BuilderPageService] ❌ Error updating page navigation: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
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
        final pageIdStr = entry.key.value;
        
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
        final pageIdStr = entry.key.value;
        
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
      
      // Load all system pages
      final systemPages = await _layoutService.loadSystemPages();
      
      for (final page in systemPages) {
        // Only fix active system pages with empty layouts
        if (!page.isActive) continue;
        if (page.draftLayout.isNotEmpty || page.publishedLayout.isNotEmpty) continue;
        
        // Determine which module to inject based on page ID
        String? moduleType;
        switch (page.pageId) {
          case BuilderPageId.cart:
            moduleType = 'cart_module';
            break;
          case BuilderPageId.menu:
            moduleType = 'menu_catalog';
            break;
          case BuilderPageId.profile:
            moduleType = 'profile_module';
            break;
          case BuilderPageId.roulette:
            moduleType = 'roulette_module';
            break;
          default:
            continue; // Skip non-applicable system pages
        }
        
        // Create a module block
        final moduleBlock = SystemBlock(
          id: '${moduleType}_auto_${DateTime.now().millisecondsSinceEpoch}',
          moduleType: moduleType,
          order: 0,
        );
        
        // Update the page with the module
        final updatedPage = page.copyWith(
          draftLayout: [moduleBlock],
          hasUnpublishedChanges: true,
          updatedAt: DateTime.now(),
        );
        
        // Save the updated page
        await _layoutService.saveDraft(updatedPage);
        
        fixedCount++;
        debugPrint('[BuilderPageService] ✅ Fixed empty system page: ${page.pageId.value} with $moduleType');
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
          'ctaText': 'Voir le menu',
          'ctaAction': {'type': 'navigate', 'target': '/menu'},
        },
      ),
      BuilderBlock(
        id: 'product-list-1',
        type: BlockType.productList,
        order: 1,
        config: {
          'mode': 'featured',
          'layout': 'horizontal',
          'title': 'Nos spécialités',
          'limit': 4,
        },
      ),
      BuilderBlock(
        id: 'info-1',
        type: BlockType.info,
        order: 2,
        config: {
          'message': 'Livraison gratuite à partir de 25€',
          'type': 'info',
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
          'message': '📍 Adresse: Votre adresse ici\n📞 Téléphone: +33 X XX XX XX XX\n✉️ Email: contact@example.com',
          'type': 'info',
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
