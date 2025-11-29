# 🔍 AUDIT TECHNIQUE COMPLET - PIPELINE TEMPLATE / PAGE VIERGE

**Date :** 29 novembre 2025  
**Objectif :** Analyse forensique des flux de création de pages (template vs vierge) dans le Builder B3  
**Méthodologie :** Audit non destructif - AUCUNE modification de code  

---

## 📋 TABLE DES MATIÈRES

1. [Liste des fichiers et fonctions impliqués](#1-liste-des-fichiers-et-fonctions-impliqués)
2. [Pipeline "Créer une page template"](#2-pipeline-créer-une-page-template)
3. [Pipeline "Créer une page vierge"](#3-pipeline-créer-une-page-vierge)
4. [Pipeline "Charger une page dans le Builder"](#4-pipeline-charger-une-page-dans-le-builder)
5. [Pipeline "Charger une page côté client"](#5-pipeline-charger-une-page-côté-client)
6. [Chemins Firestore et champs utilisés](#6-chemins-firestore-et-champs-utilisés)
7. [Divergences possibles identifiées](#7-divergences-possibles-identifiées)
8. [Hypothèses classées sur la cause la plus probable](#8-hypothèses-classées-sur-la-cause-la-plus-probable)

---

## 1. LISTE DES FICHIERS ET FONCTIONS IMPLIQUÉS

### 1.1 Modèles

| Fichier | Éléments clés |
|---------|---------------|
| `lib/builder/models/builder_page.dart` | `BuilderPage` (pageKey, systemId, pageId, appId, draftLayout, publishedLayout, blocks, isSystemPage, isActive, bottomNavIndex, pageType, isTemplate) |
| `lib/builder/models/builder_enums.dart` | `BuilderPageId` (home, menu, promo, about, contact, profile, cart, rewards, roulette), `BuilderPageType` (template, blank, system, custom) |
| `lib/builder/models/system_pages.dart` | `SystemPages` (registre des pages système), `SystemPageConfig` |
| `lib/builder/models/builder_block.dart` | `BuilderBlock`, `SystemBlock` |

### 1.2 Services

| Fichier | Fonctions clés |
|---------|----------------|
| `lib/builder/services/builder_page_service.dart` | `createPageFromTemplate()`, `createBlankPage()`, `updateDraftLayout()`, `publishPage()`, `toggleActiveStatus()`, `fixEmptySystemPages()`, `initializeSpecificPageDraft()` |
| `lib/builder/services/builder_layout_service.dart` | `saveDraft()`, `loadDraft()`, `loadPublished()`, `publishPage()`, `loadAllDraftPages()`, `loadAllPublishedPages()`, `loadSystemPages()`, `getBottomBarPages()` |
| `lib/builder/services/builder_navigation_service.dart` | `getBottomBarPages()`, `_ensureMinimumPages()`, `_getDefaultBlocksForPage()` |
| `lib/builder/services/dynamic_page_resolver.dart` | `resolve()`, `resolveByRoute()`, `resolveByKey()`, `resolveSystemPage()` |
| `lib/builder/services/default_page_creator.dart` | `createDefaultPage()`, `ensurePageExists()`, `_buildDefaultBlocks()` |

### 1.3 Écrans (UI)

| Fichier | Rôle |
|---------|------|
| `lib/builder/page_list/new_page_dialog_v2.dart` | Dialog de création de page (choix template ou vierge) |
| `lib/builder/page_list/builder_page_list_screen.dart` | Liste des pages (Active/Inactive) |
| `lib/builder/editor/builder_page_editor_screen.dart` | Écran d'édition des blocs |
| `lib/builder/runtime/dynamic_builder_page_screen.dart` | Affichage runtime côté client |

### 1.4 Firestore Paths

| Fichier | Collections |
|---------|-------------|
| `lib/src/core/firestore_paths.dart` | `pages_draft`, `pages_published`, `pages_system`, `builder_settings/meta` |

---

## 2. PIPELINE "CRÉER UNE PAGE TEMPLATE"

### 2.1 Flux d'exécution

```
[NewPageDialogV2] 
    │
    ├─ User choisit "Page à partir d'un template"
    │
    ├─ User sélectionne un template (home_template, menu_template, etc.)
    │
    ├─ Clic sur "Créer la page"
    │
    └─▶ [BuilderPageService.createPageFromTemplate()]
         │
         ├─ 1. _getTemplateBlocks(templateId)
         │      → Retourne List<BuilderBlock> prédéfinis pour ce template
         │
         ├─ 2. _generatePageId(name)
         │      → Génère pageKey en snake_case
         │      → Ex: "Ma Page Promo" → "ma_page_promo"
         │
         ├─ 3. BuilderPageId.tryFromString(pageKey)
         │      → Retourne null pour pages custom
         │      → Retourne BuilderPageId si match (home, menu, cart, profile...)
         │
         ├─ 4. Création BuilderPage avec:
         │      • pageKey = pageKeyValue généré
         │      • systemId = null (pour custom) ou BuilderPageId
         │      • pageType = BuilderPageType.template
         │      • route = '/page/$pageKeyValue' (pour custom)
         │      • blocks = templateBlocks
         │      • draftLayout = templateBlocks
         │      • publishedLayout = [] (vide!)
         │      • hasUnpublishedChanges = true
         │      • isActive = true
         │      • bottomNavIndex = order (ou 999)
         │
         └─ 5. _layoutService.saveDraft(page)
                → Sauvegarde dans pages_draft/{pageKey}
```

### 2.2 Templates disponibles

| Template ID | Blocs générés |
|-------------|---------------|
| `home_template` | HeroBlock + ProductListBlock + InfoBlock |
| `menu_template` | SystemBlock(menu_catalog) |
| `cart_template` | SystemBlock(cart_module) |
| `profile_template` | SystemBlock(profile_module) |
| `roulette_template` | SystemBlock(roulette_module) |
| `promo_template` | BannerBlock + TextBlock + ProductListBlock |
| `about_template` | TextBlock (titre) + ImageBlock + TextBlock (contenu) |
| `contact_template` | TextBlock (titre) + InfoBlock + TextBlock (horaires) |

### 2.3 Points critiques

1. **publishedLayout = [] à la création** → La page n'est PAS publiée immédiatement
2. **hasUnpublishedChanges = true** → Flag correct
3. **route = '/page/$pageKeyValue'** → Route dynamique pour custom pages
4. **Sauvegarde UNIQUEMENT dans pages_draft** → PAS dans pages_published

---

## 3. PIPELINE "CRÉER UNE PAGE VIERGE"

### 3.1 Flux d'exécution

```
[NewPageDialogV2]
    │
    ├─ User choisit "Page vierge"
    │
    ├─ User entre un nom de page
    │
    ├─ Clic sur "Créer la page"
    │
    └─▶ [BuilderPageService.createBlankPage()]
         │
         ├─ 1. _generatePageId(name)
         │      → Génère pageKey en snake_case
         │
         ├─ 2. BuilderPageId.tryFromString(pageKey)
         │      → Retourne null pour pages custom
         │
         ├─ 3. Création BuilderPage avec:
         │      • pageKey = pageKeyValue généré
         │      • systemId = null (pour custom)
         │      • pageType = BuilderPageType.blank
         │      • route = '/page/$pageKeyValue'
         │      • blocks = [] (VIDE!)
         │      • draftLayout = [] (VIDE!)
         │      • publishedLayout = [] (VIDE!)
         │      • hasUnpublishedChanges = false (car vide)
         │      • isActive = true
         │      • bottomNavIndex = order (ou 999)
         │
         └─ 4. _layoutService.saveDraft(page)
                → Sauvegarde dans pages_draft/{pageKey}
```

### 3.2 Différences avec page template

| Aspect | Template | Blank |
|--------|----------|-------|
| pageType | `BuilderPageType.template` | `BuilderPageType.blank` |
| blocks | Préremplis | `[]` |
| draftLayout | Préremplis | `[]` |
| hasUnpublishedChanges | `true` | `false` |

### 3.3 Point critique

- **La page vierge est créée avec TOUS les layouts vides** → Potentiel problème si le client essaie de l'afficher avant publication

---

## 4. PIPELINE "CHARGER UNE PAGE DANS LE BUILDER"

### 4.1 Flux d'exécution (BuilderPageEditorScreen)

```
[BuilderPageEditorScreen._loadPage()]
    │
    ├─ 1. Déterminer pageIdentifier
    │      → widget.pageId (pour system pages)
    │      → widget.pageKey (pour custom pages)
    │
    ├─ 2. _service.loadDraft(appId, pageIdentifier)
    │      │
    │      └─▶ [BuilderLayoutService.loadDraft()]
    │           │
    │           ├─ Lecture pages_draft/{pageId}
    │           │
    │           ├─ Si document existe ET draftLayout.isNotEmpty:
    │           │   → Retourne page
    │           │
    │           ├─ Si document existe MAIS draftLayout.isEmpty:
    │           │   ├─ Log warning
    │           │   ├─ Tente loadPublished()
    │           │   └─ Si publishedLayout.isNotEmpty:
    │           │       ├─ Copie publishedLayout → draftLayout
    │           │       ├─ *** SELF-HEAL: saveDraft() ***
    │           │       └─ Retourne page
    │           │
    │           └─ Si document n'existe pas:
    │               ├─ Tente loadPublished()
    │               └─ Si exists → même logique de copie
    │
    ├─ 3. Si page.draftLayout.isEmpty ET widget.pageId != null:
    │      │
    │      └─ _pageService.initializeSpecificPageDraft()
    │           → Injecte blocs par défaut pour system pages
    │           → Sauvegarde dans pages_draft UNIQUEMENT
    │
    ├─ 4. Si page == null ET widget.pageId != null:
    │      │
    │      └─ _service.createDefaultPage()
    │           → Crée page système par défaut
    │
    └─ 5. _verifySystemPageIntegrity(page)
         → Corrige isSystemPage, displayLocation, icon si nécessaire
```

### 4.2 Fonctions utilisées dans l'éditeur

```dart
// Récupérer les blocs à afficher
final blocksToRender = _page!.draftLayout.isNotEmpty 
    ? _page!.draftLayout 
    : _page!.blocks;
```

### 4.3 Points critiques

1. **loadDraft() a un fallback vers published** + SELF-HEAL (sauvegarde)
2. **initializeSpecificPageDraft()** ne s'exécute QUE si:
   - `draftLayout.isEmpty` 
   - ET `publishedLayout.isEmpty` (vérifié dans la fonction)
   - ET pageId est un system page
3. **Pour custom pages sans pageId** (pageKey only):
   - Pas d'auto-init possible
   - Si draft vide et published vide → page reste vide

---

## 5. PIPELINE "CHARGER UNE PAGE CÔTÉ CLIENT"

### 5.1 Flux d'exécution (DynamicBuilderPageScreen)

```
[DynamicBuilderPageScreen.build()]
    │
    ├─ 1. Obtenir appId depuis currentRestaurantProvider
    │
    ├─ 2. DynamicPageResolver().resolveByKey(pageKey, appId)
    │      │
    │      └─▶ [DynamicPageResolver.resolveByKey()]
    │           │
    │           ├─ 1. BuilderPageId.tryFromString(pageKey)
    │           │      → Si match system page → resolve(pageId, appId)
    │           │
    │           ├─ 2. _layoutService.loadPublishedByDocId(appId, pageKey)
    │           │      → Lecture pages_published/{pageKey}
    │           │      → Retourne si exists ET isEnabled
    │           │
    │           └─ 3. Fallback: loadAllPublishedPages() + recherche par pageKey ou route
    │
    ├─ 3. Sélection des blocs à afficher:
    │      │
    │      └─ blocksToRender = 
    │           publishedLayout.isNotEmpty ? publishedLayout
    │           : draftLayout.isNotEmpty ? draftLayout
    │           : blocks
    │
    └─ 4. Si hasContent → BuilderRuntimeRenderer(blocks)
         Sinon → "Aucun contenu configuré"
```

### 5.2 Différence critique Builder vs Runtime

| Aspect | Builder (Éditeur) | Runtime (Client) |
|--------|-------------------|------------------|
| Collection lue | `pages_draft` (fallback published) | `pages_published` |
| Méthode | `loadDraft()` | `resolveByKey()` → `loadPublishedByDocId()` |
| Layout utilisé | `draftLayout` | `publishedLayout` > `draftLayout` > `blocks` |
| Self-heal | OUI (saveDraft) | NON |

---

## 6. CHEMINS FIRESTORE ET CHAMPS UTILISÉS

### 6.1 Collections

```
restaurants/{appId}/
    ├── pages_draft/{pageKey}          ← ÉDITEUR écrit/lit (brouillons)
    ├── pages_published/{pageKey}      ← RUNTIME lit (pages publiées)
    ├── pages_system/{pageKey}         ← LEGACY (encore référencé mais remplacé)
    └── builder_settings/
            └── meta                   ← Flag autoInitDone
```

### 6.2 Champs du document BuilderPage

```javascript
{
  // Identifiants
  "pageKey": "ma_page_custom",           // Document ID (source of truth)
  "pageId": "home" ou "ma_page_custom",  // String - pour compat ou custom
  
  // Metadata
  "appId": "delizza",
  "name": "Ma Page Custom",
  "description": "Description",
  "route": "/page/ma_page_custom",
  "icon": "home",
  
  // Layouts (CRITIQUES)
  "blocks": [...],                        // LEGACY - deprecated
  "draftLayout": [...],                   // ÉDITEUR - blocs en cours d'édition
  "publishedLayout": [...],               // RUNTIME - blocs publiés visibles client
  
  // Flags
  "isEnabled": true,
  "isDraft": true/false,
  "isActive": true/false,                 // Affiché dans bottom bar si true
  "isSystemPage": true/false,             // Page protégée (cart, profile...)
  "hasUnpublishedChanges": true/false,
  
  // Navigation
  "displayLocation": "bottomBar" | "hidden" | "internal",
  "bottomNavIndex": 0-4 ou 999,
  "order": 0-4 ou 999,
  
  // Type de page
  "pageType": "template" | "blank" | "system" | "custom",
  
  // Modules (optionnel)
  "modules": ["menu_catalog", "cart_module", ...],
  
  // Timestamps
  "createdAt": "...",
  "updatedAt": "...",
  "publishedAt": "..." ou null,
  "lastModifiedBy": "user_id" ou null,
  
  // Version
  "version": 1
}
```

### 6.3 Opérations par type de page

| Opération | Collection | Champs critiques |
|-----------|------------|------------------|
| Créer page template | `pages_draft/{pageKey}` | pageType=template, draftLayout=blocs, publishedLayout=[] |
| Créer page vierge | `pages_draft/{pageKey}` | pageType=blank, draftLayout=[], publishedLayout=[] |
| Auto-init system | `pages_published/{pageKey}` | pageType=system, isSystemPage=true, draftLayout+publishedLayout remplis |
| Charger dans Builder | `pages_draft` (fallback published) | Lit draftLayout |
| Charger côté client | `pages_published` | Lit publishedLayout > draftLayout > blocks |
| Publier | Copie draft → published | draftLayout → publishedLayout |

---

## 7. DIVERGENCES POSSIBLES IDENTIFIÉES

### 7.1 Page visible côté client mais vide/invisible dans Builder

#### Cause 1: Race condition avec fixEmptySystemPages (HAUTE PROBABILITÉ)

```
T0: getBottomBarPages() s'exécute
T1: fixEmptySystemPages() commence (injecte contenu dans published)
T2: Utilisateur ouvre l'éditeur AVANT fin de T1
T3: loadDraft() lit pages_draft (vide)
T4: fixEmptySystemPages() termine (published maintenant rempli)
T5: Client affiche contenu (lit published)
T6: Éditeur affiche page vide (a lu draft vide au T3)
```

**Solution déjà implémentée:** loadDraft() a un self-heal qui sauvegarde dans draft après copie depuis published.

**MAIS:** Si la page existe dans draft avec `draftLayout: []` et que published est rempli APRÈS, le self-heal ne se déclenche que si on recharge.

#### Cause 2: Page créée avec template mais jamais publiée

```
1. Admin crée page depuis template → pages_draft avec draftLayout rempli
2. Admin ne publie PAS
3. Client essaie de voir la page → pages_published N'EXISTE PAS
4. Client voit "Page introuvable"
```

**Mais l'inverse peut arriver:**
```
1. Auto-init crée pages published avec contenu
2. Draft n'existe pas
3. Builder ouvre → loadDraft fallback vers published + SELF-HEAL
4. DEVRAIT fonctionner maintenant grâce au self-heal
```

#### Cause 3: templateId qui ne génère pas de blocs

Dans `_getTemplateBlocks()`:
```dart
default:
  // Unknown template, return empty blocks
  return [];
```

Si un templateId non reconnu est passé → page créée sans blocs.

#### Cause 4: Custom pages sans pageId enum

Pour les pages custom:
- `systemId = null`
- `pageId = null` (car BuilderPageId.tryFromString retourne null)
- `initializeSpecificPageDraft()` NE S'EXÉCUTE PAS (vérifie widget.pageId != null)

**Conséquence:** Pages custom créées vierges restent vides même avec le fallback.

### 7.2 Exclusion des listes utilisées par le Builder

#### Cause 1: Filtre _isBottomBarPage trop strict

```dart
bool _isBottomBarPage(BuilderPage page) {
  // Route invalide → exclus
  if (page.route.isEmpty || page.route == '/') {
    return false;
  }
  
  // Page inactive → exclus
  if (!page.isActive) {
    return false;
  }
  
  // bottomNavIndex doit être 0-4
  if (page.bottomNavIndex >= 0 && page.bottomNavIndex <= 4) {
    return true;
  }
  
  // Fallback: displayLocation + order
  if (page.displayLocation == 'bottomBar' && page.order >= 0 && page.order <= 4) {
    return true;
  }
  
  return false;
}
```

**Pages exclues si:**
- `route == '/'` ou vide
- `isActive == false`
- `bottomNavIndex > 4` ou null/undefined
- `displayLocation != 'bottomBar'` ET pas de fallback

#### Cause 2: BuilderPageListScreen merge draft + published

```dart
// Merge pages - prefer draft if exists
final mergedPages = <String, BuilderPage>{};

for (final entry in publishedPages.entries) {
  mergedPages[entry.key] = entry.value; // Published d'abord
}

for (final entry in draftPages.entries) {
  mergedPages[entry.key] = entry.value; // Draft écrase si existe
}
```

**Risque:** Si une page existe UNIQUEMENT dans published (pas de draft), elle est visible dans la liste. Mais l'éditeur appelle `loadDraft()` qui fait un fallback + self-heal.

---

## 8. HYPOTHÈSES CLASSÉES SUR LA CAUSE LA PLUS PROBABLE

### Hypothèse 1: Custom pages sans auto-init (PROBABILITÉ: 80%)

**Description:**
Les pages créées via "Page vierge" ou avec un template non-système:
- Ont `pageType = blank` ou `template`
- Ont `pageId = null` (car custom)
- `initializeSpecificPageDraft()` ne s'exécute PAS (condition `widget.pageId != null`)
- `fixEmptySystemPages()` ne les traite PAS (condition `sysId == null → continue`)

**Conséquence:**
1. Page créée avec `draftLayout: []`
2. Admin quitte sans publier
3. Admin revient plus tard
4. `loadDraft()` charge page avec draft vide
5. Fallback vers published → MAIS published n'existe pas non plus
6. Éditeur affiche page vide

**Fichiers concernés:**
- `builder_page_service.dart:113-157` (createBlankPage)
- `builder_page_service.dart:727-878` (fixEmptySystemPages - ignore custom)
- `builder_page_editor_screen.dart:121-131` (initializeSpecificPageDraft condition)

---

### Hypothèse 2: Race condition auto-init vs éditeur (PROBABILITÉ: 10%)

**Description:**
L'auto-init système (`_ensureMinimumPages` + `fixEmptySystemPages`) s'exécute via `getBottomBarPages()` dans la navigation. Si l'utilisateur accède au Builder avant la fin, l'éditeur peut charger une version stale.

**Atténuation existante:**
- `loadDraft()` a maintenant un self-heal qui persiste la copie
- Mais ne fonctionne QUE si la condition `draftLayout.isEmpty` est vraie

**Fichiers concernés:**
- `builder_navigation_service.dart:59-91` (getBottomBarPages)
- `builder_layout_service.dart:158-214` (loadDraft avec self-heal)

---

### Hypothèse 3: templateId invalide passé à createPageFromTemplate (PROBABILITÉ: 5%)

**Description:**
Si `_getTemplateBlocks(templateId)` reçoit un ID non reconnu, elle retourne `[]`.

```dart
default:
  // Unknown template, return empty blocks
  return [];
```

La page est alors créée sans blocs malgré le choix "template".

**Fichiers concernés:**
- `builder_page_service.dart:1047-1073` (_getTemplateBlocks)

---

### Hypothèse 4: Données Firestore malformées (PROBABILITÉ: 3%)

**Description:**
`_safeLayoutParse()` retourne `[]` silencieusement si:
- `draftLayout` est une string (ex: `"none"`, `"[]"`)
- Blocs malformés dans la liste

**Fichiers concernés:**
- `builder_page.dart:287-342` (_safeLayoutParse)

---

### Hypothèse 5: Route invalide excluant la page (PROBABILITÉ: 2%)

**Description:**
`_isBottomBarPage()` exclut les pages avec `route == '/'` ou vide.

Si une page a été créée avec une route invalide, elle n'apparaît pas dans les listes.

**Fichiers concernés:**
- `builder_layout_service.dart:722-751` (_isBottomBarPage)

---

## 📋 RÉSUMÉ ET RECOMMANDATIONS (SANS CODE)

### Points confirmés fonctionnels:
1. ✅ `loadDraft()` a un self-heal qui persiste dans Firestore
2. ✅ `initializeSpecificPageDraft()` protège les system pages avec contenu par défaut
3. ✅ Le runtime vérifie `publishedLayout > draftLayout > blocks` dans l'ordre

### Points à vérifier dans Firestore:
1. ⚠️ Pages custom: ont-elles un document dans `pages_published` ?
2. ⚠️ Pages custom: leur `route` est-elle valide (pas `/` ni vide) ?
3. ⚠️ Pages template: le `templateId` utilisé était-il valide ?

### Points d'attention architecturaux:
1. 🔍 `initializeSpecificPageDraft()` ne traite PAS les custom pages
2. 🔍 `fixEmptySystemPages()` ignore les pages sans `systemId`
3. 🔍 Les pages template NE SONT PAS publiées automatiquement

---

## ⚠️ AVERTISSEMENT FINAL

Ce rapport est **purement diagnostique**. Aucune modification de code n'a été effectuée ni proposée.

Les hypothèses doivent être confirmées par:
1. Inspection des documents Firestore des pages problématiques
2. Logs de débogage sur les chemins de code identifiés
3. Tests manuels de reproduction du bug

**Fin du rapport d'audit technique**
