# Builder B3 Pipeline - Deep Audit Report

**Date:** 2025-11-29  
**Scope:** lib/builder/**, lib/src/core/** (Firestore paths)  
**Author:** Flutter Architecture Audit  

---

## 1️⃣ GLOBAL ARCHITECTURE MAP (Builder B3)

### 1.1 Architecture Overview Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        BUILDER B3 ARCHITECTURE PIPELINE                         │
└─────────────────────────────────────────────────────────────────────────────────┘

                              ┌──────────────────┐
                              │  PAGE CREATION   │
                              └────────┬─────────┘
                                       │
           ┌───────────────────────────┼───────────────────────────┐
           │                           │                           │
           ▼                           ▼                           ▼
   ┌───────────────┐          ┌───────────────┐          ┌───────────────┐
   │   TEMPLATE    │          │    BLANK      │          │   SYSTEM      │
   │    PAGE       │          │    PAGE       │          │    PAGE       │
   │               │          │               │          │               │
   │ createPage-   │          │ createBlank-  │          │ auto-init     │
   │ FromTemplate()│          │ Page()        │          │ on first load │
   └───────┬───────┘          └───────┬───────┘          └───────┬───────┘
           │                           │                           │
           └───────────────────────────┼───────────────────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────┐
                        │   _generatePageId(name)  │
                        │   Converts name to slug  │
                        │   e.g., "Menu" → "menu"  │
                        └────────────┬─────────────┘
                                     │
                ┌────────────────────┴────────────────────┐
                │                                         │
                ▼                                         ▼
    ┌─────────────────────┐                 ┌─────────────────────┐
    │    CUSTOM PAGE      │                 │   SYSTEM PAGE       │
    │                     │                 │                     │
    │ pageKey: slug       │                 │ pageKey: enum.value │
    │ systemId: null      │                 │ systemId: BuilderPId│
    │ route: /page/slug   │                 │ route: /enum.value  │
    │ isSystemPage: false │                 │ isSystemPage: true  │
    └──────────┬──────────┘                 └──────────┬──────────┘
               │                                       │
               └───────────────────┬───────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────┐
                    │    FIRESTORE STORAGE     │
                    └──────────────────────────┘
                               │
           ┌───────────────────┼───────────────────┐
           │                   │                   │
           ▼                   ▼                   ▼
   ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
   │ pages_draft/  │  │pages_published│  │ pages_system/ │
   │ {pageKey}     │  │ {pageKey}     │  │   (legacy)    │
   │               │  │               │  │               │
   │ draftLayout   │  │publishedLayout│  │ navigation    │
   │ blocks        │  │ blocks        │  │ metadata      │
   └───────────────┘  └───────────────┘  └───────────────┘
                               │
                               ▼
                    ┌──────────────────────────┐
                    │    RUNTIME LOADING       │
                    └──────────────────────────┘
                               │
           ┌───────────────────┼───────────────────┐
           │                   │                   │
           ▼                   ▼                   ▼
   ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
   │ BuilderPage-  │  │ DynamicPage-  │  │ DynamicBuilder│
   │ Loader        │  │ Resolver      │  │ PageScreen    │
   │               │  │               │  │               │
   │ System pages  │  │ byRoute()     │  │ /page/:key    │
   │ with fallback │  │ byKey()       │  │ Custom pages  │
   └───────────────┘  └───────────────┘  └───────────────┘
```

### 1.2 Key Components

| Component | File | Purpose |
|-----------|------|---------|
| **BuilderPage** | `models/builder_page.dart` | Core page model with pageKey, systemId, route, layouts |
| **BuilderPageId** | `models/builder_enums.dart` | Enum for known system pages (home, menu, cart, profile, etc.) |
| **SystemPages** | `models/system_pages.dart` | Registry mapping BuilderPageId → routes, icons, names |
| **BuilderLayoutService** | `services/builder_layout_service.dart` | Firestore CRUD for pages_draft/pages_published |
| **BuilderPageService** | `services/builder_page_service.dart` | High-level page operations (create, publish, toggle) |
| **BuilderNavigationService** | `services/builder_navigation_service.dart` | Bottom nav bar logic, auto-init |
| **DynamicPageResolver** | `services/dynamic_page_resolver.dart` | Runtime page resolution by route/key/pageId |
| **BuilderPageLoader** | `runtime/builder_page_loader.dart` | Widget that loads Builder page with legacy fallback |
| **DynamicBuilderPageScreen** | `runtime/dynamic_builder_page_screen.dart` | Widget for /page/:pageKey routes |
| **BuilderPageEditorScreen** | `editor/builder_page_editor_screen.dart` | Admin editor for pages |

### 1.3 Firestore Structure

```
restaurants/{appId}/
├── pages_draft/{pageKey}        ← Editor working copy
│   ├── pageKey: String          ← Document ID (primary key)
│   ├── pageId: String           ← Legacy field, often same as pageKey
│   ├── systemId: null|enum      ← Only for system pages
│   ├── route: String            ← Navigation route
│   ├── draftLayout: []          ← Editor blocks
│   ├── publishedLayout: []      ← Snapshot at publish time
│   ├── blocks: []               ← Legacy field
│   ├── isActive: bool
│   ├── isSystemPage: bool
│   └── bottomNavIndex: int
│
├── pages_published/{pageKey}    ← Live client-facing data
│   └── (same fields as above)
│
└── pages_system/{pageKey}       ← Legacy/navigation order (being phased out)
```

---

## 2️⃣ LIST OF PAGE IDENTIFIERS (Points of Truth)

### 2.1 Identifier Analysis

| Identifier | Location | Intent | Reality in Code |
|------------|----------|--------|-----------------|
| **pageKey** | `BuilderPage.pageKey` | Primary identifier, Firestore doc ID | ✅ Always set, computed from systemId or generated from name |
| **pageId** | `BuilderPage.pageId` | Legacy enum reference | ⚠️ Nullable for custom pages, but often derived from pageKey incorrectly |
| **systemId** | `BuilderPage.systemId` | Enum for known system pages | ⚠️ Should be null for custom pages but derived from pageKey in fromJson |
| **route** | `BuilderPage.route` | Navigation path | ⚠️ Inconsistent: `/home` for system, `/page/slug` for custom |
| **BuilderPageId enum** | `builder_enums.dart` | Defines known pages | ✅ Fixed set: home, menu, cart, profile, promo, about, contact, rewards, roulette |
| **isSystemPage** | `BuilderPage.isSystemPage` | Protection flag | ⚠️ Computed from systemId/pageId but can be incorrectly false for system pages |
| **Firestore doc ID** | Collection document | Actual storage key | ✅ Uses pageKey correctly |
| **_generatePageId()** | `builder_page_service.dart` | Slug generator | ⚠️ **CRITICAL BUG**: Can generate "menu", "home" etc. for custom pages |
| **navigation mapping** | `action_helper.dart` | Route → pageId | ⚠️ Only handles system pages, custom pages need /page/key format |
| **template mapping** | `new_page_dialog_v2.dart` | Template → blocks | ⚠️ Includes system page templates (cart, profile) that shouldn't be creatable |

### 2.2 The _generatePageId() Problem

**File:** `lib/builder/services/builder_page_service.dart:1141-1148`

```dart
String _generatePageId(String name) {
  final processed = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return processed.substring(0, processed.length > 20 ? 20 : processed.length);
}
```

**Problem:** If user creates a page named "Menu", "Home", "Cart", or "Profile", this generates:
- "Menu" → "menu" → matches `BuilderPageId.menu`
- "Accueil" → "accueil" → different from "home" but stored at /page/accueil

---

## 3️⃣ DETECTED INCONSISTENCIES

### [FATAL] F1: Custom Page Name Can Collide With System Page ID

**Location:** `builder_page_service.dart:66-76` (createPageFromTemplate) and `:139-144` (createBlankPage)

**Problem:** `_generatePageId(name)` generates slugs that can match system page IDs.

**Example:** User creates custom page "Menu" → pageKey="menu" → stored in pages_draft/menu → **collides with the system menu page document, replacing its content!**

**Detailed collision behavior:**
1. Both system and custom pages use pageKey as Firestore document ID
2. If custom page has same pageKey as system page, they write to the same document
3. The second write replaces all fields (except merge fields)
4. Result: System page content is lost, replaced by custom page content

**Current Mitigation Attempt (Insufficient):**
```dart
if (kDebugMode) {
  final potentialCollision = BuilderPageId.tryFromString(pageKeyValue);
  if (potentialCollision != null) {
    debugPrint('[BuilderPageService] ⚠️ Custom page name collides...');
  }
}
```
This only logs in debug mode but **does not prevent the collision**.

---

### [FATAL] F2: BuilderPage.fromJson() Incorrectly Derives systemId

**Location:** `builder_page.dart:346-355`

```dart
final rawPageId = json['pageId'] as String? ?? json['pageKey'] as String? ?? 'home';
final pageKey = json['pageKey'] as String? ?? rawPageId;

// Try to get system page ID (nullable for custom pages)
final systemId = BuilderPageId.tryFromString(rawPageId);

// pageId is now nullable - don't default to home for custom pages
final BuilderPageId? pageId = systemId;
```

**Problem:** If a custom page has pageKey="menu", this code sets `systemId = BuilderPageId.menu`, causing:
1. Route computed as `/menu` instead of `/page/menu`
2. isSystemPage = true (incorrectly)
3. System page config applied (wrong icon, name)

---

### [FATAL] F3: No Validation Prevents Creating Reserved Page IDs

**Location:** `new_page_dialog.dart:246-250`

```dart
if (BuilderPageId.systemPageIds.contains(v.trim().toLowerCase())) {
  return 'Cet ID est réservé aux pages système (profile, cart, rewards, roulette)';
}
```

**Problem:** This validation only runs for NewPageDialog, not NewPageDialogV2. Additionally, `systemPageIds` only contains some IDs:
```dart
static const List<String> systemPageIds = [
  'home', 'menu', 'promo', 'about', 'contact',
  'profile', 'cart', 'rewards', 'roulette',
];
```

But template selection in NewPageDialogV2 allows creating "cart_template", "profile_template" etc.

---

### [SEVERE] S1: Draft/Published Layout Synchronization Issues

**Location:** `builder_layout_service.dart:159-213` (loadDraft)

**Problem:** When draft is empty but published has content, the code self-heals by copying publishedLayout to draft:
```dart
if (draftLayout.isEmpty && publishedLayout.isNotEmpty) {
  draftLayout = List<BuilderBlock>.from(publishedLayout);
}
```

However, this happens at **parse time** in fromJson(), not consistently across all load paths.

**Symptom:** "Home empty in builder but not in client" - Editor loads stale draft, client loads correct published.

---

### [SEVERE] S2: Navigation Service Uses Multiple Sources of Truth

**Location:** `builder_navigation_service.dart:59-77`

```dart
// Step 1: Load ALL system pages (active AND inactive)
final allSystemPages = await _layoutService.loadSystemPages(appId);

// Step 2: Strict check - only trigger auto-init if truly empty
if (allSystemPages.isEmpty) {
  await _ensureMinimumPages(allSystemPages);
}

// Step 3: Always fix empty system pages
await _pageService.fixEmptySystemPages(appId);

// Step 4: Return ONLY active pages
final pages = await _layoutService.getBottomBarPages(appId: appId);
```

**Problem:** 
1. `loadSystemPages()` queries from pages_published with `isSystemPage` filter
2. `getBottomBarPages()` queries from pages_published with `isActive && bottomNavIndex` filter
3. These can return different pages if isSystemPage flag is wrong

---

### [SEVERE] S3: Profile and Cart Can Show Same Content

**Location:** `dynamic_page_resolver.dart:125-168`

**Root Cause Analysis:**
1. User creates custom page "Profil" → pageKey="profil"
2. `fromJson()` tries `BuilderPageId.tryFromString("profil")` → returns null (profile ≠ profil)
3. Page is correctly treated as custom
4. BUT if user creates "Profile" → pageKey="profile" → `tryFromString` returns `BuilderPageId.profile`
5. Now two documents compete: custom "Profile" at pages_published/profile AND system profile

When `resolveByKey('profile')`:
```dart
final systemPageId = BuilderPageId.tryFromString(pageKey);
if (systemPageId != null) {
  final resolved = await resolve(systemPageId, appId); // Returns system page
  if (resolved != null) return resolved;
}
```

Both cart and profile could resolve to same underlying page if the collision document was copied.

---

### [SEVERE] S4: Route Confusion Between /page/key and /systemKey

**Location:** Multiple files

**System page routes:** `/home`, `/menu`, `/cart`, `/profile`
**Custom page routes:** `/page/{pageKey}`

**Problem in fromJson (builder_page.dart:398-404):**
```dart
if (systemConfig != null) {
  defaultRoute = systemConfig.route;  // e.g., /menu
} else {
  defaultRoute = '/page/$pageKey';    // e.g., /page/menu
}
```

If pageKey="menu" but it's a custom page (systemId=null), route becomes `/page/menu`. But if fromJson incorrectly derives systemId from pageKey, route becomes `/menu`.

---

### [MODERATE] M1: Editor Uses pageId || systemId Inconsistently

**Location:** `builder_page_editor_screen.dart:713-726`

```dart
final pageId = _page!.pageId ?? _page!.systemId;
if (pageId == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('❌ Impossible de modifier une page personnalisée sans pageId'),
    ),
  );
  return;
}
```

**Problem:** Custom pages have null pageId AND null systemId, so navigation updates fail with this error.

---

### [MODERATE] M2: Template Initialization Happens in Wrong Service

**Location:** 
- `builder_page_service.dart:986-1136` (_getDefaultBlocksForSystemPage)
- `builder_navigation_service.dart:209-277` (_getDefaultBlocksForPage)
- `default_page_creator.dart:235-259` (_buildDefaultBlocks)

**Problem:** Three different services define default blocks for system pages with slight variations:
1. BuilderPageService uses modern config keys (`buttonLabel`, `tapAction`)
2. BuilderNavigationService uses nested tapAction format (`{'type': 'openPage', 'value': '/menu'}`)
3. DefaultPageCreator returns empty arrays for system pages

---

### [MODERATE] M3: SystemPages Registry vs BuilderPageId.isSystemPage Mismatch

**Location:** 
- `system_pages.dart:45-47` defines home and menu as `isSystemPage: false`
- `builder_enums.dart:109` `isSystemPage` checks `systemPageIds.contains(value)` which includes home and menu

```dart
// system_pages.dart
BuilderPageId.home: SystemPageConfig(
  isSystemPage: false, // home is not protected
),
BuilderPageId.menu: SystemPageConfig(
  isSystemPage: false, // menu is not protected
),

// builder_enums.dart
static const List<String> systemPageIds = [
  'home', 'menu', 'promo', 'about', 'contact', // ← includes home and menu!
  'profile', 'cart', 'rewards', 'roulette',
];
bool get isSystemPage => systemPageIds.contains(value); // Returns true for home!
```

---

### [MODERATE] M4: pages_system Collection Is Legacy But Still Queried

**Location:** `builder_layout_service.dart:655-675`

```dart
Future<BuilderPage?> loadSystemPage(String appId, BuilderPageId pageId) async {
  final docRef = FirestorePaths.systemPageDoc(pageId.value, appId);
  // ...
}

Stream<List<BuilderPage>> watchSystemPages(String appId) {
  return FirestorePaths.pagesSystem(appId).snapshots()...
}
```

**Problem:** `loadSystemPages()` now queries pages_published (line 635-649), but `loadSystemPage()` and `watchSystemPages()` still use pages_system collection.

---

### [MINOR] N1: availableTemplates Includes System Page Templates

**Location:** `new_page_dialog_v2.dart:26-84`

```dart
const List<PageTemplate> availableTemplates = [
  // ...
  PageTemplate(
    id: 'cart_template',
    name: 'Panier',
    description: 'Page panier (système)',
  ),
  PageTemplate(
    id: 'profile_template',
    name: 'Profil',
    description: 'Page profil utilisateur (système)',
  ),
];
```

Users can create these from templates, which would create custom pages with system-like names.

---

### [MINOR] N2: SystemBlock.availableModules Is Incomplete

**Location:** `builder_block.dart:242-247`

```dart
static const List<String> availableModules = [
  'roulette', 'loyalty', 'rewards', 'accountActivity',
];
```

But `builder_modules.dart:54-59` defines:
```dart
final Map<String, ModuleWidgetBuilder> builderModules = {
  'menu_catalog': ...,
  'cart_module': ...,
  'profile_module': ...,
  'roulette_module': ...,
};
```

Missing: `menu_catalog`, `cart_module`, `profile_module` in SystemBlock.availableModules.

---

## 4️⃣ ROOT CAUSE MAPPING TO USER SYMPTOMS

### Symptom 1: "Home empty in builder but not in client"

**Root Cause:** S1 - Draft/Published Layout Synchronization Issues

**Flow:**
1. Client app calls `loadPublished()` → gets pages_published/home with publishedLayout
2. Editor calls `loadDraft()` → gets pages_draft/home with empty draftLayout
3. Self-heal in loadDraft creates in-memory copy but fails to persist (or persistence fails silently)
4. Editor shows empty, client shows correct

**Code Path:**
- `builder_layout_service.dart:159-213` loadDraft()
- Line 193: `await saveDraft(newDraft)` may fail silently

---

### Symptom 2: "Profile and Cart showing same content"

**Root Cause:** F1 + F2 - Custom page name collision + incorrect systemId derivation

**Flow:**
1. Admin creates custom page "Profile" → pageKey="profile"
2. `fromJson()` sets systemId = BuilderPageId.profile (incorrectly)
3. Stored as pages_published/profile, **replacing** the actual system profile page document
4. This single document now has custom page content but system page properties
5. If cart page was similarly affected (custom "Panier" → pageKey="cart" on French systems), both profile and cart could display similar corrupted content patterns

**Important clarification:** There's only one document at pages_published/profile - the custom page replaces it entirely. The "same content" symptom occurs when both pages inherit the same corrupted template/blocks due to the collision.

**Code Path:**
- `builder_page_service.dart:66-76` _generatePageId
- `builder_page.dart:346-355` fromJson systemId derivation

---

### Symptom 3: "Page 'Menu' created as /page/menu overriding system Menu"

**Root Cause:** F1 - _generatePageId collision + F3 - No validation

**Flow:**
1. Admin creates custom page "Menu" 
2. pageKey = _generatePageId("Menu") = "menu"
3. Stored at pages_draft/menu, pages_published/menu
4. System menu page at same location is overwritten
5. Client navigating to /menu now shows custom page content

**Code Path:**
- `builder_page_service.dart:1141-1148` _generatePageId
- No collision prevention in createPageFromTemplate

---

### Symptom 4: "Page 'Accueil' created as /page/accueil while /home exists"

**Root Cause:** Correct behavior, but confusing to admin

**Explanation:** "Accueil" → "accueil" (not "home"), so no collision. But admin expects to edit the home page.

**Issue:** UX confusion - admin should be directed to edit existing system pages, not create duplicates.

---

### Symptom 5: "Impossible de modifier une page personnalisée sans PageID"

**Root Cause:** M1 - Editor uses pageId || systemId for navigation updates

**Code Path:**
- `builder_page_editor_screen.dart:713-726`
- Custom pages have pageId=null AND systemId=null
- `updatePageNavigation()` requires BuilderPageId enum

**Fix Required:** Use pageKey (String) instead of BuilderPageId for custom page operations.

---

### Symptom 6: "Custom pages becoming system pages"

**Root Cause:** F2 - fromJson derives systemId from pageKey

**Flow:**
1. Custom page saved with pageKey matching system page name
2. On next load, fromJson sets systemId from pageKey
3. Page gains system page properties (route, icon, protection)

---

### Symptom 7: "Pages replaced silently"

**Root Cause:** F1 + no conflict detection

**Flow:**
1. Page A saved at pages_published/menu
2. New page B created with name "Menu" → pageKey="menu"
3. Page B saved at pages_published/menu
4. Page A content lost (overwritten)

---

### Symptom 8: "Navigation confusion between system/custom"

**Root Cause:** S4 - Route format inconsistency

**System:** `/menu`
**Custom:** `/page/menu` (if correctly detected as custom) OR `/menu` (if incorrectly tagged as system)

---

### Symptom 9: "Draft/published mismatch"

**Root Cause:** S1 - Incomplete sync between draft and published collections

---

### Symptom 10: "Editor loading wrong document"

**Root Cause:** M1 + collision between custom and system pages with same pageKey

---

## 5️⃣ SAFE, NON-BREAKING FIX PLAN

### Fix 1: Add Collision Prevention in Page Creation

**Files to modify:**
- `lib/builder/services/builder_page_service.dart`
- `lib/builder/page_list/new_page_dialog_v2.dart`

**Changes required:**

1. **In _generatePageId() (line ~1141):**
   - Add suffix if generated ID matches system page
   - Use unique suffix to avoid secondary collisions
   ```dart
   String _generatePageId(String name) {
     var processed = name
         .toLowerCase()
         .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
         .replaceAll(RegExp(r'^_|_$'), '');
     processed = processed.substring(0, processed.length > 20 ? 20 : processed.length);
     
     // COLLISION PREVENTION: Add unique suffix if matches system page
     if (BuilderPageId.tryFromString(processed) != null) {
       // Use timestamp to guarantee uniqueness
       final suffix = DateTime.now().millisecondsSinceEpoch % 10000;
       processed = 'custom_${processed}_$suffix';
     }
     return processed;
   }
   ```
   
   **Alternative approach (check database):**
   ```dart
   // If you want to check for existing pages too:
   Future<String> _generateUniquePageId(String name, String appId) async {
     var processed = _sanitizeName(name);
     
     // Check for system page collision
     if (BuilderPageId.tryFromString(processed) != null) {
       processed = 'custom_$processed';
     }
     
     // Check for existing custom page with same key
     var attempt = 0;
     var candidate = processed;
     while (await _layoutService.hasDraft(appId, candidate) ||
            await _layoutService.hasPublished(appId, candidate)) {
       attempt++;
       candidate = '${processed}_$attempt';
     }
     return candidate;
   }
   ```

2. **In createPageFromTemplate() and createBlankPage():**
   - Add explicit check and throw exception if collision detected
   
3. **In NewPageDialogV2:**
   - Add validation before calling service
   - Hide system page templates from the list

**Impact:** Prevents future collisions, existing pages unaffected
**Backward Compatibility:** ✅ Only affects new page creation
**Firestore Cleanup:** None required

**Testing Checklist:**
- [ ] Create page named "Menu" → should create "custom_menu"
- [ ] Create page named "Unique" → should create "unique"
- [ ] Verify existing pages still accessible
- [ ] Verify system pages unaffected

---

### Fix 2: Fix fromJson() systemId Derivation

**Files to modify:**
- `lib/builder/models/builder_page.dart`

**Changes required (line ~346-355):**
```dart
factory BuilderPage.fromJson(Map<String, dynamic> json) {
  // 1. Extract explicit systemId if stored
  // Handle multiple storage formats: String, Map, or null
  String? storedSystemId;
  final rawSystemId = json['systemId'];
  if (rawSystemId is String) {
    storedSystemId = rawSystemId;
  } else if (rawSystemId is Map && rawSystemId['value'] != null) {
    storedSystemId = rawSystemId['value'] as String?;
  }
  // Note: If storedSystemId is null, the page is treated as custom
  
  // 2. Only set systemId if it was EXPLICITLY stored, not derived from pageKey
  final BuilderPageId? systemId = storedSystemId != null 
      ? BuilderPageId.tryFromString(storedSystemId)
      : null;
  
  // 3. pageKey is the primary identifier
  final rawPageId = json['pageId'] as String? ?? json['pageKey'] as String?;
  final pageKey = json['pageKey'] as String? ?? rawPageId ?? 'unknown';
  
  // 4. pageId is deprecated - only use for backward compatibility
  final BuilderPageId? pageId = systemId;
  // ...
}
```

**Migration strategy:**
1. **Query phase:** Identify all documents in pages_draft and pages_published
2. **Classification phase:** For each document:
   - If `systemId` field exists and is valid → system page (no change needed)
   - If `systemId` field is null but `pageKey` matches BuilderPageId enum → **infer** it's a system page and add explicit `systemId`
   - If `pageKey` doesn't match any enum → custom page, ensure `systemId` stays null
3. **Write phase:** Update documents with explicit `systemId` field
4. **Rollback strategy:** Keep backup of original documents before migration; if errors occur, restore from backup

**Edge case handling:**
- Documents with corrupted `systemId` values: Set to null and log warning
- Documents missing both `pageKey` and `pageId`: Generate fallback ID from document path
- Type conversion errors: Wrap in try-catch, log, and skip with warning

**Testing Checklist:**
- [ ] Load existing system page → systemId correctly set
- [ ] Load existing custom page → systemId null
- [ ] Create new custom page "Test" → systemId null even if pageKey="test"
- [ ] Existing pages still work after migration

---

### Fix 3: Use pageKey for Custom Page Navigation Operations

**Files to modify:**
- `lib/builder/editor/builder_page_editor_screen.dart`
- `lib/builder/services/builder_page_service.dart`

**Changes required:**

1. **In _updateNavigationParams() (line ~711-726):**
   ```dart
   Future<void> _updateNavigationParams({...}) async {
     if (_page == null) return;
     
     // Use pageKey for all pages (works for both system and custom)
     final pageKey = _page!.pageKey;
     
     // For custom pages, use string-based service method
     // For system pages with pageId, use existing method
     if (_page!.systemId != null) {
       await _pageService.updatePageNavigation(
         pageId: _page!.systemId!,
         appId: widget.appId,
         isActive: finalIsActive,
         bottomNavIndex: ...,
       );
     } else {
       await _pageService.updateCustomPageNavigation(
         pageKey: pageKey,
         appId: widget.appId,
         isActive: finalIsActive,
         bottomNavIndex: ...,
       );
     }
   }
   ```

2. **Add updateCustomPageNavigation() to BuilderPageService:**
   ```dart
   Future<BuilderPage> updateCustomPageNavigation({
     required String pageKey,
     required String appId,
     required bool isActive,
     required int? bottomNavIndex,
   }) async {
     // Similar to updatePageNavigation but uses pageKey
   }
   ```

**Impact:** Custom pages can now be edited for navigation
**Backward Compatibility:** ✅ Adds new method, doesn't change existing
**Firestore Cleanup:** None

**Testing Checklist:**
- [ ] Toggle active on custom page → works
- [ ] Change bottomNavIndex on custom page → works
- [ ] Same operations on system pages → still work

---

### Fix 4: Align SystemPages Registry with BuilderPageId.isSystemPage

**Files to modify:**
- `lib/builder/models/builder_enums.dart`
- `lib/builder/models/system_pages.dart`

**Changes required:**

Option A: Define isSystemPage only in SystemPages registry (preferred)
```dart
// In BuilderPageId
bool get isSystemPage {
  final config = SystemPages.getConfig(this);
  return config?.isSystemPage ?? false;
}
```

Option B: Align both sources
```dart
// In SystemPages, change home and menu to isSystemPage: false consistently
// AND in BuilderPageId, remove home/menu from systemPageIds
```

**Impact:** Consistent behavior for isSystemPage checks
**Backward Compatibility:** ⚠️ May change existing behavior - audit all usages first
**Firestore Cleanup:** None

**Testing Checklist:**
- [ ] home.isSystemPage returns expected value
- [ ] menu.isSystemPage returns expected value
- [ ] cart.isSystemPage returns true
- [ ] Custom page isSystemPage returns false

---

### Fix 5: Deprecate pages_system Collection

**Files to modify:**
- `lib/builder/services/builder_layout_service.dart`

**Changes required:**
1. Mark `loadSystemPage()` as @deprecated
2. Mark `watchSystemPages()` as @deprecated
3. Update all callers to use `loadPublished()` instead
4. Add migration script to copy pages_system content to pages_published

**Impact:** Single source of truth for all pages
**Backward Compatibility:** ✅ Add deprecation first, remove in next version
**Firestore Cleanup:** Run migration, then delete pages_system collection

**Testing Checklist:**
- [ ] All navigation queries use pages_published
- [ ] Deprecated methods still work during transition
- [ ] No data loss from pages_system

---

### Fix 6: Remove System Page Templates from NewPageDialogV2

**Files to modify:**
- `lib/builder/page_list/new_page_dialog_v2.dart`

**Changes required:**
Filter templates to keep only content-focused templates, remove system page templates:

```dart
const List<PageTemplate> availableTemplates = [
  // KEEP: Content templates (these generate custom pages with unique pageKeys)
  PageTemplate(id: 'home_template', ...),   // Creates custom landing page, NOT system /home
  PageTemplate(id: 'menu_template', ...),   // Creates custom menu page, NOT system /menu
  PageTemplate(id: 'promo_template', ...),
  PageTemplate(id: 'about_template', ...),
  PageTemplate(id: 'contact_template', ...),
  
  // REMOVE: System page templates (these suggest creating system pages)
  // - cart_template (remove)
  // - profile_template (remove)
  // - roulette_template (remove)
];
```

**Clarification on home_template and menu_template:**
- These templates are **safe** because they generate **content blocks** (hero, product list, etc.)
- The generated pageKey will be derived from the user-provided name, NOT "home" or "menu"
- Example: User picks "home_template", names it "Landing Page" → pageKey="landing_page"
- The collision prevention fix (Fix 1) ensures even if they name it "Home", it becomes "custom_home_12345"

**Why system templates should be removed:**
- cart_template, profile_template, roulette_template suggest creating these system pages
- They would generate pageKey "panier", "profil", "roulette" which could collide
- These pages should only be edited via the existing system page editor, not created from templates

**Impact:** Users can't accidentally create system pages from templates
**Backward Compatibility:** ✅ Only removes options
**Firestore Cleanup:** None

**Testing Checklist:**
- [ ] Cart template not visible
- [ ] Profile template not visible
- [ ] Home/Menu templates still work

---

### Priority Order

1. **Fix 1** (Collision Prevention) - CRITICAL, prevents future issues
2. **Fix 3** (pageKey for Custom Pages) - HIGH, unblocks editing
3. **Fix 2** (fromJson systemId) - HIGH, core data model fix
4. **Fix 6** (Remove System Templates) - MEDIUM, prevents confusion
5. **Fix 4** (Align isSystemPage) - MEDIUM, consistency
6. **Fix 5** (Deprecate pages_system) - LOW, cleanup

---

## Summary Table

| ID | Severity | Issue | Root Files | Estimated Impact |
|----|----------|-------|------------|------------------|
| F1 | FATAL | Custom name collision | builder_page_service.dart | HIGH |
| F2 | FATAL | Incorrect systemId derivation | builder_page.dart | HIGH |
| F3 | FATAL | No reserved ID validation | new_page_dialog.dart | MEDIUM |
| S1 | SEVERE | Draft/Published sync | builder_layout_service.dart | HIGH |
| S2 | SEVERE | Multiple sources of truth | builder_navigation_service.dart | MEDIUM |
| S3 | SEVERE | Profile/Cart same content | dynamic_page_resolver.dart | HIGH |
| S4 | SEVERE | Route format confusion | Multiple | MEDIUM |
| M1 | MODERATE | Editor pageId requirement | builder_page_editor_screen.dart | HIGH |
| M2 | MODERATE | Template init inconsistency | 3 services | LOW |
| M3 | MODERATE | isSystemPage mismatch | system_pages.dart, builder_enums.dart | LOW |
| M4 | MODERATE | Legacy pages_system usage | builder_layout_service.dart | LOW |
| N1 | MINOR | System templates visible | new_page_dialog_v2.dart | LOW |
| N2 | MINOR | SystemBlock modules incomplete | builder_block.dart | LOW |

---

**End of Audit Report**
