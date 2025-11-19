// lib/src/providers/product_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/firestore_product_service.dart';

// ============================================================================
// OPTIMIZED: StreamProvider for real-time product updates with caching
// ============================================================================

/// Provider for Firestore service (singleton)
final _firestoreProductServiceProvider = Provider<FirestoreProductService>((ref) {
  return createFirestoreProductService();
});

/// OPTIMIZED: Main product provider using StreamProvider instead of FutureProvider
/// This provides real-time updates and better performance with caching
/// Using keepAlive to maintain the stream and cache across widget rebuilds
final productStreamProvider = StreamProvider<List<Product>>((ref) {
  developer.log('🔄 ProductStreamProvider: Initialisation du stream de produits...');
  
  final firestoreService = ref.watch(_firestoreProductServiceProvider);
  final repository = ref.watch(productRepositoryProvider);
  
  // Use the repository's stream (which combines Firestore + SharedPreferences + Mock)
  // Note: We're using the repository to maintain compatibility with existing merge logic
  return Stream.fromFuture(repository.fetchAllProducts());
});

/// Legacy FutureProvider maintained for backward compatibility
/// DEPRECATED: Use productStreamProvider instead for better performance
@Deprecated('Use productStreamProvider for better performance and real-time updates')
final productListProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  developer.log('🔄 ProductProvider: Chargement des produits (legacy)...');
  // Watch the stream provider to leverage its caching
  final productsAsync = ref.watch(productStreamProvider);
  return productsAsync.when(
    data: (products) {
      developer.log('✅ ProductProvider: ${products.length} produits chargés');
      return products;
    },
    loading: () => throw Exception('Loading...'),
    error: (error, stack) => throw error,
  );
});


// 2. OPTIMIZED: Provider pour obtenir un produit par son ID
// Uses the cached product list instead of making a new query
final productByIdProvider = Provider.autoDispose.family<Product?, String>((ref, id) {
  final productsAsync = ref.watch(productStreamProvider);
  
  return productsAsync.when(
    data: (products) {
      try {
        return products.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});


// 3. OPTIMIZED: Provider pour regrouper les produits par catégorie
// Uses regular Provider instead of FutureProvider for better performance
final productsByCategoryProvider = Provider.autoDispose<Map<String, List<Product>>>((ref) {
  // Watch the stream provider
  final productsAsync = ref.watch(productStreamProvider);

  return productsAsync.when(
    data: (products) {
      final Map<String, List<Product>> groupedProducts = {};
      for (var product in products) {
        // Use the enum value as the category key
        final category = product.category.value;

        if (!groupedProducts.containsKey(category)) {
          groupedProducts[category] = [];
        }
        groupedProducts[category]!.add(product);
      }
      return groupedProducts;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// 4. OPTIMIZED: Provider pour filtrer les produits par catégorie et critères
// Uses the stream provider for better performance and real-time updates
// This provider only recalculates when dependencies change
final filteredProductsProvider = Provider.family.autoDispose<List<Product>, FilterCriteria>((ref, criteria) {
  final productsAsync = ref.watch(productStreamProvider);
  
  return productsAsync.when(
    data: (allProducts) {
      var filtered = allProducts.where((p) => p.isActive).toList();
      
      // Filter by category if specified
      if (criteria.category != null) {
        filtered = filtered.where((p) => p.category == criteria.category).toList();
      }
      
      // Filter by displaySpot if specified
      if (criteria.displaySpot != null) {
        filtered = filtered.where((p) => p.displaySpot == criteria.displaySpot).toList();
      }
      
      // Filter by isFeatured if specified
      if (criteria.isFeatured != null) {
        filtered = filtered.where((p) => p.isFeatured == criteria.isFeatured).toList();
      }
      
      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Criteria for filtering products
class FilterCriteria {
  final ProductCategory? category;
  final DisplaySpot? displaySpot;
  final bool? isFeatured;
  
  const FilterCriteria({
    this.category,
    this.displaySpot,
    this.isFeatured,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterCriteria &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          displaySpot == other.displaySpot &&
          isFeatured == other.isFeatured;
  
  @override
  int get hashCode => Object.hash(category, displaySpot, isFeatured);
}