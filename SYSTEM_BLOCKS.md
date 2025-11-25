# System Blocks - Builder B3

## Vue d'ensemble

Les **SystemBlocks** sont un nouveau type de bloc dans le système Builder B3. Ces blocs représentent des modules système non configurables mais positionnables dans les pages du builder.

Contrairement aux autres blocs qui permettent une configuration détaillée (titre, couleur, contenu, etc.), les SystemBlocks affichent des fonctionnalités existantes de l'application avec leurs paramètres par défaut.

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

## Comment fonctionne SystemBlock

### Architecture

```
BlockType.system
    └── SystemBlock extends BuilderBlock
            ├── moduleType: String (type du module à afficher)
            ├── config: Map<String, dynamic> (contient le moduleType)
            └── Hérite de toutes les propriétés de BuilderBlock
```

### Classe SystemBlock

La classe `SystemBlock` étend `BuilderBlock` avec les spécificités suivantes :

- **Type** : `BlockType.system` (fixe)
- **moduleType** : Type du module système à afficher (obligatoire)
- **config** : Contient automatiquement le `moduleType`
- **Non configurable** : Aucune option de personnalisation dans l'éditeur

### Widgets

| Fichier | Description |
|---------|-------------|
| `system_block_runtime.dart` | Rendu réel des modules dans l'application |
| `system_block_preview.dart` | Aperçu simplifié dans l'éditeur |

### Flux de rendu

1. **Création** : `SystemBlock(moduleType: 'roulette', ...)`
2. **Stockage** : Sérialisé en JSON avec `type: 'system'` et `config: {moduleType: 'roulette'}`
3. **Preview** : Affiche une boîte grise avec le nom du module
4. **Runtime** : Affiche le widget réel correspondant au module

## Liste des modules disponibles

| Module Type | Label | Icône | Widget associé |
|-------------|-------|-------|----------------|
| `roulette` | Roulette | 🎰 | `RouletteScreen` (version intégrée) |
| `loyalty` | Fidélité | ⭐ | `LoyaltySectionWidget` |
| `rewards` | Récompenses | 🎁 | `RewardsTicketsWidget` |
| `accountActivity` | Activité du compte | 📊 | `AccountActivityWidget` |

### Détails des modules

#### Roulette (`roulette`)
Affiche un accès à la roue de la chance. Dans le runtime, présente une carte avec un bouton pour accéder à la page de la roulette.

#### Fidélité (`loyalty`)
Affiche les informations de fidélité de l'utilisateur :
- Points de fidélité disponibles
- Niveau VIP (Bronze, Silver, Gold)
- Progression vers la prochaine récompense

#### Récompenses (`rewards`)
Affiche les tickets de récompenses actifs de l'utilisateur :
- Liste des 3 premiers tickets
- Lien vers la page complète des récompenses

#### Activité du compte (`accountActivity`)
Affiche les statistiques du compte utilisateur :
- Nombre de commandes
- Nombre de favoris
- Liens vers les pages correspondantes

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
Widget _buildModuleWidget(BuildContext context, WidgetRef ref, String moduleType) {
  switch (moduleType) {
    // ...
    case 'nouveauModule':
      return _buildNouveauModule(context, ref);
    // ...
  }
}

Widget _buildNouveauModule(BuildContext context, WidgetRef ref) {
  return NouveauModuleWidget(/* ... */);
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
2. **Utiliser les widgets existants** : Les modules doivent réutiliser les widgets de l'application
3. **Gérer les états de chargement** : Les modules peuvent avoir besoin de charger des données
4. **Prévoir un fallback** : Si un module n'est pas reconnu, afficher un message d'erreur gracieux

## Limitations

- Les SystemBlocks ne peuvent pas être personnalisés (couleurs, textes, etc.)
- Les modules dépendent des providers et services de l'application
- En mode preview, seul un placeholder est affiché
