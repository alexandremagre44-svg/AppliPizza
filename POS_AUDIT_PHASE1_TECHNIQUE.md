# PHASE 1 — AUDIT TECHNIQUE POS

**Date**: 2024-12-15  
**Lead**: Flutter Architect + UX Engineer  
**Objectif**: Inventaire complet de l'architecture POS/KDS/Staff/Kitchen existante

---

## 📊 INVENTAIRE COMPLET DES FICHIERS

### 🔴 CATÉGORIE 1: POS (Caisse principale) - `/lib/src/screens/admin/pos/`

| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| `pos_screen.dart` | Screen | ✅ **ACTIF** | Aucun - Écran principal POS en 3 colonnes | **GARDER** - Refonte UI/UX |
| `pos_shell_scaffold.dart` | Layout | ✅ **ACTIF** | Aucun - Shell scaffold réutilisable | **GARDER** - Améliorer design |
| `pos_routes.dart` | Routes | ✅ **ACTIF** | Aucun - Configuration routes POS | **GARDER** |
| **Providers** ||||
| `providers/pos_cart_provider.dart` | Provider | ✅ **ACTIF** | Possible - Vérifier override Riverpod | **GARDER** - Fix si besoin |
| `providers/pos_order_provider.dart` | Provider | ✅ **ACTIF** | Possible - Vérifier override Riverpod | **GARDER** - Fix si besoin |
| `providers/pos_payment_provider.dart` | Provider | ✅ **ACTIF** | Possible - Vérifier override Riverpod | **GARDER** - Fix si besoin |
| `providers/pos_session_provider.dart` | Provider | ✅ **ACTIF** | Possible - Vérifier override Riverpod | **GARDER** - Fix si besoin |
| `providers/pos_state_provider.dart` | Provider | ✅ **ACTIF** | Possible - Vérifier override Riverpod | **GARDER** - Fix si besoin |
| **Widgets** ||||
| `widgets/pos_actions_panel.dart` | Widget | ⚠️ **V1** | Ancien - Remplacé par v2 | **SUPPRIMER** - Doublon |
| `widgets/pos_actions_panel_v2.dart` | Widget | ✅ **ACTIF** | Thème rouge à remplacer | **GARDER** - Refonte UI |
| `widgets/pos_cart_panel.dart` | Widget | ⚠️ **V1** | Ancien - Remplacé par v2 | **SUPPRIMER** - Doublon |
| `widgets/pos_cart_panel_v2.dart` | Widget | ✅ **ACTIF** | Thème rouge à remplacer | **GARDER** - Refonte UI |
| `widgets/pos_cash_payment_modal.dart` | Modal | ✅ **ACTIF** | UI basique à améliorer | **GARDER** - Refonte UI |
| `widgets/pos_catalog_view.dart` | Widget | ✅ **ACTIF** | UI basique à améliorer | **GARDER** - Refonte UI |
| `widgets/pos_menu_customization_modal.dart` | Modal | ✅ **ACTIF** | UI basique à améliorer | **GARDER** - Refonte UI |
| `widgets/pos_pizza_customization_modal.dart` | Modal | ✅ **ACTIF** | UI basique à améliorer | **GARDER** - Refonte UI |
| `widgets/pos_session_open_modal.dart` | Modal | ✅ **ACTIF** | UI basique à améliorer | **GARDER** - Refonte UI |
| `widgets/pos_session_close_modal.dart` | Modal | ✅ **ACTIF** | UI basique à améliorer | **GARDER** - Refonte UI |

### 🟡 CATÉGORIE 2: Staff Tablet - `/lib/src/staff_tablet/`

| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| **Providers** ||||
| `providers/staff_tablet_auth_provider.dart` | Provider | ✅ **ACTIF** | Partie du POS | **GARDER** |
| `providers/staff_tablet_cart_provider.dart` | Provider | ✅ **ACTIF** | Partie du POS | **GARDER** |
| `providers/staff_tablet_orders_provider.dart` | Provider | ✅ **ACTIF** | Partie du POS | **GARDER** |
| **Screens** ||||
| `screens/staff_tablet_pin_screen.dart` | Screen | ✅ **ACTIF** | UI basique | **GARDER** - Améliorer UI |
| `screens/staff_tablet_catalog_screen.dart` | Screen | ✅ **ACTIF** | UI basique | **GARDER** - Améliorer UI |
| `screens/staff_tablet_checkout_screen.dart` | Screen | ✅ **ACTIF** | UI basique | **GARDER** - Améliorer UI |
| `screens/staff_tablet_history_screen.dart` | Screen | ✅ **ACTIF** | UI basique | **GARDER** - Améliorer UI |
| **Widgets** ||||
| `widgets/staff_menu_customization_modal.dart` | Modal | ✅ **ACTIF** | Doublon avec POS modal? | **GARDER** - Vérifier fusion possible |
| `widgets/staff_pizza_customization_modal.dart` | Modal | ✅ **ACTIF** | Doublon avec POS modal? | **GARDER** - Vérifier fusion possible |
| `widgets/staff_tablet_cart_summary.dart` | Widget | ✅ **ACTIF** | OK | **GARDER** |

### 🟢 CATÉGORIE 3: Kitchen Display System (KDS) - Multiple locations

#### Location A: `/lib/src/screens/kds/`
| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| `kds_screen.dart` | Screen | ✅ **ACTIF** | Une des implémentations KDS | **GARDER** - Consolider |

#### Location B: `/lib/src/screens/kitchen/`
| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| `kitchen_screen.dart` | Screen | ✅ **ACTIF** | Implémentation WebSocket | **GARDER** - À fusionner? |

#### Location C: `/lib/screens/kitchen_tablet/`
| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| `kitchen_tablet_screen.dart` | Screen | ✅ **ACTIF** | 3 colonnes (Pending/Preparing/Ready) | **GARDER** - Version moderne |
| `kitchen_tablet_order_card.dart` | Widget | ✅ **ACTIF** | Card component | **GARDER** |
| `kitchen_tablet_status_chip.dart` | Widget | ✅ **ACTIF** | Status chip | **GARDER** |

#### Location D: `/lib/src/kitchen/` (Legacy?)
| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| `kitchen_page.dart` | Screen | ⚠️ **LEGACY** | 477 lignes - Ancien système? | **ÉVALUER** - Probablement supprimer |
| `kitchen_constants.dart` | Constants | ✅ **ACTIF** | Constantes réutilisables | **GARDER** |
| `services/kitchen_notifications.dart` | Service | ✅ **ACTIF** | Service notifications | **GARDER** |
| `services/kitchen_print_stub.dart` | Service | ⚠️ **STUB** | Stub pour impression | **GARDER** - Fonctionnel |
| `widgets/kitchen_colors.dart` | Constants | ✅ **ACTIF** | Thème kitchen | **GARDER** - À adapter ShopCaisse |
| `widgets/kitchen_order_card.dart` | Widget | ⚠️ **DOUBLON?** | Doublon kitchen_tablet_order_card? | **ÉVALUER** |
| `widgets/kitchen_order_detail.dart` | Widget | ✅ **ACTIF** | Détails commande | **GARDER** |
| `widgets/kitchen_status_badge.dart` | Widget | ⚠️ **DOUBLON?** | Doublon kitchen_tablet_status_chip? | **ÉVALUER** |

### 🔵 CATÉGORIE 4: Écrans isolés (possibles orphelins)

| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| `/lib/src/screens/pos/pos_home_screen.dart` | Screen | ⚠️ **MINIMAL** | Écran minimaliste sans logique | **ÉVALUER** - Nécessaire? |

### 🟣 CATÉGORIE 5: Services et Adapters POS

| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| `/lib/src/services/pos_order_service.dart` | Service | ✅ **ACTIF** | Service commandes POS | **GARDER** |
| `/lib/src/services/kds_service.dart` | Service | ✅ **ACTIF** | Service KDS | **GARDER** |
| `/lib/src/services/cashier_session_service.dart` | Service | ✅ **ACTIF** | Service sessions caisse | **GARDER** |
| `/lib/src/services/adapters/kitchen_adapter.dart` | Adapter | ✅ **ACTIF** | Adaptateur kitchen | **GARDER** |
| `/lib/src/services/adapters/staff_tablet_adapter.dart` | Adapter | ✅ **ACTIF** | Adaptateur staff tablet | **GARDER** |
| `/lib/services/runtime/kitchen_orders_runtime_service.dart` | Service | ✅ **ACTIF** | Service runtime kitchen | **GARDER** |

### 🟠 CATÉGORIE 6: Models POS

| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| `/lib/src/models/pos_order.dart` | Model | ✅ **ACTIF** | Modèle commande POS | **GARDER** |
| `/lib/src/models/pos_order_status.dart` | Model | ✅ **ACTIF** | Statuts commande | **GARDER** |
| `/lib/src/models/cashier_session.dart` | Model | ✅ **ACTIF** | Session caissier | **GARDER** |

### ⚪ CATÉGORIE 7: Providers centraux

| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| `/lib/src/providers/kds_provider.dart` | Provider | ✅ **ACTIF** | Provider KDS | **GARDER** - Fix Riverpod |

### 🔶 CATÉGORIE 8: White-Label Module Definitions

| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| `/lib/white_label/modules/operations/pos/pos_module_config.dart` | Config | ✅ **ACTIF** | Config module POS | **GARDER** |
| `/lib/white_label/modules/operations/pos/pos_module_definition.dart` | Definition | ✅ **ACTIF** | Définition module | **GARDER** |
| `/lib/white_label/modules/operations/kitchen_tablet/kitchen_tablet_module_config.dart` | Config | ⚠️ **DEPRECATED** | Ancien - POS gère tout | **VÉRIFIER** |
| `/lib/white_label/modules/operations/kitchen_tablet/kitchen_tablet_module_definition.dart` | Definition | ⚠️ **DEPRECATED** | Ancien - POS gère tout | **VÉRIFIER** |
| `/lib/white_label/modules/operations/staff_tablet/staff_tablet_module_config.dart` | Config | ⚠️ **DEPRECATED** | Ancien - POS gère tout | **VÉRIFIER** |
| `/lib/white_label/modules/operations/staff_tablet/staff_tablet_module_definition.dart` | Definition | ⚠️ **DEPRECATED** | Ancien - POS gère tout | **VÉRIFIER** |

### 🔷 CATÉGORIE 9: Builder Integration (Should NOT exist)

| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| `/lib/builder/runtime/modules/kitchen_module_widget.dart` | Widget | ⚠️ **INCORRECT** | POS = system module, pas dans Builder | **VÉRIFIER** - Ne doit pas être exposé |
| `/lib/builder/runtime/modules/staff_module_widget.dart` | Widget | ⚠️ **INCORRECT** | POS = system module, pas dans Builder | **VÉRIFIER** - Ne doit pas être exposé |

### 🔸 CATÉGORIE 10: Legacy/Archived Modules

| Fichier | Type | Statut | Problème | Action |
|---------|------|--------|----------|--------|
| `/lib/modules/kitchen_tablet/kitchen_tablet_module.dart` | Module | ⚠️ **LEGACY** | Ancien système module | **ÉVALUER** - Probablement supprimer |
| `/lib/modules/kitchen_tablet/kitchen_tablet_routes.dart` | Routes | ⚠️ **LEGACY** | Anciennes routes | **ÉVALUER** - Probablement supprimer |

---

## 🔍 ANALYSE DES ROUTES

### Routes principales définies
```dart
// Dans /lib/src/core/constants.dart
static const String pos = '/pos';                               // ✅ Route POS principale
static const String kitchen = '/kitchen';                       // ✅ Route Kitchen
static const String staffTabletPin = '/staff-tablet';          // ✅ Staff Tablet Entry
static const String staffTabletCatalog = '/staff-tablet/catalog';
static const String staffTabletCheckout = '/staff-tablet/checkout';
static const String staffTabletHistory = '/staff-tablet/history';
```

