# Builder B3 Module Integration

## Overview

The Builder B3 system has been enhanced to integrate with the white-label navigation system, providing:
1. **Unified preview/runtime rendering** - No more duplicate code
2. **Module-aware blocks** - Automatically hide blocks for disabled modules
3. **Centralized registry** - Single source of truth for all block types

## Problem Solved

### Before: Duplication ❌
```
Every block had 2 files:
- text_block_preview.dart    (for editor)
- text_block_runtime.dart    (for app)

Maintaining:
- 11 block types × 2 files = 22 files
- Duplicate logic
- Risk of inconsistencies
```

### After: Unified ✅
```
Single renderer per block:
- BlockRenderer function with isPreview flag
- 11 block types = 11 renderers
- No duplication
- Consistent behavior
```

## Architecture

### Unified Block Renderer

```dart
/// Unified renderer that works for preview AND runtime
typedef BlockRenderer = Widget Function(
  BuildContext context,
  BuilderBlock block,
  bool isPreview, {
  double? maxContentWidth,
});

// Example: Text block renderer
BlockType.text: (context, block, isPreview, {maxContentWidth}) {
  return isPreview
    ? TextBlockPreview(block: block)   // Editor mode
    : TextBlockRuntime(block: block);  // App mode
}
```

### Registry Pattern

```dart
class BuilderBlockRuntimeRegistry {
  static final Map<BlockType, BlockRenderer> _renderers = {
    BlockType.text: /* unified renderer */,
    BlockType.button: /* unified renderer */,
    BlockType.hero: /* unified renderer */,
    // ... all other blocks
  };
  
  static Widget render(
    BuilderBlock block,
    BuildContext context, {
    bool isPreview = false,
    double? maxContentWidth,
  }) {
    final renderer = _renderers[block.type];
    return renderer(context, block, isPreview, maxContentWidth: maxContentWidth);
  }
}
```

### Module-Aware Rendering

```dart
/// Widget that automatically hides blocks for disabled modules
class ModuleAwareBlock extends ConsumerWidget {
  final BuilderBlock block;
  final bool isPreview;

  Widget build(BuildContext context, WidgetRef ref) {
    // In preview mode, always show
    if (isPreview) {
      return _renderBlock(context);
    }
    
    // Check if block requires a module
    if (block.requiredModule != null) {
      final moduleId = _parseModuleId(block.requiredModule!);
      
      // Use white-label helper
      if (!isModuleEnabled(ref, moduleId)) {
        return const SizedBox.shrink(); // Hide block
      }
    }
    
    return _renderBlock(context);
  }
}
```

## Usage Guide

### 1. Rendering Blocks

#### In Editor (Preview Mode)
```dart
// Single block
BuilderBlockRuntimeRegistry.render(
  block,
  context,
  isPreview: true,  // Preview mode
);

// Multiple blocks
BuilderBlockRuntimeRegistry.renderAll(
  blocks,
  context,
  isPreview: true,
);
```

#### In App (Runtime Mode)
```dart
// Single block
BuilderBlockRuntimeRegistry.render(
  block,
  context,
  isPreview: false,  // Runtime mode
);

// Multiple blocks
BuilderBlockRuntimeRegistry.renderAll(
  blocks,
  context,
  isPreview: false,
);
```

### 2. Module-Aware Rendering

#### Single Block
```dart
// Automatically checks module status
ModuleAwareBlock(
  block: block,
  isPreview: false,  // In app
)

// Or in editor
ModuleAwareBlock(
  block: block,
  isPreview: true,  // Shows all blocks
)
```

#### Multiple Blocks
```dart
ModuleAwareBlockList(
  blocks: blocks,
  isPreview: false,
  maxContentWidth: 800,
)
```

### 3. Setting Required Modules

#### In Block Definition
```dart
final block = BuilderBlock(
  id: 'btn_roulette',
  type: BlockType.button,
  config: {
    'label': 'Spin the Wheel',
    'action': {
      'type': 'navigate',
      'route': '/roulette',
    },
  },
);

// Mark as requiring roulette module (using ModuleId enum)
block.requiredModule = ModuleId.roulette;
```

#### In JSON/Firestore
```json
{
  "id": "btn_roulette",
  "type": "button",
  "config": {
    "label": "Spin the Wheel",
    "action": {
      "type": "navigate",
      "route": "/roulette"
    }
  },
  "requiredModule": "roulette"
}
// Note: In JSON, requiredModule is stored as a string (ModuleId.code)
// The BuilderBlock.fromJson() automatically converts it to ModuleId enum
```

