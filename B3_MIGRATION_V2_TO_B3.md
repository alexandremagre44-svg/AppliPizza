# Migration V2 → B3 - Documentation

## Objectif

Migrer automatiquement les pages existantes du système V2 (HomeConfigV2) vers l'architecture B3 basée sur PageSchema.

## Implémentation

### Méthode Principale

**`AppConfigService.migrateExistingPagesToB3(String appId)`**

Cette méthode effectue la migration complète des contenus V2 vers B3.

### Fonctionnalités

✅ **Lecture des contenus existants**
- Charge la configuration V2 depuis Firestore
- Extrait les sections home (hero, promo banner, popup)

✅ **Conversion en B3**
- Hero → `WidgetBlockType.heroAdvanced` avec CTAs, gradients et overlay
- PromoBanner → `WidgetBlockType.promoBanner` avec couleurs et gradients
- Popup → `WidgetBlockType.popup` avec CTAs et déclencheurs
- Ajout automatique de `productSlider` et `categorySlider`

✅ **Création des 4 pages B3**
1. **home_b3** (`/home-b3`) - Page d'accueil avec sections migrées
2. **menu_b3** (`/menu-b3`) - Page menu avec liste de produits
3. **categories_b3** (`/categories-b3`) - Page catégories
4. **cart_b3** (`/cart-b3`) - Page panier

✅ **Écriture dans Firestore**
- Écrit dans `app_config/{appId}/draft`
- Écrit dans `app_config/{appId}/published`
- Utilise `SetOptions(merge: true)` pour préserver les données existantes

✅ **Exécution unique**
- Flag SharedPreferences: `b3_migration_v2_to_b3_completed`
- Ne se réexécute jamais une fois réussie
- Réessaye si les deux écritures échouent

### Mapping des Contenus

| V2 Section Type | B3 Block Type | Propriétés |
|----------------|---------------|------------|
| `hero` | `heroAdvanced` | title, subtitle, imageUrl, gradient, CTAs |
| `promoBanner` | `promoBanner` | title, backgroundColor, gradient |
| `popup` | `popup` | title, message, CTAs, triggers |
| N/A | `productSlider` | dataSource products, columns, spacing |
| N/A | `categorySlider` | dataSource categories, itemWidth |
| N/A | `banner` | text, backgroundColor (pages menu/cart) |
| N/A | `text` | text, fontSize, align |
| N/A | `button` | label, action |

### Navigation

La migration convertit automatiquement les cibles V2 en routes B3:

```dart
V2 Target    →  B3 Route
'menu'       →  '/menu-b3'
'categories' →  '/categories-b3'
'cart'       →  '/cart-b3'
'home'       →  '/home-b3'
```

### Constantes

Le service utilise des constantes pour garantir la cohérence:

```dart
// Routes B3
_homeB3Route = '/home-b3'
_menuB3Route = '/menu-b3'
_categoriesB3Route = '/categories-b3'
_cartB3Route = '/cart-b3'

// Couleurs
_defaultPrimaryColor = '#D62828'
_defaultWhiteColor = '#FFFFFF'
_defaultGradientStartColor = '#000000CC'
_defaultGradientEndColor = '#00000000'

// Images
_defaultHeroImageUrl = 'https://images.unsplash.com/photo-1513104890138-7c749659a591'
```

## Exécution

### Automatique

La migration est appelée automatiquement au démarrage de l'application:

```dart
// lib/main.dart
await AppConfigService().migrateExistingPagesToB3('pizza_delizza');
```

### Manuelle

Peut être appelée manuellement si nécessaire:

```dart
final service = AppConfigService();
await service.migrateExistingPagesToB3('pizza_delizza');
```

## Logs

La migration génère des logs clairs:

```
B3 Migration: Starting V2 → B3 migration for appId: pizza_delizza
B3 Migration: Home page created with 5 blocks
B3 Migration: Menu page created
B3 Migration: Categories page created
B3 Migration: Cart page created
B3 Migration: Written to published config
B3 Migration: Written to draft config
✅ Migration B3 SUCCESS - 4 pages migrated
```

En cas d'échec:

```
B3 Migration: Both writes failed, will retry on next launch
```

## Gestion des Erreurs

✅ **Robustesse**
- Jamais de crash, toutes les erreurs sont capturées
- Logs détaillés pour le débogage
- Réessaye automatiquement si les écritures échouent

✅ **Fallbacks**
- Si sections V2 manquantes → utilise pages B3 par défaut
- Si conversion échoue → utilise PageSchema.homeB3()
- Si écriture échoue → log et continue

✅ **Flag de migration**
- Uniquement défini si au moins une écriture réussit
- Permet la réexécution en cas d'échec partiel

## Tests

Tests complets dans `test/app_config_service_test.dart`:

- ✅ Structure des 4 pages B3
- ✅ Mapping des types de blocs
- ✅ Sérialisation/désérialisation
- ✅ Conversion des types
- ✅ Recherche de pages par route et ID

## Compatibilité

### Ce qui est préservé

✅ **Studio V2**
- Aucun changement aux écrans existants
- HomeConfigV2 reste fonctionnel
- Aucune suppression de code V2

✅ **DynamicPageScreen**
- Aucune modification
- Continue de fonctionner normalement

✅ **Autres modules**
- Products, categories, cart, auth inchangés
- Aucune modification des services existants

✅ **Firestore**
- Structure existante préservée
- Utilise `merge: true` pour sécurité
- Fallback draft → published intact

### Résultat

Après la migration:

1. **Studio B3** affiche les 4 pages migrées
2. Les pages sont **entièrement éditables** dans Studio B3
3. Le **builder est 100% fonctionnel**
4. Le système est **prêt pour le white-label**
5. **Aucune régression** dans Studio V2 ou l'app client

## Modifications de Fichiers

### Fichiers Modifiés

- ✅ `lib/src/services/app_config_service.dart` - Méthode de migration
- ✅ `lib/main.dart` - Appel de la migration

### Fichiers Ajoutés

- ✅ `test/app_config_service_test.dart` - Tests de migration
- ✅ `B3_MIGRATION_V2_TO_B3.md` - Cette documentation

### Fichiers Non Modifiés

- ✅ Tous les autres fichiers du projet
- ✅ Aucun changement aux classes existantes
- ✅ Aucun renommage de classes

## Conclusion

La migration V2 → B3 est maintenant complète et opérationnelle. Elle s'exécute automatiquement au premier démarrage de l'application, convertit tous les contenus existants en format B3, et rend Studio B3 entièrement fonctionnel sans casser aucun système existant.

**Status**: ✅ COMPLET - Migration B3 SUCCESS
