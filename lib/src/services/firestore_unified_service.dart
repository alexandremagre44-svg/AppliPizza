// lib/src/services/firestore_unified_service.dart
// Service unifié pour gérer TOUTES les opérations Firestore (produits + admin)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/product.dart';

/// Service unifié qui gère les opérations Firestore pour tous les produits
/// Ce service est utilisé par les écrans admin pour écrire directement dans Firestore
class FirestoreUnifiedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Singleton
  static final FirestoreUnifiedService _instance = FirestoreUnifiedService._internal();
  factory FirestoreUnifiedService() => _instance;
  FirestoreUnifiedService._internal();

  // ===============================================
  // FONCTION CENTRALISÉE: Mapper le nom de collection
  // ===============================================
  String _getCollectionName(ProductCategory category) {
    switch (category) {
      case ProductCategory.pizza:
        return 'pizzas';
      case ProductCategory.menus:
        return 'menus';
      case ProductCategory.boissons:
        return 'drinks';
      case ProductCategory.desserts:
        return 'desserts';
    }
  }

  // ===============================================
  // CRUD GÉNÉRIQUE POUR TOUS LES PRODUITS
  // ===============================================

  /// Créer ou mettre à jour un produit dans Firestore
  Future<bool> saveProduct(Product product) async {
    try {
      final collectionName = _getCollectionName(product.category);
      final data = product.toJson();
      
      await _firestore
          .collection(collectionName)
          .doc(product.id)
          .set(data, SetOptions(merge: true));
      
      developer.log('✅ Produit "${product.name}" sauvegardé dans Firestore ($collectionName)');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors de la sauvegarde du produit "${product.name}": $e');
      return false;
    }
  }

  /// Supprimer un produit de Firestore
  Future<bool> deleteProduct(String productId, ProductCategory category) async {
    try {
      final collectionName = _getCollectionName(category);
      
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

  /// Charger tous les produits d'une catégorie
  Future<List<Product>> loadProductsByCategory(ProductCategory category) async {
    try {
      final collectionName = _getCollectionName(category);
      developer.log('🔥 Chargement de ${category.value} depuis Firestore ($collectionName)...');
      
      final snapshot = await _firestore
          .collection(collectionName)
          .get();
      
      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Assurer les valeurs par défaut
        data['baseIngredients'] = data['baseIngredients'] ?? [];
        data['isActive'] = data['isActive'] ?? true;
        data['isMenu'] = data['isMenu'] ?? (category == ProductCategory.menus);
        data['isFeatured'] = data['isFeatured'] ?? false;
        data['displaySpot'] = data['displaySpot'] ?? 'all';
        data['order'] = data['order'] ?? 0;
        data['pizzaCount'] = data['pizzaCount'] ?? 1;
        data['drinkCount'] = data['drinkCount'] ?? 0;
        data['category'] = data['category'] ?? category.value;
        
        return Product.fromJson(data);
      }).toList();
      
      developer.log('📦 ${products.length} produits "${category.value}" trouvés dans Firestore');
      return products;
    } catch (e) {
      developer.log('❌ Erreur lors du chargement de ${category.value} depuis Firestore: $e');
      return [];
    }
  }

  /// Stream en temps réel pour une catégorie
  Stream<List<Product>> watchProductsByCategory(ProductCategory category) {
    final collectionName = _getCollectionName(category);
    developer.log('🔄 Écoute en temps réel de ${category.value} ($collectionName)...');
    
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
        data['isMenu'] = data['isMenu'] ?? (category == ProductCategory.menus);
        data['isFeatured'] = data['isFeatured'] ?? false;
        data['displaySpot'] = data['displaySpot'] ?? 'all';
        data['order'] = data['order'] ?? 0;
        data['pizzaCount'] = data['pizzaCount'] ?? 1;
        data['drinkCount'] = data['drinkCount'] ?? 0;
        data['category'] = data['category'] ?? category.value;
        
        return Product.fromJson(data);
      }).toList();
    }).handleError((error) {
      developer.log('❌ Erreur stream Firestore pour ${category.value}: $error');
      return <Product>[];
    });
  }

  /// Charger un produit par ID
  Future<Product?> getProductById(String productId, ProductCategory category) async {
    try {
      final collectionName = _getCollectionName(category);
      final doc = await _firestore
          .collection(collectionName)
          .doc(productId)
          .get();
      
      if (!doc.exists) {
        developer.log('⚠️ Produit "$productId" non trouvé dans Firestore');
        return null;
      }
      
      final data = doc.data()!;
      data['id'] = doc.id;
      
      // Assurer valeurs par défaut
      data['baseIngredients'] = data['baseIngredients'] ?? [];
      data['isActive'] = data['isActive'] ?? true;
      data['isMenu'] = data['isMenu'] ?? (category == ProductCategory.menus);
      data['isFeatured'] = data['isFeatured'] ?? false;
      data['displaySpot'] = data['displaySpot'] ?? 'all';
      data['order'] = data['order'] ?? 0;
      data['pizzaCount'] = data['pizzaCount'] ?? 1;
      data['drinkCount'] = data['drinkCount'] ?? 0;
      data['category'] = data['category'] ?? category.value;
      
      return Product.fromJson(data);
    } catch (e) {
      developer.log('❌ Erreur lors de la récupération du produit "$productId": $e');
      return null;
    }
  }

  // ===============================================
  // MÉTHODES SPÉCIFIQUES PAR CATÉGORIE (pour compatibilité)
  // ===============================================

  Future<List<Product>> loadPizzas() => loadProductsByCategory(ProductCategory.pizza);
  Future<List<Product>> loadMenus() => loadProductsByCategory(ProductCategory.menus);
  Future<List<Product>> loadDrinks() => loadProductsByCategory(ProductCategory.boissons);
  Future<List<Product>> loadDesserts() => loadProductsByCategory(ProductCategory.desserts);

  Stream<List<Product>> watchPizzas() => watchProductsByCategory(ProductCategory.pizza);
  Stream<List<Product>> watchMenus() => watchProductsByCategory(ProductCategory.menus);
  Stream<List<Product>> watchDrinks() => watchProductsByCategory(ProductCategory.boissons);
  Stream<List<Product>> watchDesserts() => watchProductsByCategory(ProductCategory.desserts);

  Future<bool> savePizza(Product pizza) => saveProduct(pizza);
  Future<bool> saveMenu(Product menu) => saveProduct(menu);
  Future<bool> saveDrink(Product drink) => saveProduct(drink);
  Future<bool> saveDessert(Product dessert) => saveProduct(dessert);

  Future<bool> deletePizza(String pizzaId) => deleteProduct(pizzaId, ProductCategory.pizza);
  Future<bool> deleteMenu(String menuId) => deleteProduct(menuId, ProductCategory.menus);
  Future<bool> deleteDrink(String drinkId) => deleteProduct(drinkId, ProductCategory.boissons);
  Future<bool> deleteDessert(String dessertId) => deleteProduct(dessertId, ProductCategory.desserts);
}
