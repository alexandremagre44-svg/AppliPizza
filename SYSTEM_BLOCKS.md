# System Blocks - Builder B3

## Vue d'ensemble

Les **SystemBlocks** sont un nouveau type de bloc dans le système Builder B3. Ces blocs représentent des modules système non configurables mais positionnables dans les pages du builder.

Contrairement aux autres blocs qui permettent une configuration détaillée (titre, couleur, contenu, etc.), les SystemBlocks affichent des fonctionnalités existantes de l'application avec leurs paramètres par défaut.

## Tableau des modules

| Module Type | Label | Icône | Description | Widget Runtime |
|-------------|-------|-------|-------------|----------------|
| `roulette` | Roulette | 🎰 | Accès à la roue de la chance | Carte d'accès avec bouton |
| `loyalty` | Fidélité | ⭐ | Points et progression fidélité | Carte avec points et barre |
| `rewards` | Récompenses | 🎁 | Tickets de récompenses actifs | Liste des tickets ou placeholder |
| `accountActivity` | Activité du compte | 📊 | Commandes et favoris | Statistiques avec liens |

## Rendu Preview

En mode **preview** (éditeur de page), les SystemBlocks affichent un placeholder simplifié :

### Caractéristiques
- **Hauteur fixe** : 120px par défaut
- **Fond** : Gris clair (`Colors.grey.shade200`)
- **Bordure** : Bleue en mode debug, grise sinon
- **Contenu** : Icône du module + nom + mention "Prévisualisation uniquement"
- **Aucune exécution** : Les widgets système réels ne sont jamais exécutés en preview

### Exemple visuel
```
┌─────────────────────────────────────────┐
│  🎰  Module Roulette                    │
│       Prévisualisation uniquement       │
└─────────────────────────────────────────┘
```

### Code
```dart
SystemBlockPreview(
  block: block,
  debugMode: true,  // Affiche bordure bleue
)
```

## Rendu Runtime

En mode **runtime** (application réelle), les SystemBlocks affichent les vrais widgets système.

### Caractéristiques
- **Pleine largeur** : `SizedBox(width: double.infinity)`
- **Configuration via BlockConfigHelper** :
  - `padding` : Espacement intérieur (défaut: 16px)
  - `margin` : Espacement extérieur
  - `backgroundColor` : Couleur de fond optionnelle
  - `height` : Hauteur fixe optionnelle
- **maxContentWidth** : Largeur maximale optionnelle
- **Gestion d'erreurs** : Fallback propre en cas d'exception

### Modules détaillés

#### Roulette (`roulette`)
Affiche une carte d'accès à la roue de la chance avec :
- Icône casino
- Titre "Roue de la Chance"
- Description
- Bouton "Jouer maintenant" (navigation vers `/roulette`)

#### Fidélité (`loyalty`)
Affiche les informations de fidélité :
- Points disponibles
- Niveau VIP (Bronze, Silver, Gold)
- Barre de progression
- Points restants pour la prochaine récompense

#### Récompenses (`rewards`)
Affiche les tickets de récompenses :
- Si aucun ticket : placeholder avec message
- Bouton "Voir toutes les récompenses"

#### Activité du compte (`accountActivity`)
Affiche les statistiques du compte :
- Nombre de commandes avec lien
- Nombre de favoris avec lien

## Intégration dans l'éditeur

### Comment ajouter un module système

1. Ouvrez l'éditeur de page Builder B3
2. Cliquez sur le bouton **+ Ajouter un bloc**
3. Dans la boîte de dialogue, faites défiler jusqu'à la section **"Modules système"** (en bleu)
4. Quatre boutons sont disponibles avec leurs icônes Material :
   - 🎰 **Ajouter module Roulette** (`Icons.casino`) - Roue de la chance
   - 🎁 **Ajouter module Fidélité** (`Icons.card_giftcard`) - Points et progression
   - ⭐ **Ajouter module Récompenses** (`Icons.stars`) - Tickets et bons
   - 📊 **Ajouter module Activité du compte** (`Icons.history`) - Commandes et favoris

5. Le module apparaîtra dans la liste des blocs et peut être repositionné par glisser-déposer

### Comment fonctionne leur panneau

Lorsqu'un SystemBlock est sélectionné dans l'éditeur, le panneau de configuration affiche :

