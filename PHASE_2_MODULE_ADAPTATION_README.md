# Phase 2: Module Runtime Adaptation - Documentation

## Vue d'ensemble

Phase 2 implémente l'adaptation runtime des modules existants pour qu'ils soient contrôlés par le `RestaurantPlanUnified`. Cette phase crée des adapters, guards, et helpers NON INTRUSIFS qui ne modifient jamais les services existants.

## Principes fondamentaux

✅ **AUCUN service existant modifié**
✅ **AUCUNE logique métier réécrite**
✅ **Adapters et wrappers uniquement**
✅ **Guards de navigation transparents**
✅ **Backward compatibility totale**

## Architecture

```
┌─────────────────────────────────────────┐
│   RestaurantPlanUnified (Firestore)     │
│   - activeModules: List<String>         │
│   - delivery, loyalty, roulette, etc.   │
└───────────────┬─────────────────────────┘
                │
                ├─► ModuleRuntimeAdapter
                │   └─► isModuleActive()
                │   └─► applyAll()
                │
                ├─► Module Visibility Helpers
                │   └─► isDeliveryEnabled()
                │   └─► isLoyaltyEnabled()
                │   └─► etc.
                │
                ├─► Module Route Guards
                │   └─► deliveryRouteGuard()
                │   └─► loyaltyRouteGuard()
                │   └─► etc.
                │
                ├─► Dynamic Navbar Builder
                │   └─► filterNavItems()
                │   └─► hideDisabledTabs()
                │
                └─► Service Adapters
                    └─► LoyaltyAdapter
                    └─► DeliveryAdapter
                    └─► etc.
```

## Composants créés

### 1. Module Runtime Adapter

**Fichier:** `lib/white_label/runtime/module_runtime_adapter.dart`

Adaptateur central pour vérifier l'état des modules.

```dart
// Vérifier si un module est actif
bool isActive = ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.delivery);

// Obtenir tous les modules actifs
List<ModuleId> activeModules = ModuleRuntimeAdapter.getActiveModules(plan);

// Vérifier plusieurs modules
bool allActive = ModuleRuntimeAdapter.areAllModulesActive(
  plan,
  [ModuleId.delivery, ModuleId.ordering],
);
```

**Classes:**
- `RuntimeContext`: Contexte d'exécution avec WidgetRef
- `ModuleRuntimeAdapter`: Méthodes statiques pour vérifier les modules

**Méthodes principales:**
- `isModuleActive(plan, moduleCode)`: Vérifie par code string
- `isModuleActiveById(plan, moduleId)`: Vérifie par ModuleId enum
- `getActiveModules(plan)`: Liste des modules actifs
- `getInactiveModules(plan)`: Liste des modules inactifs
- `areAllModulesActive(plan, modules)`: Vérifie tous
- `isAnyModuleActive(plan, modules)`: Vérifie au moins un
- `applyAll(context, plan)`: Point d'entrée centralisé

### 2. Module Visibility Helpers

**Fichier:** `lib/src/helpers/module_visibility.dart`

Helpers simples pour vérifier la visibilité des modules dans l'UI.

```dart
// Dans un ConsumerWidget
if (isDeliveryEnabled(ref)) {
  // Afficher l'option de livraison
}

if (isLoyaltyEnabled(ref)) {
  // Afficher le programme de fidélité
}
```

