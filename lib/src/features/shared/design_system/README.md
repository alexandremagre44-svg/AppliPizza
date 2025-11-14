# Design System Pizza Deli'Zza

Système de design complet et professionnel pour l'application Admin Pizza Deli'Zza.

## 📋 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Installation](#installation)
- [Composants](#composants)
- [Utilisation](#utilisation)
- [Architecture](#architecture)

## 🎯 Vue d'ensemble

Ce design system fournit une collection complète de composants UI réutilisables, cohérents et modernes pour l'application Pizza Deli'Zza.

### Caractéristiques

- ✅ **Cohérent**: Tous les composants partagent le même langage visuel
- ✅ **Accessible**: Design WCAG compliant avec bon contraste
- ✅ **Responsive**: S'adapte automatiquement aux différentes tailles d'écran
- ✅ **Moderne**: Inspiré de Stripe, Linear et Shopify
- ✅ **Scalable**: Facile à étendre et maintenir
- ✅ **Rétrocompatible**: Les anciens imports continuent de fonctionner

## 🚀 Installation

### Import complet

```dart
import 'package:pizza_delizza/src/design_system/app_theme.dart';
```

Cet import donne accès à tous les composants :
- `AppColors` - Palette de couleurs
- `AppTextStyles` - Styles typographiques
- `AppSpacing` - Espacements
- `AppRadius` - Coins arrondis
- `AppShadows` - Ombres
- `AppButton` - Boutons
- `AppTextField` - Champs de formulaire
- `AppCard` - Cartes
- `AppBadge` - Badges
- `AppTable` - Tableaux
- `AppDialog` - Modales
- `SectionHeader` - En-têtes de section
- Et plus...

### Appliquer le thème

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  // ...
)
```

## 🎨 Composants

### 1. Couleurs (`colors.dart`)

#### Couleurs primaires
```dart
AppColors.primary          // Rouge principal #B00020
AppColors.primaryLight     // Rouge clair #E53935
AppColors.primaryDark      // Rouge foncé #8E0000
```

#### Couleurs neutres (échelle 50-900)
```dart
AppColors.neutral50        // Gris très clair
AppColors.neutral100       // Background secondaire
AppColors.neutral200       // Bordures subtiles
AppColors.neutral300       // Bordures normales
AppColors.neutral900       // Texte principal
```

#### Couleurs d'état
```dart
AppColors.success          // Vert succès
AppColors.warning          // Orange avertissement
AppColors.danger           // Rouge erreur
AppColors.info             // Bleu information
```

### 2. Typographie (`text_styles.dart`)

#### Hiérarchie complète
```dart
// Display (32-40px) - Très grands titres
AppTextStyles.displayLarge
AppTextStyles.displayMedium

// Headlines (20-28px) - Titres de section
AppTextStyles.h1
AppTextStyles.h2
AppTextStyles.h3

// Titles (14-18px) - Titres de carte
AppTextStyles.titleLarge
AppTextStyles.titleMedium
AppTextStyles.titleSmall

// Body (12-16px) - Corps de texte
AppTextStyles.bodyLarge
AppTextStyles.bodyMedium
AppTextStyles.bodySmall

// Labels (11-14px) - Labels et badges
AppTextStyles.labelLarge
AppTextStyles.labelMedium
AppTextStyles.labelSmall

// Prices - Styles pour prix
AppTextStyles.price
AppTextStyles.priceLarge
```

### 3. Boutons (`buttons.dart`)

#### Variantes
```dart
// Bouton principal (rouge)
AppButton.primary(
  text: 'Enregistrer',
  onPressed: () {},
)

// Bouton secondaire (gris)
AppButton.secondary(
  text: 'Annuler',
  onPressed: () {},
)

// Bouton outline (bordure rouge)
AppButton.outline(
  text: 'Modifier',
  onPressed: () {},
)

// Bouton ghost (transparent)
AppButton.ghost(
  text: 'Voir plus',
  onPressed: () {},
)

// Bouton danger (rouge danger)
AppButton.danger(
  text: 'Supprimer',
  onPressed: () {},
)

// Bouton avec icône
AppButton.primary(
  text: 'Ajouter',
  icon: Icons.add,
  onPressed: () {},
)

// Bouton loading
AppButton.primary(
  text: 'Enregistrement...',
  isLoading: true,
  onPressed: () {},
)

// Bouton pleine largeur
AppButton.primary(
  text: 'Continuer',
  fullWidth: true,
  onPressed: () {},
)
```

#### Boutons icône
```dart
AppIconButton.primary(
  icon: Icons.edit,
  onPressed: () {},
  tooltip: 'Modifier',
)
```

### 4. Champs de formulaire (`inputs.dart`)

#### Input standard
```dart
AppTextField(
  label: 'Nom',
  hint: 'Entrez votre nom',
  controller: nameController,
  validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
)
```

#### Input avec icône
```dart
AppTextFieldWithIcon(
  label: 'Email',
  icon: Icons.email,
  controller: emailController,
)
```

#### Zone de texte
```dart
AppTextArea(
  label: 'Description',
  maxLines: 5,
  controller: descriptionController,
)
```

#### Dropdown
```dart
AppDropdown<String>(
  label: 'Catégorie',
  value: selectedCategory,
  items: [
    DropdownMenuItem(value: 'pizza', child: Text('Pizza')),
    DropdownMenuItem(value: 'boisson', child: Text('Boisson')),
  ],
  onChanged: (value) => setState(() => selectedCategory = value),
)
```

#### Date/Time Picker
```dart
AppDateTimePicker(
  label: 'Date de livraison',
  selectedDate: selectedDate,
  onDateSelected: (date) => setState(() => selectedDate = date),
  mode: DateTimePickerMode.dateTime,
)
```

#### Checkbox & Radio
```dart
AppCheckbox(
  label: 'J\'accepte les conditions',
  value: accepted,
  onChanged: (value) => setState(() => accepted = value ?? false),
)

AppRadio<String>(
  label: 'Option 1',
  value: 'opt1',
  groupValue: selectedOption,
  onChanged: (value) => setState(() => selectedOption = value),
)
```

### 5. Cartes (`cards.dart`)

#### Carte standard
```dart
AppCard(
  child: Text('Contenu de la carte'),
)
```

#### Carte avec section
```dart
AppSectionCard(
  title: 'Informations',
  subtitle: 'Détails du produit',
  child: Column(
    children: [
      // Contenu
    ],
  ),
)
```

#### Carte interactive
```dart
AppInteractiveCard(
  selected: isSelected,
  onTap: () => setState(() => isSelected = !isSelected),
  child: Text('Carte sélectionnable'),
)
```

#### Carte statistique
```dart
AppStatCard(
  title: 'Commandes',
  value: '42',
  icon: Icons.shopping_bag,
  iconColor: AppColors.primary,
  subtitle: '+12% ce mois',
)
```

#### Carte avec image
```dart
AppImageCard(
  imageUrl: 'https://...',
  title: 'Pizza Margherita',
  subtitle: '12.50 €',
  onTap: () {},
)
```

#### Carte vide
```dart
AppEmptyCard(
  icon: Icons.inbox,
  title: 'Aucune commande',
  subtitle: 'Les commandes apparaîtront ici',
  action: AppButton.primary(
    text: 'Créer une commande',
    onPressed: () {},
  ),
)
```

### 6. Badges (`badges.dart`)

#### Badges d'état
```dart
AppBadge.success(text: 'Livré')
AppBadge.warning(text: 'En cours')
AppBadge.danger(text: 'Annulé')
AppBadge.info(text: 'En attente')
```

#### Tags produits
```dart
ProductTag.bestSeller()
ProductTag.nouveau()
ProductTag.specialiteChef()
ProductTag.promo()
```

#### Badge de statut
```dart
StatusBadge(
  text: 'En ligne',
  type: BadgeType.success,
  showDot: true,
)
```

#### Badge compteur
```dart
CountBadge(count: 5)
```

#### Badge prix
```dart
PriceBadge(price: 12.50)
```

### 7. Tableaux (`tables.dart`)

#### Table standard
```dart
AppTable(
  columns: [
    AppTableColumn(header: 'Nom', flex: 2),
    AppTableColumn(header: 'Prix', alignment: TextAlign.right),
    AppTableColumn(header: 'Actions', alignment: TextAlign.right),
  ],
  rows: [
    [
      Text('Pizza Margherita'),
      Text('12.50 €'),
      AppTableActions(
        actions: [
          AppTableAction(
            icon: Icons.edit,
            onPressed: () {},
            tooltip: 'Modifier',
          ),
          AppTableAction(
            icon: Icons.delete,
            onPressed: () {},
            tooltip: 'Supprimer',
            color: AppColors.danger,
          ),
        ],
      ),
    ],
  ],
)
```

### 8. Dialogs (`dialogs.dart`)

#### Dialog info
```dart
await AppInfoDialog.show(
  context,
  title: 'Information',
  message: 'Opération réussie',
  icon: Icons.check_circle,
  iconColor: AppColors.success,
);
```

#### Dialog confirmation
```dart
final confirmed = await AppConfirmDialog.show(
  context,
  title: 'Confirmer',
  message: 'Êtes-vous sûr ?',
);

if (confirmed) {
  // Action confirmée
}
```

#### Dialog danger
```dart
final confirmed = await AppDangerDialog.show(
  context,
  title: 'Supprimer',
  message: 'Cette action est irréversible',
);
```

#### Dialog loading
```dart
AppLoadingDialog.show(context, message: 'Chargement...');
// ... opération async
AppLoadingDialog.hide(context);
```

#### Bottom Sheet
```dart
await AppBottomSheet.show(
  context,
  title: 'Options',
  child: Column(
    children: [
      // Contenu
    ],
  ),
);
```

### 9. Sections (`sections.dart`)

#### En-tête de section
```dart
SectionHeader(
  title: 'Produits',
  subtitle: 'Gérer vos produits',
  actions: [
    AppButton.primary(
      text: 'Ajouter',
      icon: Icons.add,
      onPressed: () {},
    ),
  ],
  showDivider: true,
)
```

#### Groupe de cartes
```dart
SectionCardGroup(
  title: 'Statistiques',
  crossAxisCount: 3, // 3 colonnes sur desktop
  children: [
    AppStatCard(...),
    AppStatCard(...),
    AppStatCard(...),
  ],
)
```

#### Layouts responsive

##### 2 colonnes
```dart
TwoColumnLayout(
  left: Widget1(),
  right: Widget2(),
  breakpoint: 768, // Passe à 1 colonne en dessous
)
```

##### 3 colonnes
```dart
ThreeColumnLayout(
  children: [
    Widget1(),
    Widget2(),
    Widget3(),
  ],
  // 3 → 2 → 1 colonnes selon la largeur
)
```

##### Grille responsive
```dart
ResponsiveGrid(
  minItemWidth: 300,
  children: [
    Card1(),
    Card2(),
    Card3(),
  ],
)
```

## 📐 Spacing & Sizing

### Espacements
```dart
AppSpacing.xxs   // 4px
AppSpacing.xs    // 8px
AppSpacing.sm    // 12px
AppSpacing.md    // 16px
AppSpacing.lg    // 24px
AppSpacing.xl    // 32px
AppSpacing.xxl   // 48px
```

### Radius
```dart
AppRadius.small   // 8px (cartes)
AppRadius.medium  // 12px (boutons, inputs)
AppRadius.large   // 16px (modales)
```

### Ombres
```dart
AppShadows.soft      // Légère
AppShadows.medium    // Normale
AppShadows.strong    // Forte
AppShadows.card      // Pour cartes
AppShadows.primary   // Colorée rouge
```

## 🎨 Responsive Design

Le design system gère automatiquement 3 breakpoints :

- **Desktop large** (> 900px) : 3 colonnes
- **Tablet** (600-900px) : 2 colonnes  
- **Mobile** (< 600px) : 1 colonne

Utilisez `TwoColumnLayout`, `ThreeColumnLayout` ou `ResponsiveGrid` pour bénéficier de la responsivité automatique.

## 🔧 Architecture

```
lib/src/design_system/
├── app_theme.dart          # Export central + ThemeData
├── colors.dart             # Palette de couleurs
├── text_styles.dart        # Styles typographiques
├── spacing.dart            # Espacements
├── radius.dart             # Coins arrondis
├── shadows.dart            # Ombres
├── buttons.dart            # Composants boutons
├── inputs.dart             # Composants formulaires
├── cards.dart              # Composants cartes
├── badges.dart             # Badges et tags
├── tables.dart             # Composants tableaux
├── dialogs.dart            # Modales et dialogs
├── sections.dart           # Sections et layouts
└── design_system_showcase.dart  # Démonstration
```

## 🎯 Best Practices

1. **Utilisez les composants du design system** plutôt que les widgets Material par défaut
2. **Respectez la hiérarchie typographique** (H1 > H2 > H3 > Body)
3. **Utilisez les espacements définis** (`AppSpacing.md` plutôt que `16.0`)
4. **Préférez les layouts responsive** (`TwoColumnLayout` plutôt que `Row`)
5. **Testez sur différentes tailles d'écran** (mobile, tablet, desktop)

## 🔄 Rétrocompatibilité

Les anciens imports continuent de fonctionner :

```dart
import 'package:pizza_delizza/src/theme/app_theme.dart';
// ✅ Toujours valide, redirige vers le nouveau design system
```

Tous les anciens noms (`AppColors.primaryRed`, `AppSpacing.paddingLG`, etc.) sont conservés comme aliases.

## 📝 Exemples

Voir `design_system_showcase.dart` pour des exemples complets d'utilisation de tous les composants.

## 🤝 Contribution

Pour ajouter un nouveau composant :

1. Créer le fichier dans `lib/src/design_system/`
2. Exporter depuis `app_theme.dart`
3. Ajouter des exemples dans `design_system_showcase.dart`
4. Documenter dans ce README

---

**Pizza Deli'Zza Design System** - Version 1.0.0
