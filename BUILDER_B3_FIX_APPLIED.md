# Builder B3 Fixes Applied

**Date:** 2025-11-29  
**Based on:** BUILDER_B3_DEEP_AUDIT_REPORT.md  
**Author:** Flutter Architecture Fix Implementation

---

## Summary of Fixes Applied

This document describes the implementation of fixes for the critical issues identified in the Builder B3 Deep Audit Report.

---

## 1️⃣ FIX F1: _generatePageId() Collision Prevention

### Problem (FATAL)
Custom pages named "Menu", "Home", "Cart", or "Profile" would generate pageKey values that collide with system page IDs, causing custom pages to overwrite system pages.

### Solution Applied
**File:** `lib/builder/services/builder_page_service.dart`  
**Function:** `_generatePageId()` (lines ~1141-1162)

**Changes:**
```dart
/// Generate a unique pageId from a name
/// 
/// FIX F1: Prevents collision with system page IDs by adding unique suffix
/// If a generated ID matches a system page (home, menu, cart, profile, etc.),
/// we append a unique timestamp-based suffix to ensure no collision.
String _generatePageId(String name) {
  var processed = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  // Truncate to max 20 characters
  processed = processed.substring(0, processed.length > 20 ? 20 : processed.length);
  
  // FIX F1: COLLISION PREVENTION - Never allow custom pages to use system page IDs
  final potentialCollision = BuilderPageId.tryFromString(processed);
  if (potentialCollision != null) {
    // Add unique suffix to prevent collision with system pages
    final suffix = DateTime.now().millisecondsSinceEpoch % 100000;
    processed = 'custom_${processed}_$suffix';
    debugPrint('[BuilderPageService] ⚠️ Collision prevention: renamed to $processed');
  }
  
  return processed;
}
```

**Before:** "Menu" → `menu` (collides with system menu page)  
**After:** "Menu" → `custom_menu_12345` (unique, no collision)

---

## 2️⃣ FIX F2: Stop Deriving systemId from pageKey

### Problem (FATAL)
In `BuilderPage.fromJson()`, systemId was incorrectly inferred from pageKey using `BuilderPageId.tryFromString(rawPageId)`. This caused custom pages with names like "menu" to become system pages.

### Solution Applied
**File:** `lib/builder/models/builder_page.dart`  
**Function:** `fromJson()` (lines ~344-380)

**Changes:**
```dart
/// Create from Firestore JSON
/// 
/// FIX F2: systemId is NEVER inferred from pageKey
/// Only use explicit systemId field from Firestore. If missing, treat as custom page.
factory BuilderPage.fromJson(Map<String, dynamic> json) {
  // FIX F2: Extract pageKey (source of truth)
  final rawPageKey = json['pageKey'] as String? ?? json['pageId'] as String?;
  final pageKey = rawPageKey ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}';
  
  // FIX F2: NEVER derive systemId from pageKey
  // Only use EXPLICIT systemId field from Firestore
  BuilderPageId? systemId;
  final explicitSystemId = json['systemId'] as String?;
  if (explicitSystemId != null && explicitSystemId.isNotEmpty) {
    // Only set systemId if it was EXPLICITLY stored in Firestore
    systemId = BuilderPageId.tryFromString(explicitSystemId);
  } else {
    // Check if isSystemPage is explicitly true AND pageKey matches a known system page
    final isExplicitlySystemPage = json['isSystemPage'] as bool? ?? false;
    if (isExplicitlySystemPage) {
      systemId = BuilderPageId.tryFromString(pageKey);
    }
    // If not explicitly marked as system page, systemId stays null (custom page)
  }
  // ...
}
```

**Also Updated `toJson()`:**
```dart
Map<String, dynamic> toJson() {
  return {
    'pageKey': pageKey,
    'pageId': pageId?.toJson() ?? pageKey,
    'systemId': systemId?.toJson(), // FIX F2: Explicitly store systemId
    // ...
  };
}
```

**Before:** Custom page "menu" → systemId = `BuilderPageId.menu` (WRONG)  
**After:** Custom page "menu" → systemId = `null` (CORRECT, treated as custom)

---

## 3️⃣ FIX M1: Editor Handles Custom Pages Correctly

