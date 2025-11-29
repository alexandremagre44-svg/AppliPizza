# 🔬 BUILDER B3 DEEP AUDIT REPORT

**Date:** 2025-11-29  
**Purpose:** Forensic code audit to identify root cause of Editor/App desynchronization bug  
**Symptom:** App displays content correctly but Editor shows "Empty Page" / No Blocks

---

## 💥 1. DATA MISMATCH ANALYSIS (Producer vs Consumer)

### 1.1 PRODUCERS ANALYZED

#### Producer 1: `BuilderNavigationService._getDefaultBlocksForPage`
**Location:** `lib/builder/services/builder_navigation_service.dart` (lines 209-277)

#### Producer 2: `BuilderPageService.fixEmptySystemPages`
**Location:** `lib/builder/services/builder_page_service.dart` (lines 727-878)

### 1.2 CONSUMERS ANALYZED

#### Consumer 1: `HeroBlockRuntime`
**Location:** `lib/builder/blocks/hero_block_runtime.dart`

#### Consumer 2: `ProductListBlockRuntime`
**Location:** `lib/builder/blocks/product_list_block_runtime.dart`

---

### 1.3 CONFIG KEY MISMATCH TABLE: HERO BLOCK

| Field | Producer 1 (NavigationService) | Producer 2 (PageService) | Consumer (HeroBlockRuntime) | ❌ MISMATCH? |
|-------|-------------------------------|--------------------------|----------------------------|-------------|
| **Button Label** | `buttonLabel` ✅ | `buttonLabel` ✅ | Reads `buttonText` first, fallback `buttonLabel` | ⚠️ NO (has fallback) |
| **Tap Action** | `tapAction: Map { type, value }` | `tapAction: String` + `tapActionTarget: String` | Reads `getActionConfig()` which expects separate fields | ⚠️ POTENTIAL ISSUE |
| **Title** | `title` ✅ | `title` ✅ | `title` ✅ | ✅ OK |
| **Subtitle** | `subtitle` ✅ | `subtitle` ✅ | `subtitle` ✅ | ✅ OK |
| **Image URL** | `imageUrl` ✅ | `imageUrl` ✅ | `imageUrl` ✅ | ✅ OK |

#### Critical Tap Action Format Differences:

**Producer 1 (NavigationService line 225-226):**
```dart
'tapAction': {'type': 'openPage', 'value': '/menu'},
```

**Producer 2 (PageService line 785-786):**
```dart
'tapAction': 'openPage',
'tapActionTarget': '/menu',
```

**Consumer (HeroBlockRuntime lines 57-60):**
```dart
var tapActionConfig = helper.getActionConfig();  // Expects separate fields
tapActionConfig ??= block.config['tapAction'] as Map<String, dynamic>?;  // Fallback to Map
```

- [ ] **ISSUE FOUND:** Producer 1 uses a Map format `{'type': 'openPage', 'value': '/menu'}` for `tapAction`
- [x] Producer 2 uses separate String fields `tapAction` + `tapActionTarget` (matches BlockConfigHelper)
- [x] Consumer has fallback logic that handles BOTH formats

**VERDICT:** The HeroBlockRuntime handles both formats via fallback. **NOT the root cause of empty editor.**

---

### 1.4 CONFIG KEY MISMATCH TABLE: PRODUCT LIST BLOCK

| Field | Producer 1 (NavigationService) | Producer 2 (PageService) | Consumer (ProductListBlockRuntime) | ❌ MISMATCH? |
|-------|-------------------------------|--------------------------|-----------------------------------|-------------|
| **Title** | `title` ✅ | `title` ✅ | `title` ✅ | ✅ OK |
| **Mode** | `mode` ✅ | `mode` ✅ | `mode` ✅ | ✅ OK |
| **Layout** | `layout` ✅ | `layout` ✅ | `layout` ✅ | ✅ OK |
| **Limit** | `limit` ✅ | `limit` ✅ | `limit` ✅ | ✅ OK |
| **Columns** | `columns` ✅ | `columns` ✅ | NOT READ | ⚠️ Unused field (not a bug) |

**VERDICT:** ProductListBlock config is consistent. **NOT the root cause.**

---

## 🕵️ 2. PARSING LOGIC AUDIT

### 2.1 BuilderBlock.fromJson Analysis
**Location:** `lib/builder/models/builder_block.dart` (lines 113-162)

#### Critical Questions Answered:

