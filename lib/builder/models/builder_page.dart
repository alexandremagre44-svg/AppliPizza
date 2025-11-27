// lib/builder/models/builder_page.dart
// Page model for Builder B3 system

import 'package:flutter/material.dart';
import 'builder_enums.dart';
import 'builder_block.dart';
import 'system_pages.dart';
import '../utils/firestore_parsing_helpers.dart';

/// Default restaurant ID for backwards compatibility when parsing pages
const String _defaultAppId = 'delizza';

/// Page model for multi-page builder system
/// 
/// Represents a complete page configuration with all its blocks.
/// Supports:
/// - Multi-page: Different pages (home, menu, promo, custom, etc.)
/// - Multi-resto: Different configurations per restaurant (appId)
/// - Draft/Published: Separate draft and published layouts per page
/// - Version control: Track changes over time
/// - Modules: Attach modules (menu, cart, profile, roulette) to pages
/// - Custom pages: Unlimited custom pages with any pageKey
class BuilderPage {
  /// Primary page identifier as string (source of truth)
  /// 
  /// This is the Firestore document ID or the explicit pageId field.
  /// For system pages, this matches BuilderPageId.value (e.g., 'home', 'menu').
  /// For custom pages, this can be any string (e.g., 'promo_noel', 'special_offer').
  final String pageKey;
  
  /// System page identifier (nullable)
  /// 
  /// Only set if [pageKey] matches a known system page (BuilderPageId).
  /// Use this to access system page configurations from SystemPages.
  /// For custom pages, this is null.
  final BuilderPageId? systemId;

  /// Unique page identifier (home, menu, promo, etc.)
  /// 
  /// This is nullable for custom pages that don't have a matching Enum value.
  /// For system pages, this will match [systemId].
  /// For custom pages, this will be null.
  /// 
  /// @deprecated Use [pageKey] for the string identifier and [systemId] for system pages.
  final BuilderPageId? pageId;

  /// Restaurant/app identifier for multi-resto support
  /// Example: 'delizza', 'pizza_express', etc.
  final String appId;

  /// Display name for this page
  final String name;

  /// Page description (for admin reference)
  final String description;

  /// Route path for this page
  /// Example: '/home', '/menu', '/promo'
  final String route;

  /// List of blocks on this page, ordered by block.order
  /// 
  /// @deprecated This field is maintained for backward compatibility.
  /// Use [draftLayout] for editor changes and [publishedLayout] for runtime.
  /// Will be removed in a future version. Migration:
  /// - Editor: Read/write [draftLayout] instead of [blocks]
  /// - Runtime: Read [publishedLayout] instead of [blocks]
  final List<BuilderBlock> blocks;

  /// Whether this page is currently enabled/published
  final bool isEnabled;

  /// Whether this is a draft version (not published yet)
  final bool isDraft;

  /// SEO metadata
  final PageMetadata? metadata;

  /// Version number for tracking changes
  final int version;

  /// Timestamp when page was created
  final DateTime createdAt;

  /// Timestamp when page was last updated
  final DateTime updatedAt;

  /// Timestamp when page was published (null if never published)
  final DateTime? publishedAt;

  /// User ID who last modified this page
  final String? lastModifiedBy;

  /// Display location for this page in navigation
  /// Values: 'bottomBar', 'hidden', 'internal'
  /// - 'bottomBar': appears in bottom navigation bar
  /// - 'hidden': accessible only via actions, not visible in nav
  /// - 'internal': internal pages (cart, profile, checkout, login)
  final String displayLocation;

  /// Icon name for bottom navigation bar (Material Icon name)
  /// Example: 'home', 'menu', 'shopping_cart'
  final String icon;

  /// Order in bottom navigation bar (lower = appears first)
  final int order;
  
  /// Whether this is a system page (profile, cart, rewards, roulette)
  /// System pages cannot be deleted or have their pageId changed
  final bool isSystemPage;

  // ==================== NEW FIELDS FOR ENHANCED DRAFT/PUBLISH ====================

  /// Type of page (template, blank, system, custom)
  final BuilderPageType pageType;

  /// Whether the page is active (visible in navigation/app)
  /// Different from isEnabled which controls if page is published
  final bool isActive;

