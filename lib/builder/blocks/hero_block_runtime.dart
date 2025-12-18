// lib/builder/blocks/hero_block_runtime.dart
import '../../white_label/theme/theme_extensions.dart';
// Runtime version of HeroBlock - Phase 5 enhanced with modern visual design
// ThemeConfig Integration: Uses theme primaryColor, textHeadingSize, textBodySize, buttonRadius

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../models/theme_config.dart';
import '../utils/block_config_helper.dart';
import '../utils/action_helper.dart';
import '../runtime/builder_theme_resolver.dart';

/// Hero block for prominent headers with image, title, subtitle, and CTA button
/// 
/// Configuration (all backward compatible):
/// - title: Hero title text (default: 'Hero Title')
/// - subtitle: Hero subtitle text (default: 'Hero subtitle')
/// - imageUrl: Background image URL (default: '')
/// - align: Text alignment - left, center, right (default: center)
/// - padding: Padding inside the hero (default: 16)
/// - paddingSize: Padding preset - S, M, L (default: M)
/// - margin: Margin around the hero (default: 0)
/// - backgroundColor: Background color in hex (default: #D32F2F)
/// - textColor: Text color in hex (default: #FFFFFF)
/// - buttonText: CTA button text (default: 'Button')
/// - buttonColor: Button background color in hex (default: #FFFFFF)
/// - buttonTextColor: Button text color in hex (default: #D32F2F)
/// - borderRadius: Corner radius (default: 16)
/// - height: Hero height in pixels (default: responsive)
/// - aspectRatio: Aspect ratio - auto, 16:9, square (default: auto)
/// - overlayEnabled: Enable gradient overlay (default: true)
/// - overlayOpacity: Overlay opacity 0-0.7 (default: 0.5)
/// - tapAction: Action when hero is tapped (openPage, openUrl, scrollToBlock)
/// 
/// Responsive: Mobile / Tablet / Desktop with adaptive sizing
/// Animation: Fade-in + slight scale on mount
/// ThemeConfig: Uses theme.primaryColor for default background and button colors
class HeroBlockRuntime extends StatefulWidget {
  final BuilderBlock block;
  
  /// Optional theme config override
  /// If null, uses theme from context
  final ThemeConfig? themeConfig;

  const HeroBlockRuntime({
    super.key,
    required this.block,
    this.themeConfig,
  });

  @override
  State<HeroBlockRuntime> createState() => _HeroBlockRuntimeState();
}

