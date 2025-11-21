// lib/src/screens/home/home_content_helper.dart
// Helper functions for rendering home content based on Studio configurations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../studio/content/models/content_section_model.dart';
import '../../studio/content/models/featured_products_model.dart';
import '../../studio/content/models/category_override_model.dart';
import '../../studio/content/providers/content_providers.dart';
import '../../widgets/product_card.dart';
import '../../widgets/home/section_header.dart';
import '../../theme/app_theme.dart';
import '../../core/constants.dart';

/// Helper class for rendering home content based on Studio configurations
class HomeContentHelper {
  /// Get visible categories in display order
  static List<ProductCategory> getVisibleCategories(List<CategoryOverride>? overrides) {
    if (overrides == null || overrides.isEmpty) {
      // Return all categories in default order
      return ProductCategory.values;
    }

    // Sort by order and filter visible
    final sortedOverrides = overrides
        .where((o) => o.isVisibleOnHome)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return sortedOverrides
        .map((o) => ProductCategory.fromString(o.categoryId))
        .toList();
  }

  /// Build featured products section
  static List<Widget> buildFeaturedSection({
    required BuildContext context,
    required WidgetRef ref,
    required FeaturedProductsConfig? config,
    required List<Product> allProducts,
    required void Function(Product) onProductTap,
  }) {
    if (config == null || !config.isActive) {
      return [];
    }

    List<Product> featured = [];

    // Get products based on config
    if (config.productIds.isNotEmpty) {
      // Use manually selected products
      for (final id in config.productIds) {
        final product = allProducts.firstWhere(
          (p) => p.id == id && p.isActive,
          orElse: () => allProducts.first, // Won't be used due to isEmpty check
        );
        if (product.id == id) {
          featured.add(product);
        }
      }
    } else if (config.autoFill) {
      // Auto-fill with featured products
      featured = allProducts.where((p) => p.isFeatured && p.isActive).take(4).toList();
    }

    if (featured.isEmpty) {
      return [];
    }

    final widgets = <Widget>[];

    widgets.add(SectionHeader(
      title: config.title ?? '⭐ Produits mis en avant',
    ));
    widgets.add(SizedBox(height: AppSpacing.lg));

    switch (config.displayType) {
      case FeaturedDisplayType.carousel:
        widgets.add(_buildCarousel(context, ref, featured, onProductTap));
        break;
      case FeaturedDisplayType.hero:
        widgets.add(_buildHeroDisplay(context, ref, featured, onProductTap));
        break;
      case FeaturedDisplayType.horizontalCards:
        widgets.add(_buildHorizontalCards(context, ref, featured, onProductTap));
        break;
    }

    widgets.add(SizedBox(height: AppSpacing.xxxl));

    return widgets;
  }

  /// Build custom section
  static List<Widget> buildCustomSection({
    required BuildContext context,
    required WidgetRef ref,
    required ContentSection section,
    required List<Product> allProducts,
    required void Function(Product) onProductTap,
  }) {
    if (!section.isActive) {
      return [];
    }

    List<Product> products = [];

    if (section.contentMode == SectionContentMode.manual) {
      // Manual mode: use selected products
      for (final id in section.productIds) {
        final product = allProducts.firstWhere(
          (p) => p.id == id && p.isActive,
          orElse: () => allProducts.first,
        );
        if (product.id == id) {
          products.add(product);
        }
      }
    } else {
      // Auto mode: sort based on autoSortType
      products = _sortProductsAuto(allProducts, section.autoSortType);
    }

    if (products.isEmpty) {
      return [];
    }

    final widgets = <Widget>[];

    // Section header
    widgets.add(SectionHeader(
      title: section.title,
      subtitle: section.subtitle,
    ));
    widgets.add(SizedBox(height: AppSpacing.lg));

    // Section content based on display type
    switch (section.displayType) {
      case SectionDisplayType.carousel:
        widgets.add(_buildCarousel(context, ref, products, onProductTap));
        break;
      case SectionDisplayType.grid:
        widgets.add(_buildProductGrid(context, ref, products, onProductTap));
        break;
      case SectionDisplayType.largeBanner:
        widgets.add(_buildLargeBanner(context, ref, products.first, onProductTap));
        break;
    }

    widgets.add(SizedBox(height: AppSpacing.xxxl));

    return widgets;
  }

  /// Sort products automatically
  static List<Product> _sortProductsAuto(
    List<Product> products,
    SectionAutoSortType? sortType,
  ) {
    final activeProducts = products.where((p) => p.isActive).toList();

    switch (sortType) {
      case SectionAutoSortType.bestSeller:
        return activeProducts.where((p) => p.isBestSeller).take(6).toList();
      case SectionAutoSortType.price:
        return (activeProducts..sort((a, b) => a.price.compareTo(b.price))).take(6).toList();
      case SectionAutoSortType.newest:
        return activeProducts.where((p) => p.isNew).take(6).toList();
      case SectionAutoSortType.promo:
        return activeProducts.where((p) => p.displaySpot == DisplaySpot.promotions).take(6).toList();
      default:
        return activeProducts.take(6).toList();
    }
  }

  /// Build carousel display
  static Widget _buildCarousel(BuildContext context, WidgetRef ref, List<Product> products, void Function(Product) onProductTap) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: AppSpacing.md),
            child: ProductCard(
              product: product,
              onAddToCart: () => onProductTap(product),
            ),
          );
        },
      ),
    );
  }

  /// Build product grid
  static Widget _buildProductGrid(BuildContext context, WidgetRef ref, List<Product> products, void Function(Product) onProductTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onAddToCart: () => onProductTap(product),
          );
        },
      ),
    );
  }

  /// Build hero display (large featured product)
  static Widget _buildHeroDisplay(BuildContext context, WidgetRef ref, List<Product> products, void Function(Product) onProductTap) {
    final product = products.first;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: () => onProductTap(product),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: product.imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            color: product.imageUrl.isEmpty ? Colors.grey.shade300 : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${product.price.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build horizontal cards
  static Widget _buildHorizontalCards(BuildContext context, WidgetRef ref, List<Product> products, void Function(Product) onProductTap) {
    return Column(
      children: products.map((product) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              onTap: () => onProductTap(product),
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: product.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: product.imageUrl.isEmpty ? Colors.grey.shade300 : null,
                ),
              ),
              title: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(product.description),
              trailing: Text(
                '${product.price.toStringAsFixed(2)} €',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build large banner (single product showcase)
  static Widget _buildLargeBanner(BuildContext context, WidgetRef ref, Product product, void Function(Product) onProductTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: () => onProductTap(product),
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: product.imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            color: product.imageUrl.isEmpty ? Colors.grey.shade300 : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Add to cart
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Commander'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
