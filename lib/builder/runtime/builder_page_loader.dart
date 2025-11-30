// lib/builder/runtime/builder_page_loader.dart
// Widget that loads Builder pages with fallback to legacy screens
//
// Uses new Firestore structure:
// restaurants/{restaurantId}/pages_published/{pageId}
//
// THEME INTEGRATION (Phase 2):
// - Loads publishedTheme for client runtime
// - Wraps content with BuilderThemeProvider
// - Block runtimes access theme via context.builderTheme

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../models/theme_config.dart';
import '../services/dynamic_page_resolver.dart';
import '../services/theme_service.dart';
import '../../src/providers/restaurant_provider.dart';
import '../preview/builder_runtime_renderer.dart';
import 'dynamic_page_router.dart';
import 'builder_theme_resolver.dart';

/// Widget that loads a Builder page with fallback to legacy screen
/// 
/// This widget attempts to load a BuilderPage from Firestore.
/// If the page exists, it renders it using BuilderRuntimeRenderer.
/// If not, it displays the provided fallback widget.
/// 
/// THEME INTEGRATION:
/// - Loads the publishedTheme from Firestore
/// - Wraps content with BuilderThemeProvider
/// - Block runtimes can access theme via context.builderTheme
/// 
/// This enables a smooth transition from legacy screens to Builder-driven pages
/// without breaking existing functionality.
/// 
/// Example:
/// ```dart
/// BuilderPageLoader(
///   pageId: BuilderPageId.home,
///   fallback: HomeScreen(),
/// )
/// ```
class BuilderPageLoader extends ConsumerWidget {
  final BuilderPageId pageId;
  final Widget fallback;
  final Color? backgroundColor;
  
  const BuilderPageLoader({
    super.key,
    required this.pageId,
    required this.fallback,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read appId from the restaurant provider
    final appId = ref.watch(currentRestaurantProvider).id;
    
    // Resolver instance - could be optimized with a provider if needed
    final resolver = DynamicPageResolver();
    final themeService = ThemeService();
    
    return FutureBuilder<BuilderPage?>(
      future: resolver.resolve(pageId, appId),
      builder: (context, snapshot) {
        // Show loading indicator while fetching
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
        
        // If Builder page exists and is enabled, render it
        if (snapshot.hasData && snapshot.data != null) {
          final builderPage = snapshot.data!;
          
          // Get system page config for proper naming and icons
          final systemConfig = SystemPages.getConfig(pageId);
          
          // Ensure page has proper name and icon from system config if it's a system page
          final displayName = (builderPage.name.isNotEmpty && builderPage.name != 'Page')
              ? builderPage.name 
              : (systemConfig?.defaultName ?? pageId.label);
          
          // Load published theme and wrap content with BuilderThemeProvider
          return FutureBuilder<ThemeConfig>(
            future: themeService.loadPublishedTheme(appId),
            builder: (context, themeSnapshot) {
              // Use default theme while loading
              final theme = themeSnapshot.data ?? ThemeConfig.defaultConfig;
              
              return BuilderThemeProvider(
                theme: theme,
                child: Scaffold(
                  appBar: _buildAppBar(context, builderPage, displayName),
                  body: buildPageFromBuilder(context, builderPage),
                ),
              );
            },
          );
        }
        
        // Fallback to legacy screen
        // IMPORTANT: Never redirect or disconnect user, just show fallback
        return fallback;
      },
    );
  }

  /// Build AppBar with page title
  /// Returns null if no title should be shown
  AppBar? _buildAppBar(BuildContext context, BuilderPage page, String displayName) {
    // Don't show AppBar if it's the home page
    if (pageId == BuilderPageId.home) {
      return null;
    }
    
    // Show AppBar with proper name
    return AppBar(
      title: Text(displayName),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
    );
  }
}

/// Provider for BuilderPageLoader
/// 
/// This provider can be used to check if a Builder page exists
/// before deciding whether to show Builder or legacy content.
final builderPageProvider = FutureProvider.family<BuilderPage?, BuilderPageId>(
  (ref, pageId) async {
    // Read appId from the restaurant provider
    final appId = ref.watch(currentRestaurantProvider).id;
    return await DynamicPageResolver().resolve(pageId, appId);
  },
);
