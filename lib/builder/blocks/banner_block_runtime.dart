// lib/builder/blocks/banner_block_runtime.dart
// Runtime version of BannerBlock - Phase 5 enhanced

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../utils/block_config_helper.dart';
import '../utils/action_helper.dart';

/// Banner block for promotional and informational messages
/// 
/// Configuration:
/// - title: Banner title text (default: 'Banner Title')
/// - subtitle: Banner subtitle text (default: '')
/// - imageUrl: Background image URL (default: '')
/// - align: Text alignment - left, center, right (default: center)
/// - padding: Padding inside the banner (default: 16)
/// - margin: Margin around the banner (default: 0)
/// - backgroundColor: Background color in hex (default: transparent)
/// - textColor: Text color in hex (default: #000000)
/// - borderRadius: Corner radius (default: 8)
/// - height: Banner height in pixels (default: 140 mobile, 180 desktop)
/// - tapAction: Action when banner is tapped (openPage, openUrl, scrollToBlock)
/// 
/// Responsive: Full width on mobile, max 1200px centered on desktop
class BannerBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  // Responsive breakpoints
  static const double _desktopBreakpoint = 800.0;
  static const double _maxDesktopWidth = 1200.0;

  const BannerBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults
    final title = helper.getString('title', defaultValue: 'Banner Title');
    final subtitle = helper.getString('subtitle', defaultValue: '');
    final imageUrl = helper.getString('imageUrl', defaultValue: '');
    final align = helper.getString('align', defaultValue: 'center');
    final padding = helper.getEdgeInsets('padding', defaultValue: const EdgeInsets.all(16));
    final margin = helper.getEdgeInsets('margin');
    final backgroundColor = helper.getColor('backgroundColor');
    final textColor = helper.getColor('textColor', defaultValue: Colors.black) ?? Colors.black;
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 8.0);
    final tapActionConfig = block.config['tapAction'] as Map<String, dynamic>?;
    final height = _calculateHeight(helper, context);

    // Determine alignment
    CrossAxisAlignment crossAxisAlignment;
    TextAlign textAlign;
    switch (align.toLowerCase()) {
      case 'left':
        crossAxisAlignment = CrossAxisAlignment.start;
        textAlign = TextAlign.left;
        break;
      case 'right':
        crossAxisAlignment = CrossAxisAlignment.end;
        textAlign = TextAlign.right;
        break;
      default: // center
        crossAxisAlignment = CrossAxisAlignment.center;
        textAlign = TextAlign.center;
    }

    // Build banner content
    Widget bannerContent = Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : BorderRadius.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background (image or solid color)
            if (imageUrl.isNotEmpty)
              _buildBackground(imageUrl, backgroundColor, borderRadius),
            
            // Content
            if (title.isNotEmpty || subtitle.isNotEmpty)
              Padding(
                padding: padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: crossAxisAlignment,
                  children: [
                    // Title (only if not empty)
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: textAlign,
                      ),
                    
                    // Subtitle (only if not empty)
                    if (subtitle.isNotEmpty) ...[
                      if (title.isNotEmpty) const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor.withOpacity(0.9),
                        ),
                        textAlign: textAlign,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    // Apply margin if configured
    if (margin != EdgeInsets.zero) {
      bannerContent = Padding(
        padding: margin,
        child: bannerContent,
      );
    }

    // Wrap with action if configured
    if (tapActionConfig != null && tapActionConfig.isNotEmpty) {
      bannerContent = ActionHelper.wrapWithAction(context, bannerContent, tapActionConfig);
    }

    // Responsive: constrain width on desktop
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > _maxDesktopWidth) {
          return Center(
            child: SizedBox(
              width: _maxDesktopWidth,
              child: bannerContent,
            ),
          );
        }
        return bannerContent;
      },
    );
  }

  /// Calculate height with responsive defaults
  double _calculateHeight(BlockConfigHelper helper, BuildContext context) {
    // Responsive height: check screen size
    final isDesktop = MediaQuery.of(context).size.width > _desktopBreakpoint;
    final defaultHeight = isDesktop ? 180.0 : 140.0;
    
    // Use explicit 'height' if provided, otherwise use default
    return helper.getDouble('height', defaultValue: defaultHeight);
  }

  /// Build background with image or gradient
  Widget _buildBackground(String imageUrl, Color? backgroundColor, double borderRadius) {
    Widget background = Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to color or gradient if image fails
        return _buildErrorPlaceholder(backgroundColor);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingPlaceholder(backgroundColor);
      },
    );

    return background;
  }

  /// Build loading placeholder
  Widget _buildLoadingPlaceholder(Color? backgroundColor) {
    return Container(
      color: backgroundColor ?? Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Build error placeholder
  Widget _buildErrorPlaceholder(Color? backgroundColor) {
    return Container(
      color: backgroundColor ?? Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.broken_image,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            const Text(
              'Failed to load image',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
