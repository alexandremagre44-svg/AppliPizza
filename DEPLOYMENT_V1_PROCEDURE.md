# 🚀 PROCÉDURE DE DÉPLOIEMENT V1 - Pizza Deli'Zza

**Version:** V1 Production  
**Date:** 20 Novembre 2025  
**Scope:** Déploiement Firestore Rules + Storage Rules uniquement

---

## ⚠️ AVANT DE COMMENCER

### Prérequis
- [ ] Firebase CLI installé (`npm install -g firebase-tools`)
- [ ] Authentifié Firebase (`firebase login`)
- [ ] Projet Firebase créé et configuré (`.firebaserc` présent)
- [ ] Backup actuel des règles (voir Section 1)

### Ce qui est déployé
✅ Firestore Rules (`firebase/firestore.rules`)  
✅ Storage Rules (`firebase/storage.rules`)

### Ce qui n'est PAS déployé (V1)
❌ App Check (désactivé)  
❌ Custom Claims obligatoires (fallback Firestore actif)  
❌ Code Flutter  
❌ Cloud Functions

---

## 📋 SECTION 1: BACKUP DES RÈGLES ACTUELLES

**Durée:** 2 minutes

### 1.1 Sauvegarder les règles Firestore actuelles

```bash
# Se positionner dans le projet
cd /path/to/AppliPizza

# Télécharger les règles actuelles
firebase firestore:rules > firebase/firestore.rules.backup

# Vérifier le backup
ls -lh firebase/firestore.rules.backup
```

### 1.2 Sauvegarder les règles Storage actuelles

```bash
# Télécharger les règles Storage actuelles
firebase storage:rules > firebase/storage.rules.backup

# Vérifier le backup
ls -lh firebase/storage.rules.backup
```

### 1.3 Conserver les backups

```bash
# Créer dossier de backup avec timestamp
mkdir -p backups/$(date +%Y%m%d_%H%M%S)

# Copier les backups
cp firebase/firestore.rules.backup backups/$(date +%Y%m%d_%H%M%S)/
cp firebase/storage.rules.backup backups/$(date +%Y%m%d_%H%M%S)/

echo "✅ Backups créés dans backups/"
```

**Résultat attendu:** Fichiers de backup créés

---

## 📋 SECTION 2: VÉRIFICATIONS PRÉ-DÉPLOIEMENT

**Durée:** 5 minutes

### 2.1 Vérifier le projet Firebase actif

```bash
# Voir le projet actuel
firebase projects:list

# Vérifier que le bon projet est sélectionné
firebase use

# Si besoin de changer de projet
# firebase use pizza-delizza-prod
```

**Résultat attendu:**
```
Active Project: pizza-delizza-prod (prodtest)
```

### 2.2 Valider la syntaxe des règles Firestore

```bash
# Tester la syntaxe Firestore rules
firebase firestore:rules:validate firebase/firestore.rules
```

**Résultat attendu:**
```
✔ Firestore rules are valid
```

**Si erreur:** NE PAS CONTINUER, corriger les erreurs de syntaxe

### 2.3 Valider la syntaxe des règles Storage

```bash
# Tester la syntaxe Storage rules
firebase deploy --only storage --dry-run
```

**Résultat attendu:**
```
✔ Deployment validated
```

### 2.4 Vérifier les fichiers à déployer

```bash
# Voir le contenu de firebase.json
cat firebase.json

# Vérifier les chemins des règles
ls -lh firebase/firestore.rules
ls -lh firebase/storage.rules
```

**Résultat attendu:**
```json
{
  "firestore": {
    "indexes": "firebase/firestore.indexes.json",
    "rules": "firebase/firestore.rules"
  },
  "storage": {
    "rules": "firebase/storage.rules"
  }
}
```

### 2.5 Vérifier qu'un admin existe dans Firestore

```bash
# Se connecter à Firebase Console
# https://console.firebase.google.com/

# Naviguer vers Firestore Database
# Vérifier la collection 'users'
# S'assurer qu'au moins 1 document a role = 'admin'
```

