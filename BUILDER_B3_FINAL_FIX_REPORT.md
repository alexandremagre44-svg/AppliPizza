# Builder B3 Final Fix Report

**Date:** 2025-11-29  
**Based on:** BUILDER_B3_DEEP_AUDIT_REPORT.md & BUILDER_B3_FIX_APPLIED.md  
**Author:** Flutter Architecture Fix Implementation (Final)

---

## Summary

This document provides a complete summary of all Builder B3 fixes that have been applied to address the issues identified in the deep audit report.

---

## Fixes Verified as Already Applied

### ✅ FIX F1: _generatePageId() Collision Prevention
**File:** `lib/builder/services/builder_page_service.dart` (lines 1131-1149)

**Status:** Already correctly implemented

**Description:** The `_generatePageId()` function prevents collision with system page IDs by adding a unique timestamp-based suffix when the generated ID matches a system page.

```dart
// FIX F1: COLLISION PREVENTION - Never allow custom pages to use system page IDs
final potentialCollision = BuilderPageId.tryFromString(processed);
if (potentialCollision != null) {
  final suffix = DateTime.now().millisecondsSinceEpoch % 100000;
  processed = 'custom_${processed}_$suffix';
  debugPrint('[BuilderPageService] ⚠️ Collision prevention: renamed to $processed');
}
```

**Before:** "Menu" → `menu` (collides with system menu page)  
**After:** "Menu" → `custom_menu_12345` (unique, no collision)

---

### ✅ FIX F2: Stop Deriving systemId from pageKey
**File:** `lib/builder/models/builder_page.dart` (lines 351-372)

**Status:** Already correctly implemented

**Description:** `fromJson()` no longer derives `systemId` from `pageKey`. It only uses the explicit `systemId` field from Firestore, or falls back to checking `isSystemPage: true` flag.

```dart
// FIX F2: NEVER derive systemId from pageKey
// Only use EXPLICIT systemId field from Firestore
BuilderPageId? systemId;
final explicitSystemId = json['systemId'] as String?;
if (explicitSystemId != null && explicitSystemId.isNotEmpty) {
  systemId = BuilderPageId.tryFromString(explicitSystemId);
} else {
  final isExplicitlySystemPage = json['isSystemPage'] as bool? ?? false;
  if (isExplicitlySystemPage) {
    systemId = BuilderPageId.tryFromString(pageKey);
  }
}
```

**Before:** Custom page "menu" → systemId = `BuilderPageId.menu` (WRONG)  
**After:** Custom page "menu" → systemId = `null` (CORRECT, treated as custom)

---

### ✅ FIX M1: Editor Handles Custom Pages Correctly
**File:** `lib/builder/editor/builder_page_editor_screen.dart` (lines 714-861)

**Status:** Already correctly implemented

**Description:** `_updateNavigationParams()` now handles both system pages (with pageId) and custom pages (with pageKey) without errors.

```dart
// FIX M1: For system pages, use the enum-based method
// For custom pages, use pageKey-based approach
if (systemPageId != null) {
  updatedPage = await _pageService.updatePageNavigation(...);
} else {
  // FIX M1: Custom page: update via layout service directly using pageKey
  updatedPage = _page!.copyWith(...);
  await _service.saveDraft(updatedPage.copyWith(isDraft: true));
  ...
}
```

**Before:** Custom page navigation update → ERROR "Impossible de modifier..."  
**After:** Custom page navigation update → SUCCESS, uses pageKey directly

---

### ✅ FIX S1: Draft/Published Sync with Persistent Self-Heal
**File:** `lib/builder/services/builder_layout_service.dart` (lines 159-213)

**Status:** Already correctly implemented

**Description:** When draft is empty but published has content, the code self-heals by copying `publishedLayout` to draft AND persists it to Firestore.

```dart
// CRITICAL: Persist to Firestore immediately (draft only, NEVER publish)
try {
  await saveDraft(newDraft);
  debugPrint('✅ [SELF-HEAL] Draft persisted to pages_draft/$pageIdStr');
} catch (saveError) {
  debugPrint('⚠️ [SELF-HEAL] Failed to persist draft: $saveError');
}
```

