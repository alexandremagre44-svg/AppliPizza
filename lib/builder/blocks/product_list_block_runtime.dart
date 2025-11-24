// lib/builder/blocks/product_list_block_runtime.dart
// Runtime version of ProductListBlock - Phase 5 enhanced

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/builder_block.dart';
import '../utils/block_config_helper.dart';
import '../utils/action_helper.dart';
import '../../src/models/product.dart';
import '../../src/providers/product_provider.dart';
import '../../src/providers/cart_provider.dart';
import '../../src/widgets/product_card.dart';
import '../../src/widgets/home/promo_card_compact.dart';
import '../../src/screens/home/pizza_customization_modal.dart';
import '../../src/screens/menu/menu_customization_modal.dart';

/// Product list block for displaying product grids, carousels, or lists
/// 
/// Configuration:
/// - title: Section title (default: '')
/// - layout: Display layout - grid, carousel, list (default: grid)
/// - columns: Grid columns (default: 2 mobile, 4 desktop)
/// - showPrices: Display prices (default: true)
/// - showBadges: Display product badges (default: true)
/// - category: Filter by category (default: null = all products)
/// - limit: Maximum products to show (default: null = unlimited)
/// - padding: Padding around container (default: 12)
/// - margin: Margin around container (default: 0)
/// - backgroundColor: Background color in hex (default: transparent)
/// - borderRadius: Corner radius (default: 0)
/// - tapAction: Custom action on product tap (optional)
/// 
/// Responsive: Grid adapts columns based on screen size
class ProductListBlockRuntime extends ConsumerWidget {
  final BuilderBlock block;

  // Responsive breakpoints
  static const double _mobileBreakpoint = 600.0;
  static const double _desktopBreakpoint = 800.0;

