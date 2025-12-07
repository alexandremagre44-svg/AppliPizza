# Migration WL Modules: plan/unified → plan/config

## 📋 Vue d'ensemble

Cette migration transforme le système de modules White Label pour qu'il lise **UNIQUEMENT** depuis `restaurants/{id}/plan/config` avec une structure `modules[]` au lieu de `plan/unified`.

**Objectif** : Centraliser la configuration des modules dans un seul document avec une structure claire et facile à gérer.

## 🎯 Changements clés

### 1. Nouvelle structure Firestore

**Avant (plan/unified)** :
```json
{
  "restaurantId": "resto123",
  "name": "Pizza DeliZza",
  "activeModules": ["ordering", "delivery", "roulette"],
  "branding": { ... },
  "delivery": { ... },
  "ordering": { ... }
}
```

**Après (plan/config)** :
```json
{
  "restaurantId": "resto123",
  "name": "Pizza DeliZza",
  "modules": [
    { "id": "ordering", "enabled": true, "settings": {} },
    { "id": "delivery", "enabled": true, "settings": {} },
    { "id": "roulette", "enabled": true, "settings": {} },
    { "id": "loyalty", "enabled": false, "settings": {} }
  ],
  "branding": {
    "brandName": "Pizza DeliZza",
    "primaryColor": "#FF5733"
  }
}
```

### 2. Calcul automatique des activeModules

Le champ `activeModules` est maintenant **calculé automatiquement** à partir des modules avec `enabled: true` :

```dart
final activeModules = modules
    .where((m) => m.enabled == true)
    .map((m) => m.id)
    .toList();
```

### 3. ModuleConfig simplifié

**Avant** :
```dart
class ModuleConfig {
  final ModuleId id;  // Enum
  final bool enabled;
  final Map<String, dynamic> settings;
}
```

**Après** :
```dart
class ModuleConfig {
  final String id;  // String direct
  final bool enabled;
  final Map<String, dynamic> settings;
}
```

## 🔧 Utilisation

### Vérifier si un module est activé

```dart
// Avec string (nouveau)
if (plan.hasModule('ordering')) {
  // Module ordering activé
}

// Avec ModuleId (backward compatible)
if (plan.hasModule(ModuleId.ordering)) {
  // Module ordering activé
}
```

### Créer un plan avec modules

```dart
final plan = RestaurantPlanUnified(
  restaurantId: 'resto123',
  name: 'Pizza DeliZza',
  slug: 'pizza-delizza',
  modules: [
    ModuleConfig(id: 'ordering', enabled: true, settings: {}),
    ModuleConfig(id: 'delivery', enabled: false, settings: {}),
    ModuleConfig(id: 'roulette', enabled: true, settings: {}),
  ],
  activeModules: ['ordering', 'roulette'], // Calculé automatiquement
  branding: BrandingConfig.empty(),
);
```

### Lire depuis Firestore

Le provider `restaurantPlanUnifiedProvider` lit automatiquement depuis `plan/config` :

```dart
final planAsync = ref.watch(restaurantPlanUnifiedProvider);

planAsync.when(
  data: (plan) {
    if (plan?.hasModule('ordering') ?? false) {
      // Module ordering activé
    }
  },
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Erreur: $err'),
);
```

## 🏗️ Builder B3

### Filtrage des modules

Le Builder B3 utilise `SystemBlock.getFilteredModules()` pour filtrer les modules :

```dart
final filteredModules = SystemBlock.getFilteredModules(plan);

// Si plan == null → liste vide (strict)
// Si module in SystemModules.alwaysVisible → toujours visible
// Sinon → vérifie plan.hasModule(moduleId)
```

### Modules toujours visibles

```dart
class SystemModules {
  static const List<String> alwaysVisible = [
    'menu_catalog',    // Catalogue produits
    'profile_module',  // Profil utilisateur
  ];
}
```

### BlockAddDialog

Le `BlockAddDialog` reçoit le plan du BuilderPageEditorScreen :

```dart
final block = await BlockAddDialog.show(
  context,
  currentBlockCount: blocks.length,
  restaurantPlan: plan, // ← Passé depuis l'éditeur
);
```

## 🎭 Runtime

### Vérification des modules

Le runtime vérifie automatiquement si les modules sont activés :

```dart
if (!plan.hasModule(moduleId)) {
  return SizedBox.shrink(); // Module désactivé → masqué
}
```

### Module Guards

Les guards vérifient l'accès aux modules :

```dart
final canAccessModule = ref.watch(
  isModuleEnabledProvider(ModuleId.delivery),
);

if (!canAccessModule) {
  return UnauthorizedPage();
}
```