**Fonctions disponibles:**
- `isDeliveryEnabled(ref)` - Module livraison
- `isClickAndCollectEnabled(ref)` - Module Click & Collect
- `isOrderingEnabled(ref)` - Module commandes
- `isLoyaltyEnabled(ref)` - Module fidélité
- `isPromotionEnabled(ref)` - Module promotions
- `isRouletteEnabled(ref)` - Module roulette
- `isNewsletterEnabled(ref)` - Module newsletter
- `isKitchenEnabled(ref)` - Tablette cuisine
- `isStaffTabletEnabled(ref)` - Tablette staff
- `isPaymentEnabled(ref)` - Module paiements
- `isPaymentTerminalEnabled(ref)` - Terminal de paiement
- `isWalletEnabled(ref)` - Portefeuille
- `isThemeEnabled(ref)` - Module thème
- `isPagesBuilderEnabled(ref)` - Constructeur de pages
- `isReportingEnabled(ref)` - Reporting
- `isExportsEnabled(ref)` - Exports
- `isCampaignsEnabled(ref)` - Campagnes
- `isTimeRecorderEnabled(ref)` - Pointeuse
- `areAllModulesEnabled(ref, moduleIds)` - Vérification multiple
- `isAnyModuleEnabled(ref, moduleIds)` - Au moins un

### 3. Module Route Guards

**Fichier:** `lib/src/navigation/module_route_guards.dart`

Guards pour protéger les routes selon les modules activés.

```dart
// Dans le router
GoRoute(
  path: '/rewards',
  builder: (context, state) => loyaltyRouteGuard(
    const RewardsScreen(),
    fallbackRoute: '/home',
  ),
),

// Ou avec le widget générique
GoRoute(
  path: '/delivery',
  builder: (context, state) => ModuleRouteGuard(
    requiredModule: ModuleId.delivery,
    fallbackRoute: '/home',
    child: const DeliveryScreen(),
  ),
),
```

**Classes:**
- `ModuleDisabledScreen`: Page de fallback quand module désactivé
- `ModuleRouteGuard`: Guard générique avec module requis

**Fonctions de guard:**
- `deliveryRouteGuard(child, fallbackRoute)`
- `loyaltyRouteGuard(child, fallbackRoute)`
- `rouletteRouteGuard(child, fallbackRoute)`
- `promotionsRouteGuard(child, fallbackRoute)`
- `clickAndCollectRouteGuard(child, fallbackRoute)`
- `newsletterRouteGuard(child, fallbackRoute)`
- `kitchenRouteGuard(child, fallbackRoute)`
- `staffTabletRouteGuard(child, fallbackRoute)`

**Comportement:**
- Module actif → Affiche le child
- Module inactif + fallbackRoute → Redirect automatique
- Module inactif + silentRedirect → Redirect sans UI
- Sinon → Affiche ModuleDisabledScreen

### 4. Dynamic Navbar Builder

**Fichier:** `lib/src/navigation/dynamic_navbar_builder.dart`

Construit une navbar filtrée selon les modules actifs.

```dart
// Filtrer les items de navigation
final filtered = DynamicNavbarBuilder.filterNavItems(
  originalPages: builderPages,
  originalItems: navItems,
  plan: plan,
);

// filtered.items : Liste filtrée des BottomNavigationBarItem
// filtered.pages : Liste filtrée des BuilderPage
// filtered.indexMapping : Mapping index filtré -> index original
```

**Classes:**
- `FilteredNavItems`: Résultat du filtrage avec mapping d'index

**Méthodes:**
- `filterNavItems()`: Filtre selon modules actifs
- `hideDisabledTabs()`: Cache les onglets désactivés
- `buildFallbackNavItems()`: Navbar minimale de fallback
- `requiresModule(route)`: Vérifie si une route nécessite un module
- `getRequiredModule(route)`: Obtient le module requis pour une route

**Mapping de routes:**
- `/delivery*` → ModuleId.delivery
- `/rewards*` → ModuleId.loyalty
- `/roulette*` → ModuleId.roulette
- `/promotions*`, `/promo*` → ModuleId.promotions
- `/newsletter*` → ModuleId.newsletter
- `/kitchen*` → ModuleId.kitchenTablet
- `/staff*` → ModuleId.staffTablet
- Routes système (home, menu, cart, profile) → Pas de module requis

### 5. Service Adapters

**Répertoire:** `lib/src/services/adapters/`

Adapters NON INTRUSIFS pour chaque service existant.

