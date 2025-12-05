# White-Label Navigation Implementation

## Vue d'ensemble

Ce document décrit l'implémentation complète du système de navigation white-label qui permet à chaque restaurant d'avoir ses propres modules activés/désactivés, son arborescence de routes, et ses restrictions d'accès.

## Architecture

### 1. Module Access Level (`module_category.dart`)

Ajout d'un nouveau enum `ModuleAccessLevel` pour définir les niveaux d'accès :

```dart
enum ModuleAccessLevel {
  client,   // Accessible par tous les utilisateurs
  staff,    // Réservé au personnel
  admin,    // Réservé aux administrateurs
  kitchen,  // Réservé au personnel de cuisine
  system,   // Module système sans restriction spéciale
}
```

### 2. Module Navigation Registry (`module_navigation_registry.dart`)

Un registry centralisé pour gérer toutes les routes des modules :

**Fonctionnalités principales :**
- `registerModuleRoutes()` - Enregistrer les routes d'un module
- `getRoutesFor()` - Récupérer les routes d'un module
- `getAllRegisteredModules()` - Lister tous les modules enregistrés
- `getRoutesByAccessLevel()` - Filtrer par niveau d'accès
- `getSummary()` - Statistiques sur les routes enregistrées

### 3. Module Route Resolver (`module_route_resolver.dart`)

Améliorations pour résoudre les routes dynamiquement :

**Nouvelles fonctions :**
- `resolveRoutesFor(RestaurantPlanUnified plan)` - Résout toutes les routes pour un plan restaurant
- `resolveImplementedRoutesFor(plan)` - Ne retourne que les routes des modules implémentés
- `getEnabledModulesWithRoutes(plan)` - Liste les modules activés qui ont des routes

### 4. Module Guards (`module_guards.dart`)

Guards génériques pour protéger les routes :

**Guards disponibles :**
- `ModuleGuard` - Vérifie si un module est activé
- `AdminGuard` - Vérifie si l'utilisateur est admin
- `StaffGuard` - Vérifie si l'utilisateur est staff
- `KitchenGuard` - Vérifie l'accès cuisine
- `ModuleAndRoleGuard` - Combine module + rôle

**Exemple d'utilisation :**
```dart
GoRoute(
  path: '/rewards',
  builder: (context, state) {
    return ModuleGuard(
      module: ModuleId.loyalty,
      child: const RewardsScreen(),
    );
  },
)
```

### 5. Module Helpers (`module_helpers.dart`)

Helpers pour vérifier le statut des modules dans les widgets :

**Fonctions principales :**
- `isModuleEnabled(ref, moduleId)` - Vérifie si un module est activé
- `watchModuleEnabled(ref, moduleId)` - Version réactive pour les widgets
- `areModulesEnabled(ref, modules)` - Vérifie plusieurs modules
- `isAnyModuleEnabled(ref, modules)` - Vérifie si au moins un module est activé
- `getEnabledModules(ref)` - Liste tous les modules activés

**Utilisation dans le Builder B3 :**
```dart
// Masquer un bloc si le module est désactivé
if (!isModuleEnabled(ref, ModuleId.roulette)) {
  return const SizedBox.shrink();
}
```

### 6. Register Module Routes (`register_module_routes.dart`)

Centralisation de l'enregistrement des routes :

**Modules enregistrés :**
- Roulette (`/roulette`)
- Loyalty (`/rewards`)
- Delivery (`/delivery`, `/delivery/area`, `/order/:id/tracking`)
- Kitchen Tablet (`/kitchen`)
- Staff Tablet (`/pos`, `/staff-tablet/*`)

**Utilisation :**
```dart
void main() async {
  // Enregistrer toutes les routes au démarrage
  registerAllModuleRoutes();
  runApp(MyApp());
}
```

## Intégration dans main.dart

### Modifications apportées

1. **Initialisation au démarrage :**
```dart
void main() async {
  registerAllModuleRoutes(); // Nouveau
  // ... reste du code
}
```

2. **Routes protégées par guards :**

Avant :
```dart
GoRoute(
  path: '/rewards',
  builder: (context, state) => const RewardsScreen(),
)
```

Après :
```dart
GoRoute(
  path: '/rewards',
  builder: (context, state) {
    return ModuleGuard(
      module: ModuleId.loyalty,
      child: const RewardsScreen(),
    );
  },
)
```

3. **Routes combinant module + rôle :**
```dart
GoRoute(
  path: '/kitchen',
  builder: (context, state) {
    return ModuleAndRoleGuard(
      module: ModuleId.kitchen_tablet,
      requiresKitchen: true,
      child: const KitchenScreen(),
    );
  },
)
```

## Stratégie de protection des routes

### Double protection

1. **Niveau Global** - `whiteLabelRouteGuard` dans le router
   - Vérifie toutes les routes contre les modules actifs
   - Redirige vers `/home` si le module est désactivé
   - S'exécute avant toute navigation

2. **Niveau Local** - `ModuleGuard` sur chaque route
   - Vérification supplémentaire au niveau du widget
   - Permet un contrôle granulaire
   - Affiche un message d'erreur approprié

### Avantages de cette approche

