// lib/builder/preview/builder_page_preview.dart
// Preview widget that renders a list of blocks visually
// MOBILE RESPONSIVE: Fixed sizing and zoom issues on mobile
// Enhanced with draftLayout support and module placeholders
//
// PREVIEW DATA SOURCES (Builder Studio):
// - Brouillon preview: uses pages_draft + draftLayout
// - Publié preview: uses pages_published + publishedLayout (same as client runtime)
//
// This ensures the "Publié" preview in Builder Studio shows exactly what the 
// client app renders, reading from the same collection and field.
//
// THEME INTEGRATION (Phase 1):
// - Accepts optional ThemeConfig for preview rendering
// - Wraps content with BuilderThemeProvider for consistent theming
// - Block previews can access theme via context.builderTheme

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/theme_config.dart';
import '../blocks/blocks.dart';
import '../utils/responsive.dart';
import '../utils/builder_modules.dart';
import '../runtime/builder_theme_resolver.dart';

/// Builder Page Preview Widget
/// 
/// Displays a visual preview of a page based on its blocks.
/// Now supports:
/// - draftLayout for editor preview
/// - Module placeholders for attached modules
/// - ThemeConfig for consistent styling across blocks
/// 
/// Usage:
/// ```dart
/// BuilderPagePreview(
///   blocks: page.draftLayout, 
///   modules: page.modules,
///   themeConfig: draftTheme, // Optional: for live theme preview
/// )
/// ```
class BuilderPagePreview extends StatelessWidget {
  final List<BuilderBlock> blocks;
  final List<String>? modules;
  final Color? backgroundColor;
  
  /// Optional theme configuration for preview
  /// 
  /// When provided, wraps the preview content with BuilderThemeProvider
  /// so that blocks can access theme values via context.builderTheme.
  /// If null, uses ThemeConfig.defaultConfig.
  final ThemeConfig? themeConfig;

  const BuilderPagePreview({
    super.key,
    required this.blocks,
    this.modules,
    this.backgroundColor,
    this.themeConfig,
  });

  @override
  Widget build(BuildContext context) {
    // Sort blocks by order
    final sortedBlocks = List<BuilderBlock>.from(blocks)
      ..sort((a, b) => a.order.compareTo(b.order));

    // Filter only active blocks
    final activeBlocks = sortedBlocks.where((b) => b.isActive).toList();

    // Check if we have any content
    final hasBlocks = activeBlocks.isNotEmpty;
    final hasModules = modules != null && modules!.isNotEmpty;

    if (!hasBlocks && !hasModules) {
      return _buildEmptyState();
    }

    // Resolve theme: use provided themeConfig or default
    final theme = themeConfig ?? ThemeConfig.defaultConfig;
    
    // Use theme background color if not explicitly overridden
    final effectiveBackgroundColor = backgroundColor ?? theme.backgroundColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = ResponsiveBuilder(constraints.maxWidth);
        
        // Wrap with BuilderThemeProvider for theme access in blocks
        return BuilderThemeProvider(
          theme: theme,
          child: Container(
            color: effectiveBackgroundColor,
            child: SingleChildScrollView(
              physics: responsive.isMobile 
                ? const ClampingScrollPhysics() 
                : const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: responsive.previewMaxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                    vertical: responsive.verticalPadding,
                  ),
                  child: Column(
                    children: [
                      // Render blocks with theme-based spacing
                      for (int i = 0; i < activeBlocks.length; i++) ...[
                        _buildBlock(activeBlocks[i]),
                        // Add spacing between blocks using theme
                        if (i < activeBlocks.length - 1)
                          SizedBox(height: theme.spacing),
                      ],
                      
                      // Render module placeholders
                      if (hasModules) ...[
                        SizedBox(height: theme.spacing),
                        ...modules!.map((moduleId) => _buildModulePlaceholder(moduleId)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlock(BuilderBlock block) {
    switch (block.type) {
      case BlockType.hero:
        return HeroBlockPreview(block: block);
      case BlockType.banner:
        return BannerBlockPreview(block: block);
      case BlockType.text:
        return TextBlockPreview(block: block);
      case BlockType.productList:
        return ProductListBlockPreview(block: block);
      case BlockType.info:
        return InfoBlockPreview(block: block);
      case BlockType.spacer:
        return SpacerBlockPreview(block: block);
      case BlockType.image:
        return ImageBlockPreview(block: block);
      case BlockType.button:
        return ButtonBlockPreview(block: block);
      case BlockType.categoryList:
        return CategoryListBlockPreview(block: block);
      case BlockType.html:
        return HtmlBlockPreview(block: block);
      case BlockType.system:
        return SystemBlockPreview(block: block);
    }
  }

  /// Build a placeholder for a module
  Widget _buildModulePlaceholder(String moduleId) {
    final config = getModuleConfig(moduleId);
    final name = config?.name ?? moduleId;
    final icon = _getModuleIcon(moduleId);
    final color = _getModuleColor(moduleId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Module: $name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ce module sera rendu au runtime',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Placeholder',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getModuleIcon(String moduleId) {
    switch (moduleId) {
      case 'menu_catalog':
        return Icons.restaurant_menu;
      case 'cart_module':
        return Icons.shopping_cart;
      case 'profile_module':
        return Icons.person;
      case 'roulette_module':
        return Icons.casino;
      default:
        return Icons.extension;
    }
  }

  Color _getModuleColor(String moduleId) {
    switch (moduleId) {
      case 'menu_catalog':
        return Colors.orange;
      case 'cart_module':
        return Colors.purple;
      case 'profile_module':
        return Colors.indigo;
      case 'roulette_module':
        return Colors.amber;
      default:
        return Colors.teal;
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun bloc à prévisualiser',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ajoutez des blocs pour voir la prévisualisation',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen preview dialog
class BuilderFullScreenPreview extends StatelessWidget {
  final List<BuilderBlock> blocks;
  final List<String>? modules;
  final String pageTitle;

  const BuilderFullScreenPreview({
    super.key,
    required this.blocks,
    this.modules,
    required this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prévisualisation: $pageTitle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: BuilderPagePreview(blocks: blocks, modules: modules),
    );
  }

  /// Show full-screen preview
  static void show(
    BuildContext context, {
    required List<BuilderBlock> blocks,
    List<String>? modules,
    required String pageTitle,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuilderFullScreenPreview(
          blocks: blocks,
          modules: modules,
          pageTitle: pageTitle,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
