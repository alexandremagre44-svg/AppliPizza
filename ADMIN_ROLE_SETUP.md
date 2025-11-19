# Configuration des Rôles Admin - Pizza Deli'Zza

## Vue d'ensemble

Ce guide explique comment gérer les rôles utilisateurs (admin, client, kitchen) dans l'application Pizza Deli'Zza.

## Convention Actuelle

### Stockage du Rôle

Le rôle est stocké dans **Firestore** dans la collection `users`:

```javascript
users/{userId}
  ├─ email: string
  ├─ role: 'admin' | 'client' | 'kitchen'
  ├─ displayName: string
  ├─ createdAt: timestamp
  └─ updatedAt: timestamp
```

### Rôles Disponibles

Définis dans `lib/src/core/constants.dart`:

```dart
class UserRole {
  static const String admin = 'admin';
  static const String client = 'client';
  static const String kitchen = 'kitchen';
}
```

### Vérification du Rôle

**Côté Application (Flutter):**

```dart
// Via AuthProvider
final authState = ref.read(authProvider);
bool isAdmin = authState.isAdmin;  // vérifie userRole == 'admin'
bool isKitchen = authState.isKitchen;  // vérifie userRole == 'kitchen'
```

**Côté Firestore Rules:**

```javascript
function getUserRole() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
}

function isAdmin() {
  return isAuthenticated() && getUserRole() == 'admin';
}
```

## Créer un Utilisateur Admin

### Option 1: Via Firebase Console (Recommandé pour le premier admin)

1. **Créer l'utilisateur dans Firebase Authentication:**
   - Aller dans Firebase Console → Authentication → Users
   - Cliquer sur "Add user"
   - Entrer email et mot de passe
   - Noter l'UID généré

2. **Créer le document Firestore:**
   - Aller dans Firebase Console → Firestore Database
   - Créer un document dans la collection `users`
   - ID du document = UID de l'utilisateur
   - Ajouter les champs:
     ```json
     {
       "email": "admin@delizza.com",
       "role": "admin",
       "displayName": "Administrateur",
       "createdAt": [timestamp actuel],
       "updatedAt": [timestamp actuel]
     }
     ```

### Option 2: Via l'Application (Si déjà admin)

Un admin existant peut modifier le rôle d'un autre utilisateur via le service:

```dart
// Dans un service admin
await FirebaseAuthService().updateUserRole(userId, UserRole.admin);
```

**Note:** Cette fonction est définie dans `lib/src/services/firebase_auth_service.dart`:

```dart
Future<void> updateUserRole(String uid, String role) async {
  await _firestore.collection('users').doc(uid).update({
    'role': role,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
```

### Option 3: Via Cloud Functions (Recommandé pour production)

Créer une Cloud Function pour promouvoir un utilisateur:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.makeAdmin = functions.https.onCall(async (data, context) => {
  // Vérifier que l'appelant est admin
  const callerDoc = await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .get();
  
  if (callerDoc.data()?.role !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied', 
      'Seul un admin peut promouvoir un utilisateur'
    );
  }
  
  // Mettre à jour le rôle
  const targetUserId = data.userId;
  const newRole = data.role; // 'admin', 'client', ou 'kitchen'
  
  await admin.firestore()
    .collection('users')
    .doc(targetUserId)
    .update({
      role: newRole,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  
  return { success: true, message: `Utilisateur promu à ${newRole}` };
});
```

## Accès Admin dans l'Application

### Routes Protégées

Les routes suivantes nécessitent le rôle admin (configuré dans `lib/main.dart`):

- `/admin/studio` - Admin Studio (gestion produits, ingrédients, promos, etc.)
- `/staff-tablet` - Staff Tablet / Caisse
- `/staff-tablet/catalog` - Catalogue Staff Tablet
- `/staff-tablet/checkout` - Checkout Staff Tablet
- `/staff-tablet/history` - Historique Staff Tablet

### Protection dans main.dart

```dart
GoRoute(
  path: AppRoutes.adminStudio,
  builder: (context, state) {
    final authState = ref.read(authProvider);
    if (!authState.isAdmin) {
      // Redirection si pas admin
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.home);
      });
      return Scaffold(
        body: Center(
          child: Text('Accès réservé aux administrateurs'),
        ),
      );
    }
    return const AdminStudioScreen();
  },
)
```

## Accès Kitchen

Le rôle `kitchen` est utilisé pour le Kitchen Board:

### Route Kitchen

```
/kitchen - Kitchen Page (mode cuisine temps réel)
```

### Permissions

Dans les Firestore Rules:

```javascript
function isKitchen() {
  return isAuthenticated() && getUserRole() == 'kitchen';
}

function isAdminOrKitchen() {
  return isAdmin() || isKitchen();
}

// Commandes - lecture
allow read: if resource.data.uid == request.auth.uid || isAdminOrKitchen();

