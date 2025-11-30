# Audit Technique - Blocs Builder

## Vue d'ensemble des blocs

Ce document liste tous les blocs disponibles dans le Builder B3.

---

## 1. Inventaire complet des blocs

### Blocs de contenu

| Type | Fichier Preview | Fichier Runtime | Modèle | Status |
|------|-----------------|-----------------|--------|--------|
| hero | hero_block_preview.dart | hero_block_runtime.dart | BuilderBlock | ✅ Complet |
| banner | banner_block_preview.dart | banner_block_runtime.dart | BuilderBlock | ✅ Complet |
| text | text_block_preview.dart | text_block_runtime.dart | BuilderBlock | ✅ Complet |
| productList | product_list_block_preview.dart | product_list_block_runtime.dart | BuilderBlock | ✅ Complet |
| info | info_block_preview.dart | info_block_runtime.dart | BuilderBlock | ✅ Complet |
| spacer | spacer_block_preview.dart | spacer_block_runtime.dart | BuilderBlock | ✅ Complet |
| image | image_block_preview.dart | image_block_runtime.dart | BuilderBlock | ✅ Complet |
| button | button_block_preview.dart | button_block_runtime.dart | BuilderBlock | ✅ Complet |
| categoryList | category_list_block_preview.dart | category_list_block_runtime.dart | BuilderBlock | ✅ Complet |
| html | html_block_preview.dart | html_block_runtime.dart | BuilderBlock | ✅ Complet |
| system | system_block_preview.dart | system_block_runtime.dart | SystemBlock | ✅ Complet |

---

## 2. Fichiers par dossier

### `lib/builder/blocks/`

```
blocks/
├── blocks.dart                    # Barrel file (exports)
├── README.md                      # Documentation
│
├── hero_block_preview.dart        # Preview Hero
├── hero_block_runtime.dart        # Runtime Hero
│
├── banner_block_preview.dart      # Preview Banner
├── banner_block_runtime.dart      # Runtime Banner
│
├── text_block_preview.dart        # Preview Text
├── text_block_runtime.dart        # Runtime Text
│
├── product_list_block_preview.dart # Preview ProductList
├── product_list_block_runtime.dart # Runtime ProductList
│
├── info_block_preview.dart        # Preview Info
├── info_block_runtime.dart        # Runtime Info
│
├── spacer_block_preview.dart      # Preview Spacer
├── spacer_block_runtime.dart      # Runtime Spacer
│
├── image_block_preview.dart       # Preview Image
├── image_block_runtime.dart       # Runtime Image
│
├── button_block_preview.dart      # Preview Button
├── button_block_runtime.dart      # Runtime Button
│
├── category_list_block_preview.dart # Preview CategoryList
├── category_list_block_runtime.dart # Runtime CategoryList
│
├── html_block_preview.dart        # Preview HTML
├── html_block_runtime.dart        # Runtime HTML
│
├── system_block_preview.dart      # Preview System
└── system_block_runtime.dart      # Runtime System
```

---

## 3. Détail des blocs

### Hero Block
**Description:** Bannière héro avec image de fond et CTA

**Config:**
```dart
{
  'title': String,           // Titre principal
  'subtitle': String,        // Sous-titre
  'imageUrl': String,        // URL image de fond
  'backgroundColor': String, // Couleur de fond (#RRGGBB)
  'textColor': String,       // Couleur du texte
  'buttonLabel': String,     // Label du bouton CTA
  'alignment': String,       // left, center, right
  'heightPreset': String,    // small, normal, large
  'tapAction': String,       // Action au clic
  'tapActionTarget': String, // Cible de l'action
}
```

---

### Text Block
**Description:** Bloc de texte formaté

**Config:**
```dart
{
  'content': String,     // Contenu texte
  'alignment': String,   // left, center, right
  'size': String,        // small, normal, large, title, heading
  'bold': bool,          // Gras
  'color': String,       // Couleur (#RRGGBB)
  'padding': int,        // Padding en pixels
  'maxLines': int,       // Nombre de lignes max (0 = illimité)
  'tapAction': String,
  'tapActionTarget': String,
}
```

---

### Product List Block
**Description:** Liste de produits avec différents modes d'affichage

**Config:**
```dart
{
  'title': String,               // Titre de section
  'titleAlignment': String,      // left, center, right
  'titleSize': String,           // small, medium, large
  'mode': String,                // featured, manual, top_selling, promo
  'categoryId': String,          // ID catégorie (pour filtrage)
  'productIds': String,          // IDs produits séparés par virgule
  'layout': String,              // grid, carousel, list
  'limit': int,                  // Nombre max de produits
  'backgroundColor': String,
  'textColor': String,
  'borderRadius': int,
  'elevation': int,
  'actionOnProductTap': String,  // openProductDetail, openPage
}
```

