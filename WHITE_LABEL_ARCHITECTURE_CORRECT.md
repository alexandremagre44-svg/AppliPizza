# White-Label Architecture - Séparation des Responsabilités

## ✅ Architecture Correcte (Post-Correction)

### Principe Fondamental

> **Builder B3 contrôle la PRÉSENTATION**  
> **White-Label contrôle les DROITS D'ACCÈS**

---

## Rôles et Responsabilités

### 1. Builder B3 (MAÎTRE)

**Contrôle total sur:**
- ✅ Quelles pages apparaissent dans la navigation
- ✅ L'ordre des éléments dans la bottom-nav
- ✅ Où les modules sont placés (home, nav bar, pages custom)
- ✅ La visibilité ou non d'un module dans l'UI
- ✅ Les icônes, labels, et présentation visuelle

**Stockage:**
```
restaurants/{restaurantId}/pages_system
  └─ order: [0, 1, 2, 3]  // Ordre des pages
  
restaurants/{restaurantId}/pages_published
  └─ pages: [
       { pageKey: "home", route: "/home", visible: true },
       { pageKey: "rewards", route: "/rewards", visible: true },
       { pageKey: "cart", route: "/cart", visible: true }
     ]
```

**Décisions:**
```dart
// Builder B3 décide d'inclure rewards dans la nav
builderPages = [home, rewards, cart, profile]

// OU Builder décide de l'exclure
builderPages = [home, cart, profile]  // Pas de rewards
```

---

### 2. White-Label Modules (VALIDATEUR)

**Contrôle uniquement:**
- ✅ Accès aux routes (guards)
- ✅ Visibilité des blocs Builder (ModuleAwareBlock)
- ❌ **PAS** la navigation
- ❌ **PAS** la présentation

**Stockage:**
```
restaurants/{restaurantId}/plan
  └─ activeModules: ["ordering", "delivery", "loyalty"]
```

**Validations:**
```dart
// Guard: Bloquer l'accès si module OFF
if (!plan.hasModule(ModuleId.roulette)) {
  return RedirectRoute('/menu');
}

// ModuleAwareBlock: Cacher bloc si module OFF
if (!isModuleEnabled(ref, ModuleId.loyalty)) {
  return SizedBox.shrink();
}
```

---

## Flow Correct

```
┌─────────────────────────────────────────┐
│  1. Builder B3 charge les pages         │
│     depuis Firestore                     │
│     pages = [home, rewards, cart]       │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  2. scaffold_with_nav_bar.dart          │
│     Rend TOUTES les pages du Builder   │
│     Navigation = [home, rewards, cart]  │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  3. Utilisateur clique sur "rewards"    │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  4. Route Guard vérifie                 │
│     plan.hasModule(ModuleId.loyalty)?   │
│       ✅ OUI → Affiche RewardsScreen    │
│       ❌ NON → Redirige + message       │
└─────────────────────────────────────────┘
```

---

## Exemples de Scénarios

### Scénario 1: Module ON + Builder Inclut

**Config:**
```javascript
// Firestore plan
activeModules: ["loyalty"]

// Builder B3
pages: [home, rewards, cart]
```

**Résultat:**
- ✅ "Rewards" apparaît dans nav
- ✅ Route `/rewards` accessible
- ✅ Blocs loyalty visibles dans Builder

---

### Scénario 2: Module ON + Builder Exclut

**Config:**
```javascript
// Firestore plan
activeModules: ["loyalty"]

// Builder B3
pages: [home, cart]  // Pas de rewards
```

**Résultat:**
- ❌ "Rewards" N'apparaît PAS dans nav (Builder décide)
- ✅ Route `/rewards` accessible si accès direct (URL)
- ✅ Blocs loyalty visibles dans Builder si utilisés

**Note:** Builder contrôle la navigation, pas le module.

---

### Scénario 3: Module OFF + Builder Inclut

**Config:**
```javascript
// Firestore plan
activeModules: []  // loyalty OFF

// Builder B3
pages: [home, rewards, cart]  // rewards inclus par erreur
```

**Résultat:**
- ⚠️ "Rewards" apparaît dans nav (Builder décide)
- ❌ Route `/rewards` BLOQUÉE par guard → redirect
- ❌ Blocs loyalty cachés (ModuleAwareBlock)
- 🔔 Utilisateur voit l'erreur de config

**Solution:** Le restaurateur doit retirer "rewards" du Builder B3.

---

### Scénario 4: Module OFF + Builder Exclut

**Config:**
```javascript
// Firestore plan
activeModules: []  // loyalty OFF

// Builder B3
pages: [home, cart]  // Pas de rewards
```

**Résultat:**
- ❌ "Rewards" N'apparaît PAS dans nav
- ❌ Route `/rewards` bloquée si accès direct
- ❌ Blocs loyalty cachés

**Parfait!** Configuration cohérente.

---

## Implémentation

### 1. Navigation (scaffold_with_nav_bar.dart)

```dart
// ✅ CORRECT: Rendre toutes les pages du Builder
_NavigationItemsResult _buildNavigationItems(
  BuildContext context,
  WidgetRef ref,
  List<BuilderPage> builderPages,  // Pages du Builder B3
  bool isAdmin,
  int totalItems,
  RestaurantFeatureFlags? flags,
) {
  final items = <BottomNavigationBarItem>[];
  
  // Pas de filtrage par plan.hasModule()
  // Builder B3 contrôle ce qui apparaît
  for (final page in builderPages) {
    items.add(/* Créer l'item */);
  }
  
  return _NavigationItemsResult(items: items, pages: pages);
}
```