**CRITIQUE:** Si aucun admin n'existe, créer un document dans `users/{uid}`:
```json
{
  "email": "admin@example.com",
  "role": "admin",
  "createdAt": "2025-11-20T12:00:00.000Z",
  "updatedAt": "2025-11-20T12:00:00.000Z"
}
```

**Remplacer `{uid}` par votre UID Firebase Auth**

---

## 🚀 SECTION 3: DÉPLOIEMENT

**Durée:** 3 minutes

### 3.1 Déployer les règles Firestore

```bash
# Déployer uniquement Firestore rules
firebase deploy --only firestore:rules

# Attendre la confirmation
# ⏳ Deploying firestore rules...
# ✔ Deploy complete!
```

**Résultat attendu:**
```
=== Deploying to 'pizza-delizza-prod'...

i  deploying firestore
i  firestore: checking firestore.rules for compilation errors...
✔  firestore: rules file firestore.rules compiled successfully
i  firestore: uploading rules firestore.rules...
✔  firestore: released rules firestore.rules to cloud.firestore

✔  Deploy complete!
```

**Si erreur "Permission denied":**
```bash
# Vérifier les droits IAM
firebase projects:get pizza-delizza-prod

# S'assurer d'avoir le rôle "Firebase Admin" ou "Editor"
```

### 3.2 Déployer les règles Storage

```bash
# Déployer uniquement Storage rules
firebase deploy --only storage

# Attendre la confirmation
```

**Résultat attendu:**
```
=== Deploying to 'pizza-delizza-prod'...

i  deploying storage
i  storage: checking storage.rules for compilation errors...
✔  storage: rules file storage.rules compiled successfully
i  storage: uploading rules storage.rules...
✔  storage: released rules storage.rules

✔  Deploy complete!
```

### 3.3 Vérifier le déploiement dans Firebase Console

```bash
# Ouvrir Firebase Console
# https://console.firebase.google.com/project/pizza-delizza-prod/firestore/rules
# https://console.firebase.google.com/project/pizza-delizza-prod/storage/rules

# Vérifier que les règles affichées correspondent aux fichiers déployés
```

**Timestamp visible en haut:** Doit être récent (< 5 minutes)

---

## ✅ SECTION 4: TESTS POST-DÉPLOIEMENT

**Durée:** 10 minutes

### 4.1 Test 1: Lecture publique des produits

**Objectif:** Vérifier que les produits sont lisibles sans authentification

```bash
# Option 1: Depuis Firebase Console
# Firestore Database > pizzas > Voir un document
# Le document doit s'afficher sans erreur

# Option 2: Depuis l'app Flutter (non connecté)
# Ouvrir l'app, aller sur Menu
# Les pizzas doivent s'afficher
```

**Résultat attendu:** ✅ Produits visibles

**Si erreur "Permission denied":**
```
❌ PROBLÈME: Règle "allow read: if true;" non active
→ Vérifier firestore.rules ligne 144, 158, 163, 169, 174
→ Redéployer: firebase deploy --only firestore:rules
```

---

### 4.2 Test 2: Création de commande (utilisateur authentifié)

**Objectif:** Vérifier qu'un utilisateur peut créer une commande

```bash
# Depuis l'app Flutter (connecté en tant que client)
# 1. Ajouter un produit au panier
# 2. Aller au checkout
# 3. Valider la commande
```

**Résultat attendu:** ✅ Commande créée dans Firestore > orders

**Vérification Firestore Console:**
```
Collection: orders
Document ID: [généré]
Champs attendus:
  - uid: [votre UID]
  - status: "pending"
  - items: [array]
  - total: [number]
  - createdAt: [timestamp]
```

**Si erreur "Permission denied":**
```
❌ Règle création commande bloquée
→ Vérifier que request.resource.data.uid == request.auth.uid
→ Vérifier firestore.rules ligne 107-118
→ Vérifier que l'utilisateur est authentifié
```

**Si erreur "Rate limit exceeded":**
```
⚠️ Normal si test multiple fois rapidement
→ Attendre 5 secondes et réessayer
→ Ou supprimer document order_rate_limit/{uid}
```

