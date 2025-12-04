# Migration des Références Firestore Globales vers Multi-Restaurant

## 🎯 Objectif
Remplacer toutes les références Firestore globales par des références multi-restaurants pour garantir l'isolation complète des données entre restaurants.

## ✅ Services Migrés dans ce Commit

### 1. **RewardService** 🔧
**Fichier**: `lib/src/services/reward_service.dart`

**Avant** (Collection globale):
```dart
class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Accès: users/{userId}/rewardTickets/{ticketId}
  _firestore.collection('users').doc(userId).collection('rewardTickets')
}
```

**Après** (Collection scopée par restaurant):
```dart
class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;
  
  RewardService({required this.appId});
  
  // Accès: restaurants/{appId}/reward_tickets/{userId}/tickets/{ticketId}
  _firestore
    .collection('restaurants')
    .doc(appId)
    .collection('reward_tickets')
    .doc(userId)
    .collection('tickets')
}
```

**Provider créé**:
```dart
final rewardServiceProvider = Provider<RewardService>((ref) {
  final appId = ref.watch(currentRestaurantProvider).id;
  return RewardService(appId: appId);
});
```

**Impact**: Tous les tickets de récompense sont maintenant isolés par restaurant.

---

### 2. **PopupService** 🔧
**Fichier**: `lib/src/services/popup_service.dart`

**Collections modifiées**:
- `user_popup_views` → `restaurants/{appId}/user_popup_views`

**Avant**:
```dart
await _firestore
  .collection('user_popup_views')
  .doc('${userId}_${popup.id}')
  .get();
```

**Après**:
```dart
await _firestore
  .collection('restaurants')
  .doc(appId)
  .collection('user_popup_views')
  .doc('${userId}_${popup.id}')
  .get();
```

**Impact**: Le tracking des popups vus par les utilisateurs est maintenant scopé par restaurant.

---

## ✅ Services Déjà Conformes (Pas de Changements)

### Collections Multi-Restaurant Existantes

1. **FirestoreProductService** ✅
   - Chemin: `restaurants/{appId}/pizzas`, `menus`, `drinks`, `desserts`
   - Déjà migré

2. **FirestoreIngredientService** ✅
   - Chemin: `restaurants/{appId}/ingredients`
   - Déjà migré

3. **FirebaseOrderService** ✅
   - Chemin: `restaurants/{appId}/orders`
   - Déjà migré

4. **PromotionService** ✅
   - Chemin: `restaurants/{appId}/builder_settings/promotions/items`
   - Déjà migré

5. **HomeConfigService** ✅
   - Chemin: `restaurants/{appId}/builder_settings/home_config`
   - Déjà migré

6. **LoyaltyService** ✅
   - Chemin: `restaurants/{appId}/users`
   - Déjà migré

7. **UserProfileService** ✅
   - Chemin: `restaurants/{appId}/user_profiles`
   - Déjà migré

8. **AppTextsService** ✅
   - Chemin: `restaurants/{appId}/builder_settings/app_texts`
   - Déjà migré

9. **PopupService** ✅
   - Chemin: `restaurants/{appId}/builder_settings/popups/items`
   - Déjà migré

10. **BannerService** ✅
    - Chemin: `restaurants/{appId}/builder_settings/banners/items`
    - Déjà migré

11. **LoyaltySettingsService** ✅
    - Chemin: `restaurants/{appId}/builder_settings/loyalty_settings`
    - Déjà migré

12. **RouletteRulesService** ✅
    - Chemin: `restaurants/{appId}/config/roulette_rules`
    - Chemin: `restaurants/{appId}/users`
    - Chemin: `restaurants/{appId}/roulette_history`
    - Déjà migré

13. **ThemeService** (Builder) ✅
    - Chemin: `restaurants/{appId}/theme_draft`
    - Chemin: `restaurants/{appId}/theme_published`
    - Déjà conforme

---

## 📋 Collections Globales Intentionnelles (À NE PAS Modifier)

Ces collections restent globales car elles servent à des fins cross-restaurant:

### 1. **users** (Authentication/Roles) 🔒
**Fichier**: `lib/src/services/firebase_auth_service.dart`
**Chemin**: `users/{userId}`
**Raison**: Gestion globale de l'authentification et des rôles utilisateurs cross-restaurant

