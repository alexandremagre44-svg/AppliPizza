# Architecture B3 - Phase 2 : Intégration des Pages Dynamiques

## Vue d'ensemble

La Phase 2 de l'architecture B3 ajoute l'intégration complète des pages dynamiques dans l'application, permettant de naviguer vers des pages définies dans AppConfig sans modifier le code Flutter.

## Nouveautés Phase 2 ✅

### 1. Pages par Défaut dans AppConfig

Trois pages dynamiques sont maintenant créées automatiquement lors de l'initialisation :

#### Menu B3 (`/menu-b3`)
- Bannière rouge "🍕 Notre Menu"
- Titre "Découvrez nos pizzas"
- Liste de produits (placeholder avec DataSource)

#### Catégories B3 (`/categories-b3`)
- Bannière verte "📂 Catégories"
- Titre "Explorez nos catégories"
- Liste de catégories (placeholder avec DataSource)

#### Panier B3 (`/cart-b3`)
- Bannière bleue "🛒 Votre Panier"
- Message "Votre panier est vide"
- Sous-titre informatif
- Bouton "Retour au menu" avec navigation

### 2. Méthodes Utilitaires PagesConfig

Nouvelles méthodes ajoutées à `PagesConfig` :

```dart
// Récupérer une page par route (alias de findByRoute)
PageSchema? getPage(String route)

// Vérifier si une page existe
bool hasPage(String route)

// Factory pour créer la config avec pages par défaut
factory PagesConfig.initial()
```

### 3. DynamicPageScreen

Nouveau widget qui affiche une page dynamique :

```dart
DynamicPageScreen(pageSchema: pageSchema)
```

**Caractéristiques** :
- Utilise `PageRenderer` pour l'affichage
- Gestion d'erreur avec `PageNotFoundScreen`
- Widget léger et réutilisable

### 4. PageNotFoundScreen

Écran d'erreur élégant affiché quand une page B3 n'existe pas :
- Icône de recherche barrée
- Message clair "Page B3 non trouvée"
- Route demandée affichée
- Bouton retour

### 5. Router Dynamique

Méthode helper dans `MyApp` :

```dart
static Widget _buildDynamicPage(BuildContext context, WidgetRef ref, String route)
```

**Fonctionnement** :
1. Récupère l'AppConfig (via service)
2. Cherche la page avec `config.pages.getPage(route)`
3. Si trouvée → `DynamicPageScreen`
4. Sinon → `PageNotFoundScreen`

### 6. Routes de Test Ajoutées

Routes accessibles dans l'application :

```
/menu-b3          → Menu dynamique B3
/categories-b3    → Catégories dynamiques B3
/cart-b3          → Panier dynamique B3
```

Constantes ajoutées dans `AppRoutes` :
- `AppRoutes.menuB3`
- `AppRoutes.categoriesB3`
- `AppRoutes.cartB3`

## Structure des Fichiers

```
lib/
├── src/
│   ├── models/
│   │   ├── app_config.dart           (updated: PagesConfig.initial())
│   │   └── page_schema.dart          (updated: getPage, hasPage, initial)
│   ├── services/
│   │   └── app_config_service.dart   (updated: comment)
│   ├── screens/
│   │   └── dynamic/
│   │       └── dynamic_page_screen.dart (nouveau)
│   └── core/
│       └── constants.dart            (updated: new routes)
└── main.dart                         (updated: routes + helper)
```

## Utilisation

### 1. Accéder aux Pages Dynamiques

```dart
// Navigation programmatique
context.go('/categories-b3');
context.go('/cart-b3');

// Ou depuis un bouton dans PageSchema
WidgetBlock(
  type: WidgetBlockType.button,
  properties: {'label': 'Voir les catégories'},
  actions: {'onTap': 'navigate:/categories-b3'},
)
```

### 2. Créer une Nouvelle Page Dynamique

**Option A : Via Code (temporaire)** :

```dart
// Dans PagesConfig.initial(), ajouter :
static PageSchema _createMyCustomPage() {
  return PageSchema(
    id: 'my_page',
    name: 'Ma Page',
    route: '/my-page',
    enabled: true,
    blocks: [
      // ... vos blocs
    ],
  );
}
```

**Option B : Via Firestore (Phase 3 - à venir)** :

Depuis le Studio B3, créer et publier des pages directement dans Firestore.

### 3. Vérifier si une Page Existe

```dart
final config = appConfigService.getDefaultConfig('pizza_delizza');

if (config.pages.hasPage('/my-route')) {
  // La page existe
  final page = config.pages.getPage('/my-route');
  // Utiliser la page
}
```

## Auto-Initialisation

