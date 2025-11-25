// lib/builder/models/builder_page.dart
// Page model for Builder B3 system

import 'builder_enums.dart';
import 'builder_block.dart';

/// Page model for multi-page builder system
/// 
/// Represents a complete page configuration with all its blocks.
/// Supports:
/// - Multi-page: Different pages (home, menu, promo, etc.)
/// - Multi-resto: Different configurations per restaurant (appId)
/// - Draft/Published: Separate draft and published versions
/// - Version control: Track changes over time
class BuilderPage {
  /// Unique page identifier (home, menu, promo, etc.)
  final BuilderPageId pageId;

  /// Restaurant/app identifier for multi-resto support
  /// Example: 'pizza_delizza', 'pizza_express', etc.
  final String appId;

  /// Display name for this page
  final String name;

  /// Page description (for admin reference)
  final String description;

  /// Route path for this page
  /// Example: '/home', '/menu', '/promo'
  final String route;

  /// List of blocks on this page, ordered by block.order
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

  BuilderPage({
    required this.pageId,
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
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        isSystemPage = isSystemPage ?? pageId.isSystemPage;

  /// Create a copy with modified fields
  BuilderPage copyWith({
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
  }) {
    return BuilderPage(
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
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'pageId': pageId.toJson(),
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
    };
  }

  /// Create from Firestore JSON
  factory BuilderPage.fromJson(Map<String, dynamic> json) {
    final pageId = BuilderPageId.fromJson(json['pageId'] as String? ?? 'home');
    return BuilderPage(
      pageId: pageId,
      appId: json['appId'] as String? ?? 'pizza_delizza',
      name: json['name'] as String? ?? 'Page',
      description: json['description'] as String? ?? '',
      route: json['route'] as String? ?? '/',
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((b) => BuilderBlock.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      isEnabled: json['isEnabled'] as bool? ?? true,
      isDraft: json['isDraft'] as bool? ?? false,
      metadata: json['metadata'] != null
          ? PageMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      version: json['version'] as int? ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      lastModifiedBy: json['lastModifiedBy'] as String?,
      displayLocation: json['displayLocation'] as String? ?? 'hidden',
      icon: json['icon'] as String? ?? 'help_outline',
      order: json['order'] as int? ?? 999,
      isSystemPage: json['isSystemPage'] as bool? ?? pageId.isSystemPage,
    );
  }

  /// Get blocks sorted by order
  List<BuilderBlock> get sortedBlocks {
    final sorted = List<BuilderBlock>.from(blocks);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  /// Get only active/visible blocks
  List<BuilderBlock> get activeBlocks {
    return sortedBlocks.where((b) => b.isActive).toList();
  }

  /// Add a block to this page
  BuilderPage addBlock(BuilderBlock block) {
    final newBlocks = List<BuilderBlock>.from(blocks);
    newBlocks.add(block);
    return copyWith(
      blocks: newBlocks,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Remove a block from this page
  BuilderPage removeBlock(String blockId) {
    final newBlocks = blocks.where((b) => b.id != blockId).toList();
    return copyWith(
      blocks: newBlocks,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Update a block on this page
  BuilderPage updateBlock(BuilderBlock updatedBlock) {
    final newBlocks = blocks.map((b) {
      return b.id == updatedBlock.id ? updatedBlock : b;
    }).toList();
    return copyWith(
      blocks: newBlocks,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Reorder blocks
  BuilderPage reorderBlocks(List<String> blockIds) {
    final newBlocks = <BuilderBlock>[];
    for (var i = 0; i < blockIds.length; i++) {
      final blockId = blockIds[i];
      final block = blocks.firstWhere((b) => b.id == blockId);
      newBlocks.add(block.copyWith(order: i));
    }
    return copyWith(
      blocks: newBlocks,
      updatedAt: DateTime.now(),
      version: version + 1,
    );
  }

  /// Create a published version from draft
  BuilderPage publish({required String userId}) {
    return copyWith(
      isDraft: false,
      publishedAt: DateTime.now(),
      lastModifiedBy: userId,
      updatedAt: DateTime.now(),
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

  @override
  String toString() {
    return 'BuilderPage(pageId: ${pageId.value}, appId: $appId, blocks: ${blocks.length}, draft: $isDraft)';
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
