# Guide d'Utilisation : moduleEnabledProvider

## 🎯 Objectif

Le `moduleEnabledProvider` est le **provider global unique** pour contrôler l'activation des modules White-Label dans toute l'application Flutter.

Quand un module est désactivé par le SuperAdmin dans `RestaurantPlanUnified`, il doit être **totalement supprimé** pour le restaurant :
- ✅ Côté client
- ✅ Côté admin
- ✅ Côté builder
- ✅ Dans les routes
- ✅ Dans les services runtime

## 📦 Import

```dart
import 'package:pizza_delizza/white_label/runtime/module_enabled_provider.dart';
// OU
import 'package:pizza_delizza/white_label/runtime/runtime.dart'; // Exporte tout
```

## 🔧 Providers Disponibles

### 1. `moduleEnabledProvider` - Provider Principal

Le provider de base pour vérifier si un module est activé.

```dart
final moduleEnabledProvider = Provider.family<bool, ModuleId>((ref, moduleId) { ... });
```

**Usage dans les widgets:**
```dart
class RouletteButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRouletteEnabled = ref.watch(moduleEnabledProvider(ModuleId.roulette));
    
    if (!isRouletteEnabled) {
      return const SizedBox.shrink(); // Masquer le bouton
    }
    
    return ElevatedButton(
      onPressed: () => context.go('/roulette'),
      child: const Text('Roulette'),
    );
  }
}
```

**Usage dans les guards de routes:**
```dart
// Dans router_guard.dart
String? moduleRouteGuard(GoRouterState state, WidgetRef ref, ModuleId moduleId) {
  final isEnabled = ref.read(moduleEnabledProvider(moduleId));
  
  if (!isEnabled) {
    return '/home'; // Rediriger vers home si module désactivé
  }
  
  return null; // Autoriser l'accès
}
```

**Usage dans le Builder B3:**
```dart
class SystemBlockRuntime extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoyaltyEnabled = ref.watch(moduleEnabledProvider(ModuleId.loyalty));
    final isRouletteEnabled = ref.watch(moduleEnabledProvider(ModuleId.roulette));
    
    return Column(
      children: [
        if (isLoyaltyEnabled)
          LoyaltyButton(),
        if (isRouletteEnabled)
          RouletteButton(),
      ],
    );
  }
}
```

### 2. `allModulesEnabledProvider` - Vérifier Plusieurs Modules

Retourne `true` seulement si **TOUS** les modules sont activés.

```dart
final allModulesEnabledProvider = Provider.family<bool, List<ModuleId>>((ref, moduleIds) { ... });
```

**Usage:**
```dart
class CombinedFeature extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEnabled = ref.watch(allModulesEnabledProvider([
      ModuleId.loyalty,
      ModuleId.roulette,
    ]));
    
    if (!allEnabled) {
      return Text('Fonctionnalité complète indisponible');
    }
    
    return CombinedLoyaltyRouletteWidget();
  }
}
```

### 3. `anyModuleEnabledProvider` - Vérifier Au Moins Un Module

Retourne `true` si **AU MOINS UN** module est activé.

```dart
final anyModuleEnabledProvider = Provider.family<bool, List<ModuleId>>((ref, moduleIds) { ... });
```

**Usage:**
```dart
class CheckoutScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDeliveryOption = ref.watch(anyModuleEnabledProvider([
      ModuleId.delivery,
      ModuleId.clickAndCollect,
    ]));
    
    if (!hasDeliveryOption) {
      return Text('Aucune option de retrait disponible');
    }
    
    return CheckoutOptionsWidget();
  }
}
```

### 4. `enabledModulesListProvider` - Liste des Modules Activés

Retourne la liste complète des `ModuleId` activés.

```dart
final enabledModulesListProvider = Provider<List<ModuleId>>((ref) { ... });
```

**Usage:**
```dart
class ModuleStatusScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledModules = ref.watch(enabledModulesListProvider);
    
    return ListView.builder(
      itemCount: enabledModules.length,
      itemBuilder: (context, index) {
        final moduleId = enabledModules[index];
        return ListTile(
          title: Text(moduleId.label),
          subtitle: Text('Code: ${moduleId.code}'),
          leading: Icon(Icons.check_circle, color: Colors.green),
        );
      },
    );
  }
}
```

### 5. `enabledModulesCountProvider` - Nombre de Modules Activés

Retourne le nombre total de modules activés.

```dart
final enabledModulesCountProvider = Provider<int>((ref) { ... });
```

**Usage:**
```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(enabledModulesCountProvider);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Modules Activés', style: Theme.of(context).textTheme.headline6),
            Text('$count', style: Theme.of(context).textTheme.headline3),
          ],
        ),
      ),
    );
  }
}
```

## 🔨 Fonctions Helper (Non-Reactive)

Pour les cas où vous ne pouvez pas utiliser `ref.watch` (callbacks, fonctions utilitaires).

### `isModuleEnabledSync`

```dart
bool isModuleEnabledSync(WidgetRef ref, ModuleId moduleId) { ... }
```

