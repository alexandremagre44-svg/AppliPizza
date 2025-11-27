# 🔐 Security Audit Report: Multi-Tenant Data Isolation

**Audit Date:** 2025-11-27  
**Scope:** `lib/src/services/` and `lib/src/repositories/`  
**Focus:** Firestore queries missing `restaurantId` (or `appId`) filtering

---

## 📊 Summary

| Status | Count |
|--------|-------|
| 🚨 CRITICAL LEAKS | 10 files |
| ✅ SECURE | 6 files |
| ⏭️ NOT APPLICABLE | 7 files |

---

## 🚨 CRITICAL DATA LEAKS

### 1. `firebase_order_service.dart`

| Line | Risky Code | Issue | Fix |
|------|-----------|-------|-----|
| 20 | `_firestore.collection('orders')` | Global collection reference without appId | Use `FirestorePaths.orders(appId)` or add appId parameter |
| 127-134 | `_ordersCollection.orderBy('createdAt', descending: true).snapshots()` | `watchAllOrders()` fetches ALL orders across ALL restaurants | Add `.where('restaurantId', isEqualTo: appId)` |
| 206-215 | `_ordersCollection.where('status', isEqualTo: status)...` | `watchOrdersByStatus()` fetches orders WITHOUT restaurantId filter | Add `.where('restaurantId', isEqualTo: appId)` |
| 218-227 | `_ordersCollection.where('isViewed', isEqualTo: false)...` | `watchUnviewedOrders()` fetches unviewed orders WITHOUT restaurantId filter | Add `.where('restaurantId', isEqualTo: appId)` |

**Impact:** Admin/Kitchen users can see orders from ALL restaurants in the shared database.

---

### 2. `firestore_product_service.dart`

| Line | Risky Code | Issue | Fix |
|------|-----------|-------|-----|
| 172-174 | `_firestore.collection(collectionName).get()` | `loadProductsByCategory()` fetches from global collections (pizzas, menus, drinks, desserts) | Use `restaurants/{appId}/products/{category}` path or add restaurantId filter |
| 212-214 | `_firestore.collection(collectionName).snapshots()` | `watchProductsByCategory()` streams products globally | Use `restaurants/{appId}/products/{category}` path or add restaurantId filter |

**Impact:** Products from all restaurants are visible/merged together.

---

### 3. `user_profile_service.dart`

| Line | Risky Code | Issue | Fix |
|------|-----------|-------|-----|
| 19 | `_firestore.collection('user_profiles')` | Global collection reference | Use `restaurants/{appId}/user_profiles` or add restaurantId field |
| 89-91 | `_profilesCollection.get()` | `getAllUserProfiles()` fetches ALL user profiles from the entire database | Add `.where('restaurantId', isEqualTo: appId)` or use scoped collection path |

**Impact:** Admin can see ALL user profiles across ALL restaurants - major privacy violation.

---

### 4. `loyalty_service.dart`

| Line | Risky Code | Issue | Fix |
|------|-----------|-------|-----|
| 17 | `_firestore.collection('users')` | Global users collection for loyalty data | Use `restaurants/{appId}/users` or add restaurantId field to filter |
| 21-47 | `_usersCollection.doc(uid).get()` and `.set()` | `initializeLoyalty()` operates on global users collection | Scope to restaurant-specific users |
| 52-103 | `_usersCollection.doc(uid).update()` | `addPointsFromOrder()` updates global users collection | Scope to restaurant-specific users |

**Impact:** Loyalty points and VIP tiers are shared/mixed across restaurants.

---

### 5. `roulette_rules_service.dart`

| Line | Risky Code | Issue | Fix |
|------|-----------|-------|-----|
| 146-160 | `_firestore.collection('config').doc('roulette_rules').get()` | `getRules()` reads from global config | Use `restaurants/{appId}/config/roulette_rules` |
| 163-174 | `_firestore.collection('config').doc('roulette_rules').set()` | `saveRules()` writes to global config | Use `restaurants/{appId}/config/roulette_rules` |
| 205-219 | `_firestore.collection('users').doc(userId).get()` | `checkEligibility()` reads from global users collection | Use scoped users collection |
| 289-320 | `_firestore.collection('roulette_history')...` | `recordSpinAudit()` writes to global collection | Use `restaurants/{appId}/roulette_history` |

**Impact:** All restaurants share the same roulette rules; spin history is mixed.

---

### 6. `roulette_service.dart`

| Line | Risky Code | Issue | Fix |
|------|-----------|-------|-----|
| 33 | `_firestore.collection('user_roulette_spins').add({...})` | `recordSpin()` writes to global collection | Use `restaurants/{appId}/user_roulette_spins` |
| 44 | `_firestore.collection('roulette_rate_limit').doc(userId)` | Rate limit tracking is global | Use `restaurants/{appId}/roulette_rate_limit` |
| 57-68 | `_firestore.collection('user_roulette_spins').where('userId', isEqualTo: userId)...` | `getUserSpinHistory()` queries global collection | Add restaurantId filter or use scoped collection |

**Impact:** Roulette spin history from all restaurants is mixed together.

---

### 7. `roulette_segment_service.dart`

| Line | Risky Code | Issue | Fix |
|------|-----------|-------|-----|
| 19 | `static const String _collection = 'roulette_segments'` | Uses global collection name | Use `restaurants/{appId}/roulette_segments` |
| 29-55 | `_firestore.collection(_collection).get()` | `getAllSegments()` fetches from global collection | Use scoped collection path |
| 65-94 | `_firestore.collection(_collection).where('isActive', isEqualTo: true).get()` | `getActiveSegments()` fetches from global collection | Use scoped collection path |

