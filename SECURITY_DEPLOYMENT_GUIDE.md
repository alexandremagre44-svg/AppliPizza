# Guide de Déploiement Sécurité - Pizza Deli'Zza

## 📋 Pré-requis

- Firebase CLI installé (`npm install -g firebase-tools`)
- Flutter SDK installé
- Accès administrateur au projet Firebase
- Android Studio (pour builds Android)
- Xcode (pour builds iOS, si applicable)

## 🚀 Étapes de Déploiement

### Étape 1: Installation des Dépendances

```bash
# Se placer dans le répertoire du projet
cd /path/to/AppliPizza

# Installer les dépendances Flutter
flutter pub get

# Vérifier qu'il n'y a pas d'erreurs
flutter doctor
```

**Vérifications:**
- ✅ `firebase_app_check: ^0.3.1+3` installé
- ✅ `firebase_crashlytics: ^4.1.3` installé
- ✅ Pas d'erreurs de dépendances

### Étape 2: Configuration Firebase Console

#### 2.1 Activer App Check

1. **Aller dans Firebase Console:**
   - Ouvrir https://console.firebase.google.com
   - Sélectionner le projet Pizza Deli'Zza

2. **Activer App Check:**
   - Menu → App Check
   - Cliquer sur "Get Started"

3. **Configurer Android (Play Integrity):**
   - Sélectionner votre app Android
   - Choisir "Play Integrity"
   - Cliquer sur "Save"
   
   **Note:** Play Integrity nécessite:
   - App publiée sur Google Play Console (même en internal testing)
   - SHA-256 de la clé de signature configuré dans Firebase

4. **Créer un Debug Token (pour développement):**
   - Dans App Check → Apps
   - Sélectionner l'app
   - Onglet "Debug tokens"
   - Cliquer sur "Add debug token"
   - Copier le token généré

5. **Configurer le Debug Token en local:**
   ```bash
   # Android
   adb shell setprop debug.firebase.appcheck.debug_token "<TOKEN>"
   
   # iOS
   # Ajouter dans le scheme Xcode:
   # FIRDebugEnabled
   # -FIRDebugEnabled -FIRAppCheckDebugToken=<TOKEN>
   ```