### 2. **apps** (SuperAdmin) 🔒
**Fichier**: `lib/builder/utils/app_context.dart`
**Chemin**: `apps/{appId}`
**Raison**: Liste des restaurants disponibles pour les super-admins

### 3. **user_popup_views** (Déplacé) ✅
Maintenant scopé par restaurant: `restaurants/{appId}/user_popup_views`

---

## 📊 Structure Firestore Finale

```
firestore/
├── users/                              # Global (auth/roles)
│   └── {userId}/
│       ├── role: string
│       ├── email: string
│       └── appId: string (for admin_resto)
│
├── apps/                               # Global (superadmin)
│   └── {appId}/
│       ├── name: string
│       ├── description: string
│       └── isActive: boolean
│
└── restaurants/                        # Multi-tenant root
    └── {appId}/                        # Restaurant-specific data
        ├── pizzas/                     # Products
        ├── menus/
        ├── drinks/
        ├── desserts/
        ├── ingredients/                # Ingredients
        ├── orders/                     # Orders
        ├── user_profiles/              # User profiles (scoped)
        ├── users/                      # Loyalty data (scoped)
        ├── reward_tickets/             # Reward tickets (NEW)
        │   └── {userId}/
        │       └── tickets/
        │           └── {ticketId}
        ├── user_popup_views/           # Popup tracking (NEW)
        ├── roulette_history/           # Roulette audit trail
        ├── config/
        │   └── roulette_rules          # Roulette rules
        ├── builder_settings/
        │   ├── home_config             # Home page config
        │   ├── app_texts               # App texts
        │   ├── loyalty_settings        # Loyalty settings
        │   ├── theme                   # Theme config
        │   ├── banners/items/          # Banners
        │   ├── popups/items/           # Popups
        │   └── promotions/items/       # Promotions
        ├── theme_draft/                # Builder theme draft
        ├── theme_published/            # Builder theme published
        ├── pages_draft/                # Builder pages draft
        ├── pages_published/            # Builder pages published
        ├── builder_pages/              # Builder page metadata
        └── builder_blocks/             # Builder block templates
```

---

## 🔍 Méthodologie de Migration

Pour chaque service identifié:

1. **Analyse**: Identifier les références `_firestore.collection('...')` sans `restaurants/{appId}`
2. **Validation**: Vérifier si la collection doit être globale (auth, superadmin) ou scopée
3. **Modification**: Ajouter `appId` au constructeur
4. **Mise à jour**: Remplacer les chemins par `restaurants/{appId}/...`
5. **Provider**: Créer un provider Riverpod qui injecte `appId` depuis `currentRestaurantProvider`
6. **Test**: Vérifier que les données sont correctement isolées

---

## ✅ Résultat Final

**100% des services applicatifs** utilisent maintenant le schéma multi-restaurant.

**Isolation complète**: Chaque restaurant a ses propres données:
- ✅ Produits (pizzas, menus, drinks, desserts)
- ✅ Ingrédients
- ✅ Commandes
- ✅ Profils utilisateurs
- ✅ Fidélité
- ✅ Tickets de récompense (NOUVEAU)
- ✅ Vues de popups (NOUVEAU)
- ✅ Promotions
- ✅ Configuration home
- ✅ Textes de l'app
- ✅ Paramètres de fidélité
- ✅ Banners
- ✅ Popups
- ✅ Roulette (rules, history)
- ✅ Thèmes (Builder)
- ✅ Pages (Builder)

**Collections globales maintenues** (intentionnel):
- 🔒 `users` - Authentication/Roles cross-restaurant
- 🔒 `apps` - Liste des restaurants (SuperAdmin)

---

## 🚀 Impact

**Avant cette migration**:
- Risque de fuite de données entre restaurants
- Tickets de récompense partagés entre restaurants
- Vues de popups non isolées

**Après cette migration**:
- ✅ Isolation totale des données
- ✅ Chaque restaurant est un tenant indépendant
- ✅ Pas de risque de collision de données
- ✅ Support multi-restaurant natif

---

**Date**: 2025-12-04
**Status**: ✅ COMPLET
**Services migrés**: 2 (RewardService, PopupService - user_popup_views)
**Services déjà conformes**: 13
**Collections globales maintenues**: 2 (intentionnel)
