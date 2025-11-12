# Configuration Firebase pour Pizza Deli'Zza

## 🔥 Introduction

L'application utilise maintenant Firebase pour l'authentification et la gestion des commandes en temps réel. Ce guide explique comment configurer Firebase pour votre projet.

## 📋 Prérequis

1. Un compte Firebase (https://console.firebase.google.com)
2. Flutter installé et configuré
3. FlutterFire CLI (optionnel mais recommandé)

## 🚀 Configuration Initiale

### 1. Créer un projet Firebase

1. Allez sur https://console.firebase.google.com
2. Créez un nouveau projet ou utilisez un projet existant
3. Activez les services suivants :
   - **Authentication** (Email/Password)
   - **Cloud Firestore**

### 2. Configurer l'Authentication

1. Dans la console Firebase, allez dans **Authentication** > **Sign-in method**
2. Activez **Email/Password**
3. Ne pas activer "Email link (passwordless sign-in)" pour le moment

### 3. Créer les utilisateurs de test

#### Utilisateurs recommandés pour démarrer :

**Admin:**
- Email: `admin@delizza.com`
- Password: (choisir un mot de passe fort)
- Rôle: `admin`

**Cuisine:**
- Email: `kitchen@delizza.com`
- Password: (choisir un mot de passe fort)
- Rôle: `kitchen`

**Client:**
- Email: `client@delizza.com`
- Password: (choisir un mot de passe fort)
- Rôle: `client`

#### Créer les utilisateurs :

1. Dans **Authentication** > **Users**, cliquez sur "Add user"
2. Entrez l'email et le mot de passe
3. Une fois créé, notez l'UID de l'utilisateur

### 4. Configurer Firestore

#### Structure des collections :

```
/users/{userId}
  - email: string
  - role: string ("client", "admin", "kitchen")
  - displayName: string (optionnel)
  - createdAt: timestamp
  - updatedAt: timestamp

/orders/{orderId}
  - uid: string (ID de l'utilisateur)
  - status: string
  - items: array
  - total: number
  - total_cents: number
  - customerName: string
  - customerPhone: string
  - customerEmail: string
  - comment: string
  - pickupDate: string
  - pickupTimeSlot: string
  - createdAt: timestamp
  - statusChangedAt: timestamp
  - seenByKitchen: boolean
  - isViewed: boolean
  - viewedAt: timestamp
  - statusHistory: array
```

#### Créer les documents users :

Pour chaque utilisateur créé dans Authentication :

1. Allez dans **Firestore Database**
2. Créez la collection `users` si elle n'existe pas
3. Ajoutez un document avec l'UID de l'utilisateur comme ID
4. Ajoutez les champs :
   ```json
   {
     "email": "admin@delizza.com",
     "role": "admin",
     "displayName": "Administrateur",
     "createdAt": "2024-01-01T00:00:00Z",
     "updatedAt": "2024-01-01T00:00:00Z"
   }
   ```

### 5. Déployer les règles de sécurité

Les règles Firestore sont définies dans `firestore.rules`. Pour les déployer :

```bash
# Installer Firebase CLI si ce n'est pas déjà fait
npm install -g firebase-tools

# Se connecter à Firebase
firebase login

# Initialiser Firebase dans le projet (si pas déjà fait)
firebase init firestore

# Déployer les règles
firebase deploy --only firestore:rules
```

### 6. Mettre à jour firebase_options.dart

Le fichier `lib/firebase_options.dart` contient les clés de configuration Firebase. Mettez-le à jour avec vos propres clés :

```bash
# Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurer Firebase pour Flutter
flutterfire configure
```

Cette commande va générer automatiquement le fichier `firebase_options.dart` avec vos clés.

## 🔒 Règles de Sécurité

Les règles de sécurité Firestore sont configurées pour :

- **Users** : Un utilisateur peut lire et modifier son propre profil (sauf le rôle). Les admins peuvent tout modifier.
- **Orders** : 
  - Les clients peuvent créer des commandes et lire uniquement leurs propres commandes
  - Les admins et la cuisine peuvent lire toutes les commandes et modifier les statuts
  - Les champs critiques (uid, total_cents, items, createdAt) ne peuvent jamais être modifiés après création

## 🎭 Rôles Utilisateurs

### Client (`client`)
- Créer des commandes
- Voir ses propres commandes
- Accès à l'interface client

### Cuisine (`kitchen`)
- Voir toutes les commandes
- Modifier les statuts des commandes
- Accès au mode cuisine

### Admin (`admin`)
- Tout ce que la cuisine peut faire
- Gérer les produits
- Voir les statistiques
- Gérer les utilisateurs
- Accès au dashboard admin

## 🧪 Tests

### Tester l'authentification

1. Lancez l'application
2. Connectez-vous avec un des comptes de test
3. Vérifiez que le rôle est correctement appliqué

### Tester les commandes

1. Connectez-vous en tant que client
2. Créez une commande
3. Ouvrez une autre session en mode cuisine
4. Vérifiez que la commande apparaît en temps réel
5. Modifiez le statut depuis la cuisine
6. Vérifiez que le changement est visible côté client

## 📱 Configuration Multi-Plateformes

### Web
Les configurations sont dans `firebase_options.dart` - section `web`.

### Android
1. Téléchargez `google-services.json` depuis la console Firebase
2. Placez-le dans `android/app/`

### iOS
1. Téléchargez `GoogleService-Info.plist` depuis la console Firebase
2. Placez-le dans `ios/Runner/`

## 🐛 Dépannage

### Erreur "FirebaseOptions not configured"
- Vérifiez que `firebase_options.dart` existe
- Exécutez `flutterfire configure` pour le régénérer

### Erreur "Permission denied" sur Firestore
- Vérifiez que les règles de sécurité sont déployées
- Vérifiez que l'utilisateur a le bon rôle dans Firestore

### Les commandes n'apparaissent pas en temps réel
- Vérifiez la connexion internet
- Vérifiez que Firestore est activé dans la console Firebase
- Regardez les logs dans la console pour les erreurs

### L'utilisateur ne peut pas se connecter
- Vérifiez que l'email/password est correct
- Vérifiez que l'utilisateur existe dans Firebase Authentication
- Vérifiez que le profil utilisateur existe dans Firestore collection `users`

## 📚 Ressources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

## 🔄 Migration depuis la version locale

Si vous migrez depuis la version avec stockage local (SharedPreferences) :

1. Les anciennes commandes en local ne seront plus accessibles
2. Les utilisateurs devront créer de nouveaux comptes Firebase
3. Les données de test locales ne sont plus utilisées
4. Assurez-vous de créer les utilisateurs dans Firebase avant de vous connecter

## ⚠️ Notes Importantes

- Ne jamais committer `firebase_options.dart` avec de vraies clés de production dans un dépôt public
- Utilisez Firebase Environment pour gérer plusieurs environnements (dev, staging, prod)
- Surveillez les quotas Firebase (surtout pour Firestore reads/writes)
- Activez la facturation si nécessaire pour éviter les limites du plan gratuit
