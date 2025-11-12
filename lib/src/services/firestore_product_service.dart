// lib/src/services/firestore_product_service.dart
// Service pour charger et sauvegarder les produits depuis Firestore
// Note: Nécessite les dépendances Firebase dans pubspec.yaml:
//   - cloud_firestore: ^4.13.0
//   - firebase_core: ^2.24.0

import 'dart:developer' as developer;
import '../models/product.dart';

// Interface abstraite pour permettre la compatibilité avec/sans Firebase
abstract class FirestoreProductService {
  // CRUD pour toutes les catégories de produits
  Future<List<Product>> loadPizzas();
  Future<List<Product>> loadMenus();
  Future<List<Product>> loadDrinks();
  Future<List<Product>> loadDesserts();
  
  // OPTIMIZATION: Load all products at once instead of separate calls per category
  Future<List<Product>> loadAllProducts();
  
  // Fonction centralisée pour charger par catégorie
  Future<List<Product>> loadProductsByCategory(String category);
  
  // Stream pour écoute en temps réel
  Stream<List<Product>> watchProductsByCategory(String category);
  
  Future<bool> savePizza(Product pizza);
  Future<bool> saveMenu(Product menu);
  Future<bool> saveDrink(Product drink);
  Future<bool> saveDessert(Product dessert);
  
  Future<bool> deletePizza(String pizzaId);
  Future<bool> deleteMenu(String menuId);
  Future<bool> deleteDrink(String drinkId);
  Future<bool> deleteDessert(String dessertId);
}

// Implémentation mock pour quand Firebase n'est pas disponible
class MockFirestoreProductService implements FirestoreProductService {
  @override
  Future<List<Product>> loadPizzas() async {
    developer.log('MockFirestoreProductService: Firebase non configuré, retourne liste vide');
    return [];
  }

  @override
  Future<List<Product>> loadMenus() async {
    developer.log('MockFirestoreProductService: Firebase non configuré, retourne liste vide');
    return [];
  }

  @override
  Future<List<Product>> loadDrinks() async {
    developer.log('MockFirestoreProductService: Firebase non configuré, retourne liste vide');
    return [];
  }

  @override
  Future<List<Product>> loadDesserts() async {
    developer.log('MockFirestoreProductService: Firebase non configuré, retourne liste vide');
    return [];
  }

  @override
  Future<List<Product>> loadAllProducts() async {
    developer.log('MockFirestoreProductService: Firebase non configuré, retourne liste vide');
    return [];
  }

  @override
  Future<List<Product>> loadProductsByCategory(String category) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, retourne liste vide pour $category');
    return [];
  }

  @override
  Stream<List<Product>> watchProductsByCategory(String category) {
    developer.log('MockFirestoreProductService: Firebase non configuré, retourne stream vide pour $category');
    return Stream.value([]);
  }

  @override
  Future<bool> savePizza(Product pizza) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, sauvegarde ignorée');
    return false;
  }

  @override
  Future<bool> saveMenu(Product menu) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, sauvegarde ignorée');
    return false;
  }

  @override
  Future<bool> saveDrink(Product drink) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, sauvegarde ignorée');
    return false;
  }

  @override
  Future<bool> saveDessert(Product dessert) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, sauvegarde ignorée');
    return false;
  }

  @override
  Future<bool> deletePizza(String pizzaId) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, suppression ignorée');
    return false;
  }

  @override
  Future<bool> deleteMenu(String menuId) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, suppression ignorée');
    return false;
  }

  @override
  Future<bool> deleteDrink(String drinkId) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, suppression ignorée');
    return false;
  }

  @override
  Future<bool> deleteDessert(String dessertId) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, suppression ignorée');
    return false;
  }
}

