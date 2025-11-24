# Builder B3 - Preview

This directory contains the preview system components.

## Purpose
- Real-time page preview
- Visual feedback during editing
- No runtime dependencies
- Pure visual rendering

## Files (2 total)

### ✅ Preview System

1. **`builder_page_preview.dart`** - Main preview widget
2. **`preview.dart`** - Barrel file for easy imports

## Features

### BuilderPagePreview Widget ✅

```dart
BuilderPagePreview(
  blocks: page.blocks,
  backgroundColor: Colors.grey.shade50,
)
```

### BuilderFullScreenPreview Dialog ✅

```dart
BuilderFullScreenPreview.show(
  context,
  blocks: page.blocks,
  pageTitle: 'Accueil',
);
```

## Usage

### In Editor

Integrated automatically in BuilderPageEditorScreen:
- Tab 1: Édition (editing mode)
- Tab 2: Prévisualisation (preview mode)
- Full-screen button in toolbar

### Standalone

```dart
import 'package:pizza_delizza/builder/preview/preview.dart';

BuilderPagePreview(blocks: myBlocks);
```

## Architecture

### No Runtime Dependencies

- ❌ No providers
- ❌ No API calls
- ❌ No database queries
- ✅ Pure visual rendering
- ✅ Configuration-based only

## Status
✅ **IMPLEMENTED** - Core preview system complete

See BUILDER_B3_PREVIEW.md for complete documentation.
