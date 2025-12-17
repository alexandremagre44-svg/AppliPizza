// MIGRATED to WL V2 Theme - Uses theme colors
// lib/builder/runtime/dynamic_page_router.dart
// Dynamic page router for Builder B3 system
// 
// Routes pages from Builder to runtime widgets
// Handles modules (cart_module, menu_catalog, profile_module, roulette_module)
// and dynamic layouts (publishedLayout blocks)
//
// WHITE-LABEL FIX (November 2024):
// Client runtime now uses ONLY publishedLayout as the source of truth.
// draftLayout is NEVER used for client runtime - only for editor preview.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../preview/builder_runtime_renderer.dart';
import '../utils/builder_modules.dart' as builder_modules;

/// Build a page from a BuilderPage configuration
/// 
/// WHITE-LABEL FIX: publishedLayout is the ONLY source of truth for client runtime.
/// 
/// This function routes Builder pages to their runtime representations:
/// - If page has publishedLayout blocks → render with BuilderRuntimeRenderer
/// - If publishedLayout is empty → use legacy blocks field as migration fallback
/// - NEVER uses draftLayout for client runtime (draft is for editor only)
/// - For system pages with no published content → render default module
/// - If page is empty and not a system page → show "Page non publiée" message
/// 
/// IMPORTANT: 
/// - The "blocks" field is DEPRECATED and used only as migration fallback
/// - The "draftLayout" field is NEVER used here - only in editor preview
/// - New pages must be published to be visible to clients
/// 
/// Example:
/// ```dart
/// final widget = buildPageFromBuilder(builderPage);
/// ```
Widget buildPageFromBuilder(BuildContext context, BuilderPage page) {
  // WHITE-LABEL FIX: Only use publishedLayout for client runtime
  // Never fall back to draftLayout - that's for editor preview only
  List<BuilderBlock> blocksToRender = [];
  
  if (page.publishedLayout.isNotEmpty) {
    // Primary source: publishedLayout (the only correct source for runtime)
    blocksToRender = page.publishedLayout;
    debugPrint('📄 [PageRouter] ${page.pageKey}: using publishedLayout (${blocksToRender.length} blocks)');
  } else if (page.blocks.isNotEmpty) {
    // LEGACY MIGRATION FALLBACK: Only used for old data that hasn't been migrated
    // This is the ONLY fallback - we never use draftLayout for runtime
    blocksToRender = page.blocks;
    debugPrint('⚠️ [PageRouter] ${page.pageKey}: using LEGACY blocks fallback (${blocksToRender.length} blocks) - page needs to be published');
  } else {
    // No published content - log clearly for debugging
    debugPrint('⚠️ [PageRouter] ${page.pageKey}: no publishedLayout - page has not been published yet');
  }
  
  // Render blocks if we have any
  if (blocksToRender.isNotEmpty) {
    return BuilderRuntimeRenderer(
      blocks: blocksToRender,
      wrapInScrollView: true,
    );
  }
  
  // No published blocks found - check if we can use a system module fallback (only for system pages)
  if (page.systemId != null) {
    final systemModuleFallback = _getSystemModuleFallback(page.systemId!);
    if (systemModuleFallback != null) {
      debugPrint('📄 [PageRouter] ${page.pageKey}: no published blocks, using system module fallback');
      return builder_modules.renderModule(context, systemModuleFallback);
    }
  }
  
  // No content - show "not published" state for client
  debugPrint('📄 [PageRouter] ${page.pageKey}: showing "not published" state');
  return _buildNotPublishedState(context, page.name);
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

/// Build "not published" state when page has no published content
/// 
/// WHITE-LABEL FIX: This is shown when publishedLayout is empty.
/// The page exists but needs to be published before clients can see it.
Widget _buildNotPublishedState(BuildContext context, String pageName) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_off_outlined,
            size: 80,
            color: context.colorScheme.surfaceVariant // was Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Page non publiée',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'La page "$pageName" n\'a pas encore été publiée.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: context.colorScheme.surfaceVariant // was Colors.grey[600],
            ),
          ),
        ],
      ),
    ),
  );
}
