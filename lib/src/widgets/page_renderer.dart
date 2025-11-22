// lib/src/widgets/page_renderer.dart
// Page renderer for B3 dynamic page architecture
// Builds Flutter widgets from PageSchema configurations

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final Map<String, bool> _popupShownState = {}; // Track which popups have been shown
  Timer? _delayedPopupTimer;
  WidgetBlock? _stickyCta; // Track sticky CTA block

  @override
  void initState() {
    super.initState();
    _initializePopups();
  }

  @override
  void dispose() {
    _delayedPopupTimer?.cancel();
    super.dispose();
  }

  /// Initialize popups with triggers
  Future<void> _initializePopups() async {
    final sortedBlocks = List<WidgetBlock>.from(widget.pageSchema.blocks)
      ..sort((a, b) => a.order.compareTo(b.order));
    
    final popupBlocks = sortedBlocks.where((block) => 
      block.visible && block.type == WidgetBlockType.popup
    ).toList();

    for (final popup in popupBlocks) {
      final showOnLoad = popup.properties['showOnLoad'] as bool? ?? true;
      final triggerType = popup.properties['triggerType'] as String? ?? 'onLoad';
      final delayMs = popup.properties['delayMs'] as int? ?? 0;
      final showOncePerSession = popup.properties['showOncePerSession'] as bool? ?? false;

      // Check if popup should be shown based on session storage
      if (showOncePerSession) {
        final prefs = await SharedPreferences.getInstance();
        final key = 'popup_shown_${popup.id}';
        final hasShown = prefs.getBool(key) ?? false;
        if (hasShown) {
          continue; // Skip this popup
        }
      }

      // Handle different trigger types
      if (showOnLoad && triggerType == 'onLoad') {
        if (delayMs > 0) {
          _delayedPopupTimer = Timer(Duration(milliseconds: delayMs), () {
            if (mounted) {
              _showPopup(context, popup);
            }
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showPopup(context, popup);
            }
          });
        }
      } else if (triggerType == 'delayed' && delayMs > 0) {
        _delayedPopupTimer = Timer(Duration(milliseconds: delayMs), () {
          if (mounted) {
            _showPopup(context, popup);
          }
        });
      }
    }
  }

  /// Show a popup dialog
  Future<void> _showPopup(BuildContext context, WidgetBlock popupBlock) async {
    // Mark as shown in state
    if (_popupShownState[popupBlock.id] == true) {
      return; // Already shown
    }
    _popupShownState[popupBlock.id] = true;

    // Mark as shown in persistent storage if needed
    final showOncePerSession = popupBlock.properties['showOncePerSession'] as bool? ?? false;
    if (showOncePerSession) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('popup_shown_${popupBlock.id}', true);
    }

    final dismissibleByTapOutside = popupBlock.properties['dismissibleByTapOutside'] as bool? ?? true;
    final overlayColor = _parseColor(popupBlock.properties['overlayColor'] as String?) ?? Colors.black;
    final overlayOpacity = (popupBlock.properties['overlayOpacity'] as num?)?.toDouble() ?? 0.5;

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: dismissibleByTapOutside,
      barrierColor: overlayColor.withOpacity(overlayOpacity),
      builder: (BuildContext dialogContext) {
        return _buildPopupContent(dialogContext, popupBlock);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort blocks by order
    final sortedBlocks = List<WidgetBlock>.from(widget.pageSchema.blocks)
      ..sort((a, b) => a.order.compareTo(b.order));

    // Filter visible blocks (exclude popups and sticky CTAs as they're rendered separately)
    final visibleBlocks = sortedBlocks.where((block) => 
      block.visible && 
      block.type != WidgetBlockType.popup &&
      block.type != WidgetBlockType.stickyCta
    ).toList();

    // Find sticky CTA block (if any)
    _stickyCta = sortedBlocks
        .where((block) => block.visible && block.type == WidgetBlockType.stickyCta)
        .toList()
        .lastOrNull; // Use the last one if multiple exist

    final mainContent = Scaffold(
      appBar: AppBar(
        title: Text(widget.pageSchema.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: visibleBlocks.map((block) => _buildBlock(context, block)).toList(),
        ),
      ),
    );

    // Wrap with Stack if sticky CTA exists
    if (_stickyCta != null) {
      return Stack(
        children: [
          mainContent,
          _buildStickyCta(context, _stickyCta!),
        ],
      );
    }

    return mainContent;
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
      case WidgetBlockType.productSlider:
        return _buildProductSliderBlock(context, block);
      case WidgetBlockType.categorySlider:
        return _buildCategorySliderBlock(context, block);
      case WidgetBlockType.promoBanner:
        return _buildPromoBannerBlock(context, block);
      case WidgetBlockType.stickyCta:
        // Sticky CTAs are handled separately in build(), return empty container
        return const SizedBox.shrink();
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
          _slides = categories.map((cat) => {'name': cat.value, 'count': 0}).toList();
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
      child: ProductCard(
        product: product,
        onAddToCart: () {
          // TODO: Implement add to cart functionality
          developer.log('Add to cart: ${product.name}');
        },
      ),
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

  /// Build popup dialog content
  Widget _buildPopupContent(BuildContext context, WidgetBlock block) {
    final title = block.properties['title'] as String? ?? '';
    final message = block.properties['message'] as String? ?? '';
    final titleColor = _parseColor(block.properties['titleColor'] as String?) ?? Colors.black;
    final messageColor = _parseColor(block.properties['messageColor'] as String?) ?? Colors.grey[700];
    final alignment = block.properties['alignment'] as String? ?? 'center';
    final icon = block.properties['icon'] as String?;
    
    final backgroundColor = _parseColor(block.properties['backgroundColor'] as String?) ?? Colors.white;
    final borderRadius = (block.properties['borderRadius'] as num?)?.toDouble() ?? 16.0;
    final padding = (block.properties['padding'] as num?)?.toDouble() ?? 20.0;
    final maxWidth = (block.properties['maxWidth'] as num?)?.toDouble() ?? 300.0;
    final elevation = (block.properties['elevation'] as num?)?.toDouble() ?? 8.0;

    // Parse CTAs
    final ctas = (block.properties['ctas'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: elevation,
              offset: Offset(0, elevation / 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: alignment == 'start' 
            ? CrossAxisAlignment.start 
            : CrossAxisAlignment.center,
          children: [
            // Icon
            if (icon != null && icon.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildPopupIcon(icon),
              ),
            
            // Title
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                  textAlign: alignment == 'start' ? TextAlign.left : TextAlign.center,
                ),
              ),
            
            // Message
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: messageColor,
                  ),
                  textAlign: alignment == 'start' ? TextAlign.left : TextAlign.center,
                ),
              ),
            
            // CTAs
            if (ctas.isNotEmpty)
              ...ctas.map((cta) => _buildPopupCTA(context, cta)).toList(),
          ],
        ),
      ),
    );
  }

  /// Build popup icon
  Widget _buildPopupIcon(String iconType) {
    IconData iconData;
    Color iconColor;

    switch (iconType.toLowerCase()) {
      case 'info':
        iconData = Icons.info_outline;
        iconColor = Colors.blue;
        break;
      case 'warning':
        iconData = Icons.warning_amber_outlined;
        iconColor = Colors.orange;
        break;
      case 'promo':
        iconData = Icons.local_offer_outlined;
        iconColor = Colors.green;
        break;
      case 'success':
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case 'error':
        iconData = Icons.error_outline;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.notifications_outlined;
        iconColor = Colors.blue;
    }

    return Icon(
      iconData,
      size: 48,
      color: iconColor,
    );
  }

  /// Build popup CTA button
  Widget _buildPopupCTA(BuildContext context, Map<String, dynamic> cta) {
    final label = cta['label'] as String? ?? 'OK';
    final action = cta['action'] as String? ?? 'dismissOnly';
    final bgColor = _parseColor(cta['backgroundColor'] as String?) ?? Colors.blue;
    final textColor = _parseColor(cta['textColor'] as String?) ?? Colors.white;
    final borderRadius = (cta['borderRadius'] as num?)?.toDouble() ?? 8.0;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Always dismiss the popup
            
            // Handle additional actions
            if (action.startsWith('navigate:')) {
              final route = action.substring('navigate:'.length);
              Navigator.of(context).pushNamed(route);
            } else if (action.startsWith('openUrl:')) {
              // TODO: Implement URL opening if needed
              developer.log('Open URL action: $action');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Build product slider block (B3.5.D.1)
  Widget _buildProductSliderBlock(BuildContext context, WidgetBlock block) {
    final title = block.properties['title'] as String?;
    final showTitle = block.properties['showTitle'] as bool? ?? true;
    final itemWidth = (block.properties['itemWidth'] as num?)?.toDouble() ?? 180.0;
    final itemHeight = (block.properties['itemHeight'] as num?)?.toDouble() ?? 280.0;
    final spacing = (block.properties['spacing'] as num?)?.toDouble() ?? 12.0;
    final showPrice = block.properties['showPrice'] as bool? ?? true;
    final limit = block.properties['limit'] as int? ?? 10;

    developer.log('🎯 Building product slider block');

    return FutureBuilder<List<Product>>(
      future: _dataSourceResolver.resolveProducts(block.dataSource),
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading products: ${snapshot.error}'),
            ),
          );
        }

        final products = (snapshot.data ?? []).take(limit).toList();

        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No products found'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle && title != null && title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(
              height: itemHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                separatorBuilder: (context, index) => SizedBox(width: spacing),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SizedBox(
                    width: itemWidth,
                    child: ProductCard(
                      product: product,
                      onAddToCart: () {
                        // TODO: Implement add to cart functionality
                        developer.log('Add to cart: ${product.name}');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build category slider block (B3.5.D.2)
  Widget _buildCategorySliderBlock(BuildContext context, WidgetBlock block) {
    final title = block.properties['title'] as String?;
    final itemWidth = (block.properties['itemWidth'] as num?)?.toDouble() ?? 120.0;
    final itemHeight = (block.properties['itemHeight'] as num?)?.toDouble() ?? 140.0;
    final spacing = (block.properties['spacing'] as num?)?.toDouble() ?? 12.0;
    final limit = block.properties['limit'] as int? ?? 10;

    developer.log('🎯 Building category slider block');

    return FutureBuilder<List<ProductCategory>>(
      future: _dataSourceResolver.resolveCategories(block.dataSource),
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading categories: ${snapshot.error}'),
            ),
          );
        }

        final categories = snapshot.data ?? [];
        final categoryList = categories.take(limit).toList();

        if (categoryList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No categories found'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(
              height: itemHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categoryList.length,
                separatorBuilder: (context, index) => SizedBox(width: spacing),
                itemBuilder: (context, index) {
                  final category = categoryList[index];
                  return SizedBox(
                    width: itemWidth,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Navigate to category
                          developer.log('Open category: ${category.value}');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category,
                                size: 48,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build promo banner block (B3.5.D.3)
  Widget _buildPromoBannerBlock(BuildContext context, WidgetBlock block) {
    final title = block.properties['title'] as String? ?? '';
    final subtitle = block.properties['subtitle'] as String? ?? '';
    final backgroundColor = _parseColor(block.properties['backgroundColor'] as String?) ?? Colors.red;
    final textColor = _parseColor(block.properties['textColor'] as String?) ?? Colors.white;
    final imageUrl = block.properties['imageUrl'] as String?;
    final borderRadius = (block.properties['borderRadius'] as num?)?.toDouble() ?? 12.0;
    final padding = (block.properties['padding'] as num?)?.toDouble() ?? 16.0;
    final ctaLabel = block.properties['ctaLabel'] as String?;
    final ctaAction = block.properties['ctaAction'] as String?;

    // Display conditions (for future implementation)
    final displayCondition = block.properties['displayCondition'] as Map<String, dynamic>?;
    final activeOnly = displayCondition?['activeOnly'] as bool? ?? false;
    
    // TODO: Implement display conditions logic
    // For now, always show if activeOnly is false

    developer.log('🎯 Building promo banner block');

    return Container(
      margin: EdgeInsets.all(padding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.3,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_offer,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title.isNotEmpty)
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (ctaLabel != null && ctaLabel.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          if (ctaAction != null) {
                            if (ctaAction.startsWith('navigate:')) {
                              final route = ctaAction.substring('navigate:'.length);
                              Navigator.of(context).pushNamed(route);
                            } else if (ctaAction.startsWith('openUrl:')) {
                              developer.log('Open URL: $ctaAction');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: textColor,
                          foregroundColor: backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          ctaLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build sticky CTA block (B3.5.D.4)
  Widget _buildStickyCta(BuildContext context, WidgetBlock block) {
    final label = block.properties['label'] as String? ?? 'Action';
    final iconName = block.properties['icon'] as String?;
    final backgroundColor = _parseColor(block.properties['backgroundColor'] as String?) ?? Colors.blue;
    final textColor = _parseColor(block.properties['textColor'] as String?) ?? Colors.white;
    final borderRadius = (block.properties['borderRadius'] as num?)?.toDouble() ?? 24.0;
    final padding = (block.properties['padding'] as num?)?.toDouble() ?? 16.0;
    final position = block.properties['position'] as String? ?? 'bottom';
    final action = block.properties['action'] as Map<String, dynamic>?;
    final behavior = block.properties['behavior'] as Map<String, dynamic>?;
    final elevation = (behavior?['elevation'] as num?)?.toDouble() ?? 4.0;

    // TODO: Implement scroll behaviors (showOnScrollUp, hideOnScrollDown)
    // TODO: Implement conditional display (showIfCartNotEmpty, showIfCategory)
    // For now, always show

    IconData? icon;
    if (iconName != null) {
      switch (iconName) {
        case 'shopping_cart':
          icon = Icons.shopping_cart;
          break;
        case 'local_pizza':
          icon = Icons.local_pizza;
          break;
        case 'arrow_forward':
          icon = Icons.arrow_forward;
          break;
        case 'info':
          icon = Icons.info;
          break;
        default:
          icon = Icons.touch_app;
      }
    }

    developer.log('🎯 Building sticky CTA block at $position');

    return Positioned(
      bottom: position == 'bottom' ? 16 : null,
      top: position == 'top' ? 16 : null,
      left: 16,
      right: 16,
      child: Material(
        elevation: elevation,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: () {
            if (action != null) {
              final actionType = action['type'] as String?;
              if (actionType == 'navigate') {
                final route = action['route'] as String?;
                if (route != null) {
                  Navigator.of(context).pushNamed(route);
                }
              } else if (actionType == 'openProduct') {
                final productId = action['productId'] as String?;
                developer.log('Open product: $productId');
              } else if (actionType == 'openCategory') {
                final categoryId = action['categoryId'] as String?;
                developer.log('Open category: $categoryId');
              } else if (actionType == 'openUrl') {
                final url = action['url'] as String?;
                developer.log('Open URL: $url');
              }
            }
          },
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 24),
                  const SizedBox(width: 12),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
