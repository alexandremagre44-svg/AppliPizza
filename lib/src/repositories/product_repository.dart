// lib/src/repositories/product_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../data/mock_data.dart';
import '../services/product_crud_service.dart';

// Définition de l'interface (contrat) pour le Repository
abstract class ProductRepository {
  Future<List<Product>> fetchAllProducts();
  Future<Product?> getProductById(String id);
}

// Implémentation concrète (fusionne les données mockées et admin)
class MockProductRepository implements ProductRepository {
  final ProductCrudService _crudService = ProductCrudService();

  // Simule un délai réseau pour les appels asynchrones
  Future<T> _simulateDelay<T>(T result) {
    return Future.delayed(const Duration(milliseconds: 500), () => result);
  }

  @override
  Future<List<Product>> fetchAllProducts() async {
    // Charger les produits admin depuis SharedPreferences
    final adminPizzas = await _crudService.loadPizzas();
    final adminMenus = await _crudService.loadMenus();
    
    // Fusionner avec les données mockées
    // On évite les doublons en utilisant les IDs
    final allProducts = <String, Product>{};
    
    // D'abord les mock data (base)
    for (var product in mockProducts) {
      allProducts[product.id] = product;
    }
    
    // Puis on ajoute/écrase avec les produits admin
    for (var pizza in adminPizzas) {
      allProducts[pizza.id] = pizza;
    }
    
    for (var menu in adminMenus) {
      allProducts[menu.id] = menu;
    }
    
    return _simulateDelay(allProducts.values.toList());
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