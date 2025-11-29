# 🔍 AUDIT TECHNIQUE COMPLET - PIPELINE BUILDER B3

**Date:** 29 novembre 2025  
**Objectif:** Analyse forensique du pipeline de chargement Builder B3  
**Symptômes signalés:**  
- ✅ Côté client → les pages s'affichent correctement  
- ❌ Côté Builder → "page vide", "pages fantômes", blocs invisibles  
- ❌ Certains modules visibles côté runtime ne le sont pas dans l'éditeur  

**⚠️ AUCUNE MODIFICATION DE CODE - RAPPORT D'AUDIT UNIQUEMENT**

---

## 📋 RÉSUMÉ RAPIDE (10 lignes)

1. **Le pipeline Builder vs Runtime diverge** : Le runtime lit `publishedLayout`, l'éditeur lit `draftLayout` via `loadDraft()`
2. **Problème de synchronisation draft ↔ published** : Si `draftLayout` est vide mais `publishedLayout` contient des blocs, le sync existe MAIS peut être court-circuité
3. **L'éditeur charge via `loadDraft()`** qui a un fallback vers `loadPublished()`, mais seulement si `draftLayout.isEmpty`
4. **Race condition potentielle** : `getBottomBarPages()` appelle `fixEmptySystemPages()` AVANT que l'éditeur ne charge la page
5. **Les pages système (cart, menu, profile)** peuvent avoir des blocs vides si auto-init ne les a pas peuplées correctement
6. **Format des données Firestore** : `_safeLayoutParse` retourne `[]` silencieusement pour les valeurs string comme `"none"`
7. **La source de vérité a changé** : De `pages_system` vers `pages_published` avec le flag `isSystemPage`
8. **`DefaultPageCreator._buildDefaultBlocks()`** retourne `[]` pour les pages système (cart, profile, etc.)
9. **L'ordre des appels** dans `BuilderNavigationService.getBottomBarPages()` peut créer une course entre création et lecture
10. **Le chemin de l'éditeur** (`BuilderPageEditorScreen`) est complètement séparé du chemin de navigation

---

## 🗺️ DIAGRAMME DU PIPELINE (ASCII)

```
                    ┌─────────────────────────────────────────────────────────────────────┐
                    │                    CHARGEMENT INITIAL (App Launch)                   │
                    └─────────────────────────────────────────────────────────────────────┘
                                                    │
                                                    ▼
                    ┌─────────────────────────────────────────────────────────────────────┐
                    │              ScaffoldWithNavBar (bottomBarPagesProvider)             │
                    │                                                                      │
                    │   ref.watch(bottomBarPagesProvider) ─────┐                          │
                    └──────────────────────────────────────────│──────────────────────────┘
                                                               │
                                                               ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                            BuilderNavigationService.getBottomBarPages()                          │
│                                                                                                  │
│  1. loadSystemPages(appId) ─────────────► loadAllPublishedPages() ─► filter(isSystemPage)       │
│                                                                                                  │
│  2. if (allSystemPages.isEmpty) ────────► _ensureMinimumPages() ─────► publishes 4 default      │
│                                                                                                  │
│  3. _pageService.fixEmptySystemPages() ─► injects default blocks if layouts empty               │
│                                                                                                  │
│  4. getBottomBarPages(appId) ───────────► loadAllPublishedPages() ─► filter(_isBottomBarPage)   │
│                                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                    │
                    ┌───────────────────────────────┴───────────────────────────┐
                    ▼                                                           ▼
┌─────────────────────────────────────────┐         ┌─────────────────────────────────────────┐
│           RUNTIME (Client)              │         │           BUILDER (Éditeur)             │
│                                         │         │                                          │
│  DynamicBuilderPageScreen               │         │  BuilderPageEditorScreen                 │
│         │                               │         │         │                                │
│         ▼                               │         │         ▼                                │
│  DynamicPageResolver.resolveByKey()     │         │  _layoutService.loadDraft(appId, pageId) │
│         │                               │         │         │                                │
│         ▼                               │         │         ▼                                │
│  loadPublished() ────────► pages_published       │  ┌─────────────────────────────────────┐ │
│         │                               │         │  │ loadDraft():                         │ │
│         ▼                               │         │  │  1. Load from pages_draft            │ │
│  Priorité: publishedLayout              │         │  │  2. if draftLayout.isEmpty:          │ │
│            > draftLayout                │         │  │     → loadPublished()                │ │
│            > blocks                     │         │  │     → copy publishedLayout to draft  │ │
│         │                               │         │  │  3. return page                      │ │
│         ▼                               │         │  └─────────────────────────────────────┘ │
│  BuilderRuntimeRenderer                 │         │         │                                │
│                                         │         │         ▼                                │
└─────────────────────────────────────────┘         │  Utilise: draftLayout (pour édition)     │
                                                    │         │                                │
                                                    │         ▼                                │
                                                    │  BuilderPagePreview (preview)            │
                                                    └─────────────────────────────────────────┘

```

