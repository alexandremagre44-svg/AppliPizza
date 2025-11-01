// lib/src/repositories/product_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../data/mock_data.dart'; // Importe les données mockées
import '../services/firestore_product_service.dart';

// Définition de l'interface (contrat) pour le Repository
abstract class ProductRepository {
  Future<List<Product>> fetchAllProducts();
  Future<Product?> getProductById(String id);
}

// Implémentation concrète (utilise les données mockées)
class MockProductRepository implements ProductRepository {
  // Simule un délai réseau pour les appels asynchrones
  Future<T> _simulateDelay<T>(T result) {
    return Future.delayed(const Duration(milliseconds: 500), () => result);
  }

  @override
  Future<List<Product>> fetchAllProducts() {
    return _simulateDelay(mockProducts);
  }

  @override
  Future<Product?> getProductById(String id) {
    final product = mockProducts.firstWhere(
      (p) => p.id == id,
      orElse: () => null as Product,
    );
    return _simulateDelay(product);
  }
}

// Implémentation Firestore (utilise Firebase Cloud + cache local)
class FirestoreProductRepository implements ProductRepository {
  final FirestoreProductService _firestoreService = FirestoreProductService();

  @override
  Future<List<Product>> fetchAllProducts() async {
    // Charger les pizzas et menus depuis Firestore
    final pizzas = await _firestoreService.loadPizzas();
    final menus = await _firestoreService.loadMenus();
    
    // Combiner les deux listes
    return [...pizzas, ...menus];
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
// MODIFIÉ: Utilise maintenant FirestoreProductRepository au lieu de MockProductRepository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirestoreProductRepository(); // Migration vers Firestore!
});