**Q: Does it strictly require a Map for config?**  
**A: NO.** The parsing is crash-proof:

```dart
// Self-contained config parsing - bulletproof against nested maps
Map<String, dynamic> configMap = {};
try {
  final raw = json['config'];
  if (raw is Map) {
    configMap = Map<String, dynamic>.from(raw);
  } else if (raw is String) {
    configMap = Map<String, dynamic>.from(jsonDecode(raw));  // ✅ Handles JSON-encoded String
  }
} catch (e) {
  print('⚠️ Config parsing error: $e');
  // Do not throw, keep empty configMap  ✅ Crash-proof
}
```

- [x] Handles `Map<String, dynamic>` ✅
- [x] Handles JSON-encoded `String` ✅  
- [x] Handles `null` ✅ (returns empty map)
- [x] **Never throws** - catches all errors ✅

**Q: If a block fails to parse, is it dropped or replaced by an error placeholder?**  
**A: REPLACED WITH FALLBACK BLOCK.**

```dart
} catch (e) {
  // Log warning but return a valid Block with empty config to prevent crashes
  print('⚠️ Warning: Error parsing block, returning fallback block: $e');
  final fallbackId = 'block_fallback_${DateTime.now().millisecondsSinceEpoch}';
  return BuilderBlock(
    id: fallbackId,
    type: BlockType.text,  // ⚠️ Fallback to text type
    order: 0,
    config: configMap, // Use whatever config we managed to parse
  );
}
```

- [ ] **ISSUE FOUND:** Failed blocks become fallback `text` blocks with empty config, NOT dropped silently.
- [ ] **WARNING:** If many blocks fail parsing, the editor will show multiple empty text blocks, NOT "Empty Page".

**VERDICT:** Block parsing is robust. **NOT the root cause of empty editor.**

---

### 2.2 SystemBlock.fromJson Analysis
**Location:** `lib/builder/models/builder_block.dart` (lines 320-369)

Same crash-proof logic as BuilderBlock. **NOT the root cause.**

---

## 👻 3. DRAFT/PUBLISHED SYNC CHECK

### 3.1 BuilderPage.fromJson Analysis
**Location:** `lib/builder/models/builder_page.dart` (lines 345-448)

#### Critical Question: Is there explicit logic to copy publishedLayout into draftLayout if draft is empty/null?

**A: YES.** Lines 373-378 contain the fix:

```dart
// Fix 'Ghost Content': If draft is empty but published has content, sync them to avoid blank editor
if (draftLayout.isEmpty && publishedLayout.isNotEmpty) {
  draftLayout = List<BuilderBlock>.from(publishedLayout);
} else if (draftLayout.isEmpty && blocks.isNotEmpty) {
  // Fallback for legacy data: if both draft and published are empty but blocks has content
  draftLayout = List<BuilderBlock>.from(blocks);
}
```

#### 🔍 Layout Field Parsing Logic:

```dart
// Parse blocks (legacy field)
final blocks = _safeLayoutParse(json['blocks']);

// Parse draftLayout (new field, fallback to blocks for backward compatibility)
final draftLayoutRaw = json['draftLayout'];
var draftLayout = draftLayoutRaw != null 
    ? _safeLayoutParse(draftLayoutRaw)
    : blocks;  // ⚠️ Falls back to legacy 'blocks' field

// Parse publishedLayout (new field)
final publishedLayout = _safeLayoutParse(json['publishedLayout']);
```

- [x] If `draftLayout` field exists in JSON → parse it
- [x] If `draftLayout` is null → fallback to `blocks` field
- [x] If both are empty but `publishedLayout` has content → copy from published
- [x] If both are empty but `blocks` has content → copy from blocks

### 3.2 _safeLayoutParse Analysis
**Location:** `lib/builder/models/builder_page.dart` (lines 287-342)

**Critical: Handles legacy string values like "none":**

```dart
// For any other type (String like "none", etc.), return empty list
// This handles legacy data where draftLayout/publishedLayout might be stored as strings
if (value is String) {
  print('⚠️ Legacy string value found in layout field: "$value". Returning empty list.');
} else {
  print('⚠️ Warning: Unexpected layout field type: ${value.runtimeType}. Returning empty list.');
}
return [];
```

- [ ] **ISSUE FOUND:** If Firestore stores `draftLayout: "none"` or any other string, it returns **empty list** instead of parsing as JSON.
- [ ] This could cause blocks to be silently dropped if the producer writes string values like `"none"` or `"[]"` instead of actual arrays.