### Chemins Firestore Utilisés

```
restaurants/{appId}/
    ├── pages_draft/{pageId}        ← ÉDITEUR écrit/lit (brouillons)
    ├── pages_published/{pageId}    ← RUNTIME lit (pages publiées)
    ├── pages_system/{pageId}       ← LEGACY (plus utilisé, mais encore référencé)
    └── builder_settings/
            └── meta                ← Flag autoInitDone
```

---

## 🔬 ANALYSE PAR COUCHE

### Couche 1: Chargement Initial (ScaffoldWithNavBar)

**Fichier:** `lib/src/widgets/scaffold_with_nav_bar.dart`

```dart
final bottomBarPagesProvider = FutureProvider.autoDispose<List<BuilderPage>>((ref) async {
  final appId = ref.watch(currentRestaurantProvider).id;
  final service = BuilderNavigationService(appId);
  return await service.getBottomBarPages();  // ⚠️ Point d'entrée
});
```

**Ce qui se passe:**
1. Le provider est `autoDispose` - il se recharge à chaque fois
2. Appelle `BuilderNavigationService.getBottomBarPages()`
3. Si < 2 items, fallback hardcodé vers Accueil/Menu

**Points de divergence potentiels:**
- ⚠️ Si `getBottomBarPages()` retourne des pages sans contenu, elles apparaissent dans la nav mais vides dans l'éditeur
- ⚠️ Le fallback `< 2 items` peut masquer des problèmes

---

### Couche 2: BuilderNavigationService

**Fichier:** `lib/builder/services/builder_navigation_service.dart` (lignes 59-91)

```dart
Future<List<BuilderPage>> getBottomBarPages() async {
  try {
    // Step 1: Load ALL system pages (active AND inactive)
    final allSystemPages = await _layoutService.loadSystemPages(appId);  // ← Lit pages_published
    
    // Step 2: Only trigger auto-init if truly empty
    if (allSystemPages.isEmpty) {
      await _ensureMinimumPages(allSystemPages);  // ← Crée 4 pages par défaut
    }
    
    // Step 3: Always fix empty system pages
    await _pageService.fixEmptySystemPages(appId);  // ← ⚠️ INJECTE CONTENU
    
    // Step 4: Return ONLY active pages for the UI
    final pages = await _layoutService.getBottomBarPages(appId: appId);
    
    return pages;
  } catch (e, stackTrace) { ... }
}
```

**Ordre critique:**
1. `loadSystemPages()` → filtre `isSystemPage == true` depuis `pages_published`
2. Si vide → `_ensureMinimumPages()` crée 4 pages par défaut ET les publie
3. `fixEmptySystemPages()` → injecte des blocs par défaut si layouts vides
4. `getBottomBarPages()` → retourne les pages actives

