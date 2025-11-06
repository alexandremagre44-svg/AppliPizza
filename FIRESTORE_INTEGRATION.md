# 🔥 Guide d'Intégration Firestore

## Problème Résolu

Les pizzas ajoutées via Firestore n'apparaissaient pas dans l'application car le repository ne chargeait pas les données depuis Firestore.

## Solution Implémentée

✅ **FirestoreProductService créé** (`lib/src/services/firestore_product_service.dart`)
✅ **Repository mis à jour** pour charger depuis Firestore
✅ **Ordre de priorité**: Mock Data → SharedPreferences → **Firestore** (priorité maximale)

---

## 🚀 Comment Activer Firestore

### Étape 1: Ajouter les Dépendances Firebase

Ajoutez dans `pubspec.yaml`:

```yaml
dependencies:
  # ... autres dépendances ...
  
  # Firebase
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
```

Puis exécutez:
```bash
flutter pub get
```

### Étape 2: Initialiser Firebase dans main.dart

Modifiez `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Étape 3: Activer le Service Firestore

Dans `lib/src/services/firestore_product_service.dart`:

1. **Décommentez** l'implémentation `FirestoreProductServiceImpl` (lignes 61-175)
2. **Modifiez** la fonction `createFirestoreProductService()`:

```dart
FirestoreProductService createFirestoreProductService() {
  // ACTIVER CETTE LIGNE:
  return FirestoreProductServiceImpl();
  
  // DÉSACTIVER CETTE LIGNE:
  // return MockFirestoreProductService();
}
```

### Étape 4: Structure Firestore Requise

Votre base Firestore doit avoir ces collections:

```
Firestore Database
├── pizzas/
│   ├── {pizza_id}/
│   │   ├── id: "pizza_id"
│   │   ├── name: "Margherita"
│   │   ├── description: "Tomate, Mozzarella"
│   │   ├── price: 12.50
│   │   ├── imageUrl: "https://..."
│   │   ├── category: "Pizza"
│   │   ├── isMenu: false
│   │   ├── baseIngredients: ["Tomate", "Mozzarella"]
│   │   ├── pizzaCount: 1
│   │   └── drinkCount: 0
│   └── ...
│
└── menus/
    ├── {menu_id}/
    │   ├── id: "menu_id"
    │   ├── name: "Menu Duo"
    │   ├── description: "1 pizza + 1 boisson"
    │   ├── price: 18.90
    │   ├── imageUrl: "https://..."
    │   ├── category: "Menus"
    │   ├── isMenu: true
    │   ├── baseIngredients: []
    │   ├── pizzaCount: 1
    │   └── drinkCount: 1
    └── ...
```

---

## 🔄 Comment Ça Fonctionne Maintenant

### Ordre de Chargement et Fusion

```
1. Mock Data (données de base hardcodées)
   ↓
2. SharedPreferences (produits admin locaux)
   ↓
3. Firestore (produits cloud - PRIORITÉ MAXIMALE)
```

Les produits Firestore **écrasent** les produits avec le même ID dans les autres sources.

### Exemple de Flux

```dart
// Le repository charge depuis 3 sources:
fetchAllProducts() {
  1. mockProducts (6 pizzas hardcodées)
  2. SharedPreferences (pizzas admin locales)
  3. Firestore (3 pizzas cloud)
  
  // Résultat: 
  // - Les 3 pizzas Firestore apparaissent
  // - Les pizzas mock/local avec IDs différents aussi
  // - Si même ID, Firestore a priorité
}
```

### Affichage dans l'App

Les pizzas Firestore apparaissent maintenant:
- ✅ **HomeScreen** (section "Pizzas Populaires")
- ✅ **MenuScreen** (onglet "Pizza")
- ✅ **Recherche** dans MenuScreen
- ✅ **Toutes les catégories**

---

## 🧪 Tester l'Intégration

### Test 1: Vérifier le Chargement

Ajoutez une pizza dans Firestore et observez les logs:

```
🔥 FirestoreProductService: Chargement des pizzas depuis Firestore...
📦 Nombre de pizzas trouvées dans Firestore: 3
✅ Pizzas chargées depuis Firestore et mises en cache localement
```

### Test 2: Vérifier l'Affichage

1. Ouvrez l'app sur mobile
2. Allez sur **HomeScreen** → La pizza Firestore doit apparaître
3. Allez sur **MenuScreen** → Onglet Pizza → La pizza doit apparaître
4. Cherchez le nom de la pizza → Elle doit être trouvée

### Test 3: Ajouter une Nouvelle Pizza

1. Ajoutez une pizza via l'admin ou directement dans Firestore
2. Fermez et rouvrez l'app (ou utilisez pull-to-refresh si implémenté)
3. La nouvelle pizza doit apparaître partout

---

## 🐛 Dépannage

### Problème: Les pizzas n'apparaissent toujours pas

**Vérifiez:**
1. ✅ Firebase est initialisé dans `main.dart`
2. ✅ `FirestoreProductServiceImpl` est activé
3. ✅ Les pizzas existent dans Firestore (bonne collection)
4. ✅ Les champs requis sont présents (id, name, price, etc.)
5. ✅ L'app a les permissions réseau
6. ✅ Les logs Firebase apparaissent dans la console

### Problème: Erreur "Firebase not initialized"

**Solution:** Assurez-vous que `Firebase.initializeApp()` est appelé AVANT `runApp()`.

### Problème: Erreur de parsing JSON

**Solution:** Vérifiez que la structure Firestore correspond exactement au modèle `Product`:
- Tous les champs requis présents
- Types corrects (number pour price, boolean pour isMenu, etc.)
- Arrays pour baseIngredients (même vide: `[]`)

---

## 📝 Notes Importantes

### Priorité des Sources

Si une pizza existe dans plusieurs sources avec le **même ID**:
- Firestore **gagne toujours**
- SharedPreferences écrase mock_data
- mock_data est la base par défaut

### Performance

- Les données Firestore sont chargées **une seule fois** au démarrage
- Mise en cache automatique
- Délai de simulation: 500ms pour UX fluide

### Sécurité

Pour la production, ajoutez des règles Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Lecture publique, écriture admin uniquement
    match /pizzas/{pizzaId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    match /menus/{menuId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

---

## ✅ Checklist de Validation

- [ ] Dépendances Firebase ajoutées dans pubspec.yaml
- [ ] Firebase initialisé dans main.dart
- [ ] FirestoreProductServiceImpl activé
- [ ] Collections Firestore créées (pizzas, menus)
- [ ] Au moins une pizza de test dans Firestore
- [ ] App relancée (pas de hot reload)
- [ ] Logs Firebase visibles
- [ ] Pizza Firestore visible sur HomeScreen
- [ ] Pizza Firestore visible sur MenuScreen

---

**Une fois ces étapes complétées, toutes vos pizzas Firestore apparaîtront automatiquement dans l'application mobile ! 🎉**

*Dernière mise à jour: 6 novembre 2025*
