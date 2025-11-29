# Builder B3 Fixes Applied

**Date:** 2024-11-29  
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

## Security Summary

No security vulnerabilities were introduced by these changes. The fixes are defensive in nature:
- Collision prevention adds safety, not removes it
- Explicit systemId handling prevents unintended privilege escalation
- pageKey-based operations are properly validated

---

**End of Fix Documentation**