**⚠️ PROBLÈME POTENTIEL:**
Le Step 3 (`fixEmptySystemPages`) s'exécute à CHAQUE chargement de la bottom bar, mais l'éditeur ne recharge pas depuis Firestore après ce fix.

---

### Couche 3: BuilderLayoutService

**Fichier:** `lib/builder/services/builder_layout_service.dart`

#### loadDraft() - Utilisé par l'éditeur (lignes 158-200)

```dart
Future<BuilderPage?> loadDraft(String appId, dynamic pageId) async {
  try {
    final ref = _getDraftRef(appId, pageId);
    final snapshot = await ref.get();

    // Case 1: Draft exists and has content
    if (snapshot.exists && snapshot.data() != null) {
      final draftPage = BuilderPage.fromJson(snapshot.data()!);
      
      if (draftPage.draftLayout.isNotEmpty) {
        return draftPage;  // ✅ Retourne le draft
      }
      
      // Draft exists but draftLayout is empty - try sync from published
      debugPrint('⚠️ Draft exists but draftLayout is empty...');
    }

    // Case 2: Try published version
    final publishedPage = await loadPublished(appId, pageId);
    if (publishedPage != null && publishedPage.publishedLayout.isNotEmpty) {
      debugPrint('📋 Creating draft from published content...');
      return publishedPage.copyWith(
        isDraft: true,
        draftLayout: publishedPage.publishedLayout.toList(),  // ← Sync
        hasUnpublishedChanges: false,
      );
    }

    // Case 3: Return original draft if exists (even if empty)
    if (snapshot.exists) {
      return BuilderPage.fromJson(snapshot.data()!);
    }
    
    return null;
  } catch (e) { ... }
}
```

**LOGIQUE DE FALLBACK:**
1. Si `draftLayout.isNotEmpty` → retourne le draft tel quel
2. Si `draftLayout.isEmpty` ET `publishedLayout.isNotEmpty` → copie published vers draft
3. Si les deux sont vides → retourne le draft vide (ou null si inexistant)

**⚠️ POINT DE DIVERGENCE:**
- Le fallback ne se déclenche QUE si `draftLayout.isEmpty`
- Mais si `draftLayout` contient des blocs invalides qui ont été parsés en `[]`, le fallback ne se déclenche pas

#### loadSystemPages() - Source de vérité (lignes 619-637)

```dart
Future<List<BuilderPage>> loadSystemPages(String appId) async {
  try {
    // Query from published pages - the source of truth
    final publishedPages = await loadAllPublishedPages(appId);
    
    // Filter to return only pages where isSystemPage == true
    final systemPages = publishedPages.values
        .where((page) => page.isSystemPage)
        .toList();
    
    return systemPages;
  } catch (e) { ... }
}
```

**CHANGEMENT MAJEUR:**
- AVANT: Lisait depuis `pages_system` (collection statique)
- MAINTENANT: Lit depuis `pages_published` avec filtre `isSystemPage`

---

### Couche 4: BuilderPageService.fixEmptySystemPages()

**Fichier:** `lib/builder/services/builder_page_service.dart` (lignes 727-878)

