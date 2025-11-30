// lib/builder/runtime/dynamic_builder_page_screen.dart
// Screen for displaying dynamic Builder pages via /page/:pageId route
// THEME INTEGRATION: Loads published theme and passes it to blocks via BuilderThemeProvider
//
// Uses new Firestore structure:
// restaurants/{restaurantId}/pages_published/{pageId}
//
// WHITE-LABEL FIX (November 2024):
// Client runtime now uses ONLY publishedLayout as the source of truth.
// draftLayout is NEVER used for client runtime - only for editor preview.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../models/theme_config.dart';
import '../services/dynamic_page_resolver.dart';
import '../services/theme_service.dart';
import '../../src/providers/restaurant_provider.dart';
import '../preview/builder_runtime_renderer.dart';
import 'builder_theme_resolver.dart';

/// Screen that displays a dynamic Builder page
/// 
/// Used for the /page/:pageId route to display any Builder page dynamically.
/// If the page doesn't exist, shows a "Page not found" message.
/// 
/// THEME INTEGRATION:
/// - Loads publishedTheme from Firestore for client runtime
/// - Wraps content with BuilderThemeProvider for context.builderTheme access
/// - Falls back to ThemeConfig.defaultConfig if no theme exists
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
    // Read appId from the restaurant provider
    final appId = ref.watch(currentRestaurantProvider).id;
    
    // Resolver instance - could be optimized with a provider if needed
    final resolver = DynamicPageResolver();
    final themeService = ThemeService();
    
    // Load both page and published theme in parallel
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        resolver.resolveByKey(pageKey, appId),
        themeService.loadPublishedTheme(appId),
      ]),
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
        
        // Extract results from Future.wait
        final results = snapshot.data;
        final builderPage = results?[0] as BuilderPage?;
        final publishedTheme = (results?[1] as ThemeConfig?) ?? ThemeConfig.defaultConfig;
        
        // If page exists, render it with published theme
        if (builderPage != null) {
          // Use systemId to get system page config (only for system pages)
          final systemConfig = builderPage.systemId != null 
              ? SystemPages.getConfig(builderPage.systemId!) 
              : null;
          
          // Use proper display name - prefer page name (if not generic), fallback to system default or pageKey
          final displayName = (builderPage.name.isNotEmpty && builderPage.name != 'Page')
              ? builderPage.name 
              : (systemConfig?.defaultName ?? builderPage.pageKey);
          
          // WHITE-LABEL FIX: Only use publishedLayout for client runtime
          // Never fall back to draftLayout - that's for editor preview only
          // Legacy 'blocks' field is only used as migration fallback
          final blocksToRender = builderPage.publishedLayout.isNotEmpty
              ? builderPage.publishedLayout
              : builderPage.blocks; // Legacy fallback only, never draftLayout
          
          // Check if we have any content to display
          final hasContent = blocksToRender.isNotEmpty;
          
          return Scaffold(
            appBar: AppBar(
              title: Text(displayName),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
            ),
            // THEME INTEGRATION: Wrap page content with BuilderThemeProvider
            body: BuilderThemeProvider(
              theme: publishedTheme,
              child: hasContent
                ? BuilderRuntimeRenderer(
                    blocks: blocksToRender,
                    wrapInScrollView: true,
                    // No need to pass themeConfig since BuilderThemeProvider provides it via context
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_off_outlined,
                            size: 80,
                            color: Colors.grey[400],
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
                            'Cette page n\'a pas encore été publiée.',
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