6. **Activer l'enforcement (après tests):**
   - App Check → APIs
   - Activer pour: Firestore, Storage, Authentication
   - Mode: Enforce (ou Monitoring pour tester d'abord)

#### 2.2 Activer Crashlytics

1. **Dans Firebase Console:**
   - Menu → Crashlytics
   - Cliquer sur "Enable Crashlytics"

2. **Vérifier la configuration:**
   - Les plugins Gradle sont bien configurés ✅
   - Le code d'initialisation est dans main.dart ✅

### Étape 3: Déploiement des Security Rules

```bash
# Se connecter à Firebase
firebase login

# Initialiser Firebase dans le projet (si pas déjà fait)
firebase init

# Sélectionner:
# - Firestore
# - Storage

# Vérifier que firebase.json pointe vers les bons fichiers:
# "firestore": { "rules": "firebase/firestore.rules" }
# "storage": { "rules": "firebase/storage.rules" }

# Déployer UNIQUEMENT les rules (pas les functions, hosting, etc.)
firebase deploy --only firestore:rules,storage

# Vérifier le déploiement
firebase deploy --only firestore:rules,storage --dry-run
```

**Vérifications post-déploiement:**

1. **Tester les Firestore Rules:**
   - Firebase Console → Firestore → Rules
   - Cliquer sur "Simuler"
   - Tester quelques scénarios:
     ```
     # Test 1: Client lit ses commandes (doit réussir)
     Type: read
     Location: orders/ORDER123
     Auth: [UID du client]
     
     # Test 2: Client modifie un produit (doit échouer)
     Type: write
     Location: pizzas/PIZZA123
     Auth: [UID du client]
     
     # Test 3: Admin modifie un produit (doit réussir)
     Type: write
     Location: pizzas/PIZZA123
     Auth: [UID admin avec role='admin']
     ```

2. **Tester les Storage Rules:**
   - Firebase Console → Storage → Rules
   - Vérifier que les règles sont déployées
   - Tester un upload en tant que client (doit échouer)

### Étape 4: Configuration Proguard (Android)

**Fichiers déjà configurés:**
- ✅ `android/app/proguard-rules.pro` créé
- ✅ `android/app/build.gradle.kts` modifié
- ✅ `android/build.gradle.kts` modifié

**Vérification:**

```bash
# Vérifier la configuration Gradle
cd android
./gradlew :app:dependencies | grep firebase
cd ..

# Devrait afficher:
# - firebase-crashlytics
# - firebase-app-check
# - firebase-firestore
# - firebase-storage
# - firebase-auth
```

### Étape 5: Build de Test (Debug)

```bash
# Build debug pour tester
flutter build apk --debug

# Installer sur un appareil/émulateur
flutter install

# Lancer l'app
flutter run

# Vérifier les logs
flutter logs
```

**Vérifications dans les logs:**

```
✅ Firebase initialized
✅ App Check activated
✅ Crashlytics initialized
```

**Tests fonctionnels:**

1. **Test App Check:**
   - Vérifier qu'aucune erreur "App Check token" n'apparaît
   - Si erreur: vérifier le debug token

2. **Test Crashlytics:**
   - Forcer un crash test:
     ```dart
     // Ajouter temporairement dans un bouton
     FirebaseCrashlytics.instance.crash();
     ```
   - Vérifier dans Firebase Console → Crashlytics (après 5-10 min)

3. **Test Firestore Rules:**
   - Se connecter en tant que client
   - Créer une commande (doit réussir)
   - Essayer de modifier un produit (doit échouer)
   - Se connecter en tant qu'admin
   - Modifier un produit (doit réussir)

### Étape 6: Build Release (Production)

```bash
# Nettoyer les builds précédents
flutter clean
flutter pub get

# Build APK release
flutter build apk --release

# OU Build App Bundle (recommandé pour Play Store)
flutter build appbundle --release

# Localisation du build:
# APK: build/app/outputs/flutter-apk/app-release.apk
# AAB: build/app/outputs/bundle/release/app-release.aab
```

**Vérifications du build release:**

1. **Taille de l'APK:**
   ```bash
   ls -lh build/app/outputs/flutter-apk/app-release.apk
   ```
   - Doit être plus petit qu'un build debug
   - shrinkResources et minifyEnabled réduisent la taille

2. **Proguard appliqué:**
   ```bash
   # Vérifier le mapping file (pour déobfusquer les stack traces)
   ls -l build/app/outputs/mapping/release/
   ```
   - Le fichier `mapping.txt` doit exister
   - **IMPORTANT:** Uploader ce fichier sur Firebase Console → Crashlytics → Mappings

3. **Test de l'APK release:**
   ```bash
   # Installer l'APK release sur un appareil
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   
   # Lancer l'app
   # Vérifier que tout fonctionne correctement
   ```

### Étape 7: Upload du Mapping File

**Pour que Crashlytics puisse déobfusquer les stack traces:**

1. **Via Firebase Console:**
   - Crashlytics → cog icon → Mappings
   - Upload `build/app/outputs/mapping/release/mapping.txt`
   - Tag avec la version (ex: 1.0.0+1)

2. **Via Gradle (automatique):**
   - Déjà configuré avec le plugin crashlytics
   - Le mapping file sera uploadé automatiquement lors du build

### Étape 8: Monitoring Post-Déploiement

#### 8.1 App Check

1. **Firebase Console → App Check:**
   - Vérifier les métriques de requêtes
   - Surveiller les tentatives de requêtes non autorisées
   - Ajuster l'enforcement si nécessaire

2. **Métriques à surveiller:**
   - Nombre de requêtes avec token valide
   - Nombre de requêtes rejetées
   - Taux d'erreur des tokens

#### 8.2 Crashlytics

1. **Firebase Console → Crashlytics:**
   - Dashboard: vue d'ensemble des crashes
   - Issues: liste des problèmes
   - Velocity: tendance des crashes

2. **Alertes:**
   - Configurer des alertes email pour nouveaux crashes
   - Settings → Integrations → Email

#### 8.3 Firestore & Storage

1. **Surveiller l'utilisation:**
   - Firebase Console → Usage and billing
   - Vérifier les quotas
   - Configurer des alertes de budget

2. **Analyser les logs:**
   - Si une règle bloque légitimement: OK
   - Si une règle bloque un cas d'usage valide: ajuster

## 🧪 Plan de Test Complet

### Tests Unitaires de Sécurité

#### Test 1: Firestore Rules - Utilisateur Non Authentifié

```bash
# Via Firebase Emulator (optionnel)
firebase emulators:start --only firestore

# Tester dans le code:
# Essayer de lire/écrire sans être connecté
# Doit échouer: PermissionDenied
```

#### Test 2: Firestore Rules - Client

**Scénarios:**
- ✅ Lire ses propres commandes
- ✅ Créer une commande
- ❌ Modifier une commande existante
- ✅ Lire les produits
- ❌ Créer/modifier un produit
- ❌ Modifier le rôle dans users

#### Test 3: Firestore Rules - Admin

**Scénarios:**
- ✅ Lire toutes les commandes
- ✅ Modifier toutes les commandes
- ✅ Créer/modifier/supprimer des produits
- ✅ Modifier les rôles utilisateurs
- ✅ Modifier les configs (home, texts, popups, etc.)

#### Test 4: Storage Rules - Client

**Scénarios:**
- ✅ Lire les images produits
- ❌ Uploader une image
- ❌ Supprimer une image

#### Test 5: Storage Rules - Admin

**Scénarios:**
- ✅ Lire les images
- ✅ Uploader une image (JPEG/PNG)
- ✅ Supprimer une image
- ❌ Uploader un fichier non-image
- ❌ Uploader un fichier > 5MB

### Tests Fonctionnels

#### Test 6: App Check - Mode Debug

1. Configurer le debug token
2. Lancer l'app
3. Vérifier qu'il n'y a pas d'erreur "App Check"
4. Les requêtes Firestore/Storage doivent passer

#### Test 7: App Check - Mode Production

1. Build release sans debug token
2. Vérifier que Play Integrity fonctionne
3. Les requêtes doivent passer si l'app est valide

#### Test 8: Crashlytics

1. Forcer un crash:
   ```dart
   throw Exception('Test crash');
   ```
2. Attendre 5-10 minutes
3. Vérifier dans Firebase Console → Crashlytics
4. Le crash doit apparaître avec stack trace déobfusqué

#### Test 9: Proguard

1. Build release
2. Lancer l'app
3. Tester toutes les fonctionnalités principales
4. Vérifier qu'aucune fonctionnalité n'est cassée par l'obfuscation

### Tests de Régression

**Vérifier que rien n'est cassé:**

- [ ] Login/Logout fonctionne
- [ ] Navigation entre écrans
- [ ] Affichage des produits
- [ ] Création de commande
- [ ] Panier
- [ ] Roulette
- [ ] Rewards
- [ ] Admin Studio (pour admin)
- [ ] Kitchen Board (pour kitchen)
- [ ] Staff Tablet (pour admin)

## 🐛 Résolution de Problèmes

### Problème 1: "App Check token expired"

**Cause:** Le debug token n'est pas configuré ou a expiré

**Solution:**
```bash
# Android
adb shell setprop debug.firebase.appcheck.debug_token "<NOUVEAU_TOKEN>"

# Ou dans Firebase Console → App Check → Debug tokens
# Générer un nouveau token
```

### Problème 2: "Permission denied" dans Firestore

**Causes possibles:**

1. **Les rules ne sont pas déployées:**
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Le rôle utilisateur n'est pas configuré:**
   - Vérifier dans Firestore que `users/{uid}.role` existe
   - Valeur doit être exactement: `'admin'`, `'client'`, ou `'kitchen'`

3. **L'utilisateur doit se reconnecter:**
   ```dart
   // Se déconnecter
   await FirebaseAuth.instance.signOut();
   // Se reconnecter
   ```

### Problème 3: Build release crash au démarrage

**Cause:** Proguard a supprimé des classes nécessaires

**Solution:**
1. Vérifier les règles dans `android/app/proguard-rules.pro`
2. Ajouter `-keep` pour les classes problématiques
3. Analyser le mapping file pour identifier la classe

### Problème 4: Crashlytics ne reçoit pas les rapports

**Solutions:**

1. **Vérifier l'initialisation:**
   ```dart
   // Dans main.dart
   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
   ```

2. **Vérifier le plugin Gradle:**
   ```kotlin
   // android/app/build.gradle.kts
   id("com.google.firebase.crashlytics")
   ```

3. **Forcer l'envoi:**
   ```bash
   # Le rapport peut prendre 5-10 minutes
   # Redémarrer l'app force l'envoi
   ```

4. **Vérifier le mapping file:**
   - Upload dans Firebase Console → Crashlytics → Mappings

### Problème 5: APK release trop volumineux

**Solutions:**

1. **Vérifier que shrinkResources est activé:**
   ```kotlin
   isShrinkResources = true
   ```

2. **Analyser la taille:**
   ```bash
   flutter build apk --release --analyze-size
   ```

3. **Considérer App Bundle:**
   ```bash
   flutter build appbundle --release
   # Plus petit, optimisé par Play Store
   ```

## ✅ Checklist Finale

### Avant le Déploiement

- [ ] `flutter pub get` exécuté sans erreurs
- [ ] Firebase CLI installé et authentifié
- [ ] App Check configuré dans Firebase Console
- [ ] Debug token configuré pour le dev
- [ ] Crashlytics activé dans Firebase Console
- [ ] Firestore Rules testées dans le simulateur
- [ ] Storage Rules vérifiées
- [ ] Build debug testé sur appareil réel

### Déploiement

- [ ] `firebase deploy --only firestore:rules,storage` réussi
- [ ] Rules vérifiées dans Firebase Console
- [ ] Build release réussi
- [ ] APK/AAB release testé
- [ ] Mapping file uploadé sur Crashlytics

### Post-Déploiement

- [ ] App Check métriques vérifiées (pas d'erreurs massives)
- [ ] Crashlytics reçoit les rapports de test
- [ ] Tous les tests fonctionnels passent
- [ ] Tests de régression OK
- [ ] Documentation mise à jour
- [ ] Équipe informée des changements

## 📚 Ressources

- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Firebase App Check](https://firebase.google.com/docs/app-check)
- [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
- [Android Proguard](https://developer.android.com/studio/build/shrink-code)
- [Flutter Build Release](https://docs.flutter.dev/deployment/android)

## 🎯 Prochaines Étapes (Optionnel)

1. **Migration vers Custom Claims:**
   - Voir `ADMIN_ROLE_SETUP.md`
   - Nécessite Cloud Functions

2. **Monitoring Avancé:**
   - Firebase Performance Monitoring
   - Analytics pour les erreurs de sécurité

3. **CI/CD:**
   - Automatiser le déploiement des rules
   - Tests automatiques des rules
   - Build automatique release

4. **Audits Réguliers:**
   - Vérifier les Security Rules mensuellement
   - Analyser les rapports Crashlytics
   - Monitorer les métriques App Check
