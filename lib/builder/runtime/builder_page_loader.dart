// lib/builder/runtime/builder_page_loader.dart
// Widget that loads Builder pages with fallback to legacy screens
//
// Uses new Firestore structure:
// restaurants/{restaurantId}/pages_published/{pageId}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/dynamic_page_resolver.dart';
import '../../src/core/firestore_paths.dart';
import '../preview/builder_runtime_renderer.dart';

/// Widget that loads a Builder page with fallback to legacy screen
/// 
/// This widget attempts to load a BuilderPage from Firestore.
/// If the page exists, it renders it using BuilderRuntimeRenderer.
/// If not, it displays the provided fallback widget.
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
    // Use kRestaurantId from FirestorePaths for consistent restaurant scoping
    final appId = kRestaurantId;
    
    // Resolver instance - could be optimized with a provider if needed
    final resolver = DynamicPageResolver();
    
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
        
        // If Builder page exists and has blocks, render it
        if (snapshot.hasData && snapshot.data != null) {
          final builderPage = snapshot.data!;
          
          return Scaffold(
            appBar: _buildAppBar(context, builderPage),
            body: BuilderRuntimeRenderer(
              blocks: builderPage.blocks,
              backgroundColor: backgroundColor,
              wrapInScrollView: true,
            ),
          );
        }
        
        // Fallback to legacy screen
        return fallback;
      },
    );
  }

  /// Build AppBar with page title
  /// Returns null if no title should be shown
  AppBar? _buildAppBar(BuildContext context, BuilderPage page) {
    // Don't show AppBar if page has no name or if it's the home page
    if (page.name.isEmpty || pageId == BuilderPageId.home) {
      return null;
    }
    
    return AppBar(
      title: Text(page.name),
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
    // Use kRestaurantId for consistent restaurant scoping
    return await DynamicPageResolver().resolve(pageId, kRestaurantId);
  },
);
