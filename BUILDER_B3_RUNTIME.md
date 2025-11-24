# Builder B3 - Runtime Integration

Complete runtime integration guide for Builder B3 system with HomeScreen.

## Overview

The Builder B3 system is now integrated into the HomeScreen with **automatic fallback** to existing behavior. The app loads published layouts from Firestore and renders them using runtime widgets with full provider access.

## Architecture

### Runtime vs Preview Widgets

**Preview Widgets** (`*_block_preview.dart`):
- Used in editor preview tab
- Static visual representation
- No provider dependencies
- Placeholder data only

**Runtime Widgets** (`*_block_runtime.dart`):
- Used in actual app (HomeScreen)
- Full provider access
- Real product data
- Interactive functionality

### Integration Flow

```
HomeScreen
    ↓
FutureBuilder<BuilderPage?>
    ↓
BuilderLayoutService.loadPublished()
    ↓
Has published layout?
    ├─ YES → BuilderRuntimeRenderer
    │           ↓
    │       Render blocks with runtime widgets
    │           ↓
    │       Full app functionality
    │
    └─ NO → Fallback to default HomeScreen
                ↓
            Existing hero, promos, bestsellers
```

## Runtime Widgets

### 1. HeroBlockRuntime
- Uses existing `HeroBanner` widget
- Full styling from app theme
- Navigation to menu on tap

**Config:**
- title, subtitle, imageUrl, backgroundColor, buttonLabel

### 2. TextBlockRuntime
- Uses `AppTextStyles` from theme
- Alignment: left/center/right
- Size: small/normal/large

**Config:**
- content, alignment, size

### 3. BannerBlockRuntime
- Uses existing `InfoBanner` widget
- Consistent styling

**Config:**
- text

### 4. ProductListBlockRuntime ⭐
- **Full provider integration**
- Loads real products via `productListProvider`
- Shopping cart integration
- Pizza/menu customization modals
- Product cards with cart quantity

**Config:**
- mode (manual/auto)
- productIds (comma-separated)

**Features:**
- Manual mode: Filter by product IDs
- Auto mode: Show featured/promo products
- 2-column grid layout
- Add to cart functionality
- Customization modals for pizzas/menus

### 5. InfoBlockRuntime
- Colored info boxes
- Icons: info/warning/error/success
- Theme-consistent styling

**Config:**
- title, content, icon

### 6. SpacerBlockRuntime
- Configurable vertical spacing

**Config:**
- height (default: 32px)

### 7. ImageBlockRuntime
- Network image loading
- Loading/error states
- Optional caption
- Rounded corners

**Config:**
- imageUrl, caption, height

### 8. ButtonBlockRuntime
- Three styles: primary/secondary/outline
- Three alignments: left/center/right
- Navigation actions

**Config:**
- label, alignment, style, action

**Actions:**
- menu → Go to menu
- cart → Open cart
- profile → Open profile

### 9. CategoryListBlockRuntime
- Uses existing `CategoryShortcuts` widget
- Horizontal scroll
- Real categories from app

### 10. HtmlBlockRuntime
- Simplified HTML rendering
- Tag stripping for display

**Config:**
- html

## BuilderRuntimeRenderer

Main rendering component that converts `BuilderBlock` list to widgets.

**Features:**
- Filters active blocks
- Sorts by order
- Maps block types to runtime widgets
- Full Riverpod consumer for provider access

**Usage:**
```dart
BuilderRuntimeRenderer(
  blocks: page.blocks,
  backgroundColor: Colors.white,
)
```

## HomeScreen Integration

### Multi-Resto Support

```dart
static const String appId = 'pizza_delizza';
```

Change `appId` for different restaurants.

### Loading Strategy

1. **FutureBuilder** loads published layout
2. **Snapshot has data** → Use Builder B3 layout
3. **Snapshot empty/error** → Use default layout
4. **Smooth fallback** with no breaking changes

### Performance

- Single Firestore read on load
- Cached by Flutter's FutureBuilder
- RefreshIndicator for manual refresh
- No continuous polling

