// lib/builder/runtime/dynamic_builder_page_screen.dart
// Screen for displaying dynamic Builder pages via /page/:pageId route
//
// Uses new Firestore structure:
// restaurants/{restaurantId}/pages_published/{pageId}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/dynamic_page_resolver.dart';
import '../../src/core/firestore_paths.dart';
import '../preview/builder_runtime_renderer.dart';

/// Screen that displays a dynamic Builder page
/// 
/// Used for the /page/:pageId route to display any Builder page dynamically.
/// If the page doesn't exist, shows a "Page not found" message.
/// 
/// Example route: /page/promo-du-jour
class DynamicBuilderPageScreen extends ConsumerWidget {
  final String pageKey;
  
  const DynamicBuilderPageScreen({
    super.key,
    required this.pageKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use kRestaurantId from FirestorePaths for consistent restaurant scoping
    final appId = kRestaurantId;
    
    // Resolver instance - could be optimized with a provider if needed
    final resolver = DynamicPageResolver();
    
    return FutureBuilder<BuilderPage?>(
      future: resolver.resolveByKey(pageKey, appId),
      builder: (context, snapshot) {
        // Show loading indicator while fetching
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Chargement...'),
            ),
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
        
        // If page exists, render it
        if (snapshot.hasData && snapshot.data != null) {
          final builderPage = snapshot.data!;
          
          // Try to get system page config for proper naming
          final systemConfig = SystemPages.getConfigByFirestoreId(pageKey);
          
          // Use proper display name - prefer page name (if not generic), fallback to system default
          final displayName = (builderPage.name.isNotEmpty && builderPage.name != 'Page')
              ? builderPage.name 
              : (systemConfig?.defaultName ?? 'Page');
          
          // Check if the page has content (published layout, draft layout, or legacy blocks)
          // IMPORTANT: Check all possible sources of content
          final hasContent = builderPage.publishedLayout.isNotEmpty || 
                            builderPage.draftLayout.isNotEmpty ||
                            builderPage.blocks.isNotEmpty;
          
          // Select content to display - prefer published, then draft, then legacy blocks
          final blocksToRender = builderPage.publishedLayout.isNotEmpty
              ? builderPage.publishedLayout
              : (builderPage.draftLayout.isNotEmpty 
                  ? builderPage.draftLayout 
                  : builderPage.blocks);
          
          return Scaffold(
            appBar: AppBar(
              title: Text(displayName),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
            ),
            body: hasContent
              ? BuilderRuntimeRenderer(
                  blocks: blocksToRender,
                  wrapInScrollView: true,
                )
              : Center(
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
                          'Aucun contenu configuré',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Cette page n\'a pas encore de contenu publié.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          );
        }
        
        // Page not found
        return Scaffold(
          appBar: AppBar(
            title: const Text('Page introuvable'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Page introuvable',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'La page "$pageKey" n\'existe pas ou n\'a pas été publiée.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
