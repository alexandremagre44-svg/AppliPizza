// lib/builder/runtime/dynamic_page_router.dart
// Dynamic page router for Builder B3 system
// 
// Routes pages from Builder to runtime widgets
// Handles modules (cart_module, menu_catalog, profile_module, roulette_module)
// and dynamic layouts (publishedLayout blocks)

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../preview/builder_runtime_renderer.dart';
import '../utils/builder_modules.dart' as builder_modules;

/// Build a page from a BuilderPage configuration
/// 
/// This function routes Builder pages to their runtime representations:
/// - If page has publishedLayout blocks → render with BuilderRuntimeRenderer
/// - If page has SystemBlock modules → render via builder_modules
/// - If page is empty → show "Page vide / non configurée" message
/// 
/// Example:
/// ```dart
/// final widget = buildPageFromBuilder(builderPage);
/// ```
Widget buildPageFromBuilder(BuildContext context, BuilderPage page) {
  // Check if page has published content
  final hasPublishedContent = page.publishedLayout.isNotEmpty;
  
  if (hasPublishedContent) {
    // Render page with BuilderRuntimeRenderer
    return BuilderRuntimeRenderer(
      blocks: page.publishedLayout,
      wrapInScrollView: true,
    );
  }
  
  // Check if page has a single module block (common for system pages)
  if (page.publishedLayout.length == 1 && 
      page.publishedLayout.first.type == BlockType.system) {
    final moduleType = page.publishedLayout.first.getConfig<String>('moduleType', '');
    if (moduleType != null && moduleType.isNotEmpty) {
      // Render module directly
      return builder_modules.renderModule(context, moduleType);
    }
  }
  
  // No content - show empty state
  return _buildEmptyPageState(context, page.name);
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
