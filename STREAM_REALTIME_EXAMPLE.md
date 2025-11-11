# 🔄 Guide de Synchronisation Temps Réel avec Firestore

## Objectif

Ce guide explique comment activer la synchronisation en temps réel pour que les modifications dans Firestore apparaissent instantanément dans l'application sans recharger.

---

## 🎯 Principe

Actuellement, l'app utilise des **FutureProvider** qui chargent les données une seule fois au démarrage.

Avec les **StreamProvider**, l'app écoute les changements Firestore et se met à jour automatiquement.

---

## 📦 Étape 1 : Préparer le Service (Déjà fait ✅)

Le service `FirestoreProductService` inclut déjà la méthode `watchProductsByCategory()` qui retourne un Stream.

```dart
@override
Stream<List<Product>> watchProductsByCategory(String category) {
  final collectionName = _getCollectionName(category);
  
  return _firestore
      .collection(collectionName)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      // ... valeurs par défaut
      return Product.fromJson(data);
    }).toList();
  });
}
```

---

## 🔧 Étape 2 : Modifier le Provider

### Option A : Stream pour UNE Catégorie

Si vous voulez écouter uniquement les pizzas en temps réel :

```dart
// lib/src/providers/product_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/firestore_product_service.dart';

// Provider pour écouter les pizzas en temps réel
final pizzasStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final firestoreService = createFirestoreProductService();
  return firestoreService.watchProductsByCategory('Pizza');
});

// Provider pour écouter les boissons en temps réel
final drinksStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final firestoreService = createFirestoreProductService();
  return firestoreService.watchProductsByCategory('Boissons');
});

// ... etc pour chaque catégorie
```

**Usage dans un Widget :**

```dart
class MenuScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pizzasAsync = ref.watch(pizzasStreamProvider);
    
    return pizzasAsync.when(
      data: (pizzas) => ListView.builder(
        itemCount: pizzas.length,
        itemBuilder: (context, index) {
          return ProductCard(product: pizzas[index]);
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Erreur: $error'),
    );
  }
}
```

### Option B : Stream pour TOUTES les Catégories (Recommandé)

Pour écouter toutes les catégories simultanément :

```dart
// lib/src/providers/product_provider.dart

// Provider qui combine tous les streams
final allProductsStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) async* {
  final firestoreService = createFirestoreProductService();
  
  // Écouter les 4 catégories en parallèle
  await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
    final pizzas = await firestoreService.loadPizzas();
    final menus = await firestoreService.loadMenus();
    final drinks = await firestoreService.loadDrinks();
    final desserts = await firestoreService.loadDesserts();
    
    // Fusionner les données
    final allProducts = <String, Product>{};
    
    // Mock data (base)
    for (var product in mockProducts) {
      allProducts[product.id] = product;
    }
    
    // Ajouter les produits Firestore
    for (var product in [...pizzas, ...menus, ...drinks, ...desserts]) {
      allProducts[product.id] = product;
    }
    
    // Retourner la liste fusionnée
    yield allProducts.values.toList();
  }
});
```

### Option C : Stream avec Combiner (Le Plus Élégant)

Utiliser `StreamProvider.family` avec combineLatest :

```dart
// lib/src/providers/product_provider.dart
import 'package:rxdart/rxdart.dart'; // Ajouter rxdart: ^0.27.7 dans pubspec.yaml

final allProductsStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final firestoreService = createFirestoreProductService();
  
  // Combiner les 4 streams en un seul
  return Rx.combineLatest4(
    firestoreService.watchProductsByCategory('Pizza'),
    firestoreService.watchProductsByCategory('Menus'),
    firestoreService.watchProductsByCategory('Boissons'),
    firestoreService.watchProductsByCategory('Desserts'),
    (List<Product> pizzas, List<Product> menus, List<Product> drinks, List<Product> desserts) {
      // Fusionner avec mock data
      final allProducts = <String, Product>{};
      
      for (var product in mockProducts) {
        allProducts[product.id] = product;
      }
      
      for (var product in [...pizzas, ...menus, ...drinks, ...desserts]) {
        allProducts[product.id] = product;
      }
      
      return allProducts.values.toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    },
  );
});
```

---

## 🎨 Étape 3 : Adapter les Widgets

Les widgets n'ont pas besoin de changement majeur. Remplacez juste le provider :

### Avant (FutureProvider)
```dart
final productsAsync = ref.watch(productListProvider);
```

### Après (StreamProvider)
```dart
final productsAsync = ref.watch(allProductsStreamProvider);
```

Le reste du code (`when()`, `data`, `loading`, `error`) reste identique !

---

## 📊 Étape 4 : Gérer les États de Transition

Avec les streams, vous pouvez afficher des indicateurs de mise à jour :

```dart
return productsAsync.when(
  data: (products) {
    // Afficher un badge "En direct" si le stream est actif
    return Stack(
      children: [
        ProductGrid(products: products),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: Colors.white),
                SizedBox(width: 4),
                Text('En direct', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error: error),
);
```

---

## 🔔 Étape 5 : Optimisation et Performance

### A. Limiter le Nombre d'Écoutes

N'écoutez que les catégories affichées à l'écran :

```dart
// Sur la page Pizza, écouter uniquement les pizzas
final pizzasAsync = ref.watch(pizzasStreamProvider);

// Sur la page Menu, écouter tout
final allProductsAsync = ref.watch(allProductsStreamProvider);
```

### B. Utiliser `autoDispose`

