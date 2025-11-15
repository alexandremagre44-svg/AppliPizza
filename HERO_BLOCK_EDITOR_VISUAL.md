# HeroBlockEditor - Guide Visuel

## Vue d'ensemble de l'écran

```
┌─────────────────────────────────────────────┐
│  ← Hero                                      │  AppBar (surface, elevation 0)
├─────────────────────────────────────────────┤
│                                              │
│  ┌─────────────────────────────────────┐   │
│  │                                      │   │  Main Card (surface, radius 16)
│  │  Image principale                    │   │
│  │  ┌──────────────────────────────┐  │   │
│  │  │                               │  │   │
│  │  │     [Image Preview ou        │  │   │  Image Section
│  │  │      Placeholder Icon]        │  │   │
│  │  │                               │  │   │
│  │  └──────────────────────────────┘  │   │
│  │                                      │   │
│  │  [Choisir une image]                │   │  FilledButton.tonal
│  │                                      │   │
│  │  Titre *                             │   │
│  │  ┌──────────────────────────────┐  │   │
│  │  │ Bienvenue chez Pizza...      │  │   │  TextField (required)
│  │  └──────────────────────────────┘  │   │
│  │                                      │   │
│  │  Sous-titre                          │   │
│  │  ┌──────────────────────────────┐  │   │
│  │  │ Découvrez nos pizzas...      │  │   │  TextField
│  │  └──────────────────────────────┘  │   │
│  │                                      │   │
│  │  Texte du bouton CTA                │   │
│  │  ┌──────────────────────────────┐  │   │
│  │  │ Voir le menu                  │  │   │  TextField
│  │  └──────────────────────────────┘  │   │
│  │                                      │   │
│  │  Action / lien du CTA               │   │
│  │  ┌──────────────────────────────┐  │   │
│  │  │ /menu                         │  │   │  TextField
│  │  └──────────────────────────────┘  │   │
│  │  Ex: /menu, /admin/pizza            │   │
│  │                                      │   │
│  │  ┌──────────────────────────────┐  │   │
│  │  │ 🔄 Visibilité                │  │   │  Switch Card
│  │  │ Hero actif              ◉─── │  │   │
│  │  └──────────────────────────────┘  │   │
│  │                                      │   │
│  └─────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐  │
│  │       Enregistrer                     │  │  FilledButton (primary)
│  └──────────────────────────────────────┘  │
│                                              │
└─────────────────────────────────────────────┘
 Background: surfaceContainerLow (#F5F5F5)
```

## États de l'écran

### 1. État initial (chargement)

```
┌─────────────────────────────────────────────┐
│  ← Hero                                      │
├─────────────────────────────────────────────┤
│                                              │
│                                              │
│                                              │
│              ⏳ Chargement...                │
│                                              │
│                                              │
│                                              │
└─────────────────────────────────────────────┘
```

### 2. Pas d'image sélectionnée

```
┌─────────────────────────────────────────┐
│  Image principale                        │
│  ┌──────────────────────────────────┐  │
│  │                                   │  │
│  │         📷 [Icon 48px]           │  │  surfaceContainer (#EEEEEE)
│  │     Aucune image sélectionnée    │  │  onSurfaceVariant text
│  │                                   │  │
│  └──────────────────────────────────┘  │
│                                          │
│  [📤 Choisir une image]                 │  FilledButton.tonal
└─────────────────────────────────────────┘
```

### 3. Image sélectionnée avec bouton de suppression

```
┌─────────────────────────────────────────┐
│  Image principale                        │
│  ┌──────────────────────────────────┐  │
│  │  ╔══════════════════════════╗ ✕ │  │  [✕] = IconButton (overlay bg)
│  │  ║                          ║   │  │
│  │  ║   [Image Network]        ║   │  │  200px height
│  │  ║                          ║   │  │
│  │  ╚══════════════════════════╝   │  │
│  └──────────────────────────────────┘  │
│                                          │
│  [🔄 Changer l'image]                   │  FilledButton.tonal
└─────────────────────────────────────────┘
```

### 4. Upload en cours

```
┌─────────────────────────────────────────┐
│  [⏳ 47% Upload en cours... 47%]        │  Disabled button
│                                          │  with CircularProgressIndicator
└─────────────────────────────────────────┘
```

### 5. Sauvegarde en cours

```
┌─────────────────────────────────────────┐
│  [⏳ Loading spinner]                    │  Disabled FilledButton
│                                          │  with CircularProgressIndicator
└─────────────────────────────────────────┘
```

### 6. Validation d'erreur

```
┌─────────────────────────────────────────┐
│  Titre *                                 │
│  ┌──────────────────────────────────┐  │
│  │ [Champ vide]                     │  │  Error border (red)
│  └──────────────────────────────────┘  │
│  ⚠️ Ce champ est requis                 │  Error text (AppColors.error)
└─────────────────────────────────────────┘
```

## Palette de couleurs utilisée

