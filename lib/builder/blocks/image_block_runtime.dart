// lib/builder/blocks/image_block_runtime.dart
// Runtime version of ImageBlock - Phase 5 enhanced

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../utils/block_config_helper.dart';
import '../utils/action_helper.dart';

/// Image block for displaying images
/// 
/// Configuration:
/// - imageUrl: URL of the image to display (required)
/// - caption: Optional caption below image
/// - height: Image height in pixels (default: 200)
/// - boxFit: How image should fit (cover, contain, fill) (default: cover)
/// - borderRadius: Corner radius (default: 8)
/// - padding: Padding around image (default: 12)
/// - margin: Margin around block (default: 0)
/// - action: Optional tap action
/// 
/// Responsive: Full width on mobile, max 800px on desktop
class ImageBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const ImageBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults
    final imageUrl = helper.getString('imageUrl', defaultValue: '');
    final caption = helper.getString('caption', defaultValue: '');
    final height = helper.getDouble('height', defaultValue: 200.0);
    final boxFit = helper.getBoxFit('boxFit', defaultValue: BoxFit.cover);
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 8.0);
    final padding = helper.getEdgeInsets('padding', defaultValue: const EdgeInsets.all(12));
    final margin = helper.getEdgeInsets('margin');
    
    // Get action config from separate tapAction/tapActionTarget fields
    // Falls back to 'action' field for backward compatibility
    var actionConfig = helper.getActionConfig();
    actionConfig ??= block.config['action'] as Map<String, dynamic>?;

    // Show placeholder if no image URL
    if (imageUrl.isEmpty) {
      return _buildPlaceholder(height, borderRadius, padding, margin);
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
          return _buildErrorPlaceholder(height);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder(height);
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
              const SizedBox(height: 8),
              Text(
                caption,
                style: const TextStyle(
                  fontSize: 14,
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
  Widget _buildPlaceholder(double height, double borderRadius, EdgeInsets padding, EdgeInsets margin) {
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
            const SizedBox(height: 8),
            Text(
              'No image configured',
              style: TextStyle(
                fontSize: 14,
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
  Widget _buildErrorPlaceholder(double height) {
    return Container(
      height: height,
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'Failed to load image',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading placeholder
  Widget _buildLoadingPlaceholder(double height) {
    return Container(
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
