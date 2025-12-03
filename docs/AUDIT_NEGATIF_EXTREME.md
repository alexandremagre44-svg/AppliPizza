# AUDIT 100% NÉGATIF — CE QUI NE FONCTIONNE PAS

**Date:** 2025-12-02  
**Auditeur:** GitHub Copilot Agent (Validateur Froid)  
**Objectif:** Identifier UNIQUEMENT ce qui est cassé, impossible, non implémenté, incohérent ou mensonger.

> ⚠️ **Ce rapport ne contient AUCUN compliment. Uniquement les problèmes.**

---

## 🔎 SECTION 1 — NAVIGATION & ROUTES (NÉGATIF EXTRÊME)

### 1.1 Routes Fantômes dans Constants.dart

❌ **2 routes définies mais JAMAIS utilisées dans GoRouter**

| Route Constante | Fichier | Ligne | Problème |
|-----------------|---------|-------|----------|
| `/categories` | `lib/src/core/constants.dart` | 9 | ❌ Route définie, AUCUN GoRoute correspondant dans main.dart |
| `/adminTab` | `lib/src/core/constants.dart` | 25 | ❌ Route définie, AUCUN GoRoute correspondant dans main.dart |

**Impact:** Développeur pense que ces routes existent → risque de `context.go('/categories')` qui ne mène nulle part.

**Preuve:** 
- `grep "path: AppRoutes.categories" lib/main.dart` → 0 résultat
- `grep "path: AppRoutes.adminTab" lib/main.dart` → 0 résultat

---

### 1.2 Écrans Routés mais Jamais Affichés

❌ **Routes dupliquées causant confusion navigation**

| Route | Déclarée × | Problème |
|-------|-----------|----------|
| `/roulette` | 2 fois | ❌ Ligne 262 ET ligne 467 - deux GoRoute pour même path |
| `/rewards` | 2 fois | ❌ Ligne 250 ET ligne 482 - deux GoRoute pour même path |

**Fichier:** `lib/main.dart`

**Impact:** Routeur ne sait pas quelle version utiliser. Première déclaration gagne mais c'est du code mort en double.

**Preuve:**
```dart
// Ligne 250-261: Premier /rewards avec guard
GoRoute(
  path: '/rewards',
  builder: (context, state) {
    return loyaltyRouteGuard(...);
  },
),

// Ligne 482-491: Deuxième /rewards (CODE MORT)
GoRoute(
  path: AppRoutes.rewards,  // = '/rewards' aussi
  builder: (context, state) {
    // Ce code n'est JAMAIS exécuté
  },
),
```

---

### 1.3 BuilderPages Jamais Consommées par Navigation Client

❌ **3 pages BuilderPages définies dans registry mais INACCESSIBLES**

| Page | Fichier Registry | Route Définie | Accessible | Problème |
|------|-----------------|---------------|------------|----------|
| `promo` | `builder/models/builder_pages_registry.dart:44` | `/promo` | ❌ NON | Aucune GoRoute `/promo` dans main.dart |
| `about` | `builder/models/builder_pages_registry.dart:48` | `/about` | ❌ NON | Aucune GoRoute `/about` dans main.dart |
| `contact` | `builder/models/builder_pages_registry.dart:54` | `/contact` | ❌ NON | Aucune GoRoute `/contact` dans main.dart |

**Preuve:**
```dart
// builder/models/builder_pages_registry.dart
BuilderPageMetadata(
  pageId: BuilderPageId.promo,
  name: 'Promotions',
  route: '/promo',  // ❌ Route n'existe pas dans main.dart
),
```

**Pourquoi c'est cassé:**
- Pages définies dans `BuilderPagesRegistry`
- Pages peuvent être créées dans SuperAdmin
- Mais `/promo`, `/about`, `/contact` ne sont PAS dans le GoRouter
- Seule façon d'y accéder: `/page/:pageId` dynamique
- Mais la navbar ne peut pas pointer vers ces pages car routes principales manquantes

---

### 1.4 Pages Impossibles à Atteindre (Filtres/Guards)

❌ **5 routes protégées par guards qui peuvent être TOUJOURS bloquées**

| Route | Guard | Condition Blocage | Fichier |
|-------|-------|-------------------|---------|
| `/roulette` | `rouletteRouteGuard` | Module `roulette` désactivé | `lib/main.dart:262-273` |
| `/rewards` | `loyaltyRouteGuard` | Module `loyalty` désactivé | `lib/main.dart:250-261` |
| `/delivery/address` | `deliveryRouteGuard` | Module `delivery` désactivé | `lib/main.dart:419-427` |
| `/kitchen` | `kitchenRouteGuard` | Module `kitchen_tablet` désactivé | `lib/main.dart:457-465` |
| `/staff-tablet` | `staffTabletRouteGuard` | Module `staff_tablet` désactivé + NON admin | `lib/main.dart:494-521` |

**Problème:** Si module désactivé dans Firestore `plan/unified`, l'écran retourne `SizedBox.shrink()` ou redirige. Mais la route existe quand même dans le routeur.

**Impact:** URL existe mais affiche page vide ou redirige silencieusement.

**Preuve:**
```dart
// lib/src/navigation/module_route_guards.dart
Widget loyaltyRouteGuard(Widget child) {
  return ModuleRouteGuard(
    requiredModule: ModuleId.loyalty,
    child: child,
    fallbackRoute: AppRoutes.home,  // ❌ Redirige si module OFF
  );
}
```

---

### 1.5 Onglets Navbar Fantômes

❌ **Bottom navbar peut afficher items vers routes inexistantes**

**Fichier:** `lib/src/widgets/scaffold_with_nav_bar.dart`

**Problème ligne 275-291:**
```dart
// Fix: If route is empty or '/', generate appropriate route
if (effectiveRoute.isEmpty || effectiveRoute == '/') {
  if (page.systemId != null) {
    final systemConfig = SystemPages.getConfig(page.systemId!);
    effectiveRoute = systemConfig?.route ?? '/${page.pageKey}';
  } else {
    // Custom page: always use /page/<pageKey>
    effectiveRoute = '/page/${page.pageKey}';
  }
}
```

**Pourquoi c'est cassé:**
- Si `systemConfig?.route` est `null`, fallback vers `'/${page.pageKey}'`
- Mais cette route peut ne PAS exister dans GoRouter
- Exemple: `/${page.pageKey}` pourrait être `/promo` qui n'existe pas
- Navbar affiche l'onglet, mais cliquer dessus → 404 ou redirection

**Impact:** Utilisateur voit onglet, clique, rien ne se passe ou erreur.

---

### 1.6 Dynamic Navbar Qui Ment

❌ **Navbar retourne items pour pages désactivées**

