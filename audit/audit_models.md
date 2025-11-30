# Audit Technique - Modèles de Données

## Vue d'ensemble des modèles

Ce document liste tous les modèles de données du projet, organisés par domaine.

---

## 1. Modèles Builder B3 (`lib/builder/models/`)

### BuilderPage
**Fichier:** `lib/builder/models/builder_page.dart`

**Description:** Modèle principal représentant une page éditable.

**Structure:**
```dart
class BuilderPage {
  final String pageKey;              // Identifiant unique (source de vérité)
  final BuilderPageId? systemId;     // ID système (nullable pour pages custom)
  final BuilderPageId? pageId;       // @deprecated - utiliser pageKey/systemId
  final String appId;                // ID restaurant (multi-tenant)
  final String name;                 // Nom affiché
  final String description;          // Description
  final String route;                // Route (/home, /menu, etc.)
  final List<BuilderBlock> blocks;   // @deprecated - utiliser draftLayout
  final bool isEnabled;              // Page active
  final bool isDraft;                // Version brouillon
  final PageMetadata? metadata;      // SEO
  final int version;                 // Numéro de version
  final DateTime createdAt;          // Date création
  final DateTime updatedAt;          // Date modification
  final DateTime? publishedAt;       // Date publication
  final String? lastModifiedBy;      // Dernier éditeur
  final String displayLocation;      // Position nav ('bottomBar', 'hidden')
  final String icon;                 // Icône (nom Material Icon)
  final int order;                   // Ordre dans la navigation
  final bool isSystemPage;           // Page système protégée
  final BuilderPageType pageType;    // Type (template, blank, system, custom)
  final bool isActive;               // Visible dans bottom bar
  final int? bottomNavIndex;         // Position dans bottom bar (0-4)
  final List<String> modules;        // Modules attachés
  final bool hasUnpublishedChanges;  // Modifications non publiées
  final List<BuilderBlock> draftLayout;     // Layout brouillon ✅
  final List<BuilderBlock> publishedLayout; // Layout publié ✅
}
```

**Méthodes clés:**
- `fromJson()` - Parsing avec fallback chain
- `toJson()` - Sérialisation
- `publish()` - Publication (copy draftLayout → publishedLayout)
- `createDraft()` - Création brouillon
- `addBlock()`, `removeBlock()`, `updateBlock()`, `reorderBlocks()`

---

### BuilderBlock
**Fichier:** `lib/builder/models/builder_block.dart`

**Description:** Modèle d'un bloc de contenu.

**Structure:**
```dart
class BuilderBlock {
  final String id;                   // ID unique
  final BlockType type;              // Type de bloc
  final int order;                   // Position (0 = premier)
  final Map<String, dynamic> config; // Configuration spécifique
  final bool isActive;               // Bloc actif
  final BlockVisibility visibility;  // Visibilité
  final String? customStyles;        // CSS personnalisé
  final DateTime createdAt;          // Date création
  final DateTime updatedAt;          // Date modification
}
```

**Champs config par type:**
| Type | Champs config |
|------|---------------|
| hero | title, subtitle, imageUrl, backgroundColor, buttonLabel, alignment, heightPreset, tapAction, tapActionTarget |
| text | content, alignment, size, bold, color, padding, maxLines, tapAction |
| productList | title, mode, categoryId, productIds, layout, limit, backgroundColor, textColor |
| banner | title, subtitle, text, imageUrl, backgroundColor, textColor, style, ctaLabel, ctaAction |
| button | label, style, alignment, backgroundColor, textColor, borderRadius, tapAction |
| image | imageUrl, caption, alignment, height, fit, borderRadius, tapAction |
| spacer | height |
| info | title, content, icon, highlight, actionType, actionValue |
| categoryList | title, mode, layout |
| html | htmlContent |
| system | moduleType |

---

### SystemBlock
**Fichier:** `lib/builder/models/builder_block.dart`

**Description:** Extension de BuilderBlock pour les modules système.

**Structure:**
```dart
class SystemBlock extends BuilderBlock {
  final String moduleType;  // Type de module
}
```

**Modules disponibles:**
- `roulette` - Roue de la chance
- `loyalty` - Fidélité
- `rewards` - Récompenses
- `accountActivity` - Activité du compte
- `menu_catalog` - Catalogue menu
- `cart_module` - Panier
- `profile_module` - Profil