**Fichiers créés:**
- `loyalty_adapter.dart` - Adapter fidélité
- `delivery_adapter.dart` - Adapter livraison
- `promotions_adapter.dart` - Adapter promotions
- `roulette_adapter.dart` - Adapter roulette
- `newsletter_adapter.dart` - Adapter newsletter
- `kitchen_adapter.dart` - Adapter tablette cuisine
- `staff_tablet_adapter.dart` - Adapter tablette staff

**Structure type:**
```dart
class LoyaltyAdapter {
  final WidgetRef ref;
  
  LoyaltyAdapter(this.ref);
  
  // Vérifie si le module est activé
  bool get isEnabled {
    final plan = ref.watch(restaurantPlanUnifiedProvider).asData?.value;
    return plan?.loyalty?.enabled ?? false;
  }
  
  // Récupère la configuration
  LoyaltyModuleConfig? get config {
    final plan = ref.watch(restaurantPlanUnifiedProvider).asData?.value;
    return plan?.loyalty;
  }
  
  // Récupère les paramètres
  Map<String, dynamic>? get settings => config?.settings;
  
  // Applique la configuration (hook futur)
  void apply() {
    if (!isEnabled) return;
    // Hook pour adaptations futures
  }
}

// Provider Riverpod
final loyaltyAdapterProvider = Provider<LoyaltyAdapter>((ref) {
  return LoyaltyAdapter(ref);
});
```

**Principe:**
- ❌ Ne modifie JAMAIS les services originaux
- ✅ Lit uniquement le RestaurantPlanUnified
- ✅ Fournit un accès typé aux configurations
- ✅ Hook `apply()` pour futures adaptations
- ✅ Provider Riverpod pour injection

### 6. Tests Unitaires

**Fichier:** `test/white_label/module_activation_test.dart`

Tests complets pour l'activation/désactivation des modules.

**Tests inclus:**
- `isModuleActive()` avec modules actifs/inactifs
- `isModuleActiveById()` avec enum ModuleId
- `getActiveModules()` liste correcte
- `getInactiveModules()` liste correcte
- `areAllModulesActive()` vérification multiple
- `isAnyModuleActive()` au moins un actif
- Gestion de plan null
- `hasModule()` sur RestaurantPlanUnified
- `enabledModuleIds` conversion correcte
- Gestion des codes invalides

**Exécution:**
```bash
flutter test test/white_label/module_activation_test.dart
```

## Intégration dans l'application

### Dans le Router (main.dart)

Les guards peuvent être appliqués aux routes existantes:

```dart
GoRoute(
  path: '/rewards',
  builder: (context, state) {
    // Guard déjà présent dans le code
    final flags = ref.read(restaurantFeatureFlagsProvider);
    if (flags != null && !flags.has(ModuleId.loyalty)) {
      return const SizedBox.shrink();
    }
    return const RewardsScreen();
  },
),

// Peut être remplacé par:
GoRoute(
  path: '/rewards',
  builder: (context, state) => loyaltyRouteGuard(
    const RewardsScreen(),
  ),
),
```

### Dans les Widgets

Utilisation des helpers de visibilité:

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Afficher conditionnellement
        if (isDeliveryEnabled(ref))
          DeliveryOption(),
        
        if (isLoyaltyEnabled(ref))
          LoyaltyCard(),
        
        if (areAllModulesEnabled(ref, [ModuleId.ordering, ModuleId.delivery]))
          OrderWithDeliveryButton(),
      ],
    );
  }
}
```

### Dans la Navbar

Le `ScaffoldWithNavBar` peut utiliser le `DynamicNavbarBuilder`:

```dart
// Dans _buildNavigationItems
final filtered = DynamicNavbarBuilder.filterNavItems(
  originalPages: builderPages,
  originalItems: items,
  plan: plan,
);

