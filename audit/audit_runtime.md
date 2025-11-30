# Audit Technique - Runtime

## Vue d'ensemble du pipeline Runtime

Ce document décrit le pipeline complet de chargement et rendu des pages Builder en production.

---

## 1. Architecture Runtime

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT APP                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐     ┌──────────────────────────────────┐  │
│  │ DynamicPageRouter│ ──► │ DynamicBuilderPageScreen         │  │
│  │   (routing)      │     │   (page wrapper)                 │  │
│  └──────────────────┘     └──────────────────────────────────┘  │
│           │                           │                          │
│           ▼                           ▼                          │
│  ┌──────────────────┐     ┌──────────────────────────────────┐  │
│  │BuilderPageLoader │ ──► │ BuilderRuntimeRenderer           │  │
│  │  (data loading)  │     │   (block rendering)              │  │
│  └──────────────────┘     └──────────────────────────────────┘  │
│           │                           │                          │
│           ▼                           ▼                          │
│  ┌──────────────────┐     ┌──────────────────────────────────┐  │
│  │DynamicPageResolver│    │ *_block_runtime.dart             │  │
│  │  (Firestore)     │     │   (individual blocks)            │  │
│  └──────────────────┘     └──────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │    FIRESTORE     │
                    │ pages_published  │
                    └──────────────────┘
```

---

## 2. Fichiers du runtime

### `lib/builder/runtime/`

```
runtime/
├── runtime.dart                        # Barrel file
├── dynamic_page_router.dart            # Routing et navigation
├── dynamic_builder_page_screen.dart    # Écran wrapper
├── builder_page_loader.dart            # Chargement avec fallback
│
└── modules/                            # Widgets modules système
    ├── menu_catalog_runtime_widget.dart
    ├── roulette_module_widget.dart
    └── profile_module_widget.dart
```

### `lib/builder/preview/`

```
preview/
├── preview.dart                        # Barrel file
├── builder_page_preview.dart           # Preview pour éditeur
└── builder_runtime_renderer.dart       # Rendu des blocs
```

---

## 3. Composants clés

### DynamicPageRouter
**Fichier:** `lib/builder/runtime/dynamic_page_router.dart`

**Responsabilité:** Générer les routes GoRouter pour les pages Builder

**Fonctionnement:**
```dart
// Génère une route pour chaque page publiée
GoRoute(
  path: page.route,
  builder: (context, state) => DynamicBuilderPageScreen(
    pageKey: page.pageKey,
    fallback: getFallbackScreen(page.pageKey),
  ),
)
```

---

### DynamicBuilderPageScreen
**Fichier:** `lib/builder/runtime/dynamic_builder_page_screen.dart`

**Responsabilité:** Wrapper qui charge et affiche une page Builder

**Props:**
- `pageKey` - Identifiant de la page
- `fallback` - Widget de fallback si la page n'existe pas

---

### BuilderPageLoader
**Fichier:** `lib/builder/runtime/builder_page_loader.dart`

**Responsabilité:** Charger une page avec fallback vers écran legacy

**Flux:**
1. Récupère `appId` depuis `currentRestaurantProvider`
2. Appelle `DynamicPageResolver.resolve(pageId, appId)`
3. Si page existe → rend avec `BuilderRuntimeRenderer`
4. Sinon → affiche le widget `fallback`

```dart
class BuilderPageLoader extends ConsumerWidget {
  final BuilderPageId pageId;
  final Widget fallback;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appId = ref.watch(currentRestaurantProvider).id;
    final resolver = DynamicPageResolver();
    
    return FutureBuilder<BuilderPage?>(
      future: resolver.resolve(pageId, appId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return buildPageFromBuilder(context, snapshot.data!);
        }
        return fallback;
      },
    );
  }
}
```

---

### DynamicPageResolver
**Fichier:** `lib/builder/services/dynamic_page_resolver.dart`

**Responsabilité:** Résoudre une page depuis Firestore

**Source de données:** `pages_published/{pageKey}`

```dart
Future<BuilderPage?> resolve(BuilderPageId pageId, String appId) async {
  final page = await _layoutService.loadPublished(appId, pageId);
  return page;
}
```

---

### BuilderRuntimeRenderer
**Fichier:** `lib/builder/preview/builder_runtime_renderer.dart`

**Responsabilité:** Rendre une liste de blocs

**Fonctionnement:**
```dart
Widget buildPageFromBuilder(BuildContext context, BuilderPage page) {
  final blocks = page.publishedLayout.isNotEmpty 
      ? page.publishedLayout 
      : page.blocks;
  
  return ListView.builder(
    itemCount: blocks.length,
    itemBuilder: (context, index) {
      final block = blocks[index];
      return _buildBlockWidget(block);
    },
  );
}