### Scaffold & AppBar
- **Background Scaffold**: `AppColors.surfaceContainerLow` (#F5F5F5)
- **Background AppBar**: `AppColors.surface` (#FFFFFF)
- **AppBar Title**: `AppColors.onSurface` (#323232)
- **AppBar Elevation**: 0

### Card principale
- **Background**: `AppColors.surface` (#FFFFFF)
- **Border Radius**: `AppRadius.radiusLarge` (16px)
- **Shadow**: `AppColors.black` with 0.08 opacity

### Champs de texte
- **Border**: `AppRadius.medium` (12px)
- **Label**: `AppTextStyles.labelMedium` (#323232)
- **Input Text**: `AppTextStyles.bodyMedium` (#323232)
- **Helper Text**: `AppColors.onSurfaceVariant` (#5A5A5A)
- **Error**: `AppColors.error` (#C62828)

### Boutons
- **Primary (Enregistrer)**: 
  - Background: `AppColors.primary` (#D32F2F)
  - Foreground: `AppColors.onPrimary` (#FFFFFF)
- **Tonal (Upload)**: Theme's tonal style
- **Border Radius**: `AppRadius.medium` (12px)

### Switch
- **Active**: Theme's primary color (#D32F2F)
- **Background Card**: `AppColors.surfaceContainerLow` (#F5F5F5)

## Spacing utilisé

### Layout général
- **Padding horizontal**: `AppSpacing.md` (16px)
- **Padding vertical**: `AppSpacing.md` (16px)

### Dans la Card
- **Padding**: `AppSpacing.md` (16px)
- **Espacement entre sections**: `AppSpacing.md` (16px)

### Section Image
- **Entre image et bouton**: `AppSpacing.sm` (12px)
- **Entre label et preview**: `AppSpacing.sm` (12px)

### Champs de texte
- **Entre label et input**: `AppSpacing.xs` (8px)

## Typographie utilisée

| Élément | Style | Taille | Poids |
|---------|-------|--------|-------|
| AppBar Title | headlineMedium | 20px | SemiBold (600) |
| Labels | labelMedium | 13px | Medium (500) |
| Input Text | bodyMedium | 14px | Regular (400) |
| Helper Text | bodySmall | 12px | Regular (400) |
| Button Text | labelLarge | 14px | Medium (500) |
| Switch Title | bodyMedium | 14px | Regular (400) |
| Switch Subtitle | bodySmall | 12px | Regular (400) |

## Interactions utilisateur

### 1. Charger une image
```
Tap [Choisir une image]
  ↓
Image Picker (Gallery)
  ↓
Validation (format + taille)
  ↓
Upload vers Firebase Storage avec progression
  ↓
Affichage de l'aperçu + bouton suppression
```

### 2. Supprimer une image
```
Tap [✕] sur l'image
  ↓
setState(() => _imageUrl = '')
  ↓
Retour au placeholder
```

### 3. Modifier un champ
```
Tap sur TextField
  ↓
Clavier s'affiche
  ↓
Édition du texte
  ↓
Validation en temps réel (si required)
```

### 4. Changer la visibilité
```
Tap sur Switch
  ↓
setState(() => _isActive = !_isActive)
  ↓
Texte subtitle mis à jour
```

### 5. Enregistrer
```
Tap [Enregistrer]
  ↓
Validation du formulaire
  ↓
Si erreur: Afficher message d'erreur
Si OK: 
  ↓
  setState(() => _isSaving = true)
  ↓
  updateHeroConfig() via HomeConfigService
  ↓
  SnackBar de succès/erreur
  ↓
  Navigator.pop() (retour automatique)
  ↓
  onSaved() callback (refresh provider)
```

## Messages utilisateur

### SnackBar Success
```
┌─────────────────────────────────────────┐
│ ✓ Hero enregistré avec succès          │  Green background
└─────────────────────────────────────────┘
```

### SnackBar Error
```
┌─────────────────────────────────────────┐
│ ✗ Erreur lors de l'enregistrement       │  Red background
└─────────────────────────────────────────┘
```

### Upload Success
```
┌─────────────────────────────────────────┐
│ ✓ Image téléchargée avec succès        │  Green background
└─────────────────────────────────────────┘
```

### Image Invalid
```
┌─────────────────────────────────────────┐
│ ✗ Image invalide. Formats acceptés:    │  Red background
│   JPG, PNG, WEBP (max 10MB)            │
└─────────────────────────────────────────┘
```

## Conformité Material 3

✅ **Scaffold**: Background surfaceContainerLow  
✅ **AppBar**: Surface background, elevation 0  
✅ **Cards**: Proper radius (16px) and shadows  
✅ **Buttons**: FilledButton (primary) et FilledButton.tonal  
✅ **TextFields**: OutlineInputBorder avec radius 12px  
✅ **Switch**: Theme's colorScheme  
✅ **Typography**: Material 3 scale (label, body, headline)  
✅ **Spacing**: Échelle de 4px (8, 12, 16, 24)  
✅ **Colors**: ColorScheme complet (primary, surface, onSurface, etc.)  

## Responsive

L'écran est conçu pour être responsive :

- **Mobile Portrait** : Padding 16px, single column
- **Mobile Landscape** : Même layout, scrollable
- **Tablet** : Padding 16px, content centered
- **Desktop** : Padding 16px, max-width possible sur la Card

Le `SingleChildScrollView` garantit que tout le contenu est accessible même sur petits écrans.