Lors du premier lancement de l'app :

1. `AppConfigService.getConfig()` est appelé
2. Si la config n'existe pas → `getDefaultConfig()` est appelé
3. `AppConfig.initial()` crée la config avec `PagesConfig.initial()`
4. Les 3 pages par défaut sont incluses automatiquement
5. La config est sauvegardée dans Firestore

**Résultat** : Les routes `/menu-b3`, `/categories-b3`, et `/cart-b3` fonctionnent immédiatement.

## Compatibilité

✅ **Rétrocompatibilité totale** :
- Les configurations sans `pages` → `PagesConfig.empty()`
- Les configurations avec `pages` → Parse les pages
- Aucun impact sur les écrans existants

✅ **Additif uniquement** :
- Nouvelles routes ajoutées
- Nouveaux fichiers créés
- Aucune suppression ni modification destructive

✅ **Gestion d'erreur** :
- Page non trouvée → `PageNotFoundScreen`
- Config invalide → Logs + fallback
- Navigation sécurisée

## Exemple Complet

### Définir une Page

```dart
PageSchema(
  id: 'promo_page',
  name: 'Promotions',
  route: '/promos',
  enabled: true,
  blocks: [
    WidgetBlock(
      id: 'promo_banner',
      type: WidgetBlockType.banner,
      order: 1,
      visible: true,
      properties: {'text': '🎉 Promotions du jour'},
      styling: {
        'backgroundColor': '#FF5722',
        'textColor': '#FFFFFF',
      },
    ),
    WidgetBlock(
      id: 'promo_text',
      type: WidgetBlockType.text,
      order: 2,
      visible: true,
      properties: {
        'text': 'Profitez de nos offres exceptionnelles',
        'fontSize': 18.0,
        'align': 'center',
      },
    ),
  ],
)
```

### Ajouter la Route

```dart
// Dans main.dart, ShellRoute > routes
GoRoute(
  path: '/promos',
  builder: (context, state) => _buildDynamicPage(context, ref, '/promos'),
),
```

### Naviguer

```dart
// Depuis n'importe où dans l'app
context.go('/promos');
```

## Tests

Pour tester les pages dynamiques :

1. **Lancer l'app**
2. **Se connecter**
3. **Naviguer vers** :
   - `/menu-b3` → Voir le menu dynamique
   - `/categories-b3` → Voir les catégories dynamiques
   - `/cart-b3` → Voir le panier dynamique
4. **Essayer une route invalide** :
   - `/page-inexistante` → Voir `PageNotFoundScreen`

## Différences Phase 1 vs Phase 2

| Aspect | Phase 1 | Phase 2 |
|--------|---------|---------|
| **Modèles** | PageSchema défini | ✅ Idem |
| **Renderer** | PageRenderer créé | ✅ Idem |
| **Pages par défaut** | ❌ Aucune | ✅ 3 pages (menu, categories, cart) |
| **Intégration AppConfig** | ✅ Champ pages ajouté | ✅ Pages initial incluses |
| **Routes dynamiques** | ❌ Route fixe /menu-b3 | ✅ Routes multiples + helper |
| **DynamicPageScreen** | ❌ N'existe pas | ✅ Widget créé |
| **Gestion erreur** | ❌ Aucune | ✅ PageNotFoundScreen |
| **Méthodes utils** | findByRoute, findById | ✅ + getPage, hasPage |

## Prochaines Étapes (Phase 3)

Phase 3 inclura :

1. **Studio B3** : Interface admin pour créer/éditer les PageSchemas
2. **Connexion DataSource** : Lier les DataSources aux vrais produits/catégories Firestore
3. **Router générique** : Route `/page/:routeName` pour toutes les pages
4. **Preview temps réel** : Prévisualisation dans le Studio
5. **Versioning** : Gestion des versions de pages (draft/published)
6. **Analytics** : Tracking des pages dynamiques

## Notes Techniques

- Les pages sont chargées de manière synchrone pour l'instant (via `getDefaultConfig`)
- En production, elles seront chargées depuis Firestore de manière asynchrone
- Le `_buildDynamicPage` peut être optimisé avec un provider/state management
- Les DataSources (productList, categoryList) affichent des placeholders pour l'instant

## Sécurité

- ✅ Validation des routes (enabled check)
- ✅ Gestion des nulls (getPage retourne null si non trouvée)
- ✅ Pas d'exception UI (PageNotFoundScreen en fallback)
- ✅ Types stricts partout

## Performance

- Pages chargées à la demande (pas de pré-chargement)
- PageRenderer est un StatelessWidget (optimal)
- Pas de rebuild inutile
- Widgets cachés ne sont pas construits (visible: false)
