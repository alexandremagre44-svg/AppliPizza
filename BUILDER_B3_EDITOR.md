# Builder B3 - Editor Documentation

## Status: ✅ IMPLEMENTED

The page editor interface for the Builder B3 system is now complete and ready to use.

---

## 📁 Files Created

### Core Editor (2 files)

1. **`builder_page_editor_screen.dart`** - Complete page editor
   - Full CRUD operations for blocks
   - Drag & drop reordering
   - Configuration panels
   - Save/publish workflow

2. **`editor.dart`** - Barrel file for easy imports

### Documentation

3. **`README.md`** - Updated with implementation details

---

## 🎯 Key Features

### Page Editor Screen ✅

**BuilderPageEditorScreen**
```dart
BuilderPageEditorScreen(
  appId: 'pizza_delizza',
  pageId: BuilderPageId.home,
)
```

**Features:**
- Load draft page (auto-creates if missing)
- Display all blocks in list
- Add any block type
- Remove blocks
- Reorder via drag & drop
- Configure block properties
- Save draft to Firestore
- Publish to production

### UI Layout ✅

```
┌─────────────────────────────────────────────────┐
│  Éditeur: Accueil        [💾] [📤]             │
├──────────────────────────┬────────────────────────┤
│                          │                        │
│  Block List (Left 2/3)   │  Config Panel (Right)  │
│                          │                        │
│  ┌──────────────────┐    │  🖼️ Hero Banner        │
│  │ 🖼️ Hero Banner   │    │  ─────────────────     │
│  │ Titre du Hero    │    │  Configuration         │
│  │          [🗑️] [⋮] │    │                        │
│  └──────────────────┘    │  Titre:               │
│                          │  [________________]    │
│  ┌──────────────────┐    │                        │
│  │ 📝 Texte         │    │  Sous-titre:          │
│  │ Nouveau texte    │    │  [________________]    │
│  │          [🗑️] [⋮] │    │                        │
│  └──────────────────┘    │  URL Image:           │
│                          │  [________________]    │
│  ┌──────────────────┐    │                        │
│  │ 🍕 Liste Produits│    │  Couleur de fond:     │
│  │ 3 produit(s)     │    │  [________________]    │
│  │          [🗑️] [⋮] │    │                        │
│  └──────────────────┘    │  Label du bouton:     │
│                          │  [________________]    │
└──────────────────────────┴────────────────────────┘
                        [➕ Ajouter un bloc]
```

### Block Management ✅

**Add Block:**
1. Click FAB "Ajouter un bloc"
2. Select block type from dialog
3. Block added with default config
4. Automatically selected for editing

**Remove Block:**
- Click delete icon (🗑️) on any block
- Block immediately removed
- If selected, config panel closes

**Reorder Blocks:**
- Drag any block by its handle (⋮)
- Drop in new position
- Order automatically updated
- Changes marked as unsaved

**Edit Block:**
- Click on any block in list
- Configuration panel opens on right
- Edit any field
- Changes update immediately

### Configuration Panels ✅

Dynamic configuration based on block type:

#### Hero Block Configuration
```
🖼️ Hero Banner
───────────────
Configuration

Titre:
[__________________________]

Sous-titre:
[__________________________]

URL Image:
[__________________________]

Couleur de fond:
[__________________________]

Label du bouton:
[__________________________]
```

#### Text Block Configuration
```
📝 Texte
────────
Configuration

Contenu:
[__________________________]
[__________________________]
[__________________________]

Alignement:
[left ▼] left/center/right

Taille:
[normal ▼] small/normal/large
```

#### Product List Configuration
```
🍕 Liste Produits
─────────────────
Configuration

Mode:
[manual ▼] manual/auto

IDs des produits:
[__________________________]
Ex: prod1, prod2, prod3
```

#### Banner Block Configuration
```
🎨 Bannière
───────────
Configuration

Texte:
[__________________________]

Couleur de fond:
[__________________________]

Couleur du texte:
[__________________________]
```

---

## 📖 Usage

### Navigate to Editor

**From BuilderStudioScreen:**
```dart
// Main entry shows page list
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BuilderStudioScreen(appId: 'pizza_delizza'),
  ),
);

// Click "Éditer" on any page to open editor
```

**Direct Navigation:**
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

### Edit Workflow

1. **Load Page**
   - Screen loads draft from Firestore
   - If no draft exists, creates default
   - Shows loading indicator

2. **Add Blocks**
   - Click FAB "Ajouter un bloc"
   - Select from list of block types
   - Block appears in list
   - Automatically opens for editing

3. **Configure Block**
   - Click any block to select
   - Config panel opens on right
   - Edit fields
   - Changes save to state immediately
   - Changes indicator appears (💾)

4. **Reorder Blocks**
   - Drag block by handle
   - Drop in new position
   - List reorders
   - Changes indicator appears