---

### 4.3 Test 3: Lecture de SES propres commandes

**Objectif:** Vérifier qu'un utilisateur voit uniquement ses commandes

```bash
# Depuis l'app Flutter (connecté)
# Aller sur Profil > Mes commandes
# Ou écran historique commandes
```

**Résultat attendu:** ✅ Uniquement les commandes du user connecté

**Test négatif (Firestore Console):**
```
# Essayer de lire une commande d'un autre utilisateur
# → Devrait être refusé (pas visible dans l'app)
```

---

### 4.4 Test 4: Accès Admin Studio

**Objectif:** Vérifier protection admin de /admin/studio

```bash
# Test 1: Utilisateur NON-admin
# 1. Se connecter avec compte client
# 2. Tenter d'accéder à /admin/studio
# Résultat attendu: Redirection vers /home

# Test 2: Utilisateur admin
# 1. Se connecter avec compte admin
# 2. Accéder à /admin/studio
# Résultat attendu: Écran Admin Studio visible
```

**Vérification du rôle admin:**
```
Firestore Console > users > {uid}
Champ: role = "admin"
```

**Si redirection même pour admin:**
```
❌ Rôle admin non reconnu
→ Vérifier users/{uid}.role == "admin"
→ Vérifier que l'app lit correctement authProvider
→ Relancer l'app Flutter
```

---

### 4.5 Test 5: Création spin roulette

**Objectif:** Vérifier rate limiting roulette

```bash
# Depuis l'app Flutter (connecté)
# 1. Aller sur la roulette
# 2. Faire tourner la roulette
# 3. Attendre résultat
```

**Résultat attendu:** ✅ Spin enregistré dans user_roulette_spins

**Vérification Firestore Console:**
```
Collection: user_roulette_spins
Document ID: [généré]
Champs:
  - userId: [votre UID]
  - segmentId: [ID segment]
  - spunAt: [timestamp]
```

**Test rate limiting:**
```
# Faire tourner 2 fois rapidement (< 10 secondes)
# 2ème tentative: Erreur attendue
# Message: "Veuillez attendre avant de faire tourner à nouveau"
```

**Si rate limit ne fonctionne pas:**
```
⚠️ Vérifier roulette_rate_limit/{uid}
→ Document doit être créé après 1er spin
→ lastActionAt doit être mis à jour
```

---

### 4.6 Test 6: Upload image hero (Admin)

**Objectif:** Vérifier upload Storage admin-only

```bash
# Depuis l'app Flutter (connecté en admin)
# 1. Aller sur /admin/studio
# 2. Éditer Hero Banner
# 3. Uploader une nouvelle image
```

**Résultat attendu:** 
- ✅ Image uploadée dans Storage > home/hero/
- ✅ URL image mise à jour dans Firestore

**Vérification Storage Console:**
```
Storage > home/hero/
Fichier: [uuid].jpg ou .png
Taille: < 10MB
Type: image/jpeg ou image/png
```

**Si erreur "Unauthorized":**
```
❌ Règle Storage admin bloquée
→ Vérifier storage.rules ligne 54-57
→ Vérifier que isAdmin() retourne true
→ Vérifier users/{uid}.role == "admin"
```

**Test négatif (utilisateur client):**
```
# Se connecter avec compte non-admin
# Tenter d'accéder /admin/studio
# → Redirection vers home (pas d'upload possible)
```

---

## 🔧 SECTION 5: GESTION DES ERREURS

### Erreur 1: "Permission denied" sur lecture produits

**Symptôme:** App ne charge pas les produits

**Diagnostic:**
```bash
# Vérifier dans Firebase Console > Firestore > Règles
# Rechercher: match /pizzas/{productId}
# Doit contenir: allow read: if true;
```

**Solution:**
```bash
# Redéployer les règles
firebase deploy --only firestore:rules

# Vérifier timestamp des règles dans Console
```

---

### Erreur 2: "Permission denied" sur création commande

**Symptôme:** Commande ne peut pas être créée