```
┌─────────────────────────────────────────┐
│  🎰  [Module: Roulette]                 │
│       Type: roulette                    │
│                                         │
│  ℹ️  Ce module système ne possède pas   │
│      de configuration.                  │
└─────────────────────────────────────────┘
```

**Caractéristiques du panneau :**
- Affiche l'icône Material et le nom du module au format `[Module: Nom]`
- Affiche le type technique du module
- Message informatif : "Ce module système ne possède pas de configuration."
- Aucune option de personnalisation disponible

### Comment ils sont stockés dans Firestore

Les SystemBlocks sont stockés dans Firestore comme tout autre bloc :

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

**Points importants :**
- La création fonctionne depuis un brouillon
- La sauvegarde automatique conserve les SystemBlocks
- La publication vers Firestore fonctionne normalement
- Le rechargement d'un brouillon charge correctement les SystemBlocks
- Aucun plantage si un module système est supprimé

### Preview vs Runtime

| Aspect | Preview (Éditeur) | Runtime (Application) |
|--------|-------------------|----------------------|
| **Hauteur** | Fixe 120px | Variable selon contenu |
| **Contenu** | Placeholder gris avec nom | Widget réel du module |
| **Bordure** | Bleue en mode debug | Selon configuration |
| **Exécution** | Aucune | Widgets système actifs |
| **Format nom** | `[Module: Roulette]` | Contenu réel |

**Preview dans l'éditeur :**
```
┌─────────────────────────────────────────┐
│  🎰  [Module: Roulette]                 │
│       Prévisualisation uniquement       │
└─────────────────────────────────────────┘
```

**Runtime dans l'application :**
Le widget système réel est affiché avec toutes ses fonctionnalités.

## Ajouter un module dans une page

### Via l'interface d'édition

1. Ouvrez l'éditeur de page Builder B3
2. Cliquez sur le bouton **+ Ajouter un bloc**
3. Dans la boîte de dialogue, faites défiler jusqu'à la section **"Modules système"**
4. Cliquez sur le module souhaité :
   - **Ajouter module Roulette** - Ajoute la roue de la chance
   - **Ajouter module Fidélité** - Ajoute la section points de fidélité
   - **Ajouter module Récompenses** - Ajoute les tickets de récompenses
   - **Ajouter module Activité du compte** - Ajoute l'activité du compte

5. Le module apparaîtra dans la liste des blocs et peut être repositionné par glisser-déposer

### Via le code (programmatique)

```dart
// Créer un SystemBlock
final rouletteBlock = SystemBlock(
  id: 'block_${DateTime.now().millisecondsSinceEpoch}',
  moduleType: 'roulette',
  order: page.blocks.length,
);

// Ajouter à la page
page = page.addBlock(rouletteBlock);
```

## Exemples d'utilisation

### Exemple 1 : Page d'accueil avec roulette

```dart
final homePage = BuilderPage(
  pageId: BuilderPageId.home,
  appId: 'my_app',
  name: 'Accueil',
  blocks: [
    BuilderBlock(
      id: 'hero_1',
      type: BlockType.hero,
      order: 0,
      config: {'title': 'Bienvenue'},
    ),
    SystemBlock(
      id: 'roulette_1',
      moduleType: 'roulette',
      order: 1,
    ),
    SystemBlock(
      id: 'loyalty_1',
      moduleType: 'loyalty',
      order: 2,
    ),
  ],
);
```

### Exemple 2 : Page profil avec tous les modules

```dart
final profilePage = BuilderPage(
  pageId: BuilderPageId.profile,
  appId: 'my_app',
  name: 'Mon profil',
  blocks: [
    SystemBlock(id: 'loyalty', moduleType: 'loyalty', order: 0),
    SystemBlock(id: 'rewards', moduleType: 'rewards', order: 1),
    SystemBlock(id: 'activity', moduleType: 'accountActivity', order: 2),
  ],
);
```

### Exemple 3 : Rendu avec maxContentWidth

```dart
BuilderRuntimeRenderer(
  blocks: page.blocks,
  maxContentWidth: 600.0,  // Contenu centré, max 600px
  wrapInScrollView: true,
)
```

## Comment fonctionne SystemBlock

### Architecture

```
BlockType.system
    └── SystemBlock extends BuilderBlock
            ├── moduleType: String (type du module à afficher)
            ├── config: Map<String, dynamic> (contient le moduleType)
            └── Hérite de toutes les propriétés de BuilderBlock
```

