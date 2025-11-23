// lib/src/admin/studio_b3/widgets/preview_panel.dart
// Right panel: Live preview of the page using PageRenderer

import 'package:flutter/material.dart';
import '../../../models/page_schema.dart';
import '../../../widgets/page_renderer.dart';

/// Panel showing live preview of the page
class PreviewPanel extends StatelessWidget {
  final PageSchema pageSchema;

  const PreviewPanel({
    Key? key,
    required this.pageSchema,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone_android, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Aperçu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Center(
      child: Container(
        width: 375, // iPhone width
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        child: _buildPhoneMockup(),
      ),
    );
  }

  Widget _buildPhoneMockup() {
    return Column(
      children: [
        // Status bar
        Container(
          height: 44,
          color: Colors.black,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '9:41',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Page content with error boundary
        Expanded(
          child: _buildPreviewContent(),
        ),
      ],
    );
  }

  /// Build preview content with comprehensive error handling
  Widget _buildPreviewContent() {
    try {
      return PageRenderer(pageSchema: pageSchema);
    } catch (e, stackTrace) {
      // Log error for debugging
      print('PreviewPanel: Error rendering page - $e');
      print('StackTrace: $stackTrace');
      
      // Return user-friendly error widget
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.orange[700],
            ),
            const SizedBox(height: 16),
            Text(
              'Impossible d\'afficher l\'aperçu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Une erreur est survenue lors du rendu de la page',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Text(
                e.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
  }
}
