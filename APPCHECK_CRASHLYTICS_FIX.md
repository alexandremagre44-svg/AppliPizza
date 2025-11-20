# 🔧 AppCheck & Crashlytics - Fix pour Développement Web

**Date:** 20 Novembre 2025  
**Objectif:** Permettre le développement sur Chrome/Web sans erreurs AppCheck/Crashlytics  
**Statut:** ✅ CORRIGÉ

---

## 📋 PROBLÈMES IDENTIFIÉS

### 1. AppCheck bloquait le développement Web
**Symptôme:** Erreur ReCAPTCHA sur Chrome en mode debug  
**Cause:** AppCheck activé sur Web même en développement  
**Impact:** Impossible de tester l'app sur Chrome en local

### 2. Crashlytics causait des erreurs sur Web
**Symptôme:** `pluginConstants['isCrashlyticsCollectionEnabled'] != null is not true`  
**Cause:** Crashlytics n'est pas supporté sur la plateforme Web  
**Impact:** Erreurs au démarrage et lors de l'authentification

---

## ✅ CORRECTIONS APPLIQUÉES

### 1. AppCheck (lib/main.dart)

**Avant:**
```dart
await FirebaseAppCheck.instance.activate(
  androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
  appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
  webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
);
```

**Après:**
```dart
// DISABLED on Web in debug mode to prevent errors during development
// ENABLED on Android/iOS for production security
if (!(kIsWeb && kDebugMode)) {
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode 
      ? AndroidProvider.debug 
      : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode
      ? AppleProvider.debug
      : AppleProvider.appAttest,
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
  );
}
```

