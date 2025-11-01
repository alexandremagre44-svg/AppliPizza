# 🔥 Guide d'Intégration Firebase - Pizza Deli'Zza

## 📋 Vue d'Ensemble

Ce guide explique comment Firebase est intégré dans l'application et comment l'utiliser.

---

## ✅ Configuration Actuelle

### Fichiers Modifiés
1. **pubspec.yaml** - Dépendances Firebase ajoutées
2. **lib/main.dart** - Firebase initialisé au démarrage
3. **lib/firebase_options.dart** - Configuration générée par FlutterFire CLI

### Dépendances Installées
```yaml
firebase_core: ^2.24.2        # Core Firebase
cloud_firestore: ^4.13.6      # Base de données NoSQL
firebase_auth: ^4.15.3        # Authentification
```

---

## 🏗️ Structure Firestore

### Collections Firestore

```
📁 Firestore Database
│
├── 📂 orders/                    # Commandes
│   ├── 📄 {orderId}
│   │   ├── id: String
│   │   ├── total: Number
│   │   ├── date: Timestamp
│   │   ├── status: String
│   │   ├── userId: String (optionnel)
│   │   └── items: Array
│   │       └── [{productId, productName, price, quantity, ...}]
│
├── 📂 pizzas/                    # Pizzas
│   └── 📄 {pizzaId}
│       ├── id: String
│       ├── name: String
│       ├── description: String
│       ├── price: Number
│       ├── imageUrl: String
│       ├── category: String
│       ├── isMenu: Boolean
│       └── baseIngredients: Array
│
├── 📂 menus/                     # Menus
│   └── 📄 {menuId}
│       ├── id: String
│       ├── name: String
│       ├── description: String
│       ├── price: Number
│       ├── imageUrl: String
│       ├── pizzaCount: Number
│       └── drinkCount: Number
│
├── 📂 users/                     # Utilisateurs
│   └── 📄 {userId}
│       ├── id: String
│       ├── name: String
│       ├── email: String
│       ├── role: String (admin/client)
│       ├── isBlocked: Boolean
│       └── createdAt: Timestamp
│
├── 📂 settings/                  # Paramètres
│   └── 📄 app_config
│       ├── deliveryFee: Number
│       ├── minimumOrderAmount: Number
│       ├── estimatedDeliveryTime: Number
│       └── deliveryZone: String
│
├── 📂 business_hours/            # Horaires
│   ├── 📄 {dayId}
│   │   ├── dayOfWeek: String
│   │   ├── openTime: String
│   │   ├── closeTime: String
│   │   └── isClosed: Boolean
│   │
│   └── 📂 exceptional_closures/
│       └── 📄 {closureId}
│           ├── date: Timestamp
│           └── reason: String
│
└── 📂 promo_codes/               # Codes Promo
    └── 📄 {promoId}
        ├── code: String
        ├── discount: Number
        ├── fixedDiscount: Number (optionnel)
        ├── expiryDate: Timestamp (optionnel)
        ├── usageLimit: Number (optionnel)
        ├── usageCount: Number
        └── isActive: Boolean
```

---

## 🔄 Migration Progressive

### Phase 1 : Commandes (Implémentée) ✅

**Service créé:** `FirestoreOrderService`

**Fonctionnalités:**
- ✅ Sauvegarde des commandes dans Firestore
- ✅ Lecture en temps réel
- ✅ Mise à jour du statut
- ✅ Filtres par date et statut
- ✅ Statistiques en temps réel

**Utilisation:**
```dart
// Dans admin_orders_screen.dart
final orderService = FirestoreOrderService();

// Charger les commandes
final orders = await orderService.loadAllOrders();

// Ajouter une commande
await orderService.addOrder(newOrder);

// Mettre à jour le statut
await orderService.updateOrderStatus(orderId, 'En livraison');
```

### Phase 2 : Produits (Pizzas & Menus)

**À implémenter:** `FirestoreProductService`

**Fonctionnalités prévues:**
- Synchronisation des pizzas
- Synchronisation des menus
- Cache local pour mode hors ligne
- Mise à jour en temps réel

### Phase 3 : Utilisateurs

**À implémenter:** `FirestoreUserService` + Firebase Auth

**Fonctionnalités prévues:**
- Authentification Firebase
- Gestion des profils
- Rôles et permissions
- Historique utilisateur

### Phase 4 : Paramètres & Horaires

**À implémenter:** `FirestoreSettingsService`

**Fonctionnalités prévues:**
- Configuration centralisée
- Horaires d'ouverture
- Fermetures exceptionnelles

### Phase 5 : Promotions

**À implémenter:** `FirestorePromoService`

**Fonctionnalités prévues:**
- Gestion des codes promo
- Validation en temps réel
- Statistiques d'utilisation

---

## 📖 Exemples de Code

