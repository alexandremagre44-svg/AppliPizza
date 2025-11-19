# Implémentation Sécurité - Pizza Deli'Zza

## Vue d'ensemble

Ce document décrit les mesures de sécurité implémentées pour renforcer l'application Pizza Deli'Zza sans modifier la logique métier existante.

## 1. Firestore Security Rules

**Fichier:** `firebase/firestore.rules`

### Principes de sécurité appliqués

1. **Deny by default** - Règle finale qui refuse tout accès non explicitement autorisé
2. **Authentification obligatoire** - Toutes les opérations nécessitent un utilisateur connecté
3. **Séparation des rôles** - Client / Admin / Kitchen avec permissions distinctes
4. **Validation des données** - Vérification stricte des champs sensibles

### Convention de rôles

Le rôle est actuellement stocké dans Firestore:
- Collection: `users`
- Champ: `role`
- Valeurs: `'admin'`, `'client'`, `'kitchen'`

**Note:** Les custom claims Firebase Auth ne sont PAS utilisés actuellement. Les rules font un `get()` sur la collection users pour récupérer le rôle, ce qui coûte une lecture supplémentaire mais fonctionne sans Cloud Functions.

### Collections sécurisées

#### Collections utilisateurs
- `users` - Profils avec rôle
  - Lecture: utilisateur lit son profil, admin lit tout
  - Création: auto-inscription avec role='client' uniquement
  - Mise à jour: utilisateur modifie son profil (sauf rôle), admin modifie tout
  
- `user_profiles` - Profils détaillés
  - Lecture/écriture: propriétaire ou admin

#### Collections produits (admin write only)
- `pizzas`, `menus`, `drinks`, `desserts`
- `ingredients` - Validation: prix >= 0, nom non vide
- `promotions`

#### Collection commandes
- `orders`
  - Création: validation stricte (uid, status='En attente', total_cents > 0, items non vide)
  - Lecture: client lit ses commandes, admin/kitchen lit tout
  - Mise à jour: admin/kitchen uniquement, champs critiques immuables (uid, total_cents, items)
  - Statuts valides: 'En attente', 'En préparation', 'Au four', 'Prête', 'Livrée', 'Annulée'

#### Roulette & Rewards (anti-triche)
- `roulette_segments`, `config/roulette_rules` - Admin write, tous read
- `user_roulette_spins` - Création par utilisateur (userId vérifié), pas de modification
- `roulette_history/{userId}/{dateKey}` - Audit trail immuable (création interdite)
- `users/{userId}/rewardTickets` - Sous-collection, utilisateur marque comme utilisé uniquement

#### Collections configuration (admin only)
- `app_home_config`, `app_texts_config`, `app_popups`, `loyalty_settings`
- Lecture: tous authentifiés
- Écriture: admin uniquement

### Fonctions helper

```javascript
isAuthenticated() - Vérifie request.auth != null
getUserRole() - Récupère le rôle depuis Firestore
isAdmin() - Vérifie role == 'admin'
isKitchen() - Vérifie role == 'kitchen'
isAdminOrKitchen() - Vérifie admin OU kitchen
isOwner(userId) - Vérifie request.auth.uid == userId
isValidPrice(price) - Vérifie prix >= 0
isValidQuantity(qty) - Vérifie quantité > 0
isValidOrderStatus(status) - Vérifie statut dans liste autorisée
```

## 2. Storage Security Rules

**Fichier:** `firebase/storage.rules`

### Principes appliqués

1. **Upload admin uniquement** - Seuls les admins peuvent uploader des fichiers
2. **Lecture publique** - Images accessibles pour affichage dans l'app client
3. **Validation fichiers** - Types: JPEG, PNG, GIF, WebP uniquement
4. **Validation taille** - Maximum 5MB par fichier

### Chemins sécurisés

```
/products/{productId}/{filename}      - Images produits
/ingredients/{ingredientId}/{filename} - Images ingrédients
/promo_banners/{bannerId}/{filename}  - Bannières promotionnelles
/home_blocks/{blockId}/{filename}     - Images blocs home
/popups/{popupId}/{filename}          - Images popups
/carousel/{imageId}/{filename}        - Images carrousel
```

Toutes les autres chemins: **DENY**

## 3. App Check

**Fichier:** `lib/main.dart`

### Configuration

App Check est activé pour protéger les ressources Firebase contre:
- Les bots et scripts malveillants
- Les abus de quota
- Les requêtes non autorisées

### Providers configurés

- **Debug mode:** `AndroidProvider.debug` / `AppleProvider.debug`
  - Utilise un debug token pour le développement
  - Facilite les tests sans configuration Play Integrity
  
- **Production mode:** `AndroidProvider.playIntegrity` / `AppleProvider.deviceCheck`
  - Android: Play Integrity API (nécessite configuration dans Firebase Console)
  - iOS: DeviceCheck (nécessite configuration dans Firebase Console)

### Configuration requise

1. **Firebase Console:**
   - Activer App Check dans les paramètres du projet
   - Enregistrer le debug token pour le développement
   - Configurer Play Integrity pour Android
   - Configurer DeviceCheck pour iOS

