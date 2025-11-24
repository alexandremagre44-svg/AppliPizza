# Builder B3 - Models

This directory contains the data models for the Builder B3 system.

## Purpose
- Define the structure of pages, blocks, and configurations
- Provide serialization/deserialization for Firestore
- Support multi-page, multi-resto architecture

## Files

### ✅ `builder_enums.dart`
Enums for the builder system:
- `BuilderPageId` - Page identifiers (home, menu, promo, about, contact)
- `BlockType` - Block types (hero, banner, text, productList, info, spacer, image, button, categoryList, html)
- `BlockAlignment` - Alignment options (left, center, right)
- `BlockVisibility` - Visibility settings (visible, hidden, mobileOnly, desktopOnly)

### ✅ `builder_block.dart`
Base block model (`BuilderBlock`):
- Unique ID and type
- Order position on page
- Configuration map for block-specific settings
- Active/visibility states
- Created/updated timestamps
- Helper methods for config management

### ✅ `builder_page.dart`
Page model (`BuilderPage`):
- Page identifier and app ID (multi-resto)
- Name, description, route
- List of blocks
- Draft/published states
- Version control
- SEO metadata
- Block management methods (add, remove, update, reorder)

### ✅ `models.dart`
Barrel file for easy imports - exports all model classes

## Usage

```dart
import 'package:pizza_delizza/builder/models/models.dart';

// Create a page
final page = BuilderPage(
  pageId: BuilderPageId.home,
  appId: 'pizza_delizza',
  name: 'Page d\'accueil',
  route: '/home',
  blocks: [],
);

// Create a block
final block = BuilderBlock(
  id: 'block_1',
  type: BlockType.hero,
  order: 0,
  config: {
    'title': 'Bienvenue',
    'subtitle': 'Découvrez nos pizzas',
    'imageUrl': 'https://...',
  },
);

// Add block to page
final updatedPage = page.addBlock(block);
```

## Features

### Multi-Page Support
- Different page IDs: home, menu, promo, about, contact
- Extensible enum for adding new pages

### Multi-Resto Support
- Each page has an `appId` field
- Supports different configurations per restaurant

### Draft/Published Workflow
- `isDraft` flag for unpublished changes
- `publishedAt` timestamp
- Version tracking

### Block System
- Modular blocks with specific types
- Order-based positioning
- Configuration via JSON map
- Visibility controls

### Type Safety
- Enums for all categorical values
- Strong typing throughout
- Helper methods for safe access

## Status
✅ **IMPLEMENTED** - Core models ready for use
