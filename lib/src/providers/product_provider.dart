// lib/src/providers/product_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../models/product.dart';
import '../repositories/product_repository.dart'; 

// 1. FutureProvider pour obtenir la liste complète des produits
// Utilisez .autoDispose pour que le provider se rafraîchisse automatiquement
final productListProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  developer.log('🔄 ProductProvider: Chargement des produits...');
  // Le provider demande les données au Repository
  final repository = ref.watch(productRepositoryProvider);
  final products = await repository.fetchAllProducts();
  developer.log('✅ ProductProvider: ${products.length} produits chargés');
  return products;
});


// 2. Provider pour obtenir un produit par son ID
final productByIdProvider =
    FutureProvider.autoDispose.family<Product?, String>((ref, id) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(id);
});


// 3. Provider pour regrouper les produits par catégorie
final productsByCategoryProvider = FutureProvider.autoDispose<Map<String, List<Product>>>((ref) async {
  // Attend que la liste complète des produits soit chargée
  final productsAsync = ref.watch(productListProvider);

  // CORRECTION CLÉ: Utiliser whenOrNull pour ne pas bloquer l'état en cas de chargement.
  // Si les données sont en cours de chargement (null), on lance une exception 
  // pour que le FutureProvider passe à l'état loading (ou on renvoie une Map vide pour la sécurité).
  
  final products = productsAsync.value;

  // Si le chargement est en cours (products == null), le FutureProvider est déjà dans un état
  // de chargement. Si l'erreur se produit ici, on retourne une Map vide.
  if (products == null) {
      // Si productsAsync est en état 'loading', Riverpod gère déjà cet état.
      // Si on arrive ici, cela signifie que la donnée n'est pas encore disponible
      // ou qu'il y a eu une erreur. On retourne une Map vide pour l'interface.
      return {}; 
  }

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
});

// 4. OPTIMIZATION: Provider pour filtrer les produits par catégorie et critères
// Ce provider ne recalcule les produits filtrés que lorsque les dépendances changent
final filteredProductsProvider = Provider.family.autoDispose<List<Product>, FilterCriteria>((ref, criteria) {
  final productsAsync = ref.watch(productListProvider);
  
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