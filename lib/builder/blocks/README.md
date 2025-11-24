# Builder B3 - Blocks

This directory contains the block preview rendering components.

## Purpose
- Visual representation of each block type
- Preview-only widgets (no runtime dependencies)
- Reusable block preview components
- Used by preview system

## Files (11 total)

### ✅ Block Preview Widgets (10 files)

1. **`hero_block_preview.dart`** - Hero banner preview
2. **`text_block_preview.dart`** - Text content preview
3. **`banner_block_preview.dart`** - Info banner preview
4. **`product_list_block_preview.dart`** - Product grid preview
5. **`info_block_preview.dart`** - Info notice preview
6. **`spacer_block_preview.dart`** - Spacing preview
7. **`image_block_preview.dart`** - Image preview
8. **`button_block_preview.dart`** - CTA button preview
9. **`category_list_block_preview.dart`** - Category carousel preview
10. **`html_block_preview.dart`** - HTML content preview

### ✅ Barrel File

11. **`blocks.dart`** - Export all block previews

## Features

### No Runtime Dependencies
- ✅ No product providers
- ✅ No cart providers
- ✅ No auth providers
- ✅ Pure visual rendering
- ✅ Placeholder data only

### Configuration-Based
- All widgets use block.config map
- Type-safe config getters
- Default values for missing config
- Color parsing from hex strings

## Usage

```dart
import 'package:pizza_delizza/builder/blocks/blocks.dart';

// Render specific block
HeroBlockPreview(block: heroBlock);
TextBlockPreview(block: textBlock);

// Used automatically by BuilderPagePreview
BuilderPagePreview(blocks: allBlocks);
```

## Status
✅ **IMPLEMENTED** - All preview blocks complete

See BUILDER_B3_PREVIEW.md for complete documentation.
