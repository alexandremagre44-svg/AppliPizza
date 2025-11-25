# System Pages - Builder B3

## Vue d'ensemble

Les **pages système** sont des pages essentielles de l'application qui sont créées automatiquement si elles n'existent pas dans Firestore. Ces pages sont protégées contre la suppression mais peuvent être personnalisées avec des blocs.

## Liste des pages système

| Page ID | Titre | Route | Icône | Description |
|---------|-------|-------|-------|-------------|
| `profile` | Profil | `/profile` | `person` | Page de profil utilisateur |
| `cart` | Panier | `/cart` | `shopping_cart` | Page du panier d'achat |
| `rewards` | Récompenses | `/rewards` | `card_giftcard` | Page des récompenses et tickets |
| `roulette` | Roulette | `/roulette` | `casino` | Page de la roue de la chance |

## Règles de protection

### Ce qui est protégé

- **Suppression interdite** : Les pages système ne peuvent pas être supprimées
- **PageId immuable** : L'identifiant de la page ne peut pas être modifié
- **Création automatique** : Si une page système n'existe pas, elle est créée automatiquement

### Ce qui est modifiable

- **Blocs** : Vous pouvez ajouter, modifier, supprimer et réorganiser les blocs
- **Contenu** : Le contenu de chaque bloc est entièrement personnalisable
- **Affichage** : Vous pouvez modifier `displayLocation` pour afficher/masquer dans la navigation
- **Nom** : Le titre affiché de la page peut être modifié
- **Icône** : L'icône de navigation peut être changée

### Indicateur visuel

Lorsqu'une page système est ouverte dans l'éditeur, un bandeau bleu indique :

```
┌──────────────────────────────────────────┐
│ 🛡️ Page système protégée              ℹ️ │
└──────────────────────────────────────────┘
```

## Rendu Builder vs Legacy

### Comportement du resolver

Le `DynamicPageResolver` gère automatiquement le rendu :

1. **Si la page existe dans Builder** :
   - Charge la version publiée de Firestore
   - Affiche les blocs configurés
   - Les SystemBlocks affichent leurs widgets réels

2. **Si la page n'existe pas dans Builder** (fallback) :
   - Les routes vers `/profile`, `/cart`, `/rewards`, `/roulette` affichent les écrans legacy
   - L'expérience utilisateur reste cohérente

### Exemple de résolution

```dart
final resolver = DynamicPageResolver();
final page = await resolver.resolveByRoute('/profile', 'pizza_delizza');

if (page != null) {
  // Afficher la page Builder
  return BuilderRuntimeRenderer(blocks: page.blocks);
} else {
  // Fallback vers l'écran legacy
  return ProfileScreen();
}
```

## Création automatique

### Service SystemPagesInitializer

Le service `SystemPagesInitializer` vérifie et crée automatiquement les pages système manquantes :

```dart
final initializer = SystemPagesInitializer();
final createdPages = await initializer.initSystemPages('pizza_delizza');

// Retourne la liste des pages créées
// Ex: [BuilderPageId.profile, BuilderPageId.cart]
```

### Quand utiliser

- **Au démarrage de l'app** : Appeler `initSystemPages()` au lancement
- **Manuellement** : Depuis le panneau admin pour réparer les pages manquantes
- **Migration** : Lors d'une mise à jour ajoutant de nouvelles pages système

### Exemple d'intégration

```dart
// Dans le main() ou au démarrage de l'app
void initApp() async {
  final appId = 'pizza_delizza';
  
  // Initialiser les pages système
  final initializer = SystemPagesInitializer();
  await initializer.initSystemPages(appId);
  
  // Vérifier les pages manquantes
  final missing = await initializer.getMissingSystemPages(appId);
  if (missing.isNotEmpty) {
    debugPrint('Pages manquantes: ${missing.map((p) => p.value).join(', ')}');
  }
}
```

## Cas où elles n'existent pas

### Création automatique

Si une page système n'existe pas dans Firestore, elle est créée avec :

