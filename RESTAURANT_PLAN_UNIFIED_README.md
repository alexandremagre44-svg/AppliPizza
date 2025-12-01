# RestaurantPlanUnified - Documentation

## Vue d'ensemble

Le modèle `RestaurantPlanUnified` centralise toutes les configurations d'un restaurant dans un seul document Firestore, remplaçant les multiples documents éparpillés précédemment.

## Architecture

### Structure Firestore

```
restaurants/{restaurantId}/
  ├── (document principal) - métadonnées du restaurant
  └── plan/
      ├── config (legacy - RestaurantPlan)
      └── unified (nouveau - RestaurantPlanUnified)
```

### Modèle de données

Le `RestaurantPlanUnified` contient :

#### A. Informations générales
- `restaurantId`: ID unique du restaurant
- `name`: Nom du restaurant
- `slug`: Slug URL-friendly
- `templateId`: ID du template utilisé (optionnel)
- `createdAt`: Date de création
- `updatedAt`: Date de dernière mise à jour

#### B. Modules activés
- `activeModules`: Liste des codes de modules activés (ex: `["delivery", "loyalty", "roulette"]`)

#### C. Configurations consolidées
- `branding`: Configuration visuelle (couleurs, logos)
- `delivery`: Configuration du module livraison
- `ordering`: Configuration du module commandes
- `clickAndCollect`: Configuration Click & Collect
- `loyalty`: Configuration fidélité
- `promotions`: Configuration promotions
- `roulette`: Configuration roulette marketing
- `newsletter`: Configuration newsletter
- `theme`: Configuration thème
- `pages`: Configuration pages builder
- `tablets`: Configuration tablettes (cuisine/staff)

## Utilisation

### Côté SuperAdmin

#### Créer un restaurant avec le plan unifié

```dart
final planService = RestaurantPlanService();

await planService.saveFullRestaurantCreation(
  restaurantId: 'restaurant_123',
  name: 'Pizza Delizza',
  slug: 'pizza-delizza',
  enabledModuleIds: [ModuleId.delivery, ModuleId.loyalty],
  brand: {
    'brandName': 'Pizza Delizza',
    'primaryColor': '#FF5733',
    'logoUrl': 'https://...',
  },
  templateId: 'template_classic',
);
```

#### Charger et modifier le plan unifié

```dart
final plan = await planService.loadUnifiedPlan('restaurant_123');

if (plan != null) {
  // Modifier le plan
  final updatedPlan = plan.copyWith(
    activeModules: [...plan.activeModules, 'roulette'],
    roulette: RouletteModuleConfig(
      enabled: true,
      settings: {'maxSpinsPerDay': 3},
    ),
  );
  
  await planService.saveUnifiedPlan(updatedPlan);
}
```

#### Écouter les changements en temps réel

```dart
planService.watchUnifiedPlan('restaurant_123').listen((plan) {
  if (plan != null) {
    print('Plan updated: ${plan.name}');
  }
});
```

### Côté Client (Application)

#### Provider pour le plan unifié

```dart
// Dans un widget
final planAsync = ref.watch(restaurantPlanUnifiedProvider);

planAsync.when(
  data: (plan) {
    if (plan != null) {
      return Text('Restaurant: ${plan.name}');
    }
    return Text('Pas de plan');
  },
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Erreur: $err'),
);
```

#### Vérifier si un module est activé

```dart
// Méthode 1: Via feature flags
final flags = ref.watch(restaurantFeatureFlagsUnifiedProvider);
if (flags?.has(ModuleId.delivery) ?? false) {
  // Module livraison activé
}

// Méthode 2: Provider dédié
final isDeliveryEnabled = ref.watch(isDeliveryEnabledUnifiedProvider);
if (isDeliveryEnabled) {
  // Afficher l'interface de livraison
}
```

#### Accéder à la configuration d'un module

```dart
// Configuration de livraison
final deliveryConfig = ref.watch(deliveryConfigUnifiedProvider);
if (deliveryConfig != null && deliveryConfig.enabled) {
  final settings = deliveryConfig.settings;
  // Utiliser les paramètres de livraison
}

// Configuration de branding
final branding = ref.watch(brandingConfigUnifiedProvider);
if (branding != null) {
  final primaryColor = branding.primaryColor;
  final logoUrl = branding.logoUrl;
  // Appliquer le branding
}
```

## Migration

### Depuis l'ancien RestaurantPlan

Le nouveau modèle coexiste avec l'ancien :
- Les anciens documents `restaurants/{id}/plan/config` restent inchangés
- Les nouveaux documents sont dans `restaurants/{id}/plan/unified`
- Les providers existants continuent de fonctionner

### Étapes de migration (future)

1. Phase 1 (actuelle): Coexistence des deux modèles
2. Phase 2: Migration des données existantes vers le format unifié
3. Phase 3: Dépréciation de l'ancien format
4. Phase 4: Suppression de l'ancien format

## Avantages

1. **Centralisation**: Toute la configuration dans un seul document
2. **Performance**: Moins de requêtes Firestore
3. **Typage fort**: Configurations typées par module
4. **Extensibilité**: Facile d'ajouter de nouveaux modules
5. **Rétrocompatibilité**: Coexiste avec l'ancien système

## Providers Riverpod disponibles

### Providers principaux
- `restaurantPlanUnifiedProvider`: Plan complet
- `restaurantFeatureFlagsUnifiedProvider`: Feature flags

### Providers par module
- `deliveryConfigUnifiedProvider`: Config livraison
- `orderingConfigUnifiedProvider`: Config commandes
- `loyaltyConfigUnifiedProvider`: Config fidélité
- `rouletteConfigUnifiedProvider`: Config roulette
- `promotionsConfigUnifiedProvider`: Config promotions
- `brandingConfigUnifiedProvider`: Config branding

### Providers de vérification
- `isDeliveryEnabledUnifiedProvider`: Livraison activée?
- `isLoyaltyEnabledUnifiedProvider`: Fidélité activée?
- `isRouletteEnabledUnifiedProvider`: Roulette activée?
- `isPromotionsEnabledUnifiedProvider`: Promotions activées?

## Notes importantes

1. **Pas de modification des modules existants**: Les services clients (loyalty_service, delivery_provider, etc.) n'ont pas été modifiés
2. **Builder B3**: Sera connecté en Phase 3
3. **Backward compatibility**: L'ancien RestaurantPlan reste fonctionnel
4. **Services legacy**: Les méthodes `loadPlan`, `savePlan`, etc. continuent de fonctionner

## Fichiers modifiés

1. ✅ `lib/white_label/restaurant/restaurant_plan_unified.dart` (nouveau)
2. ✅ `lib/superadmin/services/restaurant_plan_service.dart` (mis à jour)
3. ✅ `lib/src/services/restaurant_plan_runtime_service.dart` (mis à jour)
4. ✅ `lib/src/providers/restaurant_plan_provider.dart` (mis à jour)
5. ✅ `lib/white_label/restaurant/restaurant_feature_flags.dart` (mis à jour)

## Prochaines étapes

1. Connecter le Builder B3 au plan unifié (Phase 3)
2. Migrer les restaurants existants vers le format unifié
3. Mettre à jour les interfaces d'administration pour utiliser le plan unifié
4. Ajouter des validations et des contraintes de cohérence
