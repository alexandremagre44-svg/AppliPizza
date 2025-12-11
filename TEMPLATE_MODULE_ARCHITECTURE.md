# Architecture Templates & Modules

## Vue d'ensemble

Ce document décrit l'architecture du système de templates et modules pour AppliPizza. Cette architecture assure une **séparation totale** entre la logique métier (templates) et les fonctionnalités activables (modules).

## Principes Fondamentaux

### 1. Templates = Logique Métier

Les **templates** définissent **UNIQUEMENT** le comportement métier du restaurant:
- Workflow de commande (cuisine, POS, salle)
- Types de service (table, comptoir, livraison)
- Structure des menus et personnalisations
- Catégories de produits suggérées
- Configuration d'impression

**Les templates NE contrôlent PAS les modules.**

### 2. Modules = Capacités Activables

Les **modules** sont des fonctionnalités business activées/désactivées **uniquement par le SuperAdmin**:
- ordering
- delivery
- click_and_collect
- payments
- payment_terminal
- wallet
- loyalty
- promotions
- newsletter
- roulette
- reporting
- exports
- campaigns
- staff_tablet
- **pos** ⭐ (nouveau)
- **kitchen_tablet** ⭐ (maintenant optionnel, pas core)
- time_recorder
- theme
- pages_builder

### 3. Dissociation Totale

```
Template → Recommande des modules
         ≠ 
         N'active PAS les modules

Modules → Activés par SuperAdmin
        ≠ 
        Pas contrôlés par le template
```

## Structure du Code

### Templates

**Fichier**: `lib/white_label/restaurant/restaurant_template.dart`

```dart
class RestaurantTemplate {
  final String id;
  final String name;
  final ServiceType serviceType;
  final WorkflowConfig workflow;
  final PrintConfig printConfig;
  final List<ModuleId> recommendedModules;  // ⚠️ Recommandations uniquement
  final bool recommendsPOS;
  final bool recommendsKitchen;
  // ...
}
```

**Templates disponibles**:
1. **Pizzeria Classic** - Workflow cuisine, personnalisation pizza
2. **Fast Food Express** - Service comptoir rapide
3. **Restaurant Premium** - Service à table haut de gamme
4. **Sushi Bar** - Spécialisé sushi avec livraison
5. **Blank Template** - Configuration manuelle complète

### Modules

**Fichier**: `lib/white_label/core/module_id.dart`

```dart
enum ModuleId {
  ordering,
  delivery,
  clickAndCollect,
  payments,
  paymentTerminal,
  wallet,
  loyalty,
  roulette,
  promotions,
  newsletter,
  kitchen_tablet,  // ⭐ Optionnel
  staff_tablet,
  pos,             // ⭐ Nouveau
  timeRecorder,
  theme,
  pagesBuilder,
  reporting,
  exports,
  campaigns,
}
```

### Configuration Restaurant

**Fichier**: `lib/white_label/restaurant/restaurant_plan_unified.dart`

```dart
class RestaurantPlanUnified {
  final String restaurantId;
  final String name;
  final String? templateId;          // Template métier
  final List<String> activeModules;  // Modules activés par SuperAdmin
  
  // Méthodes
  bool hasModule(ModuleId id) { ... }
  RestaurantTemplate? get template { ... }
}
```

**Structure Firestore**:
```
restaurants/{restaurantId}/plan/config
{
  "restaurantId": "...",
  "name": "...",
  "slug": "...",
  "templateId": "pizzeria-classic",      // Template métier
  "activeModules": [                      // Modules activés
    "ordering",
    "delivery",
    "pos",
    "kitchen_tablet"
  ],
  "createdAt": "...",
  "updatedAt": "..."
}
```

## Workflow d'Utilisation

### 1. Création d'un Restaurant (Wizard)

**Étape 1-2**: Identité et Branding

**Étape 3**: Sélection du Template
- Le SuperAdmin choisit un template métier
- Le template définit la logique business
- Les modules recommandés sont affichés mais **pas encore activés**

**Étape 4**: Activation des Modules
- Le SuperAdmin voit les modules recommandés **pré-cochés**
- Il peut cocher/décocher n'importe quel module
- Les modules sont activés **indépendamment** du template

**Étape 5**: Validation et création

### 2. Runtime Client

```dart
// Récupérer la config
final plan = ref.watch(restaurantPlanUnifiedProvider);

// Vérifier si un module est actif
if (plan.hasModule(ModuleId.pos)) {
  // Afficher le POS
}

if (plan.hasModule(ModuleId.kitchen_tablet)) {
  // Afficher la cuisine
}

// Récupérer le workflow depuis le template
final template = plan.template;
if (template != null && plan.hasModule(ModuleId.kitchen_tablet)) {
  final kitchenWorkflow = template.workflow.kitchenStates;
  // Utiliser le workflow
}
```

### 3. Guards de Navigation

```dart
// Guard POS
return posRouteGuard(
  PosScreen(),
  fallbackRoute: '/home',
);

// Guard Kitchen
return kitchenRouteGuard(
  KitchenScreen(),
  fallbackRoute: '/home',
);
```

**Le guard vérifie:**
- ✅ Module activé → Affiche l'écran
- ❌ Module désactivé → Redirige ou affiche message

## Migration Firestore

### Script de Migration

**Fichier**: `scripts/migrate_template_modules.mjs`

**Fonctionnalités**:
1. Migre les anciens champs vers le nouveau système
2. Normalise les module IDs (snake_case → camelCase)
3. Assigne un template basé sur l'heuristique des modules actifs
4. Assure la rétrocompatibilité

**Usage**:
```bash
# Preview
node scripts/migrate_template_modules.mjs --dry-run

# Apply to all restaurants
node scripts/migrate_template_modules.mjs --apply

# Apply to specific restaurant
node scripts/migrate_template_modules.mjs --restaurant=delizza --apply
```

