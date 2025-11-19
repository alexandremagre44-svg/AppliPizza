// lib/src/screens/menu/menu_customization_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../design_system/app_theme.dart';

const _uuid = Uuid();

class MenuCustomizationModal extends ConsumerStatefulWidget {
  final Product menu;

  const MenuCustomizationModal({super.key, required this.menu});

  @override
  ConsumerState<MenuCustomizationModal> createState() => _MenuCustomizationModalState();
}

class _MenuCustomizationModalState extends ConsumerState<MenuCustomizationModal> {
  // Liste pour stocker les pizzas sélectionnées (par défaut à la taille du menu)
  late List<Product?> _selectedPizzas;
  // Liste pour stocker les boissons sélectionnées
  late List<Product?> _selectedDrinks;

  @override
  void initState() {
    super.initState();
    // Initialisation avec des valeurs nulles
    _selectedPizzas = List.filled(widget.menu.pizzaCount, null);
    _selectedDrinks = List.filled(widget.menu.drinkCount, null);
  }

  // Vérifie si toutes les sélections obligatoires sont faites
  bool get _isSelectionComplete {
    return _selectedPizzas.every((p) => p != null) &&
        _selectedDrinks.every((d) => d != null);
  }

  // Construit la description pour le CartItem
  String _buildCustomDescription() {
    final pizzaNames = _selectedPizzas.whereType<Product>().map((p) => p.name).join(', ');
    final drinkNames = _selectedDrinks.whereType<Product>().map((d) => d.name).join(', ');

    String description = '';
    if (pizzaNames.isNotEmpty) {
      description += 'Pizzas: $pizzaNames';
    }
    if (drinkNames.isNotEmpty) {
      if (description.isNotEmpty) description += ' - ';
      description += 'Boissons: $drinkNames';
    }
    return description.isEmpty ? 'Menu standard' : description;
  }

  void _addToCart() {
    if (!_isSelectionComplete) return;

    final cartNotifier = ref.read(cartProvider.notifier);
    
    // Crée le nouvel article de panier (CartItem) pour le menu
    final newCartItem = CartItem(
      id: _uuid.v4(),
      productId: widget.menu.id,
      productName: widget.menu.name,
      price: widget.menu.price, // Le prix est celui du menu, pas la somme des composants
      quantity: 1,
      imageUrl: widget.menu.imageUrl,
      customDescription: _buildCustomDescription(),
      isMenu: true,
    );

    // Utilise la méthode addExistingItem que nous avons ajoutée dans cart_provider
    cartNotifier.addExistingItem(newCartItem);
    
    Navigator.of(context).pop(); // Ferme le modal
  }