// Implémentation réelle avec Firestore
// Décommentez et utilisez cette classe si vous avez Firebase configuré
/*
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProductServiceImpl implements FirestoreProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ===============================================
  // FONCTION CENTRALISÉE: Mapper le nom de collection
  // ===============================================
  String _getCollectionName(String category) {
    switch (category.toLowerCase()) {
      case 'pizza':
        return 'pizzas';
      case 'menus':
        return 'menus';
      case 'boissons':
        return 'drinks';
      case 'desserts':
        return 'desserts';
      default:
        return category.toLowerCase();
    }
  }

  // ===============================================
  // FONCTION CENTRALISÉE: Charger par catégorie
  // ===============================================
  @override
  Future<List<Product>> loadProductsByCategory(String category) async {
    try {
      final collectionName = _getCollectionName(category);
      developer.log('🔥 FirestoreProductService: Chargement de $category depuis Firestore ($collectionName)...');
      
      final snapshot = await _firestore
          .collection(collectionName)
          .get();
      
      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        // Assurer que l'ID est présent
        data['id'] = doc.id;
        
        // Assurer que les champs requis ont des valeurs par défaut si manquants
        data['baseIngredients'] = data['baseIngredients'] ?? [];
        data['isActive'] = data['isActive'] ?? true;
        data['isMenu'] = data['isMenu'] ?? false;
        data['isFeatured'] = data['isFeatured'] ?? false;
        data['displaySpot'] = data['displaySpot'] ?? 'all';
        data['order'] = data['order'] ?? 0;
        data['pizzaCount'] = data['pizzaCount'] ?? 1;
        data['drinkCount'] = data['drinkCount'] ?? 0;
        
        return Product.fromJson(data);
      }).toList();
      
      developer.log('📦 Nombre de produits "$category" trouvés dans Firestore: ${products.length}');
      
      return products;
    } catch (e) {
      developer.log('❌ Erreur lors du chargement de $category depuis Firestore: $e');
      return [];
    }
  }

  // ===============================================
  // STREAM EN TEMPS RÉEL: Écouter les changements
  // ===============================================
  @override
  Stream<List<Product>> watchProductsByCategory(String category) {
    final collectionName = _getCollectionName(category);
    developer.log('🔄 FirestoreProductService: Écoute en temps réel de $category ($collectionName)...');
    
    return _firestore
        .collection(collectionName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Assurer valeurs par défaut
        data['baseIngredients'] = data['baseIngredients'] ?? [];
        data['isActive'] = data['isActive'] ?? true;
        data['isMenu'] = data['isMenu'] ?? false;
        data['isFeatured'] = data['isFeatured'] ?? false;
        data['displaySpot'] = data['displaySpot'] ?? 'all';
        data['order'] = data['order'] ?? 0;
        data['pizzaCount'] = data['pizzaCount'] ?? 1;
        data['drinkCount'] = data['drinkCount'] ?? 0;
        
        return Product.fromJson(data);
      }).toList();
    }).handleError((error) {
      developer.log('❌ Erreur stream Firestore pour $category: $error');
      return <Product>[];
    });
  }

  // ===============================================
  // MÉTHODES SPÉCIFIQUES PAR CATÉGORIE
  // ===============================================
  
  @override
  Future<List<Product>> loadPizzas() async {
    return loadProductsByCategory('Pizza');
  }

  @override
  Future<List<Product>> loadMenus() async {
    return loadProductsByCategory('Menus');
  }

  @override
  Future<List<Product>> loadDrinks() async {
    return loadProductsByCategory('Boissons');
  }

  @override
  Future<List<Product>> loadDesserts() async {
    return loadProductsByCategory('Desserts');
  }

  // ===============================================
  // OPTIMIZATION: Load all products at once
  // ===============================================
  @override
  Future<List<Product>> loadAllProducts() async {
    developer.log('🔥 FirestoreProductService: Chargement de TOUS les produits depuis Firestore...');
    
    try {
      // Load all categories in parallel for better performance
      final results = await Future.wait([
        loadProductsByCategory('Pizza'),
        loadProductsByCategory('Menus'),
        loadProductsByCategory('Boissons'),
        loadProductsByCategory('Desserts'),
      ]);
      
      // Flatten the list
      final allProducts = results.expand((list) => list).toList();
      developer.log('📦 Total produits chargés depuis Firestore: ${allProducts.length}');
      
      return allProducts;
    } catch (e) {
      developer.log('❌ Erreur lors du chargement de tous les produits: $e');
      return [];
    }
  }

  // ===============================================
  // SAUVEGARDE: Fonction générique
  // ===============================================
  Future<bool> _saveProduct(Product product, String collectionName) async {
    try {
      // Préparer les données avec valeurs par défaut si nécessaire
      final data = product.toJson();
      
      await _firestore
          .collection(collectionName)
          .doc(product.id)
          .set(data, SetOptions(merge: true)); // merge pour ne pas écraser tout
      
      developer.log('✅ Produit "${product.name}" sauvegardé dans Firestore ($collectionName)');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors de la sauvegarde du produit "${product.name}": $e');
      return false;
    }
  }

  @override
  Future<bool> savePizza(Product pizza) async {
    return _saveProduct(pizza, 'pizzas');
  }

  @override
  Future<bool> saveMenu(Product menu) async {
    return _saveProduct(menu, 'menus');
  }

  @override
  Future<bool> saveDrink(Product drink) async {
    return _saveProduct(drink, 'drinks');
  }

  @override
  Future<bool> saveDessert(Product dessert) async {
    return _saveProduct(dessert, 'desserts');
  }

  // ===============================================
  // SUPPRESSION: Fonction générique
  // ===============================================
  Future<bool> _deleteProduct(String productId, String collectionName) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(productId)
          .delete();
      
      developer.log('✅ Produit "$productId" supprimé de Firestore ($collectionName)');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors de la suppression du produit "$productId": $e');
      return false;
    }
  }

  @override
  Future<bool> deletePizza(String pizzaId) async {
    return _deleteProduct(pizzaId, 'pizzas');
  }

  @override
  Future<bool> deleteMenu(String menuId) async {
    return _deleteProduct(menuId, 'menus');
  }

  @override
  Future<bool> deleteDrink(String drinkId) async {
    return _deleteProduct(drinkId, 'drinks');
  }

  @override
  Future<bool> deleteDessert(String dessertId) async {
    return _deleteProduct(dessertId, 'desserts');
  }
}
*/

// Factory pour créer le bon service selon la configuration
FirestoreProductService createFirestoreProductService() {
  // Si vous avez Firebase configuré, retournez FirestoreProductServiceImpl()
  // return FirestoreProductServiceImpl();
  
  // Sinon, retournez le mock
  return MockFirestoreProductService();
}
