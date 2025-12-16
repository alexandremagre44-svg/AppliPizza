// lib/src/screens/admin/pos/widgets/pos_catalog_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/product.dart';
import '../../../../providers/product_provider.dart';
import '../../../../design_system/pos_design_system.dart';
import '../../../../design_system/pos_components.dart';
import '../../../../design_system/colors.dart';
import '../providers/pos_cart_provider.dart';
import 'pos_pizza_customization_modal.dart';
import 'pos_menu_customization_modal.dart';

/// POS Catalog View - displays products catalog for POS mode
/// Reuses the same product display logic as staff tablet but adapted for POS
class PosCatalogView extends ConsumerStatefulWidget {
  const PosCatalogView({Key? key}) : super(key: key);

  @override
  ConsumerState<PosCatalogView> createState() => _PosCatalogViewState();
}

class _PosCatalogViewState extends ConsumerState<PosCatalogView> {
  ProductCategory _selectedCategory = ProductCategory.pizza;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Column(
      children: [
        // Category tabs - ShopCaisse style
        Container(
          color: PosColors.surface,
          padding: EdgeInsets.symmetric(vertical: PosSpacing.md),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: PosSpacing.md),
            child: Row(
              children: [
                _buildCategoryChip(ProductCategory.pizza, 'Pizzas', Icons.local_pizza),
                SizedBox(width: PosSpacing.md),
                _buildCategoryChip(ProductCategory.menus, 'Menus', Icons.restaurant_menu),
                SizedBox(width: PosSpacing.md),
                _buildCategoryChip(ProductCategory.boissons, 'Boissons', Icons.local_drink),
                SizedBox(width: PosSpacing.md),
                _buildCategoryChip(ProductCategory.desserts, 'Desserts', Icons.cake),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: PosColors.border),

        // Products grid
        Expanded(
          child: productsAsync.when(
            data: (products) {
              final filteredProducts = products
                  .where((p) => p.category == _selectedCategory && p.isActive)
                  .toList();

              if (filteredProducts.isEmpty) {
                return const PosEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Aucun produit',
                  subtitle: 'Aucun produit dans cette catégorie',
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(PosSpacing.md),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: PosSpacing.md,
                  mainAxisSpacing: PosSpacing.md,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return _buildProductCard(product);
                },
              );
            },
            loading: () => const PosLoadingState(message: 'Chargement des produits...'),
            error: (error, stack) => PosErrorState(
              title: 'Erreur de chargement',
              subtitle: error.toString(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(ProductCategory category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
          borderRadius: PosRadii.mdRadius,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: PosSpacing.lg, vertical: PosSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? PosColors.primary : PosColors.surface,
              borderRadius: PosRadii.mdRadius,
              border: Border.all(
                color: isSelected ? PosColors.primary : PosColors.border,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected ? PosShadows.md : PosShadows.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: PosIconSize.sm,
                  color: isSelected ? PosColors.textOnPrimary : PosColors.primary,
                ),
                SizedBox(width: PosSpacing.sm),
                Text(
                  label,
                  style: PosTypography.labelLarge.copyWith(
                    color: isSelected ? PosColors.textOnPrimary : PosColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return PosCard(
      padding: EdgeInsets.zero,
      onTap: () {
        // Show customization modal for menus
        if (product.isMenu) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => PosMenuCustomizationModal(menu: product),
            );
          }
          // Show customization modal for pizzas
          else if (product.category == ProductCategory.pizza && product.baseIngredients.isNotEmpty) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => PosPizzaCustomizationModal(pizza: product),
          );
        } else {
          // Direct add for other items (drinks, desserts, etc.)
          ref.read(posCartProvider.notifier).addItem(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: PosColors.textOnPrimary),
                  SizedBox(width: PosSpacing.sm),
                  Expanded(
                    child: Text(
                      '${product.name} ajouté au panier',
                      style: PosTypography.bodyMedium.copyWith(
                        color: PosColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 1200),
              backgroundColor: PosColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: PosRadii.mdRadius),
              margin: EdgeInsets.all(PosSpacing.md),
            ),
          );
        }
      },
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(PosRadii.md)),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: PosColors.surfaceVariant,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      PosColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: PosColors.surfaceVariant,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported_rounded,
                                      size: PosIconSize.xl, color: PosColors.textTertiary),
                                  SizedBox(height: PosSpacing.sm),
                                  Text(
                                    'Image non disponible',
                                    style: PosTypography.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fastfood_rounded,
                                    size: 56, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'Pas d\'image',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Gradient overlay for better text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product info
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLighter,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${product.price.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}
