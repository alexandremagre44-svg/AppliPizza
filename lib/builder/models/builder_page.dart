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
  /// ⚠️ LEGACY FIELD - DO NOT USE FOR NEW CODE ⚠️
  /// 
  /// @deprecated This field is maintained ONLY for backward compatibility during migration.
  /// 
  /// RUNTIME FIX (November 2024):
  /// - The runtime now uses ONLY [publishedLayout] as the source of truth
  /// - The editor now uses ONLY [draftLayout] for editing
  /// - This [blocks] field is kept ONLY to avoid data loss during migration
  /// - New code should NEVER read or write to this field
  /// 
  /// Migration path:
  /// - Editor: Read/write [draftLayout] instead of [blocks]
  /// - Runtime: Read [publishedLayout] instead of [blocks]
  /// - Firestore: Data is automatically migrated on load via fromJson() fallback chain
  /// 
  /// Will be removed in a future version once all data is migrated.
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
  /// 
  /// FIX F2: Explicitly stores systemId field for proper round-trip
  Map<String, dynamic> toJson() {
    return {
      'pageKey': pageKey,
      'pageId': pageId?.toJson() ?? pageKey, // Use pageKey as fallback for custom pages
      'systemId': systemId?.toJson(), // FIX F2: Explicitly store systemId (null for custom pages)
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
  /// FIX B3-LAYOUT-PARSE: Enhanced to support multiple Firestore formats:
  /// - Null values → empty list
  /// - List<dynamic> → parse each block individually
  /// - Map with numeric keys ("0", "1", "2") → reconstruct as list (Firestore array format)
  /// - Map with non-numeric keys → ignore (not a layout)
  /// - Legacy string values like "none" → empty list
  /// 
  /// Never returns silently - always logs issues.
  /// Never swallows errors in try/catch - logs full stack trace.
  static List<BuilderBlock> _safeLayoutParse(dynamic value) {
    // If null, return empty list (this is expected for new pages)
    if (value == null) {
      debugPrint('ℹ️ [_safeLayoutParse] value is null, returning empty list');
      return [];
    }
    
    // FIX B3-LAYOUT-PARSE: Support Map with numeric keys (Firestore array format)
    // Firestore sometimes stores arrays as {0: {...}, 1: {...}, 2: {...}}
    if (value is Map) {
      final mapKeys = value.keys.toList();
      
      // Check if all keys are numeric strings (Firestore array format)
      // First filter for String keys, then check if they're numeric
      final stringKeys = mapKeys.whereType<String>().toList();
      final numericKeys = stringKeys.where((k) => int.tryParse(k) != null).toList();
      
      if (numericKeys.isNotEmpty && numericKeys.length == mapKeys.length) {
        // All keys are numeric strings - this is a Firestore array stored as Map
        debugPrint('📋 [_safeLayoutParse] Detected Map with ${numericKeys.length} numeric keys, converting to List');
        
        // Sort keys numerically and reconstruct as list
        numericKeys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
        
        final List<dynamic> reconstructedList = [];
        for (final key in numericKeys) {
          reconstructedList.add(value[key]);
        }
        
        // Recursively call with the reconstructed list
        return _safeLayoutParse(reconstructedList);
      } else if (mapKeys.isNotEmpty) {
        // Map with non-numeric keys - not a layout, log and return empty
        debugPrint('❌ [_safeLayoutParse] Map has non-numeric keys (${mapKeys.take(3).join(", ")}...), not a valid layout format');
        return [];
      } else {
        // Empty map
        debugPrint('ℹ️ [_safeLayoutParse] Empty Map, returning empty list');
        return [];
      }
    }
    
    // If already a List, parse each block individually
    if (value is List<dynamic>) {
      final validBlocks = <BuilderBlock>[];
      
      debugPrint('📋 [_safeLayoutParse] Parsing List with ${value.length} items');
      
      for (int i = 0; i < value.length; i++) {
        try {
          final item = value[i];
          
          // Skip null items
          if (item == null) {
            debugPrint('⚠️ [_safeLayoutParse] Skipping null block at index $i');
            continue;
          }
          
          // Verify item is a Map
          if (item is! Map<String, dynamic>) {
            // Try to cast if it's a Map with different type params
            if (item is Map) {
              try {
                final blockData = Map<String, dynamic>.from(item);
                validBlocks.add(BuilderBlock.fromJson(blockData));
              } catch (parseError, stack) {
                debugPrint('❌ [_safeLayoutParse] Block parse FAILED at index $i after cast: $parseError');
                debugPrint('$stack');
              }
            } else {
              debugPrint('⚠️ [_safeLayoutParse] Skipping block at index $i - expected Map, got ${item.runtimeType}');
            }
            continue;
          }
          
          // Parse the block
          validBlocks.add(BuilderBlock.fromJson(item));
        } catch (e, stack) {
          // Catch ALL exceptions during block parsing - skip bad block, keep others
          // FIX: Never swallow errors silently - always log full stack trace
          debugPrint('❌ [_safeLayoutParse] Block parse FAILED at index $i: $e');
          debugPrint('$stack');
          continue;
        }
      }
      
      debugPrint('✅ [_safeLayoutParse] Successfully parsed ${validBlocks.length}/${value.length} blocks');
      return validBlocks;
    }
    
    // For any other type (String like "none", etc.), return empty list
    // This handles legacy data where draftLayout/publishedLayout might be stored as strings
    if (value is String) {
      debugPrint('⚠️ [_safeLayoutParse] Legacy string value found: "$value". Returning empty list.');
    } else {
      debugPrint('❌ [_safeLayoutParse] Unsupported format: ${value.runtimeType}. Returning empty list.');
    }
    return [];
  }

  /// Create from Firestore JSON
  /// 
  /// FIX F2: systemId is NEVER inferred from pageKey
  /// Only use explicit systemId field from Firestore. If missing, treat as custom page.
  factory BuilderPage.fromJson(Map<String, dynamic> json) {
    // FIX F2: Extract pageKey (source of truth) - prefer explicit pageKey, then generate fallback
    final rawPageKey = json['pageKey'] as String? ?? json['pageId'] as String?;
    final pageKey = rawPageKey ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    
    // FIX F2: NEVER derive systemId from pageKey
    // Only use EXPLICIT systemId field from Firestore
    // This prevents custom pages named "menu" or "home" from becoming system pages
    BuilderPageId? systemId;
    final explicitSystemId = json['systemId'] as String?;
    if (explicitSystemId != null && explicitSystemId.isNotEmpty) {
      // Only set systemId if it was EXPLICITLY stored in Firestore
      systemId = BuilderPageId.tryFromString(explicitSystemId);
    } else {
      // Check if isSystemPage is explicitly true AND pageKey matches a known system page
      // This handles legacy data where systemId wasn't stored but page is marked as system
      final isExplicitlySystemPage = json['isSystemPage'] as bool? ?? false;
      if (isExplicitlySystemPage) {
        systemId = BuilderPageId.tryFromString(pageKey);
      }
      // If not explicitly marked as system page, systemId stays null (custom page)
    }
    
    // pageId is now nullable - don't default to home for custom pages
    // For backward compatibility, pageId mirrors systemId
    final BuilderPageId? pageId = systemId;
    
    // Get system page config for proper defaults (only if this is a system page)
    final systemConfig = systemId != null ? SystemPages.getConfig(systemId) : null;
    
    // FIX B3-LAYOUT-MAPPING: Parse all possible legacy field names
    // Priority: draftLayout > blocks > layout > content > sections > pageBlocks
    final blocks = _safeLayoutParse(json['blocks']);
    
    // Check for legacy field names that might contain block data
    // B3-LAYOUT-MIGRATION: These are legacy field names from older versions
    final legacyLayout = _safeLayoutParse(json['layout']);
    final legacyContent = _safeLayoutParse(json['content']);
    final legacySections = _safeLayoutParse(json['sections']);
    final legacyPageBlocks = _safeLayoutParse(json['pageBlocks']);
    
    // Determine the best source for blocks - use first non-empty one
    List<BuilderBlock> bestLegacyBlocks = [];
    String legacySource = '';
    if (blocks.isNotEmpty) {
      bestLegacyBlocks = blocks;
      legacySource = 'blocks';
    } else if (legacyLayout.isNotEmpty) {
      bestLegacyBlocks = legacyLayout;
      legacySource = 'layout (legacy)';
    } else if (legacyContent.isNotEmpty) {
      bestLegacyBlocks = legacyContent;
      legacySource = 'content (legacy)';
    } else if (legacySections.isNotEmpty) {
      bestLegacyBlocks = legacySections;
      legacySource = 'sections (legacy)';
    } else if (legacyPageBlocks.isNotEmpty) {
      bestLegacyBlocks = legacyPageBlocks;
      legacySource = 'pageBlocks (legacy)';
    }
    
    if (legacySource.isNotEmpty && legacySource != 'blocks') {
      // FIX B3-LAYOUT-PARSE: Use debugPrint for consistent logging
      debugPrint('📋 [B3-LAYOUT-MIGRATION] Found ${bestLegacyBlocks.length} blocks in $legacySource for pageKey: $pageKey');
    }
    
    // FIX B3-LAYOUT-PARSE: Enhanced fallback chain with proper logging
    // Priority: draftLayout → publishedLayout → blocks (legacy) → empty
    final draftLayoutRaw = json['draftLayout'];
    var draftLayout = draftLayoutRaw != null 
        ? _safeLayoutParse(draftLayoutRaw)
        : <BuilderBlock>[];
    
    // Parse publishedLayout (new field)
    final publishedLayout = _safeLayoutParse(json['publishedLayout']);
    
    // FIX B3-LAYOUT-PARSE: Enhanced fallback chain
    // 1. If draftLayout is empty, try publishedLayout
    // 2. If publishedLayout is also empty, try legacy blocks
    // 3. Log which fallback was used
    
    if (draftLayout.isEmpty && publishedLayout.isNotEmpty) {
      // Fallback 1: Use publishedLayout
      draftLayout = List<BuilderBlock>.from(publishedLayout);
      debugPrint('ℹ️ [B3-LAYOUT-PARSE] Using fallback layout (published) for pageKey: $pageKey - ${publishedLayout.length} blocks');
    } else if (draftLayout.isEmpty && bestLegacyBlocks.isNotEmpty) {
      // Fallback 2: Use legacy blocks
      draftLayout = List<BuilderBlock>.from(bestLegacyBlocks);
      debugPrint('ℹ️ [B3-LAYOUT-PARSE] Using fallback layout ($legacySource) for pageKey: $pageKey - ${bestLegacyBlocks.length} blocks');
    } else if (draftLayout.isNotEmpty) {
      debugPrint('✅ [B3-LAYOUT-PARSE] draftLayout loaded for pageKey: $pageKey - ${draftLayout.length} blocks');
    } else {
      debugPrint('⚠️ [B3-LAYOUT-PARSE] No layout found for pageKey: $pageKey - page will be empty');
    }
    
    // Parse modules list safely - skip non-string items
    final List<String> modules = [];
    final rawModules = json['modules'];
    if (rawModules is List<dynamic>) {
      for (final m in rawModules) {
        if (m is String) {
          modules.add(m);
        } else if (m != null) {
          debugPrint('⚠️ [B3-LAYOUT-PARSE] Skipping non-string module value: $m (${m.runtimeType})');
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
