# Builder B3 - Services Documentation

## Status: ✅ IMPLEMENTED

The Firestore service layer for the Builder B3 system is now complete and ready to use.

---

## 📁 Files Created

### Core Service (3 files)

1. **`builder_layout_service.dart`** - Main Firestore service
   - Complete CRUD operations for pages
   - Draft/published workflow management
   - Multi-page and multi-resto support
   - Real-time updates via streams
   - Batch operations and utilities

2. **`services.dart`** - Barrel file for easy imports

3. **`service_example.dart`** - Comprehensive usage examples
   - All major workflows demonstrated
   - Error handling examples
   - Real-world use cases

### Documentation

4. **`README.md`** - Updated with implementation details

---

## 🎯 Key Features

### Firestore Structure ✅

```
apps/
  └── {appId}/                    # e.g., 'pizza_delizza'
      └── builder/
          └── pages/
              ├── home/
              │   ├── draft       # Draft version of home page
              │   └── published   # Published version of home page
              ├── menu/
              │   ├── draft
              │   └── published
              ├── promo/
              │   ├── draft
              │   └── published
              ├── about/
              │   ├── draft
              │   └── published
              └── contact/
                  ├── draft
                  └── published
```

**Benefits:**
- Clear separation of draft vs published
- Multi-page support (each page type separate)
- Multi-resto support (different appId = different restaurant)
- Easy to query and manage
- Scalable structure

### Draft/Published Workflow ✅

**Draft Operations:**
```dart
// Save draft
await service.saveDraft(page);

// Load draft
final draft = await service.loadDraft(appId, pageId);

// Watch draft in real-time
service.watchDraft(appId, pageId).listen((page) {
  // Update editor UI
});

// Delete draft
await service.deleteDraft(appId, pageId);

// Check if draft exists
final hasDraft = await service.hasDraft(appId, pageId);
```

**Published Operations:**
```dart
// Publish page
await service.publishPage(
  draft,
  userId: 'admin_123',
  deleteDraft: true, // Optional: clean up draft
);

// Load published
final published = await service.loadPublished(appId, pageId);

// Watch published in real-time
service.watchPublished(appId, pageId).listen((page) {
  // Update client app UI
});

// Unpublish (revert to draft)
await service.unpublishPage(appId, pageId);
```

### Smart Load Operations ✅

```dart
// Load page (prefers draft, falls back to published)
// Useful for editor: always show latest version
final page = await service.loadPage(appId, pageId);

// Watch page (prefers draft, falls back to published)
service.watchPage(appId, pageId).listen((page) {
  // Always shows most recent version
});
```

### Multi-Page Support ✅

```dart
// Load all published pages for an app
final pages = await service.loadAllPublishedPages('pizza_delizza');
// Returns: Map<BuilderPageId, BuilderPage>

// Load all drafts
final drafts = await service.loadAllDraftPages('pizza_delizza');

// Publish all drafts at once
final published = await service.publishAllDrafts(
  'pizza_delizza',
  userId: 'admin_123',
  deleteDrafts: true,
);
// Returns: List<BuilderPageId> of published pages
```

### Multi-Resto Support ✅

```dart
// Restaurant 1
final page1 = await service.loadPublished('pizza_delizza', BuilderPageId.home);

// Restaurant 2 - same page type, different content
final page2 = await service.loadPublished('pizza_express', BuilderPageId.home);

// Each restaurant has independent configurations
// Same service, different appId
```

### Page Status Checking ✅

```dart
final status = await service.getPageStatus(appId, pageId);

// Check status
print(status.hasDraft);              // Draft exists?
print(status.hasPublished);          // Published exists?
print(status.exists);                // Any version exists?
print(status.isClean);               // Only published, no draft?
print(status.hasUnpublishedChanges); // Has unpublished draft?
print(status.isNew);                 // No versions exist?
```

### Utility Operations ✅

```dart
// Create default page if none exists
final page = await service.createDefaultPage(
  'pizza_delizza',
  BuilderPageId.home,
  isDraft: true,
);

// Copy published to draft (for editing)
final draft = await service.copyPublishedToDraft(appId, pageId);
```

---

## 📖 Common Workflows

### 1. Editor Workflow

```dart
final service = BuilderLayoutService();
final appId = 'pizza_delizza';
final pageId = BuilderPageId.home;

// Load page for editing
var page = await service.loadPage(appId, pageId);

// If no page exists, create default
if (page == null) {
  page = await service.createDefaultPage(appId, pageId);
}

// If editing published page, create draft
if (!page.isDraft) {
  page = await service.copyPublishedToDraft(appId, pageId);
}

// Make changes
page = page!.addBlock(newBlock);

// Save draft
await service.saveDraft(page);

// Preview in real-time
service.watchDraft(appId, pageId).listen((draft) {
  // Update preview UI
});

// When ready, publish
await service.publishPage(page, userId: 'admin_123', deleteDraft: true);
```

### 2. Client App Workflow

```dart
final service = BuilderLayoutService();
final appId = 'pizza_delizza';

// Load published page for rendering
final homePage = await service.loadPublished(appId, BuilderPageId.home);

if (homePage != null && homePage.isEnabled) {
  // Render page with blocks
  for (final block in homePage.sortedBlocks) {
    // Render each block based on type
  }
}

// Watch for updates (real-time)
service.watchPublished(appId, BuilderPageId.home).listen((page) {
  if (page != null) {
    // Update UI when admin publishes changes
  }
});
```

