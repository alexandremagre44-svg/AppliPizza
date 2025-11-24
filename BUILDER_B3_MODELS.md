# Builder B3 - Data Models Documentation

## Status: ✅ IMPLEMENTED

The core data models for the Builder B3 system are now complete and ready to use.

---

## 📁 Files Created

### Core Models (4 files)

1. **`builder_enums.dart`** - Enumerations
   - `BuilderPageId` - Page identifiers (home, menu, promo, about, contact)
   - `BlockType` - Block types (10 types: hero, banner, text, productList, etc.)
   - `BlockAlignment` - Alignment options
   - `BlockVisibility` - Visibility settings

2. **`builder_block.dart`** - Block model
   - `BuilderBlock` class - Base block with configuration
   - Support for all block types
   - Config management helpers
   - Firestore serialization

3. **`builder_page.dart`** - Page model
   - `BuilderPage` class - Complete page with blocks
   - `PageMetadata` class - SEO metadata
   - Block management methods
   - Draft/publish workflow
   - Multi-resto support via `appId`

4. **`models.dart`** - Barrel file
   - Exports all models for easy import

### Documentation (2 files)

5. **`example_usage.dart`** - Comprehensive examples
6. **`README.md`** - Updated with implementation details

---

## 🎯 Key Features

### Multi-Page Support ✅
```dart
enum BuilderPageId {
  home,    // Main landing page
  menu,    // Product catalog
  promo,   // Promotions page
  about,   // About us page
  contact, // Contact page
}
```

Each page is identified by its `BuilderPageId` and can have completely different content and blocks.

### Multi-Resto Support ✅
```dart
final page1 = BuilderPage(
  pageId: BuilderPageId.home,
  appId: 'pizza_delizza',  // Restaurant 1
  // ...
);

final page2 = BuilderPage(
  pageId: BuilderPageId.home,
  appId: 'pizza_express',  // Restaurant 2
  // ...
);
```

Same `pageId`, different `appId` = different configurations per restaurant.

### Block System ✅
```dart
enum BlockType {
  hero,         // Hero banner with image and CTA
  banner,       // Promotional banner
  text,         // Text content
  productList,  // Product listing/grid
  info,         // Information/notice
  spacer,       // Spacing element
  image,        // Image display
  button,       // Action button
  categoryList, // Category navigation
  html,         // Custom HTML
}
```

Each block type has:
- Unique identifier
- Type enum
- Order position
- Configuration map
- Visibility settings

### Configuration System ✅
```dart
final block = BuilderBlock(
  id: 'hero_1',
  type: BlockType.hero,
  order: 0,
  config: {
    'title': 'Welcome',
    'subtitle': 'Discover our pizzas',
    'imageUrl': 'https://...',
    'ctaText': 'View Menu',
    'ctaAction': '/menu',
    'height': 400,
  },
);
```

Flexible `config` map allows each block type to have its own settings.

### Draft/Published Workflow ✅
```dart
// Create draft
var page = BuilderPage(...);

// Make changes
page = page.addBlock(newBlock);

// Publish
page = page.publish(userId: 'admin_123');

// Check status
print(page.isDraft);      // false
print(page.publishedAt);  // 2025-11-24...
```

Separate draft and published versions with timestamps.

### Version Control ✅
```dart
print(page.version);  // 1

page = page.addBlock(block);
print(page.version);  // 2

page = page.updateBlock(updatedBlock);
print(page.version);  // 3
```

Automatic version incrementing on changes.

---

## 📖 Usage Examples

### Create a Complete Page

```dart
import 'package:pizza_delizza/builder/models/models.dart';

// Create page
final page = BuilderPage(
  pageId: BuilderPageId.home,
  appId: 'pizza_delizza',
  name: 'Page d\'accueil',
  route: '/home',
  blocks: [],
);

// Create blocks
final heroBlock = BuilderBlock(
  id: 'hero_1',
  type: BlockType.hero,
  order: 0,
  config: {
    'title': 'Bienvenue chez Pizza Deli\'Zza',
    'imageUrl': 'https://...',
  },
);

final bannerBlock = BuilderBlock(
  id: 'banner_1',
  type: BlockType.banner,
  order: 1,
  config: {
    'text': '🔥 Promo: -20% ce week-end!',
    'backgroundColor': '#D32F2F',
  },
);

// Add blocks to page
final completePage = page
    .addBlock(heroBlock)
    .addBlock(bannerBlock);

print(completePage.blocks.length); // 2
```

### Block Operations

