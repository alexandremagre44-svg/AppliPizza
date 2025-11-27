# BUILDER_DATA_SPEC.md

> **Document Version:** 1.0  
> **Generated:** 2025-11-27  
> **Purpose:** Firestore Schema Specification for `lib/builder/` Module

This document reverse-engineers the required Firestore schema based on the code analysis of `lib/builder/`. It serves as a checklist to verify your existing production database without deleting anything.

---

## Table of Contents

1. [The Page Contract (builder_page.dart)](#1-the-page-contract-builder_pagedart)
2. [The Storage Strategy (builder_layout_service.dart)](#2-the-storage-strategy-builder_layout_servicedart)
3. [The Routing Logic (dynamic_page_resolver.dart)](#3-the-routing-logic-dynamic_page_resolverdart)
4. [System Defaults (system_pages_initializer.dart & builder_pages_registry.dart)](#4-system-defaults-system_pages_initializerdart--builder_pages_registrydart)
5. [Complete Schema Reference](#5-complete-schema-reference)
6. [Production Database Checklist](#6-production-database-checklist)

---

## 1. The Page Contract (builder_page.dart)

### 1.1 BuilderPage.fromJson Field Analysis

Based on the analysis of `BuilderPage.fromJson()` (lines 332-426 in `builder_page.dart`):

#### Mandatory Fields (code crashes or uses critical defaults if missing)

| Field | Type | Default if Missing | Impact |
|-------|------|-------------------|--------|
| `pageId` OR `pageKey` | `String` | `'home'` | **CRITICAL** - Determines page identity. Falls back to `'home'` if both missing. |
| `appId` | `String` | `kRestaurantId` (currently `'delizza'`) | Used for multi-restaurant support. Defaults to global constant. |
| `name` | `String` | Falls back to `json['title']`, then `systemConfig?.defaultName`, then `'Page'` | Display name. Multiple fallbacks prevent crash. |
| `route` | `String` | `systemConfig.route` for system pages, or `/page/{pageKey}` for custom pages | **CRITICAL** - Navigation routing. Invalid routes (empty or `/`) are filtered. |

#### Optional Fields (gracefully handled)

| Field | Type | Default if Missing | Notes |
|-------|------|-------------------|-------|
| `description` | `String` | `''` (empty string) | Page description for admin reference |
| `blocks` | `List<Map>` | `[]` (empty array) | Legacy field - safely parsed via `_safeLayoutParse()` |
| `draftLayout` | `List<Map>` | Falls back to `blocks` value | Editor working copy |
| `publishedLayout` | `List<Map>` | `[]` (empty array) | Live version for end users |
| `isEnabled` | `bool` | `true` | Page active/published state |
| `isDraft` | `bool` | `false` | Draft version indicator |
| `metadata` | `Map` | `null` | SEO metadata (title, description, keywords, ogImage, etc.) |
| `version` | `int` | `1` | Version tracking |
| `createdAt` | `Timestamp/String/int` | `DateTime.now()` | Supports Firestore Timestamp, ISO string, or epoch ms |
| `updatedAt` | `Timestamp/String/int` | `DateTime.now()` | Supports Firestore Timestamp, ISO string, or epoch ms |
| `publishedAt` | `Timestamp/String/int` | `null` | When page was last published |
| `lastModifiedBy` | `String` | `null` | User ID who last modified |
| `displayLocation` | `String` | `'hidden'` | Values: `'bottomBar'`, `'hidden'`, `'internal'` |
| `icon` | `String` | `systemConfig?.defaultIcon` or `'help_outline'` | Material Icon name |
| `order` | `int` | `999` | Bottom navigation bar order |
| `isSystemPage` | `bool` | `systemId?.isSystemPage ?? false` | Protected page flag |
| `pageType` | `String` | `'system'` or `'custom'` (computed) | Values: `'template'`, `'blank'`, `'system'`, `'custom'` |
| `isActive` | `bool` | `true` | Visibility in navigation |
| `bottomNavIndex` | `int` | Falls back to `order`, then `999` | Explicit bottom nav ordering |
| `modules` | `List<String>` | `[]` (empty array) | Attached module IDs (safely skips non-strings) |
| `hasUnpublishedChanges` | `bool` | `false` | Draft changes indicator |

### 1.2 pageKey vs pageId (Enum) Conflict Resolution

**Current Behavior (lines 334-341):**

```dart
// Extract pageKey (source of truth) - prefer explicit pageKey, then pageId, then doc id
final rawPageId = json['pageId'] as String? ?? json['pageKey'] as String? ?? 'home';
final pageKey = json['pageKey'] as String? ?? rawPageId;

// Try to get system page ID (nullable for custom pages)
final systemId = BuilderPageId.tryFromString(rawPageId);

// For backward compatibility, compute pageId (will be home for unknown custom pages)
final pageId = systemId ?? BuilderPageId.home;
```

**Resolution Strategy:**

| Priority | Field in Firestore | Result |
|----------|-------------------|--------|
| 1st | `pageKey` explicitly set | Used as `pageKey` (source of truth) |
| 2nd | `pageId` field present | Used as `rawPageId`, then as `pageKey` if no explicit `pageKey` |
| 3rd | Neither present | Defaults to `'home'` |

**For System Pages:**
- `systemId` is set to the matching `BuilderPageId` enum value
- `pageId` (deprecated) uses the enum value for backward compatibility

**For Custom Pages:**
- `systemId` is `null`
- `pageKey` can be any string (e.g., `'promo_noel'`, `'special_offer'`)
- `pageId` (deprecated) defaults to `BuilderPageId.home` for backward compatibility

---

## 2. The Storage Strategy (builder_layout_service.dart)

### 2.1 Firestore Paths Confirmed

Based on `firestore_paths.dart` and `builder_layout_service.dart`:

```
restaurants/{restaurantId}/
├── pages_system/           # System page configurations (navigation structure)
├── pages_draft/{pageId}    # Draft page layouts (editor working copy)
├── pages_published/{pageId} # Published page layouts (live version)
├── builder_pages/          # Page metadata and configuration
├── builder_blocks/         # Block templates and reusable blocks
└── builder_settings/       # Theme, home config, app texts, banners, etc.
    ├── home_config
    ├── theme
    ├── app_texts
    ├── loyalty_settings
    ├── meta
    ├── banners/items/
    ├── popups/items/
    └── promotions/items/
```

**Current `restaurantId`:** `'delizza'` (constant `kRestaurantId` in `firestore_paths.dart`)

### 2.2 Document ID Format

**The service ACCEPTS STRINGS as document IDs, not strictly enums.**

From `builder_layout_service.dart`:

```dart
// Draft document reference
DocumentReference _getDraftRef(String appId, BuilderPageId pageId) {
  return FirestorePaths.draftDoc(pageId.value);  // pageId.value is a String
}

// Published document reference  
DocumentReference _getPublishedRef(String appId, BuilderPageId pageId) {
  return FirestorePaths.publishedDoc(pageId.value);  // pageId.value is a String
}

// Direct document access by string ID (for custom pages)
Future<BuilderPage?> loadPublishedByDocId(String appId, String docId) async {
  final ref = FirestorePaths.publishedDoc(docId);  // docId is any String
  // ...
}
```

**Conclusion:**
- Document IDs are **String values** (`'home'`, `'menu'`, `'profile'`, `'promo_noel'`, etc.)
- The `BuilderPageId` enum is used for type safety in code but converted to `.value` strings for Firestore
- Custom pages can use any string as document ID

### 2.3 Draft vs Published Collections

| Collection | Path | Purpose | When Used |
|------------|------|---------|-----------|
| `pages_draft` | `restaurants/{restaurantId}/pages_draft/{pageId}` | Editor working copy | Admin editing |
| `pages_published` | `restaurants/{restaurantId}/pages_published/{pageId}` | Live content | Client runtime |
| `pages_system` | `restaurants/{restaurantId}/pages_system/{pageId}` | Navigation structure | App navigation |

---

## 3. The Routing Logic (dynamic_page_resolver.dart)

### 3.1 Route to Document ID Mapping

From `_routeToPageId()` method (lines 258-276):

```dart
BuilderPageId? _routeToPageId(String route) {
  // Use SystemPages registry for consistent mapping
  final config = SystemPages.getConfigByRoute(route);
  if (config != null) {
    return config.pageId;
  }
  
  // Fallback for custom pages not in system registry
  switch (route) {
    case '/promo':
      return BuilderPageId.promo;
    case '/about':
      return BuilderPageId.about;
    case '/contact':
      return BuilderPageId.contact;
    default:
      return null;
  }
}
```

### 3.2 Route → Document ID Mapping Table

**Primary Mappings (from SystemPages registry in `system_pages.dart`):**

| Route | Firestore Document ID | BuilderPageId Enum | Is System Page |
|-------|----------------------|-------------------|----------------|
| `/home` | `home` | `BuilderPageId.home` | ❌ No |
| `/menu` | `menu` | `BuilderPageId.menu` | ❌ No |
| `/cart` | `cart` | `BuilderPageId.cart` | ✅ Yes |
| `/profile` | `profile` | `BuilderPageId.profile` | ✅ Yes |
| `/rewards` | `rewards` | `BuilderPageId.rewards` | ✅ Yes |
| `/roulette` | `roulette` | `BuilderPageId.roulette` | ✅ Yes |

**Hardcoded Fallback Mappings (switch cases):**

| Route | Firestore Document ID | Notes |
|-------|----------------------|-------|
| `/promo` | `promo` | Not in SystemPages registry, uses fallback switch |
| `/about` | `about` | Not in SystemPages registry, uses fallback switch |
| `/contact` | `contact` | Not in SystemPages registry, uses fallback switch |

### 3.3 Custom Page Resolution

From `resolveByKey()` method (lines 116-160):

**Resolution Priority:**
1. **Try system page match:** If `pageKey` matches a `BuilderPageId` enum, resolve as system page
2. **Direct Firestore lookup:** Load from `pages_published/{pageKey}` directly by document ID
3. **Search by `pageKey` field:** Iterate all published pages looking for matching `pageKey` field
4. **Search by route `/page/{pageKey}`:** Iterate all published pages looking for matching route

---

## 4. System Defaults (system_pages_initializer.dart & builder_pages_registry.dart)

### 4.1 System Pages Expected to Exist

From `SystemPagesInitializer.systemPages` (lines 41-70 in `system_pages_initializer.dart`):

| Page ID | Title | Route | Icon | Description |
|---------|-------|-------|------|-------------|
| `profile` | Profil | `/profile` | `person` | Page de profil utilisateur (page système) |
| `cart` | Panier | `/cart` | `shopping_cart` | Page panier (page système) |
| `rewards` | Récompenses | `/rewards` | `card_giftcard` | Page des récompenses (page système) |
| `roulette` | Roulette | `/roulette` | `casino` | Page de la roue de la chance (page système) |

### 4.2 Default Values When Creating Missing System Pages

When the initializer creates a missing system page (lines 123-143):

```dart
final page = BuilderPage(
  pageId: config.pageId,          // e.g., BuilderPageId.profile
  appId: appId,                   // e.g., 'delizza'
  name: config.title,             // e.g., 'Profil'
  description: config.description, // e.g., 'Page de profil utilisateur (page système)'
  route: config.route,            // e.g., '/profile'
  blocks: [],                     // Empty blocks array
  isEnabled: true,                // Enabled by default
  isDraft: true,                  // Created as draft first
  displayLocation: 'hidden',      // Not in bottom nav by default
  icon: config.icon,              // e.g., 'person'
  order: 999,                     // High order (not visible in nav)
  isSystemPage: true,             // Protected from deletion
);
```

### 4.3 Builder Pages Registry (Non-System)

From `BuilderPagesRegistry.pages` (lines 25-61 in `builder_pages_registry.dart`):

| Page ID | Name | Route | Icon | Description |
|---------|------|-------|------|-------------|
| `home` | Accueil | `/home` | 🏠 | Page d'accueil principale de l'application |
| `menu` | Menu | `/menu` | 📋 | Catalogue de produits et menu |
| `promo` | Promotions | `/promo` | 🎁 | Page des promotions et offres spéciales |
| `about` | À propos | `/about` | ℹ️ | Informations sur le restaurant |
| `contact` | Contact | `/contact` | 📞 | Coordonnées et formulaire de contact |

**Note:** These are **NOT** system pages (not protected) but are expected by the registry.

### 4.4 Complete SystemPages Registry (system_pages.dart)

From `SystemPages._registry` (lines 37-86):

| BuilderPageId | Route | Firestore ID | Default Name | Default Icon | Is System (Protected) |
|---------------|-------|--------------|--------------|--------------|----------------------|
| `home` | `/home` | `home` | Accueil | `Icons.home` | ❌ No |
| `menu` | `/menu` | `menu` | Menu | `Icons.restaurant_menu` | ❌ No |
| `cart` | `/cart` | `cart` | Panier | `Icons.shopping_cart` | ✅ Yes |
| `profile` | `/profile` | `profile` | Profil | `Icons.person` | ✅ Yes |
| `rewards` | `/rewards` | `rewards` | Récompenses | `Icons.card_giftcard` | ✅ Yes |
| `roulette` | `/roulette` | `roulette` | Roulette | `Icons.casino` | ✅ Yes |

---

## 5. Complete Schema Reference

### 5.1 BuilderPage Document Schema

**Collection:** `restaurants/{restaurantId}/pages_published/{pageId}`

```json
{
  // === IDENTITY ===
  "pageKey": "home",                    // String - Source of truth for page identity
  "pageId": "home",                     // String - Backward compatibility, matches enum value
  "appId": "delizza",                   // String - Restaurant identifier
  
  // === DISPLAY ===
  "name": "Accueil",                    // String - Display name
  "description": "Page d'accueil",      // String - Admin description
  "route": "/home",                     // String - Navigation route
  "icon": "home",                       // String - Material Icon name
  
  // === STATUS ===
  "isEnabled": true,                    // Boolean - Active/published
  "isDraft": false,                     // Boolean - Draft indicator
  "isActive": true,                     // Boolean - Navigation visibility
  "isSystemPage": false,                // Boolean - Protected page flag
  
  // === NAVIGATION ===
  "displayLocation": "bottomBar",       // String: "bottomBar" | "hidden" | "internal"
  "order": 0,                           // Integer - Legacy ordering
  "bottomNavIndex": 0,                  // Integer - Explicit bottom nav index (0-4 visible)
  
  // === TYPE ===
  "pageType": "system",                 // String: "template" | "blank" | "system" | "custom"
  
  // === CONTENT ===
  "blocks": [],                         // Array<Block> - Legacy field
  "draftLayout": [                      // Array<Block> - Editor working copy
    {
      "id": "block_123",
      "type": "hero",                   // String: "hero" | "banner" | "text" | "product_list" | "info" | "spacer" | "image" | "button" | "category_list" | "html" | "system"
      "order": 0,
      "config": {},
      "isActive": true,
      "visibility": "visible",          // String: "visible" | "hidden" | "mobile_only" | "desktop_only"
      "customStyles": null,
      "createdAt": "2025-01-01T00:00:00.000Z",
      "updatedAt": "2025-01-01T00:00:00.000Z"
    }
  ],
  "publishedLayout": [],                // Array<Block> - Live version
  "modules": ["menu_catalog"],          // Array<String> - Attached module IDs
  
  // === VERSIONING ===
  "version": 1,                         // Integer - Version number
  "hasUnpublishedChanges": false,       // Boolean - Draft changes indicator
  
  // === TIMESTAMPS ===
  "createdAt": "2025-01-01T00:00:00.000Z",   // Timestamp | String | Integer (epoch ms)
  "updatedAt": "2025-01-01T00:00:00.000Z",   // Timestamp | String | Integer (epoch ms)
  "publishedAt": "2025-01-01T00:00:00.000Z", // Timestamp | String | Integer (epoch ms) | null
  "lastModifiedBy": "admin_123",             // String | null
  
  // === SEO METADATA (optional) ===
  "metadata": {
    "title": "Page Title",
    "description": "SEO description",
    "keywords": "keywords, here",
    "ogImage": "https://...",
    "ogTitle": "OG Title",
    "ogDescription": "OG Description"
  }
}
```

### 5.2 BuilderBlock Schema

```json
{
  "id": "block_unique_id",              // String - Required (auto-generated if missing)
  "type": "hero",                       // String - Block type (defaults to "text")
  "order": 0,                           // Integer - Position (defaults to 0)
  "config": {                           // Object - Type-specific configuration
    // Varies by block type
  },
  "isActive": true,                     // Boolean - Visibility (defaults to true)
  "visibility": "visible",              // String - Responsive visibility
  "customStyles": null,                 // String | null - Custom CSS
  "createdAt": "...",                   // Timestamp | String | Integer
  "updatedAt": "..."                    // Timestamp | String | Integer
}
```

### 5.3 SystemBlock Schema (type: "system")

```json
{
  "id": "sysblock_123",
  "type": "system",
  "order": 0,
  "config": {
    "moduleType": "roulette"            // String: "roulette" | "loyalty" | "rewards" | "accountActivity"
  },
  "isActive": true,
  "visibility": "visible"
}
```

---

## 6. Production Database Checklist

### ✅ Required Documents Checklist

Use this checklist to verify your Firestore database:

#### 6.1 Restaurant Root Document
- [ ] `restaurants/delizza` exists

#### 6.2 System Pages (pages_system collection)
- [ ] `restaurants/delizza/pages_system/home`
- [ ] `restaurants/delizza/pages_system/menu`
- [ ] `restaurants/delizza/pages_system/cart`
- [ ] `restaurants/delizza/pages_system/profile`
- [ ] `restaurants/delizza/pages_system/rewards`
- [ ] `restaurants/delizza/pages_system/roulette`

#### 6.3 Published Pages (pages_published collection)
For each page visible to users:
- [ ] `restaurants/delizza/pages_published/home`
- [ ] `restaurants/delizza/pages_published/menu`
- [ ] `restaurants/delizza/pages_published/cart`
- [ ] `restaurants/delizza/pages_published/profile`
- [ ] `restaurants/delizza/pages_published/rewards`
- [ ] `restaurants/delizza/pages_published/roulette`
- [ ] Any custom pages: `restaurants/delizza/pages_published/{custom_page_key}`

#### 6.4 Draft Pages (pages_draft collection)
For pages being edited:
- [ ] Check if drafts exist: `restaurants/delizza/pages_draft/{pageId}`

#### 6.5 Builder Settings
- [ ] `restaurants/delizza/builder_settings/home_config`
- [ ] `restaurants/delizza/builder_settings/theme`
- [ ] `restaurants/delizza/builder_settings/app_texts`
- [ ] `restaurants/delizza/builder_settings/loyalty_settings`
- [ ] `restaurants/delizza/builder_settings/meta`

### ✅ Field Validation Checklist

For each page document, verify:

#### Mandatory Fields
- [ ] `pageKey` OR `pageId` exists (at least one)
- [ ] `route` is not empty and not `'/'`
- [ ] `name` OR `title` exists (at least one)

#### System Page Specific
- [ ] `isSystemPage: true` for cart, profile, rewards, roulette
- [ ] `displayLocation` is `'bottomBar'` or `'hidden'` for system pages

#### Navigation Fields
- [ ] `bottomNavIndex` between 0-4 for visible nav items
- [ ] `isActive: true` for visible pages
- [ ] `displayLocation: 'bottomBar'` OR `bottomNavIndex <= 4` for nav visibility

#### Content Fields
- [ ] `publishedLayout` is an array (can be empty)
- [ ] Each block in `publishedLayout` has valid `id` and `type`

### ✅ Common Issues to Check

1. **Route Conflicts:** No two pages should have the same route
2. **Missing pageKey:** Custom pages must have `pageKey` set
3. **Invalid Routes:** Routes should start with `/` and not be empty
4. **System Page Protection:** System pages should have `isSystemPage: true`
5. **Timestamp Types:** `createdAt`/`updatedAt` should be Firestore Timestamps or ISO strings
6. **Block IDs:** All blocks should have unique `id` values
7. **Module Types:** SystemBlocks should have valid `moduleType` values

---

## Appendix A: Enum Values Reference

### BuilderPageId Values
```
home, menu, promo, about, contact, profile, cart, rewards, roulette
```

### BlockType Values
```
hero, banner, text, product_list, info, spacer, image, button, category_list, html, system
```

### BlockVisibility Values
```
visible, hidden, mobile_only, desktop_only
```

### BuilderPageType Values
```
template, blank, system, custom
```

### DisplayLocation Values
```
bottomBar, hidden, internal
```

### SystemBlock ModuleType Values
```
roulette, loyalty, rewards, accountActivity
```

---

*End of Document*