### Error Handling

**Graceful degradation:**
- Firestore error → Fallback to default
- Invalid block config → Skip block
- Missing products → Empty grid
- Network error on images → Placeholder

## Workflow

### For Admins

1. Open Admin Menu
2. Click "🎨 Builder B3"
3. Select "Accueil" (Home)
4. Click "Éditer"
5. Add/configure blocks
6. Preview in "Prévisualisation" tab
7. Save draft (💾)
8. Publish (📤)

### For Users

1. Open app
2. HomeScreen loads automatically
3. **With published layout:**
   - Sees Builder B3 blocks
   - Interactive blocks
   - Full functionality
4. **Without published layout:**
   - Sees default Home
   - Hero, promos, bestsellers
   - No difference in experience

## Safety Features

### ✅ Non-Breaking Changes

- Default behavior preserved
- No code deleted
- Fallback always works
- Existing widgets untouched

### ✅ Provider Safety

- All runtime widgets are `ConsumerWidget`
- Proper provider watching
- Error boundaries in place
- No provider leaks

### ✅ Performance

- Lazy loading with FutureBuilder
- No unnecessary rebuilds
- Efficient block rendering
- Image caching

## Testing

### Test Published Layout

1. Create page in Builder B3
2. Add blocks
3. Publish
4. Restart app
5. HomeScreen shows Builder layout

### Test Fallback

1. Delete published layout in Firestore
2. Restart app
3. HomeScreen shows default layout

### Test Error Handling

1. Disconnect network
2. Open app
3. HomeScreen shows default layout (fallback)

## Configuration

### Change App ID

Edit `HomeScreen.appId`:
```dart
static const String appId = 'your_restaurant_id';
```

### Customize Fallback

Edit `_buildContent()` method in HomeScreen to change default behavior.

### Add New Block Types

1. Create `*_block_runtime.dart` in `lib/builder/blocks/`
2. Add case in `BuilderRuntimeRenderer._buildBlock()`
3. Export from `blocks.dart`

## Firestore Structure

```
apps/
  └── pizza_delizza/
      └── builder/
          └── pages/
              └── home/
                  ├── draft      # Admin editing
                  └── published  # Live on app
```

## Migration

### Existing Apps

**No migration needed!**
- App works with or without published layouts
- Admins can gradually build pages
- Users see seamless experience

### Gradual Rollout

1. Install Builder B3 (already done)
2. Keep existing Home (already done)
3. Build layouts in draft
4. Test with preview
5. Publish when ready
6. Users see new layout
7. Fallback still works if unpublished

## Limitations

### Current

- Only Home page integrated (menu, promo, about, contact coming soon)
- HTML block simplified (no full HTML rendering)
- Category list uses existing widget (not fully customizable)

### Future Enhancements

- A/B testing support
- Scheduled publishing
- Device-specific layouts (mobile/tablet/desktop)
- Analytics integration
- Performance metrics

## Documentation

- `BUILDER_B3_SETUP.md` - Initial setup
- `BUILDER_B3_MODELS.md` - Data models
- `BUILDER_B3_SERVICES.md` - Firestore service
- `BUILDER_B3_EDITOR.md` - Page editor
- `BUILDER_B3_PREVIEW.md` - Preview system
- `BUILDER_B3_RUNTIME.md` - **This file** - Runtime integration

## Support

### Common Issues

**Q: HomeScreen shows default layout**
A: Check if layout is published in Firestore (not just draft)

**Q: Blocks not appearing**
A: Check `isActive` flag on blocks

**Q: Products not loading**
A: Verify product IDs in config match Firestore

**Q: App crashes on HomeScreen**
A: Check logs - likely provider issue. Fallback should prevent crashes.

## Result

✅ Builder B3 fully integrated with HomeScreen
✅ Automatic fallback to existing behavior
✅ Zero breaking changes
✅ Full provider access in runtime widgets
✅ Production-ready with gradual rollout capability
