# Phase 8 - Documentation Consolidée

## Vue d'ensemble

La **Phase 8** du Builder B3 introduit les **SystemBlocks** et les **pages système**, permettant d'intégrer des modules applicatifs essentiels (fidélité, récompenses, roulette, etc.) directement dans les pages personnalisables du builder.

Cette documentation consolidée résume l'ensemble du travail effectué : création des blocs système, pages protégées, actions de navigation, et mécanismes de protection.

---

## Section 1 — Présentation générale

### Rôle des SystemBlocks

Les **SystemBlocks** sont des blocs non configurables qui affichent des fonctionnalités applicatives existantes. Ils permettent aux utilisateurs de positionner des modules système (fidélité, récompenses, etc.) dans n'importe quelle page Builder sans configuration complexe.

**Caractéristiques clés :**
- Non configurables (affichage fixe)
- Positionnables librement dans les pages
- Rendu différent en preview vs runtime
- Gestion d'erreurs intégrée

### Rôle des pages système

Les **pages système** (`profile`, `cart`, `rewards`, `roulette`) sont des pages essentielles de l'application qui :
- Sont créées automatiquement si absentes
- Ne peuvent pas être supprimées
- Peuvent contenir des blocs personnalisés
- Ont un fallback vers les écrans legacy

### Logique de navigation système

L'action **`openSystemPage`** permet aux blocs interactifs de naviguer vers les pages système. Le système utilise une logique "Builder-first" :
1. Si une version Builder de la page existe → affichage Builder
2. Sinon → fallback vers l'écran legacy correspondant

### Résumé de la protection

| Élément | Protection |
|---------|------------|
| Pages système | Suppression interdite, pageId immuable |
| SystemBlocks | Configuration interdite, type immuable |
| Firestore | Correction automatique des données |
| Runtime | Fallbacks propres en cas d'erreur |

---

## Section 2 — SystemBlocks

### Liste complète des modules

| Type | Label | Icône | Widget Runtime |
|------|-------|-------|----------------|
| `roulette` | Roulette | 🎰 `Icons.casino` | Carte d'accès roue de la chance |
| `loyalty` | Fidélité | 🎁 `Icons.card_giftcard` | Section points et progression |
| `rewards` | Récompenses | ⭐ `Icons.stars` | Liste des tickets actifs |
| `accountActivity` | Activité du compte | 📊 `Icons.history` | Statistiques commandes/favoris |

### Usage

#### Comment ajouter un SystemBlock

1. Ouvrir l'éditeur de page Builder B3
2. Cliquer sur **+ Ajouter un bloc**
3. Faire défiler jusqu'à la section **"Modules système"** (en bleu)
4. Cliquer sur le module souhaité

#### Via le code

```dart
final rouletteBlock = SystemBlock(
  id: 'block_${DateTime.now().millisecondsSinceEpoch}',
  moduleType: 'roulette',
  order: page.blocks.length,
);
page = page.addBlock(rouletteBlock);
```

### Limitations