### Problem (MODERATE)
The editor's `_updateNavigationParams()` method required a `BuilderPageId` enum to modify navigation settings. Custom pages have null `pageId`/`systemId`, causing the error "Impossible de modifier une page personnalisée sans pageId".

### Solution Applied
**File:** `lib/builder/editor/builder_page_editor_screen.dart`  
**Function:** `_updateNavigationParams()` (lines ~711-832)

**Changes:**
```dart
/// Update navigation parameters using BuilderPageService
/// 
/// FIX M1: Handles both system pages (with pageId) and custom pages (with pageKey)
/// Custom pages no longer require a BuilderPageId enum to be modified.
Future<void> _updateNavigationParams({bool? isActive, int? bottomNavIndex}) async {
  if (_page == null) return;
  
  // FIX M1: Use pageKey for all pages (custom and system)
  // pageKey is ALWAYS non-null, unlike pageId/systemId which are null for custom pages
  final pageKey = _page!.pageKey;
  
  // Determine if this is a system page (has a valid systemId)
  final systemPageId = _page!.systemId ?? _page!.pageId;
  
  // ... validation logic ...
  
  try {
    BuilderPage updatedPage;
    
    // FIX M1: For system pages, use the enum-based method
    // For custom pages, use pageKey-based approach
    if (systemPageId != null) {
      // System page: use existing service method
      updatedPage = await _pageService.updatePageNavigation(
        pageId: systemPageId,
        appId: widget.appId,
        isActive: finalIsActive,
        bottomNavIndex: finalIsActive ? finalBottomNavIndex : null,
      );
    } else {
      // FIX M1: Custom page: update via layout service directly using pageKey
      final displayLocation = finalIsActive ? 'bottomBar' : 'hidden';
      final finalOrder = finalIsActive ? finalBottomNavIndex : 999;
      final finalNavIndex = finalIsActive ? finalBottomNavIndex : null;
      
      updatedPage = _page!.copyWith(
        isActive: finalIsActive,
        bottomNavIndex: finalNavIndex,
        displayLocation: displayLocation,
        order: finalOrder,
        updatedAt: DateTime.now(),
      );
      
      // Save to both draft and published
      await _service.saveDraft(updatedPage.copyWith(isDraft: true));
      
      if (await _service.hasPublished(widget.appId, pageKey)) {
        await _service.publishPage(
          updatedPage,
          userId: 'editor',
          shouldDeleteDraft: false,
        );
      }
    }
    // ...
  }
}
```

**Before:** Custom page navigation update → ERROR "Impossible de modifier..."  
**After:** Custom page navigation update → SUCCESS, uses pageKey directly

---

## Files Modified

| File | Changes |
|------|---------|
| `lib/builder/services/builder_page_service.dart` | FIX F1: Updated `_generatePageId()` to prevent collision with system page IDs |
| `lib/builder/models/builder_page.dart` | FIX F2: Updated `fromJson()` to not derive systemId from pageKey; Updated `toJson()` to explicitly store systemId |
| `lib/builder/editor/builder_page_editor_screen.dart` | FIX M1: Updated `_updateNavigationParams()` to handle custom pages using pageKey |

---

## How Each Fix Solves Each Audit Item

| Audit Item | Fix Applied | Resolution |
|------------|-------------|------------|
| F1: Custom page name collision | `_generatePageId()` adds unique suffix | Custom pages "Menu" → "custom_menu_12345", never overwrite system pages |
| F2: systemId incorrectly inferred | `fromJson()` uses explicit systemId field only | Custom pages remain custom even if pageKey matches system page name |
| M1: Editor failing on custom pages | `_updateNavigationParams()` uses pageKey for custom pages | No more "Impossible de modifier" error for custom pages |
| S3: Profile/Cart showing same content | F1 + F2 combined | No more collision between system and custom pages |
| S4: Route confusion | F2 fix ensures proper route calculation | System pages use `/menu`, custom pages use `/page/custom_menu_12345` |

---

## Testing Checklist

After applying these fixes, verify:

- [ ] **Creating custom pages** → produces `/page/...` without collisions
  - Create a page named "Menu" → should create `custom_menu_XXXXX`, NOT `menu`
  - Create a page named "Home" → should create `custom_home_XXXXX`, NOT `home`

- [ ] **System pages load correctly**
  - Home page shows correct content
  - Menu page shows correct content  
  - Profile page shows correct content
  - Cart page shows correct content