  /// Index for bottom navigation bar ordering
  /// More explicit than 'order' field for bottomNav specifically
  final int bottomNavIndex;

  /// List of module IDs attached to this page
  /// Modules: menu_catalog, cart_module, profile_module, roulette_module
  final List<String> modules;

  /// Whether there are unpublished changes in draftLayout
  /// Computed from comparing draftLayout to publishedLayout
  final bool hasUnpublishedChanges;

  /// Draft layout blocks (modified in real-time in the editor)
  /// This is the working copy that admins edit
  final List<BuilderBlock> draftLayout;

  /// Published layout blocks (visible to clients)
  /// This is the live version shown to end users
  final List<BuilderBlock> publishedLayout;

  BuilderPage({
    String? pageKey,
    this.systemId,
    BuilderPageId? pageId,
    required this.appId,
    required this.name,
    this.description = '',
    required this.route,
    this.blocks = const [],
    this.isEnabled = true,
    this.isDraft = false,
    this.metadata,
    this.version = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.publishedAt,
    this.lastModifiedBy,
    this.displayLocation = 'hidden',
    this.icon = 'help_outline',
    this.order = 999,
    bool? isSystemPage,
    // New fields
    BuilderPageType? pageType,
    this.isActive = true,
    this.bottomNavIndex = 999,
    this.modules = const [],
    bool? hasUnpublishedChanges,
    List<BuilderBlock>? draftLayout,
    List<BuilderBlock>? publishedLayout,
  })  : // Compute pageKey: explicit parameter > systemId > pageId > 'custom'
        pageKey = pageKey ?? systemId?.value ?? pageId?.value ?? 'custom',
        // Compute pageId: systemId > explicit pageId > derived from pageKey (nullable for custom pages)
        // Note: Does NOT default to home anymore - custom pages will have null pageId
        pageId = systemId ?? pageId ?? BuilderPageId.tryFromString(pageKey ?? ''),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        isSystemPage = isSystemPage ?? (systemId != null ? systemId.isSystemPage : (pageId?.isSystemPage ?? false)),
        pageType = pageType ?? ((systemId != null || (pageId?.isSystemPage ?? false)) ? BuilderPageType.system : BuilderPageType.custom),
        draftLayout = draftLayout ?? blocks,
        publishedLayout = publishedLayout ?? const [],
        hasUnpublishedChanges = hasUnpublishedChanges ?? (draftLayout != null && draftLayout.isNotEmpty && (publishedLayout == null || publishedLayout.isEmpty));

  /// Create a copy with modified fields
  BuilderPage copyWith({
    String? pageKey,
    BuilderPageId? systemId,
    BuilderPageId? pageId,
    String? appId,
    String? name,
    String? description,
    String? route,
    List<BuilderBlock>? blocks,
    bool? isEnabled,
    bool? isDraft,
    PageMetadata? metadata,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    String? lastModifiedBy,
    String? displayLocation,
    String? icon,
    int? order,
    bool? isSystemPage,
    // New fields
    BuilderPageType? pageType,
    bool? isActive,
    int? bottomNavIndex,
    List<String>? modules,
    bool? hasUnpublishedChanges,
    List<BuilderBlock>? draftLayout,
    List<BuilderBlock>? publishedLayout,
  }) {
    return BuilderPage(
      pageKey: pageKey ?? this.pageKey,
      systemId: systemId ?? this.systemId,
      pageId: pageId ?? this.pageId,
      appId: appId ?? this.appId,
      name: name ?? this.name,
      description: description ?? this.description,
      route: route ?? this.route,
      blocks: blocks ?? List<BuilderBlock>.from(this.blocks),
      isEnabled: isEnabled ?? this.isEnabled,
      isDraft: isDraft ?? this.isDraft,
      metadata: metadata ?? this.metadata,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      displayLocation: displayLocation ?? this.displayLocation,
      icon: icon ?? this.icon,
      order: order ?? this.order,
      isSystemPage: isSystemPage ?? this.isSystemPage,
      // New fields
      pageType: pageType ?? this.pageType,
      isActive: isActive ?? this.isActive,
      bottomNavIndex: bottomNavIndex ?? this.bottomNavIndex,
      modules: modules ?? List<String>.from(this.modules),
      hasUnpublishedChanges: hasUnpublishedChanges ?? this.hasUnpublishedChanges,
      draftLayout: draftLayout ?? List<BuilderBlock>.from(this.draftLayout),
      publishedLayout: publishedLayout ?? List<BuilderBlock>.from(this.publishedLayout),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'pageKey': pageKey,
      'pageId': pageId?.toJson() ?? pageKey, // Use pageKey as fallback for custom pages
      'appId': appId,
      'name': name,
      'description': description,
      'route': route,
      'blocks': blocks.map((b) => b.toJson()).toList(),
      'isEnabled': isEnabled,
      'isDraft': isDraft,
      'metadata': metadata?.toJson(),
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'lastModifiedBy': lastModifiedBy,
      'displayLocation': displayLocation,
      'icon': icon,
      'order': order,
      'isSystemPage': isSystemPage,
      // New fields
      'pageType': pageType.toJson(),
      'isActive': isActive,
      'bottomNavIndex': bottomNavIndex,
      'modules': modules,
      'hasUnpublishedChanges': hasUnpublishedChanges,
      'draftLayout': draftLayout.map((b) => b.toJson()).toList(),
      'publishedLayout': publishedLayout.map((b) => b.toJson()).toList(),
    };
  }

