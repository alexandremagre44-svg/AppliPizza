# 🔍 Guide de Dépannage Firestore

## Problème: Les pizzas Firestore ne s'affichent pas

Vous voyez les logs de chargement Firestore mais les pizzas n'apparaissent pas dans l'app ? Suivez ce guide étape par étape.

---

## ✅ Checklist de Vérification

### Étape 1: Vérifier l'Activation de Firestore

Dans `lib/src/services/firestore_product_service.dart`, ligne 187-192:

```dart
FirestoreProductService createFirestoreProductService() {
  // ✅ DOIT ÊTRE ACTIVÉ:
  return FirestoreProductServiceImpl();
  
  // ❌ NE DOIT PAS ÊTRE ACTIF:
  // return MockFirestoreProductService();
}
```

**Important:** Vous DEVEZ décommenter l'implémentation `FirestoreProductServiceImpl` complète (lignes 61-175).

### Étape 2: Vérifier les Logs dans la Console

Après avoir activé le logging détaillé (commit récent), vous devriez voir:

```
📦 Repository: Début du chargement des produits...
📱 Repository: X pizzas depuis SharedPreferences
🔥 Repository: X pizzas depuis Firestore  <-- Important!
🔥 Repository: X menus depuis Firestore
💾 Repository: 14 produits depuis mock_data
  ➕ Ajout pizza admin: ... (ID: ...)
  ⭐ Ajout pizza Firestore: ... (ID: ...)  <-- Vérifiez ces lignes!
✅ Repository: Total de X produits fusionnés
📊 Repository: Catégories présentes: Pizza, Menus, Boissons, Desserts
```

**Si vous ne voyez PAS "⭐ Ajout pizza Firestore":**
- Le service Firestore n'est pas activé correctement
- OU les pizzas Firestore ont des IDs qui matchent exactement les mock data

### Étape 3: Vérifier les IDs dans Firestore

**PROBLÈME FRÉQUENT:** Si vos pizzas Firestore ont les mêmes IDs que les pizzas mock, elles écraseront les mock mais sembleront identiques!

**Mock data IDs existants:**
- `p1` - Margherita Classique
- `p2` - Reine
- `p3` - Végétarienne
- `p4` - 4 Fromages
- `p5` - Chicken Barbecue
- `p6` - Pepperoni

**Menu IDs existants:**
- `m1` - Menu Duo
- `m2` - Menu Famille
- `m3` - Menu Solo

**Solution:** Utilisez des IDs différents dans Firestore!
- Exemple: `firestore_pizza_1`, `firestore_pizza_2`, etc.
- Ou: `fs_p1`, `fs_p2`, etc.

### Étape 4: Vérifier la Structure des Données Firestore

Vos documents Firestore DOIVENT contenir tous ces champs:

```javascript
{
  id: "votre_id_unique",          // ⚠️ OBLIGATOIRE
  name: "Nom de la Pizza",        // ⚠️ OBLIGATOIRE
  description: "Description",      // ⚠️ OBLIGATOIRE
  price: 12.50,                    // ⚠️ OBLIGATOIRE (number, pas string!)
  imageUrl: "https://...",         // ⚠️ OBLIGATOIRE
  category: "Pizza",               // ⚠️ OBLIGATOIRE (exactement "Pizza")
  isMenu: false,                   // ⚠️ OBLIGATOIRE (boolean)
  baseIngredients: ["Tomate"],     // Array (peut être vide: [])
  pizzaCount: 1,                   // Number
  drinkCount: 0                    // Number
}
```

**Erreurs fréquentes:**
- ❌ `price` en string ("12.50" au lieu de 12.50)
- ❌ `category` avec majuscule différente ("pizza" au lieu de "Pizza")
- ❌ Champs manquants
- ❌ `id` manquant dans le document

### Étape 5: Forcer le Rechargement

1. **Fermez complètement l'app** (pas seulement home, mais kill l'app)
2. **Redémarrez l'app** (pas hot reload!)
3. Vérifiez les logs dans la console

Le `FutureProvider` cache les résultats. Un redémarrage complet force le rechargement.

### Étape 6: Vérifier le Filtrage par Catégorie

Dans MenuScreen, quand vous filtrez par "Pizza", le code fait:

```dart
allProducts.where((p) => p.category == _selectedCategory)
```

Si `category` dans Firestore != "Pizza" exactement, ça ne matchera pas!

**Catégories valides:**
- `"Pizza"` (avec majuscule P)
- `"Menus"` (avec s à la fin)
- `"Boissons"`
- `"Desserts"`

---

## 🐛 Diagnostic Pas à Pas

### Test 1: Vérifier que Firestore est Appelé

**Ajoutez cette ligne dans votre FirestoreProductServiceImpl.loadPizzas():**

```dart
developer.log('🔥🔥🔥 FIRESTORE APPELÉ - Nombre de docs: ${snapshot.docs.length}');
```

Si vous ne voyez pas ce log, Firestore n'est pas activé.

### Test 2: Vérifier les Données Chargées

**Dans la console, cherchez:**

```
⭐ Ajout pizza Firestore: NOM_PIZZA (ID: firestore_pizza_1)
```

Si vous voyez "Écrasement" au lieu de "Ajout", c'est que l'ID existe déjà dans mock_data!

### Test 3: Compter les Produits

Dans la console, cherchez:

```
✅ Repository: Total de X produits fusionnés
```

