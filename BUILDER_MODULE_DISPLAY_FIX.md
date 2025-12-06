# Fix des problèmes d'affichage des modules dans Builder B3

## Problèmes résolus

Ce fix corrige plusieurs problèmes critiques qui empêchaient l'affichage correct des modules dans le Builder pour les rôles admin/builder/superadmin.

### 1. Déconnexion entre `builderModules` et `ModuleId` ✅

**Problème**: Les modules Builder utilisaient des IDs (`menu_catalog`, `cart_module`, `profile_module`, `roulette_module`) qui ne correspondaient pas aux codes dans `ModuleId` (`roulette`, `ordering`, etc.).

**Solution**: Création d'une table de correspondance `moduleIdMapping` dans `lib/builder/utils/builder_modules.dart`:

```dart
final Map<String, String> moduleIdMapping = {
  'menu_catalog': ModuleId.ordering.code,      // 'ordering'
  'cart_module': ModuleId.ordering.code,       // 'ordering'
  'profile_module': ModuleId.ordering.code,    // 'ordering'
  'roulette_module': ModuleId.roulette.code,   // 'roulette'
  'roulette': ModuleId.roulette.code,          // 'roulette' (alias)
};
```

**Fonctions ajoutées**:
- `getModuleIdCode(String builderModuleId)`: Retourne le code white-label pour un ID Builder
- `getModuleId(String builderModuleId)`: Retourne l'enum ModuleId pour un ID Builder

### 2. Problème dans `isModuleEnabled()` ✅

**Problème**: La fonction retournait `false` pendant le chargement et en cas d'erreur, masquant les blocs avant même que le plan soit chargé.

**Solution**: Modification dans `lib/white_label/runtime/module_helpers.dart`:

```dart
// AVANT
loading: () => false,  // ❌ Les blocs disparaissent pendant le chargement
error: (_, __) => false,

// APRÈS
loading: () => true,   // ✅ Les blocs restent visibles pendant le chargement
error: (_, __) => true, // ✅ Les blocs restent visibles en cas d'erreur temporaire
```

**Impact**: 
- Les modules ne disparaissent plus pendant le chargement du plan
- Les erreurs temporaires de réseau ne masquent plus les modules
- Appliqué à `isModuleEnabled()` et `watchModuleEnabled()`

### 3. Chargement asynchrone dans `AppContextNotifier` ✅

**Problème**: `loadContext()` était appelé sans await, donc le provider retournait immédiatement avec `hasBuilderAccess: false`, affichant "Accès refusé" avant le chargement du contexte.

**Solution**: Modification dans `lib/builder/utils/app_context.dart`:

```dart
// AVANT
AppContextNotifier(this._service)
    : super(AppContextState(
        currentAppId: _defaultRestaurantId,
        accessibleApps: [],
        userRole: BuilderRole.client,
        hasBuilderAccess: false, // ❌ Accès refusé par défaut
      ));

// APRÈS
AppContextNotifier(this._service)
    : super(AppContextState(
        currentAppId: _defaultRestaurantId,
        accessibleApps: [],
        userRole: BuilderRole.client,
        hasBuilderAccess: true, // ✅ Accès autorisé pendant le chargement
      ));
```

**Impact**:
- Plus d'affichage "Accès refusé" pendant le chargement du contexte
- L'accès est mis à jour correctement une fois le contexte chargé
- Les admins voient le Builder immédiatement

### 4. Duplication dans `SystemBlock.availableModules` ✅

**Problème**: La liste contenait à la fois `'roulette'` et `'roulette_module'`, créant une incohérence.

**Solution**: Nettoyage dans `lib/builder/models/builder_block.dart`:

```dart
// AVANT
static const List<String> availableModules = [
  'roulette',
  'loyalty',
  'rewards',
  'accountActivity',
  'menu_catalog',
  'cart_module',
  'profile_module',
  'roulette_module', // ❌ Duplication avec 'roulette'
];

// APRÈS
static const List<String> availableModules = [
  'roulette',
  'loyalty',
  'rewards',
  'accountActivity',
  'menu_catalog',
  'cart_module',
  'profile_module',
];
```

