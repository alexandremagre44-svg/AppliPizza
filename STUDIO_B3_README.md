# Studio B3 - Éditeur de Pages Dynamiques

## Vue d'ensemble

Le Studio B3 est un éditeur complet pour créer et modifier des pages dynamiques basées sur des schémas JSON (`PageSchema`). Il permet de construire des pages Flutter sans écrire de code.

## Accès

**Route:** `/admin/studio-b3`

**Accès:** Réservé aux administrateurs uniquement

## Architecture

Le Studio B3 suit le même modèle que le Studio B2 avec une interface à 3 panneaux pour l'édition de pages.

### Structure des Fichiers

```
lib/src/admin/studio_b3/
├── studio_b3_page.dart          # Page principale avec gestion des pages
├── page_list.dart               # Liste des pages (vue grille)
├── page_editor.dart             # Éditeur 3 panneaux
└── widgets/
    ├── block_list_panel.dart    # Panneau gauche: liste de blocs
    ├── block_editor_panel.dart  # Panneau centre: formulaires d'édition
    └── preview_panel.dart       # Panneau droite: aperçu live
```

## Fonctionnalités Principales

### 1. Page List (Vue Principale)

La vue principale affiche toutes les pages B3 sous forme de grille.

#### Fonctionnalités:
- **Liste des pages** : Affichage en grille avec cartes
- **Activation/Désactivation** : Switch pour activer/désactiver une page
- **Informations** : Nom, route, nombre de blocs
- **Actions** :
  - 📝 **Modifier** : Ouvre l'éditeur de page
  - 🗑️ **Supprimer** : Supprime la page (avec confirmation)
  - ➕ **Ajouter une page** : Crée une nouvelle page vide

#### Aperçu de la carte de page:
```
┌─────────────────────────────────┐
│ Nom de la page           [ON/OFF]│
│ /route-de-la-page               │
│ X bloc(s)                       │
│ [Modifier] [🗑️]                 │
└─────────────────────────────────┘
```

### 2. Page Editor (Éditeur 3 Panneaux)

L'éditeur de page offre une interface à 3 panneaux pour l'édition complète.

#### Layout:
```
┌─────────────────────────────────────────────────────────────────┐
│ [←] Nom de la page        Route: /...    [💾 Sauvegarder]      │
├─────────────┬───────────────────────┬──────────────────────────┤
│             │                       │                          │
│   BLOCS     │      ÉDITEUR         │       APERÇU            │
│   (gauche)  │      (centre)        │       (droite)          │
│             │                       │                          │
│   - Texte   │   Propriétés du bloc │   [Phone Mockup]        │
│   - Image   │   - Champ 1          │   ┌──────────┐         │
│   - Bouton  │   - Champ 2          │   │  LIVE    │         │
│   - ...     │   - Champ 3          │   │          │         │
│             │                       │   │  Preview │         │
│   [+ Ajouter]│   Style              │   │          │         │
│             │   Actions            │   └──────────┘         │
│             │                       │                          │
└─────────────┴───────────────────────┴──────────────────────────┘
```

### 3. Panneau Gauche: Liste de Blocs

#### Fonctionnalités:
- **Liste ordonnée** : Affiche tous les blocs de la page
- **Drag & Drop** : Réorganisation par glisser-déposer
- **Sélection** : Cliquer sur un bloc pour l'éditer
- **Visibilité** : Toggle ON/OFF pour chaque bloc
- **Actions par bloc** :
  - 📋 **Dupliquer** : Crée une copie du bloc
  - 🗑️ **Supprimer** : Supprime le bloc
- **Ajout** : Bouton pour ajouter un nouveau bloc

#### Types de blocs disponibles:
- 📝 **Texte** : Paragraphe de texte
- 🔘 **Bouton** : Bouton d'action
- 🖼️ **Image** : Image ou photo
- 📰 **Bannière** : Bannière colorée
- 📦 **Liste de produits** : Grille de produits
- 📂 **Liste de catégories** : Grille de catégories
- 🧩 **Personnalisé** : Bloc custom

#### Affichage d'un bloc:
```
┌─────────────────────────┐
│ 📝 Texte         [ON/OFF]│
│ ID: block_123456        │
│             [📋] [🗑️]   │
└─────────────────────────┘
```

### 4. Panneau Centre: Éditeur de Bloc

Formulaire dynamique qui change selon le type de bloc sélectionné.

#### Sections:
1. **Propriétés** : Champs spécifiques au type de bloc
2. **Style** : Couleurs, padding, etc.
3. **Actions** : Actions de navigation (pour les boutons)

#### Champs par type de bloc:

**Texte:**
- ✏️ Texte (multiline)
- 🔤 Taille de police (px)
- ↔️ Alignement (left/center/right/justify)
- **B** Gras (toggle)
- 🎨 Couleur

**Bouton:**
- ✏️ Texte du bouton
- 🎨 Couleur de fond
- 🎨 Couleur du texte
- 🔗 Action (navigate:/route, back)