✅ **Pas de problèmes de timing** - Toutes les routes restent dans le router
✅ **Protection robuste** - Double couche de sécurité
✅ **Backward compatible** - Fonctionne même si le plan n'est pas chargé
✅ **Flexible** - Facile d'ajouter de nouvelles routes
✅ **Maintenable** - Code centralisé et organisé

## Utilisation pour les développeurs

### Ajouter un nouveau module avec routes

1. **Créer les routes dans `register_module_routes.dart` :**

```dart
void _registerMyModuleRoutes() {
  ModuleNavigationRegistry.registerModuleRoutes(
    ModuleId.myModule,
    [
      ModuleRouteDefinition(
        route: GoRoute(
          path: '/my-module',
          builder: (context, state) => const MyModuleScreen(),
        ),
        moduleId: ModuleId.myModule,
        accessLevel: ModuleAccessLevel.client,
        isMainRoute: true,
      ),
    ],
  );
}
```

2. **Appeler la fonction d'enregistrement :**

```dart
void registerAllModuleRoutes() {
  _registerMyModuleRoutes(); // Ajouter ici
  // ... autres modules
}
```

3. **Ajouter la route dans main.dart :**

```dart
GoRoute(
  path: '/my-module',
  builder: (context, state) {
    return ModuleGuard(
      module: ModuleId.myModule,
      child: const MyModuleScreen(),
    );
  },
)
```

### Utiliser dans le Builder B3

```dart
// Dans un bloc custom du builder
class MyModuleBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // Masquer si le module est désactivé
        if (!isModuleEnabled(ref, ModuleId.myModule)) {
          return const SizedBox.shrink();
        }
        
        return ElevatedButton(
          onPressed: () => context.go('/my-module'),
          child: const Text('Ouvrir Mon Module'),
        );
      },
    );
  }
}
```

## Tests

Des tests ont été ajoutés dans `test/white_label/module_guards_test.dart` pour valider :

- ✅ L'enregistrement des routes dans le registry
- ✅ La résolution des routes pour un plan donné
- ✅ La vérification des modules activés
- ✅ L'identification des routes système
- ✅ Les helpers de modules

## Migration depuis l'ancien système

### Avant (routes hardcodées)
```dart
GoRoute(
  path: '/roulette',
  builder: (context, state) {
    return rouletteRouteGuard(const RouletteScreen());
  },
)
```

### Après (avec ModuleGuard)
```dart
GoRoute(
  path: '/roulette',
  builder: (context, state) {
    return ModuleGuard(
      module: ModuleId.roulette,
      child: const RouletteScreen(),
    );
  },
)
```

### Changements clés
- ❌ Plus de fonctions `xxxRouteGuard` dans `module_route_guards.dart`
- ✅ Utilisation de `ModuleGuard` générique
- ✅ Support pour les rôles avec `ModuleAndRoleGuard`
- ✅ Logs détaillés pour le debugging

## Compatibilité

### Rétrocompatibilité

- ✅ Fonctionne sans plan chargé (fallback gracieux)
- ✅ Les anciennes routes continuent de fonctionner
- ✅ Pas de breaking changes pour les modules existants
- ✅ Les écrans actuels (POS, Kitchen) restent inchangés

### Modules supportés

| Module | Status | Routes | Access Level |
|--------|--------|--------|--------------|
| Loyalty | ✅ Implémenté | `/rewards` | Client |
| Roulette | ✅ Implémenté | `/roulette` | Client |
| Delivery | ✅ Implémenté | `/delivery/*` | Client |
| Kitchen Tablet | ✅ Implémenté | `/kitchen` | Kitchen |
| Staff Tablet | ✅ Implémenté | `/pos`, `/staff-tablet/*` | Admin |

## Points d'attention

### ⚠️ Important

1. **Toutes les routes restent dans le router** - Ne pas essayer de les supprimer dynamiquement
2. **Les guards gèrent l'accès** - C'est leur rôle de rediriger si nécessaire
3. **Double protection** - Global + Local pour plus de sécurité
4. **Logs activés en debug** - Pour faciliter le debugging

### 🐛 Debugging

Activer les logs pour voir les vérifications :
```dart
// Les guards loggent automatiquement en mode debug
🔒 [ModuleGuard] Module Roulette is disabled, redirecting to /home
✅ [AdminGuard] Admin access granted
```

## Performance

- ✅ Aucun impact sur les performances
- ✅ Les vérifications sont faites uniquement lors de la navigation
- ✅ Le registry est initialisé une seule fois au démarrage
- ✅ Les guards sont légers (simple vérification booléenne)

## Prochaines étapes

1. [ ] Ajouter plus de modules au registry
2. [ ] Intégrer avec le Builder B3 pour masquer les blocs désactivés
3. [ ] Créer des widgets de navigation conscients des modules
4. [ ] Ajouter un écran de debug pour visualiser les modules actifs
5. [ ] Documenter l'API pour les développeurs externes

## Conclusion

Le système de navigation white-label est maintenant complet et opérationnel. Chaque restaurant peut avoir :
- ✅ Ses propres modules activés/désactivés
- ✅ Son propre arborescence de routes
- ✅ Ses propres écrans accessibles
- ✅ Ses propres restrictions d'accès (admin/staff/client/kitchen)

Le système est robuste, maintenable, et prêt pour la production.