---

### 3.3 BuilderLayoutService.loadDraft Analysis
**Location:** `lib/builder/services/builder_layout_service.dart` (lines 155-200)

**Critical fallback logic:**

```dart
// Case 1: Draft exists and has content
if (snapshot.exists && snapshot.data() != null) {
  final draftPage = BuilderPage.fromJson(snapshot.data() as Map<String, dynamic>);
  
  // Check if draft has meaningful content in draftLayout
  if (draftPage.draftLayout.isNotEmpty) {
    return draftPage;
  }
  
  // Draft exists but draftLayout is empty - try to sync from published
  debugPrint('⚠️ Draft exists but draftLayout is empty..., checking published...');
}

// Case 2: Draft doesn't exist or has empty draftLayout - try published version
final publishedPage = await loadPublished(appId, pageId);
if (publishedPage != null && publishedPage.publishedLayout.isNotEmpty) {
  debugPrint('📋 Creating draft from published content...');
  return publishedPage.copyWith(
    isDraft: true,
    draftLayout: publishedPage.publishedLayout.toList(),  // ✅ Syncs from published
    hasUnpublishedChanges: false,
  );
}
```

- [x] Service-level fallback: Creates draft from published if draft is empty
- [x] Double safety: Both `fromJson` AND `loadDraft` have sync logic

**VERDICT:** Sync logic exists at two levels. **Likely NOT the root cause if system works correctly.**

---

## 🧟 4. NAVIGATION LOGIC CHECK

### 4.1 getBottomBarPages Analysis
**Location:** `lib/builder/services/builder_navigation_service.dart` (lines 59-91)

```dart
Future<List<BuilderPage>> getBottomBarPages() async {
  try {
    // Step 1: Load ALL system pages (active AND inactive)
    final allSystemPages = await _layoutService.loadSystemPages(appId);
    
    // Step 2: Strict check - only trigger auto-init if truly empty
    if (allSystemPages.isEmpty) {
      await _ensureMinimumPages(allSystemPages);
    }
    
    // Step 3: Always fix empty system pages by injecting default content
    await _pageService.fixEmptySystemPages(appId);
    
    // Step 4: Return ONLY active pages for the UI
    final pages = await _layoutService.getBottomBarPages(appId: appId);
    
    return pages;
  } catch (e, stackTrace) {
    debugPrint('[BuilderNavigationService] Error loading bottom bar pages: $e');
    return [];
  }
}
```

#### Critical Question: Does it filter using pages_system (static) or loadAllPublishedPages (dynamic)?

**A:** It uses `_layoutService.loadSystemPages()` which NOW queries from `loadAllPublishedPages()`:

```dart
// Location: builder_layout_service.dart (lines 619-637)
Future<List<BuilderPage>> loadSystemPages(String appId) async {
  try {
    // Query from published pages - the source of truth
    final publishedPages = await loadAllPublishedPages(appId);
    
    // Filter to return only pages where isSystemPage == true
    final systemPages = publishedPages.values
        .where((page) => page.isSystemPage)
        .toList();
    
    return systemPages;
  } catch (e) {
    debugPrint('Error loading system pages: $e');
    return [];
  }
}
```

- [x] Uses **dynamic** `loadAllPublishedPages()` as source of truth
- [x] Filters by `isSystemPage == true`
- [x] No static/stale data from `pages_system` collection

#### Critical Question: Is there a hardcoded check (e.g., < 2 pages) that forces regeneration?

**A: YES.** Located in `_ensureMinimumPages()`:

```dart
// Location: builder_navigation_service.dart (lines 95-165)
Future<List<BuilderPage>> _ensureMinimumPages(List<BuilderPage> currentPages) async {
  if (currentPages.length >= 2) {
    return currentPages;  // ⚠️ Hardcoded threshold of 2 pages
  }
  
  // Check if auto-init was already done
  final isAlreadyDone = await _autoInitService.isAutoInitDone(appId);
  if (isAlreadyDone) {
    debugPrint('[BuilderNavigationService] Auto-init already done, returning current pages');
    return currentPages;
  }

  debugPrint('[BuilderNavigationService] 🚀 Creating default navigation pages');
  // ... creates 4 default pages (home, menu, cart, profile)
}
```

- [ ] **ISSUE FOUND:** `currentPages.length >= 2` hardcoded threshold
- [x] Protected by `isAutoInitDone` flag to prevent re-triggering
- [x] Only triggers if `allSystemPages.isEmpty` (strict check at line 67)