---

### Banner Block
**Description:** Bannière promotionnelle

**Config:**
```dart
{
  'title': String,
  'subtitle': String,
  'text': String,            // Fallback si pas de titre
  'imageUrl': String,
  'backgroundColor': String,
  'textColor': String,
  'style': String,           // info, promo, warning, success
  'ctaLabel': String,
  'ctaAction': String,
  'tapAction': String,
  'tapActionTarget': String,
}
```

---

### Button Block
**Description:** Bouton d'action

**Config:**
```dart
{
  'label': String,
  'style': String,           // primary, secondary, outline, text
  'alignment': String,       // left, center, right, stretch
  'backgroundColor': String,
  'textColor': String,
  'borderRadius': int,
  'tapAction': String,
  'tapActionTarget': String,
}
```

---

### Image Block
**Description:** Image avec options d'affichage

**Config:**
```dart
{
  'imageUrl': String,
  'caption': String,
  'alignment': String,
  'height': int,             // Hauteur en pixels
  'fit': String,             // cover, contain, fill, fitWidth, fitHeight
  'borderRadius': int,
  'tapAction': String,
  'tapActionTarget': String,
}
```

---

### Spacer Block
**Description:** Espace vertical

**Config:**
```dart
{
  'height': int,  // Hauteur en pixels
}
```

---

### Info Block
**Description:** Bloc d'information avec icône

**Config:**
```dart
{
  'title': String,
  'content': String,
  'icon': String,            // info, warning, success, error, time, phone, location, email
  'highlight': bool,
  'actionType': String,      // none, call, email, navigate
  'actionValue': String,
  'backgroundColor': String,
}
```

---

### Category List Block
**Description:** Liste de catégories

**Config:**
```dart
{
  'title': String,
  'mode': String,    // auto, custom
  'layout': String,  // horizontal, grid, carousel
  'tapAction': String,
  'tapActionTarget': String,
}
```

---

### HTML Block
**Description:** Contenu HTML personnalisé

**Config:**
```dart
{
  'htmlContent': String,  // Code HTML
}
```

---

### System Block
**Description:** Module système (non configurable, positionnable)

**Config:**
```dart
{
  'moduleType': String,  // roulette, loyalty, rewards, accountActivity, etc.
}
```

**Modules disponibles:**
| moduleType | Label | Widget Runtime |
|------------|-------|----------------|
| roulette | Roulette | RoulettModuleWidget |
| loyalty | Fidélité | LoyaltySectionWidget |
| rewards | Récompenses | RewardsTicketsWidget |
| accountActivity | Activité du compte | AccountActivityWidget |
| menu_catalog | Catalogue Menu | MenuCatalogRuntimeWidget |
| cart_module | Panier | CartScreen |
| profile_module | Profil | ProfileModuleWidget |

---

## 4. Widgets de rendu

### Preview (pour l'éditeur)
**Localisation:** `lib/builder/blocks/*_preview.dart`

- Affichent une représentation simplifiée
- Pas de données réelles (mock data)
- Optimisés pour l'éditeur

### Runtime (pour le client)
**Localisation:** `lib/builder/blocks/*_runtime.dart`

- Affichent les vraies données
- Connectés aux providers Riverpod
- Gèrent les interactions utilisateur

---

## 5. Actions au clic (tapAction)

| Action | Description | tapActionTarget |
|--------|-------------|-----------------|
| none | Aucune action | - |
| openPage | Ouvrir une page Builder | pageKey |
| openLegacyPage | Ouvrir une route legacy | route string |
| openSystemPage | Ouvrir une page système | pageId |
| openUrl | Ouvrir une URL externe | URL complète |

---

## 6. Blocs manquants ou en développement

### Potentiels blocs futurs
- ❌ Video block (pas implémenté)
- ❌ Map block (pas implémenté)
- ❌ Carousel block (pas implémenté - productList a mode carousel)
- ❌ Countdown block (pas implémenté)
- ❌ Review/Rating block (pas implémenté)

---

## 7. Validation de cohérence

### Tous les blocs ont :
- ✅ Enum dans BlockType
- ✅ Widget preview
- ✅ Widget runtime
- ✅ Config par défaut dans l'éditeur
- ✅ Export dans blocks.dart

### Points d'attention :
- ⚠️ html_block_runtime utilise webview (peut poser problème)
- ⚠️ system_block_runtime dépend des widgets externes

---

*Document généré automatiquement - Audit technique AppliPizza*
