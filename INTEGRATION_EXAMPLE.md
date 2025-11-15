# Exemple d'intégration du HeroBlockEditor

## Objectif
Montrer comment intégrer le nouveau **HeroBlockEditor** dans l'application existante pour remplacer ou compléter le dialog actuel.

## Option 1 : Remplacement de EditHeroDialog (Recommandé)

Cette approche remplace le dialog par un écran full-screen, offrant une meilleure expérience utilisateur.

### Étape 1 : Modifier `studio_home_config_screen.dart`

#### 1.1 Ajouter l'import
```dart
// Ligne 12, après les autres imports
import 'hero_block_editor.dart';
```

#### 1.2 Remplacer la méthode _showEditHeroDialog

Remplacer les lignes 671-688 par :

```dart
// Show edit hero screen (remplace l'ancien dialog)
void _showEditHeroDialog(HeroConfig hero) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => HeroBlockEditor(
        initialHero: hero,
        onSaved: () {
          // Refresh après sauvegarde
          ref.invalidate(homeConfigProvider);
        },
      ),
    ),
  );
}
```

### Étape 2 : Supprimer l'ancien dialog (Optionnel)

Si vous ne souhaitez plus utiliser `EditHeroDialog`, vous pouvez :

1. Supprimer l'import ligne 12 :
```dart
// import 'dialogs/edit_hero_dialog.dart'; // À supprimer
```

2. Optionnellement, supprimer le fichier :
```
lib/src/screens/admin/studio/dialogs/edit_hero_dialog.dart
```

## Option 2 : Coexistence Dialog + Screen

Garder le dialog pour les modifications rapides et ajouter un bouton pour l'édition complète.

### Modifier `studio_home_config_screen.dart`

#### Ajouter l'import
```dart
import 'hero_block_editor.dart';
```

#### Modifier la section Hero (ligne 188)

```dart
Row(
  children: [
    Icon(Icons.image, color: AppColors.primaryRed),
    SizedBox(width: AppSpacing.sm),
    Expanded(
      child: Text('Bannière Hero', style: AppTextStyles.titleLarge),
    ),
    // Bouton édition rapide (dialog)
    OutlinedButton.icon(
      onPressed: () => _showEditHeroDialog(hero),
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: const Text('Édition rapide'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryRed,
      ),
    ),
    SizedBox(width: AppSpacing.sm),
    // Bouton édition complète (screen)
    ElevatedButton.icon(
      onPressed: () => _navigateToHeroEditor(hero),
      icon: const Icon(Icons.edit, size: 18),
      label: const Text('Édition complète'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
    ),
  ],
),
```

#### Ajouter la nouvelle méthode

```dart
// Navigate to full Hero editor screen
void _navigateToHeroEditor(HeroConfig hero) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => HeroBlockEditor(
        initialHero: hero,
        onSaved: () {
          ref.invalidate(homeConfigProvider);
        },
      ),
    ),
  );
}
```

## Option 3 : Intégration dans GoRouter

Si vous utilisez go_router pour la navigation.

### Étape 1 : Ajouter la route dans `main.dart`

```dart
// Ajouter l'import
import 'src/screens/admin/studio/hero_block_editor.dart';

// Dans la configuration GoRouter, dans la section admin/studio
GoRoute(
  path: 'hero-editor',
  builder: (context, state) {
    // Récupérer le hero depuis les extras si fourni
    final hero = state.extra as HeroConfig?;
    return HeroBlockEditor(initialHero: hero);
  },
),
```

### Étape 2 : Utiliser dans StudioHomeConfigScreen

```dart
import 'package:go_router/go_router.dart';

// Dans _showEditHeroDialog
void _showEditHeroDialog(HeroConfig hero) {
  context.push('/admin/studio/hero-editor', extra: hero);
}
```

## Comparaison Dialog vs Screen

### EditHeroDialog (Dialog existant)
✅ Rapide pour modifications mineures  
✅ Reste dans le contexte actuel  
❌ Espace limité sur mobile  
❌ Navigation arrière complexe  

### HeroBlockEditor (Screen complet)
✅ Espace complet pour les champs  
✅ Navigation standard (back button)  
✅ Meilleure UX sur mobile  
✅ Design Material 3 moderne  
❌ Transition plus longue  

## Recommandation

**Pour une application moderne et une meilleure UX** :
→ Utiliser **Option 1** (remplacement complet)

**Pour conserver la flexibilité** :
→ Utiliser **Option 2** (coexistence)

## Fichiers modifiés

### Option 1 (Remplacement)
- ✏️ `lib/src/screens/admin/studio/studio_home_config_screen.dart` (1 import, 1 méthode)
- ❌ `lib/src/screens/admin/studio/dialogs/edit_hero_dialog.dart` (optionnel : suppression)

### Option 2 (Coexistence)
- ✏️ `lib/src/screens/admin/studio/studio_home_config_screen.dart` (1 import, 1 section, 1 méthode)

### Option 3 (GoRouter)
- ✏️ `lib/main.dart` (1 import, 1 route)
- ✏️ `lib/src/screens/admin/studio/studio_home_config_screen.dart` (1 import, 1 méthode)

## Test rapide

Après l'intégration, tester :

1. ✅ Naviguer vers Studio → Page d'accueil → Onglet Hero
2. ✅ Cliquer sur "Modifier" (ou "Édition complète")
3. ✅ Vérifier que l'écran HeroBlockEditor s'ouvre
4. ✅ Modifier le titre et enregistrer
5. ✅ Vérifier que les changements sont persistés
6. ✅ Vérifier le retour automatique après sauvegarde

## Support

Pour toute question sur l'intégration, voir :
- `HERO_BLOCK_EDITOR_GUIDE.md` - Documentation complète
- `lib/src/screens/admin/studio/hero_block_editor.dart` - Code source commenté