### Lire des Données

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Récupérer toutes les commandes
Future<List<Order>> getOrders() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('orders')
      .orderBy('date', descending: true)
      .get();
  
  return snapshot.docs.map((doc) {
    final data = doc.data();
    return Order.fromJson(data);
  }).toList();
}
```

### Écouter en Temps Réel

```dart
// Stream pour mise à jour automatique
Stream<List<Order>> ordersStream() {
  return FirebaseFirestore.instance
      .collection('orders')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Order.fromJson(doc.data());
        }).toList();
      });
}
```

### Ajouter des Données

```dart
// Ajouter une commande
Future<void> addOrder(Order order) async {
  await FirebaseFirestore.instance
      .collection('orders')
      .doc(order.id)
      .set(order.toJson());
}
```

### Mettre à Jour

```dart
// Mettre à jour le statut
Future<void> updateStatus(String orderId, String status) async {
  await FirebaseFirestore.instance
      .collection('orders')
      .doc(orderId)
      .update({'status': status});
}
```

### Filtrer

```dart
// Filtrer par statut
Future<List<Order>> getOrdersByStatus(String status) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('orders')
      .where('status', isEqualTo: status)
      .get();
  
  return snapshot.docs.map((doc) {
    return Order.fromJson(doc.data());
  }).toList();
}
```

---

## 🔒 Règles de Sécurité Firestore

**À configurer dans la Console Firebase:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAdmin() {
      return request.auth != null && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }
    
    // Commandes - Admin peut tout, utilisateurs leurs propres commandes
    match /orders/{orderId} {
      allow read: if isAdmin() || isOwner(resource.data.userId);
      allow create: if request.auth != null;
      allow update, delete: if isAdmin();
    }
    
    // Produits - Lecture publique, écriture admin uniquement
    match /pizzas/{pizzaId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    match /menus/{menuId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // Utilisateurs - Chacun peut lire/modifier son profil, admin peut tout
    match /users/{userId} {
      allow read: if isAdmin() || isOwner(userId);
      allow write: if isAdmin();
    }
    
    // Paramètres - Lecture publique, écriture admin
    match /settings/{document=**} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // Horaires - Lecture publique, écriture admin
    match /business_hours/{document=**} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // Codes Promo - Lecture publique, écriture admin
    match /promo_codes/{promoId} {
      allow read: if true;
      allow write: if isAdmin();
    }
  }
}
```

---

## 🧪 Tests et Debugging

### Console Firebase
1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Sélectionnez votre projet **delizza-appli**
3. Cliquez sur **Firestore Database**
4. Vous pouvez voir et modifier les données manuellement

### Flutter DevTools
```bash
# Vérifier les logs Firebase
flutter run --verbose

# En cas d'erreur, vérifier:
# 1. firebase_options.dart est bien généré
# 2. Firebase est initialisé dans main.dart
# 3. Les dépendances sont installées (flutter pub get)
```

---

## 💡 Bonnes Pratiques

### 1. Gestion des Erreurs
```dart
try {
  await FirebaseFirestore.instance
      .collection('orders')
      .doc(orderId)
      .set(data);
} on FirebaseException catch (e) {
  print('Erreur Firebase: ${e.code} - ${e.message}');
  // Gérer l'erreur (afficher un message, réessayer, etc.)
}
```

### 2. Cache et Mode Hors Ligne
Firestore met en cache automatiquement les données. Pour une meilleure expérience:

```dart
// Activer la persistance
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### 3. Pagination
Pour de grandes collections:

```dart
// Charger par pages de 20
Query query = FirebaseFirestore.instance
    .collection('orders')
    .orderBy('date', descending: true)
    .limit(20);

// Page suivante
var lastDocument = snapshot.docs.last;
query = query.startAfterDocument(lastDocument);
```

### 4. Transactions
Pour des opérations atomiques:

```dart
await FirebaseFirestore.instance.runTransaction((transaction) async {
  // Lire
  final snapshot = await transaction.get(docRef);
  
  // Modifier
  final newValue = snapshot.data()!['value'] + 1;
  
  // Écrire
  transaction.update(docRef, {'value': newValue});
});
```

---

## 🚀 Prochaines Étapes

### Immédiat
- [x] Firebase Core initialisé
- [x] Firestore configuré
- [x] Service commandes migré
- [ ] Tester avec données réelles

### Court Terme
- [ ] Migrer le service produits
- [ ] Implémenter Firebase Auth
- [ ] Ajouter les règles de sécurité

### Moyen Terme
- [ ] Migrer tous les services
- [ ] Mode hors ligne robuste
- [ ] Notifications push (Firebase Cloud Messaging)

### Long Terme
- [ ] Analytics Firebase
- [ ] Performance Monitoring
- [ ] Crashlytics
- [ ] Remote Config

---

## 📞 Support

**Documentation Firebase:**
- [Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [FlutterFire](https://firebase.flutter.dev)

**En cas de problème:**
1. Vérifier les logs dans la console
2. Vérifier la configuration Firebase Console
3. Vérifier les règles de sécurité Firestore

---

**Date de création:** 2025-11-01  
**Version:** 1.0.0  
**Statut:** En cours d'intégration progressive