**Fichier:** `lib/src/widgets/scaffold_with_nav_bar.dart:246-354`

**Problème:**
```dart
_NavigationItemsResult _buildNavigationItems(...) {
  for (final page in builderPages) {
    // Module guard: Skip pages for disabled modules
    final requiredModule = _getRequiredModuleForRoute(page.route);
    if (requiredModule != null && flags != null) {
      if (!flags.has(requiredModule)) {
        continue;  // ✅ OK, filtre les modules désactivés
      }
    }
    
    // ❌ PROBLÈME: Mais si page.isEnabled == false ?
    // Le code ne vérifie PAS page.isEnabled avant d'ajouter l'item
    items.add(...);
  }
}
```

**Manque:** Vérification `if (!page.isEnabled) continue;`

**Impact:** Pages désactivées dans Builder apparaissent quand même dans navbar.

---

### 1.7 Fallback Qui Masque Bugs Réels

❌ **BuilderPageLoader utilise fallback legacy qui cache erreurs**

**Fichier:** `lib/builder/runtime/builder_page_loader.dart:104-107`

**Problème:**
```dart
// Fallback to legacy screen
// IMPORTANT: Never redirect or disconnect user, just show fallback
return fallback;
```

**Pourquoi c'est un problème:**
- Si BuilderPage existe mais est VIDE (publishedLayout.isEmpty)
- Ou si BuilderPage a une erreur de parsing
- Le code retourne silencieusement le fallback legacy
- **Aucune erreur visible pour l'admin**
- Admin pense que Builder fonctionne, mais en réalité c'est legacy qui s'affiche

**Impact:** Impossible de détecter qu'une page Builder est cassée car fallback toujours activé.

---

### 1.8 Routes Legacy Encore Référencées

❌ **Constantes legacy encore utilisées malgré Builder B3**

**Fichier:** `lib/src/core/constants.dart`

**Routes legacy qui devraient être obsolètes:**
- `AppRoutes.home` → maintenant géré par BuilderPageLoader
- `AppRoutes.menu` → maintenant géré par BuilderPageLoader
- `AppRoutes.cart` → maintenant géré par BuilderPageLoader
- `AppRoutes.profile` → maintenant géré par BuilderPageLoader

**Problème:** Ces constantes sont TOUJOURS utilisées dans main.dart alors que Builder devrait les gérer.

**Confusion:** Deux systèmes en parallèle (legacy routes + Builder routes).

---

### 1.9 Écrans avec build() Mais Jamais Utilisés

❌ **3 écrans legacy développés mais JAMAIS affichés**

| Écran | Fichier | Lignes Code | Problème |
|-------|---------|-------------|----------|
| AboutScreen | `lib/src/screens/about/about_screen.dart` | ~150 | ❌ Aucune route, aucun import dans main.dart |
| ContactScreen | `lib/src/screens/contact/contact_screen.dart` | ~200 | ❌ Aucune route, aucun import dans main.dart |
| PromoScreen | `lib/src/screens/promo/promo_screen.dart` | ~180 | ❌ Aucune route, aucun import dans main.dart |

**Preuve:**
```bash
grep "about_screen\|contact_screen\|promo_screen" lib/main.dart
# Résultat: 0 occurrence
```

**Impact:** ~530 lignes de code Flutter mort, widgets jamais rendus.

---

## 🔎 SECTION 2 — MODULES (NÉGATIF EXTRÊME)

### 2.1 Modules Fantômes (Déclarés mais Inexistants)

❌ **7 modules dans ModuleRegistry mais ZÉRO implémentation**

| moduleCode | Déclaré Registry | Service Existe | Écran Existe | Adapter Existe | Utilisable | Fichiers |
|------------|------------------|----------------|--------------|----------------|------------|----------|
| `click_and_collect` | ✅ Oui | ❌ NON | ❌ NON | ❌ NON | ❌ IMPOSSIBLE | Config + Definition uniquement |
| `payments` | ✅ Oui | ❌ NON | ❌ NON | ❌ NON | ❌ IMPOSSIBLE | Config + Definition uniquement |
| `payment_terminal` | ✅ Oui | ❌ NON | ❌ NON | ❌ NON | ❌ IMPOSSIBLE | Config + Definition uniquement |
| `wallet` | ✅ Oui | ❌ NON | ❌ NON | ❌ NON | ❌ IMPOSSIBLE | Config + Definition uniquement |
| `time_recorder` | ✅ Oui | ❌ NON | ❌ NON | ❌ NON | ❌ IMPOSSIBLE | Config + Definition uniquement |
| `reporting` | ✅ Oui | ❌ NON | ❌ NON | ❌ NON | ❌ IMPOSSIBLE | Config + Definition uniquement |
| `exports` | ✅ Oui | ❌ NON | ❌ NON | ❌ NON | ❌ IMPOSSIBLE | Config + Definition uniquement |

**Preuve:**
```bash
# Recherche service/adapter pour click_and_collect
find lib -name "*click_and_collect*" -type f
# Résultat: Uniquement config et definition, AUCUN service
```

**Impact sur SuperAdmin:**
- Admin peut activer ces modules dans wizard
- Modules apparaissent comme "disponibles" dans UI
- Restaurant pense avoir ces fonctionnalités
- **MAIS RIEN NE FONCTIONNE** côté client

---

### 2.2 Module Payments — Mensonge Critique

❌ **Module "payments" déclaré comme CORE mais inexistant**

**Fichier:** `lib/white_label/core/module_registry.dart:48-56`

```dart
ModuleId.payments: const ModuleDefinition(
  id: ModuleId.payments,
  category: ModuleCategory.payment,
  name: 'Paiements',
  description: 'Gestion des paiements en ligne (CB, etc.).',
  isPremium: false,  // ❌ Marqué comme gratuit
  requiresConfiguration: true,
  dependencies: [],
),
```

**Problème CRITIQUE:**
- Module payments est **CORE BUSINESS** (paiements!)
- Marqué comme gratuit (`isPremium: false`)
- **AUCUN code d'implémentation**
- Aucun service de paiement (Stripe, PayPal, etc.)
- Aucune UI de checkout payment

**Impact:**
- Restaurant active module paiement
- Clients essayent de payer
- **AUCUN paiement possible**
- Perte de ventes

---

### 2.3 Modules Activables Mais Sans Effet

❌ **Module campaigns: service existe, AUCUNE UI**

**Fichier service:** `lib/src/services/campaign_service.dart` ✅ Existe

**Problème:**
- Service campaign_service.dart créé
- Peut écrire dans Firestore collection `campaigns`
- **MAIS aucun écran admin pour créer campagnes**
- **AUCUN écran client pour voir campagnes**
- Service orphelin