```dart
Future<int> fixEmptySystemPages(String appId) async {
  try {
    int fixedCount = 0;
    
    final pagesToCheck = <BuilderPage>[];
    
    // Load from pages_system collection
    final systemPages = await _layoutService.loadSystemPages(appId);
    pagesToCheck.addAll(systemPages);
    
    // Also load from pages_published (for auto-initialized pages)
    final publishedPages = await _layoutService.loadAllPublishedPages(appId);
    
    for (final page in publishedPages.values) {
      if (page.systemId != null) {
        final alreadyExists = pagesToCheck.any((p) => p.pageKey == page.pageKey);
        if (!alreadyExists) {
          pagesToCheck.add(page);
        }
      }
    }
    
    for (final page in pagesToCheck) {
      // Only fix active system pages with empty layouts
      if (!page.isActive) continue;
      
      final hasContent = page.draftLayout.isNotEmpty || 
                        page.publishedLayout.isNotEmpty ||
                        page.blocks.isNotEmpty;
      if (hasContent) continue;
      
      // Inject default blocks based on systemId
      List<BuilderBlock> defaultBlocks;
      switch (sysId) {
        case BuilderPageId.home:
          defaultBlocks = [HeroBlock, ProductListBlock];
          break;
        case BuilderPageId.cart:
          defaultBlocks = [SystemBlock(moduleType: 'cart_module')];
          break;
        // ... etc
      }
      
      // Save to BOTH draft AND published
      await _layoutService.saveDraft(updatedPage);
      await _layoutService.publishPage(updatedPage, userId: 'system_fix');
      
      fixedCount++;
    }
    
    return fixedCount;
  } catch (e) { ... }
}
```

**CE QUI SE PASSE:**
1. Collecte toutes les pages système (de pages_system ET pages_published)
2. Pour chaque page active avec layouts vides → injecte des blocs par défaut
3. Sauvegarde dans DRAFT ET PUBLISHED

**⚠️ TIMING CRITIQUE:**
- Cette fonction s'exécute PENDANT le chargement de la bottom bar
- L'éditeur peut charger une page AVANT que `fixEmptySystemPages` n'ait terminé
- → Résultat: page vide dans l'éditeur mais contenu dans le client après refresh

---

### Couche 5: BuilderPage.fromJson() - Parsing

**Fichier:** `lib/builder/models/builder_page.dart` (lignes 345-448)

```dart
factory BuilderPage.fromJson(Map<String, dynamic> json) {
  // Parse blocks (legacy field)
  final blocks = _safeLayoutParse(json['blocks']);
  
  // Parse draftLayout (new field, fallback to blocks)
  final draftLayoutRaw = json['draftLayout'];
  var draftLayout = draftLayoutRaw != null 
      ? _safeLayoutParse(draftLayoutRaw)
      : blocks;  // ⚠️ Fallback vers blocks legacy
  
  // Parse publishedLayout (new field)
  final publishedLayout = _safeLayoutParse(json['publishedLayout']);
  
  // Fix 'Ghost Content': If draft is empty but published has content
  if (draftLayout.isEmpty && publishedLayout.isNotEmpty) {
    draftLayout = List<BuilderBlock>.from(publishedLayout);  // ✅ Sync
  } else if (draftLayout.isEmpty && blocks.isNotEmpty) {
    draftLayout = List<BuilderBlock>.from(blocks);  // ✅ Fallback legacy
  }
  
  return BuilderPage(...);
}
```

**LOGIQUE DE SYNC DANS fromJson:**
1. Si `draftLayout` est null → utilise `blocks` (legacy)
2. Si `draftLayout.isEmpty` ET `publishedLayout.isNotEmpty` → copie depuis published
3. Si `draftLayout.isEmpty` ET `blocks.isNotEmpty` → copie depuis blocks

**⚠️ PROBLÈME POTENTIEL:**
`_safeLayoutParse()` retourne `[]` pour les valeurs string comme `"none"`:

```dart
static List<BuilderBlock> _safeLayoutParse(dynamic value) {
  if (value == null) return [];
  
  if (value is List<dynamic>) {
    // Parse chaque bloc...
    return validBlocks;
  }
  
  if (value is String) {
    print('⚠️ Legacy string value found: "$value". Returning empty list.');
  }
  return [];  // ← RETOURNE [] SILENCIEUSEMENT
}
```

---

### Couche 6: Runtime vs Éditeur

#### RUNTIME (DynamicBuilderPageScreen)

