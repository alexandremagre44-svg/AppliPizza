// lib/builder/builder_entry.dart
// Entry point for Builder B3 Studio
// Clean architecture - NEW implementation (all old builder code removed)

import 'package:flutter/material.dart';
import 'models/models.dart';
import 'editor/editor.dart';

/// Builder Studio Screen - Main entry point for the B3 Builder interface
/// 
/// This is the root widget for the new Builder B3 system.
/// It provides a clean, modular architecture for multi-page, multi-resto builder.
/// 
/// Usage:
/// - Navigate to this screen from admin menu
/// - Shows page list with edit buttons
/// - Navigate to page editor for each page
class BuilderStudioScreen extends StatefulWidget {
  final String appId;

  const BuilderStudioScreen({
    super.key,
    this.appId = 'pizza_delizza',
  });

  @override
  State<BuilderStudioScreen> createState() => _BuilderStudioScreenState();
}

class _BuilderStudioScreenState extends State<BuilderStudioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Builder B3 Studio'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pages disponibles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sélectionnez une page à éditer',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ...BuilderPageId.values.map((pageId) => _buildPageCard(pageId)),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Architecture Builder B3',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text('✅ lib/builder/models/ - Data models'),
          const Text('✅ lib/builder/services/ - Firestore service'),
          const Text('✅ lib/builder/editor/ - Page editor'),
          const Text('⏳ lib/builder/blocks/ - Block widgets'),
          const Text('⏳ lib/builder/preview/ - Preview system'),
          const Text('⏳ lib/builder/utils/ - Utilities'),
        ],
      ),
    );
  }

  Widget _buildPageCard(BuilderPageId pageId) {
    final metadata = BuilderPagesRegistry.getMetadata(pageId);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            metadata.icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          metadata.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(metadata.description),
        trailing: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BuilderPageEditorScreen(
                  appId: widget.appId,
                  pageId: pageId,
                ),
              ),
            );
          },
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Éditer'),
        ),
      ),
    );
  }
}