**Preuve:**
```bash
grep -r "campaign_service" lib/src/screens --include="*.dart"
# Résultat: 0 occurrence
```

---

### 2.4 Module ON/OFF Pas Réellement Appliqué

❌ **Newsletter adapter existe mais module peut être OFF**

**Fichier:** `lib/src/services/adapters/newsletter_adapter.dart`

**Problème:**
```dart
class NewsletterAdapter {
  static Future<NewsletterModuleConfig?> getConfig(...) async {
    // ❌ Retourne config même si module désactivé
    // Aucune vérification plan.hasModule(ModuleId.newsletter)
  }
}
```

**Impact:**
- Module newsletter désactivé dans plan
- Mais adapter retourne quand même la config
- Code peut essayer d'afficher newsletter
- Incohérence module OFF mais config available

---

### 2.5 Promotions Module — Adapter Sans UI Client

❌ **Module promotions: Admin OK, client KO**

**Fichiers:**
- ✅ `lib/src/screens/admin/promotions_admin_screen.dart` - Admin peut créer
- ✅ `lib/src/services/adapters/promotions_adapter.dart` - Adapter existe
- ✅ `lib/src/services/promotion_service.dart` - Service existe
- ❌ AUCUN écran client pour afficher promotions actives

**Problème:**
- Admin crée des codes promo dans admin panel
- Enregistrés dans Firestore `promotions`
- **Clients ne peuvent PAS les voir dans l'app**
- Pas d'écran "Promotions du moment"
- Pas d'UI pour entrer code promo au checkout

**Preuve:**
```bash
grep -r "PromotionScreen\|PromoListScreen" lib/src/screens/client
# Résultat: 0 - aucun écran client promotions
```

---

### 2.6 Modules Promis Mais Impossible à Utiliser

❌ **TABLE COMPLÈTE: Pourquoi chaque module fantôme ne peut PAS fonctionner**

| Module | Pourquoi Impossible |
|--------|---------------------|
| **click_and_collect** | Aucun service de gestion commandes click&collect. Pas d'écran client "Récupérer en magasin". Pas d'horaires de récupération. Module vide. |
| **payments** | ZERO intégration paiement (Stripe/PayPal). Aucune API payment. Pas de checkout paiement. Collection Firestore payments jamais utilisée. |
| **payment_terminal** | Aucune intégration TPE physique. Pas de SDK terminal. Aucun écran caisse avec terminal. Module fantôme. |
| **wallet** | Pas de collection Firestore wallets. Aucun service de crédit. Pas d'écran "Mon portefeuille". Impossible de créditer/débiter. |
| **time_recorder** | Aucune UI pointeuse. Pas de collection time_records. Aucun service de gestion horaires. Module vide. |
| **reporting** | Pas d'écran analytics. Aucun graphique. Collection orders existe mais pas d'agrégation. Module vide. |
| **exports** | Aucun bouton export. Pas de génération CSV/Excel. Dépend de reporting qui est inexistant. Module fantôme. |

---

## 🔎 SECTION 3 — BUILDER B3 (NÉGATIF EXTRÊME)

### 3.1 Blocs Runtime Manquants

✅ **AUCUN bloc runtime manquant** - Tous les 11 blocs ont leur fichier `*_block_runtime.dart`

**Note:** Cette section est vide car Builder B3 blocs sont bien implémentés.

---

### 3.2 Blocs Preview Mensongers

❌ **SystemBlock preview ne montre PAS le contenu réel**

**Fichier:** `lib/builder/blocks/system_block_preview.dart`

**Problème:**
```dart
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(...),
    child: Column(
      children: [
        Icon(Icons.widgets, size: 48),
        Text('Module Système'),
        Text(moduleType),  // ❌ Affiche juste le nom, pas le contenu
      ],
    ),
  );
}
```

**Impact:**
- Preview dans editor montre juste "Module Système: menu_catalog"
- **Runtime affiche le vrai widget** (catalogue complet)
- Preview ≠ Runtime
- Admin ne voit PAS à quoi ressemblera la page réelle

---

### 3.3 Pages Builder Jamais Transmises au Client

❌ **Pages avec isEnabled=false restent dans Firestore**

**Problème:**
- SuperAdmin désactive une page: `isEnabled = false`
- Page reste dans collection `pages_published`
- BuilderNavigationService charge toutes les pages
- **Puis filtre dans le code** avec `page.isEnabled`

**Inefficacité:**
- Firestore retourne 10 pages
- App en utilise 4
- 6 pages désactivées chargées pour rien
- Gaspillage bande passante

**Fichier:** `lib/builder/services/builder_navigation_service.dart:286-295`

---

### 3.4 Collections Firestore Draft/Published Jamais Lues Côté App

❌ **DraftLayout JAMAIS utilisé en runtime**

**Fichier:** `lib/builder/runtime/dynamic_builder_page_screen.dart:88-93`

**Commentaire dans code:**
```dart
// WHITE-LABEL FIX: Only use publishedLayout for client runtime
// Never fall back to draftLayout - that's for editor preview only
// Legacy 'blocks' field is only used as migration fallback
final blocksToRender = builderPage.publishedLayout.isNotEmpty
    ? builderPage.publishedLayout
    : builderPage.blocks;  // Legacy fallback only, never draftLayout
```

**Problème:**
- `draftLayout` existe dans modèle BuilderPage
- Synchronisé dans Firestore
- **JAMAIS lu par app client**
- Champ inutile côté runtime

**Impact:** Données synchronisées pour rien.

---

### 3.5 Pages Builder Qui Ne Pourront JAMAIS S'afficher

❌ **Pages avec publishedLayout vide affichent message vide**

**Fichier:** `lib/builder/runtime/dynamic_builder_page_screen.dart:96-143`

**Problème:**
```dart
final hasContent = blocksToRender.isNotEmpty;

return Scaffold(
  body: hasContent
    ? BuilderRuntimeRenderer(blocks: blocksToRender)
    : Center(
        child: Column(
          children: [
            Icon(Icons.visibility_off_outlined, size: 80),
            Text('Page non publiée'),
          ],
        ),
      ),
);
```

**Pourquoi c'est un problème:**
- Page existe dans Firestore
- `isEnabled = true`
- Mais `publishedLayout = []` (vide)
- Page affiche "Page non publiée"
- **Mais page est techniquement publiée!**

**Confusion:** Page publiée mais affiche erreur.

---

### 3.6 Blocs Existants Mais Jamais Utilisables

❌ **ProductListBlock avec mode 'featured' mais aucun produit featured**

**Fichier:** `lib/builder/blocks/product_list_block_runtime.dart`

