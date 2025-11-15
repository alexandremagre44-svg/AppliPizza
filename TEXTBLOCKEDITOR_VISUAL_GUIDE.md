# TextBlockEditor - Guide Visuel

## Structure de l'Écran

```
┌─────────────────────────────────────────────────────────┐
│ ← Textes & Messages                                     │ AppBar
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │ (surface #FFFFFF)
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 🏠 Accueil                                        │  │ Card 1
│  │                                                   │  │ (radius 16px)
│  │  Nom de l'application                            │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │ Pizza Deli'Zza                              │ │  │ TextField
│  │  └─────────────────────────────────────────────┘ │  │
│  │                                                   │  │
│  │  Slogan / Sous-titre                             │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │ La meilleure pizza à emporter               │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  │                                                   │  │
│  │  Message d'introduction                          │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │ Découvrez nos pizzas artisanales            │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 🛒 Commandes                                      │  │ Card 2
│  │                                                   │  │
│  │  Message de commande validée                     │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │ Votre commande a été validée avec succès !  │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  │                                                   │  │
│  │  Message de commande annulée                     │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │ Une erreur est survenue lors de...          │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  │                                                   │  │
│  │  Message aucun créneau disponible                │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │ Aucun créneau disponible pour le moment.    │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 💳 Paiements                                      │  │ Card 3
│  │                                                   │  │
│  │  Erreur de connexion                             │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │ Erreur de connexion. Vérifiez votre réseau. │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  │                                                   │  │
│  │  Erreur de paiement / serveur                    │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │ Erreur serveur. Réessayez plus tard.        │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │ ℹ️ Général                                        │  │ Card 4
│  │                                                   │  │
│  │  Message de bienvenue / Session                  │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │ Votre session a expiré. Reconnectez-vous.   │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │     Sauvegarder tous les textes                  │  │ FilledButton
│  └──────────────────────────────────────────────────┘  │ (Rouge #D32F2F)
│                                                         │
└─────────────────────────────────────────────────────────┘
Background: surfaceContainerLow (#F5F5F5)
```

## Palette de Couleurs Utilisée

### Couleurs Material 3
```
AppColors.primary             #D32F2F  (Rouge Pizza Deli'Zza)
AppColors.onPrimary           #FFFFFF  (Blanc sur primaire)
AppColors.surface             #FFFFFF  (Surface blanche)
AppColors.surfaceContainerLow #F5F5F5  (Background)
AppColors.textPrimary         #323232  (Texte principal)
AppColors.outline             #BEBEBE  (Bordures)
AppColors.error               #C62828  (Erreurs)
```

## Espacement

### Padding & Marges
```
AppSpacing.md   = 16px  (Padding horizontal du scroll, padding des cards)
AppSpacing.sm   = 12px  (Padding vertical des inputs)
AppSpacing.lg   = 24px  (Non utilisé directement)
```

### Spacing Vertical
```
AppSpacing.verticalSpaceMD  = 16px  (Entre les champs et entre les cards)
AppSpacing.verticalSpaceXL  = 32px  (Après le bouton sauvegarder)
```

## Radius

### BorderRadius
```
AppRadius.large  = 16px  (Cards)
AppRadius.input  = 12px  (TextFields)
AppRadius.button = 12px  (Bouton sauvegarder)
```

## Typographie

### Titres de Sections
```dart
AppTextStyles.titleLarge
fontSize: 20px
fontWeight: w600 (SemiBold)
color: AppColors.primary
```

### Labels des Champs
```dart
AppTextStyles.labelMedium
fontSize: 13px
fontWeight: w500 (Medium)
color: AppColors.textSecondary
```

### Texte dans les Inputs
```dart
AppTextStyles.bodyMedium
fontSize: 14px
fontWeight: w400 (Regular)
color: AppColors.textPrimary
```

### Texte du Bouton
```dart
AppTextStyles.labelLarge
fontSize: 14px
fontWeight: w500 (Medium)
color: AppColors.onPrimary
```

## États de l'Interface

### État de Chargement
```
┌─────────────────────────────────────┐
│ ← Textes & Messages                 │
├─────────────────────────────────────┤
│                                     │
│              ⟳                      │  CircularProgressIndicator
│           Chargement...             │  (AppColors.primary)
│                                     │
└─────────────────────────────────────┘
```

