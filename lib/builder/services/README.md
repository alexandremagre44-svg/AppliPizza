# Builder B3 - Services

This directory contains the business logic and data services for the Builder B3 system.

## Purpose
- Handle Firestore operations for pages and blocks
- Manage draft/published states
- Support multi-resto configuration
- Provide data synchronization

## Files

### ✅ `builder_layout_service.dart`
Main service for managing page layouts in Firestore.

**Features:**
- Draft/published workflow
- Multi-page support
- Multi-resto support (appId)
- Version control
- Real-time updates via streams

**Firestore Structure:**
```
apps/{appId}/builder/pages/{pageId}/draft
apps/{appId}/builder/pages/{pageId}/published
```

**Key Methods:**

*Draft Operations:*
- `saveDraft(page)` - Save draft page
- `loadDraft(appId, pageId)` - Load draft
- `watchDraft(appId, pageId)` - Real-time draft updates
- `deleteDraft(appId, pageId)` - Delete draft
- `hasDraft(appId, pageId)` - Check if draft exists

*Published Operations:*
- `publishPage(page, userId, deleteDraft)` - Publish a page
- `loadPublished(appId, pageId)` - Load published page
- `watchPublished(appId, pageId)` - Real-time published updates
- `deletePublished(appId, pageId)` - Delete published
- `hasPublished(appId, pageId)` - Check if published exists
- `unpublishPage(appId, pageId, deletePublished)` - Revert to draft

*Smart Load:*
- `loadPage(appId, pageId)` - Load page (prefers draft)
- `watchPage(appId, pageId)` - Watch page (prefers draft)

*Multi-Page:*
- `loadAllPublishedPages(appId)` - Load all published
- `loadAllDraftPages(appId)` - Load all drafts
- `publishAllDrafts(appId, userId, deleteDrafts)` - Batch publish

*Utilities:*
- `createDefaultPage(appId, pageId, isDraft)` - Create default page
- `copyPublishedToDraft(appId, pageId)` - Create draft from published
- `getPageStatus(appId, pageId)` - Get draft/published status

### ✅ `services.dart`
Barrel file for easy imports.

### ✅ `service_example.dart`
Comprehensive usage examples for all service operations.

## Usage

```dart
import 'package:pizza_delizza/builder/services/services.dart';
import 'package:pizza_delizza/builder/models/models.dart';

// Create service
final service = BuilderLayoutService();

// Save draft
final page = BuilderPage(..., isDraft: true);
await service.saveDraft(page);

// Load draft
final draft = await service.loadDraft('pizza_delizza', BuilderPageId.home);

// Publish
await service.publishPage(draft!, userId: 'admin_123', deleteDraft: true);

// Watch real-time updates
service.watchPublished('pizza_delizza', BuilderPageId.home).listen((page) {
  if (page != null) {
    // Update UI
  }
});
```

## Workflows

### Editor Workflow
1. Load page (draft or published)
2. Make changes
3. Save as draft
4. Preview draft
5. Publish when ready

### Publishing Workflow
1. Load draft
2. Review changes
3. Publish (converts to published)
4. Optionally delete draft

### Multi-Resto Workflow
1. Same service for all restaurants
2. Different `appId` per restaurant
3. Independent configurations

## Page Status

`PageStatus` class provides status information:
- `hasDraft` - Draft version exists
- `hasPublished` - Published version exists
- `exists` - Any version exists
- `isClean` - Only published, no draft
- `hasUnpublishedChanges` - Has draft (changes not published)
- `isNew` - No versions exist

## Error Handling

The service includes proper error handling:
- `ArgumentError` - Invalid arguments (e.g., saving non-draft as draft)
- `StateError` - Invalid state (e.g., unpublishing non-existent page)
- Try-catch blocks for Firestore operations
- Null returns for missing data

## Examples

See `service_example.dart` for comprehensive examples:
- Basic draft workflow
- Real-time updates
- Editor workflow
- Publishing workflow
- Multi-page management
- Multi-resto support
- Unpublish/revert
- Batch operations
- Error handling
- Page status checking

## Status
✅ **IMPLEMENTED** - Core service ready for use