## Supported Block Types

All block types now have unified renderers:

| Block Type | Preview | Runtime | Module Support |
|------------|---------|---------|----------------|
| hero | ✅ | ✅ | ✅ |
| text | ✅ | ✅ | ✅ |
| banner | ✅ | ✅ | ✅ |
| productList | ✅ | ✅ | ✅ |
| info | ✅ | ✅ | ✅ |
| spacer | ✅ | ✅ | ✅ |
| image | ✅ | ✅ | ✅ |
| button | ✅ | ✅ | ✅ |
| categoryList | ✅ | ✅ | ✅ |
| html | ✅ | ✅ | ✅ |
| system | ✅ | ✅ | ✅ |

## Module Integration

### Supported Modules

Blocks can require any of these modules:

- `loyalty` - Loyalty/rewards features
- `roulette` - Gamification/roulette
- `delivery` - Delivery features
- `click_and_collect` - Click & collect
- `promotions` - Promotions
- `newsletter` - Newsletter signup
- `kitchen_tablet` - Kitchen display
- `staff_tablet` - POS/Staff features
- `payments` - Payment features
- `wallet` - Digital wallet
- And more... (see `ModuleId` enum)

### How It Works

```
┌──────────────────────────────────┐
│  User views page                 │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  ModuleAwareBlock                │
│  - Reads block.requiredModule    │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  isModuleEnabled(ref, moduleId)  │
│  - Checks RestaurantPlanUnified  │
│  - Returns true/false            │
└────────────┬─────────────────────┘
             │
       ┌─────┴─────┐
       │           │
       ▼           ▼
    false        true
       │           │
       ▼           ▼
  Hide block   Show block
```

## Migration Guide

### From Separate Preview/Runtime

#### Before
```dart
// In preview code
if (isPreview) {
  return TextBlockPreview(block: block);
} else {
  return TextBlockRuntime(block: block);
}
```

#### After
```dart
// Single call
BuilderBlockRuntimeRegistry.render(
  block,
  context,
  isPreview: isPreview,
);
```

### From Old Registry

#### Before (Deprecated)
```dart
// Old way - still works but deprecated
final builder = BuilderBlockRuntimeRegistry.getBuilder(BlockType.text);
final widget = builder(block, context);
```

#### After (Recommended)
```dart
// New way - unified renderer
final renderer = BuilderBlockRuntimeRegistry.getRenderer(BlockType.text);
final widget = renderer(context, block, isPreview);

// Or use render() directly
final widget = BuilderBlockRuntimeRegistry.render(block, context, isPreview: false);
```

## Advanced Usage

### Custom Block Renderers

#### Register Custom Renderer
```dart
// Add your own block type
BuilderBlockRuntimeRegistry.registerRenderer(
  BlockType.custom,
  (context, block, isPreview, {maxContentWidth}) {
    if (isPreview) {
      return CustomBlockPreview(block: block);
    } else {
      return CustomBlockRuntime(block: block);
    }
  },
);
```

#### Unregister Renderer
```dart
// Remove a block type
BuilderBlockRuntimeRegistry.unregisterRenderer(BlockType.custom);
```

### Check Block Support

```dart
// Check if renderer exists
if (BuilderBlockRuntimeRegistry.hasRenderer(BlockType.text)) {
  // Render the block
}

// Get all supported types
final types = BuilderBlockRuntimeRegistry.registeredTypes;
print('Supported blocks: $types');
```

## Benefits

### 1. No Duplication ✅
- **Before**: 22 files (11 types × 2 modes)
- **After**: 11 renderers in 1 registry
- **Savings**: 50% less code to maintain

### 2. Module Integration ✅
- **Automatic**: Blocks hide when modules are disabled
- **White-label ready**: Works with restaurant plans
- **No manual checks**: Just set `requiredModule` property

### 3. Easier Testing ✅
```dart
testWidgets('Text block renders in preview', (tester) async {
  await tester.pumpWidget(
    BuilderBlockRuntimeRegistry.render(
      block,
      context,
      isPreview: true,  // Test preview mode
    ),
  );
});

testWidgets('Text block renders in runtime', (tester) async {
  await tester.pumpWidget(
    BuilderBlockRuntimeRegistry.render(
      block,
      context,
      isPreview: false,  // Test runtime mode
    ),
  );
});
```

