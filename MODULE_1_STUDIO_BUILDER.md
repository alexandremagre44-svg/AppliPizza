# Module 1: Studio Builder - Documentation

## Vue d'ensemble

Le Module 1 implémente un "Studio Builder" permettant de rendre la page d'accueil entièrement configurable depuis le panneau d'administration. Cette fonctionnalité permet aux administrateurs de personnaliser le contenu, les bannières et les blocs dynamiques sans modifier le code.

## Architecture

### Modèles de données

#### 1. `DynamicBlock` (`lib/src/models/dynamic_block_model.dart`)

Modèle représentant un bloc dynamique configurable.

**Champs:**
- `String id` - Identifiant unique (généré automatiquement)
- `String type` - Type de bloc ("featuredProducts", "categories", "bestSellers")
- `String title` - Titre du bloc
- `int maxItems` - Nombre maximum d'éléments à afficher (défaut: 6)
- `int order` - Ordre d'affichage (utilisé pour le tri)
- `bool isVisible` - Visibilité du bloc

**Méthodes:**
- `fromJson(Map<String, dynamic>)` - Création depuis JSON
- `toJson()` - Conversion en JSON
- `copyWith()` - Création d'une copie avec modifications

#### 2. `HomeConfig` (mis à jour dans `lib/src/models/home_config.dart`)

Configuration complète de la page d'accueil.

**Sections:**

##### Hero Banner (`HeroConfig`)
- `bool isActive` - Activation de la bannière
- `String imageUrl` - URL de l'image
- `String title` - Titre principal
- `String subtitle` - Sous-titre
- `String ctaText` - Texte du bouton d'action
- `String ctaAction` - Route GoRouter pour l'action

##### Bandeau Promo (`PromoBannerConfig`)
- `bool isActive` - Activation du bandeau
- `String text` - Texte du message
- `String? backgroundColor` - Couleur de fond (hex)
- `String? textColor` - Couleur du texte (hex)
- `DateTime? startDate` - Date de début
- `DateTime? endDate` - Date de fin

##### Blocs Dynamiques (`ContentBlock`)
- Liste de blocs configurables
- Compatible avec `DynamicBlock`

**Utilitaires:**
- `ColorConverter` - Conversion entre Color Flutter et String hex
  - `hexToColor(String?)` - Convertit hex en Color
  - `colorToHex(int)` - Convertit Color en hex avec alpha
  - `colorToHexWithoutAlpha(int)` - Convertit Color en hex sans alpha

### Services

#### 1. `ImageUploadService` (`lib/src/services/image_upload_service.dart`)

Service de gestion des uploads d'images vers Firebase Storage.

**Méthodes principales:**
- `pickImageFromGallery()` - Sélection d'image depuis la galerie
- `pickImageFromCamera()` - Capture d'image avec la caméra
- `uploadImage(File, String)` - Upload d'image vers Firebase Storage
- `uploadImageWithProgress(File, String, onProgress)` - Upload avec callback de progression
- `deleteImage(String)` - Suppression d'une image
- `isValidImage(File)` - Validation de l'image (format, taille max 10MB)

**Formats supportés:** JPG, JPEG, PNG, WEBP, GIF

#### 2. `HomeConfigService` (existant, dans `lib/src/services/home_config_service.dart`)

Service de gestion de la configuration de la page d'accueil dans Firestore.

**Méthodes:**
- `getHomeConfig()` - Récupération de la config
- `saveHomeConfig(HomeConfig)` - Sauvegarde complète
- `updateHeroConfig(HeroConfig)` - Mise à jour du Hero
- `updatePromoBanner(PromoBannerConfig)` - Mise à jour du bandeau
- `addContentBlock(ContentBlock)` - Ajout d'un bloc
- `updateContentBlock(ContentBlock)` - Mise à jour d'un bloc
- `deleteContentBlock(String)` - Suppression d'un bloc
- `reorderBlocks(List<ContentBlock>)` - Réorganisation des blocs
- `watchHomeConfig()` - Stream en temps réel

**Firestore:**
- Collection: `app_home_config`
- Document: `main`

### Providers

#### `homeConfigProvider` (`lib/src/providers/home_config_provider.dart`)

Provider Riverpod pour la configuration de la page d'accueil.

**Types:**
- `StreamProvider<HomeConfig?>` - Stream en temps réel de la config
- `FutureProvider<HomeConfig?>` - Chargement unique avec initialisation automatique

## Interface d'administration

### Écran principal: `StudioHomeConfigScreen`

**Route:** `/admin/studio/home-config`

**Structure:**
- Interface à onglets (TabBar)
  - Hero - Configuration de la bannière principale
  - Bandeau - Configuration du bandeau promotionnel
  - Blocs - Gestion des blocs dynamiques

### Dialogs d'édition

#### 1. `EditHeroDialog` (`lib/src/screens/admin/studio/dialogs/edit_hero_dialog.dart`)

Modal pour éditer la bannière Hero.

**Fonctionnalités:**
- Édition de tous les champs du Hero
- Upload d'image avec preview
- Barre de progression lors de l'upload
- Validation des champs requis

#### 2. `EditPromoBannerDialog` (`lib/src/screens/admin/studio/dialogs/edit_promo_banner_dialog.dart`)

Modal pour éditer le bandeau promotionnel.

**Fonctionnalités:**
- Édition du texte
- Sélecteur de couleur de fond
- Sélecteur de couleur de texte
- Aperçu en temps réel
- Affichage des valeurs hex

#### 3. `EditBlockDialog` (`lib/src/screens/admin/studio/dialogs/edit_block_dialog.dart`)

Modal pour créer/éditer un bloc dynamique.

