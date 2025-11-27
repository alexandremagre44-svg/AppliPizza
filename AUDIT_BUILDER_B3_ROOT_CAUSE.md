# 🔍 AUDIT BUILDER B3 - ROOT CAUSE ANALYSIS

> **Date**: 2025-11-27  
> **Projet**: pizza_delizza (Flutter)  
> **RestaurantId**: `delizza`  
> **Statut**: AUDIT UNIQUEMENT (aucune modification de code)

---

## A) PIPELINE BOTTOM-NAV (de bout en bout)

### 1. Point d'entrée UI

**Fichier**: `lib/src/widgets/scaffold_with_nav_bar.dart:24-27`

```dart
final bottomBarPagesProvider = FutureProvider.autoDispose<List<BuilderPage>>((ref) async {
  final service = BuilderNavigationService(kRestaurantId);
  return await service.getBottomBarPages();
});
```

### 2. Chaîne d'appels complète

```
ScaffoldWithNavBar.build()                              [scaffold_with_nav_bar.dart:38]
└→ bottomBarPagesProvider                               [ligne 24-27]
    └→ BuilderNavigationService(kRestaurantId)          [builder_navigation_service.dart:50-54]
        └→ BuilderLayoutService.getBottomBarPages()     [builder_layout_service.dart:598-627]
            ├→ loadSystemPages()                        [ligne 601]
            │   └→ FirestorePaths.pagesSystem().get()   [Firestore query]
            │       └→ BuilderPage.fromJson(data)       [builder_page.dart:304-374]
            ├→ _isBottomBarPage(page)                   [ligne 605] → filtre
            └→ _sortByBottomNavIndex(pages)             [ligne 609] → tri
```

### 3. Collections Firestore utilisées

| Collection | Path Firestore | Fichier qui l'utilise |
|------------|----------------|----------------------|
| `pages_system` | `restaurants/{restaurantId}/pages_system/{pageId}` | `builder_layout_service.dart:460-495` |
| `pages_draft` | `restaurants/{restaurantId}/pages_draft/{pageId}` | `builder_layout_service.dart` |
| `pages_published` | `restaurants/{restaurantId}/pages_published/{pageId}` | `builder_layout_service.dart`, `dynamic_page_resolver.dart` |

### 4. Conditions d'affichage dans la Bottom Bar

**Fichier**: `builder_layout_service.dart:556-580`

Une page **APPARAÎT** dans la bottom bar si:

```dart
// Condition 1: Route valide (OBLIGATOIRE)
page.route.isNotEmpty && page.route != '/'

// ET Condition 2a (Logique B3):
page.isActive == true 
&& page.bottomNavIndex != null 
&& page.bottomNavIndex >= 0 
&& page.bottomNavIndex <= 4

// OU Condition 2b (Fallback legacy):
page.displayLocation == 'bottomBar' 
&& page.order >= 0 
&& page.order <= 4
```

### 5. ROOT CAUSE #1: Label "Page" générique

**Fichier**: `builder_page.dart:336-341`

```dart
final defaultName = systemConfig?.defaultName ?? 'Page';  // ← ligne 336
final pageName = json['name'] as String? ?? json['title'] as String? ?? defaultName;  // ← ligne 341
```

**Condition de déclenchement**:
- `json['name']` est `null` dans Firestore
- ET `json['title']` est `null` dans Firestore  
- ET `systemConfig` n'existe pas pour ce `pageId`
- **Résultat**: Label affiché = `'Page'`

**Preuve**: Si un document dans `pages_system` n'a ni `name` ni `title`, le label sera "Page".

### 6. ROOT CAUSE #2: Pages non visibles dans la Bottom Bar

**Fichier**: `builder_layout_service.dart:559-579`

Une page est **EXCLUE** si:

