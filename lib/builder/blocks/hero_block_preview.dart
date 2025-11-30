// lib/builder/blocks/hero_block_preview.dart
// Hero block preview widget - Phase 5 enhanced with modern visual design

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/block_config_helper.dart';

/// Hero Block Preview
/// 
/// Displays a hero banner with image, title, subtitle, and CTA button.
/// Preview version with debug borders and stable rendering even with empty config.
/// 
/// Modernized with:
/// - Responsive design (mobile/tablet/desktop)
/// - Configurable overlay gradient with opacity
/// - Aspect ratio options (auto, 16:9, square)
/// - Internal padding options (S/M/L)
/// - Material 3 pill button CTA
/// - Fade-in/scale animation
/// - BorderRadius 16 with cover fit
class HeroBlockPreview extends StatefulWidget {
  final BuilderBlock block;

  const HeroBlockPreview({
    super.key,
    required this.block,
  });

  @override
  State<HeroBlockPreview> createState() => _HeroBlockPreviewState();
}

class _HeroBlockPreviewState extends State<HeroBlockPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Responsive breakpoints
  static const double _tabletBreakpoint = 600.0;
  static const double _desktopBreakpoint = 900.0;
  
  // Design constants
  static const double _maxOverlayOpacity = 0.7;
  static const double _pillButtonRadius = 50.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
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

  /// Get padding based on size preset (S/M/L) or custom value
  EdgeInsets _getPadding(BlockConfigHelper helper, double screenWidth) {
    final paddingSize = helper.getString('paddingSize', defaultValue: 'M');
    final customPadding = helper.getEdgeInsets('padding');
    
    // If custom padding is explicitly provided, use it
    if (helper.has('padding') && customPadding != EdgeInsets.zero) {
      return customPadding;
    }
    
    // Responsive padding based on screen size
    final isTablet = screenWidth >= _tabletBreakpoint;
    final isDesktop = screenWidth >= _desktopBreakpoint;
    
    switch (paddingSize.toUpperCase()) {
      case 'S':
        return EdgeInsets.all(isDesktop ? 16 : isTablet ? 12 : 8);
      case 'L':
        return EdgeInsets.all(isDesktop ? 48 : isTablet ? 32 : 24);
      case 'M':
      default:
        return EdgeInsets.all(isDesktop ? 32 : isTablet ? 24 : 16);
    }
  }

  /// Calculate height based on aspect ratio or explicit height
  double _calculateHeight(BlockConfigHelper helper, double screenWidth) {
    final aspectRatio = helper.getString('aspectRatio', defaultValue: 'auto');
    final explicitHeight = helper.getDouble('height', defaultValue: 0.0);
    
    if (explicitHeight > 0) {
      return explicitHeight;
    }
    
    switch (aspectRatio.toLowerCase()) {
      case '16:9':
        return screenWidth * 9 / 16;
      case 'square':
      case '1:1':
        return screenWidth;
      case 'auto':
      default:
        // Responsive default heights
        if (screenWidth >= _desktopBreakpoint) {
          return 320.0;
        } else if (screenWidth >= _tabletBreakpoint) {
          return 280.0;
        }
        return 240.0;
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
      Colors.black.withOpacity(clampedOpacity * 0.5),
      Colors.black.withOpacity(clampedOpacity),
    ];
  }

  /// Get responsive font sizes
  Map<String, double> _getFontSizes(double screenWidth) {
    final isTablet = screenWidth >= _tabletBreakpoint;
    final isDesktop = screenWidth >= _desktopBreakpoint;
    
    return {
      'title': isDesktop ? 32.0 : isTablet ? 28.0 : 26.0,
      'subtitle': isDesktop ? 20.0 : isTablet ? 18.0 : 16.0,
      'button': isDesktop ? 16.0 : isTablet ? 15.0 : 14.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(widget.block.config, blockId: widget.block.id);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Get configuration with defaults matching runtime
    final title = helper.getString('title', defaultValue: 'Hero Title');
    final subtitle = helper.getString('subtitle', defaultValue: 'Hero subtitle text');
    final imageUrl = helper.getString('imageUrl', defaultValue: '');
    final align = helper.getString('align', defaultValue: 'center');
    final backgroundColor = helper.getColor('backgroundColor', defaultValue: const Color(0xFFD32F2F)) ?? const Color(0xFFD32F2F);
    final textColor = helper.getColor('textColor', defaultValue: Colors.white) ?? Colors.white;
    final buttonText = helper.getString('buttonText', defaultValue: 'Button');
    final buttonColor = helper.getColor('buttonColor', defaultValue: Colors.white);
    final buttonTextColor = helper.getColor('buttonTextColor', defaultValue: const Color(0xFFD32F2F));
    
    // Modern default: borderRadius 16
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 16.0);
    
    // Calculate responsive values
    final height = _calculateHeight(helper, screenWidth);
    final padding = _getPadding(helper, screenWidth);
    final fontSizes = _getFontSizes(screenWidth);
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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: height,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue.withOpacity(0.5),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image or gradient with cover fit
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildGradientBackground(backgroundColor);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildGradientBackground(backgroundColor),
                          Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white.withOpacity(0.7),
                              strokeWidth: 2,
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else
                  _buildGradientBackground(backgroundColor),
                
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
                
                // Preview label
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'HERO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                
                // Content with configurable padding
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
                        if (title.isNotEmpty) const SizedBox(height: 10),
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
                        if (title.isNotEmpty || subtitle.isNotEmpty) const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: buttonTextColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth >= _tabletBreakpoint ? 32 : 24,
                              vertical: screenWidth >= _tabletBreakpoint ? 16 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(_pillButtonRadius), // Pill shape
                            ),
                            elevation: 4,
                            shadowColor: Colors.black.withOpacity(0.3),
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
                
                // Config info overlay (bottom) - refined style
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'h:${height.toInt()} align:$align',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
            HSLColor.fromColor(color).withLightness(
              (HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0),
            ).toColor(),
          ],
        ),
      ),
    );
  }
}
