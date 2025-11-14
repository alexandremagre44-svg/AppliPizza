// lib/src/screens/home/elegant_pizza_customization_modal.dart
// Ultra-professional pizza customization modal with modern design

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui';

import '../../../product/data/models/product.dart';
import '../../data/mock_data.dart';
import '../../../cart/application/cart_provider.dart';
import '../../../shared/theme/app_theme.dart';

const _uuid = Uuid();

class ElegantPizzaCustomizationModal extends ConsumerStatefulWidget {
  final Product pizza;

  const ElegantPizzaCustomizationModal({super.key, required this.pizza});

  @override
  ConsumerState<ElegantPizzaCustomizationModal> createState() =>
      _ElegantPizzaCustomizationModalState();
}

class _ElegantPizzaCustomizationModalState
    extends ConsumerState<ElegantPizzaCustomizationModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  late TabController _tabController;
  
  // Ingrédients de base (tous sélectionnés par défaut)
  late Map<String, bool> _baseIngredients;
  
  // Suppléments disponibles (tous désélectionnés par défaut)
  late Map<String, bool> _supplementIngredients;
  
  // Taille sélectionnée
  String _selectedSize = 'Moyenne';
  
  // Note spéciale
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _animationController.forward();
    
    // Tab controller
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize base ingredients (all selected by default - pre-filled)
    _baseIngredients = {};
    for (final ingredient in widget.pizza.baseIngredients) {
      _baseIngredients[ingredient] = true;
    }
    
    // Initialize supplements (all unselected by default)
    _supplementIngredients = {};
    for (final ingredient in mockIngredients) {
      _supplementIngredients[ingredient.name] = false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double price = widget.pizza.price;
    
    // Ajustement selon la taille
    if (_selectedSize == 'Grande') {
      price += 3.0;
    }
    
    // Coût des suppléments sélectionnés
    for (final entry in _supplementIngredients.entries) {
      if (entry.value) {
        final ingredient = mockIngredients.firstWhere(
          (ing) => ing.name == entry.key,
          orElse: () => Ingredient(id: '', name: '', extraCost: 0.0),
        );
        price += ingredient.extraCost;
      }
    }
    
    return price;
  }

  String _buildCustomDescription() {
    final List<String> details = [];
    
    // Taille
    details.add('Taille: $_selectedSize');
    
    // Ingrédients retirés
    final removed = _baseIngredients.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
    if (removed.isNotEmpty) {
      details.add('Sans: ${removed.join(', ')}');
    }
    
    // Suppléments ajoutés
    final added = _supplementIngredients.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    if (added.isNotEmpty) {
      details.add('Avec: ${added.join(', ')}');
    }
    
    // Note
    if (_notesController.text.isNotEmpty) {
      details.add('Note: ${_notesController.text}');
    }
    
    return details.join(' • ');
  }

  void _addToCart() async {
    // Animation de sortie
    await _animationController.reverse();
    
    final cartNotifier = ref.read(cartProvider.notifier);
    
    final newCartItem = CartItem(
      id: _uuid.v4(),
      productId: widget.pizza.id,
      productName: widget.pizza.name,
      price: _totalPrice,
      quantity: 1,
      imageUrl: widget.pizza.imageUrl,
      customDescription: _buildCustomDescription(),
      isMenu: false,
    );

    cartNotifier.addExistingItem(newCartItem);
    
    if (mounted) {
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('${widget.pizza.name} ajouté au panier !'),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.92,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRed.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Modern handle bar
                _buildModernHandleBar(),
                
                // Premium header with gradient
                _buildPremiumHeader(theme),
                
                // Professional tabs
                _buildProfessionalTabBar(theme),
                
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildIngredientsTab(),
                      _buildOptionsTab(),
                    ],
                  ),
                ),
                
                // Premium footer with gradient
                _buildPremiumFooter(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRed.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 16,
                  color: AppTheme.primaryRed,
                ),
                const SizedBox(width: 8),
                Text(
                  'PERSONNALISEZ VOTRE PIZZA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryRed,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryRed.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Premium image with gradient border
            Hero(
              tag: 'pizza_${widget.pizza.id}',
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primaryRed,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRed.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      widget.pizza.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                          ),
                          child: const Icon(Icons.local_pizza, size: 50, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pizza.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.pizza.description,
                    style: TextStyle(
                      color: AppTheme.textMedium,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Prix de base: ${widget.pizza.price.toStringAsFixed(2)}€',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryRed.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textMedium,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            icon: Icon(Icons.restaurant_menu, size: 24),
            text: 'Ingrédients',
            height: 60,
          ),
          Tab(
            icon: Icon(Icons.settings_suggest, size: 24),
            text: 'Options',
            height: 60,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Ingrédients de base (pré-remplis)
          _buildSectionHeader(
            'Ingrédients de base',
            'Tous sélectionnés par défaut. Retirez ce que vous ne souhaitez pas.',
            Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 16),
          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _baseIngredients.entries.map((entry) {
                return _buildAnimatedIngredientChip(
                  entry.key,
                  isSelected: entry.value,
                  isBase: true,
                  onTap: () {
                    setState(() {
                      _baseIngredients[entry.key] = !entry.value;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 32),
          const Divider(height: 1),
          const SizedBox(height: 32),
          
          // Section: Suppléments
          _buildSectionHeader(
            'Suppléments disponibles',
            'Ajoutez des ingrédients premium à votre pizza',
            Icons.add_circle_outline,
          ),
          const SizedBox(height: 16),
          
          ...mockIngredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: _buildElegantSupplementTile(ingredient),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélection de taille avec animation
          _buildSectionHeader(
            'Taille de la pizza',
            'Choisissez votre format préféré',
            Icons.straighten,
          ),
          const SizedBox(height: 16),
          
          _buildAnimatedSizeSelector(),
          
          const SizedBox(height: 32),
          const Divider(height: 1),
          const SizedBox(height: 32),
          
          // Notes spéciales
          _buildSectionHeader(
            'Instructions spéciales',
            'Des précisions pour personnaliser votre commande',
            Icons.edit_note,
          ),
          const SizedBox(height: 16),
          
          _buildElegantTextField(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryRed.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRed.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppTheme.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIngredientChip(
    String ingredient, {
    required bool isSelected,
    required bool isBase,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 0.95, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryRed : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryRed
                  : Colors.grey[300]!,
              width: 2.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryRed.withOpacity(0.4),
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.cancel,
                  key: ValueKey(isSelected),
                  size: 20,
                  color: isSelected ? Colors.white : AppTheme.textMedium,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                ingredient,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textDark,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElegantSupplementTile(Ingredient ingredient) {
    final isSelected = _supplementIngredients[ingredient.name] ?? false;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryRed : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryRed
              : Colors.grey[200]!,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppTheme.primaryRed.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: isSelected ? 15 : 6,
            offset: Offset(0, isSelected ? 6 : 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _supplementIngredients[ingredient.name] = !isSelected;
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Premium animated icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryRed : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryRed.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                    key: ValueKey(isSelected),
                    color: isSelected ? Colors.white : AppTheme.textMedium,
                    size: 30,
                  ),
                ),
              ),
              
              const SizedBox(width: 18),
              
              // Ingredient name
              Expanded(
                child: Text(
                  ingredient.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected
                        ? AppTheme.primaryRed
                        : AppTheme.textDark,
                    fontSize: 17,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              
              // Price badge with animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 1.0, end: isSelected ? 1.05 : 1.0),
                curve: Curves.easeOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryRed : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryRed.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    '+${ingredient.extraCost.toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : AppTheme.textMedium,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSizeSelector() {
    final sizes = [
      {'name': 'Moyenne', 'size': 36.0, 'extra': 0.0, 'desc': '30 cm'},
      {'name': 'Grande', 'size': 48.0, 'extra': 3.0, 'desc': '40 cm'},
    ];
    
    return Row(
      children: sizes.map((sizeData) {
        final name = sizeData['name'] as String;
        final iconSize = sizeData['size'] as double;
        final extraCost = sizeData['extra'] as double;
        final desc = sizeData['desc'] as String;
        final isSelected = _selectedSize == name;
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 0.95, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: InkWell(
                onTap: () => setState(() => _selectedSize = name),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryRed : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryRed
                          : Colors.grey[300]!,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryRed.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.local_pizza,
                          size: iconSize,
                          color: isSelected ? Colors.white : AppTheme.textMedium,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: isSelected ? Colors.white : AppTheme.textDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : AppTheme.textMedium,
                        ),
                      ),
                      if (extraCost > 0) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.25)
                                : AppTheme.primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${extraCost.toStringAsFixed(2)}€',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.primaryRed,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildElegantTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 5,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Ex: Bien cuite, supplément d\'ail, peu d\'oignons...',
          hintStyle: TextStyle(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: AppTheme.primaryRed,
              width: 2.5,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.all(18),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.edit_note_rounded,
              color: AppTheme.primaryRed,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Prix récapitulatif
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryRed.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prix total',
                        style: TextStyle(
                          color: AppTheme.textMedium,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(begin: _totalPrice, end: _totalPrice),
                        builder: (context, value, child) {
                          return Text(
                            '${value.toStringAsFixed(2)}€',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  colors: [AppTheme.primaryRed, AppTheme.primaryRedLight],
                                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRed.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.euro,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bouton Ajouter au panier premium
            Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRed.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_rounded, size: 26),
                    SizedBox(width: 12),
                    Text(
                      'AJOUTER AU PANIER',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
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
}
