// lib/builder/runtime/dynamic_builder_page_screen.dart
// Screen for displaying dynamic Builder pages via /page/:pageId route

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/dynamic_page_resolver.dart';
import '../utils/app_context.dart';
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
    final appId = ref.watch(currentAppIdProvider);
    
    return FutureBuilder<BuilderPage?>(
      future: DynamicPageResolver().resolveByKey(pageKey, appId),
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
          
          return Scaffold(
            appBar: AppBar(
              title: Text(builderPage.name),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
            ),
            body: BuilderRuntimeRenderer(
              blocks: builderPage.blocks,
              wrapInScrollView: true,
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
                    Icons.page_view_outlined,
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