// Commandes - mise à jour statut
allow update: if isAdminOrKitchen() && ...;
```

## Migration vers Custom Claims (Optionnel)

### Pourquoi migrer?

**Avantages des Custom Claims:**
- Pas de lecture Firestore supplémentaire dans les rules
- Rôle caché dans le JWT token (mis en cache)
- Plus performant pour les vérifications fréquentes

**Inconvénients:**
- Nécessite Cloud Functions pour assigner les claims
- Plus complexe à mettre en place
- Propagation du claim peut prendre jusqu'à 1h (ou force refresh token)

### Implémentation avec Custom Claims

1. **Cloud Function pour assigner le claim:**

```javascript
exports.setAdminClaim = functions.https.onCall(async (data, context) => {
  // Vérifier que l'appelant est admin
  if (!context.auth?.token?.admin) {
    throw new functions.https.HttpsError(
      'permission-denied', 
      'Seul un admin peut modifier les claims'
    );
  }
  
  // Assigner le custom claim
  await admin.auth().setCustomUserClaims(data.userId, {
    role: data.role,
    admin: data.role === 'admin',
    kitchen: data.role === 'kitchen'
  });
  
  // Mettre à jour Firestore (pour référence)
  await admin.firestore()
    .collection('users')
    .doc(data.userId)
    .update({ role: data.role });
  
  return { success: true };
});
```

2. **Modifier les Firestore Rules:**

```javascript
// Ancienne version (lecture Firestore)
function getUserRole() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
}

// Nouvelle version (custom claims)
function getUserRole() {
  return request.auth.token.role;
}

function isAdmin() {
  // Option 1: via le claim role
  return isAuthenticated() && request.auth.token.role == 'admin';
  // Option 2: via un claim dédié
  return isAuthenticated() && request.auth.token.admin == true;
}
```

3. **Modifier le code Flutter:**

```dart
// Dans firebase_auth_service.dart
Future<Map<String, dynamic>?> getUserProfile(String uid) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Forcer le rafraîchissement du token pour obtenir les claims à jour
      await user.getIdTokenResult(true);
      
      // Récupérer les custom claims
      final idTokenResult = await user.getIdTokenResult();
      final role = idTokenResult.claims?['role'] ?? UserRole.client;
      
      return {
        'role': role,
        'email': user.email,
        'displayName': user.displayName,
      };
    }
  } catch (e) {
    print('Error getting user profile: $e');
  }
  return null;
}
```

### Force Refresh Token

Si vous utilisez custom claims, il faut forcer le refresh après assignation:

```dart
// Après assignation du claim côté backend
await FirebaseAuth.instance.currentUser?.getIdToken(true);
```

## Sécurité

### Bonnes Pratiques

1. **Ne jamais exposer la fonction makeAdmin publiquement**
   - Utiliser Cloud Functions avec vérification de l'appelant
   - Ou limiter l'accès via Firebase Console uniquement

2. **Auditer les changements de rôle**
   - Logger dans une collection `role_changes_audit`
   - Inclure: qui, quand, ancien rôle, nouveau rôle

3. **Validation stricte côté rules**
   - Empêcher l'auto-promotion (utilisateur ne peut pas se faire admin)
   - Vérifier dans create que role == 'client'

4. **Monitoring**
   - Surveiller les tentatives d'accès admin non autorisées
   - Alerter si un compte admin est créé

### Firestore Rules - Protection Rôle

```javascript
match /users/{userId} {
  // Création: role doit être 'client'
  allow create: if isAuthenticated() && 
                  isOwner(userId) &&
                  request.resource.data.role == 'client';
  
  // Mise à jour: utilisateur ne peut pas modifier son propre rôle
  allow update: if isAuthenticated() && (
    (isOwner(userId) && 
     !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role'])) ||
    isAdmin()  // Admin peut tout modifier
  );
}
```

## Testing

### Tester les Permissions Admin

1. **Créer un utilisateur test:**
   ```dart
   // Email: admin.test@delizza.com
   // Role: 'admin' (à définir manuellement dans Firestore)
   ```

2. **Tester l'accès aux routes admin:**
   - Se connecter avec le compte admin
   - Vérifier l'accès à `/admin/studio`
   - Vérifier l'accès à `/staff-tablet`

3. **Tester les restrictions client:**
   - Se connecter avec un compte client
   - Vérifier le refus d'accès aux routes admin
   - Vérifier la redirection vers `/home`

### Tester les Firestore Rules

Utiliser le simulateur dans Firebase Console:

1. Aller dans Firestore Database → Rules → Simuler
2. Tester:
   - Lecture/écriture `orders` en tant que client
   - Lecture/écriture `products` en tant que client (doit échouer)
   - Lecture/écriture `products` en tant qu'admin (doit réussir)
   - Modification du rôle dans `users` (doit échouer pour client)

## Dépannage

### Problème: "Permission denied" alors que l'utilisateur est admin

**Causes possibles:**

1. **Le document Firestore n'existe pas:**
   - Vérifier que `users/{uid}` existe dans Firestore
   - Créer le document si manquant

2. **Le champ role est incorrect:**
   - Vérifier que `role` == `'admin'` (pas `'Admin'` ou autre variante)
   - Vérifier le type: doit être string

3. **L'utilisateur doit se reconnecter:**
   - Le rôle est mis en cache dans authState
   - Se déconnecter et se reconnecter pour rafraîchir

4. **Les rules n'ont pas été déployées:**
   - Déployer avec `firebase deploy --only firestore:rules`
   - Vérifier dans Firebase Console que les rules sont à jour

### Problème: Custom claims non appliqués

**Solution:**

```dart
// Forcer le refresh du token
await FirebaseAuth.instance.currentUser?.getIdToken(true);
// Puis recharger l'authState
await ref.read(authProvider.notifier).checkAuthStatus();
```

## Résumé

- **Actuellement:** Rôle stocké dans Firestore `users.role`
- **Rôles:** `admin`, `client`, `kitchen`
- **Vérification:** Via `authProvider.isAdmin` ou `authProvider.isKitchen`
- **Admin routes:** Protégées dans `main.dart` avec redirect
- **Security rules:** Utilisent `getUserRole()` pour vérifier le rôle
- **Migration custom claims:** Optionnelle, nécessite Cloud Functions