  /// Helper to safely parse layout field from Firestore
  /// 
  /// TODO(builder-b3-safe-parsing) Handles:
  /// - Null values → empty list
  /// - Legacy string values like "none" → empty list
  /// - List of blocks → parses each individually, skipping malformed ones
  /// - Individual block parsing errors → logs warning and skips block
  static List<BuilderBlock> _safeLayoutParse(dynamic value) {
    // If null, return empty list
    if (value == null) return [];
    
    // If already a List, parse each block individually
    if (value is List<dynamic>) {
      final validBlocks = <BuilderBlock>[];
      
      for (int i = 0; i < value.length; i++) {
        try {
          final item = value[i];
          
          // Skip null items
          if (item == null) {
            print('⚠️ Warning: Skipping null block at index $i');
            continue;
          }
          
          // Verify item is a Map
          if (item is! Map<String, dynamic>) {
            // Try to cast if it's a Map with different type params
            if (item is Map) {
              final blockData = Map<String, dynamic>.from(item);
              validBlocks.add(BuilderBlock.fromJson(blockData));
            } else {
              print('⚠️ Warning: Skipping block at index $i - expected Map, got ${item.runtimeType}');
            }
            continue;
          }
          
          // Parse the block
          validBlocks.add(BuilderBlock.fromJson(item));
        } catch (e) {
          // TODO(builder-b3-safe-parsing) Skip malformed blocks with warning, don't crash
          print('⚠️ Warning: Skipping malformed block at index $i. Error: $e');
          continue;
        }
      }
      
      return validBlocks;
    }
    
    // For any other type (String like "none", etc.), return empty list
    // This handles legacy data where draftLayout/publishedLayout might be stored as strings
    if (value is String) {
      print('⚠️ Legacy string value found in layout field: "$value". Returning empty list.');
    } else {
      print('⚠️ Warning: Unexpected layout field type: ${value.runtimeType}. Returning empty list.');
    }
    return [];
  }

