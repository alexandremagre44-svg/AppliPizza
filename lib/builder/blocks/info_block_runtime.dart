// lib/builder/blocks/info_block_runtime.dart
import '../../white_label/theme/theme_extensions.dart';
// Runtime version of InfoBlock - Phase 5 enhanced
// ThemeConfig Integration: Uses theme primaryColor, spacing, and font sizes

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../models/theme_config.dart';
import '../utils/block_config_helper.dart';
import '../utils/action_helper.dart';
import '../runtime/builder_theme_resolver.dart';

/// Info block for displaying informational content with icon
/// 
/// Configuration:
/// - title: Info title text (default: '')
/// - subtitle: Info subtitle text (default: '')
/// - icon: Material icon name (default: 'info')
/// - iconColor: Icon color in hex (default: theme primary)
/// - textColor: Text color in hex (default: black)
/// - backgroundColor: Background color in hex (default: #F5F5F5)
/// - borderRadius: Corner radius (default: theme cardRadius)
/// - padding: Padding inside the container (default: theme spacing * 0.75)
/// - margin: Margin around the container (default: 0)
/// - align: Text alignment - left, center, right (default: left)
/// - tapAction: Action when info is tapped (openPage, openUrl, scrollToBlock)
/// 
/// Layout: Horizontal (icon + text column) by default
/// ThemeConfig: Uses theme.primaryColor, theme.cardRadius, theme.spacing
class InfoBlockRuntime extends StatelessWidget {
  final BuilderBlock block;
  
  /// Optional theme config override
  /// If null, uses theme from context
  final ThemeConfig? themeConfig;

  const InfoBlockRuntime({
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
    final title = helper.getString('title', defaultValue: '');
    final subtitle = helper.getString('subtitle', defaultValue: '');
    final iconName = helper.getString('icon', defaultValue: 'info');
    // Use theme primary color as default icon color
    final iconColor = helper.getColor('iconColor', defaultValue: theme.primaryColor) ?? theme.primaryColor;
    final textColor = helper.getColor('textColor', defaultValue: Colors.black) ?? Colors.black;
    final backgroundColor = helper.getColor('backgroundColor', defaultValue: const Color(0xFFF5F5F5));
    // Use theme cardRadius as default
    final borderRadius = helper.getDouble('borderRadius', defaultValue: theme.cardRadius);
    final padding = helper.getEdgeInsets('padding', defaultValue: EdgeInsets.all(theme.spacing * 0.75));
    final margin = helper.getEdgeInsets('margin');
    final align = helper.getString('align', defaultValue: 'left');
    // Get action config from separate tapAction/tapActionTarget fields
    // Falls back to direct 'tapAction' Map for backward compatibility
    var tapActionConfig = helper.getActionConfig();
    tapActionConfig ??= block.config['tapAction'] as Map<String, dynamic>?;

    // If no title and no subtitle, don't render anything
    if (title.isEmpty && subtitle.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get icon
    final icon = _getIcon(iconName);

    // Determine alignment
    CrossAxisAlignment crossAxisAlignment;
    MainAxisAlignment mainAxisAlignment;
    TextAlign textAlign;
    switch (align.toLowerCase()) {
      case 'center':
        crossAxisAlignment = CrossAxisAlignment.center;
        mainAxisAlignment = MainAxisAlignment.center;
        textAlign = TextAlign.center;
        break;
      case 'right':
        crossAxisAlignment = CrossAxisAlignment.end;
        mainAxisAlignment = MainAxisAlignment.end;
        textAlign = TextAlign.right;
        break;
      default: // left
        crossAxisAlignment = CrossAxisAlignment.start;
        mainAxisAlignment = MainAxisAlignment.start;
        textAlign = TextAlign.left;
    }

    // Build info content
    Widget infoContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
      ),
      child: align.toLowerCase() == 'center'
          ? _buildCenteredLayout(icon, iconColor, title, subtitle, textColor, textAlign, theme)
          : _buildHorizontalLayout(icon, iconColor, title, subtitle, textColor, crossAxisAlignment, textAlign, tapActionConfig, theme),
    );

    // Apply border radius with ClipRRect
    if (borderRadius > 0) {
      infoContent = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: infoContent,
      );
    }

    // Apply margin
    if (margin != EdgeInsets.zero) {
      infoContent = Padding(
        padding: margin,
        child: infoContent,
      );
    }

    // Wrap with action if configured
    if (tapActionConfig != null && tapActionConfig.isNotEmpty) {
      infoContent = ActionHelper.wrapWithAction(context, infoContent, tapActionConfig);
    }

    return infoContent;
  }

  /// Build horizontal layout (icon + text column)
  /// Uses theme.textBodySize for font sizing
  Widget _buildHorizontalLayout(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
    Color textColor,
    CrossAxisAlignment crossAxisAlignment,
    TextAlign textAlign,
    Map<String, dynamic>? tapActionConfig,
    ThemeConfig theme,
  ) {
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
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 12),
        
        // Text column
        Expanded(
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: [
              if (title.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: theme.textBodySize,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: textAlign,
                      ),
                    ),
                    if (tapActionConfig != null && tapActionConfig.isNotEmpty)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: textColor.withOpacity(0.5),
                      ),
                  ],
                ),
              if (title.isNotEmpty && subtitle.isNotEmpty)
                const SizedBox(height: 4),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: theme.textBodySize * 0.875,
                    color: textColor.withOpacity(0.8),
                    height: 1.4,
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
  /// Uses theme.textHeadingSize for title and theme.textBodySize for subtitle
  Widget _buildCenteredLayout(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
    Color textColor,
    TextAlign textAlign,
    ThemeConfig theme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon container
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 32),
        ),
        if (title.isNotEmpty) ...[
          SizedBox(height: theme.spacing * 0.75),
          Text(
            title,
            style: TextStyle(
              fontSize: theme.textHeadingSize * 0.75,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: textAlign,
          ),
        ],
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: theme.spacing / 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: theme.textBodySize * 0.875,
              color: textColor.withOpacity(0.8),
              height: 1.4,
            ),
            textAlign: textAlign,
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
      case 'calendar':
        return Icons.calendar_today_outlined;
      case 'shopping':
        return Icons.shopping_cart_outlined;
      case 'delivery':
        return Icons.local_shipping_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'gift':
        return Icons.card_giftcard_outlined;
      case 'discount':
        return Icons.local_offer_outlined;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }
}
