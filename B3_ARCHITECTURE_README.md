# Architecture B3 - Pages Dynamiques

## Vue d'ensemble

L'architecture B3 introduit un système de **pages dynamiques** basées sur des schémas JSON, permettant de construire des pages Flutter sans modifier le code.

## Phase 1 - Architecture de Base ✅

### Composants Implémentés

#### 1. Modèles de Données (`lib/src/models/page_schema.dart`)

- **`PageSchema`** : Définit une page complète
  - `id` : Identifiant unique
  - `name` : Nom de la page
  - `route` : Route d'accès (ex: `/menu-b3`)
  - `enabled` : Activation/désactivation
  - `blocks` : Liste de blocs de widgets
  - `metadata` : Métadonnées optionnelles

- **`WidgetBlock`** : Élément UI dans une page
  - `id` : Identifiant unique
  - `type` : Type de widget (text, image, button, etc.)
  - `order` : Ordre d'affichage
  - `visible` : Visibilité
  - `properties` : Propriétés du widget
  - `dataSource` : Source de données optionnelle
  - `styling` : Styles CSS-like
  - `actions` : Actions (navigation, etc.)

- **`DataSource`** : Configuration de source de données
  - `id` : Identifiant
  - `type` : Type (static, products, categories, etc.)
  - `config` : Configuration spécifique

- **`PagesConfig`** : Configuration globale des pages
  - `pages` : Liste de PageSchema
  - Méthodes : `findByRoute()`, `findById()`

#### 2. Extension d'AppConfig (`lib/src/models/app_config.dart`)

L'AppConfig B2 a été étendu avec un nouveau champ `pages` de type `PagesConfig`.

**Rétrocompatibilité** : ✅ Les configurations existantes restent valides. Si le champ `pages` est absent du JSON, un `PagesConfig.empty()` est utilisé par défaut.

#### 3. Renderer de Pages (`lib/src/widgets/page_renderer.dart`)

Widget Flutter qui construit une page à partir d'un `PageSchema`.

**Types de widgets supportés** :
- `text` : Texte avec styles (taille, couleur, alignement, bold)
- `image` : Images avec URL, dimensions, fit
- `button` : Boutons avec actions (navigation)
- `banner` : Bannières colorées
- `productList` : Liste de produits (placeholder - Phase 2)
- `categoryList` : Liste de catégories (placeholder - Phase 2)
- `custom` : Blocs personnalisés

**Fonctionnalités** :
- Parsing de couleurs hexadécimales (`#RRGGBB`, `#AARRGGBB`)
- Gestion du padding (uniforme ou par côté)
- Actions de navigation
- Tri automatique des blocs par ordre
- Filtrage des blocs visibles

#### 4. Route de Test (`/menu-b3`)

Une route de test a été ajoutée avec `MenuScreenB3` qui démontre l'utilisation du système avec un exemple complet.

**Exemple de page** :
- Bannière colorée
- Textes stylés (titre, description)
- Image
- Placeholder pour liste de produits
- Placeholder pour liste de catégories
- Bouton avec action de navigation

### Structure des Fichiers

```
lib/
├── src/
│   ├── models/
│   │   ├── app_config.dart          (étendu avec PagesConfig)
│   │   └── page_schema.dart         (nouveau - modèles B3)
│   ├── widgets/
│   │   └── page_renderer.dart       (nouveau - renderer)
│   ├── screens/
│   │   └── menu/
│   │       └── menu_screen_b3.dart  (nouveau - test route)
│   └── core/
│       └── constants.dart           (ajout route /menu-b3)
└── main.dart                        (ajout route)
```

## Utilisation

### 1. Accéder à la Page de Test

```
/menu-b3
```

### 2. Créer une Page Dynamique (Programmatique)

```dart
final pageSchema = PageSchema(
  id: 'ma_page',
  name: 'Ma Page',
  route: '/ma-page',
  enabled: true,
  blocks: [
    WidgetBlock(
      id: 'text_1',
      type: WidgetBlockType.text,
      order: 1,
      visible: true,
      properties: {
        'text': 'Bonjour !',
        'fontSize': 24.0,
        'bold': true,
      },
      styling: {
        'color': '#D62828',
        'padding': 16.0,
      },
    ),
  ],
);

// Utiliser le renderer
PageRenderer(pageSchema: pageSchema)
```

### 3. Configuration JSON (à venir dans Phase 2)

En Phase 2, les pages seront configurables depuis Firestore :

```json
{
  "pages": {
    "pages": [
      {
        "id": "menu_v3",
        "name": "Menu V3",
        "route": "/menu-v3",
        "enabled": true,
        "blocks": [
          {
            "id": "banner_1",
            "type": "banner",
            "order": 1,
            "visible": true,
            "properties": {
              "text": "🍕 Notre Menu"
            },
            "styling": {
              "backgroundColor": "#D62828",
              "textColor": "#FFFFFF"
            }
          }
        ]
      }
    ]
  }
}
```

## Compatibilité

✅ **AppConfig B2** : Rétrocompatible - aucune modification destructrice
✅ **HomeScreen B2** : Inchangé
✅ **Menu V1/V2** : Inchangés
✅ **Studio B2** : Inchangé (extension pour Phase 2)

## Contraintes Respectées

- ✅ Aucune suppression de fichiers existants
- ✅ Aucune modification destructrice
- ✅ Code ADDITIF uniquement
- ✅ Null-safety complet
- ✅ fromJson/toJson/copyWith sur tous les modèles
- ✅ Logique métier existante préservée

## Phase 2 - À Venir

Phase 2 inclura :

1. **Studio B3** : Interface admin pour éditer les PageSchemas
2. **DataSource Connectées** : Connexion réelle aux produits/catégories
3. **Widgets Avancés** : Plus de types de widgets (carrousel, grille, etc.)
4. **Conditionnalité** : Affichage conditionnel basé sur des règles
5. **Animations** : Transitions et animations configurables

## Tests

Pour tester l'architecture :

1. Lancez l'application
2. Connectez-vous
3. Naviguez vers `/menu-b3`
4. Vérifiez que la page s'affiche avec tous les éléments

## Notes Techniques

- Le `PageRenderer` est un `StatelessWidget` pour la performance
- Les blocs sont triés automatiquement par `order`
- Les blocs invisibles (`visible: false`) sont filtrés
- Les erreurs d'images sont gérées avec un placeholder
- Les couleurs invalides retournent `null` (utilise les valeurs par défaut du thème)
