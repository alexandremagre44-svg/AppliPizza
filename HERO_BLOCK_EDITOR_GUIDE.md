# Guide d'utilisation du HeroBlockEditor

## Vue d'ensemble

Le **HeroBlockEditor** est un écran standalone Material 3 pour éditer la configuration de la bannière Hero de la page d'accueil.

## Caractéristiques

### ✅ Design Material 3 Complet
- Scaffold avec background `AppColors.surfaceContainerLow`
- AppBar avec background `AppColors.surface`, élévation 0
- Card principale avec radius 16px et ombre légère Material 3
- Utilisation exclusive du design system (AppColors, AppSpacing, AppRadius, AppTextStyles)

### ✅ Fonctionnalités
1. **Section Image** : Aperçu de l'image avec placeholder + bouton "Changer l'image"
2. **Champs de formulaire** :
   - Titre (obligatoire, validation)
   - Sous-titre
   - Texte du bouton CTA
   - Action/lien du CTA
3. **Switch de visibilité** : Activer/Désactiver le Hero
4. **Bouton Enregistrer** : Sauvegarde dans Firestore avec feedback

### ✅ Intégration Firestore
- Charge automatiquement les données via `HomeConfigService`
- Sauvegarde via `updateHeroConfig` (logique existante réutilisée)
- Upload d'images via `ImageUploadService`

## Utilisation

### Option 1 : Navigation Push (Recommandé)

Depuis n'importe quel écran, notamment `StudioHomeConfigScreen` :

```dart
// Remplacer la ligne 179 dans studio_home_config_screen.dart
ElevatedButton.icon(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HeroBlockEditor(),
      ),
    );
  },
  icon: const Icon(Icons.edit, size: 18),
  label: const Text('Modifier'),
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryRed,
    foregroundColor: Colors.white,
  ),
),
```

### Option 2 : GoRouter (Si vous utilisez go_router)

Ajouter dans `main.dart` :

```dart
import 'src/screens/admin/studio/hero_block_editor.dart';

// Dans les routes GoRouter
GoRoute(
  path: 'hero-editor',
  builder: (context, state) => const HeroBlockEditor(),
),

// Utilisation
context.go('/admin/studio/hero-editor');
```

### Option 3 : Avec Hero initial

Si vous voulez passer un Hero spécifique :

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => HeroBlockEditor(
      initialHero: hero, // Votre HeroConfig
      onSaved: () {
        // Callback après sauvegarde
        ref.invalidate(homeConfigProvider);
      },
    ),
  ),
);
```

## Structure du fichier

### Localisation
```
lib/src/screens/admin/studio/hero_block_editor.dart
```

### Dépendances
- `../../../models/home_config.dart` - Modèle HeroConfig
- `../../../services/home_config_service.dart` - Service Firestore
- `../../../services/image_upload_service.dart` - Upload d'images
- `../../../design_system/app_theme.dart` - Design system

## Design System utilisé

### Couleurs (AppColors)
- `surfaceContainerLow` - Background du Scaffold
- `surface` - Background de l'AppBar et Card principale
- `primary` - Bouton principal
- `onPrimary` - Texte sur bouton principal
- `onSurface` - Texte principal
- `onSurfaceVariant` - Texte secondaire
- `success` / `error` - Feedback SnackBar

### Espacement (AppSpacing)
- `md` (16px) - Padding horizontal et vertical principal
- `sm` (12px) - Espacement entre image et bouton
- `xs` (8px) - Petit espacement

### Radius (AppRadius)
- `radiusLarge` (16px) - Card principale et preview image
- `medium` (12px) - TextFields et autres éléments

### Typography (AppTextStyles)
- `headlineMedium` - Titre AppBar
- `labelMedium` - Labels des champs
- `bodyMedium` - Texte des champs
- `bodySmall` - Texte d'aide
- `labelLarge` - Texte du bouton

## Validation

- **Titre** : Champ obligatoire, affiche une erreur si vide
- **Image** : Valide formats (JPG, PNG, WEBP) et taille (max 10MB)

## États de chargement

1. **Initial loading** : CircularProgressIndicator pendant le chargement des données
2. **Upload en cours** : Barre de progression avec pourcentage
3. **Sauvegarde** : Bouton désactivé avec spinner

## Exemple complet d'intégration

### Dans `studio_home_config_screen.dart`

```dart
// Ajouter l'import en haut du fichier
import 'hero_block_editor.dart';

// Remplacer la méthode _showEditHeroDialog (ligne 671-688)
void _showEditHeroDialog(HeroConfig hero) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => HeroBlockEditor(
        initialHero: hero,
        onSaved: () {
          // Refresh après sauvegarde
          ref.invalidate(homeConfigProvider);
          _showSnackBar('Hero mis à jour avec succès');
        },
      ),
    ),
  );
}
```

## Conformité

✅ **Material 3** : Design 100% conforme  
✅ **Design Deli'Zza** : Utilise la palette officielle  
✅ **Design System** : Aucun hardcoded color/style  
✅ **Logique métier** : Réutilise les services existants  
✅ **Clean Code** : Bien organisé et documenté  
✅ **CRUD Hero** : Gestion complète (Load + Update)  

## Tests recommandés

1. ✅ Charger un Hero existant
2. ✅ Modifier le titre et sauvegarder
3. ✅ Uploader une nouvelle image
4. ✅ Changer la visibilité
5. ✅ Valider qu'un titre vide affiche une erreur
6. ✅ Vérifier que les changements sont persistés dans Firestore

## Notes techniques

- **Widget Type** : StatefulWidget
- **Form Management** : GlobalKey<FormState>
- **Image Upload** : Avec progression (0-100%)
- **Navigation** : Push standard (pas de dialog)
- **Feedback** : SnackBar pour succès/erreur
- **Retour** : Pop automatique après sauvegarde réussie