  /// Create from Firestore JSON
  factory BuilderPage.fromJson(Map<String, dynamic> json) {
    // Extract pageKey (source of truth) - prefer explicit pageKey, then pageId, then doc id
    final rawPageId = json['pageId'] as String? ?? json['pageKey'] as String? ?? 'home';
    final pageKey = json['pageKey'] as String? ?? rawPageId;
    
    // Try to get system page ID (nullable for custom pages)
    final systemId = BuilderPageId.tryFromString(rawPageId);
    
    // pageId is now nullable - don't default to home for custom pages
    // systemId is the same as pageId for system pages, null for custom pages
    final BuilderPageId? pageId = systemId;
    
    // Get system page config for proper defaults (only if this is a system page)
    final systemConfig = systemId != null ? SystemPages.getConfig(systemId) : null;
    
    // Parse blocks (legacy field)
    final blocks = _safeLayoutParse(json['blocks']);
    
    // Parse draftLayout (new field, fallback to blocks for backward compatibility)
    final draftLayoutRaw = json['draftLayout'];
    final draftLayout = draftLayoutRaw != null 
        ? _safeLayoutParse(draftLayoutRaw)
        : blocks;
    
    // Parse publishedLayout (new field)
    final publishedLayout = _safeLayoutParse(json['publishedLayout']);
    
    // TODO(builder-b3-safe-parsing) Parse modules list safely - skip non-string items
    final List<String> modules = [];
    final rawModules = json['modules'];
    if (rawModules is List<dynamic>) {
      for (final m in rawModules) {
        if (m is String) {
          modules.add(m);
        } else if (m != null) {
          print('⚠️ Warning: Skipping non-string module value: $m (${m.runtimeType})');
        }
      }
    }
    
    // Use proper defaults from SystemPages registry when available (only for system pages)
    final defaultName = systemConfig?.defaultName ?? 'Page';
    final defaultIcon = _getIconName(systemConfig?.defaultIcon) ?? 'help_outline';
    
    // Route logic: use explicit route, or system route, or generate custom page route
    String defaultRoute;
    if (systemConfig != null) {
      defaultRoute = systemConfig.route;
    } else {
      // Custom page: use /page/<pageKey> route
      defaultRoute = '/page/$pageKey';
    }
    
    // P2 fix: fallback title -> name if name is missing (Firestore may use 'title' field)
    final pageName = json['name'] as String? ?? json['title'] as String? ?? defaultName;
    
    // Determine route: prefer explicit, fallback to default
    final rawRoute = json['route'] as String?;
    final route = (rawRoute != null && rawRoute.isNotEmpty && rawRoute != '/') 
        ? rawRoute 
        : defaultRoute;
    
    return BuilderPage(
      pageKey: pageKey,
      systemId: systemId,
      pageId: pageId,
      appId: json['appId'] as String? ?? _defaultAppId,
      name: pageName,
      description: json['description'] as String? ?? '',
      route: route,
      blocks: blocks,
      isEnabled: json['isEnabled'] as bool? ?? true,
      isDraft: json['isDraft'] as bool? ?? false,
      metadata: json['metadata'] != null
          ? PageMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      version: json['version'] as int? ?? 1,
      // TODO(builder-b3-safe-parsing) Use safe DateTime parsing for Firestore Timestamp/String/null
      createdAt: safeParseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: safeParseDateTime(json['updatedAt']) ?? DateTime.now(),
      publishedAt: safeParseDateTime(json['publishedAt']),
      lastModifiedBy: json['lastModifiedBy'] as String?,
      displayLocation: json['displayLocation'] as String? ?? 'hidden',
      icon: json['icon'] as String? ?? defaultIcon,
      order: json['order'] as int? ?? 999,
      isSystemPage: json['isSystemPage'] as bool? ?? (systemId?.isSystemPage ?? false),
      // New fields
      pageType: BuilderPageType.fromJson(json['pageType'] as String? ?? (systemId != null ? 'system' : 'custom')),
      isActive: json['isActive'] as bool? ?? true,
      bottomNavIndex: json['bottomNavIndex'] as int? ?? (json['order'] as int? ?? 999),
      modules: modules,
      hasUnpublishedChanges: json['hasUnpublishedChanges'] as bool? ?? false,
      draftLayout: draftLayout,
      publishedLayout: publishedLayout,
    );
  }
  
  /// Helper to convert IconData to icon name string
  static String? _getIconName(IconData? iconData) {
    if (iconData == null) return null;
    
    // Map of IconData to string names for system pages
    const iconMap = {
      58332: 'home',            // Icons.home.codePoint
      58732: 'restaurant_menu', // Icons.restaurant_menu.codePoint
      59688: 'shopping_cart',   // Icons.shopping_cart.codePoint
      59603: 'person',          // Icons.person.codePoint
      57445: 'card_giftcard',   // Icons.card_giftcard.codePoint
      57372: 'casino',          // Icons.casino.codePoint
    };
    
    return iconMap[iconData.codePoint];
  }