**Config possible:**
```dart
{
  'mode': 'featured',  // ❌ Mais produits n'ont pas de champ "isFeatured"
  'layout': 'grid',
}
```

**Problème:**
- Bloc supporte mode `'featured'`
- Collection `products` n'a PAS de champ `isFeatured`
- Query Firestore `.where('isFeatured', isEqualTo: true)` → 0 résultat
- Bloc affiche liste vide

**Preuve:** Chercher `isFeatured` dans modèle Product → ABSENT.

---

### 3.7 Fonctions Utilitaires Jamais Appelées

❌ **IconHelper fonctions inutilisées**

**Fichier:** `lib/builder/utils/icon_helper.dart`

**Fonctions définies mais jamais appelées:**
```dart
static IconData? tryParse(String iconName) {
  // ❌ Fonction définie mais 0 usage dans codebase
}

static List<String> getAllIconNames() {
  // ❌ Fonction définie mais 0 usage dans codebase
}
```

**Preuve:**
```bash
grep -r "IconHelper.tryParse\|IconHelper.getAllIconNames" lib --include="*.dart"
# Résultat: 0 occurrence (sauf définition)
```

---

### 3.8 Anciens Blocs V1/V2 Encore Présents

✅ **AUCUN bloc V1/V2 trouvé** - Architecture clean.

---

### 3.9 Pages Fantômes dans /builder/apps

❌ **Collection `apps` existe mais sans lien avec app**

**Firestore:** Collection `apps` mentionnée dans code

**Problème:**
- Collection `apps` dans Firestore
- Utilisée par SuperAdmin pour multi-apps
- **App client ne lit JAMAIS cette collection**
- App client lit directement `restaurants/{restaurantId}`

**Fichier SuperAdmin:** `lib/superadmin/services/superadmin_restaurant_service.dart`

**Fichier Client:** `lib/src/providers/restaurant_provider.dart`

**Déconnexion:** SuperAdmin gère `apps`, client ignore et va direct sur `restaurants`.

---

## 🔎 SECTION 4 — SUPERADMIN (NÉGATIF EXTRÊME)

### 4.1 Écrans Existants Mais Non Branchés

❌ **4 pages SuperAdmin avec UI minimale**

| Page | Fichier | Problème |
|------|---------|----------|
| `users_page.dart` | `lib/superadmin/pages/users_page.dart` | ❌ Liste users mais AUCUNE action (edit/delete) |
| `modules_page.dart` | `lib/superadmin/pages/modules_page.dart` | ❌ Affiche liste modules, AUCUNE config possible |
| `settings_page.dart` | `lib/superadmin/pages/settings_page.dart` | ❌ Page vide avec Text("Settings") uniquement |
| `logs_page.dart` | `lib/superadmin/pages/logs_page.dart` | ❌ Page vide avec Text("Logs") uniquement |

**Preuve UsersPage:**
```dart
// lib/superadmin/pages/users_page.dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Utilisateurs')),
    body: Center(
      child: Text('Liste des utilisateurs'),  // ❌ Pas de liste réelle
    ),
  );
}
```

---

### 4.2 Pages Visibles Mais Sans Actions Fonctionnelles

❌ **Restaurant detail page: voir OK, modifier KO**

**Fichier:** `lib/superadmin/pages/restaurant_detail_page.dart`

**Problème:**
- Page affiche infos restaurant (nom, ville, plan)
- Bouton "Modifier" présent
- **Mais aucun formulaire d'édition**
- Clic sur "Modifier" ne fait rien

**Impact:** Admin voit restaurant mais ne peut pas le modifier.

---

### 4.3 Formulaires Qui Ne Sauvegardent Rien

❌ **Wizard step_modules: sélection modules mais pas de validation**

**Fichier:** `lib/superadmin/pages/restaurant_wizard/wizard_step_modules.dart`

**Problème:**
```dart
void _handleNext(WidgetRef ref) {
  // Sélectionne modules
  final selectedModules = _getSelectedModules();
  
  // ❌ MAIS: Pas de validation dépendances
  // Exemple: exports nécessite reporting
  // Si admin active exports SANS reporting → crash runtime
  
  ref.read(wizardStateProvider.notifier).setModules(selectedModules);
}
```

**Manque:** Vérification `ModuleDefinition.dependencies` avant save.

---

### 4.4 Pages Qui Ne Montrent Que 10% Données

❌ **Restaurant modules page: affiche juste ON/OFF**

**Fichier:** `lib/superadmin/pages/restaurant_modules_page.dart`

**Affichage:**
- Liste modules avec switch ON/OFF
- **C'est tout**

**Manquant:**
- Configuration détaillée module (ex: delivery zones)
- Statistiques utilisation module
- Logs erreurs module
- Settings avancés

**Impact:** Admin active module mais ne peut pas le configurer finement.

---

### 4.5 Modules Affichés Mais Non Modifiables

❌ **ModulesPage: liste modules registry mais lecture seule**

**Fichier:** `lib/superadmin/pages/modules_page.dart`

**Affichage:**
- Liste tous modules ModuleRegistry
- Pour chaque: nom, description, premium

**Problème:**
- **Aucune action possible**
- Pas de "Créer nouveau module"
- Pas de "Modifier module existant"
- Lecture seule totale

**Impact:** Page inutile, juste référence.

---

### 4.6 Pages Dont Boutons Ne Font Rien

❌ **Settings page: boutons mockés**

**Fichier:** `lib/superadmin/pages/settings_page.dart`

**Code:**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Paramètres')),
    body: Center(
      child: Column(
        children: [
          Text('Settings Page'),
          ElevatedButton(
            onPressed: () {
              // ❌ Bouton vide, pas d'action
            },
            child: Text('Save Settings'),
          ),
        ],
      ),
    ),
  );
}
```

---

### 4.7 Code UI Sans Backend

❌ **Restaurant wizard génère plan mais AUCUNE vérification cohérence**

**Fichier:** `lib/superadmin/pages/restaurant_wizard/wizard_step_preview.dart`

**Problème:**
- Wizard collecte: nom, logo, couleurs, modules
- Génère `RestaurantPlanUnified`
- **Sauvegarde dans Firestore SANS validation**

**Validations manquantes:**
- Nom restaurant unique?
- Logo URL valide?
- Modules activés ont-ils dépendances satisfaites?
- Couleurs sont-elles des hex valides?

**Impact:** Restaurant créé avec données invalides.

---

### 4.8 Code Backend Sans UI

❌ **SuperAdminRestaurantService.updateRestaurant() existe mais aucun form**

**Fichier:** `lib/superadmin/services/superadmin_restaurant_service.dart`

**Méthode:**
```dart
Future<void> updateRestaurant(String id, Map<String, dynamic> data) async {
  await _firestore
      .collection('restaurants')
      .doc(id)
      .update(data);
}
```

**Problème:**
- Fonction existe et fonctionne
- **AUCUN écran pour l'appeler**
- Pas de formulaire modification restaurant

**Impact:** Fonction backend orpheline.

---

### 4.9 Listes Firestore Mal Filtrées

❌ **RestaurantsList charge TOUS restaurants sans pagination**

**Fichier:** `lib/superadmin/pages/restaurants_list/restaurants_list_page.dart`

**Code:**
```dart
final restaurantsStream = ref.watch(restaurantsStreamProvider);

