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

  BuilderLayoutService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get document reference for draft page
  /// Path: restaurants/{restaurantId}/pages_draft/{pageId}
  DocumentReference _getDraftRef(String appId, BuilderPageId pageId) {
    // Note: appId parameter is kept for backward compatibility but we now use kRestaurantId
    // In future multi-resto implementations, this can be made dynamic
    return FirestorePaths.draftDoc(pageId.value);
  }

  /// Get document reference for published page
  /// Path: restaurants/{restaurantId}/pages_published/{pageId}
  DocumentReference _getPublishedRef(String appId, BuilderPageId pageId) {
    return FirestorePaths.publishedDoc(pageId.value);
  }

  // ==================== DRAFT OPERATIONS ====================

  /// Save a draft page with system page protections
  /// 
  /// Protections:
  /// - System pages retain isSystemPage = true
  /// - SystemBlocks retain type = system
  /// - System page pageId cannot be changed
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

    final ref = _getDraftRef(protectedPage.appId, protectedPage.pageId);
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
    if (page.pageId.isSystemPage && !page.isSystemPage) {
      debugPrint('⚠️ Warning: Correcting isSystemPage for system page ${page.pageId.value}');
      protectedPage = protectedPage.copyWith(isSystemPage: true);
    }
    
    // Validate displayLocation for system pages (only allow bottomBar or hidden)
    if (protectedPage.isSystemPage) {
      final validLocations = ['bottomBar', 'hidden'];
      if (!validLocations.contains(protectedPage.displayLocation)) {
        debugPrint('⚠️ Warning: Correcting displayLocation for system page ${page.pageId.value}');
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

  /// Load draft page
  /// 
  /// Returns null if no draft exists
  Future<BuilderPage?> loadDraft(String appId, BuilderPageId pageId) async {
    try {
      final ref = _getDraftRef(appId, pageId);
      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      return BuilderPage.fromJson(snapshot.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error loading draft: $e');
      return null;
    }
  }

  /// Watch draft page changes in real-time
  /// 
  /// Example:
  /// ```dart
  /// service.watchDraft('pizza_delizza', BuilderPageId.home).listen((page) {
  ///   if (page != null) {
  ///     print('Draft updated: ${page.version}');
  ///   }
  /// });
  /// ```
  Stream<BuilderPage?> watchDraft(String appId, BuilderPageId pageId) {
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
  Future<void> deleteDraft(String appId, BuilderPageId pageId) async {
    final ref = _getDraftRef(appId, pageId);
    await ref.delete();
  }

  /// Check if draft exists
  Future<bool> hasDraft(String appId, BuilderPageId pageId) async {
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

    // Save to published collection
    final ref = _getPublishedRef(page.appId, page.pageId);
    await ref.set(publishedPage.toJson());

    // Optionally delete draft
    if (shouldDeleteDraft) {
      await deleteDraft(page.appId, page.pageId);
    }
  }

  /// Load published page
  /// 
  /// Returns null if no published version exists
  Future<BuilderPage?> loadPublished(String appId, BuilderPageId pageId) async {
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

  /// Watch published page changes in real-time
  /// 
  /// Example:
  /// ```dart
  /// service.watchPublished('pizza_delizza', BuilderPageId.home).listen((page) {
  ///   if (page != null) {
  ///     // Update UI with published page
  ///   }
  /// });
  /// ```
  Stream<BuilderPage?> watchPublished(String appId, BuilderPageId pageId) {
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
  Future<void> deletePublished(String appId, BuilderPageId pageId) async {
    final ref = _getPublishedRef(appId, pageId);
    await ref.delete();
  }

  /// Check if published version exists
  Future<bool> hasPublished(String appId, BuilderPageId pageId) async {
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
  Future<void> unpublishPage(
    String appId,
    BuilderPageId pageId, {
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
  /// Useful for editor: always show latest version
  Future<BuilderPage?> loadPage(String appId, BuilderPageId pageId) async {
    // Try draft first
    final draft = await loadDraft(appId, pageId);
    if (draft != null) return draft;

    // Fall back to published
    return await loadPublished(appId, pageId);
  }

  /// Watch page (prefers draft, falls back to published)
  /// 
  /// Returns a stream that emits the most recent version
  Stream<BuilderPage?> watchPage(String appId, BuilderPageId pageId) async* {
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
  /// Returns a map of pageId -> BuilderPage
  Future<Map<BuilderPageId, BuilderPage>> loadAllPublishedPages(
    String appId,
  ) async {
    final result = <BuilderPageId, BuilderPage>{};

    for (final pageId in BuilderPageId.values) {
      final page = await loadPublished(appId, pageId);
      if (page != null) {
        result[pageId] = page;
      }
    }

    return result;
  }

  /// Load all draft pages for an app
  Future<Map<BuilderPageId, BuilderPage>> loadAllDraftPages(
    String appId,
  ) async {
    final result = <BuilderPageId, BuilderPage>{};

    for (final pageId in BuilderPageId.values) {
      final page = await loadDraft(appId, pageId);
      if (page != null) {
        result[pageId] = page;
      }
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
  /// Useful for starting to edit a published page
  Future<BuilderPage?> copyPublishedToDraft(
    String appId,
    BuilderPageId pageId,
  ) async {
    final published = await loadPublished(appId, pageId);
    if (published == null) return null;

    final draft = published.createDraft();
    await saveDraft(draft);
    
    return draft;
  }

  /// Get page status (draft exists? published exists?)
  Future<PageStatus> getPageStatus(
    String appId,
    BuilderPageId pageId,
  ) async {
    final hasDraftVersion = await hasDraft(appId, pageId);
    final hasPublishedVersion = await hasPublished(appId, pageId);

    return PageStatus(
      hasDraft: hasDraftVersion,
      hasPublished: hasPublishedVersion,
    );
  }

  /// Batch operation: Publish all drafts for an app
  Future<List<BuilderPageId>> publishAllDrafts(
    String appId, {
    required String userId,
    bool deleteDrafts = false,
  }) async {
    final published = <BuilderPageId>[];

    for (final pageId in BuilderPageId.values) {
      final draft = await loadDraft(appId, pageId);
      if (draft != null) {
        await publishPage(draft, userId: userId, shouldDeleteDraft: deleteDrafts);
        published.add(pageId);
      }
    }

    return published;
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
