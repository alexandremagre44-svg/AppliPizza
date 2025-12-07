# Builder Debug Tools

This directory contains diagnostic and debugging tools for the Builder B3 system.

## Files

### `builder_wl_diagnostic.dart`
Service de diagnostic pour les problèmes de propagation des modules entre SuperAdmin et Builder B3.

**Tests disponibles:**
1. **currentRestaurantProvider** - Valide que le restaurantId est non-vide
2. **restaurantPlanUnifiedProvider** - Valide que le plan est chargé et non-null
3. **Firestore direct** - Vérifie l'existence du document `plan/unified`
4. **moduleIdMapping** - Valide que tous les modules ont un mapping
5. **getFilteredModules** - Teste le filtrage effectif des modules
6. **Comparaison** - Compare les modules affichés vs modules actifs

**Utilisation:**
```dart
final service = BuilderWLDiagnosticService();
final results = await service.runAllTests(
  restaurantConfig: config,
  plan: plan,
);

// Log détaillé des modules
service.debugLogFilteredModules(restaurantId, plan);
```

### `diagnostic_dialog.dart`
Dialog UI pour afficher les résultats du diagnostic dans le Builder.

**Features:**
- Résumé (X/6 tests passés)
- Liste des tests avec statut (✅/❌)
- Détails expandables pour chaque test
- Bouton "Relancer"

**Utilisation:**
```dart
// Afficher le dialog dans le Builder
BuilderDiagnosticDialog.show(context, appIdOverride: appId);
```

**Intégration:**
Le bouton de diagnostic est déjà intégré dans `builder_page_editor_screen.dart` (visible en mode debug uniquement).

## SuperAdmin Diagnostic Page

Le fichier `lib/superadmin/pages/wl_diagnostic_page.dart` fournit une page SuperAdmin pour diagnostiquer et modifier les modules d'un restaurant.

**Features:**
- Affiche les activeModules du plan/unified
- Affiche tous les ModuleId avec toggles ON/OFF
- Affiche le JSON brut du document
- Permet de modifier les modules directement

**Intégration dans le router SuperAdmin:**

Pour ajouter cette page au router SuperAdmin, ajoutez cette route dans `lib/superadmin/superadmin_router.dart`:

```dart
import 'pages/wl_diagnostic_page.dart';

// Dans SuperAdminRoutes class:
static const String restaurantDiagnostic = '/superadmin/restaurants/:id/diagnostic';

// Dans la liste des routes:
GoRoute(
  path: SuperAdminRoutes.restaurantDiagnostic,
  pageBuilder: (context, state) {
    final restaurantId = state.pathParameters['id']!;
    return NoTransitionPage(
      child: WLDiagnosticPage(restaurantId: restaurantId),
    );
  },
),
```

**Accès depuis la page de détail d'un restaurant:**

Ajoutez un bouton dans `restaurant_detail_page.dart`:
```dart
ElevatedButton.icon(
  icon: const Icon(Icons.bug_report),
  label: const Text('Diagnostic WL'),
  onPressed: () {
    context.go('/superadmin/restaurants/$restaurantId/diagnostic');
  },
),
```

## Debug Mode

Toutes les fonctionnalités de debug ne sont actives qu'en mode debug (`kDebugMode`).

Pour activer le mode debug:
- En développement: automatiquement activé avec `flutter run`
- En production: jamais activé (les boutons de debug sont cachés)

## Logs de debug

Les logs de debug sont automatiquement affichés dans la console lorsque:
- Le dialog `BlockAddDialog` est ouvert
- Le plan est chargé ou modifié
- Les modules sont filtrés

Format des logs:
```
🔍 [BlockAddDialog] planAsync state:
  ✅ data: plan loaded with 3 modules: ordering, roulette, loyalty
📦 [BlockAddDialog] Filtering modules for plan delizza
   Active modules: ordering, roulette, loyalty
```

## Troubleshooting

### Problem: Plan est toujours null
- Vérifiez que `currentRestaurantProvider` retourne un ID valide
- Vérifiez que le document `restaurants/{id}/plan/unified` existe dans Firestore
- Consultez le Test 3 (Firestore direct) dans le diagnostic

### Problem: Tous les modules sont affichés
- Le plan est probablement null (fallback safe)
- Vérifiez que `restaurantPlanUnifiedProvider` charge correctement
- Consultez le Test 2 (Plan provider) dans le diagnostic

### Problem: Module manquant dans le mapping
- Ajoutez le mapping dans `lib/builder/utils/builder_modules.dart`
- Dans `moduleIdMapping`: `'mon_module': ModuleId.xxx`
- Relancez le Test 4 (moduleIdMapping) pour vérifier

## Module Legacy

Le module `accountActivity` est intentionnellement non mappé (legacy). Il est toujours visible, indépendamment de la configuration du plan. C'est documenté dans `builder_modules.dart`.