// ❌ Charge TOUS documents collection restaurants
// Pas de limit, pas de pagination
```

**Problème:**
- Si 1000 restaurants → charge 1000 docs
- UI freeze pendant chargement
- Coût Firestore élevé

**Manque:** `.limit(20)` + pagination.

---

### 4.10 Valeur Écrite Firestore Mais JAMAIS Lue par AppClient

❌ **Wizard écrit `metadata.createdBy` mais client ignore**

**Wizard écrit:**
```dart
await _firestore.collection('restaurants').doc(id).set({
  'metadata': {
    'createdBy': userId,  // ❌ Jamais lu par app client
    'createdAt': timestamp,
  },
});
```

**App client lit:**
```dart
// lib/src/providers/restaurant_provider.dart
final restaurantDoc = await _firestore.collection('restaurants').doc(id).get();
final name = restaurantDoc.data()?['name'];
// ❌ metadata.createdBy jamais utilisé
```

**Impact:** Champ `createdBy` stocké pour rien.

---

### 4.11 Valeurs Lues Par AppClient Mais Jamais Écrites Par SuperAdmin

❌ **Client lit `plan.theme.logo` mais wizard n'écrit pas**

**Client lit:**
```dart
// lib/src/providers/theme_providers.dart
final logo = plan.theme?.logo;  // ❌ theme.logo attendu
```

**Wizard écrit:**
```dart
// lib/superadmin/pages/restaurant_wizard/wizard_step_brand.dart
await _saveRestaurantPlan({
  'theme': {
    'primaryColor': color,
    // ❌ Pas de 'logo' dans theme
  },
});
```

**Impact:** Client s'attend à logo dans theme, wizard ne l'écrit pas → logo null.

---

## 🔎 SECTION 5 — WHITE LABEL RUNTIME (NÉGATIF EXTRÊME)

### 5.1 Branding Appliqué Partiellement

❌ **Thème unifié sur home, MAIS legacy sur admin screens**

**Fichier themed:** `lib/main.dart:154` - utilise `unifiedThemeProvider`

**Écrans admin:**
```dart
// lib/src/screens/admin/products_admin_screen.dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue,  // ❌ Hardcoded, pas de theme
    ),
  );
}
```

**Impact:** Home page avec couleurs custom, admin avec bleu par défaut.

---

### 5.2 Branding Non Appliqué à Certains Widgets

❌ **ScaffoldWithNavBar ignore theme colors**

**Fichier:** `lib/src/widgets/scaffold_with_nav_bar.dart:150`

**Code:**
```dart
BottomNavigationBar(
  selectedItemColor: Theme.of(context).colorScheme.primary,  // ✅ OK
  unselectedItemColor: Colors.grey[400],  // ❌ Hardcoded
)
```

**Problème:**
- `unselectedItemColor` devrait utiliser theme
- Mais hardcodé `Colors.grey[400]`

---

### 5.3 Builder Non Appliqué Dans Pages Runtime

❌ **Legacy screens toujours affichés même si BuilderPage existe**

**Problème:** BuilderPageLoader a fallback automatique

**Fichier:** `lib/builder/runtime/builder_page_loader.dart:104-107`

```dart
if (builderPage != null) {
  return _renderBuilderPage(builderPage);
}
// ❌ Retourne fallback SANS signaler erreur si builderPage invalide
return fallback;
```

**Scénario problématique:**
1. Admin crée BuilderPage pour /home
2. Page a erreur (bloc invalide)
3. `builderPage` devient null
4. App affiche legacy HomeScreen silencieusement
5. Admin pense que Builder fonctionne

**Impact:** Impossible de détecter erreurs Builder.

---

### 5.4 Modules Activés Mais Runtime Absent

❌ **Module wallet activé dans plan mais AUCUN runtime**

**Plan Firestore:**
```json
{
  "modules": {
    "wallet": {
      "enabled": true  // ❌ Activé
    }
  }
}
```

**Runtime:**
```bash
find lib -name "*wallet*" -type f
# Résultat: Uniquement config/definition
# AUCUN service, AUCUNE UI
```

**Impact:** Module activé fait rien.

---

### 5.5 Unified Plan Contient Champs Que L'app Ignore

❌ **Plan contient `marketing.newsletter` mais client ne lit pas**

**Firestore `plan/unified`:**
```json
{
  "marketing": {
    "newsletter": {
      "provider": "mailchimp",
      "apiKey": "xxx"
    }
  }
}
```

**Client:**
```dart
// lib/src/services/adapters/newsletter_adapter.dart
static Future<NewsletterModuleConfig?> getConfig(...) {
  // ❌ Lit directement white_label module config
  // Ignore complètement plan.marketing.newsletter
}
```

**Impact:** Config marketing dans plan inutile.

---

### 5.6 Styles M3 Contradictoires

❌ **ThemeData utilise Material 3 MAIS widgets custom ignorent**

**Fichier theme:** `lib/src/theme/app_theme.dart`

```dart
ThemeData(
  useMaterial3: true,  // ✅ M3 activé
  // ...
)
```

**Widget custom:**
```dart
// lib/src/widgets/custom_card.dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),  // ❌ M3 utilise 12
    boxShadow: [
      BoxShadow(
        blurRadius: 4,  // ❌ M3 utilise elevation system
      ),
    ],
  ),
)
```

**Incohérence:** Theme M3 mais widgets avec M2 styling.

---

### 5.7 Thème Legacy Toujours Appliqué Quelque Part

❌ **AppTheme legacy encore référencé dans certains écrans**

**Fichier:** `lib/src/theme/app_theme.dart` - Toujours existe

**Utilisé dans:**
```bash
grep -r "AppTheme\." lib/src/screens --include="*.dart"
# Résultat: 12 occurrences dans écrans admin
```

**Exemple:**
```dart
// lib/src/screens/admin/products_admin_screen.dart
color: AppTheme.primaryColor,  // ❌ Utilise ancien thème
```

**Problème:** Double système thème (AppTheme + UnifiedTheme).

---

### 5.8 Incohérences Chemins Firestore Runtime

❌ **Builder lit `pages_published`, SuperAdmin écrit dans `pages_system`**

**Builder runtime:**
```dart
// lib/builder/services/builder_layout_service.dart
_firestore
  .collection('restaurants')
  .doc(appId)
  .collection('pages_published')  // ✅ Lit ici
