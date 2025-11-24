# Builder B3 - Editor

This directory contains the editor interface components.

## Purpose
- User interface for building and editing pages
- Block selection and configuration
- Drag-and-drop functionality
- Property editors for blocks

## Files

### ✅ `builder_page_editor_screen.dart`
Main page editor screen with full CRUD and editing capabilities.

**Features:**
- Load draft page (auto-create if missing)
- Display blocks in reorderable list
- Add/remove blocks
- Drag & drop reordering
- Block configuration panel
- Save draft / Publish workflow

**Block Configuration:**
- Hero: title, subtitle, imageUrl, backgroundColor, buttonLabel
- Text: content, alignment (left/center/right), size (small/normal/large)
- Product List: mode (manual/auto), productIds (comma-separated)
- Banner: text, backgroundColor, textColor

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BuilderPageEditorScreen(
      appId: 'pizza_delizza',
      pageId: BuilderPageId.home,
    ),
  ),
);
```

### ✅ `editor.dart`
Barrel file for easy imports.

## UI Components

### Blocks List (Left Side)
- ReorderableListView with all blocks
- Drag handles for reordering
- Block icon, type, and summary
- Delete button per block
- Click to select and edit

### Configuration Panel (Right Side)
- Appears when block selected
- Dynamic fields based on block type
- Text fields for text inputs
- Dropdowns for selections
- Real-time updates on change

### Toolbar (Top)
- Save draft button (appears when changes)
- Publish button
- Page title display

### Add Block FAB (Bottom Right)
- Floating action button
- Opens dialog with all block types
- Icon + label for each type

## Features Implemented

### Block Management
- ✅ Add blocks (any type)
- ✅ Remove blocks
- ✅ Reorder via drag & drop
- ✅ Select block to edit
- ✅ Update block configuration

### Configuration
- ✅ Hero block config
- ✅ Text block config
- ✅ Product list config
- ✅ Banner config
- ✅ Type-safe value updates

### Workflow
- ✅ Load draft (or create default)
- ✅ Auto-save indicator
- ✅ Save draft to Firestore
- ✅ Publish to production
- ✅ Confirmation dialogs

### UX
- ✅ Visual selection feedback
- ✅ Reorderable list
- ✅ Block summaries
- ✅ Empty state message
- ✅ Error handling
- ✅ Success notifications

## Block Configuration Details

### Hero Block
- `title` - Main heading (TextField)
- `subtitle` - Secondary text (TextField)
- `imageUrl` - Background image URL (TextField)
- `backgroundColor` - Hex color (TextField)
- `buttonLabel` - CTA button text (TextField)

### Text Block
- `content` - Text content (TextField, multiline)
- `alignment` - left/center/right (Dropdown)
- `size` - small/normal/large (Dropdown)

### Product List Block
- `mode` - manual/auto (Dropdown)
- `productIds` - Comma-separated IDs (TextField)

### Banner Block
- `text` - Banner text (TextField)
- `backgroundColor` - Hex color (TextField)
- `textColor` - Hex color (TextField)

## Future Enhancements

- [ ] Image picker for imageUrl fields
- [ ] Color picker for color fields
- [ ] Product selector for productIds
- [ ] Preview panel (real-time)
- [ ] Undo/redo functionality
- [ ] Block templates
- [ ] Keyboard shortcuts
- [ ] Copy/paste blocks
- [ ] Block visibility toggle

## Status
✅ **IMPLEMENTED** - Core editor ready for use
