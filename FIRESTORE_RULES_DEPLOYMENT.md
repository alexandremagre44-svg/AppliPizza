# Déploiement des Règles Firestore - Pizza Deli'Zza

## 📋 Vue d'ensemble

Ce document explique comment déployer les règles Firestore sécurisées pour votre application.

## 🔐 Politique de Sécurité

### Admin Unique
- **UID Admin**: `dbmnp2DdyJaURWJO4YEE5fgv3002`
- **Permissions**: Lecture/Écriture sur TOUT Firestore
- **Usage**: Studio B3, Media Manager, gestion produits/catégories

### Public (Non authentifié)
- **Permissions**: Lecture SEULE
- **Collections autorisées**:
  - `app_configs/{appId}/configs/config` (published uniquement)
  - `products/*`
  - `categories/*`
  - `ingredients/*`
  - `promotions/*`

### Utilisateurs Authentifiés
- **Orders**: Lecture de leurs propres commandes, création uniquement
- **User_profiles**: Lecture/Écriture de leur propre profil
- **Carts**: Lecture/Écriture de leur propre panier
- **Loyalty**: Lecture SEULE de leur propre compte fidélité

## 🚀 Déploiement

### Option 1: Via Firebase Console (Recommandé)

1. **Ouvrir Firebase Console**
   - Aller sur https://console.firebase.google.com
   - Sélectionner votre projet "Pizza Deli'Zza"

2. **Accéder aux règles Firestore**
   - Menu: `Firestore Database`
   - Onglet: `Rules`

3. **Remplacer les règles**
   - Copier tout le contenu de `firestore.rules`
   - Coller dans l'éditeur Firebase
   - Cliquer sur `Publier`

4. **Vérifier le déploiement**
   - Un message de confirmation apparaît
   - Les règles sont actives immédiatement

### Option 2: Via Firebase CLI

```bash
# 1. Installer Firebase CLI (si pas déjà fait)
npm install -g firebase-tools

# 2. Se connecter à Firebase
firebase login

# 3. Initialiser le projet (si pas déjà fait)
firebase init

# 4. Déployer les règles uniquement
firebase deploy --only firestore:rules

# 5. Vérifier le déploiement
firebase firestore:rules get
```

## ✅ Vérification Post-Déploiement

### Test 1: Accès Admin (Vous)
```javascript
// Dans Studio B3 ou console
// Devrait réussir
await firestore.collection('app_configs')
  .doc('pizza_delizza')
  .collection('configs')
  .doc('config_draft')
  .set({test: 'ok'});
```

### Test 2: Lecture Publique
```javascript
// Dans l'app client (non authentifié)
// Devrait réussir
const products = await firestore.collection('products').get();
const config = await firestore
  .collection('app_configs/pizza_delizza/configs')
  .doc('config')
  .get();
```

### Test 3: Écriture Publique (Doit échouer)
```javascript
// Dans l'app client
// Devrait ÉCHOUER avec permission-denied
await firestore.collection('products').add({name: 'test'});
// ❌ PERMISSION_DENIED: Missing or insufficient permissions
```

### Test 4: Accès Draft Public (Doit échouer)
```javascript
// Dans l'app client
// Devrait ÉCHOUER
const draft = await firestore
  .collection('app_configs/pizza_delizza/configs')
  .doc('config_draft')
  .get();
// ❌ PERMISSION_DENIED
```

## 🎯 Collections et Permissions

| Collection | Admin | Public | Auth User |
|------------|-------|--------|-----------|
| `app_configs/.../config` | ✅ R/W | ✅ R | ✅ R |
| `app_configs/.../config_draft` | ✅ R/W | ❌ | ❌ |
| `products` | ✅ R/W | ✅ R | ✅ R |
| `categories` | ✅ R/W | ✅ R | ✅ R |
| `ingredients` | ✅ R/W | ✅ R | ✅ R |
| `promotions` | ✅ R/W | ✅ R | ✅ R |
| `uploads` | ✅ R/W | ❌ | ❌ |
| `orders` | ✅ R/W | ❌ | ✅ R (own) / C |
| `user_profiles` | ✅ R/W | ❌ | ✅ R/W (own) |
| `carts` | ✅ R/W | ❌ | ✅ R/W (own) |
| `loyalty` | ✅ R/W | ❌ | ✅ R (own) |
| `campaigns` | ✅ R/W | ❌ | ❌ |
| `subscribers` | ✅ R/W | ✅ C | ✅ C |
| `email_templates` | ✅ R/W | ❌ | ❌ |
| `_b3_test` | ✅ R/W | ❌ | ❌ |

**Légende**: R = Read, W = Write, C = Create only

## 🛡️ Sécurité Garantie

### ✅ Ce qui est protégé
- Draft configs (Studio B3 uniquement)
- Uploads/Media (Admin uniquement)
- Données sensibles (campaigns, templates)
- Profils utilisateurs (isolation par UID)
- Programme fidélité (lecture seule pour users)

### ✅ Ce qui est public (read-only)
- Published app config
- Catalogue produits
- Catégories
- Ingrédients
- Promotions actives

