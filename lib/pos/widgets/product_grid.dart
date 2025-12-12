/// POS Product Grid - displays products catalog for POS mode
/// 
/// This widget displays products organized by category with a grid layout.
/// It reuses the product provider from the existing app infrastructure.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../src/models/product.dart';
import '../../src/providers/product_provider.dart';
import 'product_card.dart';

/// Product grid widget for POS
class PosProductGrid extends ConsumerStatefulWidget {
  const PosProductGrid({super.key});
  
  @override
  ConsumerState<PosProductGrid> createState() => _PosProductGridState();
}

class _PosProductGridState extends ConsumerState<PosProductGrid> {
  ProductCategory _selectedCategory = ProductCategory.pizza;
  
  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    
    return Column(
      children: [
        // Category tabs
        Container(
          color: Colors.white,
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
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun produit dans cette catégorie',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
                  return PosProductCard(product: filteredProducts[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Erreur: $error', style: const TextStyle(color: Colors.red)),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategoryChip(ProductCategory category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
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
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                  color: isSelected ? Colors.white : theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.grey[800],
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
}