---

### SystemPageConfig
**Fichier:** `lib/builder/models/system_pages.dart`

**Description:** Configuration d'une page système.

**Structure:**
```dart
class SystemPageConfig {
  final BuilderPageId pageId;     // ID enum
  final String route;             // Route
  final String firestoreId;       // ID Firestore
  final String defaultName;       // Nom par défaut
  final IconData defaultIcon;     // Icône par défaut
  final bool isSystemPage;        // Page protégée
}
```

---

### PageMetadata
**Fichier:** `lib/builder/models/builder_page.dart`

**Description:** Métadonnées SEO d'une page.

**Structure:**
```dart
class PageMetadata {
  final String? title;          // Titre SEO
  final String? description;    // Description SEO
  final List<String>? keywords; // Mots-clés
  final String? ogImage;        // Image OpenGraph
}
```

---

## 2. Modèles Application (`lib/src/models/`)

### Product
**Fichier:** `lib/src/models/product.dart`

**Description:** Modèle produit (pizza, boisson, etc.)

### Order
**Fichier:** `lib/src/models/order.dart`

**Description:** Modèle commande

### UserProfile
**Fichier:** `lib/src/models/user_profile.dart`

**Description:** Profil utilisateur

### LoyaltySettings
**Fichier:** `lib/src/models/loyalty_settings.dart`

**Description:** Configuration fidélité

### RouletteConfig
**Fichier:** `lib/src/models/roulette_config.dart`

**Description:** Configuration roulette

### RewardTicket
**Fichier:** `lib/src/models/reward_ticket.dart`

**Description:** Ticket de récompense

### Campaign
**Fichier:** `lib/src/models/campaign.dart`

**Description:** Campagne marketing

### Promotion
**Fichier:** `lib/src/models/promotion.dart`

**Description:** Promotion

### ThemeConfig
**Fichier:** `lib/src/models/theme_config.dart`

**Description:** Configuration du thème

### HomeConfig
**Fichier:** `lib/src/models/home_config.dart`

**Description:** Configuration page d'accueil (legacy)

### BannerConfig
**Fichier:** `lib/src/models/banner_config.dart`

**Description:** Configuration bannière (legacy)

### PopupConfig
**Fichier:** `lib/src/models/popup_config.dart`

**Description:** Configuration popup

### AppTextsConfig
**Fichier:** `lib/src/models/app_texts_config.dart`

**Description:** Textes personnalisables

### RestaurantConfig
**Fichier:** `lib/src/models/restaurant_config.dart`

**Description:** Configuration restaurant

### EmailTemplate
**Fichier:** `lib/src/models/email_template.dart`

**Description:** Template email

### LoyaltyReward
**Fichier:** `lib/src/models/loyalty_reward.dart`

**Description:** Récompense fidélité

### RewardAction
**Fichier:** `lib/src/models/reward_action.dart`

**Description:** Action de récompense

### Subscriber
**Fichier:** `lib/src/models/subscriber.dart`

**Description:** Abonné newsletter

---

## 3. Doublons et problèmes identifiés

### ⚠️ Champ `blocks` vs `draftLayout`/`publishedLayout`
- **Problème:** Le champ `blocks` est déprécié mais toujours présent
- **Solution:** Migration vers draftLayout/publishedLayout en cours
- **Impact:** Certains services utilisent encore `blocks`

### ⚠️ `pageId` vs `pageKey` vs `systemId`
- **Problème:** Trois champs pour identifier une page
- **Solution:** 
  - `pageKey` = source de vérité (string)
  - `systemId` = référence enum pour pages système
  - `pageId` = déprécié, alias de systemId

### ⚠️ HomeConfig vs BuilderPage
- **Problème:** Deux systèmes de configuration de la page d'accueil
- **HomeConfig:** Legacy, dans builder_settings/home_config
- **BuilderPage:** Nouveau, dans pages_published/home
- **Solution:** Migration progressive vers BuilderPage

---

## 4. Hiérarchie des modèles

```
BuilderPage (page complète)
└── BuilderBlock (bloc de contenu)
    └── SystemBlock (module système)

SystemPages (registre)
└── SystemPageConfig (config par page)
```

---

*Document généré automatiquement - Audit technique AppliPizza*