| Condition | Ligne | Effet |
|-----------|-------|-------|
| `page.route.isEmpty` | 559 | Filtré (warning log) |
| `page.route == '/'` | 559 | Filtré (warning log) |
| `page.isActive == false` | 565 | Filtré |
| `page.bottomNavIndex == null` | 566 | Filtré (sauf fallback) |
| `page.bottomNavIndex < 0 ou > 4` | 567-568 | Filtré |

---

## B) PIPELINE NAVIGATION → GoRouter → ÉCRAN

### 1. Clic sur un onglet

**Fichier**: `scaffold_with_nav_bar.dart:319-345`

```dart
void _onItemTapped(BuildContext context, int index, List<_NavPage> pages, ...) {
  // Admin = dernier item
  if (isAdmin && index == items.length - 1) {
    context.go(AppRoutes.adminStudio);
    return;
  }
  
  // Navigation normale
  final route = pages[index].route;
  
  // Protection route invalide
  if (route.isEmpty || route == '/') {
    debugPrint('⚠️ Attempted navigation to invalid route: "$route"');
    context.go(AppRoutes.home);  // Fallback vers /home
    return;
  }
  
  context.go(route);
}
```

### 2. ROOT CAUSE #3: Redirection vers login

**Mécanisme**:
1. Si `route == '/'` ou `route == ''` dans Firestore
2. Le code filtre la page (ligne 559) → page n'apparaît pas OU
3. Si la page passe quand même, `context.go('/')` déclenche le splash/login guard

**Fichier GoRouter**: Vérifié dans `app_router.dart` - le path `/` redirige vers splash/login.

### 3. Écran de rendu: BuilderPageLoader → DynamicPageRouter

**Chaîne d'exécution**:
```
GoRouter match route (ex: '/menu')
└→ BuilderPageLoader (widget)
    └→ loadPublishedPage(pageId) / loadDraftPage(pageId)
        └→ BuilderPage.fromJson(data)
    └→ DynamicBuilderPageScreen
        └→ buildPageFromBuilder(context, page)  [dynamic_page_router.dart:27-60]
```

### 4. ROOT CAUSE #4: "Page vide"

**Fichier**: `dynamic_page_router.dart:27-60`

```dart
Widget buildPageFromBuilder(BuildContext context, BuilderPage page) {
  List<BuilderBlock> blocksToRender = [];
  
  // Priorité: published > draft > blocks (legacy)
  if (page.publishedLayout.isNotEmpty) {
    blocksToRender = page.publishedLayout;
  } else if (page.draftLayout.isNotEmpty) {
    blocksToRender = page.draftLayout;
  } else if (page.blocks.isNotEmpty) {
    blocksToRender = page.blocks;
  }
  
  if (blocksToRender.isNotEmpty) {
    return BuilderRuntimeRenderer(blocks: blocksToRender, ...);
  }
  
  // Fallback système pour menu/cart/profile/roulette
  final systemModuleFallback = _getSystemModuleFallback(page.pageId);
  if (systemModuleFallback != null) {
    return builder_modules.renderModule(context, systemModuleFallback);
  }
  
  // SINON → "Page vide"
  return _buildEmptyPageState(context, page.name);
}
```

**Condition de déclenchement "Page vide"**:
- `publishedLayout` est vide/absent
- ET `draftLayout` est vide/absent
- ET `blocks` (legacy) est vide/absent
- ET ce n'est PAS une page système (menu/cart/profile/roulette)

**Note**: Les pages système ont un fallback module automatique (lignes 66-79).

---

## C) FIRESTORE: Schéma attendu vs champs utilisés

### 1. Collection `pages_system/{pageId}`

