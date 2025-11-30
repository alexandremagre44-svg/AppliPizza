# Builder B3 System - Structured Audit Report

**Generated**: 2024-11-30  
**Purpose**: Complete overview for ChatGPT to determine stability, risks, missing pieces, and next steps

---

## Renderer & Registry

### builder_runtime_renderer.dart
**File Path**: `lib/builder/preview/builder_runtime_renderer.dart`

**Rendering Approach**:
- ✅ **Already delegates to BuilderBlockRuntimeRegistry** - No switch-case in renderer
- The `_buildBlock()` method calls `BuilderBlockRuntimeRegistry.render()` directly (line 283-287):
  ```dart
  Widget _buildBlock(BuilderBlock block, BuildContext context) {
    return BuilderBlockRuntimeRegistry.render(
      block,
      context,
      maxContentWidth: maxContentWidth,
    );
  }
  ```

**_applyGenericConfig Usage**:
- Applied in `_buildBlockSafe()` after building core widget (line 112)
- Handles: padding, margin, backgroundColor, borderRadius, elevation
- Parses padding from number, map, or CSV string formats

**_buildBlockSafe Usage**:
- Wraps all block rendering in try/catch (lines 106-124)
- Returns `_buildErrorFallback()` widget on any exception
- Logs errors with full stack trace in debug mode

**Error Fallback**:
- `_buildErrorFallback()` renders red container with error icon
- Shows block type label and error message
- Safe display even when blocks fail to render

### builder_block_runtime_registry.dart
**File Path**: `lib/builder/runtime/builder_block_runtime_registry.dart`

**BlockType → RuntimeWidget Mappings** (all 11 block types registered):

| BlockType | Runtime Widget | Status |
|-----------|---------------|--------|
| `hero` | `HeroBlockRuntime` | ✅ Registered |
| `text` | `TextBlockRuntime` | ✅ Registered |
| `banner` | `BannerBlockRuntime` | ✅ Registered |
| `productList` | `ProductListBlockRuntime` | ✅ Registered |
| `info` | `InfoBlockRuntime` | ✅ Registered |
| `spacer` | `SpacerBlockRuntime` | ✅ Registered |
| `image` | `ImageBlockRuntime` | ✅ Registered |
| `button` | `ButtonBlockRuntime` | ✅ Registered |
| `categoryList` | `CategoryListBlockRuntime` | ✅ Registered |
| `html` | `HtmlBlockRuntime` | ✅ Registered |
| `system` | `SystemBlockRuntime` | ✅ Registered (with maxContentWidth) |

**Missing Runtime Widgets**: None - All BlockType enum values have registered builders

**Import Verification**: All imports are present (lines 12-22)

---

## Models & Layout Pipeline

### BuilderPage
**File Path**: `lib/builder/models/builder_page.dart`

**Fields in Use Today**:

| Field | Type | Status | Purpose |
|-------|------|--------|---------|
| `draftLayout` | `List<BuilderBlock>` | ✅ Active | Editor working copy |
| `publishedLayout` | `List<BuilderBlock>` | ✅ Active | Client-visible content |
| `blocks` | `List<BuilderBlock>` | ⚠️ LEGACY | Marked deprecated (line 62-78) |
| `version` | `int` | ✅ Active | Version tracking |
| `pageKey` | `String` | ✅ Active | Primary identifier (Firestore doc ID) |
| `systemId` | `BuilderPageId?` | ✅ Active | System page identifier |

**Ordering Logic**:
- `sortedDraftBlocks` getter sorts by `block.order` (line 599-603)
- `sortedPublishedBlocks` getter sorts by `block.order` (line 606-610)
- `reorderDraftBlocks()` creates new list with updated order values (line 736-751)

**Deprecated Fields Still Referenced**:
- `blocks` field is still populated in `addBlock()`, `removeBlock()`, `updateBlock()`, `reorderBlocks()` methods (lines 628-733)
- Comment states: "maintained ONLY for backward compatibility during migration" (line 66)
- `blocks` is used as fallback in `_safeLayoutParse()` when draftLayout is empty (line 493-496)

**B2/V2 References**: None found in BuilderPage model