### ❌ Ce qui est interdit
- Écriture publique sur ANY collection
- Lecture des drafts par public
- Lecture des uploads par public
- Modification des points fidélité par users
- Suppression de commandes par users

## 🔧 Fonctionnalités Garanties

### Studio B3 ✅
```dart
// Écriture dans draft - OK
await configService.saveDraft(appId: 'pizza_delizza', config: config);

// Écriture dans published - OK
await configService.publishDraft(appId: 'pizza_delizza');
```

### B3 Auto-Init ✅
```dart
// Test de permissions - OK
await firestore.collection('_b3_test').doc('__b3_init__').set({...});

// Création des 4 pages B3 - OK
await firestore.collection('app_configs/pizza_delizza/configs')
  .doc('config').set({pages: {...}});
```

### Migration V2→B3 ✅
```dart
// Écriture des pages migrées - OK
await firestore.collection('app_configs/pizza_delizza/configs')
  .doc('config').set(migratedConfig.toJson(), SetOptions(merge: true));
```

### App Client ✅
```dart
// Lecture published config - OK
final config = await firestore
  .collection('app_configs/pizza_delizza/configs')
  .doc('config').get();

// Lecture produits - OK
final products = await firestore.collection('products').get();
```

## 🚨 Résolution de Problèmes

### Erreur: PERMISSION_DENIED dans Studio B3

**Cause**: Vous n'êtes pas authentifié avec le bon compte

**Solution**:
1. Vérifier que vous êtes connecté avec l'UID: `dbmnp2DdyJaURWJO4YEE5fgv3002`
2. Dans Firebase Console: Authentication > Users
3. Vérifier l'UID de votre compte
4. Si différent, mettre à jour `firestore.rules` ligne 14 avec le bon UID

### Erreur: PERMISSION_DENIED dans l'app client

**Cause**: Tentative d'écriture ou de lecture de draft

**Solution**:
1. Vérifier que l'app lit uniquement `config` (pas `config_draft`)
2. Vérifier qu'aucune tentative d'écriture n'est faite
3. Utiliser `appConfigProvider` (published) et non `appConfigDraftProvider` dans l'app client

### Erreur: B3 Init échoue avec PERMISSION_DENIED

**Cause**: Pas authentifié comme admin

**Solution**:
1. L'init auto ne fonctionne QUE si vous êtes authentifié comme admin
2. En debug mode, `forceB3InitializationForDebug()` ignore les erreurs de permission
3. Vérifier les logs: `🔧 DEBUG: Failed to write (expected in restrictive environments)`

## 📝 Notes Importantes

1. **UID Admin**: Si vous changez de compte Firebase, mettez à jour l'UID dans `firestore.rules` ligne 14

2. **Testing Local**: En développement avec émulateur, ces règles s'appliquent aussi. Utilisez:
   ```bash
   firebase emulators:start --only firestore
   ```

3. **Backup**: Avant de déployer de nouvelles règles, sauvegardez les anciennes via Firebase Console

4. **Rollback**: En cas de problème, Firebase garde un historique des règles précédentes dans l'onglet "Rules" > "History"

5. **Monitoring**: Surveillez les erreurs de permission dans Firebase Console > Firestore > Monitor

## 🔄 Maintenance

### Ajouter un nouvel admin
```javascript
// Dans firestore.rules, modifier la fonction isAdmin()
function isAdmin() {
  return request.auth != null && (
    request.auth.uid == "dbmnp2DdyJaURWJO4YEE5fgv3002" ||
    request.auth.uid == "NOUVEAU_UID_ADMIN"
  );
}
```

### Ajouter une nouvelle collection
```javascript
match /nouvelle_collection/{docId} {
  // Admin: accès complet
  allow read, write: if isAdmin();
  
  // Définir les permissions publiques si nécessaire
  allow read: if true; // ou false selon le besoin
  
  // Interdire les écritures publiques
  allow write: if false;
}
```

## ✅ Checklist de Déploiement

- [ ] Vérifier l'UID admin dans `firestore.rules` ligne 14
- [ ] Sauvegarder les anciennes règles (Firebase Console > Rules > History)
- [ ] Copier le contenu de `firestore.rules`
- [ ] Coller dans Firebase Console > Firestore > Rules
- [ ] Cliquer sur "Publier"
- [ ] Attendre la confirmation (quelques secondes)
- [ ] Tester avec Studio B3 (écriture draft) ✅
- [ ] Tester avec App Client (lecture products) ✅
- [ ] Vérifier qu'aucune écriture publique n'est possible ✅
- [ ] Surveiller les logs Firestore pour erreurs de permission

## 🎉 Résultat Attendu

Après déploiement:
- ✅ Studio B3 fonctionne normalement
- ✅ B3 Init/Migration écrivent les pages sans erreur
- ✅ App client lit les données sans problème
- ✅ Aucune écriture non autorisée possible
- ✅ Toutes les données sensibles protégées
- ✅ Logs propres sans erreurs de permission