```dart
// Get sorted blocks
final sorted = page.sortedBlocks;

// Get only active blocks
final active = page.activeBlocks;

// Update a block
final updated = page.updateBlock(modifiedBlock);

// Remove a block
final removed = page.removeBlock('block_id');

// Reorder blocks
final reordered = page.reorderBlocks(['id1', 'id2', 'id3']);
```

### Firestore Serialization

```dart
// To JSON (for Firestore)
final json = page.toJson();
await firestore.collection('pages').doc(page.pageId.value).set(json);

// From JSON (from Firestore)
final snapshot = await firestore.collection('pages').doc('home').get();
final page = BuilderPage.fromJson(snapshot.data()!);
```

### Config Management

```dart
// Get config value with type safety
final title = block.getConfig<String>('title', 'Default');
final height = block.getConfig<int>('height', 300);

// Update config
final updated = block.updateConfig('title', 'New Title');
```

---

## 🏗️ Architecture

### Class Hierarchy

```
BuilderPage
├── pageId: BuilderPageId (enum)
├── appId: String (multi-resto)
├── blocks: List<BuilderBlock>
├── metadata: PageMetadata?
└── Methods: addBlock, removeBlock, updateBlock, reorderBlocks, publish

BuilderBlock
├── id: String
├── type: BlockType (enum)
├── order: int
├── config: Map<String, dynamic>
└── Methods: copyWith, updateConfig, toJson, fromJson

Enums
├── BuilderPageId: home, menu, promo, about, contact
├── BlockType: hero, banner, text, productList, info, spacer, etc.
├── BlockAlignment: left, center, right
└── BlockVisibility: visible, hidden, mobileOnly, desktopOnly
```

### Data Flow

```
Admin creates page → BuilderPage model
    ↓
Add blocks → BuilderBlock models
    ↓
Configure blocks → config map
    ↓
Save to Firestore → toJson()
    ↓
Load in app → fromJson()
    ↓
Render blocks → Block widgets (future)
```

---

## 🎨 Block Type Details

Each block type has specific config fields:

### Hero Block
```dart
config: {
  'title': String,
  'subtitle': String,
  'imageUrl': String,
  'ctaText': String,
  'ctaAction': String,
  'height': int,
  'textColor': String,
  'overlayColor': String,
}
```

### Banner Block
```dart
config: {
  'text': String,
  'backgroundColor': String,
  'textColor': String,
  'icon': String,
}
```

### Text Block
```dart
config: {
  'content': String,
  'fontSize': int,
  'fontWeight': String,
  'color': String,
  'alignment': String,
}
```

### Product List Block
```dart
config: {
  'title': String?,
  'category': String,
  'limit': int,
  'layout': String, // 'grid' or 'list'
  'showPrice': bool,
  'showAddToCart': bool,
}
```

---

## 🔒 Type Safety

All models use:
- ✅ Strong typing with enums
- ✅ Non-nullable fields where appropriate
- ✅ Type-safe config getters
- ✅ Immutable data with `copyWith`
- ✅ JSON serialization/deserialization

---

## 🧪 Testing

See `example_usage.dart` for comprehensive examples:
- Creating pages and blocks
- Block operations (add, remove, update, reorder)
- Multi-resto scenarios
- Draft/publish workflow
- JSON serialization
- Enum usage

---

## 📝 Next Steps

With models in place, the next phases are:

### Phase 1: Services ⏳
- Create Firestore services for CRUD operations
- Implement draft/publish workflow
- Add version control

### Phase 2: Block Widgets ⏳
- Create widget for each block type
- Implement rendering logic
- Add preview support

### Phase 3: Editor UI ⏳
- Build visual editor interface
- Add drag-and-drop
- Create property panels

### Phase 4: Preview ⏳
- Real-time preview
- Device frames
- Responsive testing

---

## ✅ What's Complete

- [x] All core data models
- [x] Multi-page support (5 page types)
- [x] Multi-resto support via appId
- [x] 10 block types defined
- [x] Configuration system
- [x] Draft/publish workflow
- [x] Version control
- [x] Firestore serialization
- [x] Type safety with enums
- [x] Helper methods
- [x] Comprehensive examples
- [x] Documentation

---

## 📚 Import Usage

Simple import for all models:

```dart
import 'package:pizza_delizza/builder/models/models.dart';

// Now you have access to:
// - BuilderPage
// - BuilderBlock
// - BuilderPageId
// - BlockType
// - BlockAlignment
// - BlockVisibility
// - PageMetadata
```

---

**Created**: 2025-11-24  
**Status**: ✅ Models complete and ready for services implementation  
**Version**: 1.0
