// lib/builder/blocks/image_block_runtime.dart
import '../../white_label/theme/theme_extensions.dart';
// Runtime version of ImageBlock - Phase 5 enhanced
// ThemeConfig Integration: Uses theme cardRadius and spacing

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../models/theme_config.dart';
import '../utils/block_config_helper.dart';
import '../utils/action_helper.dart';
import '../runtime/builder_theme_resolver.dart';

/// Image block for displaying images
/// 
/// Configuration:
/// - imageUrl: URL of the image to display (required)
/// - caption: Optional caption below image
/// - height: Image height in pixels (default: 200)
/// - boxFit: How image should fit (cover, contain, fill) (default: cover)
/// - borderRadius: Corner radius (default: theme cardRadius)
/// - padding: Padding around image (default: theme spacing * 0.75)
/// - margin: Margin around block (default: 0)
/// - action: Optional tap action
/// 
/// Responsive: Full width on mobile, max 800px on desktop
/// ThemeConfig: Uses theme.cardRadius and theme.spacing
class ImageBlockRuntime extends StatelessWidget {
  final BuilderBlock block;
  
  /// Optional theme config override
  /// If null, uses theme from context
  final ThemeConfig? themeConfig;

  const ImageBlockRuntime({
    super.key,
    required this.block,
    this.themeConfig,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get theme (from prop or context)
    final theme = themeConfig ?? context.builderTheme;
    
    // Get configuration with defaults - use theme values as defaults
    final imageUrl = helper.getString('imageUrl', defaultValue: '');
    final caption = helper.getString('caption', defaultValue: '');
    final height = helper.getDouble('height', defaultValue: 200.0);
    final boxFit = helper.getBoxFit('boxFit', defaultValue: BoxFit.cover);
    // Use theme cardRadius as default
    final borderRadius = helper.getDouble('borderRadius', defaultValue: theme.cardRadius);
    final padding = helper.getEdgeInsets('padding', defaultValue: EdgeInsets.all(theme.spacing * 0.75));
    final margin = helper.getEdgeInsets('margin');
    
    // Get action config from separate tapAction/tapActionTarget fields
    // Falls back to 'action' field for backward compatibility
    var actionConfig = helper.getActionConfig();
    actionConfig ??= block.config['action'] as Map<String, dynamic>?;

    // Show placeholder if no image URL
    if (imageUrl.isEmpty) {
      return _buildPlaceholder(height, borderRadius, padding, margin, theme);
    }

    // Build image widget
    Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: boxFit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder(height, theme);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder(height, theme);
        },
      ),
    );

    // Add caption if provided
    Widget content = caption.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              imageWidget,
              SizedBox(height: theme.spacing / 2),
              Text(
                caption,
                style: TextStyle(
                  fontSize: theme.textBodySize * 0.875,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )
        : imageWidget;

    // Apply padding
    content = Padding(
      padding: padding,
      child: content,
    );

    // Apply margin if configured
    if (margin != EdgeInsets.zero) {
      content = Padding(
        padding: margin,
        child: content,
      );
    }

    // Responsive: constrain width on desktop
    content = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Center(
            child: SizedBox(
              width: 800,
              child: content,
            ),
          );
        }
        return content;
      },
    );

    // Wrap with action if configured
    if (actionConfig != null && actionConfig.isNotEmpty) {
      content = ActionHelper.wrapWithAction(context, content, actionConfig);
    }

    return content;
  }

  /// Build placeholder when no image URL is provided
  Widget _buildPlaceholder(double height, double borderRadius, EdgeInsets padding, EdgeInsets margin, ThemeConfig theme) {
    Widget placeholder = Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
            SizedBox(height: theme.spacing / 2),
            Text(
              'No image configured',
              style: TextStyle(
                fontSize: theme.textBodySize * 0.875,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );

    placeholder = Padding(padding: padding, child: placeholder);
    
    if (margin != EdgeInsets.zero) {
      placeholder = Padding(padding: margin, child: placeholder);
    }

    return placeholder;
  }

  /// Build error placeholder
  Widget _buildErrorPlaceholder(double height, ThemeConfig theme) {
    return Container(
      height: height,
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image, size: 48, color: Colors.grey),
            SizedBox(height: theme.spacing / 2),
            Text(
              'Failed to load image',
              style: TextStyle(fontSize: theme.textBodySize * 0.75, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading placeholder
  Widget _buildLoadingPlaceholder(double height, ThemeConfig theme) {
    return Container(
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