**Fichier:** `lib/builder/runtime/dynamic_builder_page_screen.dart`

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final appId = ref.watch(currentRestaurantProvider).id;
  final resolver = DynamicPageResolver();
  
  return FutureBuilder<BuilderPage?>(
    future: resolver.resolveByKey(pageKey, appId),  // ← Charge depuis PUBLISHED
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.data != null) {
        final builderPage = snapshot.data!;
        
        // Sélection du contenu à afficher
        final blocksToRender = builderPage.publishedLayout.isNotEmpty
            ? builderPage.publishedLayout            // ← Priorité: publishedLayout
            : (builderPage.draftLayout.isNotEmpty 
                ? builderPage.draftLayout 
                : builderPage.blocks);               // ← Fallback: draft puis legacy
        
        return BuilderRuntimeRenderer(blocks: blocksToRender);
      }
    },
  );
}
```

**SOURCE DE DONNÉES RUNTIME:**
- `DynamicPageResolver.resolveByKey()` → `loadPublished()` → `pages_published`
- Priorité d'affichage: `publishedLayout` > `draftLayout` > `blocks`

#### ÉDITEUR (BuilderPageEditorScreen)

**Fichier:** `lib/builder/editor/builder_page_editor_screen.dart`

```dart
Future<void> _loadPage() async {
  setState(() => _isLoading = true);

  try {
    final pageIdentifier = widget.pageId ?? widget.pageKey!;
    
    // Load draft, or create default if none exists
    var page = await _service.loadDraft(widget.appId, pageIdentifier);  // ← loadDraft()
    
    if (page == null && widget.pageId != null) {
      // Only auto-create for system pages
      page = await _service.createDefaultPage(...);
    }
    
    setState(() {
      _page = page;
      _isLoading = false;
    });
  } catch (e) { ... }
}
```

**SOURCE DE DONNÉES ÉDITEUR:**
- `loadDraft()` → `pages_draft` (avec fallback vers `pages_published`)
- Affiche: `draftLayout` (ou `blocks` legacy)

---

## 🔄 ANALYSE DRAFT ↔ PUBLISHED

### Quand published est créé:

1. **Auto-init** (`_ensureMinimumPages`): Crée ET publie 4 pages par défaut
2. **Publication manuelle** (`publishPage`): Admin clique "Publier"
3. **Fix empty pages** (`fixEmptySystemPages`): Publie les pages système avec contenu par défaut

### Quand draft est créé:

1. **saveDraft()**: Sauvegarde les modifications de l'éditeur
2. **copyPublishedToDraft()**: Copie explicite depuis published
3. **loadDraft() fallback**: Si draft vide, crée depuis published

### Synchronisation:

```
                    FIRESTORE
                        │
        ┌───────────────┴───────────────┐
        │                               │
    pages_draft                    pages_published
        │                               │
        ▼                               ▼
   draftLayout ◄────────────────── publishedLayout
        │         copyWith()            │
        │                               │
        ▼                               ▼
   [ÉDITEUR]                       [RUNTIME]
```

### Cas où la sync échoue:

1. **Draft existe avec `draftLayout: []`** mais published a du contenu
   - `loadDraft()` vérifie `draftLayout.isNotEmpty` → FAUX
   - Tente fallback vers published → OK
   - MAIS: retourne `copyWith()`, ne SAUVEGARDE PAS

2. **Draft existe avec `draftLayout: "none"`** (string legacy)
   - `_safeLayoutParse("none")` → `[]`
   - `draftLayout.isEmpty` → VRAI
   - Fallback vers published → OK
   - MAIS: même problème, pas de sauvegarde

3. **`fixEmptySystemPages()` s'exécute APRÈS le chargement de l'éditeur**
   - L'éditeur a déjà chargé un draft vide
   - Le fix s'exécute dans la bottom bar
   - L'éditeur ne recharge pas

---

## ⏱️ ANALYSE DES RACE CONDITIONS

### Scénario 1: Premier lancement après auto-init

```
T0: App démarre
T1: ScaffoldWithNavBar monte
T2: bottomBarPagesProvider déclenche getBottomBarPages()
    ├── T2.1: loadSystemPages() → pages vides
    ├── T2.2: _ensureMinimumPages() → crée 4 pages, PUBLIE
    ├── T2.3: fixEmptySystemPages() → injecte contenu, PUBLIE
    └── T2.4: getBottomBarPages() → retourne pages

