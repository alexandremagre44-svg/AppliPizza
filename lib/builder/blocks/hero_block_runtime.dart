// lib/builder/blocks/hero_block_runtime.dart
// Runtime version of HeroBlock - uses real widgets and styling

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/builder_block.dart';
import '../../src/theme/app_theme.dart';
import '../../src/core/constants.dart';

/// Enhanced HeroBlockRuntime with configurable properties
/// 
/// Configuration options:
/// - title: Hero title text
/// - subtitle: Hero subtitle text
/// - buttonLabel: CTA button text
/// - imageUrl: Background image URL
/// - backgroundColor: Hex color for background (e.g., '#FF5733')
/// - heightPreset: 'small' (200px), 'normal' (280px), 'large' (400px)
/// - alignment: 'left', 'center' (text alignment)
class HeroBlockRuntime extends ConsumerWidget {
  final BuilderBlock block;

  const HeroBlockRuntime({
    super.key,
    required this.block,
  });

  // Helper getters for configuration
  String get _title => block.getConfig<String>('title') ?? 'Bienvenue chez Pizza Deli\'Zza';
  String get _subtitle => block.getConfig<String>('subtitle') ?? 'Les meilleures pizzas artisanales';
  String get _buttonLabel => block.getConfig<String>('buttonLabel') ?? 'Commander';
  String? get _imageUrl {
    final url = block.getConfig<String>('imageUrl');
    return (url != null && url.isNotEmpty) ? url : null;
  }
  
  Color get _backgroundColor {
    final colorStr = block.getConfig<String>('backgroundColor');
    if (colorStr != null && colorStr.isNotEmpty) {
      try {
        return Color(int.parse(colorStr.replaceAll('#', '0xFF')));
      } catch (e) {
        // Fallback to default
      }
    }
    return AppColors.primaryRed;
  }
  
  double get _height {
    final preset = block.getConfig<String>('heightPreset') ?? 'normal';
    switch (preset) {
      case 'small':
        return 200;
      case 'large':
        return 400;
      case 'normal':
      default:
        return 280;
    }
  }
  
  CrossAxisAlignment get _alignment {
    final align = block.getConfig<String>('alignment') ?? 'left';
    return align == 'center' ? CrossAxisAlignment.center : CrossAxisAlignment.start;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: _height,
      margin: AppSpacing.paddingHorizontalLG,
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background (image or solid color)
            _buildBackground(),
            
            // Dark overlay for text readability
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
              padding: AppSpacing.paddingXXL,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: _alignment,
                children: [
                  Text(
                    _title,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    textAlign: _alignment == CrossAxisAlignment.center 
                        ? TextAlign.center 
                        : TextAlign.left,
                  ),
                  if (_subtitle.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.md),
                    Text(
                      _subtitle,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white.withOpacity(0.95),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: _alignment == CrossAxisAlignment.center 
                          ? TextAlign.center 
                          : TextAlign.left,
                    ),
                  ],
                  SizedBox(height: AppSpacing.xxl),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to menu when tapped
                      context.go(AppRoutes.menu);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _backgroundColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _buttonLabel,
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: _backgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (_imageUrl != null) {
      return Image.network(
        _imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to gradient if image fails
          return _buildGradientBackground();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildGradientBackground();
        },
      );
    }
    return _buildGradientBackground();
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _backgroundColor,
            _backgroundColor.withOpacity(0.8),
          ],
        ),
      ),
    );
  }
}