| Champ | Type attendu | Obligatoire | Défaut si absent | Fichier:ligne |
|-------|--------------|-------------|------------------|---------------|
| `pageId` | `String` | Non | `doc.id` | builder_page.dart:305 |
| `name` | `String` | Non | `json['title']` → `systemConfig.defaultName` → `'Page'` | builder_page.dart:341 |
| `title` | `String` | Non | - (fallback pour name) | builder_page.dart:341 |
| `route` | `String` | **OUI** | `systemConfig.route` → `'/'` ⚠️ | builder_page.dart:348 |
| `icon` | `String` | Non | `systemConfig.defaultIcon` → `'help_outline'` | builder_page.dart:362 |
| `bottomNavIndex` | `int` | **OUI pour nav** | `json['order']` → `999` | builder_page.dart:368 |
| `order` | `int` | Non | `999` | builder_page.dart:363 |
| `isActive` | `bool` | Non | `true` | builder_page.dart:367 |
| `displayLocation` | `String` | Non | `'hidden'` | builder_page.dart:361 |
| `isSystemPage` | `bool` | Non | `pageId.isSystemPage` | builder_page.dart:364 |
| `createdAt` | `Timestamp/String/int/null` | Non | `DateTime.now()` | builder_page.dart:357 |
| `updatedAt` | `Timestamp/String/int/null` | Non | `DateTime.now()` | builder_page.dart:358 |

### 2. Collection `pages_published/{pageId}`

Mêmes champs que `pages_system`, plus:

| Champ | Type attendu | Obligatoire | Défaut si absent |
|-------|--------------|-------------|------------------|
| `publishedLayout` | `List<Map>` | Non | `[]` |
| `draftLayout` | `List<Map>` | Non | Copie de `blocks` |
| `blocks` | `List<Map>` (legacy) | Non | `[]` |

### 3. Structure d'un bloc

**Fichier**: `builder_block.dart:110-133`

| Champ | Type attendu | Obligatoire | Défaut si absent |
|-------|--------------|-------------|------------------|
| `id` | `String` | Non | `block_{timestamp}_{hash}` (généré) |
| `type` | `String` | Non | `'text'` |
| `order` | `int` | Non | `0` |
| `config` | `Map<String, dynamic>` | Non | `{}` |
| `isActive` | `bool` | Non | `true` |
| `visibility` | `String` | Non | `'visible'` |
| `customStyles` | `String?` | Non | `null` |
| `createdAt` | `Timestamp/String/int/null` | Non | `DateTime.now()` |
| `updatedAt` | `Timestamp/String/int/null` | Non | `DateTime.now()` |

---

## D) AUDIT PARSING FIRESTORE (CRITIQUE)

### 1. Points de parsing sécurisés (CORRIGÉS)

| Champ | Fichier:ligne | Avant | Après |
|-------|---------------|-------|-------|
| `createdAt` | builder_page.dart:357 | `DateTime.parse(json['createdAt'] as String)` | `safeParseDateTime(json['createdAt'])` ✅ |
| `updatedAt` | builder_page.dart:358 | `DateTime.parse(json['updatedAt'] as String)` | `safeParseDateTime(json['updatedAt'])` ✅ |
| `publishedAt` | builder_page.dart:359 | `DateTime.parse(...)` | `safeParseDateTime(...)` ✅ |
| `createdAt` (bloc) | builder_block.dart:130 | Cast direct | `safeParseDateTime(...)` ✅ |
| `updatedAt` (bloc) | builder_block.dart:131 | Cast direct | `safeParseDateTime(...)` ✅ |

### 2. Fonction `safeParseDateTime` 

**Fichier**: `lib/builder/utils/firestore_parsing_helpers.dart:20-46`

```dart
DateTime? safeParseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();  // ✅ Firestore Timestamp
  if (value is String) return DateTime.parse(value);  // ✅ ISO 8601
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);  // ✅ Epoch ms
  return null;  // ⚠️ Warning log si type inconnu
}
```

### 3. Parsing des layouts (blocs)

**Fichier**: `builder_page.dart:251-301` (`_safeLayoutParse`)

```dart
static List<BuilderBlock> _safeLayoutParse(dynamic value) {
  if (value == null) return [];
  if (value is List<dynamic>) {
    final validBlocks = <BuilderBlock>[];
    for (int i = 0; i < value.length; i++) {
      try {
        // Parse chaque bloc individuellement
        validBlocks.add(BuilderBlock.fromJson(item));
      } catch (e) {
        // Skip bloc malformé avec warning (pas de crash global)
        print('⚠️ Skipping malformed block at index $i: $e');
      }
    }
    return validBlocks;
  }
  return [];  // String legacy ("none") → liste vide
}
```

