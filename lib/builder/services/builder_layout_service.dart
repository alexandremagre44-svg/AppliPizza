// lib/builder/services/builder_layout_service.dart
// Firestore service for managing Builder B3 page layouts
//
// New Firestore structure:
// restaurants/{restaurantId}/pages_draft/{pageId}
// restaurants/{restaurantId}/pages_published/{pageId}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../../src/core/firestore_paths.dart';

/// Service for managing Builder B3 page layouts in Firestore
/// 
/// Firestore structure:
/// ```
/// restaurants/{restaurantId}/pages_draft/{pageId}
/// restaurants/{restaurantId}/pages_published/{pageId}
/// ```
/// 
/// Features:
/// - Draft/published workflow
/// - Multi-page support (home, menu, promo, etc.)
/// - Multi-resto support (different restaurantId per restaurant)
/// - Version control
/// - Real-time updates via streams
class BuilderLayoutService {
  final FirebaseFirestore _firestore;
  
  /// Maximum valid bottomNavIndex value (values >= this are considered "not in bottom bar")
  static const int _maxBottomNavIndex = 999;

  BuilderLayoutService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Convert a dynamic pageId (String or BuilderPageId enum) to String
  /// 
  /// This allows methods to accept either format for flexibility.
  /// - String: returned as-is
  /// - BuilderPageId enum: returns the .value property
  /// - Other: converts to string using toString()
  String _toPageIdString(dynamic pageId) {
    if (pageId is String) return pageId;
    if (pageId is BuilderPageId) return pageId.value;
    return pageId.toString();
  }

  /// Get document reference for draft page
  /// Path: restaurants/{restaurantId}/pages_draft/{pageId}
  /// 
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  DocumentReference _getDraftRef(String appId, dynamic pageId) {
    final pageIdStr = _toPageIdString(pageId);
    return FirestorePaths.draftDoc(pageIdStr, appId);
  }

  /// Get document reference for published page
  /// Path: restaurants/{restaurantId}/pages_published/{pageId}
  /// 
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  DocumentReference _getPublishedRef(String appId, dynamic pageId) {
    final pageIdStr = _toPageIdString(pageId);
    return FirestorePaths.publishedDoc(pageIdStr, appId);
  }

  // ==================== DRAFT OPERATIONS ====================

  /// Save a draft page with system page protections
  /// 
  /// Protections:
  /// - System pages retain isSystemPage = true
  /// - SystemBlocks retain type = system
  /// - System page pageId cannot be changed
  /// 
  /// Uses page.pageKey as the Firestore document ID (supports custom pages).
  /// 
  /// Example:
  /// ```dart
  /// final page = BuilderPage(..., isDraft: true);
  /// await service.saveDraft(page);
  /// ```
  Future<void> saveDraft(BuilderPage page) async {
    if (!page.isDraft) {
      throw ArgumentError('Page must be marked as draft (isDraft: true)');
    }

    // Apply system page protections
    final protectedPage = _applySystemProtections(page);

    // Use pageKey as the document ID (supports custom pages)
    final ref = _getDraftRef(protectedPage.appId, protectedPage.pageKey);
    final data = protectedPage.toJson();
    
    await ref.set(data, SetOptions(merge: true));
  }
  
  /// Apply protection rules to a page before saving
  /// 
  /// Ensures:
  /// - System pages always have isSystemPage = true
  /// - SystemBlocks always have type = system
  /// - displayLocation is valid for system pages
  BuilderPage _applySystemProtections(BuilderPage page) {
    var protectedPage = page;
    
    // Ensure system pages retain their isSystemPage flag
    // Use systemId (which is always set for system pages) or check pageId if set
    final isSystemPageById = page.systemId?.isSystemPage ?? page.pageId?.isSystemPage ?? false;
    if (isSystemPageById && !page.isSystemPage) {
      debugPrint('⚠️ Warning: Correcting isSystemPage for system page ${page.pageKey}');
      protectedPage = protectedPage.copyWith(isSystemPage: true);
    }
    
    // Validate displayLocation for system pages (only allow bottomBar or hidden)
    if (protectedPage.isSystemPage) {
      final validLocations = ['bottomBar', 'hidden'];
      if (!validLocations.contains(protectedPage.displayLocation)) {
        debugPrint('⚠️ Warning: Correcting displayLocation for system page ${page.pageKey}');
        protectedPage = protectedPage.copyWith(displayLocation: 'hidden');
      }
    }
    
    // Protect SystemBlocks - ensure type remains 'system'
    final protectedBlocks = page.blocks.map((block) {
      if (block.type == BlockType.system) {
        // Ensure moduleType is preserved and valid
        final moduleType = block.getConfig<String>('moduleType', 'unknown') ?? 'unknown';
        if (!SystemBlock.availableModules.contains(moduleType)) {
          debugPrint('⚠️ Warning: Unknown module type "$moduleType" in SystemBlock');
        }
      }
      return block;
    }).toList();
    
    if (protectedBlocks != page.blocks) {
      protectedPage = protectedPage.copyWith(blocks: protectedBlocks);
    }
    
    return protectedPage;
  }
  
