// lib/src/repositories/product_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../models/product.dart';
import '../data/mock_data.dart';
import '../services/product_crud_service.dart';
import '../services/firestore_product_service.dart';

// Définition de l'interface (contrat) pour le Repository
abstract class ProductRepository {
  Future<List<Product>> fetchAllProducts();
  Future<Product?> getProductById(String id);
}

// Implémentation concrète (fusionne les données mockées, admin et Firestore)
class MockProductRepository implements ProductRepository {
  final ProductCrudService _crudService = ProductCrudService();
  final FirestoreProductService _firestoreService = createFirestoreProductService();

  // Simule un délai réseau pour les appels asynchrones
  Future<T> _simulateDelay<T>(T result) {
    return Future.delayed(const Duration(milliseconds: 500), () => result);
  }

  @override
  Future<List<Product>> fetchAllProducts() async {
    developer.log('📦 Repository: Début du chargement des produits...');
    
    // ===============================================
    // ÉTAPE 1: Charger depuis SharedPreferences (Admin local)
    // ===============================================
    final adminPizzas = await _crudService.loadPizzas();
    final adminMenus = await _crudService.loadMenus();
    final adminDrinks = await _crudService.loadDrinks();
    final adminDesserts = await _crudService.loadDesserts();
    
    developer.log('📱 Repository: ${adminPizzas.length} pizzas depuis SharedPreferences');
    developer.log('📱 Repository: ${adminMenus.length} menus depuis SharedPreferences');
    developer.log('📱 Repository: ${adminDrinks.length} boissons depuis SharedPreferences');
    developer.log('📱 Repository: ${adminDesserts.length} desserts depuis SharedPreferences');
    
    // ===============================================
    // ÉTAPE 2: Charger depuis Firestore (toutes catégories)
    // ===============================================
    final firestorePizzas = await _firestoreService.loadPizzas();
    final firestoreMenus = await _firestoreService.loadMenus();
    final firestoreDrinks = await _firestoreService.loadDrinks();
    final firestoreDesserts = await _firestoreService.loadDesserts();
    
    developer.log('🔥 Repository: ${firestorePizzas.length} pizzas depuis Firestore');
    developer.log('🔥 Repository: ${firestoreMenus.length} menus depuis Firestore');
    developer.log('🔥 Repository: ${firestoreDrinks.length} boissons depuis Firestore');
    developer.log('🔥 Repository: ${firestoreDesserts.length} desserts depuis Firestore');
    
    // ===============================================
    // ÉTAPE 3: Fusionner avec ordre de priorité
    // Ordre: Mock Data → SharedPreferences → Firestore
    // ===============================================
    final allProducts = <String, Product>{};
    
    // D'abord les mock data (base)
    for (var product in mockProducts) {
      allProducts[product.id] = product;
    }
    developer.log('💾 Repository: ${mockProducts.length} produits depuis mock_data');
    
    // Puis on ajoute/écrase avec les produits admin (SharedPreferences)
    for (var pizza in adminPizzas) {
      allProducts[pizza.id] = pizza;
      developer.log('  ➕ Ajout pizza admin: ${pizza.name} (ID: ${pizza.id})');
    }
    
    for (var menu in adminMenus) {
      allProducts[menu.id] = menu;
      developer.log('  ➕ Ajout menu admin: ${menu.name} (ID: ${menu.id})');
    }
    
    for (var drink in adminDrinks) {
      allProducts[drink.id] = drink;
      developer.log('  ➕ Ajout boisson admin: ${drink.name} (ID: ${drink.id})');
    }
    
    for (var dessert in adminDesserts) {
      allProducts[dessert.id] = dessert;
      developer.log('  ➕ Ajout dessert admin: ${dessert.name} (ID: ${dessert.id})');
    }
    
    // Enfin, on ajoute/écrase avec les produits Firestore (priorité maximale)
    for (var pizza in firestorePizzas) {
      final wasPresent = allProducts.containsKey(pizza.id);
      allProducts[pizza.id] = pizza;
      developer.log('  ⭐ ${wasPresent ? "Écrasement" : "Ajout"} pizza Firestore: ${pizza.name} (ID: ${pizza.id})');
    }
    
    for (var menu in firestoreMenus) {
      final wasPresent = allProducts.containsKey(menu.id);
      allProducts[menu.id] = menu;
      developer.log('  ⭐ ${wasPresent ? "Écrasement" : "Ajout"} menu Firestore: ${menu.name} (ID: ${menu.id})');
    }
    
    for (var drink in firestoreDrinks) {
      final wasPresent = allProducts.containsKey(drink.id);
      allProducts[drink.id] = drink;
      developer.log('  ⭐ ${wasPresent ? "Écrasement" : "Ajout"} boisson Firestore: ${drink.name} (ID: ${drink.id})');
    }
    
    for (var dessert in firestoreDesserts) {
      final wasPresent = allProducts.containsKey(dessert.id);
      allProducts[dessert.id] = dessert;
      developer.log('  ⭐ ${wasPresent ? "Écrasement" : "Ajout"} dessert Firestore: ${dessert.name} (ID: ${dessert.id})');
    }
    
    developer.log('✅ Repository: Total de ${allProducts.length} produits fusionnés');
    developer.log('📊 Repository: Catégories présentes: ${allProducts.values.map((p) => p.category.value).toSet().join(", ")}');
    
    // Trier les produits par ordre (priorité)
    final sortedProducts = allProducts.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    
    developer.log('🔢 Repository: Produits triés par ordre (priorité)');
    
    return _simulateDelay(sortedProducts);
  }

  @override
  Future<Product?> getProductById(String id) async {
    final allProducts = await fetchAllProducts();
    try {
      return allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Le provider pour fournir l'instance du Repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return MockProductRepository();
});