# Audit Technique - Enums

## Vue d'ensemble des enums

Ce document liste tous les enums utilisés dans le projet, avec focus sur le Builder B3.

---

## 1. Enums Builder B3 (`lib/builder/models/builder_enums.dart`)

### BuilderPageId
**Description:** Identifiants des pages système

```dart
enum BuilderPageId {
  home('home', 'Accueil'),
  menu('menu', 'Menu'),
  promo('promo', 'Promotions'),
  about('about', 'À propos'),
  contact('contact', 'Contact'),
  profile('profile', 'Profil'),      // système protégé
  cart('cart', 'Panier'),            // système protégé
  rewards('rewards', 'Récompenses'), // système protégé
  roulette('roulette', 'Roulette');  // système protégé
}
```

**Propriétés:**
- `value` - Identifiant string (Firestore ID)
- `label` - Nom affiché
- `isSystemPage` - Page protégée (via SystemPages registry)

**Méthodes statiques:**
- `tryFromString()` - Parse nullable
- `fromString()` - Parse avec exception si inconnu
- `tryFromJson()` / `fromJson()` - Parsing JSON

---

### BlockType
**Description:** Types de blocs disponibles

```dart
enum BlockType {
  hero('hero', 'Hero Banner', '🖼️'),
  banner('banner', 'Bannière', '🎨'),
  text('text', 'Texte', '📝'),
  productList('product_list', 'Liste Produits', '🍕'),
  info('info', 'Information', 'ℹ️'),
  spacer('spacer', 'Espaceur', '⬜'),
  image('image', 'Image', '🖼️'),
  button('button', 'Bouton', '🔘'),
  categoryList('category_list', 'Catégories', '📂'),
  html('html', 'HTML Personnalisé', '💻'),
  system('system', 'Module Système', '⚙️');
}
```

**Propriétés:**
- `value` - Identifiant string (pour Firestore)
- `label` - Nom affiché en français
- `icon` - Emoji représentatif

---

### BlockAlignment
**Description:** Options d'alignement

```dart
enum BlockAlignment {
  left('left', 'Gauche'),
  center('center', 'Centre'),
  right('right', 'Droite');
}
```

---

### BlockVisibility
**Description:** Options de visibilité

```dart
enum BlockVisibility {
  visible('visible', 'Visible'),
  hidden('hidden', 'Masqué'),
  mobileOnly('mobile_only', 'Mobile uniquement'),
  desktopOnly('desktop_only', 'Desktop uniquement');
}
```

---

### BuilderPageType
**Description:** Types de pages

```dart
enum BuilderPageType {
  template('template', 'Template'),
  blank('blank', 'Page Vierge'),
  system('system', 'Page Système'),
  custom('custom', 'Page Personnalisée');
}
```

---

## 2. Comparaison Builder vs Runtime

### Blocs présents dans les deux systèmes ✅

| BlockType | Preview Widget | Runtime Widget |
|-----------|---------------|----------------|
| hero | hero_block_preview.dart | hero_block_runtime.dart |
| banner | banner_block_preview.dart | banner_block_runtime.dart |
| text | text_block_preview.dart | text_block_runtime.dart |
| productList | product_list_block_preview.dart | product_list_block_runtime.dart |
| info | info_block_preview.dart | info_block_runtime.dart |
| spacer | spacer_block_preview.dart | spacer_block_runtime.dart |
| image | image_block_preview.dart | image_block_runtime.dart |
| button | button_block_preview.dart | button_block_runtime.dart |
| categoryList | category_list_block_preview.dart | category_list_block_runtime.dart |
| html | html_block_preview.dart | html_block_runtime.dart |
| system | system_block_preview.dart | system_block_runtime.dart |

### Pages système vs pages éditables

| Page | BuilderPageId | isSystemPage | Éditable | Supprimable |
|------|--------------|--------------|----------|-------------|
| Accueil | home | false | ✅ Oui | ✅ Oui |
| Menu | menu | false | ✅ Oui | ✅ Oui |
| Promotions | promo | false | ✅ Oui | ✅ Oui |
| À propos | about | false | ✅ Oui | ✅ Oui |
| Contact | contact | false | ✅ Oui | ✅ Oui |
| Panier | cart | true | ✅ Oui | ❌ Non |
| Profil | profile | true | ✅ Oui | ❌ Non |
| Récompenses | rewards | true | ✅ Oui | ❌ Non |
| Roulette | roulette | true | ✅ Oui | ❌ Non |

---

## 3. Modules système disponibles

Modules utilisables via `BlockType.system` :

| moduleType | Label | Icône | Disponible |
|------------|-------|-------|------------|
| roulette | Roulette | 🎰 | ✅ |
| loyalty | Fidélité | ⭐ | ✅ |
| rewards | Récompenses | 🎁 | ✅ |
| accountActivity | Activité du compte | 📊 | ✅ |
| menu_catalog | Catalogue Menu | 🍕 | ✅ |
| cart_module | Panier | 🛒 | ✅ |
| profile_module | Profil | 👤 | ✅ |

---

## 4. Différences et incohérences détectées

### ⚠️ Valeur de BlockType.productList
- **Enum value:** `'product_list'` (avec underscore)
- **Impact:** Doit être cohérent avec Firestore

### ⚠️ Valeur de BlockType.categoryList
- **Enum value:** `'category_list'` (avec underscore)
- **Impact:** Doit être cohérent avec Firestore

### ✅ Fallback par défaut
- `BlockType.fromString()` → `BlockType.text`
- `BlockVisibility.fromString()` → `BlockVisibility.visible`
- `BlockAlignment.fromString()` → `BlockAlignment.left`
- `BuilderPageType.fromString()` → `BuilderPageType.custom`

---

## 5. Routes par défaut

| BuilderPageId | Route | Firestore ID |
|--------------|-------|--------------|
| home | /home | home |
| menu | /menu | menu |
| promo | /promo | promo |
| about | /about | about |
| contact | /contact | contact |
| cart | /cart | cart |
| profile | /profile | profile |
| rewards | /rewards | rewards |
| roulette | /roulette | roulette |

**Pages personnalisées:** Route = `/page/{pageKey}`

---

*Document généré automatiquement - Audit technique AppliPizza*
