// lib/src/repositories/product_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../data/mock_data.dart'; // Importe les données mockées

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

// Le provider pour fournir l'instance du Repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return MockProductRepository();
});