Widget _buildBlockWidget(BuilderBlock block) {
  switch (block.type) {
    case BlockType.hero:
      return HeroBlockRuntime(block: block);
    case BlockType.text:
      return TextBlockRuntime(block: block);
    // ... autres types
  }
}
```

---

## 4. Widgets de blocs runtime

### Localisation
`lib/builder/blocks/*_runtime.dart`

### Liste complète

| Widget | Fichier | Dépendances |
|--------|---------|-------------|
| HeroBlockRuntime | hero_block_runtime.dart | - |
| TextBlockRuntime | text_block_runtime.dart | - |
| BannerBlockRuntime | banner_block_runtime.dart | - |
| ProductListBlockRuntime | product_list_block_runtime.dart | ProductProvider |
| ButtonBlockRuntime | button_block_runtime.dart | ActionHelper |
| ImageBlockRuntime | image_block_runtime.dart | - |
| SpacerBlockRuntime | spacer_block_runtime.dart | - |
| InfoBlockRuntime | info_block_runtime.dart | - |
| CategoryListBlockRuntime | category_list_block_runtime.dart | ProductProvider |
| HtmlBlockRuntime | html_block_runtime.dart | WebView |
| SystemBlockRuntime | system_block_runtime.dart | Modules système |

---

## 5. Modules système runtime

### Localisation
`lib/builder/runtime/modules/`

| Module | Widget | Fichier source original |
|--------|--------|------------------------|
| roulette | RouletteModuleWidget | lib/src/screens/roulette/roulette_screen.dart |
| loyalty | LoyaltySectionWidget | lib/src/screens/profile/widgets/loyalty_section_widget.dart |
| rewards | RewardsTicketsWidget | lib/src/screens/profile/widgets/rewards_tickets_widget.dart |
| accountActivity | AccountActivityWidget | lib/src/screens/profile/widgets/account_activity_widget.dart |
| menu_catalog | MenuCatalogRuntimeWidget | lib/builder/runtime/modules/menu_catalog_runtime_widget.dart |
| profile_module | ProfileModuleWidget | lib/builder/runtime/modules/profile_module_widget.dart |

---

## 6. Chemins Firestore utilisés par le runtime

| Service | Chemin | Usage |
|---------|--------|-------|
| DynamicPageResolver | pages_published/{pageKey} | Chargement page |
| BuilderLayoutService | pages_published/* | Liste des pages |
| getBottomBarPages | pages_published/* (filtré) | Navigation |

**Source de vérité:** `pages_published`

---

## 7. Providers Riverpod

### builderPageProvider
**Fichier:** `lib/builder/runtime/builder_page_loader.dart`

```dart
final builderPageProvider = FutureProvider.family<BuilderPage?, BuilderPageId>(
  (ref, pageId) async {
    final appId = ref.watch(currentRestaurantProvider).id;
    return await DynamicPageResolver().resolve(pageId, appId);
  },
);
```

### currentRestaurantProvider
**Fichier:** `lib/src/providers/restaurant_provider.dart`

Fournit l'ID du restaurant courant (multi-tenant).

---

## 8. Flux de données complet

```
1. Utilisateur navigue vers /menu
         │
         ▼
2. GoRouter trouve la route
         │
         ▼
3. DynamicBuilderPageScreen(pageKey: 'menu')
         │
         ▼
4. BuilderPageLoader charge la page
         │
         ▼
5. DynamicPageResolver.resolve('menu', appId)
         │
         ▼
6. Firestore: pages_published/menu
         │
         ▼
7. BuilderPage.fromJson(data)
         │
         ▼
8. BuilderRuntimeRenderer(blocks: page.publishedLayout)
         │
         ▼
9. Pour chaque bloc:
   - HeroBlockRuntime / TextBlockRuntime / etc.
         │
         ▼
10. Affichage à l'utilisateur
```

---

## 9. Fallback vers écrans legacy

Le système supporte un fallback transparent :

```dart
BuilderPageLoader(
  pageId: BuilderPageId.home,
  fallback: HomeScreen(),  // Écran legacy si Builder page n'existe pas
)
```

**Écrans legacy disponibles:**
- HomeScreen (`lib/src/screens/home/home_screen.dart`)
- MenuScreen (`lib/src/screens/menu/menu_screen.dart`)
- CartScreen (`lib/src/screens/cart/cart_screen.dart`)
- ProfileScreen (`lib/src/screens/profile/profile_screen.dart`)
- PromoScreen (`lib/src/screens/promo/promo_screen.dart`)
- RouletteScreen (`lib/src/screens/roulette/roulette_screen.dart`)
- RewardsScreen (`lib/src/screens/client/rewards/rewards_screen.dart`)
- ContactScreen (`lib/src/screens/contact/contact_screen.dart`)
- AboutScreen (`lib/src/screens/about/about_screen.dart`)

---

## 10. Performances et optimisations

### Caching
- Pas de cache explicite côté client
- Firestore gère le cache automatiquement

### Lazy loading
- Les blocs sont rendus via ListView.builder (lazy)
- Les images utilisent Image.network avec cache

### Recommandations
- ⚠️ Ajouter un cache mémoire pour les pages fréquentes
- ⚠️ Précharger les pages de navigation au démarrage
- ⚠️ Utiliser StreamBuilder au lieu de FutureBuilder pour les mises à jour temps réel

---

## 11. Pas de runtimes concurrents détectés

Le projet utilise un seul pipeline runtime :
1. `DynamicPageResolver` pour la résolution
2. `BuilderRuntimeRenderer` pour le rendu
3. Widgets `*_runtime.dart` pour chaque type de bloc

Il n'y a pas de système alternatif ou concurrent.

---

*Document généré automatiquement - Audit technique AppliPizza*
