// lib/builder/blocks/banner_block_runtime.dart
// Runtime version of BannerBlock - promotional and informational banners

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/builder_block.dart';
import '../../src/theme/app_theme.dart';
import '../../src/core/constants.dart';

/// Enhanced BannerBlockRuntime with rich configuration
/// 
/// Configuration options:
/// - title: Main banner title
/// - subtitle: Optional subtitle text
/// - text: Main content text (fallback if title not set)
/// - imageUrl: Optional background/side image
/// - backgroundColor: Hex color (e.g., '#FF5733')
/// - ctaLabel: Call-to-action button text
/// - ctaAction: Route to navigate to (e.g., '/menu')
/// - style: 'info', 'promo', 'warning', 'success'
class BannerBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const BannerBlockRuntime({
    super.key,
    required this.block,
  });

  // Helper getters for configuration
  String? get _title => block.getConfig<String>('title');
  String? get _subtitle => block.getConfig<String>('subtitle');
  String get _text {
    // Fallback chain: title -> text -> default
    return _title ?? block.getConfig<String>('text') ?? 'Information importante';
  }
  
  String? get _imageUrl {
    final url = block.getConfig<String>('imageUrl');
    return (url != null && url.isNotEmpty) ? url : null;
  }
  
  Color get _backgroundColor {
    final style = block.getConfig<String>('style') ?? 'info';
    final colorStr = block.getConfig<String>('backgroundColor');
    
    // Try custom color first
    if (colorStr != null && colorStr.isNotEmpty) {
      try {
        return Color(int.parse(colorStr.replaceAll('#', '0xFF')));
      } catch (e) {
        // Fall through to style-based color
      }
    }
    
    // Style-based colors
    switch (style) {
      case 'promo':
        return AppColors.primaryRed;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'info':
      default:
        return Colors.blue;
    }
  }
  
  String? get _ctaLabel => block.getConfig<String>('ctaLabel');
  String? get _ctaAction => block.getConfig<String>('ctaAction');

  @override
  Widget build(BuildContext context) {
    final hasImage = _imageUrl != null;
    final hasCta = _ctaLabel != null && _ctaLabel!.isNotEmpty;

    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor.withOpacity(0.1),
          borderRadius: AppRadius.card,
          border: Border.all(
            color: _backgroundColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.card,
          child: hasImage
              ? _buildBannerWithImage(context)
              : _buildSimpleBanner(context, hasCta),
        ),
      ),
    );
  }

  Widget _buildSimpleBanner(BuildContext context, bool hasCta) {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: Row(
        children: [
          Icon(
            Icons.campaign_outlined,
            color: _backgroundColor,
            size: 28,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: _backgroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_subtitle != null && _subtitle!.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    _subtitle!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (hasCta) ...[
            SizedBox(width: AppSpacing.md),
            _buildCtaButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildBannerWithImage(BuildContext context) {
    return Stack(
      children: [
        // Background image with overlay
        Positioned.fill(
          child: Image.network(
            _imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: _backgroundColor.withOpacity(0.2));
            },
          ),
        ),
        
        // Content overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                _backgroundColor.withOpacity(0.9),
                _backgroundColor.withOpacity(0.7),
              ],
            ),
          ),
          padding: AppSpacing.paddingXL,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _text,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_subtitle != null && _subtitle!.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        _subtitle!,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                    ],
                    if (_ctaLabel != null && _ctaLabel!.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.md),
                      _buildCtaButton(context, isOnImage: true),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCtaButton(BuildContext context, {bool isOnImage = false}) {
    return ElevatedButton(
      onPressed: () {
        if (_ctaAction != null && _ctaAction!.isNotEmpty) {
          context.go(_ctaAction!);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isOnImage ? Colors.white : _backgroundColor,
        foregroundColor: isOnImage ? _backgroundColor : Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.button,
        ),
      ),
      child: Text(
        _ctaLabel!,
        style: AppTextStyles.button.copyWith(
          color: isOnImage ? _backgroundColor : Colors.white,
        ),
      ),
    );
  }
}