- `blocks: []` (vide, à personnaliser)
- `displayLocation: "hidden"` (pas dans la navigation)
- `icon: ""` (icône par défaut du type de page)
- `order: 999` (dernier dans l'ordre)
- `isSystemPage: true` (protection activée)

### Journalisation

Le service enregistre chaque création dans la console debug :

```
✅ Created system page: profile for app pizza_delizza
✅ Created system page: cart for app pizza_delizza
✅ Created 2 system pages: profile, cart
```

## Structure Firestore

### Emplacement

```
builder/apps/{appId}/pages/{pageId}/draft
builder/apps/{appId}/pages/{pageId}/published
```

### Exemple de document

```json
{
  "pageId": "profile",
  "appId": "pizza_delizza",
  "name": "Profil",
  "description": "Page de profil utilisateur (page système)",
  "route": "/profile",
  "blocks": [],
  "isEnabled": true,
  "isDraft": false,
  "displayLocation": "hidden",
  "icon": "person",
  "order": 999,
  "isSystemPage": true,
  "version": 1,
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z",
  "publishedAt": "2024-01-15T10:30:00.000Z",
  "lastModifiedBy": "system"
}
```

### Champs spécifiques

| Champ | Type | Description |
|-------|------|-------------|
| `isSystemPage` | `bool` | `true` pour les pages système |
| `displayLocation` | `string` | `"hidden"` par défaut pour les pages système |
| `lastModifiedBy` | `string` | `"system"` lors de la création automatique |

## Navigation dynamique

### Configuration dans la navigation

Les pages système apparaissent dans la barre de navigation **uniquement si** :

```dart
displayLocation == "bottomBar"
```

### Modifier l'affichage

Pour afficher une page système dans la navigation :

1. Ouvrir l'éditeur de la page
2. Modifier `displayLocation` vers "bottomBar"
3. Définir un `order` approprié
4. Publier la page

### Exemple de configuration

```dart
// Page panier visible dans la navigation
final cartPage = BuilderPage(
  pageId: BuilderPageId.cart,
  displayLocation: 'bottomBar',
  icon: 'shopping_cart',
  order: 3,
  isSystemPage: true,
  // ... autres champs
);
```

## Ajouter une nouvelle page système

### 1. Mettre à jour les enums

```dart
// Dans builder_enums.dart
enum BuilderPageId {
  // ... pages existantes
  newSystemPage('new_system_page', 'Nouvelle Page');
  
  // Ajouter à la liste des IDs système
  static const List<String> systemPageIds = [
    'profile', 'cart', 'rewards', 'roulette', 'new_system_page'
  ];
}
```

### 2. Mettre à jour l'initializer

```dart
// Dans system_pages_initializer.dart
static const List<SystemPageConfig> systemPages = [
  // ... pages existantes
  SystemPageConfig(
    pageId: BuilderPageId.newSystemPage,
    title: 'Nouvelle Page',
    route: '/new-system-page',
    icon: 'new_releases',
    description: 'Description de la nouvelle page système',
  ),
];
```

### 3. Mettre à jour le resolver

```dart
// Dans dynamic_page_resolver.dart, _routeToPageId()
case '/new-system-page':
  return BuilderPageId.newSystemPage;
```

## Bonnes pratiques

1. **Ne jamais supprimer manuellement** les documents Firestore des pages système
2. **Toujours utiliser le service** `SystemPagesInitializer` pour créer les pages
3. **Tester le fallback** legacy avant de déployer
4. **Prévoir des blocs par défaut** pour une meilleure expérience utilisateur

## Limitations

- Les pages système ne peuvent pas avoir un pageId personnalisé
- La suppression via l'interface est bloquée mais pas au niveau Firestore
- Le fallback legacy doit être maintenu tant que les pages peuvent ne pas exister

## Actions système (openSystemPage)

L'action `openSystemPage` permet aux blocs de naviguer vers une page système via un clic.

### Configuration

Dans l'éditeur de page, les blocs interactifs (text, hero, image, button) peuvent être configurés avec :

1. **Type d'action** : `openSystemPage`
2. **Page cible** : `profile`, `cart`, `rewards`, ou `roulette`

### Pages cibles

| Identifiant | Label dans l'éditeur | Route |
|-------------|---------------------|-------|
| `profile` | Page Profil | `/profile` |
| `cart` | Page Panier | `/cart` |
| `rewards` | Page Récompenses | `/rewards` |
| `roulette` | Page Roulette | `/roulette` |

### Exemple de bloc avec action

```dart
BuilderBlock(
  id: 'btn_rewards',
  type: BlockType.button,
  config: {
    'label': 'Voir mes récompenses',
    'tapAction': 'openSystemPage',
    'tapActionTarget': 'rewards',
  },
)
```

### Format Firestore

```json
{
  "type": "button",
  "config": {
    "label": "Voir mes récompenses",
    "tapAction": "openSystemPage",
    "tapActionTarget": "rewards"
  }
}
```

### Comportement

- **Runtime** : La navigation s'effectue via `go_router` vers la route correspondante
- **Preview** : L'action n'est pas exécutée pour permettre la sélection du bloc
- **Builder-first** : Si une version Builder de la page existe, elle est affichée ; sinon, l'écran legacy est utilisé

### Note technique

L'action utilise `ActionHelper.executeSystemPageNavigation(context, pageId)` qui :
1. Valide l'identifiant de la page système
2. Obtient la route correspondante via `SystemPageRoutes`
3. Navigue via `context.go(route)`
