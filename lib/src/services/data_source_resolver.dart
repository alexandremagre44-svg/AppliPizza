// lib/src/services/data_source_resolver.dart
// Resolves DataSource configurations to actual data from Firestore

import 'dart:developer' as developer;
import '../models/page_schema.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

/// Resolves DataSource configurations to actual data
/// 
/// This service acts as a bridge between PageSchema DataSource configurations
/// and the actual data services (ProductRepository, CategoryService, etc.)
class DataSourceResolver {
  final ProductRepository _productRepository;

  DataSourceResolver({ProductRepository? productRepository})
      : _productRepository = productRepository ?? CombinedProductRepository();

  /// Resolve a DataSource to a list of products
  /// 
  /// Supports filtering by:
  /// - category: Filter products by category
  /// - limit: Limit number of results
  /// - displaySpot: Filter by display spot (home, promotions, new, all)
  Future<List<Product>> resolveProducts(DataSource dataSource) async {
    developer.log('🔍 DataSourceResolver: Resolving data source for products');
    developer.log('   Source type: ${dataSource.type.value}');
    developer.log('   Config: ${dataSource.config}');

    if (dataSource.type != DataSourceType.products) {
      developer.log('⚠️ DataSourceResolver: Invalid source type for products: ${dataSource.type.value}');
      return [];
    }

    try {
      // Fetch all products from repository
      final allProducts = await _productRepository.fetchAllProducts();
      developer.log('✅ DataSourceResolver: Fetched ${allProducts.length} products from ProductRepository');

      // Apply filters from config
      var filteredProducts = allProducts;

      // Filter by category if specified
      final categoryFilter = dataSource.config['category'] as String?;
      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        filteredProducts = filteredProducts.where((product) {
          return product.category.value.toLowerCase() == categoryFilter.toLowerCase();
        }).toList();
        developer.log('   Filtered by category "$categoryFilter": ${filteredProducts.length} products');
      }

      // Filter by displaySpot if specified
      final displaySpotFilter = dataSource.config['displaySpot'] as String?;
      if (displaySpotFilter != null && displaySpotFilter.isNotEmpty) {
        final spot = DisplaySpot.fromString(displaySpotFilter);
        if (spot != DisplaySpot.all) {
          filteredProducts = filteredProducts.where((product) {
            return product.displaySpot == spot;
          }).toList();
          developer.log('   Filtered by displaySpot "$displaySpotFilter": ${filteredProducts.length} products');
        }
      }

      // Apply limit if specified
      final limit = dataSource.config['limit'] as int?;
      if (limit != null && limit > 0 && limit < filteredProducts.length) {
        filteredProducts = filteredProducts.take(limit).toList();
        developer.log('   Limited to $limit products');
      }

      developer.log('🎯 DataSourceResolver: Returning ${filteredProducts.length} products');
      return filteredProducts;
    } catch (e) {
      developer.log('❌ DataSourceResolver: Error fetching products: $e');
      return [];
    }
  }

  /// Resolve a DataSource to a list of categories
  /// 
  /// Returns unique categories from all products
  Future<List<ProductCategory>> resolveCategories(DataSource dataSource) async {
    developer.log('🔍 DataSourceResolver: Resolving data source for categories');
    developer.log('   Source type: ${dataSource.type.value}');

    if (dataSource.type != DataSourceType.categories) {
      developer.log('⚠️ DataSourceResolver: Invalid source type for categories: ${dataSource.type.value}');
      return [];
    }

    try {
      // Fetch all products to extract categories
      final allProducts = await _productRepository.fetchAllProducts();
      developer.log('✅ DataSourceResolver: Fetched ${allProducts.length} products');

      // Extract unique categories
      final categories = allProducts
          .map((product) => product.category)
          .toSet()
          .toList();

      developer.log('🎯 DataSourceResolver: Found ${categories.length} unique categories');
      return categories;
    } catch (e) {
      developer.log('❌ DataSourceResolver: Error fetching categories: $e');
      return [];
    }
  }

  /// Get category display name with product count
  Future<Map<ProductCategory, int>> getCategoryCounts() async {
    try {
      final allProducts = await _productRepository.fetchAllProducts();
      final counts = <ProductCategory, int>{};

      for (var product in allProducts) {
        counts[product.category] = (counts[product.category] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      developer.log('❌ DataSourceResolver: Error getting category counts: $e');
      return {};
    }
  }
}
