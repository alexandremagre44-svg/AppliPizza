// lib/builder/utils/responsive.dart
// Responsive utility for Builder B3
// Helps determine device breakpoints for responsive layouts

import 'package:flutter/material.dart';

/// Responsive breakpoints for Builder B3
class ResponsiveBreakpoints {
  // Mobile: < 768px (phones in portrait and landscape)
  static const double mobile = 768;
  
  // Tablet: >= 768px and < 1024px (tablets, large phones in landscape)
  static const double tablet = 768;
  
  // Desktop: >= 1024px (desktops, large tablets in landscape)
  static const double desktop = 1024;
  
  // Max content width for centering on wide screens
  static const double maxContentWidth = 1200;
  
  // Sidebar widths for editor
  static const double sidebarMinWidth = 260;
  static const double sidebarMaxWidth = 320;
  
  // Properties panel widths
  static const double propertiesPanelMinWidth = 320;
  static const double propertiesPanelMaxWidth = 380;
}

/// Responsive builder helper
/// Provides device type detection and responsive utilities
class ResponsiveBuilder {
  final double width;
  
  const ResponsiveBuilder(this.width);
  
  /// Factory from BuildContext
  factory ResponsiveBuilder.of(BuildContext context) {
    return ResponsiveBuilder(MediaQuery.of(context).size.width);
  }
  
  /// Check if current width is mobile (<768px)
  bool get isMobile => width < ResponsiveBreakpoints.mobile;
  
  /// Check if current width is tablet (>=768px and <1024px)
  bool get isTablet => width >= ResponsiveBreakpoints.mobile && 
                       width < ResponsiveBreakpoints.desktop;
  
  /// Check if current width is desktop (>=1024px)
  bool get isDesktop => width >= ResponsiveBreakpoints.desktop;
  
  /// Check if not mobile (tablet or desktop)
  bool get isNotMobile => width >= ResponsiveBreakpoints.mobile;
  
  /// Get responsive value based on screen size
  T getValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
  
  /// Get horizontal padding based on screen size
  double get horizontalPadding {
    if (isMobile) return 12.0;
    if (isTablet) return 16.0;
    return 24.0;
  }
  
  /// Get vertical padding based on screen size
  double get verticalPadding {
    if (isMobile) return 8.0;
    if (isTablet) return 12.0;
    return 16.0;
  }
  
  /// Get sidebar width for page editor
  double get sidebarWidth {
    if (isMobile) return width; // Full width on mobile
    if (isTablet) return 0; // Hidden on tablet (use dropdown)
    // Desktop: fixed width between min and max
    return ResponsiveBreakpoints.sidebarMinWidth;
  }
  
  /// Get properties panel width for page editor
  double get propertiesPanelWidth {
    if (isMobile) return width; // Full width on mobile (bottom sheet)
    if (isTablet) return width * 0.4; // 40% on tablet
    // Desktop: fixed width between min and max
    return ResponsiveBreakpoints.propertiesPanelMinWidth;
  }
  
  /// Get editor panel width
  /// @deprecated Use [propertiesPanelWidth] instead
  @Deprecated('Use propertiesPanelWidth instead')
  double get editorPanelWidth {
    if (isMobile) return width; // Full width on mobile
    if (isTablet) return width * 0.4; // 40% on tablet
    return 320.0; // Fixed 320px on desktop
  }
  
  /// Get preview max width (respects maxContentWidth)
  double get previewMaxWidth {
    if (isMobile) return width;
    if (isTablet) return width * 0.6;
    // On desktop, use max content width
    final contentArea = width - editorPanelWidth;
    return contentArea.clamp(0.0, ResponsiveBreakpoints.maxContentWidth);
  }
  
  /// Get content max width for runtime (centered on wide screens)
  double get contentMaxWidth {
    if (isMobile) return width;
    return width.clamp(0.0, ResponsiveBreakpoints.maxContentWidth);
  }
}

/// Responsive layout widget
/// Builds different layouts based on screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = ResponsiveBuilder(constraints.maxWidth);
        
        if (responsive.isDesktop && desktop != null) {
          return desktop!(context);
        }
        if (responsive.isTablet && tablet != null) {
          return tablet!(context);
        }
        return mobile(context);
      },
    );
  }
}