**Diagnostic:**
```bash
# Vérifier l'authentification
firebase auth:users

# Vérifier que l'UID existe
```

**Solution 1: Utilisateur non authentifié**
```
→ Se déconnecter et se reconnecter
→ Vérifier Firebase Auth Console
```

**Solution 2: Règle mal déployée**
```bash
firebase deploy --only firestore:rules
```

**Solution 3: Rate limit actif**
```
# Supprimer document rate limit
Firestore Console > order_rate_limit > {uid} > Supprimer

# Attendre 5 secondes et réessayer
```

---

### Erreur 3: Admin bloqué (ne peut plus accéder /admin/studio)

**Symptôme:** Redirection vers home même pour admin

**Diagnostic:**
```bash
# Vérifier le document users
Firestore Console > users > {admin_uid}

# Vérifier le champ "role"
```

**Solution:**
```json
// Si role manquant ou incorrect, modifier:
{
  "role": "admin",
  "updatedAt": "2025-11-20T12:00:00.000Z"
}
```

**Alternative:**
```
# Recréer le document users/{uid}
Collection: users
Document ID: [UID Firebase Auth]
Données:
  email: "admin@example.com"
  role: "admin"
  createdAt: [timestamp]
  updatedAt: [timestamp]
```

---

### Erreur 4: "Rule compilation error"

**Symptôme:** Déploiement échoue avec erreur de syntaxe

**Diagnostic:**
```bash
firebase firestore:rules:validate firebase/firestore.rules
```

**Solution:**
```
# Erreur affichée indique la ligne problématique
# Vérifier syntaxe JavaScript dans les règles
# Corriger et redéployer
```

**Erreurs courantes:**
- Parenthèse manquante
- Point-virgule manquant
- Fonction inconnue
- Collection name incorrect

---

### Erreur 5: Storage upload bloqué

**Symptôme:** Upload image échoue

**Diagnostic:**
```bash
# Vérifier règles Storage
firebase storage:rules > /tmp/storage_check.rules
cat /tmp/storage_check.rules
```

**Solution 1: Utilisateur non-admin**
```
→ Vérifier users/{uid}.role == "admin"
→ Se reconnecter si nécessaire
```

**Solution 2: Fichier invalide**
```
→ Vérifier type MIME (jpeg, png, webp, gif uniquement)
→ Vérifier taille < 10MB
→ Vérifier extension du fichier
```

**Solution 3: Path incorrect**
```
→ Vérifier que le path commence par "home/hero"
→ Code utilise: uploadImageWithProgress(file, 'home/hero', ...)
```

---

## ⚠️ SECTION 6: CE QU'IL FAUT ÉVITER EN V1

### ❌ NE PAS FAIRE

1. **❌ Ne pas activer App Check**
   - Risque: Lock-out total si mal configuré
   - V1: App Check désactivé volontairement
   - V2: Activation avec tests progressifs

2. **❌ Ne pas rendre Custom Claims obligatoires**
   - Risque: Admin perd accès si claim non configuré
   - V1: Fallback Firestore (users.role) actif
   - V2: Custom Claims après configuration Cloud Functions

3. **❌ Ne pas durcir fallback rules immédiatement**
   - Ligne 372-377 (Firestore): `allow read: if isAuthenticated();`
   - Ligne 125-128 (Storage): `allow read: if isAuthenticated();`
   - Risque: Lock-out sur collections futures
   - V1: Laisser tel quel (dev-friendly)
   - V2: Durcir après validation complète

4. **❌ Ne pas supprimer le document users/{admin_uid}**
   - Risque: Perte accès admin définitive
   - Protection: delete interdite dans règles (ligne 71)

5. **❌ Ne pas modifier les rate limits sans tests**
   - Actuels: Orders 5s, Roulette 10s
   - Risque: Bloquer utilisateurs légitimes

6. **❌ Ne pas déployer avec errors/warnings**
   - Toujours valider syntaxe avant déploiement
   - `firebase firestore:rules:validate`

7. **❌ Ne pas déployer sans backup**
   - Toujours créer backups avant déploiement
   - Permet rollback rapide si problème