**reorderDraftBlocks() and updateDraftLayout() Usage**:
- `reorderDraftBlocks()` - Creates new draftLayout with updated order, sets `hasUnpublishedChanges: true` (line 736-751)
- `updateDraftLayout()` - Replaces entire draftLayout, increments version (line 777-784)
- Both used correctly in editor for block manipulation

**Preview Layout Selection** (in BuilderPageEditorScreen):
- Uses `_isShowingDraft` toggle to choose layout (lines 1203-1213):
  ```dart
  if (_isShowingDraft) {
    layout = _page!.draftLayout.isNotEmpty ? _page!.draftLayout : _page!.publishedLayout;
  } else {
    layout = _page!.publishedLayout.isNotEmpty ? _page!.publishedLayout : _page!.draftLayout;
  }
  ```
- Falls back to opposite layout if preferred is empty

---

## Editor (UI)

### builder_page_editor_screen.dart
**File Path**: `lib/builder/editor/builder_page_editor_screen.dart`

**How Blocks Are Displayed**:
- Uses `ReorderableListView.builder` for drag-and-drop (line 1256)
- Each block rendered as `Card` with `ListTile` showing icon, label, summary
- Selected block highlighted with `primaryContainer` color and border
- Block summary via `_getBlockSummary()` helper

**Block Selection**:
- `_selectBlock(BuilderBlock block)` sets `_selectedBlock` state (line 491-493)
- Tapping a block in list triggers selection
- Selection indicated by background color and border styling

**Properties Panel Connection**:
- Three-tab layout: Page / Block / Nav (line 1039-1046)
- `_buildBlockPropertiesTab()` renders config fields for `_selectedBlock`
- `_buildConfigFields()` switches on block type to render appropriate fields
- Fields call `_updateBlockConfig(key, value)` on change

**Add/Remove/Update Block Actions**:
- `_addBlock(BlockType type)` - Creates new block with default config, adds to page (line 328-344)
- `_addSystemBlock(String moduleType)` - Creates SystemBlock for modules (line 3344-3360)
- `_removeBlock(String blockId)` - Calls `page.removeBlock()`, clears selection if removed (line 457-468)
- `_updateBlockConfig(key, value)` - Uses `block.updateConfig()`, updates page (line 497-508)

**draftLayout Modification Points**:
- All modifications go through `page.addBlock()`, `page.removeBlock()`, `page.updateBlock()`, `page.reorderBlocks()`
- These methods update BOTH `blocks` (legacy) and `draftLayout` fields
- Auto-save triggered via `_scheduleAutoSave()` after each modification

**V2 Widgets Referenced**: None found - no references to V2 widget imports

---

## Page List & Navigation

### builder_page_list_screen.dart
**File Path**: `lib/builder/page_list/builder_page_list_screen.dart`

**System Pages vs Custom Pages Loading**:
- `_loadPages()` loads both draft and published pages (lines 47-79)
- Uses `_layoutService.loadAllDraftPages()` and `loadAllPublishedPages()`
- Merges pages preferring draft over published
- Both system and custom pages loaded from same collections

**pageKey/systemId/route Logic Consistency**:
- `_editPage()` passes both `pageId` (systemId/pageId for system) and `pageKey` (lines 510-520)
- `_toggleActive()` uses `page.pageKey` for all pages (line 529)
- `_setBottomNavOrder()` uses `page.pageKey` for service call (line 594)
- Route displayed from `page.route` field in card UI

**Hardcoded Routes or Assumptions**:
- No hardcoded routes in this file
- Routes come from page.route field
- Navigation handled via service methods

---

## Runtime Widgets

### Block Runtime Widget Files

