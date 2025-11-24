# Builder B3 - Utils

This directory contains utility functions and helpers for the Builder B3 system.

## Current Contents

### ✅ BuilderPageWrapper
**File:** `builder_page_wrapper.dart`

Reusable wrapper widget for pages that support Builder B3 layouts with automatic fallback.

**Features:**
- Loads published layouts from Firestore  
- Falls back to default content if no layout exists
- Error handling with graceful degradation
- Loading state management
- RefreshIndicator support

**Usage:**
```dart
BuilderPageWrapper(
  pageId: BuilderPageId.menu,
  appId: 'pizza_delizza',
  fallbackBuilder: () => DefaultMenuWidget(),
)
```

## Purpose
- Common utilities and helper functions
- Validation logic
- Constants and enums
- Shared helpers

## Future Contents
- `block_validator.dart` - Validate block configurations
- `builder_constants.dart` - Constants for builder
- `id_generator.dart` - Generate unique IDs
- `color_utils.dart` - Color manipulation helpers
- `serialization_utils.dart` - JSON helpers

## Utilities to Implement
- Block validation
- ID generation
- Data transformation
- Error handling
- Common helpers

## Status
✅ BuilderPageWrapper implemented
🚧 Additional utilities awaiting implementation
