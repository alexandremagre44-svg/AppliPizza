// lib/builder/blocks/hero_block_runtime.dart
// Runtime version of HeroBlock - Phase 5 enhanced

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../utils/block_config_helper.dart';
import '../utils/action_helper.dart';

/// Hero block for prominent headers with image, title, subtitle, and CTA button
/// 
/// Configuration:
/// - title: Hero title text (default: 'Hero Title')
/// - subtitle: Hero subtitle text (default: 'Hero subtitle')
/// - imageUrl: Background image URL (default: '')
/// - align: Text alignment - left, center, right (default: center)
/// - padding: Padding inside the hero (default: 16)
/// - margin: Margin around the hero (default: 0)
/// - backgroundColor: Background color in hex (default: #D32F2F)
/// - textColor: Text color in hex (default: #FFFFFF)
/// - buttonText: CTA button text (default: 'Button')
/// - buttonColor: Button background color in hex (default: #FFFFFF)
/// - buttonTextColor: Button text color in hex (default: #D32F2F)
/// - borderRadius: Corner radius (default: 0)
/// - height: Hero height in pixels (default: 200 mobile, 280 desktop)
/// - tapAction: Action when hero is tapped (openPage, openUrl, scrollToBlock)
/// 
/// Responsive: Full width on mobile, max 1200px centered on desktop
class HeroBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  // Responsive breakpoints
  static const double _desktopBreakpoint = 800.0;
  static const double _maxDesktopWidth = 1200.0;

  const HeroBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults
    final title = helper.getString('title', defaultValue: 'Hero Title');
    final subtitle = helper.getString('subtitle', defaultValue: 'Hero subtitle');
    final imageUrl = helper.getString('imageUrl', defaultValue: '');
    final align = _getAlignValue(helper);
    final padding = helper.getEdgeInsets('padding', defaultValue: const EdgeInsets.all(16));
    final margin = helper.getEdgeInsets('margin');
    final backgroundColor = helper.getColor('backgroundColor', defaultValue: const Color(0xFFD32F2F)) ?? const Color(0xFFD32F2F);
    final textColor = helper.getColor('textColor', defaultValue: Colors.white) ?? Colors.white;
    final buttonText = _getButtonTextValue(helper);
    final buttonColor = helper.getColor('buttonColor', defaultValue: Colors.white);
    final buttonTextColor = helper.getColor('buttonTextColor', defaultValue: const Color(0xFFD32F2F));
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 0.0);
    // Get action config from separate tapAction/tapActionTarget fields
    // Falls back to direct 'tapAction' Map for backward compatibility
    var tapActionConfig = helper.getActionConfig();
    tapActionConfig ??= block.config['tapAction'] as Map<String, dynamic>?;
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

    // Build hero content
    Widget heroContent = Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background (image or solid color)
          _buildBackground(imageUrl, backgroundColor, borderRadius),
          
          // Dark overlay for text readability (only if image is present)
          if (imageUrl.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          
          // Content
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
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    textAlign: textAlign,
                  ),
                
                // Subtitle (only if not empty)
                if (subtitle.isNotEmpty) ...[
                  if (title.isNotEmpty) const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor.withOpacity(0.95),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: textAlign,
                  ),
                ],
                
                // Button (only if buttonText is not empty)
                if (buttonText.isNotEmpty) ...[
                  if (title.isNotEmpty || subtitle.isNotEmpty) const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: tapActionConfig != null && tapActionConfig.isNotEmpty
                        ? () => ActionHelper.execute(context, BlockAction.fromConfig(tapActionConfig))
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: buttonTextColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    // Apply margin if configured
    if (margin != EdgeInsets.zero) {
      heroContent = Padding(
        padding: margin,
        child: heroContent,
      );
    }

    // Responsive: constrain width on desktop
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > _maxDesktopWidth) {
          return Center(
            child: SizedBox(
              width: _maxDesktopWidth,
              child: heroContent,
            ),
          );
        }
        return heroContent;
      },
    );
  }

  /// Get align value with backward compatibility for 'alignment' field
  String _getAlignValue(BlockConfigHelper helper) {
    // Support both 'align' (new) and 'alignment' (legacy)
    return helper.getString('align', 
        defaultValue: helper.getString('alignment', defaultValue: 'center'));
  }

  /// Get button text value with backward compatibility for 'buttonLabel' field
  String _getButtonTextValue(BlockConfigHelper helper) {
    // Support both 'buttonText' (new) and 'buttonLabel' (legacy)
    return helper.getString('buttonText', 
        defaultValue: helper.getString('buttonLabel', defaultValue: 'Button'));
  }

  /// Calculate height with responsive defaults and legacy support
  double _calculateHeight(BlockConfigHelper helper, BuildContext context) {
    // Responsive height: check screen size
    final isDesktop = MediaQuery.of(context).size.width > _desktopBreakpoint;
    final defaultHeight = isDesktop ? 280.0 : 200.0;
    
    // Support legacy 'heightPreset' field
    final heightPreset = helper.getString('heightPreset', defaultValue: '');
    double legacyHeight = defaultHeight;
    if (heightPreset.isNotEmpty) {
      switch (heightPreset.toLowerCase()) {
        case 'small':
          legacyHeight = 200;
          break;
        case 'large':
          legacyHeight = 400;
          break;
        case 'normal':
        default:
          legacyHeight = 280;
      }
    }
    
    // Use explicit 'height' if provided, otherwise use heightPreset value, otherwise default
    return helper.has('height') 
        ? helper.getDouble('height', defaultValue: defaultHeight)
        : legacyHeight;
  }

  /// Build background with image or gradient
  Widget _buildBackground(String imageUrl, Color backgroundColor, double borderRadius) {
    Widget background;
    
    if (imageUrl.isNotEmpty) {
      background = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to gradient if image fails with placeholder
          return _buildErrorPlaceholder(backgroundColor);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder(backgroundColor);
        },
      );
    } else {
      background = _buildGradientBackground(backgroundColor);
    }

    // Apply ClipRRect if borderRadius > 0
    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: background,
      );
    }

    return background;
  }

  /// Build gradient background
  Widget _buildGradientBackground(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  /// Build loading placeholder
  Widget _buildLoadingPlaceholder(Color backgroundColor) {
    return Container(
      color: backgroundColor.withOpacity(0.7),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build error placeholder (same style as image_block_runtime)
  Widget _buildErrorPlaceholder(Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.broken_image,
              size: 48,
              color: Colors.white70,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
