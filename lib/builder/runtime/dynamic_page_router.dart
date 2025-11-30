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
/// RUNTIME FIX: publishedLayout is the ONLY source of truth for runtime display.
/// 
/// This function routes Builder pages to their runtime representations:
/// - If page has publishedLayout blocks → render with BuilderRuntimeRenderer
/// - Fallback to draftLayout if publishedLayout is empty (editor preview mode)
/// - Fallback to blocks (LEGACY) if draftLayout is also empty (backward compatibility only)
/// - For system pages with no blocks → render default module (menu_catalog, cart_module, etc.)
/// - If page is empty and not a system page → show "Page vide / non configurée" message
/// 
/// IMPORTANT: The "blocks" field is DEPRECATED and maintained only for migration.
/// New code should NEVER write to "blocks", only to draftLayout/publishedLayout.
/// 
/// Example:
/// ```dart
/// final widget = buildPageFromBuilder(builderPage);
/// ```
Widget buildPageFromBuilder(BuildContext context, BuilderPage page) {
  // RUNTIME FIX: Determine which layout to render 
  // Priority: publishedLayout (runtime) → draftLayout (preview) → blocks (legacy migration only)
  List<BuilderBlock> blocksToRender = [];
  
  if (page.publishedLayout.isNotEmpty) {
    blocksToRender = page.publishedLayout;
    debugPrint('📄 [PageRouter] ${page.pageKey}: using publishedLayout (${blocksToRender.length} blocks)');
  } else if (page.draftLayout.isNotEmpty) {
    blocksToRender = page.draftLayout;
    debugPrint('📄 [PageRouter] ${page.pageKey}: using draftLayout fallback (${blocksToRender.length} blocks)');
  } else if (page.blocks.isNotEmpty) {
    // LEGACY FALLBACK: Only used for old data that hasn't been migrated yet
    blocksToRender = page.blocks;
    debugPrint('⚠️ [PageRouter] ${page.pageKey}: using LEGACY blocks fallback (${blocksToRender.length} blocks) - migration needed');
  }
  
  // Render blocks if we have any
  if (blocksToRender.isNotEmpty) {
    return BuilderRuntimeRenderer(
      blocks: blocksToRender,
      wrapInScrollView: true,
    );
  }
  
  // No blocks found - check if we can use a system module fallback (only for system pages)
  if (page.systemId != null) {
    final systemModuleFallback = _getSystemModuleFallback(page.systemId!);
    if (systemModuleFallback != null) {
      debugPrint('📄 [PageRouter] ${page.pageKey}: no blocks, using system module fallback');
      return builder_modules.renderModule(context, systemModuleFallback);
    }
  }
  
  // No content - show empty state
  debugPrint('📄 [PageRouter] ${page.pageKey}: no blocks found, showing empty state');
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
