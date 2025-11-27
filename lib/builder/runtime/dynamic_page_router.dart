// lib/builder/runtime/dynamic_page_router.dart
// Dynamic page router for Builder B3 system
// 
// Routes pages from Builder to runtime widgets
// Handles modules (cart_module, menu_catalog, profile_module, roulette_module)
// and dynamic layouts (publishedLayout blocks)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../preview/builder_runtime_renderer.dart';
import '../utils/builder_modules.dart' as builder_modules;

/// Build a page from a BuilderPage configuration
/// 
/// This function routes Builder pages to their runtime representations:
/// - If page has publishedLayout blocks → render with BuilderRuntimeRenderer
/// - Fallback to draftLayout if publishedLayout is empty
/// - Fallback to blocks (legacy) if draftLayout is also empty
/// - For system pages with no blocks → render default module (menu_catalog, cart_module, etc.)
/// - If page is empty and not a system page → show "Page vide / non configurée" message
/// 
/// Example:
/// ```dart
/// final widget = buildPageFromBuilder(builderPage);
/// ```
Widget buildPageFromBuilder(BuildContext context, BuilderPage page) {
  // Determine which layout to render (priority: published > draft > blocks legacy)
  List<BuilderBlock> blocksToRender = [];
  
  if (page.publishedLayout.isNotEmpty) {
    blocksToRender = page.publishedLayout;
    debugPrint('📄 [PageRouter] ${page.pageId.value}: using publishedLayout (${blocksToRender.length} blocks)');
  } else if (page.draftLayout.isNotEmpty) {
    blocksToRender = page.draftLayout;
    debugPrint('📄 [PageRouter] ${page.pageId.value}: using draftLayout fallback (${blocksToRender.length} blocks)');
  } else if (page.blocks.isNotEmpty) {
    blocksToRender = page.blocks;
    debugPrint('📄 [PageRouter] ${page.pageId.value}: using blocks legacy fallback (${blocksToRender.length} blocks)');
  }
  
  // Render blocks if we have any
  if (blocksToRender.isNotEmpty) {
    return BuilderRuntimeRenderer(
      blocks: blocksToRender,
      wrapInScrollView: true,
    );
  }
  
  // No blocks found - check if we can use a system module fallback
  final systemModuleFallback = _getSystemModuleFallback(page.pageId);
  if (systemModuleFallback != null) {
    debugPrint('📄 [PageRouter] ${page.pageId.value}: no blocks, using system module fallback');
    return builder_modules.renderModule(context, systemModuleFallback);
  }
  
  // No content - show empty state
  debugPrint('📄 [PageRouter] ${page.pageId.value}: no blocks found, showing empty state');
  return _buildEmptyPageState(context, page.name);
}

/// Get the default module ID for system pages
/// 
/// Returns the module that should be rendered when a system page has no blocks.
/// This ensures system pages always have content even if the Builder page is empty.
String? _getSystemModuleFallback(BuilderPageId pageId) {
  switch (pageId) {
    case BuilderPageId.menu:
      return 'menu_catalog';
    case BuilderPageId.cart:
      return 'cart_module';
    case BuilderPageId.profile:
      return 'profile_module';
    case BuilderPageId.roulette:
      return 'roulette_module';
    default:
      return null; // Non-system pages don't have a fallback
  }
}

/// Build empty page state when page has no content
Widget _buildEmptyPageState(BuildContext context, String pageName) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Page vide',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'La page "$pageName" n\'a pas encore de contenu publié.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ),
  );
}