---

## E) SUPPORT DES PAGES CUSTOM

### 1. ROOT CAUSE #5: Pages custom converties en "home"

**Fichier**: `builder_enums.dart:47-56`

```dart
static BuilderPageId fromString(String value) {
  final found = BuilderPageId.values.where((e) => e.value == value);
  if (found.isNotEmpty) {
    return found.first;
  }
  // ⚠️ PROBLÈME: pageId inconnu → fallback silencieux vers home
  print('⚠️ [BuilderPageId] Unknown pageId: "$value". Falling back to home.');
  return BuilderPageId.home;  // ← Conversion silencieuse!
}
```

**Impact**:
- Une page custom avec `pageId: "promo_noel"` devient `BuilderPageId.home`
- La route de la page custom est ignorée
- L'écran affiché est celui de "home", pas la page custom

### 2. Pages reconnues par l'enum

**Fichier**: `builder_enums.dart:8-36`

| pageId | Label | Type |
|--------|-------|------|
| `home` | Accueil | Standard |
| `menu` | Menu | Standard |
| `promo` | Promotions | Standard |
| `about` | À propos | Standard |
| `contact` | Contact | Standard |
| `profile` | Profil | **Système** |
| `cart` | Panier | **Système** |
| `rewards` | Récompenses | **Système** |
| `roulette` | Roulette | **Système** |

**Tout autre pageId** → Fallback vers `home` avec warning ⚠️

---

## F) RÉSUMÉ DES ROOT CAUSES

| # | Problème | Cause | Fichier:ligne |
|---|----------|-------|---------------|
| 1 | Label "Page" | `name` ET `title` absents dans Firestore | builder_page.dart:341 |
| 2 | Page non visible | `route` vide/`'/'` OU `bottomNavIndex` null/invalide | builder_layout_service.dart:559-568 |
| 3 | Redirection login | `route == '/'` → GoRouter splash guard | scaffold_with_nav_bar.dart:337-340 |
| 4 | "Page vide" | `publishedLayout` + `draftLayout` + `blocks` tous vides | dynamic_page_router.dart:31-40 |
| 5 | Page custom → home | pageId inconnu dans enum → fallback `home` | builder_enums.dart:55 |

---

## G) STATUT DES CORRECTIONS APPLIQUÉES

| Correction | Statut | Commit |
|------------|--------|--------|
| `safeParseDateTime()` pour Timestamp/null | ✅ | PR actuelle |
| Fallback `title` → `name` | ✅ | PR actuelle |
| Fallback `publishedLayout` → `draftLayout` → `blocks` | ✅ | PR actuelle |
| System page fallback (menu/cart/profile/roulette) | ✅ | PR actuelle |
| Warning pour pageId inconnu | ✅ | PR actuelle |
| Parsing blocs tolérant (skip malformed) | ✅ | PR actuelle |
| Script de normalisation Firestore | ✅ | `scripts/normalize_builder_firestore.mjs` |

---

## H) RECOMMANDATIONS

### Pour éviter les problèmes futurs:

1. **Toujours renseigner `name` dans Firestore** (ou au moins `title`)
2. **Toujours renseigner une `route` valide** (ex: `/menu`, jamais `/` seul)
3. **Renseigner `bottomNavIndex` 0-4** pour les pages de la bottom bar
4. **Pour les pages custom**: envisager de modifier l'enum pour accepter des pageId dynamiques

### Script de normalisation:

```bash
# Preview des modifications
node scripts/normalize_builder_firestore.mjs --dry-run

# Appliquer les corrections
node scripts/normalize_builder_firestore.mjs
```

---

*Fin de l'audit - Aucune modification de code effectuée*