### Phase 5 : Règles respectées

1. **Zéro ConsumerWidget** : `SystemBlockRuntime` est un `StatelessWidget` pur
2. **Zéro logique métier** : Données de démo uniquement, pas d'appel aux providers
3. **Layout dans renderer** : Toute la mise en page via `builder_runtime_renderer.dart`
4. **Styling via BlockConfigHelper** : Padding, margin, backgroundColor, height

### Widgets

| Fichier | Description |
|---------|-------------|
| `system_block_runtime.dart` | Rendu réel des modules dans l'application (StatelessWidget) |
| `system_block_preview.dart` | Aperçu simplifié dans l'éditeur (hauteur 120px) |

### Flux de rendu

1. **Création** : `SystemBlock(moduleType: 'roulette', ...)`
2. **Stockage** : Sérialisé en JSON avec `type: 'system'` et `config: {moduleType: 'roulette'}`
3. **Preview** : Affiche placeholder gris 120px avec nom du module
4. **Runtime** : Affiche le widget réel via `buildSystemBlock()`

## Gestion des erreurs

### Module inconnu

Si `moduleType` n'est pas reconnu :
```
┌─────────────────────────────────────────┐
│  ⚠️  Module système inconnu             │
│       Type: unknown_module              │
└─────────────────────────────────────────┘
```

### Exception de rendu

Si une exception se produit lors du rendu :
```
┌─────────────────────────────────────────┐
│  ⚠️  Erreur de rendu                    │
│       Module: roulette                  │
│       (message d'erreur en debug)       │
└─────────────────────────────────────────┘
```

## Compatibilité

### Firestore

Les SystemBlocks sont entièrement compatibles avec le stockage Firestore :

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

### Drafts et Published

Les SystemBlocks fonctionnent de manière identique pour :
- Les brouillons (drafts)
- Les pages publiées (published)

Aucun traitement spécial n'est requis lors de la publication.

### Impact sur l'application

Le rendu système n'affecte pas :
- Les blocs classiques (hero, text, banner, etc.)
- La navigation dynamique
- La publication Firestore
- Le fonctionnement du builder

## Ajouter un nouveau module système

Pour ajouter un nouveau type de module système :

### 1. Mettre à jour SystemBlock

```dart
// Dans builder_block.dart
static const List<String> availableModules = [
  'roulette',
  'loyalty',
  'rewards',
  'accountActivity',
  'nouveauModule', // Ajouter ici
];

static String getModuleLabel(String moduleType) {
  switch (moduleType) {
    // ...
    case 'nouveauModule':
      return 'Nouveau Module';
    // ...
  }
}

static String getModuleIcon(String moduleType) {
  switch (moduleType) {
    // ...
    case 'nouveauModule':
      return '🆕';
    // ...
  }
}
```

### 2. Mettre à jour le runtime

```dart
// Dans system_block_runtime.dart
Widget _buildModuleWidget(BuildContext context, String moduleType) {
  switch (moduleType) {
    // ...
    case 'nouveauModule':
      return _buildNouveauModule(context);
    // ...
  }
}

Widget _buildNouveauModule(BuildContext context) {
  return Container(/* widget du module */);
}
```

### 3. Mettre à jour l'éditeur

```dart
// Dans builder_page_editor_screen.dart, dans _showAddBlockDialog()
ListTile(
  leading: const Text('🆕', style: TextStyle(fontSize: 24)),
  title: const Text('Ajouter module Nouveau Module'),
  subtitle: const Text('Description du module'),
  onTap: () {
    Navigator.pop(context);
    _addSystemBlock('nouveauModule');
  },
),
```

## Bonnes pratiques

1. **Ne pas exposer de configuration** : Les SystemBlocks sont conçus pour être simples et non configurables
2. **StatelessWidget uniquement** : Pas de ConsumerWidget dans les blocs
3. **Données de démo** : Utiliser des données de démo en runtime, les vraies données viennent des providers parents
4. **Gérer les erreurs** : Toujours prévoir un fallback propre
5. **Preview légère** : Jamais d'exécution de widgets système réels en preview

## Limitations

- Les SystemBlocks ne peuvent pas être personnalisés (couleurs, textes, etc.)
- Les modules affichent des données de démo (l'intégration avec les providers est à faire au niveau parent)
- En mode preview, seul un placeholder est affiché