### État de Sauvegarde
```
┌────────────────────────────────────┐
│  ⟳  Sauvegarder tous les textes    │  Bouton avec spinner
└────────────────────────────────────┘  (texte remplacé par spinner)
```

### Messages de Feedback (SnackBar)

#### Succès
```
┌────────────────────────────────────┐
│ ✓ Tous les textes ont été...      │  backgroundColor: AppColors.primary
└────────────────────────────────────┘  borderRadius: 12px
                                         floating
```

#### Erreur
```
┌────────────────────────────────────┐
│ ✗ Erreur lors de l'enregistrement  │  backgroundColor: AppColors.error
└────────────────────────────────────┘  borderRadius: 12px
                                         floating
```

## Focus & Interaction

### TextField Normal
```
┌─────────────────────────────────────┐
│ Pizza Deli'Zza                      │  border: 1px solid #BEBEBE
└─────────────────────────────────────┘
```

### TextField en Focus
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ Pizza Deli'Zza                      ┃  border: 2px solid #D32F2F
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  (plus épais et rouge)
```

### TextField avec Erreur
```
┌─────────────────────────────────────┐
│                                     │  border: 1px solid #C62828
└─────────────────────────────────────┘
Ce champ ne peut pas être vide         ← Message d'erreur rouge
```

## Responsive Behavior

### Mobile (< 600px)
- Padding horizontal: 16px
- Cards pleine largeur
- Bouton pleine largeur

### Tablet/Desktop (> 600px)
- Même layout (pas de breakpoints spécifiques)
- Scroll vertical fluide
- Cards s'étendent avec la largeur disponible

## Accessibilité

### Labels
- Tous les champs ont des labels clairs
- Textes d'aide (hint) fournis

### Couleurs
- Contraste suffisant pour le texte
- Bordures visibles en mode normal
- Bordures renforcées en mode focus

### Navigation
- Tab order naturel (top to bottom)
- Bouton retour dans l'AppBar
- Focus visible sur les champs

## Flux Utilisateur

```
1. Ouverture du screen
   ↓
2. Chargement automatique (CircularProgressIndicator)
   ↓
3. Affichage des données existantes
   ↓
4. Utilisateur modifie un ou plusieurs champs
   ↓
5. Utilisateur clique "Sauvegarder"
   ↓
6. Validation (tous les champs non vides)
   ├─ ✓ Valide → Sauvegarde → SnackBar succès → Rechargement
   └─ ✗ Invalide → Messages d'erreur sur les champs
```

## Intégration dans le Studio Builder

### Menu de Navigation
```
Studio Builder
├─ Configuration Accueil
├─ Hero Banner
├─ Produits Vedettes
├─ Popups & Roulette
└─ 📝 Textes & Messages  ← Notre écran
```

### Code d'Intégration
```dart
ListTile(
  leading: Icon(Icons.text_fields, color: AppColors.primary),
  title: Text('Textes & Messages'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudioTextsScreen(),
      ),
    );
  },
)
```

## Avantages du Design

### ✅ Clarté
- Organisation en catégories logiques
- Icônes pour identification rapide
- Labels explicites

### ✅ Cohérence
- 100% Design System
- Aucun style hardcodé
- Respecte Material 3

### ✅ Efficacité
- Modification batch (un seul bouton)
- Validation en temps réel
- Feedback immédiat

### ✅ Maintenabilité
- Code propre et documenté
- Séparation des responsabilités
- Facile à étendre

## Exemples de Contenu

### Textes par Défaut

**Accueil:**
- Nom: "Pizza Deli'Zza"
- Slogan: "La meilleure pizza à emporter"
- Intro: "Découvrez nos pizzas artisanales"

**Commandes:**
- Succès: "Votre commande a été validée avec succès !"
- Échec: "Une erreur est survenue lors de la commande."
- Pas de créneaux: "Aucun créneau disponible pour le moment."

**Paiements:**
- Erreur réseau: "Erreur de connexion. Vérifiez votre réseau."
- Erreur serveur: "Erreur serveur. Réessayez plus tard."

**Général:**
- Session: "Votre session a expiré. Reconnectez-vous."