Toujours utiliser `.autoDispose` pour fermer les streams quand le widget est détruit :

```dart
final pizzasStreamProvider = StreamProvider.autoDispose<List<Product>>(...);
```

### C. Debounce pour Réduire les Updates

Si les données changent trop souvent, utilisez `debounce` :

```dart
return firestoreService
    .watchProductsByCategory('Pizza')
    .debounceTime(Duration(milliseconds: 500)); // Attendre 500ms entre chaque update
```

---

## 🧪 Test de Synchronisation Temps Réel

### Test 1 : Modification dans la Console Firebase

1. Ouvrez l'app sur mobile/web
2. Ouvrez la console Firebase
3. Modifiez le nom d'une pizza dans Firestore
4. **Résultat attendu** : Le nom se met à jour instantanément dans l'app (sans recharger)

### Test 2 : Ajout d'un Nouveau Produit

1. Ouvrez l'app
2. Ouvrez la console Firebase
3. Ajoutez une nouvelle pizza
4. **Résultat attendu** : La pizza apparaît automatiquement dans la liste

### Test 3 : Suppression d'un Produit

1. Ouvrez l'app
2. Ouvrez la console Firebase
3. Supprimez une pizza
4. **Résultat attendu** : La pizza disparaît de la liste instantanément

---

## 📈 Avantages du Temps Réel

### Pour l'Utilisateur
- ✅ Toujours à jour (pas besoin de recharger)
- ✅ Voir les nouveaux produits immédiatement
- ✅ Changements de prix en direct
- ✅ Expérience fluide et moderne

### Pour l'Admin
- ✅ Les modifications apparaissent instantanément
- ✅ Pas besoin de demander aux clients de recharger
- ✅ Feedback immédiat
- ✅ Plusieurs admins peuvent travailler en même temps

### Pour le Développeur
- ✅ Code simple et élégant
- ✅ Moins de bugs (pas de cache obsolète)
- ✅ Architecture scalable
- ✅ Debugging facilité

---

## ⚠️ Points d'Attention

### Coûts Firestore

Les streams créent des écoutes permanentes. Surveillez vos quotas Firestore :

- **Gratuit** : 50,000 lectures/jour
- **Au-delà** : 0,06€ / 100,000 lectures

**Recommandation** : Utilisez `autoDispose` et limitez les écoutes aux pages actives.

### Gestion Hors Ligne

Firestore garde un cache local. Si l'utilisateur est hors ligne :

```dart
return productsAsync.when(
  data: (products) {
    // Afficher un indicateur "Hors ligne" si nécessaire
    return Column(
      children: [
        if (isOffline) OfflineBanner(),
        ProductGrid(products: products),
      ],
    );
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) {
    // Gérer les erreurs réseau
    if (error.toString().contains('network')) {
      return Text('Pas de connexion. Affichage du cache local.');
    }
    return Text('Erreur: $error');
  },
);
```

### Performance

Sur de grosses collections (>1000 produits), utilisez :

1. **Pagination** : Charger par batches
2. **Filtres Firestore** : Filtrer côté serveur
3. **Index** : Créer des index Firestore pour les requêtes complexes

---

## 🎯 Exemple Complet

Voici un exemple complet d'un écran avec synchronisation temps réel :

```dart
// lib/src/screens/menu/realtime_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';

// Provider stream
final pizzasStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final firestoreService = createFirestoreProductService();
  return firestoreService.watchProductsByCategory('Pizza');
});

class RealtimeMenuScreen extends ConsumerWidget {
  const RealtimeMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pizzasAsync = ref.watch(pizzasStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pizzas (Temps Réel)'),
        actions: [
          // Indicateur de connexion
          pizzasAsync.when(
            data: (_) => Icon(Icons.cloud_done, color: Colors.green),
            loading: () => Icon(Icons.cloud_sync, color: Colors.orange),
            error: (_, __) => Icon(Icons.cloud_off, color: Colors.red),
          ),
        ],
      ),
      body: pizzasAsync.when(
        data: (pizzas) {
          if (pizzas.isEmpty) {
            return Center(
              child: Text('Aucune pizza disponible'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Force un refresh (optionnel avec streams)
              ref.refresh(pizzasStreamProvider);
            },
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: pizzas.length,
              itemBuilder: (context, index) {
                return ProductCard(product: pizzas[index]);
              },
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connexion à Firestore...'),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Erreur: $error'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(pizzasStreamProvider);
                },
                child: Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## ✅ Checklist d'Activation

- [ ] Firestore configuré et actif
- [ ] `rxdart` ajouté dans `pubspec.yaml` (si Option C)
- [ ] StreamProvider créé pour chaque catégorie
- [ ] Widgets adaptés pour utiliser les StreamProviders
- [ ] `autoDispose` utilisé sur tous les providers
- [ ] Tests effectués (ajout, modification, suppression)
- [ ] Gestion des erreurs réseau implémentée
- [ ] Indicateurs de connexion affichés

---

## 🎉 Résultat

Avec ces modifications, votre application Pizza Deli'Zza bénéficie d'une synchronisation en temps réel professionnelle !

Les changements dans Firestore apparaissent instantanément sans aucune action de l'utilisateur.

---

**💡 Note :** Si vous préférez garder le système actuel (FutureProvider), il fonctionne parfaitement ! Le temps réel est une amélioration optionnelle pour les applications nécessitant des mises à jour fréquentes.

*Dernière mise à jour : 11 novembre 2025*
