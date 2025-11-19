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
// Renamed from MockProductRepository to better reflect its combined data source functionality
class CombinedProductRepository implements ProductRepository {
  final ProductCrudService _crudService = ProductCrudService();
  final FirestoreProductService _firestoreService = createFirestoreProductService();

  // Simule un délai réseau pour les appels asynchrones
  Future<T> _simulateDelay<T>(T result) {
    return Future.delayed(const Duration(milliseconds: 500), () => result);
  }

  @override
  Future<List<Product>> fetchAllProducts() async {
    developer.log('📦 Repository: Début du chargement des produits (OPTIMIZED)...');
    
    // ===============================================
    // OPTIMIZATION: Load from all sources in parallel
    // ===============================================
    final results = await Future.wait([
      // SharedPreferences (Admin local) - load all categories in parallel
      _crudService.loadPizzas(),
      _crudService.loadMenus(),
      _crudService.loadDrinks(),
      _crudService.loadDesserts(),
      // Firestore - use optimized single call
      _firestoreService.loadAllProducts(),
    ]);
    
    final adminPizzas = results[0];
    final adminMenus = results[1];
    final adminDrinks = results[2];
    final adminDesserts = results[3];
    final firestoreProducts = results[4];
    
    developer.log('📱 Repository: ${adminPizzas.length} pizzas depuis SharedPreferences');
    developer.log('📱 Repository: ${adminMenus.length} menus depuis SharedPreferences');
    developer.log('📱 Repository: ${adminDrinks.length} boissons depuis SharedPreferences');
    developer.log('📱 Repository: ${adminDesserts.length} desserts depuis SharedPreferences');
    developer.log('🔥 Repository: ${firestoreProducts.length} produits depuis Firestore (bulk load)');
    
    // ===============================================
    // ÉTAPE 2: Fusionner avec ordre de priorité (OPTIMIZED)
    // Ordre: Mock Data → SharedPreferences → Firestore
    // ===============================================
    final allProducts = <String, Product>{};
    
    // D'abord les mock data (base)
    for (var product in mockProducts) {
      allProducts[product.id] = product;
    }
    developer.log('💾 Repository: ${mockProducts.length} produits depuis mock_data');
    
    // Puis on ajoute/écrase avec les produits admin (SharedPreferences)
    final adminProducts = [...adminPizzas, ...adminMenus, ...adminDrinks, ...adminDesserts];
    for (var product in adminProducts) {
      allProducts[product.id] = product;
    }
    developer.log('📱 Repository: ${adminProducts.length} produits admin ajoutés');
    
    // Enfin, on ajoute/écrase avec les produits Firestore (priorité maximale)
    int firestoreOverrides = 0;
    int firestoreNew = 0;
    for (var product in firestoreProducts) {
      if (allProducts.containsKey(product.id)) {
        firestoreOverrides++;
      } else {
        firestoreNew++;
      }
      allProducts[product.id] = product;
    }
    developer.log('🔥 Repository: Firestore - $firestoreNew nouveaux, $firestoreOverrides écrasés');
    
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
    developer.log('🔍 Repository: Recherche du produit ID: $id (OPTIMIZED)');
    
    // OPTIMIZATION: Use fetchAllProducts which has the merge logic
    // This reuses the same loading pattern and benefits from any caching
    final allProducts = await fetchAllProducts();
    
    try {
      final product = allProducts.firstWhere((p) => p.id == id);
      developer.log('  ✅ Produit trouvé: ${product.name}');
      return product;
    } catch (_) {
      developer.log('  ❌ Produit non trouvé');
      return null;
    }
  }
}

// Le provider pour fournir l'instance du Repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return CombinedProductRepository();
});