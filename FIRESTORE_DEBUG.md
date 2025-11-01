# 🔍 Guide de Débogage Firestore

## Problème: Les pizzas ne s'enregistrent pas dans Firestore

### ✅ Étape 1: Vérifier Firebase Console

1. Ouvrez votre **Firebase Console**: https://console.firebase.google.com/
2. Sélectionnez votre projet **delizza-appli**
3. Allez dans **Firestore Database** (menu de gauche)
4. Vérifiez si vous avez des collections (`pizzas`, `menus`, `orders`)

### ✅ Étape 2: Vérifier les Règles Firestore

Dans Firebase Console → Firestore Database → **Rules** (onglet), vous devez avoir:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **IMPORTANT**: Ces règles sont pour le développement uniquement!

Cliquez sur **Publier** pour activer les règles.

### ✅ Étape 3: Vérifier les Logs de l'Application

Quand vous lancez l'app avec `flutter run -d web-server`:

1. Ouvrez votre navigateur sur `http://localhost:PORT`
2. Ouvrez la **Console JavaScript** (F12 → Console)
3. Connectez-vous en admin
4. Créez une pizza
5. Regardez les logs dans la console

**Logs attendus:**
```
🔥 FirestoreProductService: Tentative d'ajout de pizza "Margherita" à Firestore...
✅ Pizza ajoutée à Firestore avec ID: abc123xyz
✅ Pizza sauvegardée localement
```

**Si vous voyez une erreur:**
```
❌ ERREUR lors de l'ajout à Firestore: [Firebase Error]
📱 Fallback: sauvegarde locale uniquement
```

### 🐛 Erreurs Communes

#### 1. Permission denied (Insufficient permissions)

**Cause**: Les règles Firestore bloquent l'accès

**Solution**: 
- Allez dans Firebase Console → Firestore → Rules
- Mettez `allow read, write: if true;`
- Publiez les règles

#### 2. Firebase not initialized

**Cause**: Firebase n'a pas démarré correctement

**Solution**:
```bash
flutter clean
flutter pub get
flutter run -d web-server
```

#### 3. Collection vide dans Firebase Console

**Cause**: C'est NORMAL! Les collections apparaissent SEULEMENT après avoir ajouté des documents.

**Test**:
1. Créez une pizza dans l'app
2. Regardez les logs (F12)
3. Si vous voyez "✅ Pizza ajoutée à Firestore", rafraîchissez Firebase Console
4. La collection `pizzas/` devrait apparaître

### ✅ Étape 4: Test Manuel dans la Console

Dans la console JavaScript (F12), testez manuellement:

```javascript
// Vérifier que Firebase est chargé
console.log(firebase);

// Tester l'ajout manuel
firebase.firestore().collection('test').add({
  test: 'donnée de test',
  timestamp: new Date()
}).then(doc => {
  console.log('✅ Test réussi! ID:', doc.id);
}).catch(err => {
  console.error('❌ Erreur:', err);
});
```

### ✅ Étape 5: Vérifier la Configuration Firebase

Vérifiez que `lib/firebase_options.dart` existe et contient:
- `projectId`
- `storageBucket`
- `apiKey`

### 📞 Diagnostics Complets

Si rien ne fonctionne, partagez les informations suivantes:

1. **Logs de la console** (F12 → Console) quand vous créez une pizza
2. **Capture d'écran** de vos règles Firestore
3. **Erreur exacte** affichée (si elle existe)

### 🎯 Solution Temporaire (Mode Hors Ligne)

L'application fonctionne **100% en mode local** même sans Firestore.

Les données sont sauvegardées sur votre appareil (SharedPreferences) et persistent entre les sessions.

Firebase n'est nécessaire QUE pour:
- Synchronisation multi-appareils
- Accès depuis n'importe quel appareil
- Sauvegarde cloud

## 🔧 Commandes Utiles

```bash
# Nettoyer et reconstruire
flutter clean
flutter pub get

# Lancer en mode web avec logs
flutter run -d web-server -v

# Voir les logs Firebase
# (Dans la console browser - F12)
```

## 📝 Notes

- Les messages avec 🔥 = Tentatives Firestore
- Les messages avec ✅ = Succès
- Les messages avec ❌ = Erreur (passe en mode local)
- Les messages avec 📱 = Utilisation du cache local