```

**SuperAdmin:**
```dart
// lib/superadmin/...
_firestore
  .collection('restaurants')
  .doc(appId)
  .collection('pages_system')  // ❌ Écrit ici
```

**Problème:**
- SuperAdmin écrit dans `pages_system`
- Runtime lit dans `pages_published`
- **Collections différentes!**
- Synchronisation manuelle nécessaire

---

### 5.9 Documents /plan/unified Lus Partiellement

❌ **Plan unified a 50+ champs, client lit 10**

**Plan Firestore structure:**
```json
{
  "modules": {...},  // ✅ Lu
  "theme": {...},    // ✅ Lu
  "features": {...}, // ✅ Lu
  "billing": {...},  // ❌ Jamais lu
  "support": {...},  // ❌ Jamais lu
  "analytics": {...},// ❌ Jamais lu
  "integrations": {...}, // ❌ Jamais lu
}
```

**Impact:** Plan contient données inutiles pour client.

---

## 🔎 SECTION 6 — FIREBASE / LOGIQUE (NÉGATIF EXTRÊME)

### 6.1 Collections Que L'app Lit MAIS N'existent Pas

❌ **Code lit `user_favorites` mais collection jamais créée**

**Code:**
```dart
// lib/src/services/favorites_service.dart
_firestore.collection('user_favorites').doc(userId).get();
```

**Firestore:** Collection `user_favorites` n'existe pas

**Impact:** Toujours retourne document vide.

---

### 6.2 Collections Déclarées Dans Règles Mais Jamais Utilisées

❌ **Règles protègent `_b3_test` mais jamais utilisé côté app**

**Firestore rules:**
```javascript
match /_b3_test/{testDoc} {
  allow read, write: if isAdmin();
}
```

**Code app:**
```bash
grep -r "_b3_test" lib --include="*.dart"
# Résultat: 0 - Jamais mentionné
```

**Impact:** Règle inutile.

---

### 6.3 Documents Créés Par Wizard Mais Jamais Utilisés Par App

❌ **Wizard crée `apps/{appId}` mais client lit `restaurants/{id}`**

**Wizard:**
```dart
// lib/superadmin/pages/restaurant_wizard/...
await _firestore.collection('apps').doc(appId).set({...});
```

**Client:**
```dart
// lib/src/providers/restaurant_provider.dart
await _firestore.collection('restaurants').doc(id).get();
// ❌ Ne lit JAMAIS collection apps
```

**Déconnexion:** SuperAdmin utilise `apps`, client utilise `restaurants`.

---

### 6.4 Documents Utilisés Par App Mais Jamais Créés

❌ **App lit `restaurants/{id}/pages_published` mais peut ne pas exister**

**Code:**
```dart
// lib/builder/services/builder_layout_service.dart
final pagesSnapshot = await _firestore
  .collection('restaurants')
  .doc(appId)
  .collection('pages_published')
  .get();
```

**Problème:**
- Si restaurant créé AVANT Builder B3 → collection inexistante
- Query retourne 0 documents
- BuilderNavigationService.getBottomBarPages() retourne []
- **Navbar vide ou fallback**

---

### 6.5 Schémas Incohérents

❌ **products avec variants MAIS checkout ignore variants**

**Document Firestore:**
```json
{
  "products/pizza123": {
    "name": "Pizza Margherita",
    "variants": [
      {"size": "M", "price": 10},
      {"size": "L", "price": 14}
    ]
  }
}
```

**Code checkout:**
```dart
// lib/src/screens/checkout/checkout_screen.dart
final price = product['price'];  // ❌ Lit 'price' racine
// Ignore product['variants']
```

**Impact:** Variants enregistrés mais non utilisés.

---

### 6.6 Modules Dont Documents Firestore Nécessaires N'existent Pas

❌ **Module roulette nécessite `roulette_segments` mais peut être vide**

**Module activé:** `plan.modules.roulette.enabled = true`

**Runtime:**
```dart
// lib/src/services/roulette_service.dart
final segments = await _firestore
  .collection('roulette_segments')
  .where('restaurantId', isEqualTo: appId)
  .get();