- [ ] **Builder shows pages correctly**
  - System pages show "Système" badge
  - Custom pages show "Personnalisée" badge
  - No mixing between system and custom

- [ ] **Editor modifies custom pages without errors**
  - Toggle active on custom page → works ✅
  - Change bottomNavIndex on custom page → works ✅
  - No "Impossible de modifier une page personnalisée sans pageId" error

- [ ] **Runtime loads correct pages**
  - /home loads system home page
  - /menu loads system menu page
  - /page/my_custom loads custom page
  - No duplication or wrong content

- [ ] **No more pageKey collisions**
  - Creating "Menu" custom page doesn't affect system menu
  - Creating "Profile" custom page doesn't affect system profile

- [ ] **No more systemId misclassification**
  - Custom page with pageKey "custom_menu_12345" has systemId = null
  - System page with pageKey "menu" has systemId = BuilderPageId.menu

- [ ] **No more "ghost pages"**
  - Deleted pages stay deleted
  - Draft/published sync works correctly

- [ ] **No fallback-to-home behavior**
  - Unknown routes show 404, not home page
  - Custom pages don't redirect to home

---

## Backward Compatibility Notes

1. **Existing custom pages** with pageKey matching system pages (e.g., "menu") will now be treated as custom pages (systemId = null) unless explicitly marked with `isSystemPage: true` in Firestore.

2. **New custom pages** will never collide with system pages due to the `custom_` prefix.

3. **Migration recommended**: Run a Firestore migration to add explicit `systemId` field to all existing system pages for data consistency.

---

## 4️⃣ FIX PAGES FANTÔMES / IDS / ROUTES / DRAFT-PUBLISHED

**Date:** 2025-11-29  
**Based on:** User feedback about ghost pages and draft/published desync

### Problem Summary

Users reported:
1. **Ghost pages**: Client shows correct content, Builder shows empty/default template
2. **Draft/Published desync**: Editor loading wrong data despite Firestore having correct content
3. **Empty publish overwrites**: Publishing empty layouts was silently replacing real content

### Root Cause Analysis

The `loadDraft()` method wasn't robust enough:
- Only checked `draftLayout` being non-empty, not `blocks` (legacy field)
- Self-heal from published only worked for `publishedLayout`, not `blocks`
- No migration from legacy `blocks` to new `draftLayout` field

### Solution Applied

#### 4.1 Enhanced `loadDraft()` with Robust Self-Healing

**File:** `lib/builder/services/builder_layout_service.dart`

**Changes:**
```dart
Future<BuilderPage?> loadDraft(String appId, dynamic pageId) async {
  // Priority order:
  // 1. If draft exists with draftLayout → use it
  // 2. If draft exists with blocks but empty draftLayout → migrate blocks to draftLayout
  // 3. If published exists with publishedLayout → create draft from it (self-heal)
  // 4. If published exists with blocks → create draft from blocks
  // 5. Otherwise → return empty draft or null
  
  // Detailed logging for every case
  debugPrint('📖 [loadDraft] Loading draft for appId=$appId, pageId=$pageIdStr');
  
  // Case 1b: Migrate legacy blocks to draftLayout
  if (draftPage.blocks.isNotEmpty) {
    debugPrint('📋 [loadDraft] Migrating ${draftPage.blocks.length} legacy blocks to draftLayout');
    final migratedPage = draftPage.copyWith(
      draftLayout: draftPage.blocks.toList(),
      hasUnpublishedChanges: true,
    );
    await saveDraft(migratedPage);
    return migratedPage;
  }
  // ... more cases
}
```

#### 4.2 Safe Publication with Empty Layout Protection

**File:** `lib/builder/services/builder_layout_service.dart`

**Changes:**
```dart
Future<void> publishPage(
  BuilderPage page, {
  required String userId,
  bool shouldDeleteDraft = false,
  bool allowEmptyPublish = false, // NEW: explicit flag for empty publish
}) async {
  // SAFETY CHECK: Prevent accidental empty publish
  if (!allowEmptyPublish && page.draftLayout.isEmpty) {
    final existingPublished = await loadPublished(page.appId, pageKey);
    if (existingPublished != null && existingPublished.publishedLayout.isNotEmpty) {
      throw StateError(
        'Cannot publish empty layout - would overwrite existing content. '
        'Set allowEmptyPublish=true to force empty publish.'
      );
    }
  }
  // ... rest of method
}
```

