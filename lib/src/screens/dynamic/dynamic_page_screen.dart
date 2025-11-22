// lib/src/screens/dynamic/dynamic_page_screen.dart
// Dynamic page screen for B3 Phase 2
// Displays pages from PageSchema using PageRenderer

import 'package:flutter/material.dart';
import '../../models/page_schema.dart';
import '../../widgets/page_renderer.dart';

/// Screen that displays a dynamic page from a PageSchema
class DynamicPageScreen extends StatelessWidget {
  final PageSchema pageSchema;

  const DynamicPageScreen({
    Key? key,
    required this.pageSchema,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageRenderer(pageSchema: pageSchema);
  }
}

/// Error screen displayed when a B3 page is not found
class PageNotFoundScreen extends StatelessWidget {
  final String route;

  const PageNotFoundScreen({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page non trouvée'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'Page B3 non trouvée',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'La route "$route" n\'existe pas dans la configuration.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
