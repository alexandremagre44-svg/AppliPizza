// lib/src/widgets/page_renderer.dart
// Page renderer for B3 dynamic page architecture
// Builds Flutter widgets from PageSchema configurations

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/page_schema.dart';
import '../models/product.dart';
import '../services/data_source_resolver.dart';
import '../widgets/product_card.dart';
import 'dart:developer' as developer;

/// Widget that renders a page from a PageSchema
class PageRenderer extends StatefulWidget {
  final PageSchema pageSchema;

  const PageRenderer({
    Key? key,
    required this.pageSchema,
  }) : super(key: key);

  @override
  State<PageRenderer> createState() => _PageRendererState();
}

class _PageRendererState extends State<PageRenderer> {
  final DataSourceResolver _dataSourceResolver = DataSourceResolver();

  @override
  Widget build(BuildContext context) {
    // Sort blocks by order
    final sortedBlocks = List<WidgetBlock>.from(widget.pageSchema.blocks)
      ..sort((a, b) => a.order.compareTo(b.order));

    // Filter visible blocks
    final visibleBlocks = sortedBlocks.where((block) => block.visible).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageSchema.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: visibleBlocks.map((block) => _buildBlock(context, block)).toList(),
        ),
      ),
    );
  }

  /// Build a widget from a WidgetBlock
  Widget _buildBlock(BuildContext context, WidgetBlock block) {
    switch (block.type) {
      case WidgetBlockType.text:
        return _buildTextBlock(context, block);
      case WidgetBlockType.image:
        return _buildImageBlock(context, block);
      case WidgetBlockType.button:
        return _buildButtonBlock(context, block);
      case WidgetBlockType.banner:
        return _buildBannerBlock(context, block);
      case WidgetBlockType.productList:
        return _buildProductListBlock(context, block);
      case WidgetBlockType.categoryList:
        return _buildCategoryListBlock(context, block);
      case WidgetBlockType.heroAdvanced:
        return _buildHeroAdvancedBlock(context, block);
      case WidgetBlockType.carousel:
        return _buildCarouselBlock(context, block);
      case WidgetBlockType.custom:
      default:
        return _buildCustomBlock(context, block);
    }
  }

  /// Build a text block
  Widget _buildTextBlock(BuildContext context, WidgetBlock block) {
    final text = block.properties['text'] as String? ?? '';
    final fontSize = (block.properties['fontSize'] as num?)?.toDouble() ?? 16.0;
    final fontWeight = block.properties['bold'] == true ? FontWeight.bold : FontWeight.normal;
    final textAlign = _parseTextAlign(block.properties['align'] as String?);
    
    final color = _parseColor(block.styling?['color'] as String?);
    final padding = _parsePadding(block.styling?['padding']);

    return Padding(
      padding: padding,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
        textAlign: textAlign,
      ),
    );
  }

  /// Build an image block
  Widget _buildImageBlock(BuildContext context, WidgetBlock block) {
    final imageUrl = block.properties['url'] as String? ?? '';
    final height = (block.properties['height'] as num?)?.toDouble();
    final width = (block.properties['width'] as num?)?.toDouble();
    final fit = _parseBoxFit(block.properties['fit'] as String?);
    
    final padding = _parsePadding(block.styling?['padding']);

    if (imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height ?? 200,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 50),
            ),
          );
        },
      ),
    );
  }

  /// Build a button block
  Widget _buildButtonBlock(BuildContext context, WidgetBlock block) {
    final label = block.properties['label'] as String? ?? 'Button';
    final action = block.actions?['onTap'] as String?;
    
    final padding = _parsePadding(block.styling?['padding']);
    final backgroundColor = _parseColor(block.styling?['backgroundColor'] as String?);
    final textColor = _parseColor(block.styling?['textColor'] as String?);

    return Padding(
      padding: padding,
      child: ElevatedButton(
        onPressed: action != null ? () => _handleAction(context, action, block.actions) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
        ),
        child: Text(label),
      ),
    );
  }

  /// Build a banner block
  Widget _buildBannerBlock(BuildContext context, WidgetBlock block) {
    final text = block.properties['text'] as String? ?? '';
    final backgroundColor = _parseColor(block.styling?['backgroundColor'] as String?) ?? 
                           Theme.of(context).primaryColor;
    final textColor = _parseColor(block.styling?['textColor'] as String?) ?? Colors.white;
    final padding = _parsePadding(block.styling?['padding']);

    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: padding,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Build a product list block with real data
  Widget _buildProductListBlock(BuildContext context, WidgetBlock block) {
    developer.log('🔨 PageRenderer: Building product list block: ${block.id}');
    
    final title = block.properties['title'] as String? ?? 'Produits';
    final columns = (block.properties['columns'] as num?)?.toInt() ?? 2;
    final spacing = (block.properties['spacing'] as num?)?.toDouble() ?? 16.0;
    final showPrice = block.properties['showPrice'] as bool? ?? true;
    final padding = _parsePadding(block.styling?['padding']);

    // If no data source, show placeholder
    if (block.dataSource == null) {
      developer.log('⚠️ PageRenderer: No data source for product list block');
      return Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Aucune source de données configurée'),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          FutureBuilder<List<Product>>(
            future: _dataSourceResolver.resolveProducts(block.dataSource!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                developer.log('❌ PageRenderer: Error loading products: ${snapshot.error}');
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Erreur de chargement: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final products = snapshot.data ?? [];
              developer.log('✅ PageRenderer: Loaded ${products.length} products');

              if (products.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32.0),
                  child: const Center(
                    child: Text('Aucun produit disponible'),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(spacing / 2),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onAddToCart: () {
                      // Add to cart functionality (to be implemented)
                      developer.log('🛒 Add to cart: ${product.name}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} ajouté au panier'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build a category list block with real data
  Widget _buildCategoryListBlock(BuildContext context, WidgetBlock block) {
    developer.log('🔨 PageRenderer: Building category list block: ${block.id}');
    
    final title = block.properties['title'] as String? ?? 'Catégories';
    final padding = _parsePadding(block.styling?['padding']);

    // If no data source, show placeholder
    if (block.dataSource == null) {
      developer.log('⚠️ PageRenderer: No data source for category list block');
      return Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            Container(
              height: 150,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Aucune source de données configurée'),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          FutureBuilder<Map<ProductCategory, int>>(
            future: _dataSourceResolver.getCategoryCounts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                developer.log('❌ PageRenderer: Error loading categories: ${snapshot.error}');
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Erreur de chargement: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final categoryCounts = snapshot.data ?? {};
              developer.log('✅ PageRenderer: Loaded ${categoryCounts.length} categories');

              if (categoryCounts.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32.0),
                  child: const Center(
                    child: Text('Aucune catégorie disponible'),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: categoryCounts.length,
                itemBuilder: (context, index) {
                  final category = categoryCounts.keys.elementAt(index);
                  final count = categoryCounts[category] ?? 0;
                  
                  return _buildCategoryCard(context, category, count);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build a category card
  Widget _buildCategoryCard(BuildContext context, ProductCategory category, int count) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          developer.log('📂 Navigate to category: ${category.value}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Catégorie: ${category.value}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForCategory(category),
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                category.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '$count produit${count > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get icon for category
  IconData _getIconForCategory(ProductCategory category) {
    switch (category) {
      case ProductCategory.pizza:
        return Icons.local_pizza;
      case ProductCategory.menus:
        return Icons.menu_book;
      case ProductCategory.boissons:
        return Icons.local_drink;
      case ProductCategory.desserts:
        return Icons.cake;
    }
  }

  /// Build an advanced hero block (B3.5.A)
  Widget _buildHeroAdvancedBlock(BuildContext context, WidgetBlock block) {
    developer.log('🔨 PageRenderer: Building heroAdvanced block: ${block.id}');
    
    // Extract properties
    final imageUrl = block.properties['imageUrl'] as String? ?? '';
    final height = (block.properties['height'] as num?)?.toDouble() ?? 300.0;
    final borderRadius = (block.properties['borderRadius'] as num?)?.toDouble() ?? 0.0;
    final imageFit = block.properties['imageFit'] as String? ?? 'cover';
    
    // Overlay properties
    final overlayColor = _parseColor(block.properties['overlayColor'] as String?) ?? Colors.black;
    final overlayOpacity = (block.properties['overlayOpacity'] as num?)?.toDouble() ?? 0.4;
    
    // Gradient properties
    final hasGradient = block.properties['hasGradient'] == true;
    final gradientStartColor = _parseColor(block.properties['gradientStartColor'] as String?) ?? Colors.black;
    final gradientEndColor = _parseColor(block.properties['gradientEndColor'] as String?) ?? Colors.transparent;
    final gradientDirection = block.properties['gradientDirection'] as String? ?? 'vertical';
    
    // Content properties
    final title = block.properties['title'] as String? ?? '';
    final subtitle = block.properties['subtitle'] as String? ?? '';
    final titleColor = _parseColor(block.properties['titleColor'] as String?) ?? Colors.white;
    final subtitleColor = _parseColor(block.properties['subtitleColor'] as String?) ?? Colors.white70;
    final contentAlign = block.properties['contentAlign'] as String? ?? 'center';
    final spacing = (block.properties['spacing'] as num?)?.toDouble() ?? 8.0;
    
    // CTA buttons
    final ctas = (block.properties['ctas'] as List<dynamic>?) ?? [];
    
    // Note: Animation support to be implemented in future phase

    return Container(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: _parseBoxFit(imageFit),
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    ),
                  );
                },
              )
            else
              Container(color: Colors.grey[300]),
            
            // Overlay or gradient with opacity
            if (hasGradient)
              Opacity(
                opacity: overlayOpacity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: gradientDirection == 'vertical' ? Alignment.topCenter : Alignment.centerLeft,
                      end: gradientDirection == 'vertical' ? Alignment.bottomCenter : Alignment.centerRight,
                      colors: [gradientStartColor, gradientEndColor],
                    ),
                  ),
                ),
              )
            else
              Container(
                color: overlayColor.withOpacity(overlayOpacity),
              ),
            
            // Content (title, subtitle, CTAs)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: _parseMainAxisAlignment(contentAlign),
                  crossAxisAlignment: _parseCrossAxisAlignment(contentAlign),
                  children: [
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                        textAlign: _parseTextAlign(contentAlign),
                      ),
                    if (title.isNotEmpty && subtitle.isNotEmpty)
                      SizedBox(height: spacing),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 18,
                          color: subtitleColor,
                        ),
                        textAlign: _parseTextAlign(contentAlign),
                      ),
                    if (ctas.isNotEmpty && (title.isNotEmpty || subtitle.isNotEmpty))
                      SizedBox(height: spacing * 2),
                    if (ctas.isNotEmpty)
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: _parseWrapAlignment(contentAlign),
                        children: ctas.take(3).map((cta) => _buildCTAButton(context, cta)).toList(),
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

  /// Build a CTA button for hero block
  Widget _buildCTAButton(BuildContext context, dynamic cta) {
    if (cta is! Map<String, dynamic>) return const SizedBox.shrink();
    
    final label = cta['label'] as String? ?? 'Button';
    final action = cta['action'] as String? ?? '';
    final backgroundColor = _parseColor(cta['backgroundColor'] as String?) ?? Colors.blue;
    final textColor = _parseColor(cta['textColor'] as String?) ?? Colors.white;
    final borderRadius = (cta['borderRadius'] as num?)?.toDouble() ?? 8.0;
    final padding = (cta['padding'] as num?)?.toDouble() ?? 16.0;
    
    return ElevatedButton(
      onPressed: () {
        if (action.isNotEmpty) {
          _handleAction(context, action, null);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(label),
    );
  }

  /// Parse MainAxisAlignment from string
  MainAxisAlignment _parseMainAxisAlignment(String? align) {
    switch (align?.toLowerCase()) {
      case 'top':
      case 'start':
        return MainAxisAlignment.start;
      case 'bottom':
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
      default:
        return MainAxisAlignment.center;
    }
  }

  /// Parse CrossAxisAlignment from string
  CrossAxisAlignment _parseCrossAxisAlignment(String? align) {
    switch (align?.toLowerCase()) {
      case 'left':
      case 'start':
        return CrossAxisAlignment.start;
      case 'right':
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
      default:
        return CrossAxisAlignment.center;
    }
  }

  /// Parse WrapAlignment from string
  WrapAlignment _parseWrapAlignment(String? align) {
    switch (align?.toLowerCase()) {
      case 'left':
      case 'start':
        return WrapAlignment.start;
      case 'right':
      case 'end':
        return WrapAlignment.end;
      case 'center':
      default:
        return WrapAlignment.center;
    }
  }

  /// Build a carousel block (B3.5.B)
  Widget _buildCarouselBlock(BuildContext context, WidgetBlock block) {
    developer.log('📊 PageRenderer: Building carousel block ${block.id}');
    
    final carouselType = block.properties['carouselType'] as String? ?? 'images';
    final height = (block.properties['height'] as num?)?.toDouble() ?? 250.0;
    final viewportFraction = (block.properties['viewportFraction'] as num?)?.toDouble() ?? 0.85;
    final autoPlay = block.properties['autoPlay'] as bool? ?? false;
    final autoPlayIntervalMs = (block.properties['autoPlayIntervalMs'] as num?)?.toInt() ?? 3000;
    final enlargeCenterPage = block.properties['enlargeCenterPage'] as bool? ?? true;
    final showIndicators = block.properties['showIndicators'] as bool? ?? true;
    final indicatorColor = _parseColor(block.properties['indicatorColor'] as String?) ?? Colors.grey;
    final indicatorActiveColor = _parseColor(block.properties['indicatorActiveColor'] as String?) ?? Colors.blue;
    final padding = _parsePadding(block.styling?['padding']);
    final borderRadius = (block.properties['borderRadius'] as num?)?.toDouble() ?? 12.0;
    
    return Padding(
      padding: padding,
      child: _CarouselWidget(
        block: block,
        carouselType: carouselType,
        height: height,
        viewportFraction: viewportFraction,
        autoPlay: autoPlay,
        autoPlayIntervalMs: autoPlayIntervalMs,
        enlargeCenterPage: enlargeCenterPage,
        showIndicators: showIndicators,
        indicatorColor: indicatorColor,
        indicatorActiveColor: indicatorActiveColor,
        borderRadius: borderRadius,
        dataSourceResolver: _dataSourceResolver,
        onAction: (action) => _handleAction(context, action, null),
      ),
    );
  }

  /// Build a custom block (fallback)
  Widget _buildCustomBlock(BuildContext context, WidgetBlock block) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.amber[100],
      child: Text('Custom Block: ${block.id} (type: ${block.type.value})'),
    );
  }

  /// Handle button actions
  void _handleAction(BuildContext context, String action, Map<String, dynamic>? actionData) {
    // Parse action
    if (action.startsWith('navigate:')) {
      final route = action.substring('navigate:'.length);
      // Use GoRouter for consistency with the app's routing system
      try {
        // Try to use context.go (requires go_router package imported)
        // For now, using Navigator as fallback for compatibility
        Navigator.pushNamed(context, route);
      } catch (e) {
        // Fallback to Navigator if GoRouter context extension not available
        Navigator.pushNamed(context, route);
      }
    } else if (action == 'back') {
      Navigator.pop(context);
    }
    // Add more action types as needed
  }

  /// Parse color from hex string
  Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return null;
    
    try {
      if (colorStr.startsWith('#')) {
        final hexColor = colorStr.substring(1);
        if (hexColor.length == 6) {
          return Color(int.parse('FF$hexColor', radix: 16));
        } else if (hexColor.length == 8) {
          return Color(int.parse(hexColor, radix: 16));
        }
      }
    } catch (e) {
      // Invalid color format - log for debugging
      debugPrint('PageRenderer: Failed to parse color "$colorStr": $e');
    }
    return null;
  }

  /// Parse padding from various formats
  EdgeInsets _parsePadding(dynamic paddingData) {
    if (paddingData == null) {
      return const EdgeInsets.all(8.0);
    }

    if (paddingData is num) {
      return EdgeInsets.all(paddingData.toDouble());
    }

    if (paddingData is Map) {
      final top = (paddingData['top'] as num?)?.toDouble() ?? 8.0;
      final right = (paddingData['right'] as num?)?.toDouble() ?? 8.0;
      final bottom = (paddingData['bottom'] as num?)?.toDouble() ?? 8.0;
      final left = (paddingData['left'] as num?)?.toDouble() ?? 8.0;
      return EdgeInsets.fromLTRB(left, top, right, bottom);
    }

    return const EdgeInsets.all(8.0);
  }

  /// Parse TextAlign from string
  TextAlign _parseTextAlign(String? align) {
    switch (align?.toLowerCase()) {
      case 'left':
        return TextAlign.left;
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.start;
    }
  }

  /// Parse BoxFit from string
  BoxFit _parseBoxFit(String? fit) {
    switch (fit?.toLowerCase()) {
      case 'cover':
        return BoxFit.cover;
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitwidth':
        return BoxFit.fitWidth;
      case 'fitheight':
        return BoxFit.fitHeight;
      default:
        return BoxFit.cover;
    }
  }
}

/// Stateful widget for carousel with autoplay support
class _CarouselWidget extends StatefulWidget {
  final WidgetBlock block;
  final String carouselType;
  final double height;
  final double viewportFraction;
  final bool autoPlay;
  final int autoPlayIntervalMs;
  final bool enlargeCenterPage;
  final bool showIndicators;
  final Color indicatorColor;
  final Color indicatorActiveColor;
  final double borderRadius;
  final DataSourceResolver dataSourceResolver;
  final Function(String) onAction;

  const _CarouselWidget({
    Key? key,
    required this.block,
    required this.carouselType,
    required this.height,
    required this.viewportFraction,
    required this.autoPlay,
    required this.autoPlayIntervalMs,
    required this.enlargeCenterPage,
    required this.showIndicators,
    required this.indicatorColor,
    required this.indicatorActiveColor,
    required this.borderRadius,
    required this.dataSourceResolver,
    required this.onAction,
  }) : super(key: key);

  @override
  State<_CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<_CarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;
  List<dynamic> _slides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: 0,
    );
    _loadSlides();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSlides() async {
    try {
      if (widget.carouselType == 'images') {
        // Load slides from properties
        final slides = widget.block.properties['slides'] as List? ?? [];
        setState(() {
          _slides = slides;
          _isLoading = false;
        });
        _startAutoPlay();
      } else if (widget.carouselType == 'products' && widget.block.dataSource != null) {
        // Load products from DataSource
        final products = await widget.dataSourceResolver.resolveProducts(widget.block.dataSource!);
        developer.log('✅ CarouselWidget: Loaded ${products.length} products');
        setState(() {
          _slides = products;
          _isLoading = false;
        });
        _startAutoPlay();
      } else if (widget.carouselType == 'categories' && widget.block.dataSource != null) {
        // Load categories from DataSource
        final categories = await widget.dataSourceResolver.resolveCategories(widget.block.dataSource!);
        developer.log('✅ CarouselWidget: Loaded ${categories.length} categories');
        setState(() {
          _slides = categories.map((cat) => {'name': cat['name'], 'count': cat['count']}).toList();
          _isLoading = false;
        });
        _startAutoPlay();
      } else {
        // Fallback: empty slides
        setState(() {
          _slides = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('❌ CarouselWidget: Error loading slides: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startAutoPlay() {
    if (widget.autoPlay && _slides.isNotEmpty) {
      _autoPlayTimer = Timer.periodic(
        Duration(milliseconds: widget.autoPlayIntervalMs),
        (_) {
          if (_currentPage < _slides.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            _pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_slides.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: const Center(
          child: Text('No slides available'),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }

                  final scale = widget.enlargeCenterPage 
                      ? Curves.easeOut.transform(value)
                      : 1.0;

                  return Center(
                    child: SizedBox(
                      height: widget.height * scale,
                      child: child,
                    ),
                  );
                },
                child: _buildSlide(context, _slides[index], index),
              );
            },
          ),
        ),
        if (widget.showIndicators && _slides.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? widget.indicatorActiveColor
                      : widget.indicatorColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSlide(BuildContext context, dynamic slide, int index) {
    if (widget.carouselType == 'images') {
      return _buildImageSlide(context, slide);
    } else if (widget.carouselType == 'products') {
      return _buildProductSlide(context, slide as Product);
    } else if (widget.carouselType == 'categories') {
      return _buildCategorySlide(context, slide);
    }
    return Container();
  }

  Widget _buildImageSlide(BuildContext context, Map<String, dynamic> slide) {
    final imageUrl = slide['imageUrl'] as String? ?? '';
    final title = slide['title'] as String? ?? '';
    final subtitle = slide['subtitle'] as String? ?? '';
    final action = slide['action'] as String? ?? '';
    final overlayColor = _parseColor(slide['overlayColor'] as String?);
    final overlayOpacity = (slide['overlayOpacity'] as num?)?.toDouble() ?? 0.3;
    final useGradient = slide['useGradient'] as bool? ?? false;
    final gradientStartColor = _parseColor(slide['gradientStartColor'] as String?) ?? Colors.black;
    final gradientEndColor = _parseColor(slide['gradientEndColor'] as String?) ?? Colors.transparent;
    final gradientDirection = slide['gradientDirection'] as String? ?? 'vertical';

    return GestureDetector(
      onTap: () {
        if (action.isNotEmpty) {
          widget.onAction(action);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  );
                },
              ),
              
              // Overlay or gradient
              if (useGradient)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: gradientDirection == 'horizontal' ? Alignment.centerLeft : Alignment.topCenter,
                      end: gradientDirection == 'horizontal' ? Alignment.centerRight : Alignment.bottomCenter,
                      colors: [gradientStartColor, gradientEndColor],
                    ),
                  ),
                )
              else if (overlayColor != null)
                Container(
                  color: overlayColor.withOpacity(overlayOpacity),
                ),
              
              // Content
              if (title.isNotEmpty || subtitle.isNotEmpty)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSlide(BuildContext context, Product product) {
    final showPrice = widget.block.properties['showPrice'] as bool? ?? true;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ProductCard(product: product),
    );
  }

  Widget _buildCategorySlide(BuildContext context, Map<String, dynamic> category) {
    final name = category['name'] as String? ?? '';
    final count = category['count'] as int? ?? 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 48, color: Colors.blue[700]),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count produit${count != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return null;
    
    try {
      if (colorStr.startsWith('#')) {
        final hexColor = colorStr.substring(1);
        if (hexColor.length == 6) {
          return Color(int.parse('FF$hexColor', radix: 16));
        } else if (hexColor.length == 8) {
          return Color(int.parse(hexColor, radix: 16));
        }
      }
    } catch (e) {
      developer.log('Failed to parse color "$colorStr": $e');
    }
    return null;
  }
}
