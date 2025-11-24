// lib/builder/blocks/banner_block_preview.dart
// Banner block preview widget - Phase 5 enhanced

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/block_config_helper.dart';

/// Banner Block Preview
/// 
/// Displays a promotional or informational banner.
/// Preview version with debug borders and stable rendering even with empty config.
class BannerBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  const BannerBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults matching runtime
    final title = helper.getString('title', defaultValue: 'Banner Title');
    final subtitle = helper.getString('subtitle', defaultValue: '');
    final imageUrl = helper.getString('imageUrl', defaultValue: '');
    final align = helper.getString('align', defaultValue: 'center');
    final backgroundColor = helper.getColor('backgroundColor');
    final textColor = helper.getColor('textColor', defaultValue: Colors.black);
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 8.0);
    final height = helper.getDouble('height', defaultValue: 160.0);

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
          color: Colors.orange.withOpacity(0.5),
          width: 2,
        ),
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : BorderRadius.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or color
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: backgroundColor ?? Colors.grey.shade200);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(color: backgroundColor ?? Colors.grey.shade200);
                },
              )
            else
              Container(color: backgroundColor ?? Colors.transparent),
            
            // Preview label
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BANNER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Content
            if (title.isNotEmpty || subtitle.isNotEmpty)
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: textAlign,
                      ),
                    
                    // Subtitle (only if not empty)
                    if (subtitle.isNotEmpty) ...[
                      if (title.isNotEmpty) const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.9),
                        ),
                        textAlign: textAlign,
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
}