**Fonctionnalités:**
- Sélection du type de bloc (radio buttons)
- Édition du titre
- Configuration du nombre max d'items
- Définition de l'ordre d'affichage
- Toggle de visibilité
- Validation des entrées

### Types de blocs disponibles

1. **featuredProducts** - Produits en vedette
   - Affiche les produits marqués comme `isFeatured`
   - Grille responsive (2 colonnes)

2. **bestSellers** - Meilleures ventes
   - Affiche les best-sellers ou les pizzas par défaut
   - Grille responsive (2 colonnes)

3. **categories** - Catégories
   - Affiche les raccourcis vers les catégories
   - Widget `CategoryShortcuts`

4. **promotions** - Promotions
   - Affiche les produits en promotion
   - Carousel horizontal

## Page d'accueil client

### `HomeScreen` (mis à jour)

**Rendu dynamique:**

1. **Hero Banner** - Affiché si `isActive` est vrai
   - Utilise les données de `HeroConfig`
   - Navigation vers la route spécifiée

2. **Bandeau Promo** - Affiché si actif et dans la période valide
   - Couleurs personnalisées (background et texte)
   - Méthode `isCurrentlyActive` vérifie les dates

3. **Blocs dynamiques** - Rendus selon la configuration
   - Triés par `order`
   - Filtrés par `isVisible`
   - Rendu spécifique selon le `type`

4. **Catégories** - Toujours affichées
   - Raccourcis vers les sections du menu

5. **Info Banner** - Horaires d'ouverture

**Fallback:** Si aucun bloc n'est configuré, affiche les sections par défaut (promos + best-sellers).

## Dépendances ajoutées

```yaml
firebase_storage: ^12.3.2
image_picker: ^1.0.7
flutter_colorpicker: ^1.0.3
```

## Utilisation

### Configuration initiale

1. Accéder au dashboard admin
2. Cliquer sur "Studio" → "Page d'accueil"
3. La configuration par défaut est créée automatiquement si elle n'existe pas

### Éditer le Hero

1. Onglet "Hero"
2. Activer/désactiver avec le switch
3. Cliquer sur "Modifier"
4. Remplir les champs
5. Upload d'image (bouton "Choisir")
6. Enregistrer

### Éditer le bandeau promo

1. Onglet "Bandeau"
2. Activer/désactiver avec le switch
3. Cliquer sur "Modifier"
4. Éditer le texte
5. Choisir les couleurs avec les color pickers
6. Prévisualiser en temps réel
7. Enregistrer

### Gérer les blocs

1. Onglet "Blocs"
2. Cliquer sur "+" pour ajouter un bloc
3. Sélectionner le type
4. Définir le titre et les paramètres
5. Définir l'ordre (position)
6. Activer/désactiver le bloc
7. Enregistrer

### Réorganiser les blocs

- Modifier l'ordre de chaque bloc
- Les blocs sont automatiquement triés par ordre croissant
- Ordre 0 = en premier, ordre 1 = en deuxième, etc.

### Supprimer un bloc

1. Développer le bloc dans la liste
2. Cliquer sur "Supprimer"
3. Confirmer la suppression

## Sécurité Firebase

### Storage Rules

```
service firebase.storage {
  match /b/{bucket}/o {
    match /home/{imageId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### Firestore Rules

```
service cloud.firestore {
  match /databases/{database}/documents {
    match /app_home_config/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Tests

Pour tester le Module 1:

1. **Test de l'interface admin:**
   - Créer/modifier des blocs
   - Uploader des images
   - Changer les couleurs
   - Vérifier la persistance des données

2. **Test de la page d'accueil:**
   - Vérifier l'affichage du Hero
   - Vérifier le bandeau promo avec dates
   - Vérifier le rendu des blocs dynamiques
   - Vérifier l'ordre des blocs
   - Tester la visibilité des blocs

3. **Test de la conversion de couleurs:**
   - Vérifier que les couleurs hex sont correctement converties
   - Vérifier l'affichage avec différentes couleurs

## Améliorations futures

1. **Drag & Drop pour réorganiser les blocs**
2. **Prévisualisation en temps réel de la page d'accueil**
3. **Templates prédéfinis de configurations**
4. **Historique des modifications**
5. **A/B testing des configurations**
6. **Analytics sur les clics des blocs**
7. **Planification des changements**
8. **Multi-langues pour les textes**

## Structure des fichiers

```
lib/src/
├── models/
│   ├── dynamic_block_model.dart (nouveau)
│   └── home_config.dart (mis à jour)
├── services/
│   ├── image_upload_service.dart (nouveau)
│   └── home_config_service.dart (existant)
├── providers/
│   └── home_config_provider.dart (existant)
├── screens/
│   ├── admin/studio/
│   │   ├── studio_home_config_screen.dart (mis à jour)
│   │   └── dialogs/
│   │       ├── edit_hero_dialog.dart (nouveau)
│   │       ├── edit_promo_banner_dialog.dart (nouveau)
│   │       └── edit_block_dialog.dart (nouveau)
│   └── home/
│       └── home_screen.dart (mis à jour)
└── widgets/home/
    └── info_banner.dart (mis à jour)
```

## Support et maintenance

Pour toute question ou problème:
1. Vérifier les logs Firebase
2. Vérifier les règles Firestore et Storage
3. Vérifier que les images sont bien uploadées
4. Vérifier la structure des données dans Firestore

## Conclusion

Le Module 1 fournit une solution complète et professionnelle pour gérer la page d'accueil de manière dynamique, sans nécessiter de modifications du code pour chaque changement de contenu. L'interface est intuitive et permet une grande flexibilité dans l'agencement du contenu.