### Stratégie de Migration

1. **Non-destructive**: Les anciens champs sont conservés
2. **Rétrocompatible**: L'ancien code continue de fonctionner
3. **Progressif**: Migration restaurant par restaurant possible
4. **Réversible**: Rollback possible en cas de problème

## Exemples d'Utilisation

### Exemple 1: Pizzeria avec Workflow Cuisine

```dart
// Template
final template = RestaurantTemplates.pizzeriaClassic;

// Workflow cuisine défini par le template
template.workflow.kitchenStates; // ["Reçue", "En préparation", "Prête", "Livrée"]

// Mais le module kitchen_tablet DOIT être activé
final plan = RestaurantPlanUnified(
  templateId: 'pizzeria-classic',
  activeModules: ['ordering', 'kitchen_tablet'],  // ⚠️ Activé explicitement
);

// Vérification runtime
if (plan.hasModule(ModuleId.kitchen_tablet)) {
  // ✅ Afficher la cuisine avec le workflow du template
  final workflow = plan.template?.workflow.kitchenStates;
}
```

### Exemple 2: Fast-Food sans Cuisine

```dart
// Template
final template = RestaurantTemplates.fastFoodExpress;

// Template recommande POS mais pas Kitchen
template.recommendsPOS;      // true
template.recommendsKitchen;  // false

// Configuration
final plan = RestaurantPlanUnified(
  templateId: 'fast-food-express',
  activeModules: ['ordering', 'pos'],  // Kitchen non activé
);

// Runtime
plan.hasModule(ModuleId.pos);            // ✅ true
plan.hasModule(ModuleId.kitchen_tablet); // ❌ false
```

### Exemple 3: Restaurant Premium avec Service Table

```dart
// Template
final template = RestaurantTemplates.restaurantPremium;

// Workflow service à table
template.workflow.tableServiceStates; // ["Envoyée", "En préparation", "Servie"]

// Configuration
final plan = RestaurantPlanUnified(
  templateId: 'restaurant-premium',
  activeModules: [
    'ordering',
    'kitchen_tablet',
    'loyalty',
    'reporting',
  ],
);

// Vérification
if (plan.hasModule(ModuleId.kitchen_tablet)) {
  // Utiliser le workflow cuisine ET service à table
  final kitchenWorkflow = plan.template?.workflow.kitchenStates;
  final tableWorkflow = plan.template?.workflow.tableServiceStates;
}
```

## Tests

### Tests Templates

**Fichier**: `test/restaurant_template_test.dart`

Tests couverts:
- ✅ Tous les templates définis
- ✅ Récupération par ID
- ✅ Sérialisation/Désérialisation JSON
- ✅ Propriétés de workflow
- ✅ Configuration d'impression
- ✅ Modules recommandés
- ✅ Séparation template/modules

### Tests Guards

**Fichier**: `test/pos_module_guard_test.dart`

Tests couverts:
- ✅ POS guard avec module actif
- ✅ POS guard avec module inactif
- ✅ Kitchen guard avec module actif
- ✅ Kitchen guard avec module inactif
- ✅ Indépendance POS/Kitchen
- ✅ Template ne force pas l'activation

## Points d'Attention

### ⚠️ À NE PAS FAIRE

```dart
// ❌ MAL: Activer automatiquement les modules depuis le template
if (plan.templateId == 'pizzeria-classic') {
  // Ne pas auto-activer kitchen_tablet
}

// ❌ MAL: Supposer qu'un template active des modules
final isPizzeria = plan.templateId == 'pizzeria-classic';
if (isPizzeria) {
  // Ne pas supposer que kitchen_tablet est actif
}
```

### ✅ À FAIRE

```dart
// ✅ BON: Toujours vérifier l'activation explicite
if (plan.hasModule(ModuleId.kitchen_tablet)) {
  // Afficher la cuisine
}

// ✅ BON: Utiliser le template pour la logique métier
final template = plan.template;
if (template != null && plan.hasModule(ModuleId.kitchen_tablet)) {
  // Utiliser le workflow défini par le template
  final workflow = template.workflow.kitchenStates;
}

// ✅ BON: Les recommandations du template sont des suggestions
final template = plan.template;
final recommended = template?.recommendedModules ?? [];
// Afficher en UI pour suggestion, mais ne pas forcer l'activation
```

## Flux de Données

```
┌─────────────────┐
│   SuperAdmin    │
│     Wizard      │
└────────┬────────┘
         │
         ├─ Étape 3: Sélectionne Template
         │           ↓
         │    Définit logique métier
         │    Suggère modules
         │
         ├─ Étape 4: Active Modules
         │           ↓
         │    Activation indépendante
         │    Peut différer des suggestions
         │
         ▼
┌─────────────────────────────┐
│  RestaurantPlanUnified      │
├─────────────────────────────┤
│ templateId: "pizzeria"      │
│ activeModules: [            │
│   "ordering",               │
│   "kitchen_tablet",         │
│   "pos"                     │
│ ]                           │
└────────┬────────────────────┘
         │
         ├─ Runtime Client
         │  ↓
         │  Vérifie hasModule()
         │  Utilise template.workflow
         │
         └─ Navigation Guards
            ↓
            Filtrage routes
```

## Conclusion

Cette architecture assure:
1. ✅ **Séparation claire** entre logique métier et fonctionnalités
2. ✅ **Contrôle total** du SuperAdmin sur les modules
3. ✅ **Flexibilité** maximale pour configurer chaque restaurant
4. ✅ **Maintenabilité** du code avec responsabilités bien définies
5. ✅ **Évolutivité** facile pour ajouter templates ou modules
6. ✅ **Rétrocompatibilité** avec l'existant