---

## New Fixes Applied in This Update

### ✅ FIX F3/N1 (Fix 6): Reserved ID Validation & Remove System Templates
**File:** `lib/builder/page_list/new_page_dialog_v2.dart`

**Changes:**
1. Removed system page templates from `availableTemplates`:
   - `cart_template` (removed)
   - `profile_template` (removed)
   - `roulette_template` (removed)

2. Added informational note in blank page form about automatic renaming when page name matches a system page.

**Reason:** These templates suggested creating system pages which could cause collision/confusion. System pages (cart, profile, roulette) should only be edited, not created from templates.

---

### ✅ FIX M2/N2: SystemBlock.availableModules Updated
**File:** `lib/builder/models/builder_block.dart`

**Changes:** Added missing modules to `availableModules`:
- `menu_catalog`
- `cart_module`
- `profile_module`
- `roulette_module` (alias for 'roulette')

Also updated `getModuleLabel()` and `getModuleIcon()` to handle the new module types.

```dart
static const List<String> availableModules = [
  'roulette',
  'loyalty',
  'rewards',
  'accountActivity',
  // FIX M2/N2: Added modules that are defined in builder_modules.dart
  'menu_catalog',
  'cart_module',
  'profile_module',
  'roulette_module',
];
```

---

### ✅ FIX M3: Align isSystemPage with SystemPages Registry
**Files:** 
- `lib/builder/models/builder_enums.dart`
- `lib/builder/models/system_pages.dart`

**Changes:**
1. Updated `BuilderPageId.isSystemPage` getter to delegate to `SystemPages.getConfig()` for consistent behavior.
2. Added missing pages (promo, about, contact) to `SystemPages._registry` with `isSystemPage: false`.

**New behavior:**
- Protected system pages (cart, profile, rewards, roulette) → `isSystemPage: true`
- Content pages (home, menu, promo, about, contact) → `isSystemPage: false`

```dart
bool get isSystemPage {
  final config = SystemPages.getConfig(this);
  if (config != null) {
    return config.isSystemPage;
  }
  return false;
}
```

---

### ✅ FIX M4: Legacy pages_system Methods Deprecated
**File:** `lib/builder/services/builder_layout_service.dart`

**Changes:** Marked legacy methods as `@Deprecated`:
- `loadSystemPage()` - Use `loadPublished()` instead
- `watchSystemPages()` - Use pages_published collection instead

The `pages_system` collection is being phased out. All page data now lives in `pages_published` collection.

---

## Files Modified

| File | Changes |
|------|---------|
| `lib/builder/page_list/new_page_dialog_v2.dart` | FIX F3/N1: Removed system templates, added reserved ID info note |
| `lib/builder/models/builder_block.dart` | FIX M2/N2: Added missing modules to availableModules |
| `lib/builder/models/builder_enums.dart` | FIX M3: Updated isSystemPage to use SystemPages registry |
| `lib/builder/models/system_pages.dart` | FIX M3: Added promo, about, contact pages to registry |
| `lib/builder/services/builder_layout_service.dart` | FIX M4: Deprecated legacy pages_system methods |

---

## How Each Fix Solves Each Audit Item