- ❌ Pas de personnalisation (couleurs, textes, etc.)
- ❌ Pas de modification du type après création
- ⚠️ Preview = placeholder uniquement (pas d'exécution réelle)
- ⚠️ Données de démo en runtime (intégration providers au niveau parent)

### Architecture

```
lib/builder/blocks/
├── system_block_runtime.dart    # Rendu réel (StatelessWidget Phase 5)
├── system_block_preview.dart    # Placeholder éditeur (120px)
└── blocks.dart                  # Export barrel

lib/builder/models/
├── builder_block.dart           # Classe SystemBlock
└── builder_enums.dart           # BlockType.system

lib/builder/preview/
└── builder_runtime_renderer.dart # buildSystemBlock()
```

#### Preview vs Runtime

| Aspect | Preview (Éditeur) | Runtime (Application) |
|--------|-------------------|----------------------|
| Hauteur | Fixe 120px | Variable selon contenu |
| Contenu | Placeholder gris + nom | Widget réel du module |
| Bordure | Bleue en mode debug | Selon configuration |
| Exécution | Aucune | Widgets système actifs |

### Exemples Firestore

```json
{
  "id": "block_1234567890",
  "type": "system",
  "order": 2,
  "config": {
    "moduleType": "roulette"
  },
  "isActive": true,
  "visibility": "visible",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z"
}
```

---

## Section 3 — Pages système

### Liste complète

| Page ID | Titre | Route | Icône | Écran Legacy |
|---------|-------|-------|-------|--------------|
| `profile` | Profil | `/profile` | `person` | ProfileScreen |
| `cart` | Panier | `/cart` | `shopping_cart` | CartScreen |
| `rewards` | Récompenses | `/rewards` | `card_giftcard` | RewardsScreen |
| `roulette` | Roulette | `/roulette` | `casino` | RouletteScreen |

### Règles de protection

#### Ce qui est interdit
- ❌ Suppression de la page
- ❌ Modification du pageId
- ❌ Création manuelle avec un ID réservé

#### Ce qui est autorisé
- ✅ Ajout/modification/suppression de blocs
- ✅ Réorganisation des blocs
- ✅ Modification du titre et de l'icône
- ✅ Modification du displayLocation (limité à `bottomBar`/`hidden`)
- ✅ Publication/dépublication

### Création automatique

Le service `SystemPagesInitializer` crée automatiquement les pages manquantes :

```dart
final initializer = SystemPagesInitializer();
await initializer.initSystemPages('pizza_delizza');
```

**Structure créée :**
- `blocks: []` (vide)
- `displayLocation: "hidden"`
- `order: 999`
- `isSystemPage: true`

### Fallback legacy

Si la page Builder n'existe pas, le système affiche l'écran legacy correspondant :

```dart
// Dans dynamic_page_resolver.dart
if (builderPageExists) {
  return BuilderRuntimeRenderer(blocks: page.blocks);
} else {
  return ProfileScreen(); // ou CartScreen, etc.
}
```

### Navigation (displayLocation)

| Valeur | Comportement |
|--------|--------------|
| `bottomBar` | Visible dans la barre de navigation |
| `hidden` | Accessible uniquement via navigation directe |

### Structure Firestore

```
builder/apps/{appId}/pages/{pageId}/draft
builder/apps/{appId}/pages/{pageId}/published
```

```json
{
  "pageId": "profile",
  "appId": "pizza_delizza",
  "name": "Profil",
  "route": "/profile",
  "blocks": [],
  "displayLocation": "hidden",
  "icon": "person",
  "order": 999,
  "isSystemPage": true,
  "version": 1,
  "createdAt": "2024-01-15T10:30:00.000Z"
}
```

---

## Section 4 — Actions openSystemPage

### Description

L'action `openSystemPage` permet aux blocs interactifs (text, button, hero, image) de naviguer vers une page système au clic.

### Configuration dans l'éditeur

1. Sélectionner un bloc avec action au clic
2. Choisir "openSystemPage" dans le dropdown "Type d'action"
3. Sélectionner la page système cible

### Liste des pages valides

| Identifiant | Label dans l'éditeur | Route |
|-------------|---------------------|-------|
| `profile` | Page Profil | `/profile` |
| `cart` | Page Panier | `/cart` |
| `rewards` | Page Récompenses | `/rewards` |
| `roulette` | Page Roulette | `/roulette` |

### Exemple de configuration

```dart
BuilderBlock(
  id: 'btn_profile',
  type: BlockType.button,
  config: {
    'label': 'Mon profil',
    'tapAction': 'openSystemPage',
    'tapActionTarget': 'profile',
  },
)
```

### Format Firestore

```json
{
  "tapAction": "openSystemPage",
  "tapActionTarget": "profile"
}
```

### Comportement preview vs runtime

| Mode | Comportement |
|------|--------------|
| **Preview** | Action non exécutée (permet sélection du bloc) |
| **Runtime** | Navigation via go_router vers la route système |

---

## Section 5 — Protections internes

### Ce que l'utilisateur peut modifier

#### Pages système
- ✅ Contenu des blocs
- ✅ Organisation des blocs
- ✅ Titre et icône
- ✅ Ordre dans la navigation (si bottomBar)
- ✅ Publication

#### SystemBlocks
- ✅ Suppression
- ✅ Position dans la page

### Ce que l'utilisateur ne peut pas modifier

#### Pages système
- ❌ Suppression de la page
- ❌ PageId
- ❌ displayLocation vers valeur non autorisée

#### SystemBlocks
- ❌ Type du bloc (toujours `system`)
- ❌ moduleType
- ❌ Configuration personnalisée

### Règles Firestore supplémentaires

Le service `builder_layout_service.dart` applique des corrections automatiques :

```dart
void _applySystemProtections(Map<String, dynamic> data) {
  final pageId = data['pageId'] as String?;
  
  // Correction isSystemPage
  if (BuilderPageId.isSystemPageId(pageId) && data['isSystemPage'] != true) {
    data['isSystemPage'] = true;
    debugPrint('⚠️ Correcting isSystemPage for $pageId');
  }
  
  // Correction displayLocation
  if (data['isSystemPage'] == true) {
    final displayLocation = data['displayLocation'] as String?;
    if (displayLocation != 'bottomBar' && displayLocation != 'hidden') {
      data['displayLocation'] = 'hidden';
      debugPrint('⚠️ Correcting displayLocation for $pageId');
    }
  }
}
```

### Cas de fallback

| Situation | Fallback |
|-----------|----------|
| Module type inconnu | Widget jaune "Module système introuvable" |
| Exception dans module | Widget rouge "Erreur de rendu" |
| Page système absente | Écran legacy correspondant |
| `isSystemPage` manquant | Corrigé automatiquement à `true` |
| `displayLocation` invalide | Corrigé automatiquement à `hidden` |

### Exemple de comportement attendu

**Scénario : Utilisateur tente de supprimer une page système**
1. Bouton de suppression masqué dans l'éditeur
2. Si suppression forcée via API → page recréée au prochain `initSystemPages()`

**Scénario : Module système invalide**
1. Runtime affiche widget fallback jaune
2. Message "Module système introuvable"
3. Liste des modules disponibles affichée
4. Application ne plante pas

---

## Section 6 — Architecture technique

### Emplacement des fichiers

```
lib/builder/
├── blocks/
│   ├── system_block_runtime.dart      # Widget runtime des modules
│   ├── system_block_preview.dart      # Widget preview (placeholder)
│   └── blocks.dart                    # Exports
│
├── models/
│   ├── builder_block.dart             # SystemBlock class
│   └── builder_enums.dart             # BlockType.system, BuilderPageId
│
├── services/
│   ├── system_pages_initializer.dart  # Création auto des pages
│   ├── dynamic_page_resolver.dart     # Résolution routes système
│   └── builder_layout_service.dart    # Protections Firestore
│
├── editor/
│   ├── builder_page_editor_screen.dart # UI éditeur + protection
│   └── new_page_dialog.dart           # Validation création page
│
├── preview/
│   └── builder_runtime_renderer.dart  # buildSystemBlock()
│
└── utils/
    └── action_helper.dart             # openSystemPage action
```

### Flux Builder → Firestore → Runtime

```
┌─────────────┐     ┌───────────┐     ┌─────────────┐
│   Editor    │ ──► │ Firestore │ ◄── │   Runtime   │
│             │     │           │     │             │
│ SystemBlock │     │ { type:   │     │ SystemBlock │
│ preview     │     │   system, │     │ runtime     │
│ (120px)     │     │   config: │     │ (widget     │
│             │     │   {...}}  │     │  réel)      │
└─────────────┘     └───────────┘     └─────────────┘
       │                  │                  │
       └──────────────────┼──────────────────┘
                          ▼
              Protection automatique
              - isSystemPage: true
              - displayLocation: hidden
              - type: system (conservé)
```

### Flux de navigation système

```
┌──────────────┐     ┌─────────────────┐     ┌───────────────┐
│ Bloc Button  │     │ ActionHelper    │     │ go_router     │
│              │ ──► │                 │ ──► │               │
│ tapAction:   │     │ executeSystem   │     │ /profile      │
│ openSystem   │     │ PageNavigation  │     │ /cart         │
│ Page         │     │                 │     │ /rewards      │
│              │     │                 │     │ /roulette     │
└──────────────┘     └─────────────────┘     └───────────────┘
                                                    │
                                                    ▼
                                          ┌─────────────────┐
                                          │ BuilderPage     │
                                          │ Loader          │
                                          │                 │
                                          │ Builder exists? │
                                          │ ├─ Yes: Builder │
                                          │ └─ No: Legacy   │
                                          └─────────────────┘
```

---

## Section 7 — Intégration future (white-label)

### Préparation multi-restaurant

L'architecture Phase 8 prépare le système pour le déploiement multi-restaurant :

1. **Isolation par appId** : Chaque restaurant a ses propres pages système dans `builder/apps/{appId}/`
2. **Personnalisation complète** : Les pages système peuvent avoir un contenu différent par restaurant
3. **Fallback uniforme** : Les écrans legacy restent disponibles comme base commune

### Importance du système modulaire

- **SystemBlocks réutilisables** : Même module utilisable sur différentes pages
- **Pages personnalisables** : Chaque restaurant peut organiser ses pages différemment
- **Protection des fonctionnalités core** : Les pages système ne peuvent pas être supprimées accidentellement

### Points d'extension futurs

| Extension | Description |
|-----------|-------------|
| Nouveaux modules | Ajouter des SystemBlocks pour d'autres fonctionnalités |
| Nouvelles pages système | Étendre la liste des pages protégées |
| Thématisation | Appliquer des thèmes différents par restaurant |
| Analytics | Suivre l'utilisation des modules par page |
| A/B testing | Tester différentes configurations de blocs |

### Structure d'extension

```dart
// Ajouter un nouveau module système
// 1. builder_block.dart - availableModules
// 2. system_block_runtime.dart - _buildNewModule()
// 3. builder_page_editor_screen.dart - bouton d'ajout
// 4. SYSTEM_BLOCKS.md - documentation

// Ajouter une nouvelle page système
// 1. builder_enums.dart - BuilderPageId
// 2. system_pages_initializer.dart - SystemPageConfig
// 3. dynamic_page_resolver.dart - route mapping
// 4. main.dart - route explicite
// 5. SYSTEM_PAGES.md - documentation
```

---

## Documents de référence

Pour plus de détails, consultez :

- 📄 [SYSTEM_BLOCKS.md](./SYSTEM_BLOCKS.md) - Documentation complète des SystemBlocks
- 📄 [SYSTEM_PAGES.md](./SYSTEM_PAGES.md) - Documentation complète des pages système
- 📄 [SYSTEM_PROTECTION.md](./SYSTEM_PROTECTION.md) - Règles de protection détaillées
- 📄 [PHASE_8_VALIDATION_CHECKLIST.md](./PHASE_8_VALIDATION_CHECKLIST.md) - Checklist de validation

---

## Historique des missions

| Mission | Objectif | Commit |
|---------|----------|--------|
| 8A | Création des SystemBlocks | Bloc type system, preview, runtime |
| 8B | Finalisation runtime | buildSystemBlock, Phase 5, erreurs |
| 8C | Intégration éditeur | Boutons ajout, icônes, panneau config |
| 8D | Pages système | Auto-création, protection, fallback |
| 8E | Protection complète | Firestore, éditeur, runtime |
| 8F | Actions navigation | openSystemPage, routes, resolver |
| 8G | Documentation | Consolidation, checklist validation |