**Usage:**
```dart
void onButtonPressed(WidgetRef ref) {
  if (isModuleEnabledSync(ref, ModuleId.roulette)) {
    // Lancer la roulette
    launchRoulette();
  } else {
    showError('Module roulette désactivé');
  }
}
```

### `areModulesEnabledSync`

```dart
bool areModulesEnabledSync(WidgetRef ref, List<ModuleId> moduleIds) { ... }
```

**Usage:**
```dart
void checkFeatureAvailability(WidgetRef ref) {
  if (areModulesEnabledSync(ref, [ModuleId.loyalty, ModuleId.roulette])) {
    enableCombinedFeature();
  }
}
```

### `isAnyModuleEnabledSync`

```dart
bool isAnyModuleEnabledSync(WidgetRef ref, List<ModuleId> moduleIds) { ... }
```

**Usage:**
```dart
void validateCheckout(WidgetRef ref) {
  if (!isAnyModuleEnabledSync(ref, [ModuleId.delivery, ModuleId.clickAndCollect])) {
    throw Exception('Aucune option de retrait disponible');
  }
}
```

## 📋 Cas d'Usage Complets

### Cas 1: Protéger une Route

```dart
// Dans main.dart
GoRoute(
  path: '/roulette',
  redirect: (context, state) {
    final container = ProviderContainer();
    final isEnabled = container.read(moduleEnabledProvider(ModuleId.roulette));
    
    if (!isEnabled) {
      return '/home';
    }
    return null;
  },
  builder: (context, state) => const RouletteScreen(),
),
```

### Cas 2: Masquer un Élément de Navigation

```dart
class BottomNavBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoyaltyEnabled = ref.watch(moduleEnabledProvider(ModuleId.loyalty));
    
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        if (isLoyaltyEnabled)
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Récompenses'),
      ],
    );
  }
}
```

### Cas 3: Conditionner un Service Runtime

```dart
class OrderService {
  final Ref ref;
  
  OrderService(this.ref);
  
  Future<void> placeOrder(Order order) async {
    // Vérifier si la livraison est disponible
    final hasDelivery = ref.read(moduleEnabledProvider(ModuleId.delivery));
    
    if (order.isDelivery && !hasDelivery) {
      throw Exception('Module livraison désactivé');
    }
    
    // Appliquer les points de fidélité si activé
    final hasLoyalty = ref.read(moduleEnabledProvider(ModuleId.loyalty));
    if (hasLoyalty) {
      await applyLoyaltyPoints(order);
    }
    
    // Traiter la commande
    await processOrder(order);
  }
}
```

### Cas 4: Builder B3 - Bloc Module-Aware

```dart
class ProductListBlockRuntime extends ConsumerWidget {
  final BuilderBlock block;
  
  const ProductListBlockRuntime({required this.block});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPromotionsEnabled = ref.watch(moduleEnabledProvider(ModuleId.promotions));
    final products = ref.watch(productListProvider);
    
    return products.when(
      data: (productList) => GridView.builder(
        itemCount: productList.length,
        itemBuilder: (context, index) {
          final product = productList[index];
          
          return ProductCard(
            product: product,
            // Afficher badge promo seulement si module activé
            showPromoBadge: isPromotionsEnabled && product.hasPromo,
          );
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Erreur: $e'),
    );
  }
}
```

### Cas 5: Admin - Configuration Dynamique

```dart
class AdminModuleSettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledModules = ref.watch(enabledModulesListProvider);
    final allModules = ModuleId.values;
    
    return ListView.builder(
      itemCount: allModules.length,
      itemBuilder: (context, index) {
        final moduleId = allModules[index];
        final isEnabled = enabledModules.contains(moduleId);
        
        return SwitchListTile(
          title: Text(moduleId.label),
          subtitle: Text(moduleId.code),
          value: isEnabled,
          onChanged: (value) {
            // Mettre à jour la configuration dans Firestore
            updateModuleStatus(moduleId, value);
          },
        );
      },
    );
  }
}
```

## ⚡ Performance & Best Practices

### ✅ DO

1. **Utiliser `ref.watch` dans les widgets** pour réactivité automatique
```dart
final isEnabled = ref.watch(moduleEnabledProvider(ModuleId.roulette));
```

2. **Utiliser `ref.read` dans les callbacks** pour éviter rebuilds inutiles
```dart
onPressed: () {
  final isEnabled = ref.read(moduleEnabledProvider(ModuleId.roulette));
  if (isEnabled) { ... }
}
```

3. **Combiner avec conditions** pour UI propre
```dart
if (ref.watch(moduleEnabledProvider(ModuleId.loyalty)))
  LoyaltyWidget(),
```

4. **Utiliser `.family` pour performance**
```dart
// Chaque ModuleId a son propre cache
moduleEnabledProvider(ModuleId.roulette)
moduleEnabledProvider(ModuleId.loyalty)
```

### ❌ DON'T