2. **Android (Play Integrity):**
   - Associer l'app au Google Play Console
   - Activer Play Integrity API

3. **iOS (DeviceCheck):**
   - Vérifier que l'app est signée avec un profil de provisioning valide

## 4. Crashlytics

**Fichier:** `lib/main.dart`

### Configuration

Crashlytics est configuré pour capturer automatiquement:
- Les erreurs Flutter fatales (`FlutterError.onError`)
- Les erreurs asynchrones non gérées (`PlatformDispatcher.onError`)

### Informations capturées

- Stack traces complètes
- État de l'application au moment de l'erreur
- Informations sur l'appareil et la plateforme
- Numéros de ligne préservés (grâce aux règles Proguard)

### Android configuration

**Fichier:** `android/app/build.gradle.kts`
- Plugin Crashlytics ajouté
- Gradle classpath configuré dans `android/build.gradle.kts`

### Visualisation

Les crash reports sont disponibles dans:
**Firebase Console → Crashlytics**

## 5. Proguard & Build Release

**Fichiers:** 
- `android/app/build.gradle.kts` - Configuration build
- `android/app/proguard-rules.pro` - Règles d'obfuscation

### Build release sécurisé

```kotlin
buildTypes {
    release {
        isMinifyEnabled = true        // Obfuscation du code
        isShrinkResources = true      // Réduction des ressources
        proguardFiles(...)            // Règles personnalisées
    }
}
```

### Règles Proguard incluses

1. **Flutter** - Préservation des classes Flutter essentielles
2. **Firebase** - Core, Auth, Firestore, Storage, Crashlytics, App Check
3. **Google Play Services** - Play Integrity, SafetyNet
4. **Kotlin** - Classes et métadonnées Kotlin
5. **Modèles de données** - Préservation pour serialization JSON
6. **Optimisations** - 5 passes d'optimisation
7. **Debug info** - Numéros de ligne préservés pour Crashlytics

### Bénéfices

- **Taille APK réduite** - shrinkResources supprime les ressources inutilisées
- **Code obfusqué** - Rend le reverse engineering plus difficile
- **Performance** - Optimisations R8 appliquées
- **Sécurité** - Noms de classes/méthodes obscurcis

## 6. Configuration Firebase

**Fichier:** `firebase.json`

```json
{
  "firestore": {
    "rules": "firebase/firestore.rules",
    "indexes": "firebase/firestore.indexes.json"
  },
  "storage": {
    "rules": "firebase/storage.rules"
  }
}
```

### Indexes Firestore

**Fichier:** `firebase/firestore.indexes.json`

Indexes composés créés pour:
- `orders` - (uid, createdAt) et (status, createdAt)
- `promotions` - (isActive, createdAt)
- `user_roulette_spins` - (userId, spinDate)

## 7. Dépendances ajoutées

**Fichier:** `pubspec.yaml`

```yaml
firebase_app_check: ^0.3.1+3
firebase_crashlytics: ^4.1.3
```

## Déploiement

### 1. Déployer les Security Rules

```bash
# Installer Firebase CLI si nécessaire
npm install -g firebase-tools

# Se connecter
firebase login

# Déployer uniquement les rules
firebase deploy --only firestore:rules,storage
```

### 2. Configurer App Check

1. Aller dans Firebase Console → App Check
2. Activer App Check pour le projet
3. Enregistrer les providers:
   - Android: Play Integrity API
   - iOS: DeviceCheck
4. Générer et enregistrer un debug token pour le développement

### 3. Build release

```bash
# Android
flutter build apk --release
# ou
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Notes importantes

### Custom Claims vs Firestore Role

**Actuellement:** Le rôle est stocké dans Firestore (`users.role`)

**Avantage:**
- Simple à implémenter
- Pas besoin de Cloud Functions
- Modifiable facilement par admin

**Inconvénient:**
- Coût lecture supplémentaire dans les rules (1 get par requête)
- Pas de mise en cache côté auth token

**Migration vers custom claims (optionnel):**
Si souhaité, nécessite:
1. Cloud Functions pour assigner les custom claims
2. Modification des rules: `request.auth.token.role` au lieu de `getUserRole()`
3. Avantage: pas de lecture supplémentaire, claims cachés dans le token

### Maintenance

- **Security Rules:** Tester régulièrement avec le simulateur Firebase
- **App Check:** Monitorer les métriques dans la console
- **Crashlytics:** Analyser les rapports de crash régulièrement
- **Proguard:** Vérifier que les règles n'empêchent pas le fonctionnement

### Testing

1. **Security Rules:** Utiliser le simulateur dans Firebase Console
2. **App Check:** Tester en debug mode d'abord
3. **Crashlytics:** Forcer un crash test pour vérifier la configuration
4. **Build release:** Tester l'APK release en profondeur avant déploiement

## Résumé

Cette implémentation renforce considérablement la sécurité de l'application sans modifier:
- La logique métier
- L'interface utilisateur
- Les routes
- La structure du code

Toutes les modifications sont concentrées sur:
- Les rules de sécurité Firebase
- La configuration build Android
- L'initialisation de l'app (main.dart)