**Image:**
- 🔗 URL de l'image
- 📏 Hauteur (px)
- 📐 Ajustement (cover/contain/fill/fitWidth/fitHeight)

**Bannière:**
- ✏️ Texte de la bannière
- 🎨 Couleur de fond
- 🎨 Couleur du texte

**Liste de produits:**
- ✏️ Titre
- 📊 DataSource (à connecter en Phase 4)

**Liste de catégories:**
- ✏️ Titre
- 📊 DataSource (à connecter en Phase 4)

#### Style (pour tous les blocs):
- 🎨 Couleur (hex: #RRGGBB)
- 🎨 Couleur de fond (hex: #RRGGBB)
- 📦 Padding (px)

### 5. Panneau Droite: Aperçu Live

#### Fonctionnalités:
- **Rendu temps réel** : Utilise `PageRenderer`
- **Mockup téléphone** : Dimensions iPhone (375px)
- **Barre d'état** : Simule l'UI iOS
- **Mise à jour automatique** : À chaque modification

#### Affichage:
```
┌──────────────────┐
│  📱 Aperçu  LIVE │
├──────────────────┤
│ ┌──────────────┐ │
│ │ 9:41      ☀️ │ │ (Status bar)
│ ├──────────────┤ │
│ │              │ │
│ │   [PREVIEW]  │ │
│ │              │ │
│ │   Bloc 1     │ │
│ │   Bloc 2     │ │
│ │   ...        │ │
│ │              │ │
│ └──────────────┘ │
└──────────────────┘
```

## Workflow d'Utilisation

### Créer une nouvelle page

1. Aller sur `/admin/studio-b3`
2. Cliquer sur **"Ajouter une page"**
3. Une nouvelle page est créée avec:
   - ID unique généré automatiquement
   - Nom: "Nouvelle Page"
   - Route: "/new-page"
   - Enabled: false (désactivée par défaut)
   - Aucun bloc

### Éditer une page

1. Cliquer sur **"Modifier"** sur une carte de page
2. L'éditeur 3 panneaux s'ouvre
3. **Modifier les informations** :
   - Changer le nom de la page (header)
   - Changer la route (header)
4. **Gérer les blocs** :
   - Ajouter des blocs avec **"+ Ajouter"**
   - Réorganiser par drag & drop
   - Sélectionner un bloc pour l'éditer
5. **Éditer un bloc** :
   - Remplir les champs dans le panneau centre
   - Voir les changements en temps réel dans l'aperçu
6. **Sauvegarder** :
   - Cliquer sur **"💾 Sauvegarder"**
   - Les modifications sont enregistrées dans le draft

### Publier les modifications

1. Après avoir édité les pages, retourner à la liste
2. Cliquer sur **"Publier"** dans l'AppBar
3. Confirmer la publication
4. Les modifications sont maintenant visibles dans l'application

### Annuler les modifications

1. Cliquer sur **"Annuler"** dans l'AppBar
2. Confirmer l'annulation
3. Le draft est restauré depuis la version publiée

## Gestion des Blocs

### Ajouter un bloc

1. Cliquer sur **"+ Ajouter"** dans le panneau gauche
2. Une dialog s'ouvre avec la liste des types de blocs
3. Sélectionner un type
4. Le bloc est ajouté avec des valeurs par défaut
5. Éditer les propriétés dans le panneau centre

### Réorganiser les blocs

1. Dans le panneau gauche, **glisser-déposer** un bloc
2. L'ordre est mis à jour automatiquement
3. La propriété `order` de chaque bloc est recalculée
4. L'aperçu reflète le nouvel ordre

### Dupliquer un bloc

1. Cliquer sur l'icône **📋** du bloc
2. Une copie est créée avec un nouvel ID
3. La copie est ajoutée à la fin de la liste

### Supprimer un bloc

1. Cliquer sur l'icône **🗑️** du bloc
2. Le bloc est supprimé immédiatement
3. L'ordre des blocs restants est recalculé

### Activer/Désactiver un bloc

1. Utiliser le **Switch** à côté du nom du bloc
2. Les blocs désactivés ne s'affichent pas dans l'aperçu
3. Utile pour tester sans supprimer

## Intégration avec AppConfig

### Draft vs Published

Le Studio B3 utilise le système draft/published d'AppConfigService:

- **Draft** : Version de travail, modifiable dans le Studio
- **Published** : Version live, affichée dans l'application

### Synchronisation

```dart
// Le Studio écoute les changements du draft
StreamBuilder<AppConfig?>(
  stream: _configService.watchConfig(appId: _appId, draft: true),
  ...
)

// Les modifications sont sauvegardées dans le draft
await _configService.saveDraft(appId: _appId, config: updatedConfig);

// Publication du draft vers la version live
await _configService.publishDraft(appId: _appId);
```

### Persistance

Les pages B3 sont stockées dans Firestore :

```
app_configs/{appId}/configs/
  ├── config (published)
  └── config_draft (draft)
```

Chaque document contient:
```json
{
  "appId": "pizza_delizza",
  "version": 1,
  "pages": {
    "pages": [
      {
        "id": "menu_b3",
        "name": "Menu B3",
        "route": "/menu-b3",
        "enabled": true,
        "blocks": [...]
      }
    ]
  }
}
```

## Exemples d'Utilisation

### Créer une page "À Propos"

1. **Ajouter une page**
   - Nom: "À Propos"
   - Route: "/about"

2. **Ajouter une bannière**
   - Type: Bannière
   - Texte: "À propos de nous"
   - Couleur de fond: #2196F3

3. **Ajouter du texte**
   - Type: Texte
   - Texte: "Nous sommes Pizza Deli'Zza..."
   - Taille: 16
   - Alignement: center

4. **Ajouter une image**
   - Type: Image
   - URL: "https://..."
   - Hauteur: 300

5. **Sauvegarder et publier**

### Créer une landing page promotionnelle

1. **Bannière hero**
   - Texte: "🎉 -20% sur toutes les pizzas"
   - Couleur: #FF5722

2. **Image produit**
   - URL de la photo de pizza
   - Hauteur: 400px

3. **Texte descriptif**
   - "Offre valable jusqu'au..."
   - Gras, centré

4. **Bouton CTA**
   - Texte: "Commander maintenant"
   - Action: navigate:/menu
   - Couleur: #D62828

5. **Liste de produits**
   - Titre: "Nos meilleures ventes"
   - DataSource: produits populaires

## Limitations Actuelles

### Phase 3 (Actuelle)

✅ **Implémenté:**
- Éditeur complet de pages
- Gestion des blocs (CRUD)
- Drag & drop
- Aperçu live
- Publish/revert workflow

❌ **Non implémenté:**
- DataSources connectées (Phase 4)
- Types de blocs avancés (carrousel, grid personnalisé)
- Conditions d'affichage
- Animations
- Import/Export de pages

### DataSources (Phase 4)

Les blocs `productList` et `categoryList` affichent actuellement des placeholders.

**À venir:**
- Connexion à Firestore
- Filtres dynamiques
- Pagination
- Tri personnalisé

## Sécurité

### Protection des Routes

✅ Toutes les routes Studio B3 sont protégées:
```dart
if (!authState.isAdmin) {
  context.go(AppRoutes.home);
  return CircularProgressIndicator();
}
```

### Validation

- Validation des routes (doivent commencer par `/`)
- Validation des couleurs hex
- Validation des nombres (taille, padding)
- Confirmation pour suppressions

## Performance

### Optimisations

- **StreamBuilder** : Mises à jour réactives depuis Firestore
- **ReorderableListView** : Drag & drop natif performant
- **Lazy loading** : Aperçu chargé uniquement quand nécessaire
- **Debouncing** : Évite les sauvegardes trop fréquentes

### Bonnes Pratiques

- Sauvegarder régulièrement (bouton dans l'en-tête)
- Publier uniquement quand les tests sont OK
- Utiliser le draft pour expérimenter
- Dupliquer les pages pour créer des variantes

## Dépannage

### La page ne s'affiche pas dans l'app

1. Vérifier que `enabled: true`
2. Vérifier que la route est correcte
3. Publier les modifications (bouton "Publier")
4. Vérifier que la route existe dans main.dart

### L'aperçu ne se met pas à jour

1. Sauvegarder les modifications (bouton "Sauvegarder")
2. Vérifier la console pour les erreurs
3. Recharger la page du Studio

### Les modifications sont perdues

1. Toujours sauvegarder avant de changer de page
2. Le système demande confirmation si modifications non sauvegardées
3. Utiliser "Publier" pour rendre permanent

### Un bloc ne s'affiche pas

1. Vérifier que le bloc est `visible: true` (switch ON)
2. Vérifier les propriétés requises (texte, URL, etc.)
3. Vérifier les couleurs (format hex valide)

## Compatibilité

✅ **Rétrocompatible:**
- Studio B2 inchangé
- Pages V1/V2 inchangées
- AppConfig B2 compatible

✅ **Non destructif:**
- Aucune suppression de code existant
- Additif uniquement
- Draft séparé du published

## Roadmap

### Phase 4 (À venir)

- Connexion DataSources Firestore
- Filtres et tri dynamiques
- Widgets avancés (carrousel, tabs, accordion)
- Conditions d'affichage (if/else sur blocs)
- Variables et expressions
- Import/Export JSON
- Templates de pages
- Historique des versions
- Preview multi-device
- Analytics intégrées

## Support

Pour toute question ou problème:
1. Consulter cette documentation
2. Vérifier les logs dans la console
3. Tester dans un environnement de développement d'abord
4. Utiliser le système draft/published pour éviter les erreurs en production