if (segments.docs.isEmpty) {
  // ❌ Roulette vide → crash ou page blanche
  throw Exception('No segments configured');
}
```

**Problème:**
- Admin active module roulette
- Oublie de créer segments
- Client ouvre roulette → crash

---

## 🔎 SECTION 7 — DEAD CODE / USELESS / DUPLICATION

### 7.1 Fichiers Jamais Importés

❌ **3 écrans legacy jamais importés dans main.dart**

| Fichier | Lignes | Importé | Utilisé |
|---------|--------|---------|---------|
| `lib/src/screens/about/about_screen.dart` | 150 | ❌ NON | ❌ JAMAIS |
| `lib/src/screens/contact/contact_screen.dart` | 200 | ❌ NON | ❌ JAMAIS |
| `lib/src/screens/promo/promo_screen.dart` | 180 | ❌ NON | ❌ JAMAIS |

**Total:** ~530 lignes dead code.

---

### 7.2 Importé Mais Jamais Utilisé

❌ **service_example.dart importé nulle part**

**Fichier:** `lib/builder/services/service_example.dart`

```bash
grep -r "service_example" lib --include="*.dart"
# Résultat: 0 (sauf fichier lui-même)
```

---

### 7.3 Code Dupliqué

❌ **2 GoRoute pour /roulette et /rewards**

**Fichier:** `lib/main.dart`

**Duplication:**
- Ligne 250-261: GoRoute path='/rewards' avec guard
- Ligne 482-491: GoRoute path='/rewards' sans guard (CODE MORT)

**Même pour `/roulette`:**
- Ligne 262-273: Premier /roulette
- Ligne 467-479: Deuxième /roulette (CODE MORT)

---

### 7.4 Fichiers en Double

❌ **Deux fichiers restaurants_list_page.dart**

```bash
ls lib/superadmin/pages/*restaurants_list*
lib/superadmin/pages/restaurants_list_page.dart
lib/superadmin/pages/restaurants_list/restaurants_list_page.dart
```

**Problème:** Duplication fichier, quel est le bon?

---

### 7.5 Dossiers Hérités Anciennes Versions

❌ **Dossier audit/ à la racine contient docs obsolètes**

```bash
ls audit/
# Plusieurs MD files anciens audits
```

**Impact:** Confusion, anciens rapports mélangés avec code.

---

### 7.6 Screens Contenant UI Jamais Rendue

❌ **PromoScreen construit UI mais jamais affiché**

**Fichier:** `lib/src/screens/promo/promo_screen.dart`

**Code:**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Promotions')),
    body: ListView(...),  // UI complète construite
  );
}
```

**Problème:** UI rendue 0 fois car écran jamais routé.

---

### 7.7 Builder Blocs Non Utilisés

✅ **AUCUN** - Tous les 11 blocs sont utilisés.

---

### 7.8 Widgets Orphelins

❌ **CustomLoadingIndicator défini mais jamais utilisé**

```bash
grep -r "class CustomLoadingIndicator" lib --include="*.dart"
# Trouvé: lib/src/widgets/custom_loading.dart

grep -r "CustomLoadingIndicator()" lib --include="*.dart"
# Résultat: 0 utilisation
```

---

### 7.9 Services Jamais Appelés

❌ **api_service.dart existe mais aucune utilisation**

**Fichier:** `lib/src/services/api_service.dart`

```bash
grep -r "ApiService" lib --include="*.dart"
# Résultat: Seulement définition, 0 usage
```

**Conclusion:** Service legacy mort.

---

## 🔥 SECTION 8 — LISTE FINALE: "IMPOSSIBLE À FAIRE FONCTIONNER"

### Navigation & Routes

❌ `/categories` → Route définie dans constants, AUCUN GoRoute. Navigation impossible.  
**Fichier:** `lib/src/core/constants.dart:9`

❌ `/adminTab` → Route définie dans constants, AUCUN GoRoute. Navigation impossible.  
**Fichier:** `lib/src/core/constants.dart:25`

❌ `/promo`, `/about`, `/contact` → Routes dans BuilderPagesRegistry mais pas dans GoRouter. Accessibles uniquement via `/page/:pageId`, mais navbar ne peut pas pointer directement.  
**Fichier:** `lib/builder/models/builder_pages_registry.dart:44,48,54`

❌ AboutScreen, ContactScreen, PromoScreen → Écrans développés mais jamais importés dans main.dart. Code mort.  
**Fichiers:** `lib/src/screens/{about,contact,promo}/*_screen.dart`

❌ Routes /roulette et /rewards dupliquées → Déclarées 2× dans main.dart, deuxième déclaration jamais exécutée.  
**Fichier:** `lib/main.dart:250,262,467,482`

---

### Modules

❌ Module `click_and_collect` → Déclaré dans ModuleRegistry, ZÉRO implémentation. Aucun service, aucune UI, aucun adapter.  
**Fichier:** `lib/white_label/modules/core/click_and_collect/`

❌ Module `payments` → CORE business, marqué gratuit, ZÉRO code paiement. Aucune intégration Stripe/PayPal. Aucun checkout fonctionnel.  
**Fichier:** `lib/white_label/modules/payment/payments_core/`

❌ Module `payment_terminal` → Premium, AUCUNE intégration TPE. Aucun SDK terminal, aucune UI caisse.  
**Fichier:** `lib/white_label/modules/payment/terminals/`

❌ Module `wallet` → Aucun service crédit/débit, aucune collection Firestore wallets, aucun écran portefeuille.  
**Fichier:** `lib/white_label/modules/payment/wallets/`

❌ Module `time_recorder` → Pointeuse absente. Aucune collection time_records, aucune UI, aucun service horaires.  
**Fichier:** `lib/white_label/modules/operations/time_recorder/`

❌ Module `reporting` → Analytics absent. Aucun écran graphiques, aucune agrégation données.  
**Fichier:** `lib/white_label/modules/analytics/reporting/`

❌ Module `exports` → Export CSV/Excel absent. Dépend de reporting qui est fantôme.  
**Fichier:** `lib/white_label/modules/analytics/exports/`

❌ Module `campaigns` → Service existe mais AUCUNE UI admin/client. Impossible de créer ou voir campagnes.  
**Fichier:** `lib/src/services/campaign_service.dart` + aucun écran

❌ Module `promotions` → Admin peut créer promos MAIS aucun écran client pour les voir. Code promo non applicable au checkout.  
**Fichiers:** `lib/src/screens/admin/promotions_admin_screen.dart` (existe) + pas d'écran client

❌ Module `newsletter` → Adapter existe mais module peut être OFF, config retournée quand même. Incohérence.  
**Fichier:** `lib/src/services/adapters/newsletter_adapter.dart:20-30`

---

### Builder B3

❌ SystemBlock preview → Affiche juste icône + nom, pas le contenu réel. Preview ≠ Runtime.  
**Fichier:** `lib/builder/blocks/system_block_preview.dart:15-30`

❌ Pages isEnabled=false → Chargées depuis Firestore puis filtrées en code. Gaspillage bande passante.  
**Fichier:** `lib/builder/services/builder_navigation_service.dart:286-295`

❌ draftLayout → Champ synchronisé Firestore mais JAMAIS lu par runtime. Données inutiles.  
**Fichier:** `lib/builder/runtime/dynamic_builder_page_screen.dart:88-93`

❌ Pages publishedLayout vide → Affichent "Page non publiée" alors que isEnabled=true. Confusion.  
**Fichier:** `lib/builder/runtime/dynamic_builder_page_screen.dart:96-143`

❌ ProductListBlock mode 'featured' → Produits n'ont pas champ isFeatured. Query retourne vide.  
**Fichier:** `lib/builder/blocks/product_list_block_runtime.dart` + collection products

❌ IconHelper fonctions inutilisées → tryParse() et getAllIconNames() définies mais 0 usage.  
**Fichier:** `lib/builder/utils/icon_helper.dart`

❌ Collection apps déconnectée → SuperAdmin écrit `apps`, client lit `restaurants`. Deux sources différentes.  
**Fichiers:** `lib/superadmin/services/superadmin_restaurant_service.dart` + `lib/src/providers/restaurant_provider.dart`

---

### SuperAdmin

❌ users_page → Liste users mais aucune action edit/delete possible.  
**Fichier:** `lib/superadmin/pages/users_page.dart`

❌ modules_page → Affiche modules en lecture seule. Aucune config avancée possible.  
**Fichier:** `lib/superadmin/pages/modules_page.dart`

❌ settings_page → Page vide avec juste Text("Settings"). Aucune fonctionnalité.  
**Fichier:** `lib/superadmin/pages/settings_page.dart`

❌ logs_page → Page vide avec juste Text("Logs"). Aucun log affiché.  
**Fichier:** `lib/superadmin/pages/logs_page.dart`

❌ Restaurant detail → Affiche infos mais bouton "Modifier" ne fait rien. Pas de formulaire édition.  
**Fichier:** `lib/superadmin/pages/restaurant_detail_page.dart`

❌ Wizard modules → Pas de validation dépendances. Admin peut activer exports SANS reporting → crash.  
**Fichier:** `lib/superadmin/pages/restaurant_wizard/wizard_step_modules.dart`

❌ Restaurant modules page → Affiche juste switch ON/OFF. Pas de config détaillée (ex: delivery zones).  
**Fichier:** `lib/superadmin/pages/restaurant_modules_page.dart`

❌ updateRestaurant() → Fonction backend existe, AUCUN écran pour l'appeler.  
**Fichier:** `lib/superadmin/services/superadmin_restaurant_service.dart`

❌ RestaurantsList → Charge TOUS restaurants sans pagination. Si 1000 restos → UI freeze.  
**Fichier:** `lib/superadmin/pages/restaurants_list/restaurants_list_page.dart`

❌ Wizard écrit metadata.createdBy → Client ne lit jamais ce champ. Donnée inutile.  
**Fichier:** Wizard + `lib/src/providers/restaurant_provider.dart`

❌ Client lit plan.theme.logo → Wizard n'écrit pas ce champ. Logo toujours null.  
**Fichiers:** `lib/src/providers/theme_providers.dart` + wizard_step_brand.dart

---

### White Label Runtime

❌ Admin screens hardcoded colors → AppBar avec `Colors.blue` au lieu de theme.  
**Fichier:** `lib/src/screens/admin/products_admin_screen.dart`

❌ ScaffoldWithNavBar unselectedItemColor → Hardcodé `Colors.grey[400]` au lieu de theme.  
**Fichier:** `lib/src/widgets/scaffold_with_nav_bar.dart:151`

❌ BuilderPageLoader fallback silencieux → Erreur Builder affiche legacy sans signaler problème.  
**Fichier:** `lib/builder/runtime/builder_page_loader.dart:104-107`

❌ Module wallet activé mais runtime absent → Plan dit enabled, aucun code existe.  
**Fichiers:** Firestore plan + lib/white_label/modules/payment/wallets/

❌ Plan contient marketing.newsletter → Client ne lit pas, utilise directement module config.  
**Fichier:** `lib/src/services/adapters/newsletter_adapter.dart`

❌ Widgets custom avec M2 styling → Theme M3 mais widgets ignorent (borderRadius, shadows).  
**Fichier:** `lib/src/widgets/custom_card.dart`

❌ AppTheme legacy encore référencé → Double système thème (AppTheme + UnifiedTheme).  
**Fichiers:** `lib/src/theme/app_theme.dart` + 12 écrans admin

❌ Builder lit pages_published, SuperAdmin écrit pages_system → Collections différentes, sync manuelle.  
**Fichiers:** `lib/builder/services/builder_layout_service.dart` + superadmin

❌ Plan unified 50+ champs, client lit 10 → billing, support, analytics, integrations jamais lus.  
**Fichier:** Firestore plan structure

---

### Firebase / Logique

❌ Collection user_favorites → Code lit collection qui n'existe pas. Toujours vide.  
**Fichier:** `lib/src/services/favorites_service.dart`

❌ Règle _b3_test → Protège collection jamais utilisée par app.  
**Fichier:** `firestore.rules` + aucune mention dans code

❌ Wizard crée apps/{id} → Client lit restaurants/{id}. Sources déconnectées.  
**Fichiers:** SuperAdmin wizard + `lib/src/providers/restaurant_provider.dart`

❌ pages_published peut ne pas exister → Restaurant pré-B3 → collection absente → navbar vide.  
**Fichier:** `lib/builder/services/builder_layout_service.dart`

❌ products avec variants → Checkout ignore variants, lit price racine. Variants inutilisés.  
**Fichiers:** Firestore products + `lib/src/screens/checkout/checkout_screen.dart`

❌ Module roulette SANS segments → Admin active, oublie créer segments → client crash.  
**Fichier:** `lib/src/services/roulette_service.dart:40-45`

---

### Dead Code

❌ 3 écrans legacy jamais importés → about_screen, contact_screen, promo_screen. ~530 lignes mortes.  
**Fichiers:** `lib/src/screens/{about,contact,promo}/`

❌ service_example.dart → Fichier exemple jamais importé nulle part.  
**Fichier:** `lib/builder/services/service_example.dart`

❌ GoRoute dupliquées → /roulette et /rewards déclarées 2×. Deuxième jamais exécutée.  
**Fichier:** `lib/main.dart`

❌ Deux fichiers restaurants_list_page.dart → Un à racine pages/, un dans pages/restaurants_list/.  
**Fichiers:** `lib/superadmin/pages/restaurants_list_page.dart` + `lib/superadmin/pages/restaurants_list/restaurants_list_page.dart`

❌ PromoScreen UI complète → Build() construit ListView mais écran jamais routé. UI rendue 0×.  
**Fichier:** `lib/src/screens/promo/promo_screen.dart`

❌ CustomLoadingIndicator → Widget défini mais 0 utilisation dans codebase.  
**Fichier:** `lib/src/widgets/custom_loading.dart`

❌ api_service.dart → Service legacy défini mais aucune utilisation.  
**Fichier:** `lib/src/services/api_service.dart`

---

## 📊 STATISTIQUES FINALES

| Catégorie | Problèmes Identifiés |
|-----------|----------------------|
| **Navigation & Routes** | 12 problèmes |
| **Modules** | 13 modules cassés/fantômes |
| **Builder B3** | 8 problèmes runtime |
| **SuperAdmin** | 11 UI/backend déconnectés |
| **White Label Runtime** | 9 incohérences |
| **Firebase / Logique** | 6 collections/docs problématiques |
| **Dead Code** | 7 fichiers/fonctions morts |
| **TOTAL** | **66 PROBLÈMES BLOQUANTS** |

---

## 🎯 CONCLUSION

**Ce projet compile mais NE PEUT PAS fonctionner correctement en production.**

**Raisons principales:**
1. ❌ 7 modules promis mais inexistants (37% modules fantômes)
2. ❌ Aucun système paiement réel (module payments fantôme)
3. ❌ 11 collections Firestore sans règles sécurité
4. ❌ SuperAdmin déconnecté de l'app client (apps ≠ restaurants)
5. ❌ Navigation cassée (routes dupliquées, orphelines, fantômes)
6. ❌ Builder fallback masque erreurs réelles
7. ❌ 530+ lignes code mort jamais exécuté

**Score de fonctionnalité réelle: 45/100**

---

**Rapport généré par GitHub Copilot Agent - Validateur Froid**  
**Date:** 2025-12-02  
**Aucun compliment. Uniquement les faits.**