  const ProductListBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults
    final title = helper.getString('title', defaultValue: '');
    final layout = helper.getString('layout', defaultValue: 'grid');
    final columns = _calculateColumns(helper, context);
    final showPrices = helper.getBool('showPrices', defaultValue: true);
    final showBadges = helper.getBool('showBadges', defaultValue: true);
    final category = helper.getString('category', defaultValue: '');
    final limitValue = helper.has('limit') ? helper.getInt('limit') : null;
    final padding = helper.getEdgeInsets('padding', defaultValue: const EdgeInsets.all(12));
    final margin = helper.getEdgeInsets('margin');
    final backgroundColor = helper.getColor('backgroundColor');
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 0.0);
    final tapActionConfig = block.config['tapAction'] as Map<String, dynamic>?;

    final productsAsync = ref.watch(productListProvider);

    return productsAsync.when(
      data: (allProducts) {
        final products = _filterProducts(allProducts, category, limitValue);

        if (products.isEmpty) {
          return _buildPlaceholder(padding, margin, backgroundColor, borderRadius);
        }

        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildLayout(
              context,
              ref,
              products,
              layout,
              columns,
              showPrices,
              showBadges,
              tapActionConfig,
            ),
          ],
        );

        // Apply padding
        content = Padding(
          padding: padding,
          child: content,
        );

        // Apply background color and border radius
        if (backgroundColor != null || borderRadius > 0) {
          content = Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
            ),
            child: content,
          );
        }

        // Apply margin
        if (margin != EdgeInsets.zero) {
          content = Padding(
            padding: margin,
            child: content,
          );
        }

        return content;
      },
      loading: () => _buildLoadingPlaceholder(padding, margin),
      error: (error, stack) {
        debugPrint('Error loading products: $error');
        return _buildErrorPlaceholder(padding, margin, backgroundColor, borderRadius);
      },
    );
  }

  /// Calculate grid columns based on screen size and config
  int _calculateColumns(BlockConfigHelper helper, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < _mobileBreakpoint;
    
    // Use config value if provided, otherwise use responsive defaults
    if (helper.has('columns')) {
      return helper.getInt('columns', defaultValue: isMobile ? 2 : 4);
    }
    
    return isMobile ? 2 : 4;
  }

  /// Filter products by category and limit
  List<Product> _filterProducts(List<Product> allProducts, String category, int? limit) {
    // Filter by category if specified
    List<Product> filtered = allProducts.where((p) => p.isActive).toList();
    
    if (category.isNotEmpty) {
      try {
        final categoryEnum = ProductCategory.values.firstWhere(
          (c) => c.value == category,
          orElse: () => ProductCategory.values.first,
        );
        filtered = filtered.where((p) => p.category == categoryEnum).toList();
      } catch (e) {
        debugPrint('Invalid category: $category');
      }
    }
    
    // Apply limit if specified
    if (limit != null && limit > 0) {
      filtered = filtered.take(limit).toList();
    }
    
    return filtered;
  }

  /// Build layout based on configuration
  Widget _buildLayout(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
    String layout,
    int columns,
    bool showPrices,
    bool showBadges,
    Map<String, dynamic>? tapActionConfig,
  ) {
    switch (layout.toLowerCase()) {
      case 'carousel':
        return _buildCarousel(context, ref, products, tapActionConfig);
      case 'list':
        return _buildList(context, ref, products, showPrices, showBadges, tapActionConfig);
      case 'grid':
      default:
        return _buildGrid(context, ref, products, columns, showPrices, showBadges, tapActionConfig);
    }
  }

  /// Build grid layout
  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
    int columns,
    bool showPrices,
    bool showBadges,
    Map<String, dynamic>? tapActionConfig,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(
        context,
        ref,
        products[index],
        showPrices,
        showBadges,
        tapActionConfig,
      ),
    );
  }

  /// Build carousel layout
  Widget _buildCarousel(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
    Map<String, dynamic>? tapActionConfig,
  ) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PromoCardCompact(
              product: product,
              onTap: () => _handleProductTap(context, ref, product, tapActionConfig),
            ),
          );
        },
      ),
    );
  }

  /// Build list layout
  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
    bool showPrices,
    bool showBadges,
    Map<String, dynamic>? tapActionConfig,
  ) {
    return Column(
      children: products
          .map((product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildProductCard(
                  context,
                  ref,
                  product,
                  showPrices,
                  showBadges,
                  tapActionConfig,
                ),
              ))
          .toList(),
    );
  }

  /// Build product card
  Widget _buildProductCard(
    BuildContext context,
    WidgetRef ref,
    Product product,
    bool showPrices,
    bool showBadges,
    Map<String, dynamic>? tapActionConfig,
  ) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart.items.cast<CartItem?>().firstWhere(
      (item) => item?.productId == product.id,
      orElse: () => null,
    );

    return ProductCard(
      product: product,
      onAddToCart: () => _handleProductTap(context, ref, product, tapActionConfig),
      cartQuantity: cartItem?.quantity,
    );
  }

  /// Handle product tap with custom action or default behavior
  void _handleProductTap(
    BuildContext context,
    WidgetRef ref,
    Product product,
    Map<String, dynamic>? tapActionConfig,
  ) {
    // If custom tap action is configured, use ActionHelper
    if (tapActionConfig != null && tapActionConfig.isNotEmpty) {
      ActionHelper.execute(context, BlockAction.fromConfig(tapActionConfig));
      return;
    }

    // Default behavior: show customization or add to cart
    final cartNotifier = ref.read(cartProvider.notifier);
    
    if (product.isMenu) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => MenuCustomizationModal(menu: product),
      );
    } else if (product.category == ProductCategory.pizza) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PizzaCustomizationModal(pizza: product),
      );
    } else {
      cartNotifier.addItem(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ajouté au panier !'),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Build placeholder when no products available
  Widget _buildPlaceholder(
    EdgeInsets padding,
    EdgeInsets margin,
    Color? backgroundColor,
    double borderRadius,
  ) {
    Widget placeholder = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade100,
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'No products available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );

    if (margin != EdgeInsets.zero) {
      placeholder = Padding(padding: margin, child: placeholder);
    }

    return placeholder;
  }

  /// Build loading placeholder
  Widget _buildLoadingPlaceholder(EdgeInsets padding, EdgeInsets margin) {
    Widget placeholder = Padding(
      padding: padding,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (margin != EdgeInsets.zero) {
      placeholder = Padding(padding: margin, child: placeholder);
    }

    return placeholder;
  }

  /// Build error placeholder
  Widget _buildErrorPlaceholder(
    EdgeInsets padding,
    EdgeInsets margin,
    Color? backgroundColor,
    double borderRadius,
  ) {
    Widget placeholder = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade100,
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            const Text(
              'Error loading products',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    if (margin != EdgeInsets.zero) {
      placeholder = Padding(padding: margin, child: placeholder);
    }

    return placeholder;
  }
}