1. **Ne pas recréer des vérifications manuelles**
```dart
// ❌ Mauvais
final plan = ref.watch(restaurantPlanUnifiedProvider);
final isEnabled = plan.value?.activeModules.contains('roulette') ?? false;

// ✅ Bon
final isEnabled = ref.watch(moduleEnabledProvider(ModuleId.roulette));
```

2. **Ne pas utiliser dans les boucles serrées**
```dart
// ❌ Éviter
for (var i = 0; i < 1000; i++) {
  if (ref.watch(moduleEnabledProvider(ModuleId.loyalty))) { ... }
}

// ✅ Mieux
final isLoyaltyEnabled = ref.watch(moduleEnabledProvider(ModuleId.loyalty));
for (var i = 0; i < 1000; i++) {
  if (isLoyaltyEnabled) { ... }
}
```

3. **Ne pas ignorer les états loading/error**
```dart
// Le provider gère automatiquement:
// - loading → false
// - error → false
// - data → vérification du plan
```

## 🔄 Migration depuis `module_helpers.dart`

### Ancien Code (module_helpers.dart)

```dart
import 'package:pizza_delizza/white_label/runtime/module_helpers.dart';

// Ancien
final isEnabled = isModuleEnabled(ref, ModuleId.roulette);
final isWatchEnabled = watchModuleEnabled(ref, ModuleId.roulette);
```

### Nouveau Code (module_enabled_provider.dart)

```dart
import 'package:pizza_delizza/white_label/runtime/module_enabled_provider.dart';

// Nouveau - Plus simple et plus puissant
final isEnabled = ref.read(moduleEnabledProvider(ModuleId.roulette));
final isWatchEnabled = ref.watch(moduleEnabledProvider(ModuleId.roulette));
```

### Tableau de Correspondance

| Ancien (module_helpers) | Nouveau (module_enabled_provider) |
|-------------------------|-----------------------------------|
| `isModuleEnabled(ref, id)` | `ref.read(moduleEnabledProvider(id))` |
| `watchModuleEnabled(ref, id)` | `ref.watch(moduleEnabledProvider(id))` |
| `areModulesEnabled(ref, [ids])` | `ref.watch(allModulesEnabledProvider([ids]))` |
| `isAnyModuleEnabled(ref, [ids])` | `ref.watch(anyModuleEnabledProvider([ids]))` |
| `getEnabledModules(ref)` | `ref.watch(enabledModulesListProvider)` |
| `isModuleDisabled(ref, id)` | `!ref.watch(moduleEnabledProvider(id))` |

## 📊 Architecture & Dépendances

```
moduleEnabledProvider
  ↓ depends on
restaurantPlanUnifiedProvider
  ↓ depends on
currentRestaurantProvider (overridden by RestaurantScope)
```

**Avantages:**
- ✅ Source de vérité unique
- ✅ Réactivité automatique Riverpod
- ✅ Cache par ModuleId (performance)
- ✅ Type-safe avec enum
- ✅ Dependencies correctement déclarées
- ✅ Gestion automatique loading/error

## 🧪 Tests

```dart
// test/white_label/runtime/module_enabled_provider_test.dart
void main() {
  group('moduleEnabledProvider', () {
    test('returns true when module is in activeModules', () {
      final container = ProviderContainer(
        overrides: [
          restaurantPlanUnifiedProvider.overrideWithValue(
            AsyncValue.data(RestaurantPlanUnified(
              restaurantId: 'test',
              name: 'Test',
              slug: 'test',
              activeModules: ['roulette', 'loyalty'],
            )),
          ),
        ],
      );
      
      final isRouletteEnabled = container.read(moduleEnabledProvider(ModuleId.roulette));
      final isLoyaltyEnabled = container.read(moduleEnabledProvider(ModuleId.loyalty));
      final isDeliveryEnabled = container.read(moduleEnabledProvider(ModuleId.delivery));
      
      expect(isRouletteEnabled, true);
      expect(isLoyaltyEnabled, true);
      expect(isDeliveryEnabled, false);
    });
    
    test('returns false when plan is loading', () {
      final container = ProviderContainer(
        overrides: [
          restaurantPlanUnifiedProvider.overrideWithValue(
            const AsyncValue.loading(),
          ),
        ],
      );
      
      final isEnabled = container.read(moduleEnabledProvider(ModuleId.roulette));
      expect(isEnabled, false);
    });
  });
}
```

## 📚 Références

- **Source:** `lib/white_label/runtime/module_enabled_provider.dart`
- **Export:** `lib/white_label/runtime/runtime.dart`
- **Documentation:** Ce fichier
- **Modèle:** `lib/white_label/restaurant/restaurant_plan_unified.dart`
- **Provider Plan:** `lib/src/providers/restaurant_plan_provider.dart`

## 🎓 Conclusion

Le `moduleEnabledProvider` est maintenant la **seule et unique source de vérité** pour tous les contrôles de modules dans l'application.

**Utilisez-le partout:**
- ✅ Widgets client
- ✅ Screens admin
- ✅ Blocs Builder B3
- ✅ Guards de routes
- ✅ Services runtime

**Résultat:** Contrôle strict et cohérent des modules White-Label dans toute l'application. ✨