class _HeroBlockRuntimeState extends State<HeroBlockRuntime>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Responsive breakpoints
  static const double _mobileBreakpoint = 480.0;
  static const double _tabletBreakpoint = 768.0;
  static const double _desktopBreakpoint = 1024.0;
  static const double _maxDesktopWidth = 1200.0;
  
  // Design constants
  static const double _maxOverlayOpacity = 0.7;
  static const double _pillButtonRadius = 50.0;
  
  // Responsive font scaling factors (relative to theme base sizes)
  static const double _titleScaleDesktop = 1.35;
  static const double _titleScaleTablet = 1.15;
  static const double _titleScaleMobile = 1.08;
  static const double _subtitleScaleDesktop = 1.25;
  static const double _subtitleScaleTablet = 1.125;
  static const double _subtitleScaleMobile = 1.0;
  static const double _buttonTextScaleTablet = 0.94;
  static const double _buttonTextScaleMobile = 0.875;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get device type for responsive design
  _DeviceType _getDeviceType(double width) {
    if (width >= _desktopBreakpoint) return _DeviceType.desktop;
    if (width >= _tabletBreakpoint) return _DeviceType.tablet;
    return _DeviceType.mobile;
  }

  /// Get padding based on size preset (S/M/L) or custom value
  EdgeInsets _getPadding(BlockConfigHelper helper, _DeviceType device) {
    final paddingSize = helper.getString('paddingSize', defaultValue: 'M');
    
    // If custom padding is explicitly provided, use it
    if (helper.has('padding')) {
      final customPadding = helper.getEdgeInsets('padding');
      if (customPadding != EdgeInsets.zero) {
        return customPadding;
      }
    }
    
    // Responsive padding based on device type and preset
    switch (paddingSize.toUpperCase()) {
      case 'S':
        switch (device) {
          case _DeviceType.desktop:
            return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
          case _DeviceType.tablet:
            return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
          case _DeviceType.mobile:
            return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
        }
      case 'L':
        switch (device) {
          case _DeviceType.desktop:
            return const EdgeInsets.symmetric(horizontal: 64, vertical: 48);
          case _DeviceType.tablet:
            return const EdgeInsets.symmetric(horizontal: 48, vertical: 36);
          case _DeviceType.mobile:
            return const EdgeInsets.symmetric(horizontal: 32, vertical: 28);
        }
      case 'M':
      default:
        switch (device) {
          case _DeviceType.desktop:
            return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
          case _DeviceType.tablet:
            return const EdgeInsets.symmetric(horizontal: 36, vertical: 24);
          case _DeviceType.mobile:
            return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
        }
    }
  }

  /// Calculate height based on aspect ratio or explicit height
  double _calculateHeight(BlockConfigHelper helper, double screenWidth, _DeviceType device) {
    final aspectRatio = helper.getString('aspectRatio', defaultValue: 'auto');
    
    // Check for explicit height first
    if (helper.has('height')) {
      return helper.getDouble('height', defaultValue: 280.0);
    }
    
    // Support legacy 'heightPreset' field
    final heightPreset = helper.getString('heightPreset', defaultValue: '');
    if (heightPreset.isNotEmpty) {
      switch (heightPreset.toLowerCase()) {
        case 'small':
          return device == _DeviceType.mobile ? 180 : 200;
        case 'large':
          return device == _DeviceType.mobile ? 320 : device == _DeviceType.tablet ? 380 : 420;
        case 'normal':
        default:
          return device == _DeviceType.mobile ? 220 : device == _DeviceType.tablet ? 280 : 320;
      }
    }
    
    // Calculate based on aspect ratio
    switch (aspectRatio.toLowerCase()) {
      case '16:9':
        // Constrain to reasonable max width for aspect ratio
        final effectiveWidth = screenWidth.clamp(0.0, _maxDesktopWidth);
        return effectiveWidth * 9 / 16;
      case 'square':
      case '1:1':
        // Square but with reasonable max height
        final maxSquareSize = device == _DeviceType.mobile ? 300.0 : 400.0;
        return screenWidth.clamp(0.0, maxSquareSize);
      case 'auto':
      default:
        // Responsive default heights
        switch (device) {
          case _DeviceType.desktop:
            return 340.0;
          case _DeviceType.tablet:
            return 300.0;
          case _DeviceType.mobile:
            return 260.0;
        }
    }
  }

  /// Get overlay gradient colors based on config
  List<Color> _getOverlayGradient(BlockConfigHelper helper, bool hasImage) {
    final overlayEnabled = helper.getBool('overlayEnabled', defaultValue: true);
    final overlayOpacity = helper.getDouble('overlayOpacity', defaultValue: 0.5);
    
    if (!overlayEnabled || !hasImage) {
      return [Colors.transparent, Colors.transparent];
    }
    
    // Clamp opacity between 0 and max for readability
    final clampedOpacity = overlayOpacity.clamp(0.0, _maxOverlayOpacity);
    
    return [
      Colors.black.withOpacity(clampedOpacity * 0.4),
      Colors.black.withOpacity(clampedOpacity),
    ];
  }

  /// Get responsive font sizes based on theme
  /// Uses theme.textHeadingSize for title and theme.textBodySize for subtitle
  Map<String, double> _getFontSizes(_DeviceType device, ThemeConfig theme) {
    // Use theme font sizes with responsive scaling
    final headingSize = theme.textHeadingSize;
    final bodySize = theme.textBodySize;
    
    switch (device) {
      case _DeviceType.desktop:
        return {
          'title': headingSize * _titleScaleDesktop,
          'subtitle': bodySize * _subtitleScaleDesktop,
          'button': bodySize,
        };
      case _DeviceType.tablet:
        return {
          'title': headingSize * _titleScaleTablet,
          'subtitle': bodySize * _subtitleScaleTablet,
          'button': bodySize * _buttonTextScaleTablet,
        };
      case _DeviceType.mobile:
        return {
          'title': headingSize * _titleScaleMobile,
          'subtitle': bodySize * _subtitleScaleMobile,
          'button': bodySize * _buttonTextScaleMobile,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(widget.block.config, blockId: widget.block.id);
    final screenWidth = MediaQuery.of(context).size.width;
    final device = _getDeviceType(screenWidth);
    
    // Get theme (from prop or context)
    final theme = widget.themeConfig ?? context.builderTheme;
    
    // Get configuration with defaults - use theme primaryColor as default
    final title = helper.getString('title', defaultValue: 'Hero Title');
    final subtitle = helper.getString('subtitle', defaultValue: 'Hero subtitle');
    final imageUrl = helper.getString('imageUrl', defaultValue: '');
    final align = _getAlignValue(helper);
    final margin = helper.getEdgeInsets('margin');
    // Use theme primaryColor as default background
    final backgroundColor = helper.getColor('backgroundColor') ?? theme.primaryColor;
    final textColor = helper.getColor('textColor') ?? Colors.white;
    final buttonText = _getButtonTextValue(helper);
    final buttonColor = helper.getColor('buttonColor') ?? Colors.white;
    // Use theme primaryColor as default button text color
    final buttonTextColor = helper.getColor('buttonTextColor') ?? theme.primaryColor;
    
    // Use theme buttonRadius as default, with 16.0 as ultimate fallback
    final borderRadius = helper.getDouble('borderRadius', defaultValue: theme.buttonRadius.clamp(0, 100));
    
    // Get action config from separate tapAction/tapActionTarget fields
    // Falls back to direct 'tapAction' Map for backward compatibility
    var tapActionConfig = helper.getActionConfig();
    tapActionConfig ??= widget.block.config['tapAction'] as Map<String, dynamic>?;
    
    // Calculate responsive values
    final height = _calculateHeight(helper, screenWidth, device);
    final padding = _getPadding(helper, device);
    final fontSizes = _getFontSizes(device, theme);
    final overlayColors = _getOverlayGradient(helper, imageUrl.isNotEmpty);

    // Determine alignment
    CrossAxisAlignment crossAxisAlignment;
    TextAlign textAlign;
    MainAxisAlignment mainAxisAlignment;
    switch (align.toLowerCase()) {
      case 'left':
        crossAxisAlignment = CrossAxisAlignment.start;
        textAlign = TextAlign.left;
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case 'right':
        crossAxisAlignment = CrossAxisAlignment.end;
        textAlign = TextAlign.right;
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      default: // center
        crossAxisAlignment = CrossAxisAlignment.center;
        textAlign = TextAlign.center;
        mainAxisAlignment = MainAxisAlignment.center;
    }

    // Build hero content with modern styling
    Widget heroContent = FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background (image or gradient) with cover fit
                _buildBackground(imageUrl, backgroundColor),
                
                // Configurable overlay gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: overlayColors,
                    ),
                  ),
                ),
                
                // Content with responsive padding
                Padding(
                  padding: padding,
                  child: Column(
                    mainAxisAlignment: mainAxisAlignment,
                    crossAxisAlignment: crossAxisAlignment,
                    children: [
                      // Title with modern typography
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: fontSizes['title'],
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            letterSpacing: -0.5,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          textAlign: textAlign,
                        ),
                      
                      // Subtitle with refined typography
                      if (subtitle.isNotEmpty) ...[
                        if (title.isNotEmpty) SizedBox(height: device == _DeviceType.mobile ? 10 : 14),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: fontSizes['subtitle'],
                            fontWeight: FontWeight.w400,
                            color: textColor.withOpacity(0.9),
                            height: 1.4,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          textAlign: textAlign,
                        ),
                      ],
                      
                      // Modern pill button CTA (Material 3 style)
                      if (buttonText.isNotEmpty) ...[
                        if (title.isNotEmpty || subtitle.isNotEmpty) 
                          SizedBox(height: device == _DeviceType.mobile ? 20 : 28),
                        ElevatedButton(
                          onPressed: tapActionConfig != null && tapActionConfig.isNotEmpty
                              ? () => ActionHelper.execute(context, BlockAction.fromConfig(tapActionConfig))
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: buttonTextColor,
                            disabledBackgroundColor: buttonColor?.withOpacity(0.6),
                            disabledForegroundColor: buttonTextColor?.withOpacity(0.6),
                            padding: EdgeInsets.symmetric(
                              horizontal: device == _DeviceType.mobile ? 28 : 36,
                              vertical: device == _DeviceType.mobile ? 14 : 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(_pillButtonRadius), // Pill shape
                            ),
                            elevation: 6,
                            shadowColor: Colors.black.withOpacity(0.25),
                          ),
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              fontSize: fontSizes['button'],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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

  /// Build background with image or gradient with cover fit
  Widget _buildBackground(String imageUrl, Color backgroundColor) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder(backgroundColor);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder(backgroundColor, loadingProgress);
        },
      );
    }
    return _buildGradientBackground(backgroundColor);
  }

  /// Build modern gradient background
  Widget _buildGradientBackground(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            HSLColor.fromColor(color).withLightness(
              (HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0),
            ).toColor(),
          ],
        ),
      ),
    );
  }

  /// Build loading placeholder with progress indicator
  Widget _buildLoadingPlaceholder(Color backgroundColor, ImageChunkEvent loadingProgress) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor.withOpacity(0.8),
            backgroundColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
          color: Colors.white.withOpacity(0.8),
          strokeWidth: 3,
        ),
      ),
    );
  }

  /// Build error placeholder with modern styling
  Widget _buildErrorPlaceholder(Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            HSLColor.fromColor(backgroundColor).withLightness(
              (HSLColor.fromColor(backgroundColor).lightness - 0.1).clamp(0.0, 1.0),
            ).toColor(),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'Image unavailable',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Device type enum for responsive design
enum _DeviceType { mobile, tablet, desktop }