## 🔄 Rétrocompatibilité

### Plan manquant

Si le document `plan/config` n'existe pas :

```dart
return RestaurantPlanUnified(
  restaurantId: restaurantId,
  name: '',
  slug: '',
  modules: [],
  activeModules: [],
  branding: BrandingConfig.empty(),
);
```

### hasModule() flexible

La méthode `hasModule()` accepte à la fois des strings et des ModuleId :

```dart
bool hasModule(dynamic moduleIdOrCode) {
  if (moduleIdOrCode is ModuleId) {
    return activeModules.contains(moduleIdOrCode.code);
  } else if (moduleIdOrCode is String) {
    return activeModules.contains(moduleIdOrCode);
  }
  return false;
}
```

## 📝 Migration des données

### SuperAdmin

Créer ou mettre à jour le document `plan/config` :

```dart
final configDoc = await firestore
    .collection('restaurants')
    .doc(restaurantId)
    .collection('plan')
    .doc('config');

await configDoc.set({
  'restaurantId': restaurantId,
  'name': 'Pizza DeliZza',
  'slug': 'pizza-delizza',
  'modules': [
    {'id': 'ordering', 'enabled': true, 'settings': {}},
    {'id': 'delivery', 'enabled': true, 'settings': {}},
    {'id': 'roulette', 'enabled': false, 'settings': {}},
  ],
  'branding': {
    'brandName': 'Pizza DeliZza',
    'primaryColor': '#FF5733',
  },
});
```

### Migration script (si nécessaire)

```dart
// Lire depuis l'ancien plan/unified
final unifiedDoc = await firestore
    .collection('restaurants')
    .doc(restaurantId)
    .collection('plan')
    .doc('unified')
    .get();

if (unifiedDoc.exists) {
  final data = unifiedDoc.data()!;
  final activeModules = data['activeModules'] as List<dynamic>? ?? [];
  
  // Créer la nouvelle structure modules[]
  final modules = activeModules.map((id) => {
    'id': id,
    'enabled': true,
    'settings': {},
  }).toList();
  
  // Sauvegarder dans plan/config
  final configDoc = await firestore
      .collection('restaurants')
      .doc(restaurantId)
      .collection('plan')
      .doc('config');
  
  await configDoc.set({
    'restaurantId': restaurantId,
    'name': data['name'],
    'slug': data['slug'],
    'modules': modules,
    'branding': data['branding'],
  });
}
```

## ✅ Tests

### Tests unitaires

```dart
test('modules[] parsing and activeModules computation', () {
  final json = {
    'restaurantId': 'test',
    'name': 'Test',
    'slug': 'test',
    'modules': [
      {'id': 'ordering', 'enabled': true, 'settings': {}},
      {'id': 'delivery', 'enabled': false, 'settings': {}},
    ],
  };

  final plan = RestaurantPlanUnified.fromJson(json);

  expect(plan.modules.length, 2);
  expect(plan.activeModules, ['ordering']);
  expect(plan.hasModule('ordering'), true);
  expect(plan.hasModule('delivery'), false);
});
```

### Tests d'intégration

Voir `test/restaurant_plan_provider_test.dart` pour les tests complets.

## 🚀 Résultat

✅ **SuperAdmin ON/OFF** → instantanément appliqué via `modules[]`  
✅ **Builder** n'affiche que les modules activés (`getFilteredModules`)  
✅ **Runtime** masque les modules OFF (`hasModule` checks)  
✅ **Plus de modules fantômes** visibles  
✅ **Système 100% cohérent** et centralisé sur `plan/config`  
✅ **Rétrocompatibilité** : config manquant → plan vide  
✅ **Modules always-visible** : menu_catalog, profile_module bypass plan check

## 📚 Fichiers modifiés

- `lib/white_label/core/module_config.dart`
- `lib/white_label/restaurant/restaurant_plan_unified.dart`
- `lib/src/providers/restaurant_plan_provider.dart`
- `lib/src/services/restaurant_plan_runtime_service.dart`
- `lib/superadmin/services/restaurant_plan_service.dart`
- `lib/builder/debug/builder_wl_diagnostic.dart`
- `lib/superadmin/pages/wl_diagnostic_page.dart`
- `lib/superadmin/providers/superadmin_restaurants_provider.dart`
- `test/restaurant_plan_provider_test.dart` (nouveau)

## 🔗 Liens utiles

- [ModuleId enum](lib/white_label/core/module_id.dart)
- [SystemBlock filtering](lib/builder/models/builder_block.dart)
- [Builder modules mapping](lib/builder/utils/builder_modules.dart)
- [Module guards](lib/white_label/runtime/module_guards.dart)
