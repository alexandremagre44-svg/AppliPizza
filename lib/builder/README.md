# Builder B3 - Clean Architecture

**Status**: 🚧 Work In Progress - Base structure ready

## Overview

This is the NEW Builder B3 implementation - a clean, modular, multi-page, multi-resto page builder system.

All old builder/studio code has been removed. This is a fresh start with proper architecture.

## Architecture

```
lib/builder/
├── builder_entry.dart          # Main entry point - BuilderStudioScreen
├── models/                     # Data models (pages, blocks, configs)
├── blocks/                     # Block components (text, image, button, etc.)
├── editor/                     # Editor UI (visual builder, properties)
├── preview/                    # Preview components (device frames, renderer)
├── services/                   # Business logic (Firestore, publishing)
└── utils/                      # Utilities and helpers
```

## Key Features (Planned)

- ✅ Clean architecture - No legacy code
- 🚧 Multi-page support
- 🚧 Multi-resto configuration
- 🚧 Modular block system
- 🚧 Drag-and-drop editor
- 🚧 Real-time preview
- 🚧 Draft/publish workflow
- 🚧 Firestore integration

## Entry Point

The main entry widget is `BuilderStudioScreen` in `builder_entry.dart`.

### How to Use

From your admin menu, navigate to the Builder Studio:

```dart
import 'package:pizza_delizza/builder/builder_entry.dart';

// Navigate to builder
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const BuilderStudioScreen(),
  ),
);

// Or with GoRouter
context.push('/admin/builder-b3');
```

## Current Implementation

### What's Ready
- ✅ Directory structure created
- ✅ Entry point widget (BuilderStudioScreen)
- ✅ Documentation for each module
- ✅ Clean separation from existing app

### What's Not Implemented Yet
- ⏳ Block models and definitions
- ⏳ Editor interface
- ⏳ Preview system
- ⏳ Firestore services
- ⏳ Actual building functionality

## Design Principles

1. **Modular**: Each block is independent and reusable
2. **Clean**: No legacy code, fresh architecture
3. **Scalable**: Support multiple pages and restaurants
4. **Safe**: No impact on existing app functionality
5. **Professional**: Production-ready code quality

## Integration with Existing App

### What This Module Does NOT Touch

- ❌ Existing HomeScreen
- ❌ Existing MenuScreen
- ❌ Current routes for client app
- ❌ Existing Firestore services
- ❌ Product management
- ❌ Order system
- ❌ Authentication

### What This Module Will Do

- ✅ Provide admin interface for building pages
- ✅ Store page configurations in Firestore
- ✅ Generate dynamic pages that can be rendered
- ✅ Support multiple restaurants

## Next Steps

1. Implement block models
2. Create basic block types (text, image, button)
3. Build editor interface
4. Add preview functionality
5. Implement Firestore services
6. Add drag-and-drop
7. Implement publish workflow

## Notes

- This module is completely isolated from the existing app
- It can be developed incrementally without breaking anything
- Old builder routes and code have been removed
- Ready for clean implementation

---

**Created**: 2025-11-24  
**Status**: Base structure only - Ready for implementation
