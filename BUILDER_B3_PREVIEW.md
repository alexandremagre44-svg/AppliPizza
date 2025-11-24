# Builder B3 - Preview System Documentation

## Status: ✅ IMPLEMENTED

The preview system for the Builder B3 is now complete with visual block renderers and integrated editor preview.

---

## 📁 Files Created (13 new files)

### Preview System (2 files)

1. **`builder_page_preview.dart`** - Main preview widget
   - Renders list of blocks visually
   - Empty state handling
   - Full-screen preview dialog

2. **`preview.dart`** - Barrel file for easy imports

### Block Preview Widgets (10 files)

3. **`hero_block_preview.dart`** - Hero banner with image/CTA
4. **`text_block_preview.dart`** - Text content with alignment/size
5. **`banner_block_preview.dart`** - Colored info banner
6. **`product_list_block_preview.dart`** - Product grid placeholders
7. **`info_block_preview.dart`** - Info notice box
8. **`spacer_block_preview.dart`** - Vertical spacing
9. **`image_block_preview.dart`** - Image with caption
10. **`button_block_preview.dart`** - CTA button
11. **`category_list_block_preview.dart`** - Category carousel
12. **`html_block_preview.dart`** - Custom HTML content

13. **`blocks.dart`** - Barrel file for block widgets

### Updated Files

- **`builder_page_editor_screen.dart`** - Integrated preview with tabs
- **`lib/builder/blocks/README.md`** - Implementation details
- **`lib/builder/preview/README.md`** - Implementation details

---

## 🎯 Key Features

### Preview Widget ✅

**BuilderPagePreview**
```dart
BuilderPagePreview(
  blocks: page.blocks,
  backgroundColor: Colors.grey.shade50,
)
```

**Features:**
- Renders all active blocks in order
- Filters inactive blocks automatically
- Empty state with helpful message
- Scrollable content
- No runtime provider dependencies

### Full-Screen Preview ✅

**BuilderFullScreenPreview**
```dart
BuilderFullScreenPreview.show(
  context,
  blocks: page.blocks,
  pageTitle: 'Accueil',
);
```

**Features:**
- Full-screen dialog
- AppBar with close button
- Page title displayed
- Complete preview experience

### Editor Integration ✅

**Tab-Based Layout:**
- **Tab 1: Édition** - Block list + configuration panel
- **Tab 2: Prévisualisation** - Live preview of page

**Toolbar Actions:**
- 💾 Save (when changes)
- 🖥️ Full-screen preview
- 📤 Publish

**FAB:**
- Shows only in Édition tab
- "Ajouter un bloc" button

---

## 📖 Block Preview Details

### Hero Block Preview
**Visual:**
- 280px height container
- Image or gradient background
- Dark overlay for text readability
- Title (32px, bold, white)
- Subtitle (18px, white with opacity)
- CTA button (white bg, colored text)

**Config:**
- title, subtitle, imageUrl, backgroundColor, buttonLabel

### Text Block Preview
**Visual:**
- Padding 16px horizontal, 24px vertical
- Configurable alignment (left/center/right)
- Configurable size (small 14px, normal 16px, large 20px)

**Config:**
- content, alignment, size

### Banner Block Preview
**Visual:**
- Full-width colored banner
- Icon + text row
- Rounded corners
- Subtle shadow

**Config:**
- text, backgroundColor, textColor

### Product List Block Preview
**Visual:**
- Grid layout (2 columns)
- Product cards with image placeholder
- Product name + price
- Responsive grid
- Max 6 products displayed

**Config:**
- mode (manual/auto), productIds

### Info Block Preview
**Visual:**
- Colored box (blue tint)
- Icon + title + content
- Rounded corners
- Border styling

**Config:**
- title, content, icon

### Spacer Block Preview
**Visual:**
- Vertical spacing
- Subtle divider line
- Configurable height

**Config:**
- height (default 32px)

### Image Block Preview
**Visual:**
- Rounded corners
- Configurable height
- Optional caption below
- Placeholder for missing images

**Config:**
- imageUrl, caption, height

### Button Block Preview
**Visual:**
- Configurable alignment
- Style variants (primary/secondary/outline)
- Padding and rounded corners

**Config:**
- label, alignment, style

### Category List Block Preview
**Visual:**
- Horizontal scrolling list
- Colored category cards (100px width)
- Icon + label
- 8 color variations

**Config:**
- categoryIds

### HTML Block Preview
**Visual:**
- Gray box with code icon
- Stripped HTML preview
- White content box

**Config:**
- html content

---

## 🏗️ Architecture

### No Runtime Dependencies