### Mapping dans main.dart
```dart
// POS Route - Ligne 607-617
GoRoute(path: AppRoutes.pos, builder: (context, state) {
  return ModuleAndRoleGuard(
    module: ModuleId.pos,        // ✅ Correctement gated par ModuleId.pos
    requiresAdmin: true,
    child: const PosScreen(),
  );
})

// Kitchen Route - Ligne 492 (estimée)
GoRoute(path: '/kitchen', builder: (context, state) {
  return ModuleAndRoleGuard(
    module: ModuleId.pos,        // ✅ Correctement gated par ModuleId.pos
    requiresAdmin: true,
    child: const KitchenScreen(),
  );
})

// Staff Tablet Routes - Lignes 536-605
// Toutes les routes staff-tablet utilisent ModuleId.pos ✅
```

### ✅ État de la navigation
- **CONFORME**: Toutes les routes POS/Kitchen/Staff sont correctement gatées par `ModuleId.pos`
- **AUCUNE RÉGRESSION**: L'architecture module est respectée
- **PROBLÈME IDENTIFIÉ**: Aucun problème majeur de routing

---

## 🔗 ANALYSE DES PROVIDERS

### Providers POS à vérifier pour issues Riverpod

| Provider | Fichier | Risque Override |
|----------|---------|-----------------|
| `posCartProvider` | `pos_cart_provider.dart` | ⚠️ **À VÉRIFIER** |
| `posStateProvider` | `pos_state_provider.dart` | ⚠️ **À VÉRIFIER** |
| `posSessionProvider` | `pos_session_provider.dart` | ⚠️ **À VÉRIFIER** |
| `posOrderProvider` | `pos_order_provider.dart` | ⚠️ **À VÉRIFIER** |
| `paymentProvider` | `pos_payment_provider.dart` | ⚠️ **À VÉRIFIER** |
| `kdsProvider` | `kds_provider.dart` | ⚠️ **À VÉRIFIER** |
| `staffTabletAuthProvider` | `staff_tablet_auth_provider.dart` | ⚠️ **À VÉRIFIER** |
| `staffTabletCartProvider` | `staff_tablet_cart_provider.dart` | ⚠️ **À VÉRIFIER** |
| `staffTabletOrdersProvider` | `staff_tablet_orders_provider.dart` | ⚠️ **À VÉRIFIER** |
| `activeCashierSessionProvider` | `pos_session_provider.dart` | ⚠️ **À VÉRIFIER** |

### Pattern à rechercher
```dart
// ❌ MAUVAIS: Provider lu depuis override sans dependencies
final value = ref.watch(someProvider);
// Context override sans déclarer dependencies: [someProvider]

// ✅ BON: Provider avec dependencies déclarées
@Riverpod(dependencies: [someProvider])
```

---

## 🎯 IDENTIFICATION DES DOUBLONS

### 🔴 **DOUBLONS CONFIRMÉS** (À supprimer)

1. **POS Actions Panel**
   - ❌ `pos_actions_panel.dart` (V1)
   - ✅ `pos_actions_panel_v2.dart` (Version active)
   - **Action**: Supprimer V1

2. **POS Cart Panel**
   - ❌ `pos_cart_panel.dart` (V1)
   - ✅ `pos_cart_panel_v2.dart` (Version active)
   - **Action**: Supprimer V1

### 🟡 **DOUBLONS POSSIBLES** (À évaluer)

3. **Kitchen Order Card**
   - ⚠️ `/lib/src/kitchen/widgets/kitchen_order_card.dart`
   - ⚠️ `/lib/screens/kitchen_tablet/kitchen_tablet_order_card.dart`
   - **Action**: Comparer implémentations, fusionner si identiques