  // Affiche un modal de sélection pour une pizza ou une boisson
  Future<void> _showSelectionModal({
    required String title,
    required List<Product> options,
    required int index,
    required bool isPizza,
  }) async {
    final selectedProduct = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _SelectionOptionsModal(
          title: title,
          options: options,
        );
      },
    );

    if (selectedProduct != null) {
      setState(() {
        if (isPizza) {
          _selectedPizzas[index] = selectedProduct;
        } else {
          _selectedDrinks[index] = selectedProduct;
        }
      });
    }
  }

  Widget _buildSelectionTile(String title, Product? selected, VoidCallback onTap) {
    final isSelected = selected != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? AppShadows.card : AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.card,
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                    borderRadius: AppRadius.radiusMedium,
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                    color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMediumSemiBold.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        selected?.name ?? 'Cliquez pour sélectionner',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Charger les produits depuis le provider (inclut mock + admin + Firestore)
    final productsAsync = ref.watch(productListProvider);
    
    return productsAsync.when(
      data: (allProducts) {
        final pizzaOptions = allProducts
            .where((p) => p.category == ProductCategory.pizza && !p.isMenu)
            .toList();
        final drinkOptions = allProducts
            .where((p) => p.category == ProductCategory.boissons)
            .toList();
        
        return _buildContent(context, pizzaOptions, drinkOptions);
      },
      loading: () => _buildLoading(),
      error: (error, stack) => _buildError(error),
    );
  }

  Widget _buildLoading() {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildError(Object error) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Erreur: $error'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Product> pizzaOptions,
    List<Product> drinkOptions,
  ) {

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: AppRadius.bottomSheet.topLeft),
          ),
          child: Column(
            children: [
              // Drag handle Material 3
              Padding(
                padding: AppSpacing.paddingVerticalSM,
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: AppRadius.radiusFull,
                  ),
                ),
              ),

              // Header avec titre
              _buildHeader(context),

              // Contenu scrollable
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: AppSpacing.paddingHorizontalMD,
                  children: [
                    AppSpacing.verticalSpaceSM,
                    
                    // Menu info card
                    _buildMenuInfoCard(context),
                    
                    AppSpacing.verticalSpaceLG,
                    
                    // --- Section Pizzas ---
                    if (widget.menu.pizzaCount > 0) ...[
                      _buildSectionHeader(
                        icon: Icons.local_pizza_rounded,
                        title: 'Vos Pizzas',
                        subtitle: '${widget.menu.pizzaCount} requises',
                        badgeCount: widget.menu.pizzaCount,
                      ),
                      AppSpacing.verticalSpaceMD,
                      ...List.generate(widget.menu.pizzaCount, (index) {
                        return _buildSelectionTile(
                          'Pizza n°${index + 1}',
                          _selectedPizzas[index],
                          () => _showSelectionModal(
                            title: 'Choisir la Pizza n°${index + 1}',
                            options: pizzaOptions,
                            index: index,
                            isPizza: true,
                          ),
                        );
                      }),
                      AppSpacing.verticalSpaceLG,
                    ],

                    // --- Section Boissons ---
                    if (widget.menu.drinkCount > 0) ...[
                      _buildSectionHeader(
                        icon: Icons.local_drink_rounded,
                        title: 'Vos Boissons',
                        subtitle: '${widget.menu.drinkCount} requises',
                        badgeCount: widget.menu.drinkCount,
                      ),
                      AppSpacing.verticalSpaceMD,
                      ...List.generate(widget.menu.drinkCount, (index) {
                        return _buildSelectionTile(
                          'Boisson n°${index + 1}',
                          _selectedDrinks[index],
                          () => _showSelectionModal(
                            title: 'Choisir la Boisson n°${index + 1}',
                            options: drinkOptions,
                            index: index,
                            isPizza: false,
                          ),
                        );
                      }),
                    ],
                    
                    SizedBox(height: 100 + AppSpacing.lg), // Espace pour bouton fixe
                  ],
                ),
              ),

              // CTA fixe en bas
              _buildFixedCTA(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingHorizontalMD,
      child: Column(
        children: [
          Text(
            widget.menu.name,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            'Personnalisez votre menu',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildMenuInfoCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.radiusMedium,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prix du menu',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${widget.menu.price.toStringAsFixed(2)} €',
                    style: AppTextStyles.priceLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required int badgeCount,
  }) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.radiusMedium,
            ),
            child: Icon(
              icon,
              color: AppColors.onPrimary,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadius.badge,
            ),
            child: Text(
              '$badgeCount',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedCTA(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.navBar,
        borderRadius: BorderRadius.vertical(top: AppRadius.card.topLeft),
      ),
      child: SafeArea(
        child: AnimatedScale(
          scale: _isSelectionComplete ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 200),
          child: FilledButton(
            onPressed: _isSelectionComplete ? _addToCart : null,
            style: FilledButton.styleFrom(
              backgroundColor: _isSelectionComplete ? AppColors.primary : AppColors.neutral300,
              minimumSize: const Size.fromHeight(56),
              padding: AppSpacing.buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.button,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_rounded,
                  size: 24,
                  color: _isSelectionComplete ? AppColors.onPrimary : AppColors.neutral500,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Ajouter au panier',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: _isSelectionComplete ? AppColors.onPrimary : AppColors.neutral500,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: _isSelectionComplete 
                        ? AppColors.onPrimary.withOpacity(0.2)
                        : AppColors.neutral400,
                    borderRadius: AppRadius.badge,
                  ),
                  child: Text(
                    '${widget.menu.price.toStringAsFixed(2)} €',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: _isSelectionComplete ? AppColors.onPrimary : AppColors.neutral600,
                      fontWeight: FontWeight.bold,
                    ),
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

// Modal interne pour choisir les options (Pizza ou Boisson)
class _SelectionOptionsModal extends StatelessWidget {
  final String title;
  final List<Product> options;

  const _SelectionOptionsModal({
    required this.title,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: AppRadius.bottomSheet.topLeft),
      ),
      child: Column(
        children: [
          // Drag handle Material 3
          Padding(
            padding: AppSpacing.paddingVerticalSM,
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: AppRadius.radiusFull,
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: AppSpacing.paddingHorizontalMD,
            child: Column(
              children: [
                Text(
                  title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Sélectionnez une option',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // Product list
          Expanded(
            child: ListView.builder(
              padding: AppSpacing.paddingHorizontalMD,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return Card(
                  margin: EdgeInsets.only(bottom: AppSpacing.sm),
                  elevation: 0,
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.card,
                    side: BorderSide(color: AppColors.outlineVariant),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(option),
                    borderRadius: AppRadius.card,
                    child: Padding(
                      padding: AppSpacing.paddingMD,
                      child: Row(
                        children: [
                          // Image
                          if (option.imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: AppRadius.radiusSmall,
                              child: Image.network(
                                option.imageUrl,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainer,
                                      borderRadius: AppRadius.radiusSmall,
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported_rounded,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  );
                                },
                              ),
                            ),
                          
                          SizedBox(width: AppSpacing.md),
                          
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.name,
                                  style: AppTextStyles.bodyMediumSemiBold,
                                ),
                                SizedBox(height: AppSpacing.xxs),
                                Text(
                                  option.description.length > 50
                                      ? '${option.description.substring(0, 50)}...'
                                      : option.description,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(width: AppSpacing.sm),
                          
                          // Prix badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: AppRadius.badge,
                            ),
                            child: Text(
                              '${option.price.toStringAsFixed(2)} €',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}