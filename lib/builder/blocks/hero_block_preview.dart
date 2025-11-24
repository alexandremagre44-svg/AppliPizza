// lib/builder/blocks/hero_block_preview.dart
// Hero block preview widget - Phase 5 enhanced

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/block_config_helper.dart';

/// Hero Block Preview
/// 
/// Displays a hero banner with image, title, subtitle, and CTA button.
/// Preview version with debug borders and stable rendering even with empty config.
class HeroBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  const HeroBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults matching runtime
    final title = helper.getString('title', defaultValue: 'Hero Title');
    final subtitle = helper.getString('subtitle', defaultValue: 'Hero subtitle text');
    final imageUrl = helper.getString('imageUrl', defaultValue: '');
    final align = helper.getString('align', defaultValue: 'center');
    final backgroundColor = helper.getColor('backgroundColor', defaultValue: const Color(0xFFD32F2F));
    final textColor = helper.getColor('textColor', defaultValue: Colors.white);
    final buttonText = helper.getString('buttonText', defaultValue: 'Button');
    final buttonColor = helper.getColor('buttonColor', defaultValue: Colors.white);
    final buttonTextColor = helper.getColor('buttonTextColor', defaultValue: const Color(0xFFD32F2F));
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 0.0);
    final height = helper.getDouble('height', defaultValue: 240.0);

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

    return Container(
      height: height,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue.withOpacity(0.5),
          width: 2,
        ),
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : BorderRadius.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or gradient
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildGradientBackground(backgroundColor);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildGradientBackground(backgroundColor);
                },
              )
            else
              _buildGradientBackground(backgroundColor),
            
            // Dark overlay for text readability (only if image present)
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
            
            // Preview label
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HERO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: crossAxisAlignment,
                children: [
                  // Title (only if not empty)
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 28,
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
                    if (title.isNotEmpty) const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
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
                    if (title.isNotEmpty || subtitle.isNotEmpty) const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: buttonTextColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: buttonTextColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Config info overlay (bottom)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'h:${height.toInt()} align:$align',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