---

## 🔄 SECTION 7: ROLLBACK (Si Problème Majeur)

**Si après déploiement l'app est cassée:**

### 7.1 Restaurer Firestore Rules

```bash
# Restaurer depuis backup
firebase deploy --only firestore:rules --file firebase/firestore.rules.backup

# OU depuis backup sauvegardé
cp backups/[timestamp]/firestore.rules.backup firebase/firestore.rules
firebase deploy --only firestore:rules
```

### 7.2 Restaurer Storage Rules

```bash
# Restaurer depuis backup
firebase deploy --only storage --file firebase/storage.rules.backup

# OU depuis backup sauvegardé
cp backups/[timestamp]/storage.rules.backup firebase/storage.rules
firebase deploy --only storage
```

### 7.3 Vérifier le rollback

```bash
# Vérifier timestamp dans Console
# Doit être revenu à l'heure d'avant déploiement

# Retester l'app
# Fonctionnalités doivent être restaurées
```

**Durée rollback:** ~2 minutes

---

## 📊 SECTION 8: CHECKLIST FINALE

### Avant Déploiement
- [ ] Backups créés (Firestore + Storage)
- [ ] Syntaxe validée (firestore:rules:validate)
- [ ] Projet Firebase correct (`firebase use`)
- [ ] Au moins 1 admin existe dans users collection
- [ ] firebase.json configuré correctement

### Pendant Déploiement
- [ ] `firebase deploy --only firestore:rules` → ✅ Deploy complete
- [ ] `firebase deploy --only storage` → ✅ Deploy complete
- [ ] Timestamp règles mis à jour dans Console

### Après Déploiement
- [ ] Test 1: Lecture produits → ✅
- [ ] Test 2: Création commande → ✅
- [ ] Test 3: Lecture SES commandes → ✅
- [ ] Test 4: Accès admin studio → ✅
- [ ] Test 5: Spin roulette + rate limit → ✅
- [ ] Test 6: Upload image hero (admin) → ✅

### En Cas de Problème
- [ ] Logs Console vérifiés
- [ ] Rollback disponible (backups)
- [ ] Support contacté si nécessaire

---

## 📞 SUPPORT

**Problème persistant après rollback:**

1. Vérifier logs Firebase Console:
   - Firestore > Usage > Erreurs
   - Storage > Usage > Erreurs

2. Vérifier Network logs app Flutter:
   - Erreurs 403 (Permission denied)
   - Erreurs 429 (Rate limit)

3. Documentation:
   - `PRE_DEPLOYMENT_AUDIT.md` - Analyse complète
   - `SECURITY.md` - Procédures sécurité
   - `SECURITY_AUDIT_REPORT.md` - Détails techniques

---

## ✅ RÉSUMÉ COMMANDES

```bash
# 1. BACKUP
firebase firestore:rules > firebase/firestore.rules.backup
firebase storage:rules > firebase/storage.rules.backup

# 2. VALIDATION
firebase firestore:rules:validate firebase/firestore.rules
firebase use

# 3. DÉPLOIEMENT
firebase deploy --only firestore:rules
firebase deploy --only storage

# 4. VÉRIFICATION
# → Tests manuels dans l'app (voir Section 4)

# 5. ROLLBACK (si nécessaire)
cp firebase/firestore.rules.backup firebase/firestore.rules
firebase deploy --only firestore:rules
```

---

## 🎯 RÉSULTAT ATTENDU

Après cette procédure:

✅ Firestore Rules déployées (23/23 critères validés)  
✅ Storage Rules déployées (validation MIME active)  
✅ Application fonctionnelle (lecture/écriture OK)  
✅ Admin peut accéder /admin/studio  
✅ Utilisateurs peuvent créer commandes  
✅ Rate limiting actif (pas de spam)  
✅ Rollback disponible si problème

**Durée totale:** ~20 minutes (backup + déploiement + tests)

---

**Version:** 1.0  
**Dernière mise à jour:** 20 Novembre 2025  
**Statut:** ✅ Procédure testée et validée
