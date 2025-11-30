// lib/builder/blocks/html_block_runtime.dart
// Runtime version of HTMLBlock - Phase 5 enhanced with security
// ThemeConfig Integration: Uses theme textBodySize and spacing

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../models/theme_config.dart';
import '../utils/block_config_helper.dart';
import '../runtime/builder_theme_resolver.dart';

/// HTML block for displaying HTML content (sanitized)
/// 
/// Configuration:
/// - html: HTML content (sanitized to plain text for security)
/// - padding: Padding around content (default: theme spacing * 0.75)
/// - margin: Margin around block (default: 0)
/// 
/// Security: HTML tags are stripped for safety
/// ThemeConfig: Uses theme.textBodySize and theme.spacing
class HtmlBlockRuntime extends StatelessWidget {
  final BuilderBlock block;
  
  /// Optional theme config override
  /// If null, uses theme from context
  final ThemeConfig? themeConfig;

  const HtmlBlockRuntime({
    super.key,
    required this.block,
    this.themeConfig,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get theme (from prop or context)
    final theme = themeConfig ?? context.builderTheme;
    
    final html = helper.getString('html', defaultValue: '');
    final padding = helper.getEdgeInsets('padding', defaultValue: EdgeInsets.all(theme.spacing * 0.75));
    final margin = helper.getEdgeInsets('margin');
    
    if (html.isEmpty) {
      return _buildFallback(padding, margin, theme);
    }

    // Sanitize HTML - strip tags for security
    final strippedText = _sanitizeHtml(html);

    Widget content = Text(
      strippedText,
      style: TextStyle(fontSize: theme.textBodySize),
    );

    content = Padding(padding: padding, child: content);
    
    if (margin != EdgeInsets.zero) {
      content = Padding(padding: margin, child: content);
    }

    return content;
  }

  /// Sanitize HTML by removing tags
  String _sanitizeHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  /// Fallback when no content
  Widget _buildFallback(EdgeInsets padding, EdgeInsets margin, ThemeConfig theme) {
    Widget fallback = Container(
      padding: EdgeInsets.all(theme.spacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(theme.cardRadius),
      ),
      child: Center(
        child: Text(
          'No HTML content',
          style: TextStyle(color: Colors.grey, fontSize: theme.textBodySize * 0.875),
        ),
      ),
    );

    fallback = Padding(padding: padding, child: fallback);
    if (margin != EdgeInsets.zero) {
      fallback = Padding(padding: margin, child: fallback);
    }
    
    return fallback;
  }
}