**Impact:** Roulette wheel segments are shared across all restaurants.

---

### 8. `roulette_settings_service.dart`

| Line | Risky Code | Issue | Fix |
|------|-----------|-------|-----|
| 15-16 | `static const String _collection = 'config'` and `_docId = 'roulette_settings'` | Uses global config path | Use `restaurants/{appId}/config/roulette_settings` |
| 21-38 | `_firestore.collection(_collection).doc(_docId).get()` | `getLimitSeconds()` reads from global config | Use scoped config path |
| 45-61 | `_firestore.collection(_collection).doc(_docId).set()` | `updateLimitSeconds()` writes to global config | Use scoped config path |

**Impact:** All restaurants share the same roulette rate limit settings.

---

### 9. `firestore_ingredient_service.dart`

| Line | Risky Code | Issue | Fix |
|------|-----------|-------|-----|
| 42 | `static const String _collectionName = 'ingredients'` | Uses global collection name | Use `restaurants/{appId}/ingredients` |
| 44-66 | `_firestore.collection(_collectionName).get()` | `loadIngredients()` fetches from global collection | Use scoped collection path |
| 122-143 | `_firestore.collection(_collectionName).snapshots()` | `watchIngredients()` streams from global collection | Use scoped collection path |

**Impact:** Ingredients are shared across all restaurants.

---

### 10. `product_repository.dart`

| Line | Risky Code | Issue | Fix |
|------|-----------|-------|-----|
| 20-21 | Uses `FirestoreProductServiceImpl()` | Repository uses the insecure FirestoreProductService | Inject appId and use scoped paths |
| 47-55 | Calls `_firestoreService.loadPizzas()`, etc. | Loads products without restaurant scope | Pass appId to service methods |

**Impact:** Product repository merges products from all restaurants.

---

## ✅ SECURE FILES

The following files correctly use `FirestorePaths` with `appId` parameter:

| File | Status | Notes |
|------|--------|-------|
| `banner_service.dart` | ✅ SECURE | Uses `FirestorePaths.banners()` |
| `popup_service.dart` | ✅ SECURE | Uses `FirestorePaths.popups()` |
| `promotion_service.dart` | ✅ SECURE | Constructor requires `appId`, uses `FirestorePaths.promotions(appId)` |
| `home_config_service.dart` | ✅ SECURE | Constructor requires `appId`, uses `FirestorePaths.homeConfigDoc(appId)` |
| `loyalty_settings_service.dart` | ✅ SECURE | Uses `FirestorePaths.loyaltySettingsDoc()` |
| `theme_service.dart` | ✅ SECURE | Uses `FirestorePaths.themeDoc()` |

---

## ⏭️ NOT APPLICABLE

The following files use local storage (SharedPreferences) or are deprecated - not in scope for Firestore multi-tenant audit:

| File | Reason |
|------|--------|
| `order_service.dart` | DEPRECATED - Uses SharedPreferences only |
| `auth_service.dart` | DEPRECATED - Uses SharedPreferences only |
| `campaign_service.dart` | Uses SharedPreferences only |
| `mailing_service.dart` | Uses SharedPreferences only |
| `product_crud_service.dart` | Uses SharedPreferences only |
| `business_metrics_service.dart` | Static utility methods, no database access |
| `api_service.dart` | External API service |
| `email_template_service.dart` | External service |
| `image_upload_service.dart` | External storage service |
| `app_texts_service.dart` | Text configuration |
| `firebase_auth_service.dart` | Authentication (user scope, not restaurant scope) |

> ⚠️ **Note on Deprecated Services:** `order_service.dart` and `auth_service.dart` are marked as DEPRECATED. These should be removed once all consumers have migrated to their Firebase replacements (`FirebaseOrderService` and `FirebaseAuthService`) to reduce maintenance burden and eliminate potential security risks from accidental usage.

---

## 🔧 Recommended Fix Pattern

For each service requiring a fix, follow this pattern:

### Option 1: Add `appId` as Constructor Parameter

```dart
class FirebaseOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;

  // Constructor with required appId parameter
  FirebaseOrderService({required this.appId});

  CollectionReference get _ordersCollection => 
      _firestore.collection('restaurants').doc(appId).collection('orders');
}
```

### Option 2: Use FirestorePaths Utility

```dart
// In FirestorePaths, add:
static CollectionReference<Map<String, dynamic>> orders(String appId) {
  return restaurantDoc(appId).collection('orders');
}

// In service:
final orders = await FirestorePaths.orders(appId)
    .orderBy('createdAt', descending: true)
    .get();
```

### Option 3: Add restaurantId Field + Query Filter

```dart
// When creating order, add:
'restaurantId': appId,

// When querying:
_ordersCollection
    .where('restaurantId', isEqualTo: appId)
    .orderBy('createdAt', descending: true)
    .snapshots()
```

---

## 📋 Priority Action Items

1. **CRITICAL:** Fix `firebase_order_service.dart` - orders are the most sensitive data
2. **CRITICAL:** Fix `user_profile_service.dart` - user privacy violation
3. **HIGH:** Fix `firestore_product_service.dart` - products are core business data
4. **HIGH:** Fix `loyalty_service.dart` - financial impact (points, rewards)
5. **MEDIUM:** Fix roulette services - gaming/promotional features
6. **MEDIUM:** Fix `firestore_ingredient_service.dart` - menu configuration

---

*Report generated by Security Audit Tool*