#### 4.3 Enhanced Editor Loading with Debug Logs

**File:** `lib/builder/editor/builder_page_editor_screen.dart`

**Changes:**
```dart
Future<void> _loadPage() async {
  debugPrint('📖 [EditorScreen] Loading page: $pageIdStr (appId: ${widget.appId})');
  
  if (page != null) {
    debugPrint('📖 [EditorScreen] Page loaded: ${page.name}');
    debugPrint('   - pageKey: ${page.pageKey}');
    debugPrint('   - systemId: ${page.systemId?.value ?? 'null (custom page)'}');
    debugPrint('   - route: ${page.route}');
    debugPrint('   - draftLayout: ${page.draftLayout.length} blocks');
    debugPrint('   - publishedLayout: ${page.publishedLayout.length} blocks');
    debugPrint('   - blocks (legacy): ${page.blocks.length} blocks');
    debugPrint('   - isSystemPage: ${page.isSystemPage}');
  }
  // ... rest of method
}
```

### Files Modified

| File | Changes |
|------|---------|
| `lib/builder/services/builder_layout_service.dart` | Enhanced `loadDraft()` with robust self-healing; Added `allowEmptyPublish` flag to `publishPage()`; Enhanced logging in `saveDraft()` and `loadPublished()` |
| `lib/builder/editor/builder_page_editor_screen.dart` | Enhanced `_loadPage()` with comprehensive debug logging |

### ID and Route Canonical Mapping

The following canonical mapping is enforced:

| Page Type | BuilderPageId | pageId (Firestore) | Firestore Doc ID | route |
|-----------|---------------|-------------------|------------------|-------|
| HOME | `BuilderPageId.home` | `"home"` | `pages_draft/home` | `/home` |
| MENU | `BuilderPageId.menu` | `"menu"` | `pages_draft/menu` | `/menu` |
| CART | `BuilderPageId.cart` | `"cart"` | `pages_draft/cart` | `/cart` |
| PROFILE | `BuilderPageId.profile` | `"profile"` | `pages_draft/profile` | `/profile` |
| CUSTOM | `null` | `"promo_noel"` | `pages_draft/promo_noel` | `/page/promo_noel` |

### How the Fix Resolves Each Issue

| Issue | Resolution |
|-------|------------|
| Ghost pages | Self-heal now handles both `publishedLayout` AND legacy `blocks` field |
| Empty editor | Migration from `blocks` to `draftLayout` is now automatic |
| Wrong content | Priority loading order ensures correct source is always used |
| Empty publish overwrites | New `allowEmptyPublish` flag prevents accidental data loss |

---

## Testing Checklist - Pages Fantômes Fix

After applying these fixes, verify:

### Draft/Published Sync
- [ ] **Open Home in Builder** → shows same content as client sees
- [ ] **Open Menu in Builder** → shows same content as client sees
- [ ] **Edit + Publish + Reopen** → same edited content persists
- [ ] **Empty draft + Published exists** → editor loads from published (self-heal)

### Detailed Logging
- [ ] Console shows `📖 [loadDraft]` when loading a page
- [ ] Console shows `💾 [saveDraft]` when saving
- [ ] Console shows `📤 [publishPage]` when publishing
- [ ] Console shows `✅ [SELF-HEAL]` if draft is created from published

### System Page Routes
- [ ] /home → loads system home page
- [ ] /menu → loads system menu page
- [ ] /cart → loads system cart page
- [ ] /profile → loads system profile page

### Custom Page Routes
- [ ] /page/{custom_key} → loads custom page correctly
- [ ] Creating "Menu" custom → creates `custom_menu_XXXXX` (not `/menu`)

### Empty Publish Protection
- [ ] Publishing empty layout on page with content → shows error (blocked)
- [ ] Publishing empty layout with `allowEmptyPublish=true` → succeeds

---

## Security Summary

No security vulnerabilities were introduced by these changes. The fixes are defensive in nature:
- Collision prevention adds safety, not removes it
- Explicit systemId handling prevents unintended privilege escalation
- pageKey-based operations are properly validated
- Empty publish protection prevents accidental data loss

---

**End of Fix Documentation**
