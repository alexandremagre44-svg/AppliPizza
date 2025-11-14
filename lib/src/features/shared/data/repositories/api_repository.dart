// lib/src/features/shared/data/repositories/api_repository.dart
// Service API - préparé pour future intégration backend

import 'package:pizza_delizza/src/features/product/data/models/product.dart';

class ApiRepository {
  static final ApiRepository _instance = ApiRepository._internal();
  factory ApiRepository() => _instance;
  ApiRepository._internal();

  // Base URL (à configurer plus tard)
  static const String baseUrl = 'https://api.pizzadelizza.com';

  /// Récupérer la liste des pizzas
  Future<List<Product>> getPizzas() async {
    // TODO: Implémenter l'appel API
    throw UnimplementedError('API not yet connected');
  }

  /// Récupérer la liste des menus
  Future<List<Product>> getMenus() async {
    // TODO: Implémenter l'appel API
    throw UnimplementedError('API not yet connected');
  }

  /// Créer un nouveau produit
  Future<Product> createProduct(Product product) async {
    // TODO: Implémenter l'appel API
    throw UnimplementedError('API not yet connected');
  }

  /// Mettre à jour un produit
  Future<Product> updateProduct(Product product) async {
    // TODO: Implémenter l'appel API
    throw UnimplementedError('API not yet connected');
  }

  /// Supprimer un produit
  Future<void> deleteProduct(String productId) async {
    // TODO: Implémenter l'appel API
    throw UnimplementedError('API not yet connected');
  }

  /// Passer une commande
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    // TODO: Implémenter l'appel API
    throw UnimplementedError('API not yet connected');
  }
}