| Audit Item | Fix Applied | Resolution |
|------------|-------------|------------|
| F1: Custom page name collision | `_generatePageId()` adds unique suffix | Custom pages "Menu" → "custom_menu_12345", never overwrite system pages |
| F2: systemId incorrectly inferred | `fromJson()` uses explicit systemId field only | Custom pages remain custom even if pageKey matches system page name |
| F3: No reserved ID validation | Removed system templates + info note | Prevents confusion; collision is handled by F1 at service layer |
| S1: Draft/Published sync | Self-heal persists to Firestore | No more "Home empty in builder but ok in client" |
| S2/S4: Multiple sources of truth | pageKey as primary, systemId only when explicit | Consistent route resolution: system → `/menu`, custom → `/page/custom_menu_12345` |
| S3: Profile/Cart showing same content | F1 + F2 combined | No more collision between system and custom pages |
| M1: Editor failing on custom pages | `_updateNavigationParams()` uses pageKey for custom pages | No more "Impossible de modifier" error |
| M2/N2: SystemBlock modules incomplete | Added menu_catalog, cart_module, profile_module | All modules defined in builder_modules.dart are now recognized |
| M3: isSystemPage mismatch | Aligned with SystemPages registry | Single source of truth for isSystemPage check |
| M4: Legacy pages_system usage | Deprecated loadSystemPage/watchSystemPages | Clear migration path to pages_published |
| N1: System templates visible | Removed cart/profile/roulette templates | Users can't accidentally create system pages from templates |

---

## Testing Checklist

After applying these fixes, verify:

### Page Creation
- [ ] **Creating custom pages** → produces `/page/...` without collisions
  - Create a page named "Menu" → should create `custom_menu_XXXXX`, NOT `menu`
  - Create a page named "Home" → should create `custom_home_XXXXX`, NOT `home`
- [ ] **Template list** does not include cart, profile, roulette templates
- [ ] **Blank page form** shows info note about reserved ID handling

### System Pages
- [ ] Home page shows correct content and has `isSystemPage: false`
- [ ] Menu page shows correct content and has `isSystemPage: false`
- [ ] Profile page shows correct content and has `isSystemPage: true`
- [ ] Cart page shows correct content and has `isSystemPage: true`
- [ ] Rewards page shows correct content and has `isSystemPage: true`
- [ ] Roulette page shows correct content and has `isSystemPage: true`

### Builder Display
- [ ] System pages show "Système" badge for protected pages (cart, profile, rewards, roulette)
- [ ] Content pages (home, menu, promo, about, contact) are NOT marked as protected
- [ ] Custom pages show "Personnalisée" badge
- [ ] No mixing between system and custom

### Editor Operations
- [ ] Toggle active on custom page → works ✅
- [ ] Change bottomNavIndex on custom page → works ✅
- [ ] Toggle active on system page → works ✅
- [ ] No "Impossible de modifier une page personnalisée sans pageId" error

### Runtime Navigation
- [ ] /home loads system home page
- [ ] /menu loads system menu page
- [ ] /cart loads system cart page
- [ ] /profile loads system profile page
- [ ] /page/my_custom loads custom page
- [ ] No duplication or wrong content

### Draft/Published Sync
- [ ] Empty draft + published content → editor shows content (self-heal works)
- [ ] Self-heal persists to pages_draft collection
- [ ] Deleted pages stay deleted
- [ ] Draft/published sync works correctly

### Module Recognition
- [ ] `menu_catalog` module renders correctly
- [ ] `cart_module` module renders correctly
- [ ] `profile_module` module renders correctly
- [ ] `roulette_module` and `roulette` modules render correctly
- [ ] Unknown module shows appropriate warning in editor

---

## Backward Compatibility Notes

1. **Existing custom pages** with pageKey matching system pages (e.g., "menu") will now be treated as custom pages (systemId = null) unless explicitly marked with `isSystemPage: true` in Firestore.

2. **New custom pages** will never collide with system pages due to the `custom_` prefix.

3. **SystemBlock modules** now recognize more module types (menu_catalog, cart_module, profile_module).

4. **Legacy pages_system methods** still work but are deprecated. Use pages_published instead.

5. **isSystemPage behavior changed**: Only cart, profile, rewards, roulette return `true`. Home, menu, promo, about, contact now return `false` (they are not "protected" system pages).

---

## Security Summary

No security vulnerabilities were introduced by these changes. The fixes are defensive in nature:
- Collision prevention adds safety, not removes it
- Explicit systemId handling prevents unintended privilege escalation
- pageKey-based operations are properly validated
- Deprecated methods are clearly marked to guide migration

---

**End of Final Fix Report**