All preview widgets are **completely independent** from:
- ❌ Product providers
- ❌ Cart providers
- ❌ Auth providers
- ❌ Any complex runtime logic

They only use:
- ✅ Block configuration data
- ✅ Static visual rendering
- ✅ Theme/style constants
- ✅ Placeholder data

### Data Flow

```
BuilderPage
    ↓
blocks: List<BuilderBlock>
    ↓
BuilderPagePreview
    ↓
Renders each block based on type
    ↓
HeroBlockPreview, TextBlockPreview, etc.
    ↓
Visual output (no side effects)
```

### Color Parsing

All block previews support hex color strings:
```dart
'#D32F2F' → Color(0xFFD32F2F)
'#2196F3' → Color(0xFF2196F3)
```

Fallback to default colors if parsing fails.

---

## 📚 Usage

### In Editor (Tabs)

**Automatic integration:**
```dart
BuilderPageEditorScreen(
  appId: 'pizza_delizza',
  pageId: BuilderPageId.home,
)
```

Features:
- Tab 1: Edit blocks
- Tab 2: See preview
- Seamless switching
- Preview updates automatically when blocks change

### Full-Screen Preview

**From toolbar button:**
```dart
// User clicks 🖥️ button
BuilderFullScreenPreview.show(
  context,
  blocks: page.blocks,
  pageTitle: 'Accueil',
);
```

Features:
- Full-screen dialog
- Close button
- Page title in AppBar
- Complete preview experience

### Standalone Preview

**In custom screens:**
```dart
BuilderPagePreview(
  blocks: myBlocks,
  backgroundColor: Colors.white,
)
```

---

## 🎨 Visual Design

### Styling Consistency

All previews follow common design patterns:
- **Spacing**: 16px margins, 24px padding
- **Radius**: 12px rounded corners
- **Shadows**: Subtle elevation (0.1 opacity, 8px blur)
- **Typography**: 
  - Titles: 18-32px, bold
  - Body: 14-16px, regular
  - Captions: 12-14px, italic

### Color Palette

- **Primary**: User-configurable via config
- **Surface**: White backgrounds
- **Borders**: Grey.shade200-300
- **Text**: Black87 for body, White for overlays
- **Placeholders**: Grey.shade200-400

### Responsive Behavior

- **Product Grid**: 2 columns, responsive
- **Category List**: Horizontal scroll
- **Text**: Wraps naturally
- **Images**: Fit within container

---

## ✅ What's Complete

- [x] BuilderPagePreview widget
- [x] Full-screen preview dialog
- [x] 10 block preview widgets
- [x] Hero, Text, Banner, Product List
- [x] Info, Spacer, Image, Button
- [x] Category List, HTML
- [x] Editor integration (tabs)
- [x] Full-screen preview button
- [x] Empty state handling
- [x] Color parsing
- [x] No runtime dependencies
- [x] Placeholder data
- [x] Visual consistency
- [x] Complete documentation

---

## 🎯 Next Steps

Preview system is complete. Future enhancements:

### Phase 1: Enhanced Visuals ⏳
- [ ] Device frames (phone, tablet)
- [ ] Dark mode preview
- [ ] Responsive breakpoints
- [ ] Zoom controls

### Phase 2: Interactive Preview ⏳
- [ ] Click block to select in editor
- [ ] Hover effects
- [ ] Block boundaries visualization
- [ ] Edit mode overlay

### Phase 3: Real Data (Optional) ⏳
- [ ] Load actual product data for product blocks
- [ ] Load actual categories for category blocks
- [ ] Keep it optional (preview should work without data)

### Phase 4: Export/Share ⏳
- [ ] Screenshot preview
- [ ] Share preview link
- [ ] PDF export
- [ ] Preview history

---

## 📖 Import Usage

```dart
// Import preview system
import 'package:pizza_delizza/builder/preview/preview.dart';
import 'package:pizza_delizza/builder/blocks/blocks.dart';

// Use preview
BuilderPagePreview(blocks: myBlocks);

// Full-screen
BuilderFullScreenPreview.show(
  context,
  blocks: myBlocks,
  pageTitle: 'My Page',
);
```

---

## 🔒 Safety & Independence

### No Side Effects

All preview widgets are **pure** and **stateless**:
- No API calls
- No database queries
- No state mutations
- No provider dependencies

### Mock Data

When data is needed:
- Product lists: Show placeholders
- Categories: Show numbered cards
- Images: Show placeholder icon

This ensures:
- Fast rendering
- No network delays
- Works offline
- Predictable behavior

---

**Created**: 2025-11-24  
**Status**: ✅ Preview system complete and integrated  
**Version**: 1.0