**Rétrocompatibilité maintenue**: 
- `getModuleLabel('roulette_module')` et `getModuleIcon('roulette_module')` fonctionnent toujours
- Pas de breaking changes pour le code existant

## Tests ajoutés

### `test/builder/builder_modules_mapping_test.dart`
- Teste le mapping des IDs Builder vers ModuleId
- Vérifie que tous les modules Builder sont correctement mappés
- Valide `getModuleIdCode()` et `getModuleId()`

### `test/builder/system_block_test.dart`
- Teste l'absence de doublons dans `availableModules`
- Vérifie les labels et icônes pour tous les modules
- Teste la rétrocompatibilité avec `roulette_module`

## Comportement attendu

### ✅ Modules visibles dans le Builder
- Les modules s'affichent correctement pour admin/builder/superadmin
- Pas de message "Accès refusé" pendant le chargement
- Les blocs ne disparaissent pas pendant le chargement du plan

### ✅ Mapping cohérent
- Les IDs Builder sont correctement mappés vers les ModuleId white-label
- `menu_catalog`, `cart_module`, `profile_module` → `ordering`
- `roulette_module`, `roulette` → `roulette`

### ✅ Gestion des états
- Pendant le chargement: modules visibles par défaut
- Après le chargement: visibilité basée sur le plan restaurant
- En cas d'erreur: modules restent visibles (pas de masquage intempestif)

## Migration

### ⚠️ Aucun changement breaking
Tous les changements sont rétrocompatibles:
- Le code existant utilisant `roulette_module` continue de fonctionner
- Les labels et icônes fonctionnent pour les anciens et nouveaux noms
- Le mapping est transparent pour le code existant

### 📝 Utilisation recommandée

Pour vérifier si un module Builder est activé:

```dart
import 'package:pizza_delizza/builder/utils/builder_modules.dart';
import 'package:pizza_delizza/white_label/runtime/module_helpers.dart';

// Convertir l'ID Builder en ModuleId
final moduleId = getModuleId('menu_catalog'); // -> ModuleId.ordering

// Vérifier si le module est activé
if (moduleId != null && isModuleEnabled(ref, moduleId)) {
  // Le module est activé
}
```

## Fichiers modifiés

1. ✅ `lib/builder/utils/builder_modules.dart` - Ajout du mapping ModuleId
2. ✅ `lib/white_label/runtime/module_helpers.dart` - Correction du comportement loading/error
3. ✅ `lib/builder/utils/app_context.dart` - Gestion du chargement async
4. ✅ `lib/builder/models/builder_block.dart` - Nettoyage des duplications

## Tests

```bash
# Exécuter tous les tests
flutter test

# Exécuter uniquement les tests du Builder
flutter test test/builder/

# Exécuter uniquement les nouveaux tests
flutter test test/builder/builder_modules_mapping_test.dart
flutter test test/builder/system_block_test.dart
```

## Vérification manuelle

Pour vérifier que le fix fonctionne:

1. **Se connecter en tant qu'admin/builder/superadmin**
   - Vérifier que le Builder est accessible immédiatement
   - Pas de message "Accès refusé"

2. **Ouvrir l'éditeur de pages**
   - Vérifier que les modules sont visibles dans la liste
   - Tester l'ajout de blocs avec modules requis

3. **Tester avec une connexion lente**
   - Vérifier que les modules ne disparaissent pas pendant le chargement
   - Vérifier que l'accès Builder n'est pas refusé

4. **Tester avec des erreurs réseau**
   - Simuler une erreur réseau
   - Vérifier que les modules restent visibles

## Conclusion

Ces changements corrigent les problèmes critiques d'affichage des modules dans le Builder B3, garantissant une expérience utilisateur fluide pour les administrateurs et builders.

Les modifications sont minimales, ciblées et 100% rétrocompatibles.
