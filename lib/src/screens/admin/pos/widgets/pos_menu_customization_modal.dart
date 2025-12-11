// lib/src/screens/admin/pos/widgets/pos_menu_customization_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/product.dart';
import '../../../../design_system/app_theme.dart';
import '../providers/pos_cart_provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/product_provider.dart';

const _uuid = Uuid();

/// Modal de personnalisation de menu pour le module POS
/// Adapté du StaffMenuCustomizationModal mais utilise posCartProvider
class PosMenuCustomizationModal extends ConsumerStatefulWidget {
  final Product menu;

  const PosMenuCustomizationModal({super.key, required this.menu});

  @override
  ConsumerState<PosMenuCustomizationModal> createState() =>
      _PosMenuCustomizationModalState();
}

class _PosMenuCustomizationModalState
    extends ConsumerState<PosMenuCustomizationModal> {
  
  Product? _selectedPizza;
  Product? _selectedDrink;
  Product? _selectedDessert;

  void _addToCart() {
    if (_selectedPizza == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une pizza'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Build menu description
    final List<String> items = [];
    if (_selectedPizza != null) items.add(_selectedPizza!.name);
    if (_selectedDrink != null) items.add(_selectedDrink!.name);
    if (_selectedDessert != null) items.add(_selectedDessert!.name);
    
    final customDescription = items.join(' + ');
    
    // Utilise POS cart provider
    final cartNotifier = ref.read(posCartProvider.notifier);
    
    final customItem = CartItem(
      id: _uuid.v4(),
      productId: widget.menu.id,
      productName: widget.menu.name,
      price: widget.menu.price,
      quantity: 1,
      imageUrl: widget.menu.imageUrl,
      customDescription: customDescription,
      isMenu: true,
    );
    
    cartNotifier.addExistingItem(customItem);
    
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${widget.menu.name} ajouté au panier',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    
    return productsAsync.when(
      data: (allProducts) {
        final pizzas = allProducts
            .where((p) => p.category == ProductCategory.pizza && p.isActive)
            .toList();
        final drinks = allProducts
            .where((p) => p.category == ProductCategory.boissons && p.isActive)
            .toList();
        final desserts = allProducts
            .where((p) => p.category == ProductCategory.desserts && p.isActive)
            .toList();
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: widget.menu.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.menu.imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.white24,
                                child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 35),
                              ),
                            )
                          : Container(
                              width: 70,
                              height: 70,
                              color: Colors.white24,
                              child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 35),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.menu.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.menu.price.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pizza selection
                      _buildSectionTitle('Choisissez une pizza', Icons.local_pizza),
                      const SizedBox(height: 12),
                      ...pizzas.map((pizza) => _ProductTile(
                        product: pizza,
                        isSelected: _selectedPizza?.id == pizza.id,
                        onTap: () => setState(() => _selectedPizza = pizza),
                      )),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      
                      // Drink selection (optional)
                      _buildSectionTitle('Boisson (optionnel)', Icons.local_drink),
                      const SizedBox(height: 12),
                      ...drinks.take(5).map((drink) => _ProductTile(
                        product: drink,
                        isSelected: _selectedDrink?.id == drink.id,
                        onTap: () => setState(() => _selectedDrink = drink),
                      )),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      
                      // Dessert selection (optional)
                      _buildSectionTitle('Dessert (optionnel)', Icons.cake),
                      const SizedBox(height: 12),
                      ...desserts.take(5).map((dessert) => _ProductTile(
                        product: dessert,
                        isSelected: _selectedDessert?.id == dessert.id,
                        onTap: () => setState(() => _selectedDessert = dessert),
                      )),
                    ],
                  ),
                ),
              ),
              
              // Footer with add button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.add_shopping_cart, size: 24),
                  label: const Text(
                    'Ajouter au panier',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erreur: $err')),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProductTile({
    required this.product,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLighter : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: Icon(Icons.fastfood, color: Colors.grey[400]),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: Icon(Icons.fastfood, color: Colors.grey[400]),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : Colors.grey[800],
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