### 2. Route Guards (router_guard.dart)

```dart
// ✅ CORRECT: Bloquer l'accès si module OFF
String? whiteLabelRouteGuard(
  BuildContext context,
  GoRouterState state,
  RestaurantPlanUnified? plan,
) {
  final route = state.uri.path;
  final module = ModuleRouteResolver.resolve(route);
  
  if (module != null && !plan.hasModule(module)) {
    debugPrint('[WL Guard] Blocked: $route (module ${module.code} disabled)');
    return '/menu';  // Redirect
  }
  
  return null;  // Allow
}
```

### 3. Builder Blocks (module_aware_block.dart)

```dart
// ✅ CORRECT: Cacher blocs si module OFF
class ModuleAwareBlock extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isPreview) {
      return _renderBlock(context);  // Preview: toujours visible
    }
    
    final moduleId = block.requiredModule;
    if (moduleId != null && !isModuleEnabled(ref, moduleId)) {
      return const SizedBox.shrink();  // Runtime: cacher si OFF
    }
    
    return _renderBlock(context);
  }
}
```

---

## ❌ Anti-Patterns À Éviter

### ❌ Filtrage des pages par modules

```dart
// MAUVAIS: Ne pas faire
List<BuilderPage> filteredPages = builderPages.where((page) {
  final module = _getModuleForPage(page);
  return module == null || plan.hasModule(module);
}).toList();
```

**Pourquoi?** Enlève le contrôle au Builder B3.

### ❌ Ajout automatique de modules à la nav

```dart
// MAUVAIS: Ne pas faire
if (plan.hasModule(ModuleId.roulette)) {
  navItems.add(/* Ajouter roulette */);
}
```

**Pourquoi?** Le Builder doit décider, pas le module.

### ❌ Modification de l'ordre des pages

```dart
// MAUVAIS: Ne pas faire
pages.sort((a, b) => /* Ordre basé sur modules */);
```

**Pourquoi?** L'ordre vient du Builder B3.

---

## ✅ Patterns Corrects

### ✅ Respecter les décisions du Builder

```dart
// BON: Rendre exactement ce que Builder décide
final navItems = builderPages.map((page) => 
  _createNavItem(page)
).toList();
```

### ✅ Valider l'accès aux routes

```dart
// BON: Guard bloque si module OFF
if (moduleId != null && !plan.hasModule(moduleId)) {
  return redirect;
}
```

### ✅ Cacher les blocs conditionnellement

```dart
// BON: Bloc caché si module OFF
if (!isModuleEnabled(ref, requiredModule)) {
  return SizedBox.shrink();
}
```

---

## Migration depuis l'Ancien Code

### Avant (Incorrect)

```dart
// Filtrage par modules AVANT Builder
final filteredPages = buildPagesFromPlan(builderPages, plan);
final navItems = buildBottomNavItemsFromPlan(filteredPages, plan);
```

### Après (Correct)

```dart
// Builder contrôle, pas de filtrage
final navItems = _buildNavigationItems(
  context,
  ref,
  builderPages,  // Toutes les pages du Builder
  isAdmin,
  totalItems,
  flags,
);
```

---

## Tests de Validation

### Test 1: Builder exclut module
```
Given: loyalty module ON
And: Builder pages = [home, cart]  (pas de rewards)
Then: Nav ne contient pas rewards
```

### Test 2: Builder inclut module OFF
```
Given: loyalty module OFF
And: Builder pages = [home, rewards, cart]
When: User clicks "rewards"
Then: Redirect to /menu with error message
```

### Test 3: Builder contrôle l'ordre
```
Given: Builder pages = [rewards, home, cart]
Then: Nav order = [Rewards, Home, Cart]  (respecte Builder)
```

---

## Logs de Debugging

```dart
// Logs WL pour tracer
debugPrint('[WL NAV] Modules actifs: ${plan.activeModules}');
debugPrint('[WL NAV] Built ${items.length} navigation items from Builder B3');
debugPrint('[WL Guard] Blocked: $route (module disabled)');
debugPrint('[WL Block] Hidden: ${block.type} (module disabled)');
```

---

## Documentation Liée

- `WHITE_LABEL_NAVIGATION_IMPLEMENTATION.md` - Architecture globale
- `scaffold_with_nav_bar.dart` - Implémentation navigation
- `module_aware_block.dart` - Blocs conditionnels
- `router_guard.dart` - Guards de routes
- `register_module_routes.dart` - Enregistrement routes

---

## Résumé

| Composant | Rôle | Contrôle |
|-----------|------|----------|
| **Builder B3** | Maître | Navigation, ordre, présentation |
| **White-Label** | Validateur | Accès routes, visibilité blocs |
| **scaffold_with_nav_bar** | Renderer | Affiche décisions Builder |
| **Guards** | Sécurité | Bloque routes modules OFF |
| **ModuleAwareBlock** | Conditionnement | Cache blocs modules OFF |

---

**✅ RÉSULTAT:**
- Builder contrôle la présentation
- Modules contrôlent l'accès
- Séparation propre des responsabilités
- Pas d'interférence entre les deux systèmes
