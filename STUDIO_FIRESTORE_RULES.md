# Studio Admin - Firestore Security Rules

## Vue d'ensemble

Ce document décrit les règles de sécurité Firestore nécessaires pour le Studio Admin Unifié.

## Principes de sécurité

1. **Lecture publique:** Tous les utilisateurs peuvent lire les configurations (nécessaire pour afficher l'app)
2. **Écriture admin uniquement:** Seuls les administrateurs peuvent modifier les configurations
3. **Validation des données:** Structure et types de données validés
4. **Audit trail:** Chaque modification enregistre updatedAt

## Collections concernées

### 1. config/home_layout

**Path:** `config/home_layout`

**Règles:**

```javascript
match /config/home_layout {
  // Lecture: tout le monde (affichage app)
  allow read: if true;
  
  // Écriture: admins seulement
  allow write: if request.auth != null 
    && request.auth.token.admin == true;
  
  // Validation de la structure
  allow create, update: if request.resource.data.keys().hasAll([
    'id', 'studioEnabled', 'sectionsOrder', 'enabledSections', 'updatedAt'
  ])
  && request.resource.data.studioEnabled is bool
  && request.resource.data.sectionsOrder is list
  && request.resource.data.enabledSections is map
  && request.resource.data.updatedAt is timestamp;
}
```

### 2. app_banners

**Path:** `app_banners/{bannerId}`

**Règles:**

```javascript
match /app_banners/{bannerId} {
  // Lecture: tout le monde
  allow read: if true;
  
  // Écriture: admins seulement
  allow write: if request.auth != null 
    && request.auth.token.admin == true;
  
  // Validation de la structure
  allow create, update: if request.resource.data.keys().hasAll([
    'id', 'text', 'backgroundColor', 'textColor', 'isEnabled', 'order', 
    'createdAt', 'updatedAt'
  ])
  && request.resource.data.text is string
  && request.resource.data.text.size() > 0
  && request.resource.data.text.size() <= 100
  && request.resource.data.backgroundColor is string
  && request.resource.data.backgroundColor.matches('^#[0-9A-Fa-f]{6,8}$')
  && request.resource.data.textColor is string
  && request.resource.data.textColor.matches('^#[0-9A-Fa-f]{6,8}$')
  && request.resource.data.isEnabled is bool
  && request.resource.data.order is int
  && request.resource.data.order >= 0
  && request.resource.data.createdAt is timestamp
  && request.resource.data.updatedAt is timestamp;
}
```

### 3. app_popups (existant - à mettre à jour)

**Path:** `app_popups/{popupId}`

**Règles:**

```javascript
match /app_popups/{popupId} {
  // Lecture: tout le monde
  allow read: if true;
  
  // Écriture: admins seulement
  allow write: if request.auth != null 
    && request.auth.token.admin == true;
  
  // Validation de la structure
  allow create, update: if request.resource.data.keys().hasAll([
    'id', 'title', 'message', 'isEnabled', 'priority', 'createdAt'
  ])
  && request.resource.data.title is string
  && request.resource.data.title.size() > 0
  && request.resource.data.title.size() <= 50
  && request.resource.data.message is string
  && request.resource.data.message.size() > 0
  && request.resource.data.message.size() <= 200
  && request.resource.data.isEnabled is bool
  && request.resource.data.priority is int
  && request.resource.data.priority >= 0
  && request.resource.data.createdAt is timestamp;
}
```

### 4. config/app_texts (existant)

**Path:** `config/app_texts`

**Règles:**

```javascript
match /config/app_texts {
  // Lecture: tout le monde
  allow read: if true;
  
  // Écriture: admins seulement
  allow write: if request.auth != null 
    && request.auth.token.admin == true;
  
  // Validation de la structure
  allow create, update: if request.resource.data.keys().hasAll([
    'id', 'home', 'updatedAt'
  ])
  && request.resource.data.home is map
  && request.resource.data.updatedAt is timestamp;
}
```

### 5. config/home_config (existant)

**Path:** `config/home_config`

**Règles:**

```javascript
match /config/home_config {
  // Lecture: tout le monde
  allow read: if true;
  
  // Écriture: admins seulement
  allow write: if request.auth != null 
    && request.auth.token.admin == true;
  
  // Validation de la structure
  allow create, update: if request.resource.data.keys().hasAll([
    'id', 'updatedAt'
  ])
  && request.resource.data.updatedAt is timestamp;
}
```

## Configuration des custom claims admin

### Attribution du rôle admin

**Firebase Admin SDK (Functions ou Script):**

```javascript
const admin = require('firebase-admin');

// Donner le rôle admin à un utilisateur
async function setAdminRole(userEmail) {
  try {
    const user = await admin.auth().getUserByEmail(userEmail);
    
    await admin.auth().setCustomUserClaims(user.uid, {
      admin: true
    });
    
    console.log(`Admin role set for ${userEmail}`);
  } catch (error) {
    console.error('Error setting admin role:', error);
  }
}

// Utilisation
setAdminRole('admin@pizzadelizza.com');
```

### Vérification côté client

```dart
// Dans votre code Flutter
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> isAdmin() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  
  final idTokenResult = await user.getIdTokenResult();
  return idTokenResult.claims?['admin'] == true;
}

// Utiliser pour protéger la route
GoRoute(
  path: '/admin/studio',
  builder: (context, state) => const AdminStudioUnified(),
  redirect: (context, state) async {
    if (!await isAdmin()) {
      return '/';  // Rediriger vers l'accueil si non admin
    }
    return null;
  },
),
```

## Index Firestore requis

### app_banners

**Index composite:**
- `isEnabled` (ASC) + `order` (ASC)

**Création:**

```javascript
// Via Firebase Console > Firestore > Index
// Ou via CLI:
firebase firestore:indexes
```

**Fichier `firestore.indexes.json`:**

```json
{
  "indexes": [
    {
      "collectionGroup": "app_banners",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "isEnabled",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "order",
          "order": "ASCENDING"
        }
      ]
    }
  ]
}
```

### app_popups

**Index composite:**
- `isEnabled` (ASC) + `priority` (DESC)

```json
{
  "collectionGroup": "app_popups",
  "queryScope": "COLLECTION",
  "fields": [
    {
      "fieldPath": "isEnabled",
      "order": "ASCENDING"
    },
    {
      "fieldPath": "priority",
      "order": "DESCENDING"
    }
  ]
}
```

## Règles complètes (firestore.rules)

**Fichier complet à déployer:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ========================================
    // STUDIO ADMIN - NOUVELLES RÈGLES
    // ========================================
    
    // Config: Home Layout
    match /config/home_layout {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Collection: Banners
    match /app_banners/{bannerId} {
      allow read: if true;
      allow create, update: if request.auth != null 
        && request.auth.token.admin == true
        && request.resource.data.text is string
        && request.resource.data.text.size() > 0
        && request.resource.data.text.size() <= 100
        && request.resource.data.backgroundColor.matches('^#[0-9A-Fa-f]{6,8}$')
        && request.resource.data.textColor.matches('^#[0-9A-Fa-f]{6,8}$')
        && request.resource.data.isEnabled is bool
        && request.resource.data.order is int;
      allow delete: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Collection: Popups (mise à jour)
    match /app_popups/{popupId} {
      allow read: if true;
      allow create, update: if request.auth != null 
        && request.auth.token.admin == true
        && request.resource.data.title is string
        && request.resource.data.title.size() > 0
        && request.resource.data.message is string
        && request.resource.data.message.size() > 0
        && request.resource.data.isEnabled is bool
        && request.resource.data.priority is int;
      allow delete: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Config: App Texts
    match /config/app_texts {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Config: Home Config
    match /config/home_config {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // ========================================
    // AUTRES RÈGLES (EXISTANTES - NE PAS MODIFIER)
    // ========================================
    
    // Produits, Commandes, Users, etc.
    // ... (règles existantes inchangées)
    
  }
}
```

## Déploiement

### 1. Mettre à jour les règles

```bash
# Éditer le fichier
nano firestore.rules

# Déployer
firebase deploy --only firestore:rules
```

### 2. Créer les index

```bash
# Éditer le fichier
nano firestore.indexes.json

# Déployer
firebase deploy --only firestore:indexes
```

### 3. Attribuer le rôle admin

Créer un script Node.js ou une Cloud Function:

```javascript
// scripts/set-admin.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function main() {
  const email = process.argv[2];
  
  if (!email) {
    console.error('Usage: node set-admin.js <email>');
    process.exit(1);
  }
  
  try {
    const user = await admin.auth().getUserByEmail(email);
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });
    console.log(`✅ Admin role set for ${email}`);
    
    // Force token refresh
    await admin.auth().revokeRefreshTokens(user.uid);
    console.log('ℹ️  User needs to sign out and sign in again');
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
  
  process.exit(0);
}

main();
```

**Exécution:**

```bash
node scripts/set-admin.js admin@pizzadelizza.com
```

## Vérification

### Tester les règles

**Console Firestore:**
1. Aller dans Firestore > Rules
2. Cliquer sur "Rules Playground"
3. Tester les différents scénarios

**Exemples de tests:**

```javascript
// Test 1: Lecture publique app_banners
// Auth: Non connecté
// Operation: get
// Path: /app_banners/banner123
// Expected: Allow

// Test 2: Écriture admin app_banners  
// Auth: Connecté avec admin claim
// Operation: create
// Path: /app_banners/banner123
// Expected: Allow

// Test 3: Écriture non-admin app_banners
// Auth: Connecté sans admin claim
// Operation: create
// Path: /app_banners/banner123
// Expected: Deny
```

## Monitoring

### Cloud Firestore Audit Logs

Activer les logs pour suivre les accès:

```bash
# Dans GCP Console > Firestore > Audit Logs
# Activer:
# - Admin Read
# - Admin Write
# - Data Read
# - Data Write
```

### Alertes

Créer des alertes pour:
- Tentatives d'écriture non autorisées
- Nombre élevé de lectures (DoS potentiel)
- Modifications massives

## Troubleshooting

### "Permission denied" lors de l'écriture

**Vérifier:**
1. L'utilisateur est connecté
2. Le custom claim `admin` est défini
3. L'utilisateur s'est reconnecté après attribution du claim
4. Les règles sont déployées

**Debug:**

```dart
final user = FirebaseAuth.instance.currentUser;
final token = await user?.getIdTokenResult(true); // Force refresh
print('Admin claim: ${token?.claims?['admin']}');
```

### Index manquant

**Symptôme:** Erreur "The query requires an index"

**Solution:**
1. Copier le lien de l'erreur
2. Créer l'index automatiquement
3. Ou l'ajouter manuellement dans `firestore.indexes.json`

## Sécurité avancée

### Rate limiting

Implémenter dans Cloud Functions pour limiter les requêtes:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Limite: 10 publications par minute par admin
const RATE_LIMIT = 10;
const WINDOW = 60000; // 1 minute

exports.checkRateLimit = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Admin only');
  }
  
  const uid = context.auth.uid;
  const now = Date.now();
  
  // Check rate limit in Realtime Database
  const limitsRef = admin.database().ref(`rate_limits/${uid}`);
  const snapshot = await limitsRef.once('value');
  const limits = snapshot.val() || { count: 0, windowStart: now };
  
  if (now - limits.windowStart > WINDOW) {
    // Reset window
    await limitsRef.set({ count: 1, windowStart: now });
  } else if (limits.count >= RATE_LIMIT) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Rate limit exceeded'
    );
  } else {
    // Increment counter
    await limitsRef.update({ count: limits.count + 1 });
  }
  
  return { ok: true };
});
```

## Conclusion

Ces règles assurent:
- ✅ Lecture publique pour tous (app fonctionne)
- ✅ Écriture admin uniquement (sécurité)
- ✅ Validation des données (intégrité)
- ✅ Performances optimales (index)

Pour toute question, consulter la documentation Firebase Security Rules:
https://firebase.google.com/docs/firestore/security/rules-structure
