// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/staff_tablet/screens/staff_tablet_catalog_screen.dart

import 'package:flutter/material.dart';
import '../../src/design_system/colors.dart';
import '../../white_label/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../design_system/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';
import '../providers/staff_tablet_cart_provider.dart';
import '../providers/staff_tablet_auth_provider.dart';
import '../widgets/staff_tablet_cart_summary.dart';
import '../widgets/staff_pizza_customization_modal.dart';
import '../widgets/staff_menu_customization_modal.dart';

class StaffTabletCatalogScreen extends ConsumerStatefulWidget {
  const StaffTabletCatalogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StaffTabletCatalogScreen> createState() => _StaffTabletCatalogScreenState();
}

class _StaffTabletCatalogScreenState extends ConsumerState<StaffTabletCatalogScreen> {
  ProductCategory _selectedCategory = ProductCategory.pizza;

  @override
  Widget build(BuildContext context) {
    // PROTECTION: Vérifier que l'utilisateur est admin
    final authState = ref.watch(authProvider);
    if (!authState.isAdmin) {
      return _buildUnauthorizedScreen(context);
    }
    
    final productsAsync = ref.watch(productListProvider);
    final cart = ref.watch(staffTabletCartProvider);

    return Scaffold(
      backgroundColor: context.colorScheme.surfaceVariant ,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Mode Caisse - Prise de Commande',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.onPrimary,
          ),
        ),
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history, size: 28),
            onPressed: () => context.push('/staff-tablet/history'),
            tooltip: 'Historique',
            color: context.onPrimary,
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, size: 28),
            onPressed: () async {
              await ref.read(staffTabletAuthProvider.notifier).logout();
              if (mounted) {
                context.go('/menu');
              }
            },
            tooltip: 'Déconnexion',
            color: context.onPrimary,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Left side - Categories and Products
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Category tabs
                Container(
                  color: context.onPrimary,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildCategoryChip(ProductCategory.pizza, 'Pizzas', Icons.local_pizza),
                        const SizedBox(width: 12),
                        _buildCategoryChip(ProductCategory.menus, 'Menus', Icons.restaurant_menu),
                        const SizedBox(width: 12),
                        _buildCategoryChip(ProductCategory.boissons, 'Boissons', Icons.local_drink),
                        const SizedBox(width: 12),
                        _buildCategoryChip(ProductCategory.desserts, 'Desserts', Icons.cake),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Products grid
                Expanded(
                  child: productsAsync.when(
                    data: (products) {
                      final filteredProducts = products
                          .where((p) => p.category == _selectedCategory && p.isActive)
                          .toList();

                      if (filteredProducts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 64, color: context.colorScheme.surfaceVariant ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun produit dans cette catégorie',
                                style: TextStyle(fontSize: 18, color: context.colorScheme.surfaceVariant ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(product);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Erreur: $error', style: const TextStyle(color: AppColors.error)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right side - Cart
          Container(
            width: 380,
            decoration: BoxDecoration(
              color: context.onPrimary,
              boxShadow: [
                BoxShadow(
                  color: context.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: const StaffTabletCartSummary(),
          ),
        ],
      ),
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
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : context.onPrimary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : context.colorScheme.surfaceVariant ,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: context.colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? context.onPrimary : AppColors.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? context.onPrimary : context.colorScheme.surfaceVariant ,
                    letterSpacing: 0.2,
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
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Show customization modal for menus
          if (product.isMenu) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => StaffMenuCustomizationModal(menu: product),
            );
          }
          // Show customization modal for pizzas
          else if (product.category == ProductCategory.pizza && product.baseIngredients.isNotEmpty) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => StaffPizzaCustomizationModal(pizza: product),
            );
          } else {
            // Direct add for other items (drinks, desserts, etc.)
            ref.read(staffTabletCartProvider.notifier).addItem(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: context.onPrimary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${product.name} ajouté au panier',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 1200),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: context.colorScheme.surfaceVariant ,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 3,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: context.colorScheme.surfaceVariant ,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported_rounded,
                                      size: 48, color: context.colorScheme.surfaceVariant ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image non disponible',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.colorScheme.surfaceVariant ,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            color: context.colorScheme.surfaceVariant ,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fastfood_rounded,
                                    size: 56, color: context.colorScheme.surfaceVariant ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pas d\'image',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colorScheme.surfaceVariant ,
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
                            context.colorScheme.shadow.withOpacity(0.3),
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
                  color: context.onPrimary,
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
                        color: context.colorScheme.surfaceVariant ,
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
                          padding: const EdgeInsets.symmetric(
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: context.onPrimary,
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
      ),
    );
  }

  /// Widget d'écran non autorisé pour les non-admins
  Widget _buildUnauthorizedScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.error[900]!,
              AppColors.error[700]!,
            ],
          ),
        ),
        child: Center(
          child: Card(
            margin: EdgeInsets.all(AppSpacing.xl),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    size: 80,
                    color: AppColors.error,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Accès non autorisé',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Le module CAISSE est réservé aux administrateurs uniquement.',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: () => context.go('/menu'),
                    icon: const Icon(Icons.home),
                    label: const Text('Retour à l\'accueil'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