**VERDICT:** Navigation logic is sound. Auto-init only triggers once. **NOT the root cause.**

---

## 📋 5. ROOT CAUSE HYPOTHESIS

Based on the forensic analysis, the "Empty Page" in Editor likely stems from one of these scenarios:

### Hypothesis A: Firestore Data Format Issues
- [ ] **CHECK:** Are `draftLayout` and `publishedLayout` stored as strings (e.g., `"none"`, `"[]"`) instead of arrays?
- [ ] The `_safeLayoutParse` silently returns empty list for string values

### Hypothesis B: Missing `draftLayout` Field
- [ ] **CHECK:** Do auto-created pages have `draftLayout` populated in Firestore?
- [ ] If `draftLayout` is null/missing AND `blocks` is also empty, the page will be empty

### Hypothesis C: Race Condition in Editor Load
- [ ] **CHECK:** Is the editor loading a page before `fixEmptySystemPages()` completes?
- [ ] The fix runs asynchronously during `getBottomBarPages()` but editor might load via different path

### Hypothesis D: Blocks Field vs DraftLayout Desync
- [ ] **CHECK:** Are some producers populating `blocks` but not `draftLayout`?

**DefaultPageCreator._buildDefaultBlocks():**
```dart
// Location: default_page_creator.dart (lines 140-145)
return BuilderPage(
  ...
  blocks: _buildDefaultBlocks(pageId),  // ✅ Populates blocks
  // ⚠️ Note: Does NOT explicitly set draftLayout or publishedLayout
);
```

The BuilderPage constructor handles this:
```dart
draftLayout = draftLayout ?? blocks,  // Falls back to blocks
publishedLayout = publishedLayout ?? const [],
```

So `draftLayout` should be populated from `blocks`. **Likely NOT the issue.**

---

## ✅ 6. VERIFICATION CHECKLIST

To confirm root cause, verify these in Firestore:

- [ ] Check if `draftLayout` field exists and is an Array (not String)
- [ ] Check if `publishedLayout` field exists and is an Array (not String)
- [ ] Check if `blocks` field exists as fallback
- [ ] Check `pages_draft` collection has documents for system pages
- [ ] Check `pages_published` collection has documents for system pages
- [ ] Compare timestamps between draft and published documents

---

## 🔧 7. RECOMMENDED FIXES

### Fix 1: Add Firestore Data Validation
Add a migration/validation function that checks all pages for string-type layout fields and converts them to arrays.

### Fix 2: Defensive Parsing for String Arrays
In `_safeLayoutParse`, handle JSON-encoded array strings:
```dart
if (value is String) {
  try {
    final decoded = jsonDecode(value);
    if (decoded is List) {
      // Recursively parse the decoded list
      return _safeLayoutParse(decoded);
    }
  } catch (_) {
    // Not valid JSON, return empty
  }
  return [];
}
```

### Fix 3: Ensure Editor Uses Correct Loading Path
Verify the editor screen calls `loadDraft()` which has the fallback logic, not a direct Firestore read.

### Fix 4: Add Debug Logging for Empty Layouts
Add explicit logging when layouts are empty after parsing to aid debugging:
```dart
if (draftLayout.isEmpty && publishedLayout.isEmpty && blocks.isEmpty) {
  debugPrint('⚠️ ALL LAYOUTS EMPTY for page: ${json['pageKey']}');
}
```

---

## 📊 8. SUMMARY

| Component | Status | Root Cause Likelihood |
|-----------|--------|----------------------|
| Config Key Mismatches | ⚠️ Minor differences with fallbacks | LOW |
| Block Parsing Logic | ✅ Robust with fallbacks | LOW |
| Draft/Published Sync | ✅ Has sync logic at 2 levels | LOW |
| Navigation Logic | ✅ Uses dynamic source | LOW |
| Firestore Data Format | ⚠️ Potential string vs array issue | **HIGH** |
| Default Page Creation | ⚠️ Relies on constructor defaults | MEDIUM |

**Most Likely Root Cause:** Firestore documents have malformed `draftLayout` field (stored as string or missing entirely), causing `_safeLayoutParse` to return empty array.

**Recommended Action:** 
1. Inspect actual Firestore documents for affected pages
2. Add data migration to fix any string-type layout fields
3. Add defensive JSON string parsing in `_safeLayoutParse`