T3: Utilisateur navigue vers Admin > Éditeur
T4: BuilderPageEditorScreen._loadPage()
    └── loadDraft() → lit depuis pages_draft (peut être vide si sync pas faite)

⚠️ PROBLÈME: T2 a publié mais PAS créé de draft
```

### Scénario 2: Page désactivée puis réactivée

```
T0: Admin désactive une page (isActive = false)
T1: Page n'apparaît plus dans bottom bar
T2: Admin ouvre l'éditeur pour cette page
    └── loadDraft() → retourne page avec isActive = false
    
T3: Admin réactive (isActive = true)
    └── updatePageNavigation() → publie avec isActive = true

T4: Bottom bar ne se recharge pas automatiquement
⚠️ PROBLÈME: Incohérence entre éditeur et navigation
```

### Scénario 3: Édition concurrent

```
T0: getBottomBarPages() charge les pages
T1: fixEmptySystemPages() commence à injecter du contenu
T2: L'utilisateur ouvre l'éditeur PENDANT T1
    └── loadDraft() lit l'ANCIENNE version (avant le fix)
    
T3: fixEmptySystemPages() termine et sauvegarde
T4: L'éditeur affiche une version obsolète

⚠️ PROBLÈME: Race condition entre fix et chargement éditeur
```

---

## 📊 ANALYSE DES BLOCS

### Factory de création (BuilderNavigationService._getDefaultBlocksForPage)

```dart
List<BuilderBlock> _getDefaultBlocksForPage(BuilderPageId pageId) {
  switch (pageId) {
    case BuilderPageId.home:
      return [
        BuilderBlock(type: BlockType.hero, config: {...}),
        BuilderBlock(type: BlockType.productList, config: {...}),
      ];
    case BuilderPageId.menu:
      return [SystemBlock(moduleType: 'menu_catalog')];
    case BuilderPageId.cart:
      return [SystemBlock(moduleType: 'cart_module')];
    case BuilderPageId.profile:
      return [SystemBlock(moduleType: 'profile_module')];
    default:
      return [];  // ← Pages non-système: blocs vides
  }
}
```

### Factory de correction (BuilderPageService.fixEmptySystemPages)

```dart
switch (sysId) {
  case BuilderPageId.home:
    defaultBlocks = [
      BuilderBlock(type: BlockType.hero, config: {
        'tapAction': 'openPage',      // ← Format différent!
        'tapActionTarget': '/menu',   // ← Champs séparés
      }),
    ];
    break;
  // ...
}
```

**⚠️ INCOHÉRENCE DE FORMAT:**
- `_getDefaultBlocksForPage`: `'tapAction': {'type': 'openPage', 'value': '/menu'}`
- `fixEmptySystemPages`: `'tapAction': 'openPage', 'tapActionTarget': '/menu'`

Le runtime gère les deux formats, mais c'est une source de confusion.

### Parsing des blocs (BuilderBlock.fromJson)

```dart
factory BuilderBlock.fromJson(Map<String, dynamic> json) {
  Map<String, dynamic> configMap = {};
  try {
    final raw = json['config'];
    if (raw is Map) {
      configMap = Map<String, dynamic>.from(raw);
    } else if (raw is String) {
      configMap = Map<String, dynamic>.from(jsonDecode(raw));  // ← Supporte JSON string
    }
  } catch (e) {
    print('⚠️ Config parsing error: $e');
    // Ne throw pas, garde configMap vide
  }
  
  try {
    return BuilderBlock(...);
  } catch (e) {
    // Retourne un bloc fallback au lieu de crasher
    return BuilderBlock(type: BlockType.text, config: configMap);  // ← Fallback silencieux
  }
}
```

**COMPORTEMENT:**
- Jamais de crash
- Blocs malformés → deviennent des blocs `text` vides
- Erreurs silencieuses (seulement loggées)

---

## 🔍 COMPARAISON RUNTIME vs BUILDER

| Aspect | Runtime | Builder (Éditeur) |
|--------|---------|-------------------|
| **Source Firestore** | `pages_published` | `pages_draft` (fallback published) |
| **Méthode de chargement** | `DynamicPageResolver.resolveByKey()` | `BuilderLayoutService.loadDraft()` |
| **Layout utilisé** | `publishedLayout` (priorité) | `draftLayout` |
| **Fallback** | `draftLayout` → `blocks` | `publishedLayout` → `blocks` |
| **Appel de fix** | OUI (via bottom bar) | NON |
| **Refresh automatique** | OUI (provider) | NON (setState manuel) |

**⚠️ DIVERGENCE CRITIQUE:**
Le runtime peut afficher du contenu car `fixEmptySystemPages()` a injecté des blocs dans `publishedLayout`, mais l'éditeur charge depuis `pages_draft` qui peut être vide.

---

## 🎯 POINTS DE DIVERGENCE IDENTIFIÉS

### 1. Draft vide, Published avec contenu
- **Symptôme:** Page vide dans l'éditeur, contenu visible côté client
- **Cause:** `fixEmptySystemPages()` écrit dans published mais l'éditeur lit draft
- **Localisation:** `builder_page_service.dart:852-858`

### 2. Timing de fixEmptySystemPages
- **Symptôme:** Éditeur montre page vide, puis refresh montre le contenu
- **Cause:** Race condition entre fix et chargement éditeur
- **Localisation:** `builder_navigation_service.dart:72`

### 3. Fallback loadDraft sans persistance
- **Symptôme:** Contenu apparaît mais disparaît après navigation
- **Cause:** `loadDraft()` fait `copyWith()` mais ne persiste pas
- **Localisation:** `builder_layout_service.dart:183-187`

### 4. Valeurs string legacy ("none")
- **Symptôme:** Blocs existants ignorés
- **Cause:** `_safeLayoutParse("none")` retourne `[]`
- **Localisation:** `builder_page.dart:336-338`

### 5. DefaultPageCreator retourne [] pour system pages
- **Symptôme:** Pages système créées sans contenu
- **Cause:** `_buildDefaultBlocks()` retourne `[]` pour cart/profile/etc.
- **Localisation:** `default_page_creator.dart:249-259`

---

## 🔮 3 HYPOTHÈSES CLASSÉES (CAUSES PROBABLES)

### Hypothèse 1: Race Condition entre fixEmptySystemPages et l'éditeur (85%)

**Description:**
`fixEmptySystemPages()` s'exécute dans le flux de chargement de la bottom bar (`getBottomBarPages()`), mais l'éditeur charge directement depuis `loadDraft()` sans attendre ce fix.

**Séquence problématique:**
1. App démarre, `bottomBarPagesProvider` s'active
2. `getBottomBarPages()` → `fixEmptySystemPages()` commence
3. Utilisateur navigue vers l'éditeur (très rapide)
4. L'éditeur appelle `loadDraft()` AVANT que le fix termine
5. L'éditeur affiche une page vide
6. Le fix termine et publie le contenu
7. Le runtime affiche le contenu (rechargé via provider)
8. L'éditeur reste vide (pas de refresh)

**Comment confirmer:**
- Ajouter un délai artificiel dans l'éditeur (2s) avant `loadDraft()`
- Si les pages apparaissent après le délai → hypothèse confirmée

**Fichiers concernés:**
- `lib/builder/services/builder_navigation_service.dart:72`
- `lib/builder/editor/builder_page_editor_screen.dart:117`

---

### Hypothèse 2: Draft non persisté après fallback (10%)

**Description:**
`loadDraft()` fait un fallback vers published et retourne `copyWith(draftLayout: publishedLayout)`, mais NE SAUVEGARDE PAS cette copie. Le draft reste vide dans Firestore.

**Séquence problématique:**
1. Page publiée avec contenu dans `publishedLayout`
2. `pages_draft/{pageId}` n'existe pas
3. `loadDraft()` charge depuis published, fait `copyWith()`
4. Retourne page avec `draftLayout` (en mémoire seulement)
5. Si l'utilisateur navigue ailleurs et revient → recharge depuis Firestore
6. `pages_draft/{pageId}` toujours inexistant → même problème

**Comment confirmer:**
- Vérifier dans Firestore si les documents existent dans `pages_draft`
- Comparer `pages_draft/{home}` vs `pages_published/{home}`

**Fichiers concernés:**
- `lib/builder/services/builder_layout_service.dart:178-188`

---

### Hypothèse 3: Données Firestore malformées (5%)

**Description:**
Les champs `draftLayout` ou `publishedLayout` contiennent des valeurs string legacy (comme `"none"` ou `"[]"`) au lieu de tableaux.

**Séquence problématique:**
1. Ancienne version du code stockait `draftLayout: "none"`
2. `_safeLayoutParse("none")` retourne `[]`
3. `draftLayout.isEmpty` → VRAI
4. Fallback vers published
5. Mais published a le même problème → `[]`
6. Page affichée comme vide

**Comment confirmer:**
- Inspecter les documents Firestore directement
- Chercher des valeurs string dans `draftLayout`/`publishedLayout`

**Fichiers concernés:**
- `lib/builder/models/builder_page.dart:336-338`

---

## ✅ CHECKLIST DE VÉRIFICATION FIRESTORE

### Pour chaque page système (home, menu, cart, profile):

```
□ Document existe dans pages_draft/{pageId}?
□ Document existe dans pages_published/{pageId}?
□ Champ 'draftLayout' est un Array (pas String)?
□ Champ 'publishedLayout' est un Array (pas String)?
□ Champ 'blocks' est un Array (pas String)?
□ isActive == true?
□ isSystemPage == true (pour cart, profile, rewards, roulette)?
□ bottomNavIndex est entre 0 et 4?
□ route n'est pas "/" ou vide?
```

### Dans builder_settings/meta:

```
□ autoInitDone == true?
□ autoInitAt contient un timestamp valide?
```

### Comparaison draft vs published:

```
□ Les deux documents existent pour les mêmes pages?
□ draftLayout == publishedLayout (pour pages non modifiées)?
□ Les blocs ont des IDs valides (pas null)?
□ Les configs des blocs sont des Map (pas des String)?
```

---

## 📁 FICHIERS CLÉS À SURVEILLER

| Fichier | Rôle | Risque |
|---------|------|--------|
| `builder_layout_service.dart` | CRUD Firestore | Sync draft/published |
| `builder_navigation_service.dart` | Chargement navigation | Race condition fix |
| `builder_page_service.dart` | Fix pages système | Injection contenu |
| `builder_page.dart` | Modèle + parsing | Parsing layouts |
| `builder_page_editor_screen.dart` | Interface éditeur | Chargement page |
| `dynamic_builder_page_screen.dart` | Runtime client | Source published |
| `scaffold_with_nav_bar.dart` | Bottom navigation | Provider trigger |

---

## ⚠️ AUCUNE PROPOSITION DE MODIFICATION

Ce rapport est purement diagnostique. Aucune correction de code n'a été effectuée ni proposée.

Les corrections doivent être priorisées et testées une par une, en commençant par la confirmation de l'hypothèse 1 (Race Condition).

---

**Fin du rapport d'audit technique**
