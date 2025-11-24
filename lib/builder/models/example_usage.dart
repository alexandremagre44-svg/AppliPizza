// lib/builder/models/example_usage.dart
// Example usage of Builder B3 models
// This file demonstrates how to use the data models

import 'models.dart';

/// Example: Creating a complete home page
BuilderPage createExampleHomePage() {
  // Create page
  final page = BuilderPage(
    pageId: BuilderPageId.home,
    appId: 'pizza_delizza',
    name: 'Page d\'accueil',
    description: 'Page principale avec hero, promotions et produits',
    route: '/home',
    blocks: [],
    metadata: const PageMetadata(
      title: 'Pizza Deli\'Zza - Livraison de pizzas',
      description: 'Les meilleures pizzas livrées chez vous',
      keywords: 'pizza, livraison, restaurant',
    ),
  );

  // Add hero block
  final heroBlock = BuilderBlock(
    id: 'hero_1',
    type: BlockType.hero,
    order: 0,
    config: {
      'title': 'Bienvenue chez Pizza Deli\'Zza',
      'subtitle': 'Les meilleures pizzas artisanales',
      'imageUrl': 'https://images.unsplash.com/photo-1513104890138-7c749659a591',
      'ctaText': 'Voir le menu',
      'ctaAction': '/menu',
      'height': 400,
      'textColor': '#FFFFFF',
      'overlayColor': '#00000066',
    },
  );

  // Add banner block
  final bannerBlock = BuilderBlock(
    id: 'banner_1',
    type: BlockType.banner,
    order: 1,
    config: {
      'text': '🔥 Promo: -20% sur toutes les pizzas ce week-end!',
      'backgroundColor': '#D32F2F',
      'textColor': '#FFFFFF',
      'icon': 'local_offer',
    },
  );

  // Add product list block
  final productBlock = BuilderBlock(
    id: 'products_1',
    type: BlockType.productList,
    order: 2,
    config: {
      'title': '⭐ Nos best-sellers',
      'category': 'pizza',
      'limit': 4,
      'layout': 'grid',
      'showPrice': true,
      'showAddToCart': true,
    },
  );

  // Add info block
  final infoBlock = BuilderBlock(
    id: 'info_1',
    type: BlockType.info,
    order: 3,
    config: {
      'text': 'À emporter uniquement — 11h–21h (Mar→Dim)',
      'icon': 'info',
      'backgroundColor': '#E3F2FD',
      'textColor': '#1976D2',
    },
  );

  // Add spacer
  final spacerBlock = BuilderBlock(
    id: 'spacer_1',
    type: BlockType.spacer,
    order: 4,
    config: {
      'height': 32,
    },
  );

  // Add all blocks to page
  return page
      .addBlock(heroBlock)
      .addBlock(bannerBlock)
      .addBlock(productBlock)
      .addBlock(infoBlock)
      .addBlock(spacerBlock);
}

/// Example: Creating a menu page
BuilderPage createExampleMenuPage() {
  return BuilderPage(
    pageId: BuilderPageId.menu,
    appId: 'pizza_delizza',
    name: 'Menu',
    description: 'Catalogue de produits',
    route: '/menu',
    blocks: [
      BuilderBlock(
        id: 'menu_header',
        type: BlockType.text,
        order: 0,
        config: {
          'content': 'Notre Menu',
          'fontSize': 32,
          'fontWeight': 'bold',
          'alignment': 'center',
          'marginTop': 16,
          'marginBottom': 16,
        },
      ),
      BuilderBlock(
        id: 'categories',
        type: BlockType.categoryList,
        order: 1,
        config: {
          'layout': 'horizontal',
          'showIcons': true,
        },
      ),
      BuilderBlock(
        id: 'menu_products',
        type: BlockType.productList,
        order: 2,
        config: {
          'category': 'all',
          'layout': 'grid',
          'columns': 2,
          'showFilters': true,
        },
      ),
    ],
  );
}

/// Example: Working with blocks
void exampleBlockOperations() {
  // Create a page
  var page = createExampleHomePage();

  // Get sorted blocks
  final sortedBlocks = page.sortedBlocks;
  print('Page has ${sortedBlocks.length} blocks');

  // Get only active blocks
  final activeBlocks = page.activeBlocks;
  print('${activeBlocks.length} blocks are active');

  // Update a block's config
  final heroBlock = page.blocks.first;
  final updatedHero = heroBlock.updateConfig('title', 'Nouveau titre');
  page = page.updateBlock(updatedHero);

  // Remove a block
  page = page.removeBlock('spacer_1');

  // Reorder blocks
  final blockIds = page.blocks.map((b) => b.id).toList();
  blockIds.shuffle(); // Random order for demo
  page = page.reorderBlocks(blockIds);

  // Publish the page
  page = page.publish(userId: 'admin_123');
  print('Page published at: ${page.publishedAt}');
}

/// Example: Multi-resto support
void exampleMultiResto() {
  // Create page for restaurant 1
  final page1 = BuilderPage(
    pageId: BuilderPageId.home,
    appId: 'pizza_delizza',
    name: 'Accueil Pizza Deli\'Zza',
    route: '/home',
    blocks: [],
  );

  // Create page for restaurant 2
  final page2 = BuilderPage(
    pageId: BuilderPageId.home,
    appId: 'pizza_express',
    name: 'Accueil Pizza Express',
    route: '/home',
    blocks: [],
  );

  // Same pageId, different appId = different configurations
  print('Restaurant 1: ${page1.appId} - ${page1.name}');
  print('Restaurant 2: ${page2.appId} - ${page2.name}');
}

/// Example: JSON serialization
void exampleSerialization() {
  // Create page
  final page = createExampleHomePage();

  // Convert to JSON (for Firestore)
  final json = page.toJson();
  print('Page as JSON: ${json.keys}');

  // Convert back from JSON
  final restoredPage = BuilderPage.fromJson(json);
  print('Restored page: ${restoredPage.name}');
  print('Has ${restoredPage.blocks.length} blocks');
}

/// Example: Draft workflow
void exampleDraftWorkflow() {
  // Create published page
  var page = createExampleHomePage().publish(userId: 'admin_1');
  print('Published page, version: ${page.version}');

  // Create draft from published
  var draft = page.createDraft();
  print('Draft created, isDraft: ${draft.isDraft}');

  // Make changes to draft
  final newBlock = BuilderBlock(
    id: 'new_feature',
    type: BlockType.text,
    order: 10,
    config: {'content': 'Nouvelle fonctionnalité'},
  );
  draft = draft.addBlock(newBlock);
  print('Draft modified, version: ${draft.version}');

  // Publish draft
  final published = draft.publish(userId: 'admin_1');
  print('Draft published, publishedAt: ${published.publishedAt}');
}

/// Example: Block types and enums
void exampleEnums() {
  // All available page IDs
  print('Available pages:');
  for (final pageId in BuilderPageId.values) {
    print('  - ${pageId.label} (${pageId.value})');
  }

  // All available block types
  print('\nAvailable block types:');
  for (final blockType in BlockType.values) {
    print('  ${blockType.icon} ${blockType.label} (${blockType.value})');
  }

  // Convert from string
  final pageId = BuilderPageId.fromString('menu');
  final blockType = BlockType.fromString('hero');
  print('\nParsed: $pageId, $blockType');
}
