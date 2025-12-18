// lib/builder/blocks/html_block_preview.dart
import '../../white_label/theme/theme_extensions.dart';
// HTML block preview widget

import 'package:flutter/material.dart';
import '../models/models.dart';

/// HTML Block Preview
/// 
/// Displays custom HTML content (simplified preview).
/// For actual HTML rendering, would need flutter_html package.
class HtmlBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  const HtmlBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final htmlContent = block.getConfig<String>('html', '<p>Contenu HTML personnalisé</p>') ?? '<p>Contenu HTML personnalisé</p>';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                size: 20,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Contenu HTML',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _stripHtmlTags(htmlContent),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stripHtmlTags(String html) {
    // Simple HTML tag removal for preview
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }
}