5. **Remove Blocks**
   - Click delete icon (🗑️)
   - Block removed immediately
   - If selected, panel closes

6. **Save Draft**
   - Click save icon (💾) in toolbar
   - Draft saved to Firestore
   - Success notification
   - Changes indicator disappears

7. **Publish**
   - Click publish icon (📤) in toolbar
   - Confirmation dialog
   - Published to production
   - Success notification

---

## 🏗️ Architecture

### State Management

```dart
class _BuilderPageEditorScreenState {
  BuilderLayoutService _service;      // Firestore service
  BuilderPage? _page;                 // Current page being edited
  bool _isLoading;                    // Loading state
  BuilderBlock? _selectedBlock;       // Currently selected block
  bool _hasChanges;                   // Unsaved changes flag
}
```

### Key Methods

**Lifecycle:**
- `initState()` - Load page on startup
- `_loadPage()` - Load draft or create default

**Block Operations:**
- `_addBlock(type)` - Add new block
- `_removeBlock(id)` - Remove block
- `_reorderBlocks(old, new)` - Change order
- `_selectBlock(block)` - Select for editing
- `_updateBlockConfig(key, value)` - Update config field

**Save/Publish:**
- `_saveDraft()` - Save to Firestore draft
- `_publishPage()` - Publish to production

**UI Builders:**
- `_buildBlocksList()` - Reorderable list view
- `_buildConfigPanel()` - Configuration panel
- `_buildConfigFields(block)` - Dynamic fields
- `_buildHeroConfig()`, `_buildTextConfig()`, etc.

### Data Flow

```
User Action
    ↓
State Update (setState)
    ↓
UI Rebuilds
    ↓
[Save] → Firestore (draft)
    ↓
[Publish] → Firestore (published)
```

---

## 🎨 UI Components

### Blocks List

**ReorderableListView:**
- Shows all blocks in order
- Each block = Card with:
  - Icon (emoji for block type)
  - Type label
  - Summary (first line of content)
  - Delete button
  - Drag handle
- Click to select
- Visual feedback when selected (blue background)

### Configuration Panel

**Conditional Panel:**
- Only shown when block selected
- Right side of screen (1/3 width)
- Gray background
- Scrollable content
- Header with icon, type, close button
- Dynamic fields based on block type
- All changes immediate

### Toolbar

**AppBar Actions:**
- Save icon (💾) - Only when changes
- Publish icon (📤) - Always visible
- Visual indicator for unsaved changes

### Floating Action Button

**Add Block FAB:**
- Bottom right position
- Extended with icon + label
- Opens dialog with all block types
- Icon + label for each type

---

## 🔒 Error Handling

### Load Errors
```dart
try {
  final page = await _service.loadDraft(...);
} catch (e) {
  // Show error SnackBar
  // Keep loading state false
}
```

### Save Errors
```dart
try {
  await _service.saveDraft(_page!);
  // Success notification
} catch (e) {
  // Error notification
}
```

### Publish Confirmation
```dart
final confirm = await showDialog<bool>(...);
if (confirm == true) {
  // Proceed with publish
}
```

---

## 📊 Block Configuration Details

### Field Types

**TextField:**
- Single line text
- Multi-line text (maxLines)
- Helper text support
- Real-time updates

**Dropdown:**
- Predefined options
- Current value displayed
- Change updates immediately

**Future Enhancements:**
- Image picker
- Color picker
- Product selector
- Rich text editor

---

## ✅ What's Complete

- [x] Page editor screen
- [x] Load draft (auto-create if missing)
- [x] Block list display
- [x] Add blocks (all types)
- [x] Remove blocks
- [x] Reorder blocks (drag & drop)
- [x] Select block
- [x] Configuration panel
- [x] Hero block config
- [x] Text block config
- [x] Product list config
- [x] Banner block config
- [x] Save draft
- [x] Publish workflow
- [x] Changes indicator
- [x] Error handling
- [x] Success notifications
- [x] Empty state
- [x] Loading state

---

## 🎯 Next Steps

With editor in place, the next phases are:

### Phase 1: Block Widgets ⏳
- Create rendering widgets for each block type
- Implement preview system
- Add to preview panel

### Phase 2: Enhanced Config ⏳
- Image picker for images
- Color picker for colors
- Product selector for products
- Rich text editor for content

### Phase 3: Preview Panel ⏳
- Real-time preview
- Device frames
- Responsive testing
- Side-by-side view

### Phase 4: Advanced Features ⏳
- Undo/redo
- Copy/paste blocks
- Block templates
- Keyboard shortcuts

---

## 📚 Import Usage

```dart
import 'package:pizza_delizza/builder/editor/editor.dart';
import 'package:pizza_delizza/builder/models/models.dart';

// Navigate to editor
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

---

**Created**: 2025-11-24  
**Status**: ✅ Editor complete and ready for block widgets/preview  
**Version**: 1.0