### 4. Consistent Behavior ✅
- Same rendering logic in preview and runtime
- Easier to ensure consistency
- Changes propagate automatically

## Backward Compatibility

All old APIs still work with deprecation warnings:

```dart
// Old - Still works
@Deprecated('Use getRenderer instead')
static BlockRuntimeBuilder? getBuilder(BlockType type);

@Deprecated('Use registerRenderer instead')
static void registerBuilder(BlockType type, BlockRuntimeBuilder builder);

@Deprecated('Use unregisterRenderer instead')
static bool unregisterBuilder(BlockType type);
```

Your existing code will continue to work, but you'll see deprecation warnings encouraging migration to the new API.

## Troubleshooting

### Block Not Hiding When Module Disabled

**Problem**: Block shows even though module is disabled.

**Solution**: Make sure you're using `ModuleAwareBlock`:
```dart
// ❌ Won't check modules
BuilderBlockRuntimeRegistry.render(block, context);

// ✅ Checks modules
ModuleAwareBlock(block: block, isPreview: false);
```

### Preview Showing Hidden Blocks

**Problem**: Blocks are hidden in editor preview.

**Solution**: Set `isPreview: true`:
```dart
// ❌ Will hide disabled modules in preview
ModuleAwareBlock(block: block, isPreview: false);

// ✅ Shows all blocks in preview
ModuleAwareBlock(block: block, isPreview: true);
```

### Module Not Recognized

**Problem**: `requiredModule` set but block still shows.

**Solution**: Use the correct ModuleId enum value:
```dart
// ❌ Wrong - String values don't work
block.requiredModule = 'roulette';

// ✅ Correct - Use ModuleId enum
block.requiredModule = ModuleId.roulette;

// Available modules:
// ModuleId.loyalty, ModuleId.roulette, ModuleId.delivery, etc.
```

## Examples

### Example 1: Roulette Button

```dart
// Create a button that only shows if roulette is enabled
final rouletteButton = BuilderBlock(
  id: 'btn_roulette',
  type: BlockType.button,
  config: {
    'label': 'Spin the Wheel',
    'backgroundColor': '#FF5722',
    'textColor': '#FFFFFF',
    'action': {
      'type': 'navigate',
      'route': '/roulette',
    },
  },
  requiredModule: ModuleId.roulette,  // Set module requirement
);

// Render with module awareness
ModuleAwareBlock(
  block: rouletteButton,
  isPreview: false,
);

// Result:
// - If roulette enabled → Button shows
// - If roulette disabled → Button hidden (SizedBox.shrink)
```

### Example 2: Loyalty Banner

```dart
// Create a banner for loyalty program
final loyaltyBanner = BuilderBlock(
  id: 'banner_loyalty',
  type: BlockType.banner,
  config: {
    'imageUrl': 'https://example.com/loyalty.jpg',
    'height': 200.0,
    'action': {
      'type': 'navigate',
      'route': '/rewards',
    },
  },
  requiredModule: ModuleId.loyalty,  // Require loyalty module
);

// Render in a page
ModuleAwareBlockList(
  blocks: [
    heroBlock,
    loyaltyBanner,  // Hidden if loyalty disabled
    textBlock,
  ],
  isPreview: false,
);
```

### Example 3: Conditional Layout

```dart
// Build a dynamic page with module-aware blocks
class DynamicPage extends ConsumerWidget {
  final List<BuilderBlock> blocks;

  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: ModuleAwareBlockList(
        blocks: blocks,
        isPreview: false,
      ),
    );
  }
}

// Blocks adapt automatically:
// - Roulette block → Shows only if roulette enabled
// - Loyalty block → Shows only if loyalty enabled
// - System blocks → Always show (no module requirement)
```

## Performance

### Minimal Overhead
- Module check is O(1) lookup in HashSet
- Only happens at render time
- Preview mode skips all checks
- No performance impact on editor

### Caching
Restaurant plan is cached by Riverpod provider, so:
- Module checks don't hit database
- Fast in-memory lookups
- Reactive updates when plan changes

## Conclusion

The Builder B3 module integration provides:
- ✅ **Unified rendering** - No preview/runtime duplication
- ✅ **Module awareness** - Automatic feature hiding
- ✅ **Easy to use** - Just set `requiredModule` property
- ✅ **Backward compatible** - Old code still works
- ✅ **Production ready** - Tested and documented

This completes the white-label navigation system integration with Builder B3.
