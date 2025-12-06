# Plan de Test - Unification des Feature Flags

## 🎯 Objectif des Tests

Vérifier que la source unique de vérité (`RestaurantPlanUnified.activeModules`) fonctionne correctement à travers toute l'application.

---

## 📋 Tests à Effectuer

### Test 1: SuperAdmin → Client (Module Roulette)

#### Actions:
1. Se connecter en tant que SuperAdmin
2. Aller dans `/superadmin/restaurants/:id/modules`
3. **DÉSACTIVER** le module Roulette
4. Sauvegarder

#### Vérifications Client:
- [ ] Le module disparaît de la navigation client
- [ ] Le banner roulette disparaît de la page d'accueil
- [ ] Accès direct à `/roulette` → redirection vers `/module-disabled`
- [ ] Les providers liés à la roulette retournent `null`

#### Actions (suite):
5. **RÉACTIVER** le module Roulette dans SuperAdmin
6. Sauvegarder

#### Vérifications Client (suite):
- [ ] Le module réapparaît dans la navigation
- [ ] Le banner roulette réapparaît
- [ ] Accès direct à `/roulette` → fonctionne
- [ ] Les providers fonctionnent à nouveau

---

### Test 2: SuperAdmin → Client (Module Fidélité)

#### Actions:
1. Se connecter en tant que SuperAdmin
2. Aller dans `/superadmin/restaurants/:id/modules`
3. **DÉSACTIVER** le module Loyalty (Fidélité)
4. Sauvegarder

#### Vérifications Client:
- [ ] L'onglet "Fidélité" disparaît de la navigation (si présent)
- [ ] Les providers loyalty retournent `null`
- [ ] Accès direct aux pages de fidélité → redirection
- [ ] Pas de points de fidélité affichés

#### Actions (suite):
5. **RÉACTIVER** le module Loyalty
6. Sauvegarder

#### Vérifications Client (suite):
- [ ] Tout réapparaît et fonctionne

---

### Test 3: SuperAdmin → Admin (Gestion Modules)

#### Actions:
1. Se connecter en tant que SuperAdmin
2. **DÉSACTIVER** le module Promotions
3. Se connecter en tant qu'admin normal
4. Aller dans les réglages admin

#### Vérifications Admin:
- [ ] Les réglages de promotions ne sont pas visibles
- [ ] Impossible d'accéder à `/admin/promotions`
- [ ] Les écrans liés aux promotions sont masqués

#### Actions (suite):
5. Se reconnecter en SuperAdmin
6. **RÉACTIVER** le module Promotions

#### Vérifications Admin (suite):
- [ ] Tout réapparaît dans l'admin

---

### Test 4: Builder B3 → Blocs Masqués

#### Prérequis:
- Avoir une page Builder B3 avec des blocs liés à différents modules

#### Actions:
1. Se connecter en tant que SuperAdmin
2. **DÉSACTIVER** un module utilisé dans un bloc Builder
3. Aller sur la page client qui contient ce bloc

#### Vérifications:
- [ ] Le bloc est masqué (pas affiché)
- [ ] Les autres blocs s'affichent normalement
- [ ] Pas d'erreur dans la console

#### Actions (suite):
4. **RÉACTIVER** le module

#### Vérifications (suite):
- [ ] Le bloc réapparaît

---

### Test 5: Protection SuperAdmin

#### Actions:
1. Se connecter en tant qu'admin **normal** (pas SuperAdmin)
2. Essayer d'accéder à `/superadmin`

#### Vérifications:
- [ ] Accès refusé
- [ ] Message d'erreur: "Seuls les Super-Administrateurs peuvent accéder à cette zone"
- [ ] Redirection automatique OU écran d'erreur

---

### Test 6: Navigation Dynamique

#### Actions:
1. Se connecter en tant que SuperAdmin
2. Noter les modules activés dans la navigation client
3. **DÉSACTIVER** tous les modules optionnels (Roulette, Loyalty, Promotions)
4. Sauvegarder
5. Recharger l'application client

#### Vérifications:
- [ ] Seuls les modules core restent dans la navigation (Menu, Panier, Profil)
- [ ] Pas d'erreur si < 2 items (fallback navigation)
- [ ] Navigation reste fonctionnelle

#### Actions (suite):
6. **RÉACTIVER** les modules un par un

#### Vérifications (suite):
- [ ] Chaque module réapparaît dans la navigation au fur et à mesure

---

### Test 7: Guards de Route

#### Test 7.1: ModuleGuard
**Actions:**
1. Désactiver le module Roulette
2. Essayer d'accéder à `/roulette` directement

**Vérifications:**
- [ ] Redirection vers la page d'accueil
- [ ] Message dans la console: `[ModuleGuard] Module Roulette is disabled`

#### Test 7.2: AdminGuard
**Actions:**
1. Se déconnecter (ou se connecter en tant que client normal)
2. Essayer d'accéder à une page admin

**Vérifications:**
- [ ] Redirection ou accès refusé
- [ ] Message: "Accès réservé aux administrateurs"

