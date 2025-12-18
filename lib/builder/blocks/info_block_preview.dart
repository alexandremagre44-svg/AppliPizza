// lib/builder/blocks/info_block_preview.dart
import '../../white_label/theme/theme_extensions.dart';
// Info block preview widget - Phase 5 enhanced

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/block_config_helper.dart';

/// Info Block Preview
/// 
/// Displays an informational notice box with icon.
/// Preview version with debug borders and stable rendering even with empty config.
class InfoBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  const InfoBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults matching runtime
    final title = helper.getString('title', defaultValue: 'Info Title');
    final subtitle = helper.getString('subtitle', defaultValue: 'Info subtitle');
    final iconName = helper.getString('icon', defaultValue: 'info');
    final iconColor = helper.getColor('iconColor', defaultValue: const Color(0xFFD32F2F)) ?? const Color(0xFFD32F2F);
    final textColor = helper.getColor('textColor', defaultValue: Colors.black) ?? Colors.black;
    final backgroundColor = helper.getColor('backgroundColor', defaultValue: const Color(0xFFF5F5F5));
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 8.0);
    final align = helper.getString('align', defaultValue: 'left');

    // Get icon
    final icon = _getIcon(iconName);

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.teal.withOpacity(0.5),
          width: 2,
        ),
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : BorderRadius.zero,
        child: Container(
          padding: const EdgeInsets.all(12),
          color: backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview label row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'INFO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'icon:$iconName align:$align',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Info content
              align.toLowerCase() == 'center'
                  ? _buildCenteredLayout(icon, iconColor, title, subtitle, textColor)
                  : _buildHorizontalLayout(icon, iconColor, title, subtitle, textColor, align),
            ],
          ),
        ),
      ),
    );
  }

  /// Build horizontal layout (icon + text column)
  Widget _buildHorizontalLayout(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
    Color textColor,
    String align,
  ) {
    final crossAxisAlignment = align.toLowerCase() == 'right' 
        ? CrossAxisAlignment.end 
        : CrossAxisAlignment.start;
    final textAlign = align.toLowerCase() == 'right' 
        ? TextAlign.right 
        : TextAlign.left;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon container
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        
        // Text column
        Expanded(
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: textAlign,
                ),
              if (title.isNotEmpty && subtitle.isNotEmpty)
                const SizedBox(height: 4),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.8),
                  ),
                  textAlign: textAlign,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build centered layout (vertical stack)
  Widget _buildCenteredLayout(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
    Color textColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon container
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        if (title.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Get icon from name
  IconData _getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'error':
        return Icons.error_outline;
      case 'success':
        return Icons.check_circle_outline;
      case 'time':
        return Icons.access_time_outlined;
      case 'phone':
        return Icons.phone_outlined;
      case 'location':
        return Icons.location_on_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'star':
        return Icons.star_outline;
      case 'heart':
        return Icons.favorite_outline;
      case 'settings':
        return Icons.settings_outlined;
      case 'help':
        return Icons.help_outline;
      case 'notification':
        return Icons.notifications_outlined;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }
}