4. **Kitchen Status Components**
   - ⚠️ `/lib/src/kitchen/widgets/kitchen_status_badge.dart`
   - ⚠️ `/lib/screens/kitchen_tablet/kitchen_tablet_status_chip.dart`
   - **Action**: Comparer, fusionner si identiques

5. **Kitchen Screens**
   - ⚠️ `/lib/src/kitchen/kitchen_page.dart` (477 lignes - Legacy?)
   - ⚠️ `/lib/src/screens/kitchen/kitchen_screen.dart` (359 lignes - WebSocket)
   - ⚠️ `/lib/screens/kitchen_tablet/kitchen_tablet_screen.dart` (366 lignes - 3 colonnes)
   - ⚠️ `/lib/src/screens/kds/kds_screen.dart` (411 lignes)
   - **Action**: **CRITIQUE** - 4 implémentations différentes du même concept!

6. **Customization Modals**
   - `/lib/src/screens/admin/pos/widgets/pos_menu_customization_modal.dart`
   - `/lib/src/screens/admin/pos/widgets/pos_pizza_customization_modal.dart`
   - `/lib/src/staff_tablet/widgets/staff_menu_customization_modal.dart`
   - `/lib/src/staff_tablet/widgets/staff_pizza_customization_modal.dart`
   - **Action**: Vérifier si possibilité de factoriser un composant commun

---

## 🏗️ ARCHITECTURE ACTUELLE

### Structure recommandée (Source unique de vérité)

```
lib/
├── src/
│   ├── screens/
│   │   └── admin/
│   │       └── pos/                          # 📍 POINT D'ENTRÉE POS PRINCIPAL
│   │           ├── pos_screen.dart           # Écran principal caisse
│   │           ├── pos_shell_scaffold.dart   # Layout shell
│   │           ├── pos_routes.dart           # Routes POS
│   │           ├── providers/                # Providers POS
│   │           │   ├── pos_cart_provider.dart
│   │           │   ├── pos_order_provider.dart
│   │           │   ├── pos_payment_provider.dart
│   │           │   ├── pos_session_provider.dart
│   │           │   └── pos_state_provider.dart
│   │           └── widgets/                  # Widgets POS
│   │               ├── pos_actions_panel_v2.dart
│   │               ├── pos_cart_panel_v2.dart
│   │               ├── pos_cash_payment_modal.dart
│   │               ├── pos_catalog_view.dart
│   │               └── [modals...]
│   │
│   ├── staff_tablet/                         # 📍 STAFF TABLET (Partie du POS)
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── kitchen/                              # 📍 KITCHEN DISPLAYS
│   │   ├── (À CONSOLIDER)                    # ⚠️ Multiples implémentations à fusionner
│   │   └── widgets/
│   │
│   ├── services/
│   │   ├── pos_order_service.dart
│   │   ├── kds_service.dart
│   │   ├── cashier_session_service.dart
│   │   └── adapters/
│   │
│   └── models/
│       ├── pos_order.dart
│       ├── pos_order_status.dart
│       └── cashier_session.dart
│
└── white_label/
    └── modules/
        └── operations/
            └── pos/                          # Module WL POS
                ├── pos_module_config.dart
                └── pos_module_definition.dart
```

---

## 🚨 PROBLÈMES IDENTIFIÉS

### 1. ❌ **ARCHITECTURE: Doublons V1/V2**
- **Fichiers**: `pos_actions_panel.dart`, `pos_cart_panel.dart`
- **Impact**: Confusion, risque d'utiliser mauvaise version
- **Solution**: Supprimer versions V1

### 2. ⚠️ **ARCHITECTURE: 4 implémentations Kitchen différentes**
- **Fichiers**: 
  - `kitchen_page.dart` (legacy?)
  - `kitchen_screen.dart` (WebSocket)
  - `kitchen_tablet_screen.dart` (3 colonnes moderne)
  - `kds_screen.dart` (KDS)