#### Test 7.3: KitchenGuard
**Actions:**
1. Se connecter en tant que client normal
2. Essayer d'accéder à `/kitchen` (si existe)

**Vérifications:**
- [ ] Accès refusé
- [ ] Message: "Accès réservé à la cuisine"

---

### Test 8: Providers Reactive

#### Actions:
1. Ouvrir DevTools / Console
2. Se connecter en tant que client
3. Aller sur une page qui affiche plusieurs modules (ex: Home)
4. Dans un autre onglet, se connecter en SuperAdmin
5. Désactiver un module visible sur la page client
6. Retourner sur l'onglet client

#### Vérifications:
- [ ] Le contenu du module disparaît automatiquement (providers réactifs)
- [ ] Pas besoin de recharger la page
- [ ] Les autres modules continuent de fonctionner

---

### Test 9: Compatibilité Code Existant

#### Test 9.1: flags.has()
**Code à tester:**
```dart
final flags = ref.watch(restaurantFeatureFlagsProvider);
if (flags?.has(ModuleId.loyalty) ?? false) {
  print('Loyalty activé');
}
```

**Vérifications:**
- [ ] Code fonctionne
- [ ] Retourne `true` si module activé
- [ ] Retourne `false` si module désactivé

#### Test 9.2: flags.loyaltyEnabled
**Code à tester:**
```dart
final flags = ref.watch(restaurantFeatureFlagsProvider);
if (flags.loyaltyEnabled) {
  print('Loyalty activé');
}
```

**Vérifications:**
- [ ] Code fonctionne
- [ ] Retourne `true` si module activé
- [ ] Retourne `false` si module désactivé

#### Test 9.3: Anciens Constructors (DEPRECATED)
**Code à tester:**
```dart
RestaurantFeatureFlags.fromMap(data);
```

**Vérifications:**
- [ ] Lance `UnimplementedError`
- [ ] Message clair: "RestaurantFeatureFlags ne doit plus être construit à partir de Firestore"

---

### Test 10: Performance & Logs

#### Actions:
1. Ouvrir DevTools / Console
2. Activer le mode debug
3. Naviguer dans l'application

#### Vérifications:
- [ ] Logs clairs dans la console:
  - `[WL NAV] Modules actifs: [...]`
  - `[ModuleGuard] Access granted to ...`
  - `[BottomNav] Module filtering: X → Y items`
- [ ] Pas d'erreur ou warning
- [ ] Pas de boucle infinie de requêtes
- [ ] Navigation fluide

---

## ✅ Critères de Succès

Pour valider complètement l'implémentation, **tous** les tests ci-dessus doivent passer:

- [ ] Test 1: SuperAdmin → Client (Roulette)
- [ ] Test 2: SuperAdmin → Client (Fidélité)
- [ ] Test 3: SuperAdmin → Admin (Promotions)
- [ ] Test 4: Builder B3 → Blocs Masqués
- [ ] Test 5: Protection SuperAdmin
- [ ] Test 6: Navigation Dynamique
- [ ] Test 7: Guards de Route
- [ ] Test 8: Providers Reactive
- [ ] Test 9: Compatibilité Code Existant
- [ ] Test 10: Performance & Logs

---

## 🐛 En Cas de Problème

### Problème 1: Module ne disparaît pas
**Causes possibles:**
- Provider pas réactif (utilise `read` au lieu de `watch`)
- Cache local non invalidé
- Firestore pas synchronisé

**Debug:**
```dart
// Vérifier dans la console
final plan = ref.watch(restaurantPlanUnifiedProvider);
print('Active modules: ${plan.activeModules}');
```

### Problème 2: Navigation cassée
**Causes possibles:**
- Moins de 2 items après filtrage
- Fallback navigation pas affiché

**Debug:**
- Vérifier les logs `[BottomNav]` dans la console
- Vérifier que le fallback s'active

### Problème 3: Guards ne bloquent pas
**Causes possibles:**
- Guard pas appliqué à la route
- Provider pas chargé

**Debug:**
- Vérifier les logs `[ModuleGuard]` dans la console
- Vérifier que le plan est chargé

---

## 📝 Notes

- Les tests peuvent être automatisés avec des tests d'intégration Flutter
- Tests manuels recommandés pour valider l'UX
- Tester sur différents rôles: SuperAdmin, Admin, Client
- Tester sur différents états: modules ON, modules OFF, transition ON→OFF→ON

---

## ✅ Validation Finale

Une fois tous les tests passés:

- [ ] SuperAdmin ON/OFF = Client ON/OFF ✅
- [ ] SuperAdmin ON/OFF = Admin ON/OFF ✅
- [ ] Builder masque/affiche blocs ✅
- [ ] Guards bloquent correctement ✅
- [ ] Navigation filtrée dynamiquement ✅
- [ ] Aucune régression ✅
- [ ] Performance acceptable ✅

🎉 **Unification complète et fonctionnelle !**