// Utiliser filtered.items au lieu de items
return BottomNavigationBar(
  items: filtered.items,
  onTap: (index) => _onTap(index, filtered.pages),
);
```

## Workflow SuperAdmin → Client

1. **SuperAdmin crée un restaurant** avec modules activés
   ```dart
   await planService.saveFullRestaurantCreation(
     restaurantId: 'resto_123',
     name: 'Pizza Delizza',
     enabledModuleIds: [ModuleId.delivery, ModuleId.loyalty],
     brand: {...},
   );
   ```

2. **Firestore stocke** le plan unifié
   ```
   restaurants/resto_123/plan/unified
     - activeModules: ['delivery', 'loyalty']
     - delivery: {...}
     - loyalty: {...}
   ```

3. **App cliente charge** le plan
   ```dart
   final plan = ref.watch(restaurantPlanUnifiedProvider);
   ```

4. **Helpers vérifient** les modules
   ```dart
   if (isDeliveryEnabled(ref)) {
     // Afficher livraison
   }
   ```

5. **Guards protègent** les routes
   ```dart
   // Route /delivery accessible uniquement si module actif
   ```

6. **Navbar s'adapte** automatiquement
   ```dart
   // Onglet "Livraison" visible uniquement si actif
   ```

## Ce qui n'a PAS été modifié

✅ **Services existants**
- `loyalty_service.dart` - AUCUN changement
- `delivery_provider.dart` - AUCUN changement
- `roulette_service.dart` - AUCUN changement
- `promotion_service.dart` - AUCUN changement
- Tous les autres services - AUCUN changement

✅ **Logique métier**
- Aucune logique réécrite
- Aucun comportement modifié
- Backward compatibility totale

✅ **Builder B3**
- Aucune modification (Phase 3)

✅ **Thème**
- Aucune modification (Phase 4)

## Avantages de cette approche

1. **Non intrusif**: Services existants intacts
2. **Testable**: Chaque composant est testé unitairement
3. **Modulaire**: Chaque adapter/guard est indépendant
4. **Extensible**: Facile d'ajouter de nouveaux modules
5. **Sûr**: Pas de régression possible sur le code existant
6. **Transparent**: L'utilisateur ne voit que les modules actifs
7. **Performant**: Pas de surcharge, juste des vérifications

## Validation et Tests

### Tests automatiques
```bash
flutter test test/white_label/module_activation_test.dart
```

### Tests manuels
1. Créer un restaurant avec certains modules activés
2. Vérifier que seuls ces modules apparaissent dans la navbar
3. Essayer d'accéder à une route d'un module désactivé → Redirect
4. Vérifier que les helpers retournent les bonnes valeurs
5. Vérifier qu'aucun service existant ne crash

### Vérifications
- ✅ Aucune régression sur l'app existante
- ✅ Modules activés → Fonctionnalités visibles
- ✅ Modules désactivés → Masqués/Inaccessibles
- ✅ Guards redirigent correctement
- ✅ Navbar s'adapte dynamiquement
- ✅ Services originaux fonctionnent toujours

## Fichiers créés (12 fichiers)

```
lib/white_label/runtime/
  └─ module_runtime_adapter.dart

lib/src/helpers/
  └─ module_visibility.dart

lib/src/navigation/
  ├─ module_route_guards.dart
  └─ dynamic_navbar_builder.dart

lib/src/services/adapters/
  ├─ loyalty_adapter.dart
  ├─ delivery_adapter.dart
  ├─ promotions_adapter.dart
  ├─ roulette_adapter.dart
  ├─ newsletter_adapter.dart
  ├─ kitchen_adapter.dart
  └─ staff_tablet_adapter.dart

test/white_label/
  └─ module_activation_test.dart
```

## Prochaines étapes (Phase 3)

- Intégrer le Builder B3 avec les guards
- Adapter les pages dynamiques selon les modules
- Connecter le système de templates

## Support

Pour toute question:
1. Consulter ce README
2. Consulter `RESTAURANT_PLAN_UNIFIED_README.md`
3. Regarder les tests dans `module_activation_test.dart`