### 3. Admin Panel Workflow

```dart
final service = BuilderLayoutService();
final appId = 'pizza_delizza';

// Show all pages with status
for (final pageId in BuilderPageId.values) {
  final status = await service.getPageStatus(appId, pageId);
  
  print('${pageId.label}:');
  if (status.isNew) {
    print('  ❌ Not created yet');
  } else if (status.hasUnpublishedChanges) {
    print('  ⚠️  Has unpublished draft');
  } else if (status.isClean) {
    print('  ✅ Published and up-to-date');
  }
}

// Batch publish all drafts
final published = await service.publishAllDrafts(
  appId,
  userId: 'admin_123',
  deleteDrafts: true,
);
print('Published ${published.length} pages');
```

---

## 🏗️ Architecture

### Service Layer

```
BuilderLayoutService
├── Draft Operations
│   ├── saveDraft()
│   ├── loadDraft()
│   ├── watchDraft()
│   ├── deleteDraft()
│   └── hasDraft()
├── Published Operations
│   ├── publishPage()
│   ├── loadPublished()
│   ├── watchPublished()
│   ├── deletePublished()
│   ├── hasPublished()
│   └── unpublishPage()
├── Smart Load
│   ├── loadPage()
│   └── watchPage()
├── Multi-Page
│   ├── loadAllPublishedPages()
│   ├── loadAllDraftPages()
│   └── publishAllDrafts()
└── Utilities
    ├── createDefaultPage()
    ├── copyPublishedToDraft()
    └── getPageStatus()
```

### Data Flow

```
Editor UI
    ↓
loadPage() / watchDraft()
    ↓
BuilderLayoutService
    ↓
Firestore (draft collection)
    ↓
Make changes
    ↓
saveDraft()
    ↓
publishPage()
    ↓
Firestore (published collection)
    ↓
watchPublished()
    ↓
Client App UI
```

---

## 🔒 Type Safety & Error Handling

### Type Safety
```dart
// Generic types
Future<BuilderPage?> loadPage(String appId, BuilderPageId pageId)
Stream<BuilderPage?> watchPage(String appId, BuilderPageId pageId)
Future<Map<BuilderPageId, BuilderPage>> loadAllPublishedPages(String appId)
```

### Error Handling
```dart
try {
  // Try to save non-draft as draft
  await service.saveDraft(page); // throws ArgumentError
} on ArgumentError catch (e) {
  print('Invalid argument: $e');
}

try {
  // Try to unpublish non-existent page
  await service.unpublishPage(appId, pageId); // throws StateError
} on StateError catch (e) {
  print('Invalid state: $e');
}

// Firestore errors are caught and logged
// Returns null for missing data instead of throwing
final page = await service.loadDraft(appId, pageId); // Returns null if not found
```

---

## 🧪 Testing Examples

See `service_example.dart` for comprehensive examples:

1. **Basic draft workflow** - Create, save, load, publish
2. **Real-time updates** - Stream-based updates
3. **Editor workflow** - Complete editor integration
4. **Publishing workflow** - Draft to published
5. **Multi-page management** - Handle all pages
6. **Multi-resto support** - Multiple restaurants
7. **Unpublish/revert** - Move published back to draft
8. **Batch operations** - Publish all at once
9. **Error handling** - Proper error management
10. **Page status checking** - Get page state

---

## 📊 Performance Considerations

### Caching
- Use streams for real-time updates (efficient)
- Firestore caches documents automatically
- Only fetch when needed

### Batch Operations
```dart
// Efficient: Load all pages in one operation
final pages = await service.loadAllPublishedPages(appId);

// Less efficient: Load one by one
for (final pageId in BuilderPageId.values) {
  final page = await service.loadPublished(appId, pageId);
}
```

### Real-time Updates
```dart
// Efficient: Single stream for updates
service.watchPublished(appId, pageId).listen((page) {
  // Automatic updates when admin publishes
});

// Less efficient: Polling
Timer.periodic(Duration(seconds: 5), (_) async {
  final page = await service.loadPublished(appId, pageId);
});
```

---

## 🎯 Next Steps

With services in place, the next phases are:

### Phase 1: Riverpod Providers ⏳
- Create providers for service access
- State management for editor
- Cache management

### Phase 2: Block Widgets ⏳
- Create rendering widgets for each block type
- Implement block preview
- Add block editing UI

### Phase 3: Editor UI ⏳
- Build visual editor interface
- Add drag-and-drop
- Create property panels
- Implement toolbar

### Phase 4: Preview System ⏳
- Real-time preview
- Device frames
- Responsive testing

---

## ✅ What's Complete

- [x] Complete Firestore service
- [x] Draft/published workflow
- [x] Multi-page support
- [x] Multi-resto support
- [x] Real-time updates via streams
- [x] Smart load operations
- [x] Batch operations
- [x] Page status checking
- [x] Utility methods
- [x] Error handling
- [x] Type safety
- [x] Comprehensive examples
- [x] Complete documentation

---

## 📚 Import Usage

Simple import for service:

```dart
import 'package:pizza_delizza/builder/services/services.dart';
import 'package:pizza_delizza/builder/models/models.dart';

// Create service
final service = BuilderLayoutService();

// Use all operations
await service.saveDraft(page);
final draft = await service.loadDraft(appId, pageId);
// etc.
```

---

**Created**: 2025-11-24  
**Status**: ✅ Services complete and ready for provider/UI implementation  
**Version**: 1.0