| Block Type | File Path | Status |
|------------|-----------|--------|
| `hero` | `lib/builder/blocks/hero_block_runtime.dart` | ✅ Exists |
| `text` | `lib/builder/blocks/text_block_runtime.dart` | ✅ Exists |
| `banner` | `lib/builder/blocks/banner_block_runtime.dart` | ✅ Exists |
| `productList` | `lib/builder/blocks/product_list_block_runtime.dart` | ✅ Exists |
| `info` | `lib/builder/blocks/info_block_runtime.dart` | ✅ Exists |
| `spacer` | `lib/builder/blocks/spacer_block_runtime.dart` | ✅ Exists |
| `image` | `lib/builder/blocks/image_block_runtime.dart` | ✅ Exists |
| `button` | `lib/builder/blocks/button_block_runtime.dart` | ✅ Exists |
| `categoryList` | `lib/builder/blocks/category_list_block_runtime.dart` | ✅ Exists |
| `html` | `lib/builder/blocks/html_block_runtime.dart` | ✅ Exists |
| `system` | `lib/builder/blocks/system_block_runtime.dart` | ✅ Exists |

**BlockTypes Without Runtime Widget**: None - All 11 BlockType enum values have corresponding runtime widgets

---

## Stability Issues

### Null-Safety Risks

1. **Nullable Config Access** (Low Risk)
   - `block.getConfig<T>(key, defaultValue)` returns `T?` and most usages provide default
   - Example: `helper.getString('title', defaultValue: 'Hero Title')` in HeroBlockRuntime

2. **Firestore Parsing Fallbacks** (Medium Risk - Well Handled)
   - `_safeLayoutParse()` in BuilderPage handles null, List, Map (numeric keys), String
   - `safeParseDateTime()` helper for Timestamp/String/null
   - All parsing wrapped in try/catch with fallback returns

### Try/Catch Around Runtime Rendering

| Location | Coverage |
|----------|----------|
| `BuilderRuntimeRenderer._buildBlockSafe()` | ✅ Full try/catch with fallback |
| `SystemBlockRuntime._buildModuleWidgetSafe()` | ✅ Full try/catch with fallback |
| `BuilderPage._safeLayoutParse()` | ✅ Per-block try/catch (skips bad blocks) |
| `BuilderBlock.fromJson()` | ✅ Full try/catch with fallback block |

### Heavy Rebuild Patterns (Drag-and-Drop Risk)

1. **ReorderableListView** (Low Risk)
   - Uses `ValueKey(block.id)` for stable identification
   - setState calls are minimal - only updates order

2. **Auto-Save Timer** (Low Risk)
   - 2-second delay before auto-save
   - Cancels pending timer on new changes
   - Non-blocking async save

3. **Preview Rebuild** (Medium Risk)
   - Full preview rebuilds on any block change
   - `BuilderPagePreview` recreates all block widgets
   - Could be optimized with selective rebuild

### Firestore Parsing Fallback Chains

**BuilderPage.fromJson() Fallback Priority**:
1. `draftLayout` field
2. `publishedLayout` field
3. `blocks` field (legacy)
4. `layout` field (legacy)
5. `content` field (legacy)
6. `sections` field (legacy)
7. `pageBlocks` field (legacy)

Logged with `[B3-LAYOUT-MIGRATION]` prefix when using legacy fallbacks

### Legacy Fields Overriding draftLayout/publishedLayout

**Risk Areas**:
1. `addBlock()`, `removeBlock()`, `updateBlock()` update BOTH `blocks` and `draftLayout` (intentional for migration)
2. `fromJson()` uses `blocks` as fallback if `draftLayout` empty (intentional fallback)
3. No cases where legacy overrides new fields unexpectedly

**systemId vs pageId Collision Prevention**:
- `_generatePageId()` in BuilderPageService adds unique suffix if name matches system page ID (line 1132-1150)
- Custom pages explicitly set `systemId: null`

---

## Summary

### Stability Status: ✅ STABLE

**Strengths**:
- Registry-based block rendering (extensible, single source of truth)
- Comprehensive error handling throughout rendering pipeline
- Well-structured fallback chains for Firestore data migration
- Clear separation between draft and published layouts

**Active Migration**:
- `blocks` field maintained for backward compatibility
- Legacy Firestore field names still parsed as fallback
- Self-heal logic in loadDraft() creates drafts from published

**Recommended Next Steps**:
1. Monitor legacy field usage - plan deprecation timeline
2. Consider memoizing preview widget builds
3. Add telemetry for fallback chain triggers to track migration progress