**Résultat:**
- ✅ AppCheck désactivé sur Web en mode debug (pas d'erreur ReCAPTCHA)
- ✅ AppCheck actif sur Android/iOS (Play Integrity, App Attest)
- ✅ AppCheck reste disponible sur Web en production (si besoin)

---

### 2. Crashlytics Initialization (lib/main.dart)

**Avant:**
```dart
FlutterError.onError = (errorDetails) {
  FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
};

PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

**Après:**
```dart
// DISABLED on Web platform (Crashlytics not supported on Web)
if (!kIsWeb) {
  // Enable/disable collection based on debug mode
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
```

**Résultat:**
- ✅ Crashlytics désactivé sur Web (pas d'erreur au démarrage)
- ✅ Crashlytics actif sur Android/iOS
- ✅ Collection désactivée en mode debug (production uniquement)

---

### 3. Error Handler (lib/src/utils/error_handler.dart)

**Avant:**
```dart
if (reportToCrashlytics) {
  FirebaseCrashlytics.instance.recordError(
    error,
    stackTrace,
    reason: context,
    fatal: false,
  );
}
```

**Après:**
```dart
// Only report on non-web platforms (Crashlytics not supported on Web)
if (reportToCrashlytics && !kIsWeb) {
  FirebaseCrashlytics.instance.recordError(
    error,
    stackTrace,
    reason: context,
    fatal: false,
  );
}
```

**Import ajouté:**
```dart
import 'package:flutter/foundation.dart';
```

**Résultat:**
- ✅ Erreurs non rapportées sur Web (évite les crashs)
- ✅ Erreurs rapportées normalement sur Android/iOS

---

### 4. Firebase Auth Service (lib/src/services/firebase_auth_service.dart)

**Changements appliqués (3 endroits):**

#### 4.1 SignIn - setUserIdentifier (ligne 67-71)
```dart
// Only on non-web platforms (Crashlytics not supported on Web)
if (!kIsWeb) {
  await FirebaseCrashlytics.instance.setUserIdentifier(credential.user!.uid);
}
```

#### 4.2 SignIn - recordError (ligne 103-111)
```dart
// Only on non-web platforms (Crashlytics not supported on Web)
if (!kIsWeb) {
  FirebaseCrashlytics.instance.recordError(
    e,
    stackTrace,
    reason: 'signIn failed',
    fatal: false,
  );
}
```

#### 4.3 SignUp - setUserIdentifier (ligne 159-163)
```dart
// Only on non-web platforms (Crashlytics not supported on Web)
if (!kIsWeb) {
  await FirebaseCrashlytics.instance.setUserIdentifier(credential.user!.uid);
}
```

#### 4.4 SignUp - recordError (ligne 192-200)
```dart
// Only on non-web platforms (Crashlytics not supported on Web)
if (!kIsWeb) {
  FirebaseCrashlytics.instance.recordError(
    e,
    stackTrace,
    reason: 'signUp failed',
    fatal: false,
  );
}
```

**Import ajouté:**
```dart
import 'package:flutter/foundation.dart';
```

**Résultat:**
- ✅ Pas d'appel Crashlytics sur Web lors de l'authentification
- ✅ Tracking utilisateur actif sur Android/iOS
- ✅ Erreurs d'auth rapportées sur Android/iOS uniquement

---

## 📊 RÉCAPITULATIF DES MODIFICATIONS

### Fichiers Modifiés (3 fichiers)

| Fichier | Lignes Ajoutées | Lignes Retirées | Changements |
|---------|-----------------|-----------------|-------------|
| lib/main.dart | +30 | -24 | AppCheck + Crashlytics init |
| lib/src/services/firebase_auth_service.dart | +27 | -14 | 4 checks `!kIsWeb` ajoutés |
| lib/src/utils/error_handler.dart | +3 | -1 | 1 check `!kIsWeb` ajouté |
| **TOTAL** | **+60** | **-39** | **3 fichiers** |

### Imports Ajoutés (2 fichiers)

```dart
import 'package:flutter/foundation.dart';  // Pour kIsWeb et kDebugMode
```

Ajouté dans:
- ✅ lib/src/utils/error_handler.dart
- ✅ lib/src/services/firebase_auth_service.dart

---

## 🎯 RÉSULTATS ATTENDUS

### Développement Web (Chrome)
- ✅ **Plus d'erreur AppCheck** - AppCheck désactivé en debug Web
- ✅ **Plus d'erreur Crashlytics** - Tous les appels Crashlytics sont conditionnels
- ✅ **Connexion fonctionnelle** - SignIn/SignUp sans erreurs
- ✅ **Erreurs gérées** - ErrorHandler ne plante plus sur Web

### Production Android/iOS
- ✅ **AppCheck actif** - Play Integrity (Android), App Attest (iOS)
- ✅ **Crashlytics actif** - Reporting d'erreurs complet
- ✅ **User tracking** - setUserIdentifier après auth
- ✅ **Error reporting** - Erreurs auth + générales rapportées

### Mode Debug vs Production
- ✅ **Debug:** Crashlytics collection désactivée (`setCrashlyticsCollectionEnabled(false)`)
- ✅ **Production:** Crashlytics collection activée (`setCrashlyticsCollectionEnabled(true)`)

---

## 🧪 TESTS RECOMMANDÉS

### Test 1: Web Debug (Chrome)
```bash
# Nettoyer le projet
flutter clean
flutter pub get

# Lancer en mode debug Web
flutter run -d chrome

# Actions à tester:
# 1. App démarre sans erreur
# 2. Page login visible
# 3. Connexion avec email/password → succès
# 4. Inscription nouveau compte → succès
# 5. Navigation dans l'app → aucune erreur console
```

**Résultat attendu:** Aucune erreur AppCheck ou Crashlytics dans la console

---

### Test 2: Android Production
```bash
# Build release Android
flutter build apk --release

# Installer sur device
adb install build/app/outputs/flutter-apk/app-release.apk

# Tester:
# 1. AppCheck actif (Play Integrity)
# 2. Crashlytics collecte les erreurs
# 3. User identifier défini après login
```

**Résultat attendu:** Crashlytics Dashboard montre les sessions

---

### Test 3: iOS Production
```bash
# Build release iOS
flutter build ios --release

# Déployer sur TestFlight ou device
# Tester:
# 1. AppCheck actif (App Attest)
# 2. Crashlytics collecte les erreurs
# 3. User identifier défini après login
```

**Résultat attendu:** Crashlytics Dashboard montre les sessions iOS

---

## 🔍 VÉRIFICATIONS TECHNIQUES

### Check 1: kIsWeb est défini partout où nécessaire
```bash
grep -n "kIsWeb" lib/main.dart
grep -n "kIsWeb" lib/src/services/firebase_auth_service.dart
grep -n "kIsWeb" lib/src/utils/error_handler.dart
```

**Résultat attendu:**
- lib/main.dart:52
- lib/main.dart:69
- lib/src/services/firebase_auth_service.dart (4 occurrences)
- lib/src/utils/error_handler.dart:62

---

### Check 2: Import foundation.dart présent
```bash
grep -n "package:flutter/foundation" lib/src/services/firebase_auth_service.dart
grep -n "package:flutter/foundation" lib/src/utils/error_handler.dart
```

**Résultat attendu:**
- Ligne 4 dans firebase_auth_service.dart
- Ligne 8 dans error_handler.dart

---

### Check 3: Aucun appel Crashlytics sans condition
```bash
# Chercher les appels Crashlytics non protégés
grep -n "FirebaseCrashlytics.instance" lib/main.dart lib/src/**/*.dart | grep -v "if (!kIsWeb)"
```

**Résultat attendu:** Uniquement les lignes à l'intérieur des blocs `if (!kIsWeb)`

---

## 🚀 DÉPLOIEMENT

### Étape 1: Commit les changements
```bash
git add lib/main.dart
git add lib/src/services/firebase_auth_service.dart
git add lib/src/utils/error_handler.dart
git commit -m "Fix AppCheck and Crashlytics for web development"
```

### Étape 2: Tester en local
```bash
flutter clean
flutter pub get
flutter run -d chrome  # Test Web
# Vérifier aucune erreur AppCheck/Crashlytics
```

### Étape 3: Push et deploy
```bash
git push origin [branch]

# Rebuild Android/iOS si nécessaire
flutter build apk --release
flutter build ios --release
```

---

## ⚠️ POINTS D'ATTENTION

### 1. Web Production (si déploiement Web prévu)
Si vous déployez sur Web en production:
```dart
// Modifier cette ligne dans main.dart:
if (!(kIsWeb && kDebugMode)) {
  // AppCheck sera actif sur Web production
  // MAIS il faut configurer reCAPTCHA v3 avec une vraie clé
}
```

**Action requise:**
- Créer un site reCAPTCHA v3 dans Google Cloud Console
- Remplacer `'recaptcha-v3-site-key'` par la vraie clé
- Configurer le domaine autorisé

---

### 2. Debug Symbols Android
Pour que Crashlytics déchiffre les stack traces:
```bash
# Après chaque build release
firebase crashlytics:symbols:upload \
  --app=YOUR_ANDROID_APP_ID \
  build/app/outputs/bundle/release/app-release.aab
```

---

### 3. Crashlytics Console
Après déploiement, vérifier:
- Firebase Console > Crashlytics
- Sessions Android/iOS apparaissent
- Pas de sessions Web (normal, désactivé)
- User IDs visibles après authentification

---

## 📝 NOTES TECHNIQUES

### Pourquoi `!kIsWeb` au lieu de `kIsWeb == false`?
```dart
if (!kIsWeb) { ... }  // ✅ Idiomatique Dart
if (kIsWeb == false) { ... }  // ❌ Moins lisible
```

### Pourquoi `!(kIsWeb && kDebugMode)` pour AppCheck?
```dart
// Cette condition signifie:
// Activer AppCheck SAUF si (Web ET Debug)

// Cas 1: Web + Debug → AppCheck désactivé ✅
// Cas 2: Web + Release → AppCheck actif ⚠️
// Cas 3: Android/iOS + Debug → AppCheck debug provider ✅
// Cas 4: Android/iOS + Release → AppCheck production ✅
```

### setCrashlyticsCollectionEnabled(!kDebugMode)
```dart
// Debug mode → collection désactivée
// Production → collection activée
// Évite le spam de crash reports pendant le dev
```

---

## 🔗 RESSOURCES

### Documentation Firebase
- [Firebase App Check](https://firebase.google.com/docs/app-check)
- [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
- [Flutter Web Platform](https://docs.flutter.dev/platform-integration/web)

### Code Reference
- `kIsWeb`: Constant définie par `package:flutter/foundation.dart`
- `kDebugMode`: True en mode debug, false en release/profile

---

## ✅ CHECKLIST VALIDATION

### Avant de merger
- [x] 3 fichiers modifiés
- [x] Tous les appels Crashlytics protégés par `!kIsWeb`
- [x] AppCheck désactivé sur Web debug
- [x] Import `foundation.dart` ajouté où nécessaire
- [ ] Tests manuels Web (Chrome) → aucune erreur
- [ ] Tests manuels Android → Crashlytics actif
- [ ] Tests manuels iOS → Crashlytics actif

### Après merge
- [ ] Monitoring Crashlytics (24h) → sessions Android/iOS
- [ ] Aucune session Web dans Crashlytics (normal)
- [ ] Retours développeurs → Web dev fonctionne

---

**Version:** 1.0  
**Auteur:** Copilot Security Engineer  
**Dernière mise à jour:** 20 Novembre 2025  
**Statut:** ✅ Prêt pour déploiement
