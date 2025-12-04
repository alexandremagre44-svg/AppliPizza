# RestaurantScope Implementation

## 🎯 Objectif
Introduire une abstraction globale `RestaurantScope` permettant à l'application de savoir pour quel restaurant elle tourne. Le restaurant actif est disponible partout via Riverpod.

## ✅ Implémentation Complète

### 1. Widget RestaurantScope créé

**Fichier** : `lib/src/widgets/restaurant_scope.dart`

```dart
class RestaurantScope extends ConsumerWidget {
  final String restaurantId;
  final String? restaurantName;
  final Widget child;

  const RestaurantScope({
    super.key,
    required this.restaurantId,
    this.restaurantName,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        currentRestaurantProvider.overrideWithValue(
          RestaurantConfig(
            id: restaurantId,
            name: restaurantName ?? 'Restaurant $restaurantId',
          ),
        ),
      ],
      child: child,
    );
  }
}
```

### 2. Modèle RestaurantConfig existant

**Fichier** : `lib/src/models/restaurant_config.dart` (déjà existant)

```dart
class RestaurantConfig {
  final String id;
  final String name;
  const RestaurantConfig({required this.id, required this.name});
}
```

### 3. Provider global existant

**Fichier** : `lib/src/providers/restaurant_provider.dart` (déjà existant)

```dart
final currentRestaurantProvider = Provider<RestaurantConfig>((ref) {
  return const RestaurantConfig(
    id: 'delizza',
    name: 'Delizza Default',
  );
});
```

### 4. main.dart modifié

**Changements dans** : `lib/main.dart`

**Avant** :
```dart
runApp(
  ProviderScope(
    overrides: [
      currentRestaurantProvider.overrideWithValue(
        RestaurantConfig(id: appId, name: appName),
      ),
    ],
    child: const MyApp(),
  ),
);
```

**Après** :
```dart
runApp(
  ProviderScope(
    child: RestaurantScope(
      restaurantId: appId,
      restaurantName: appName,
      child: const MyApp(),
    ),
  ),
);
```

## ✅ Vérification des Services

Tous les services mis à jour utilisent `currentRestaurantProvider` :

1. **PopupService** via `popupServiceProvider`
   ```dart
   final config = ref.watch(currentRestaurantProvider);
   return PopupService(appId: config.id);
   ```

2. **BannerService** via `bannerServiceProvider`
   ```dart
   final config = ref.watch(currentRestaurantProvider);
   return BannerService(appId: config.id);
   ```

3. **LoyaltySettingsService** via `loyaltySettingsServiceProvider`
   ```dart
   final config = ref.watch(currentRestaurantProvider);
   return LoyaltySettingsService(appId: config.id);
   ```

## 🎯 Résultat

✅ **Toute l'application peut désormais fonctionner pour n'importe quel restaurant ID**

### Architecture

```
ProviderScope (root)
  └── RestaurantScope (restaurantId: "delizza")
      └── MyApp
          └── MaterialApp
              └── Tous les widgets et services
```

### Utilisation dans les services

Tout service ou widget peut accéder au restaurant actif :

```dart
// Dans un ConsumerWidget ou provider
final restaurantConfig = ref.watch(currentRestaurantProvider);
final restaurantId = restaurantConfig.id;
final restaurantName = restaurantConfig.name;
```

### Configuration

Le restaurant actif est configuré via les variables d'environnement :
- `APP_ID` : ID du restaurant (défaut: 'delizza')
- `APP_NAME` : Nom du restaurant (défaut: 'Delizza Default')

### Flexibilité

Pour changer de restaurant, il suffit de changer le `restaurantId` passé à `RestaurantScope` :

```dart
RestaurantScope(
  restaurantId: 'autre-restaurant',
  restaurantName: 'Autre Restaurant',
  child: MyApp(),
)
```

Tous les services se reconfigureront automatiquement pour pointer vers :
- `restaurants/autre-restaurant/pizzas`
- `restaurants/autre-restaurant/orders`
- `restaurants/autre-restaurant/builder_settings`
- etc.

## 📊 Impact

- **Isolation complète** : Chaque restaurant a ses propres données
- **Multi-tenant ready** : Support natif pour plusieurs restaurants
- **Configuration centralisée** : Un seul point pour définir le restaurant actif
- **Type-safe** : Utilisation de Riverpod pour la gestion d'état
- **Flexible** : Possibilité de changer dynamiquement de restaurant

---

**Status** : ✅ IMPLÉMENTÉ ET VÉRIFIÉ