  /// Debug print helper (only in debug mode)
  void debugPrint(String message) {
    assert(() {
      print(message);
      return true;
    }());
  }

  /// Load draft page with fallback to published content
  /// 
  /// **Fix for 'Ghost Content' Bug:**
  /// If the draft document is missing or has empty draftLayout, this method
  /// automatically loads the published version and creates a fresh draft from it.
  /// This ensures the editor never opens on a blank page if published content exists.
  /// 
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  /// Returns null only if both draft and published versions don't exist.
  Future<BuilderPage?> loadDraft(String appId, dynamic pageId) async {
    try {
      final ref = _getDraftRef(appId, pageId);
      final snapshot = await ref.get();

      // Case 1: Draft exists and has content
      if (snapshot.exists && snapshot.data() != null) {
        final draftPage = BuilderPage.fromJson(snapshot.data() as Map<String, dynamic>);
        
        // Check if draft has meaningful content in draftLayout
        if (draftPage.draftLayout.isNotEmpty) {
          return draftPage;
        }
        
        // Draft exists but draftLayout is empty - try to sync from published
        final pageIdStr = _toPageIdString(pageId);
        debugPrint('⚠️ Draft exists but draftLayout is empty for $pageIdStr, checking published...');
      }

      // Case 2: Draft doesn't exist or has empty draftLayout - try published version
      // SELF-HEAL FIX: Persist the draft to Firestore so editor always has content
      final publishedPage = await loadPublished(appId, pageId);
      if (publishedPage != null && publishedPage.publishedLayout.isNotEmpty) {
        final pageIdStr = _toPageIdString(pageId);
        debugPrint('📋 [SELF-HEAL] Creating and PERSISTING draft from published for $pageIdStr');
        
        // Create a fresh draft by copying publishedLayout into draftLayout
        final newDraft = publishedPage.copyWith(
          isDraft: true,
          draftLayout: publishedPage.publishedLayout.toList(),
          hasUnpublishedChanges: false,
        );
        
        // CRITICAL: Persist to Firestore immediately (draft only, NEVER publish)
        // This ensures the editor won't load stale/empty data on next access
        try {
          await saveDraft(newDraft);
          debugPrint('✅ [SELF-HEAL] Draft persisted to pages_draft/$pageIdStr');
        } catch (saveError) {
          debugPrint('⚠️ [SELF-HEAL] Failed to persist draft: $saveError (returning in-memory copy)');
        }
        
        return newDraft;
      }

      // Case 3: Neither draft nor published have content
      // Return the original draft if it exists (even if empty), otherwise null
      if (snapshot.exists && snapshot.data() != null) {
        return BuilderPage.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      print('Error loading draft: $e');
      return null;
    }
  }

  /// Watch draft page changes in real-time
  /// 
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  /// 
  /// Example:
  /// ```dart
  /// service.watchDraft('pizza_delizza', BuilderPageId.home).listen((page) {
  ///   if (page != null) {
  ///     print('Draft updated: ${page.version}');
  ///   }
  /// });
  /// // Or with string pageId for custom pages:
  /// service.watchDraft('pizza_delizza', 'promo_noel').listen((page) { ... });
  /// ```
  Stream<BuilderPage?> watchDraft(String appId, dynamic pageId) {
    return _getDraftRef(appId, pageId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      
      try {
        return BuilderPage.fromJson(snapshot.data() as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing draft: $e');
        return null;
      }
    });
  }

  /// Delete draft page
  /// 
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  Future<void> deleteDraft(String appId, dynamic pageId) async {
    final ref = _getDraftRef(appId, pageId);
    await ref.delete();
  }

  /// Check if draft exists
  /// 
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  Future<bool> hasDraft(String appId, dynamic pageId) async {
    final ref = _getDraftRef(appId, pageId);
    final snapshot = await ref.get();
    return snapshot.exists && snapshot.data() != null;
  }

  // ==================== PUBLISHED OPERATIONS ====================

  /// Publish a page
  /// 
  /// This will:
  /// 1. Save to published collection
  /// 2. Mark as published (isDraft: false)
  /// 3. Set publishedAt timestamp
  /// 4. Optionally delete draft
  /// 
  /// Uses page.pageKey as the Firestore document ID (supports custom pages).
  /// 
  /// Example:
  /// ```dart
  /// final draft = await service.loadDraft('pizza_delizza', BuilderPageId.home);
  /// await service.publishPage(draft!, userId: 'admin_123', shouldDeleteDraft: true);
  /// ```
  Future<void> publishPage(
    BuilderPage page, {
    required String userId,
    bool shouldDeleteDraft = false,
  }) async {
    // Create published version
    final publishedPage = page.publish(userId: userId);

    // Save to published collection using pageKey (supports custom pages)
    final ref = _getPublishedRef(page.appId, page.pageKey);
    await ref.set(publishedPage.toJson());

    // Optionally delete draft
    if (shouldDeleteDraft) {
      await deleteDraft(page.appId, page.pageKey);
    }
  }

  /// Load published page
  /// 
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  /// Returns null if no published version exists.
  Future<BuilderPage?> loadPublished(String appId, dynamic pageId) async {
    try {
      final ref = _getPublishedRef(appId, pageId);
      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      return BuilderPage.fromJson(snapshot.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error loading published page: $e');
      return null;
    }
  }

  /// Load published page by Firestore document ID (for custom pages)
  /// 
  /// This method loads a page directly by its Firestore document ID,
  /// which is useful for custom pages that don't have a BuilderPageId enum value.
  /// 
  /// Returns null if no published version exists.
  Future<BuilderPage?> loadPublishedByDocId(String appId, String docId) async {
    try {
      final ref = FirestorePaths.publishedDoc(docId, appId);
      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      final data = snapshot.data()!;
      // Ensure pageKey is set from docId if not present
      if (data['pageKey'] == null) {
        data['pageKey'] = docId;
      }
      if (data['pageId'] == null) {
        data['pageId'] = docId;
      }
      
      return BuilderPage.fromJson(data);
    } catch (e) {
      debugPrint('Error loading published page by docId $docId: $e');
      return null;
    }
  }

  /// Watch published page changes in real-time
  /// 
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  /// 
  /// Example:
  /// ```dart
  /// service.watchPublished('pizza_delizza', BuilderPageId.home).listen((page) {
  ///   if (page != null) {
  ///     // Update UI with published page
  ///   }
  /// });
  /// // Or with string pageId for custom pages:
  /// service.watchPublished('pizza_delizza', 'promo_noel').listen((page) { ... });
  /// ```
  Stream<BuilderPage?> watchPublished(String appId, dynamic pageId) {
    return _getPublishedRef(appId, pageId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      
      try {
        return BuilderPage.fromJson(snapshot.data() as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing published page: $e');
        return null;
      }
    });
  }

  /// Delete published page
  /// 
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  Future<void> deletePublished(String appId, dynamic pageId) async {
    final ref = _getPublishedRef(appId, pageId);
    await ref.delete();
  }

  /// Check if published version exists
  /// 
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  Future<bool> hasPublished(String appId, dynamic pageId) async {
    final ref = _getPublishedRef(appId, pageId);
    final snapshot = await ref.get();
    return snapshot.exists && snapshot.data() != null;
  }

  /// Unpublish a page (move published back to draft)
  /// 
  /// This will:
  /// 1. Load published version
  /// 2. Convert to draft
  /// 3. Save as draft
  /// 4. Optionally delete published version
  /// 
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  Future<void> unpublishPage(
    String appId,
    dynamic pageId, {
    bool deletePublished = true,
  }) async {
    final published = await loadPublished(appId, pageId);
    if (published == null) {
      throw StateError('No published page found to unpublish');
    }

    // Convert to draft
    final draft = published.createDraft();
    
    // Save as draft
    await saveDraft(draft);

    // Optionally delete published
    if (deletePublished) {
      await this.deletePublished(appId, pageId);
    }
  }

  // ==================== SMART LOAD OPERATIONS ====================

  /// Load page (prefers draft, falls back to published)
  /// 
  /// Useful for editor: always show latest version.
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  Future<BuilderPage?> loadPage(String appId, dynamic pageId) async {
    // Try draft first
    final draft = await loadDraft(appId, pageId);
    if (draft != null) return draft;

    // Fall back to published
    return await loadPublished(appId, pageId);
  }

  /// Watch page (prefers draft, falls back to published)
  /// 
  /// Returns a stream that emits the most recent version.
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  Stream<BuilderPage?> watchPage(String appId, dynamic pageId) async* {
    // First try to load draft
    final draft = await loadDraft(appId, pageId);
    if (draft != null) {
      yield draft;
      // Then watch draft changes
      yield* watchDraft(appId, pageId);
    } else {
      // No draft, load and watch published
      final published = await loadPublished(appId, pageId);
      if (published != null) {
        yield published;
      }
      yield* watchPublished(appId, pageId);
    }
  }

  // ==================== MULTI-PAGE OPERATIONS ====================

  /// Load all published pages for an app
  /// 
  /// Returns a map of pageKey (String) -> BuilderPage
  /// This includes both system pages (with BuilderPageId enum) and custom pages.
  Future<Map<String, BuilderPage>> loadAllPublishedPages(
    String appId,
  ) async {
    final result = <String, BuilderPage>{};

    try {
      // Query all documents in pages_published collection
      final snapshot = await FirestorePaths.pagesPublished(appId).get();
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          // Ensure pageKey is set from doc.id if not present
          // Note: We only set pageKey, not pageId. fromJson will derive pageId
          // from pageKey if it matches a known system page.
          if (data['pageKey'] == null) {
            data['pageKey'] = doc.id;
          }
          
          final page = BuilderPage.fromJson(data);
          result[page.pageKey] = page;
        } catch (e) {
          debugPrint('Error parsing published page ${doc.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading all published pages: $e');
    }

    return result;
  }

  /// Load all draft pages for an app
  /// 
  /// Returns a map of pageKey (String) -> BuilderPage
  /// This includes both system pages (with BuilderPageId enum) and custom pages.
  Future<Map<String, BuilderPage>> loadAllDraftPages(
    String appId,
  ) async {
    final result = <String, BuilderPage>{};

    try {
      // Query all documents in pages_draft collection
      final snapshot = await FirestorePaths.pagesDraft(appId).get();
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          // Ensure pageKey is set from doc.id if not present
          // Note: We only set pageKey, not pageId. fromJson will derive pageId
          // from pageKey if it matches a known system page.
          if (data['pageKey'] == null) {
            data['pageKey'] = doc.id;
          }
          
          final page = BuilderPage.fromJson(data);
          result[page.pageKey] = page;
        } catch (e) {
          debugPrint('Error parsing draft page ${doc.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading all draft pages: $e');
    }

    return result;
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Create default page if none exists
  /// 
  /// Creates a basic empty page with default settings
  Future<BuilderPage> createDefaultPage(
    String appId,
    BuilderPageId pageId, {
    bool isDraft = true,
  }) async {
    final page = BuilderPage(
      pageId: pageId,
      appId: appId,
      name: pageId.label,
      description: 'Page ${pageId.label} générée automatiquement',
      route: pageId == BuilderPageId.home ? '/home' : '/${pageId.value}',
      blocks: [],
      isDraft: isDraft,
    );

    if (isDraft) {
      await saveDraft(page);
    } else {
      await publishPage(page, userId: 'system');
    }

    return page;
  }

  /// Copy published to draft (create draft from published)
  /// 
  /// Useful for starting to edit a published page.
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  Future<BuilderPage?> copyPublishedToDraft(
    String appId,
    dynamic pageId,
  ) async {
    final published = await loadPublished(appId, pageId);
    if (published == null) return null;

    final draft = published.createDraft();
    await saveDraft(draft);
    
    return draft;
  }

  /// Get page status (draft exists? published exists?)
  /// 
  /// Accepts dynamic pageId (String or BuilderPageId enum).
  Future<PageStatus> getPageStatus(
    String appId,
    dynamic pageId,
  ) async {
    final hasDraftVersion = await hasDraft(appId, pageId);
    final hasPublishedVersion = await hasPublished(appId, pageId);

    return PageStatus(
      hasDraft: hasDraftVersion,
      hasPublished: hasPublishedVersion,
    );
  }

  /// Batch operation: Publish all drafts for an app
  /// 
  /// Returns a list of pageKey strings (for both system and custom pages).
  Future<List<String>> publishAllDrafts(
    String appId, {
    required String userId,
    bool deleteDrafts = false,
  }) async {
    final published = <String>[];

    // Load all drafts (including custom pages)
    final allDrafts = await loadAllDraftPages(appId);
    
    for (final entry in allDrafts.entries) {
      final draft = entry.value;
      await publishPage(draft, userId: userId, shouldDeleteDraft: deleteDrafts);
      published.add(entry.key);
    }

    return published;
  }

  // ==================== SYSTEM PAGES OPERATIONS ====================

  /// Load all system pages from published pages collection
  /// 
  /// **Fix for 'Zombie Pages' Bug:**
  /// Now queries loadAllPublishedPages instead of pages_system collection.
  /// This ensures real-time updates (like isActive: false) are reflected immediately.
  /// pages_published becomes the Single Source of Truth for navigation status.
  /// 
  /// System pages define the navigation structure:
  /// - home, cart, contact, about (order fixed)
  /// 
  /// Returns list of BuilderPage where isSystemPage == true, sorted by order
  Future<List<BuilderPage>> loadSystemPages(String appId) async {
    try {
      // Query from published pages - the source of truth
      final publishedPages = await loadAllPublishedPages(appId);
      
      // Filter to return only pages where isSystemPage == true
      final systemPages = publishedPages.values
          .where((page) => page.isSystemPage)
          .toList();
      
      // Sort by order
      systemPages.sort((a, b) => a.order.compareTo(b.order));
      
      return systemPages;
    } catch (e) {
      debugPrint('Error loading system pages: $e');
      return [];
    }
  }

  /// Load a specific system page by pageId
  /// 
  /// Path: restaurants/{restaurantId}/pages_system/{pageId}
  /// 
  /// @deprecated Use [loadPublished] instead. The pages_system collection is legacy
  /// and being phased out. All page data now lives in pages_published collection.
  /// This method is maintained for backward compatibility during transition.
  @Deprecated('Use loadPublished() instead. pages_system collection is legacy.')
  Future<BuilderPage?> loadSystemPage(String appId, BuilderPageId pageId) async {
    try {
      final docRef = FirestorePaths.systemPageDoc(pageId.value, appId);
      final snapshot = await docRef.get();
      
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      
      final data = snapshot.data()!;
      // Ensure pageKey is set from docId
      if (data['pageKey'] == null) {
        data['pageKey'] = pageId.value;
      }
      
      return BuilderPage.fromJson(data);
    } catch (e) {
      debugPrint('Error loading system page ${pageId.value}: $e');
      return null;
    }
  }

  /// Watch system pages for real-time updates
  /// 
  /// @deprecated Use pages_published collection instead. The pages_system collection is legacy
  /// and being phased out. Consider watching pages_published and filtering by isSystemPage.
  /// This method is maintained for backward compatibility during transition.
  @Deprecated('Use pages_published collection instead. pages_system is legacy.')
  Stream<List<BuilderPage>> watchSystemPages(String appId) {
    return FirestorePaths.pagesSystem(appId).snapshots().map((snapshot) {
      final pages = <BuilderPage>[];
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          
          // Ensure pageId and pageKey are set correctly from doc.id
          if (data['pageId'] == null) {
            data['pageId'] = doc.id;
          }
          if (data['pageKey'] == null) {
            data['pageKey'] = doc.id;
          }
          
          pages.add(BuilderPage.fromJson(data));
        } catch (e) {
          debugPrint('Error parsing system page ${doc.id}: $e');
        }
      }
      
      // Sort by order
      pages.sort((a, b) => a.order.compareTo(b.order));
      
      return pages;
    });
  }

  /// Helper to check if a page should appear in bottom navigation bar
  /// 
  /// NEW LOGIC (B3):
  /// - isActive == true
  /// - bottomNavIndex != null
  /// - bottomNavIndex >= 0 and <= 4
  /// - route is valid (not '/' or empty)
  /// 
  /// FALLBACK (backward compatibility):
  /// - isActive == true
  /// - displayLocation == "bottomBar"
  /// - order != null
  /// - order >= 0 and <= 4
  /// - route is valid (not '/' or empty)
  bool _isBottomBarPage(BuilderPage page) {
    // Safety check: filter out pages with invalid routes
    // Route must not be '/' (root) or empty, as these can cause navigation issues
    if (page.route.isEmpty || page.route == '/') {
      debugPrint('⚠️ Filtering out page ${page.pageKey} with invalid route: "${page.route}"');
      return false;
    }
    
    // Strict filter: page must be active to appear in bottom bar
    // This respects admin visibility choices (e.g. hiding Menu or Cart for maintenance)
    if (!page.isActive) {
      return false;
    }
    
    // Primary logic: Check bottomNavIndex (isActive already verified above)
    if (page.bottomNavIndex != null &&
        page.bottomNavIndex! >= 0 &&
        page.bottomNavIndex! <= 4) {
      return true;
    }

    // Fallback for backward compatibility with old schema (isActive already verified above)
    if (page.displayLocation == 'bottomBar' &&
        page.order >= 0 &&
        page.order <= 4) {
      return true;
    }

    return false;
  }
  
  /// Helper to sort pages by bottomNavIndex (with fallback to order field)
  void _sortByBottomNavIndex(List<BuilderPage> pages) {
    pages.sort((a, b) {
      final aIndex = a.bottomNavIndex ?? a.order ?? _maxBottomNavIndex;
      final bIndex = b.bottomNavIndex ?? b.order ?? _maxBottomNavIndex;
      return aIndex.compareTo(bIndex);
    });
  }

  /// Get pages for bottom navigation bar
  /// 
  /// Returns pages where isActive == true and bottomNavIndex is valid (>= 0 and <= 4)
  /// Sorted by bottomNavIndex ASC
  /// 
  /// This is the NEW B3 logic that uses:
  /// 1. loadAllPublishedPages as the source of truth
  /// 2. _isBottomBarPage filter (strictly checks isActive == true and bottomNavIndex 0-4)
  /// 3. _sortByBottomNavIndex for ordering
  /// 
  /// Fix for 'Zombie Pages': Uses published pages as source of truth instead of
  /// the stale pages_system collection, ensuring the admin 'Active' toggle works immediately.
  Future<List<BuilderPage>> getBottomBarPages({required String appId}) async {
    try {
      // Load from published pages - the source of truth
      // This ensures admin changes (like isActive=false) are reflected immediately
      final publishedPages = await loadAllPublishedPages(appId);
      
      // Filter using _isBottomBarPage which strictly checks isActive == true
      final bottomBarPages = publishedPages.values
          .where(_isBottomBarPage)
          .toList();
      
      // Sort by bottomNavIndex
      _sortByBottomNavIndex(bottomBarPages);
      
      return bottomBarPages;
    } catch (e) {
      debugPrint('Error loading bottom bar pages: $e');
      return [];
    }
  }
}

/// Page status information
class PageStatus {
  final bool hasDraft;
  final bool hasPublished;

  const PageStatus({
    required this.hasDraft,
    required this.hasPublished,
  });

  bool get exists => hasDraft || hasPublished;
  bool get isClean => !hasDraft && hasPublished;
  bool get hasUnpublishedChanges => hasDraft;
  bool get isNew => !hasDraft && !hasPublished;

  @override
  String toString() {
    if (isNew) return 'PageStatus(new)';
    if (isClean) return 'PageStatus(published)';
    if (hasDraft && !hasPublished) return 'PageStatus(draft only)';
    return 'PageStatus(draft + published)';
  }
}