Si X = 14 (nombre de mock products), alors Firestore n'ajoute RIEN.
Si X > 14, alors Firestore ajoute des produits!

### Test 4: Vérifier l'Affichage

1. Ouvrez HomeScreen
2. Scrollez dans "Pizzas Populaires"
3. **Comptez les pizzas** - devrait être > 6 si Firestore ajoute des pizzas

Ou:

1. Ouvrez MenuScreen
2. Cliquez sur "Tous" (pas juste "Pizza")
3. Comptez le nombre total de produits

---

## 🔧 Solutions aux Problèmes Courants

### Problème: "🔥 Repository: 0 pizzas depuis Firestore"

**Cause:** Le service Firestore n'est pas activé OU retourne une liste vide.

**Solution:**
1. Décommentez `FirestoreProductServiceImpl` dans le fichier
2. Activez-le dans `createFirestoreProductService()`
3. Vérifiez que Firebase est initialisé dans `main.dart`

### Problème: "⭐ Écrasement pizza Firestore: ..."

**Cause:** L'ID Firestore existe déjà dans mock_data.

**Solution:**
Changez les IDs dans Firestore pour qu'ils soient uniques:
- Dans la console Firebase, éditez le document
- Changez `id` de `p1` à `fs_p1` (par exemple)
- Ou créez un nouveau document avec un nouvel ID

### Problème: Les pizzas s'affichent mais ne sont pas cliquables

**Cause:** Problème de données (price en string, etc.)

**Solution:**
Vérifiez tous les types de données dans Firestore:
- `price` doit être un `number`
- `isMenu` doit être un `boolean`
- Pas de champs `null`

### Problème: L'app se bloque au chargement

**Cause:** Erreur de parsing JSON depuis Firestore.

**Solution:**
1. Regardez les logs d'erreur détaillés
2. Vérifiez que TOUS les champs requis sont présents
3. Utilisez `Product.fromJson()` correctement

---

## 📊 Interprétation des Logs

### Logs Normaux (Tout Fonctionne)

```
📦 Repository: Début du chargement des produits...
📱 Repository: 0 pizzas depuis SharedPreferences
🔥 Repository: 3 pizzas depuis Firestore  ✅
💾 Repository: 14 produits depuis mock_data
  ⭐ Ajout pizza Firestore: Ma Pizza Test (ID: fs_p1)  ✅
  ⭐ Ajout pizza Firestore: Pizza Spéciale (ID: fs_p2)  ✅
  ⭐ Ajout pizza Firestore: Deluxe (ID: fs_p3)  ✅
✅ Repository: Total de 17 produits fusionnés  ✅ (14 + 3)
```

### Logs Problématiques (Firestore Non Activé)

```
📦 Repository: Début du chargement des produits...
📱 Repository: 0 pizzas depuis SharedPreferences
🔥 Repository: 0 pizzas depuis Firestore  ❌ (devrait être > 0)
💾 Repository: 14 produits depuis mock_data
✅ Repository: Total de 14 produits fusionnés  ❌ (pas de changement)
```

### Logs Problématiques (IDs en Doublon)

```
📦 Repository: Début du chargement des produits...
🔥 Repository: 3 pizzas depuis Firestore
💾 Repository: 14 produits depuis mock_data
  ⭐ Écrasement pizza Firestore: Ma Pizza (ID: p1)  ⚠️ (écrase mock p1)
  ⭐ Écrasement pizza Firestore: Pizza 2 (ID: p2)  ⚠️ (écrase mock p2)
✅ Repository: Total de 14 produits fusionnés  ⚠️ (toujours 14!)
```

---

## 🎯 Checklist Finale

Avant de signaler un bug, vérifiez:

- [ ] FirestoreProductServiceImpl est décommenté
- [ ] `createFirestoreProductService()` retourne `FirestoreProductServiceImpl()`
- [ ] Firebase est initialisé dans main.dart
- [ ] Les pizzas existent dans Firestore (vérifiez dans console Firebase)
- [ ] Les IDs Firestore sont différents des mock IDs (p1-p6, m1-m3)
- [ ] Tous les champs requis sont présents dans Firestore
- [ ] `category` = "Pizza" exactement (majuscule P)
- [ ] `price` est un number, pas un string
- [ ] App redémarrée complètement (pas hot reload)
- [ ] Logs "⭐ Ajout pizza Firestore" visibles dans console
- [ ] Total de produits > 14 dans les logs

Si TOUT est ✅ et ça ne fonctionne toujours pas, partagez:
1. Les logs complets de la console
2. Un screenshot de votre document Firestore
3. La valeur retournée par `createFirestoreProductService()`

---

## 💡 Test Rapide de Validation

Ajoutez ce code temporaire dans HomeScreen.build():

```dart
// DEBUG: Afficher le nombre de produits
ref.watch(productListProvider).whenData((products) {
  developer.log('🎯 NOMBRE DE PRODUITS DANS HOMESCREEN: ${products.length}');
  developer.log('🎯 PIZZAS: ${products.where((p) => p.category == "Pizza").length}');
  for (var p in products.where((p) => p.category == "Pizza")) {
    developer.log('  - ${p.name} (${p.id})');
  }
});
```

Si vous voyez > 6 pizzas listées, Firestore fonctionne!
Si vous voyez = 6 pizzas, Firestore n'ajoute rien.

---

*Document créé le 7 novembre 2025*
*Pour assistance: Partagez vos logs complets*