  /// Get blocks sorted by order
  /// Uses draftLayout for editor, publishedLayout for runtime
  List<BuilderBlock> get sortedBlocks {
    final sorted = List<BuilderBlock>.from(blocks);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  /// Get draft blocks sorted by order (for editor)
  List<BuilderBlock> get sortedDraftBlocks {
    final sorted = List<BuilderBlock>.from(draftLayout);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  /// Get published blocks sorted by order (for runtime)
  List<BuilderBlock> get sortedPublishedBlocks {
    final sorted = List<BuilderBlock>.from(publishedLayout);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  /// Get only active/visible blocks
  List<BuilderBlock> get activeBlocks {
    return sortedBlocks.where((b) => b.isActive).toList();
  }

  /// Get only active/visible draft blocks (for editor)
  List<BuilderBlock> get activeDraftBlocks {
    return sortedDraftBlocks.where((b) => b.isActive).toList();
  }

  /// Get only active/visible published blocks (for runtime)
  List<BuilderBlock> get activePublishedBlocks {
    return sortedPublishedBlocks.where((b) => b.isActive).toList();
  }

  /// Add a block to this page (draft layout)
  BuilderPage addBlock(BuilderBlock block) {
    final newBlocks = List<BuilderBlock>.from(blocks);
    newBlocks.add(block);
    final newDraftLayout = List<BuilderBlock>.from(draftLayout);
    newDraftLayout.add(block);
    return copyWith(
      blocks: newBlocks,
      draftLayout: newDraftLayout,
      hasUnpublishedChanges: true,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Add a block to draft layout only
  BuilderPage addBlockToDraft(BuilderBlock block) {
    final newDraftLayout = List<BuilderBlock>.from(draftLayout);
    newDraftLayout.add(block);
    return copyWith(
      draftLayout: newDraftLayout,
      hasUnpublishedChanges: true,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Remove a block from this page (draft layout)
  BuilderPage removeBlock(String blockId) {
    final newBlocks = blocks.where((b) => b.id != blockId).toList();
    final newDraftLayout = draftLayout.where((b) => b.id != blockId).toList();
    return copyWith(
      blocks: newBlocks,
      draftLayout: newDraftLayout,
      hasUnpublishedChanges: true,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Remove a block from draft layout only
  BuilderPage removeBlockFromDraft(String blockId) {
    final newDraftLayout = draftLayout.where((b) => b.id != blockId).toList();
    return copyWith(
      draftLayout: newDraftLayout,
      hasUnpublishedChanges: true,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Update a block on this page (draft layout)
  BuilderPage updateBlock(BuilderBlock updatedBlock) {
    final newBlocks = blocks.map((b) {
      return b.id == updatedBlock.id ? updatedBlock : b;
    }).toList();
    final newDraftLayout = draftLayout.map((b) {
      return b.id == updatedBlock.id ? updatedBlock : b;
    }).toList();
    return copyWith(
      blocks: newBlocks,
      draftLayout: newDraftLayout,
      hasUnpublishedChanges: true,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Update a block in draft layout only
  BuilderPage updateBlockInDraft(BuilderBlock updatedBlock) {
    final newDraftLayout = draftLayout.map((b) {
      return b.id == updatedBlock.id ? updatedBlock : b;
    }).toList();
    return copyWith(
      draftLayout: newDraftLayout,
      hasUnpublishedChanges: true,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Reorder blocks (draft layout)
  BuilderPage reorderBlocks(List<String> blockIds) {
    final newBlocks = <BuilderBlock>[];
    for (var i = 0; i < blockIds.length; i++) {
      final blockId = blockIds[i];
      final matchingBlocks = blocks.where((b) => b.id == blockId);
      if (matchingBlocks.isNotEmpty) {
        newBlocks.add(matchingBlocks.first.copyWith(order: i));
      }
    }
    final newDraftLayout = <BuilderBlock>[];
    for (var i = 0; i < blockIds.length; i++) {
      final blockId = blockIds[i];
      final matchingBlocks = draftLayout.where((b) => b.id == blockId);
      if (matchingBlocks.isNotEmpty) {
        newDraftLayout.add(matchingBlocks.first.copyWith(order: i));
      }
    }
    return copyWith(
      blocks: newBlocks.isEmpty ? null : newBlocks,
      draftLayout: newDraftLayout.isEmpty ? null : newDraftLayout,
      hasUnpublishedChanges: true,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Reorder blocks in draft layout only
  BuilderPage reorderDraftBlocks(List<String> blockIds) {
    final newDraftLayout = <BuilderBlock>[];
    for (var i = 0; i < blockIds.length; i++) {
      final blockId = blockIds[i];
      final matchingBlocks = draftLayout.where((b) => b.id == blockId);
      if (matchingBlocks.isNotEmpty) {
        newDraftLayout.add(matchingBlocks.first.copyWith(order: i));
      }
    }
    return copyWith(
      draftLayout: newDraftLayout,
      hasUnpublishedChanges: true,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Create a published version from draft
  /// Copies draftLayout to publishedLayout
  BuilderPage publish({required String userId}) {
    return copyWith(
      isDraft: false,
      publishedAt: DateTime.now(),
      lastModifiedBy: userId,
      updatedAt: DateTime.now(),
      // Copy draft layout to published layout
      publishedLayout: List<BuilderBlock>.from(draftLayout),
      hasUnpublishedChanges: false,
    );
  }

  /// Create a draft version
  BuilderPage createDraft() {
    return copyWith(
      isDraft: true,
      publishedAt: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Update the draft layout with new blocks
  BuilderPage updateDraftLayout(List<BuilderBlock> layout) {
    return copyWith(
      draftLayout: layout,
      hasUnpublishedChanges: true,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Discard draft changes and revert to published layout
  BuilderPage discardDraftChanges() {
    return copyWith(
      draftLayout: List<BuilderBlock>.from(publishedLayout),
      hasUnpublishedChanges: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Add a module to this page
  BuilderPage addModule(String moduleId) {
    if (modules.contains(moduleId)) return this;
    final newModules = List<String>.from(modules);
    newModules.add(moduleId);
    return copyWith(
      modules: newModules,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Remove a module from this page
  BuilderPage removeModule(String moduleId) {
    if (!modules.contains(moduleId)) return this;
    final newModules = modules.where((m) => m != moduleId).toList();
    return copyWith(
      modules: newModules,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Check if this page has a specific module
  bool hasModule(String moduleId) => modules.contains(moduleId);
  
  /// Check if this is a custom page (not a system page)
  bool get isCustomPage => systemId == null;

  @override
  String toString() {
    return 'BuilderPage(pageKey: $pageKey, systemId: ${systemId?.value ?? 'null'}, appId: $appId, blocks: ${blocks.length}, draft: $isDraft, draftBlocks: ${draftLayout.length}, publishedBlocks: ${publishedLayout.length}, hasUnpublished: $hasUnpublishedChanges)';
  }
}

/// SEO and page metadata
class PageMetadata {
  final String? title;
  final String? description;
  final String? keywords;
  final String? ogImage;
  final String? ogTitle;
  final String? ogDescription;

  const PageMetadata({
    this.title,
    this.description,
    this.keywords,
    this.ogImage,
    this.ogTitle,
    this.ogDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'keywords': keywords,
      'ogImage': ogImage,
      'ogTitle': ogTitle,
      'ogDescription': ogDescription,
    };
  }

  factory PageMetadata.fromJson(Map<String, dynamic> json) {
    return PageMetadata(
      title: json['title'] as String?,
      description: json['description'] as String?,
      keywords: json['keywords'] as String?,
      ogImage: json['ogImage'] as String?,
      ogTitle: json['ogTitle'] as String?,
      ogDescription: json['ogDescription'] as String?,
    );
  }

  PageMetadata copyWith({
    String? title,
    String? description,
    String? keywords,
    String? ogImage,
    String? ogTitle,
    String? ogDescription,
  }) {
    return PageMetadata(
      title: title ?? this.title,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      ogImage: ogImage ?? this.ogImage,
      ogTitle: ogTitle ?? this.ogTitle,
      ogDescription: ogDescription ?? this.ogDescription,
    );
  }
}