- **Impact**: Confusion totale sur quelle version utiliser
- **Solution**: **Consolider en 1-2 écrans maximum**
  - Option A: Garder `kitchen_tablet_screen.dart` (3 colonnes) + `kitchen_screen.dart` (WebSocket)
  - Option B: Fusionner en un seul écran avec toggle WebSocket

### 3. ⚠️ **UI/UX: Thème rouge dominant**
- **Impact**: Pas premium, pas ShopCaisse
- **Solution**: Phase 3 - Refonte complète avec #5557F6

### 4. ⚠️ **RIVERPOD: Possibles erreurs override**
- **Impact**: Crashes runtime
- **Solution**: Phase 2 - Audit provider par provider

### 5. ⚠️ **BUILDER: Modules POS exposés**
- **Fichiers**: `kitchen_module_widget.dart`, `staff_module_widget.dart`
- **Impact**: POS accessible dans Builder (violation WL doctrine)
- **Solution**: Vérifier que ces widgets ne sont jamais exposés

### 6. ⚠️ **LEGACY: Anciens modules à nettoyer**
- **Fichiers**: `modules/kitchen_tablet/*`, module definitions deprecated
- **Impact**: Code mort qui pollue
- **Solution**: Nettoyer après validation qu'ils ne sont plus utilisés

---

## ✅ POINTS FORTS ACTUELS

1. ✅ **Module normalization**: POS est bien un module unique système
2. ✅ **Routing**: Toutes routes correctement gatées par `ModuleId.pos`
3. ✅ **Services**: Architecture services bien séparée
4. ✅ **Models**: Modèles POS bien définis
5. ✅ **White-Label**: Integration WL correcte (sauf Builder widgets)

---

## 📋 RECOMMANDATIONS PHASE 1

### Action immédiate: Source unique de vérité

#### **GARDER** (Fichiers actifs principaux)
```
✅ /lib/src/screens/admin/pos/                 # Point d'entrée POS
✅ /lib/src/staff_tablet/                      # Interface staff
✅ /lib/src/services/*_service.dart            # Services
✅ /lib/src/models/pos_*.dart                  # Modèles
✅ /lib/white_label/modules/operations/pos/    # Module WL
```

#### **SUPPRIMER** (Doublons confirmés)
```
❌ /lib/src/screens/admin/pos/widgets/pos_actions_panel.dart (V1)
❌ /lib/src/screens/admin/pos/widgets/pos_cart_panel.dart (V1)
```

#### **ÉVALUER & CONSOLIDER** (Kitchen)
```
⚠️ Décision requise sur les 4 implémentations Kitchen:
   - kitchen_page.dart (477L)
   - kitchen_screen.dart (359L)
   - kitchen_tablet_screen.dart (366L)
   - kds_screen.dart (411L)

Recommandation: Garder kitchen_tablet_screen.dart (moderne, 3 colonnes)
                Supprimer ou marquer deprecated les autres versions
```

#### **NETTOYER** (Legacy)
```
🗑️ /lib/modules/kitchen_tablet/*               # Ancien système (si non utilisé)
🗑️ Deprecated module definitions (si non utilisées)
```

---

## 📊 MÉTRIQUES

- **Fichiers POS totaux**: ~60 fichiers
- **Doublons confirmés**: 2 fichiers (V1 panels)
- **Doublons possibles**: 6 groupes
- **Implémentations Kitchen**: 4 (!!)
- **Providers à vérifier**: 10
- **Routes POS**: 7 routes
- **Services POS**: 6 services

---

## ✅ LIVRABLE PHASE 1 (Ce document)

Ce document constitue l'inventaire complet demandé avec:
- ✅ Tableau complet des fichiers par catégorie
- ✅ Statut (utilisé/legacy/doublon) pour chaque fichier
- ✅ Problèmes identifiés
- ✅ Actions recommandées (garder/fusionner/supprimer)
- ✅ Proposition source unique de vérité
- ✅ Architecture recommandée

**NEXT**: Phase 2 - Fix stabilité (Riverpod providers audit)
