// MIGRATED to WL V2 Theme - Uses theme colors
// lib/builder/runtime/builder_theme_resolver.dart
// Theme resolver for Builder B3 runtime
//
// THEME RESOLUTION BEHAVIOR:
// ========================
// - Builder preview uses draftTheme (from theme_draft collection)
// - Client runtime uses publishedTheme (from theme_published collection)
// - Blocks read ThemeConfig via BuilderThemeProvider/context.builderTheme
//
// This ensures admins see live changes in preview, while clients only see
// published theme changes after explicit publish action.
//
// Resolves the appropriate ThemeConfig for block rendering.
// Client runtime uses published theme, Builder uses draft theme.

import 'package:flutter/material.dart';
import '../models/theme_config.dart';
import '../services/theme_service.dart';

/// Resolves theme configuration for Builder blocks
///
/// This class provides theme values for block rendering:
/// - Published theme for client runtime (end users)
/// - Draft theme for Builder preview (admins editing)
///
/// Usage in blocks:
/// ```dart
/// final theme = BuilderThemeResolver.resolve(publishedTheme);
/// final buttonRadius = theme.buttonRadius;
/// ```
class BuilderThemeResolver {
  /// Resolve theme with fallback to defaults
  ///
  /// If [published] is null, returns ThemeConfig.defaultConfig.
  /// This ensures blocks always have valid styling values.
  static ThemeConfig resolve(ThemeConfig? published) {
    return published ?? ThemeConfig.defaultConfig;
  }

  /// Resolve theme for preview with draft updates
  ///
  /// Merges [draftUpdates] into [baseTheme] for live preview.
  /// Used in the Builder editor to show changes before saving.
  static ThemeConfig resolveForPreview(
    ThemeConfig? baseTheme,
    Map<String, dynamic>? draftUpdates,
  ) {
    final theme = baseTheme ?? ThemeConfig.defaultConfig;
    
    if (draftUpdates == null || draftUpdates.isEmpty) {
      return theme;
    }
    
    return theme.mergeForPreview(draftUpdates);
  }

  /// Get button style from theme
  ///
  /// Returns consistent button styling based on theme configuration.
  static ButtonStyle getButtonStyle(ThemeConfig theme, BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: theme.primaryColor,
      foregroundColor: context.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.buttonRadius),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing,
        vertical: theme.spacing * 0.75,
      ),
    );
  }

  /// Get card decoration from theme
  ///
  /// Returns consistent card styling based on theme configuration.
  static BoxDecoration getCardDecoration(
    ThemeConfig theme,
    BuildContext context, {
    Color? backgroundColor,
    double? elevation,
  }) {
    final brightness = theme.getEffectiveBrightness(context);
    final defaultBgColor = brightness == Brightness.dark
        ? const Color(0xFF424242)
        : context.onPrimary;

    return BoxDecoration(
      color: backgroundColor ?? defaultBgColor,
      borderRadius: BorderRadius.circular(theme.cardRadius),
      boxShadow: elevation != null && elevation > 0
          ? [
              BoxShadow(
                color: context.colorScheme.shadow.withOpacity(0.1),
                blurRadius: elevation * 2,
                offset: Offset(0, elevation),
              ),
            ]
          : null,
    );
  }

  /// Get heading text style from theme
  ///
  /// Returns text style for headings/titles.
  static TextStyle getHeadingStyle(ThemeConfig theme, BuildContext context) {
    return TextStyle(
      fontSize: theme.textHeadingSize,
      fontWeight: FontWeight.bold,
      color: theme.getTextColor(context),
    );
  }

  /// Get body text style from theme
  ///
  /// Returns text style for normal body text.
  static TextStyle getBodyStyle(ThemeConfig theme, BuildContext context) {
    return TextStyle(
      fontSize: theme.textBodySize,
      fontWeight: FontWeight.normal,
      color: theme.getTextColor(context),
    );
  }

  /// Get secondary text style from theme
  ///
  /// Returns text style for secondary/lighter text.
  static TextStyle getSecondaryTextStyle(
      ThemeConfig theme, BuildContext context) {
    return TextStyle(
      fontSize: theme.textBodySize * 0.875, // Slightly smaller
      fontWeight: FontWeight.normal,
      color: theme.getSecondaryTextColor(context),
    );
  }

  /// Get block spacing from theme
  ///
  /// Returns EdgeInsets for consistent spacing between blocks.
  static EdgeInsets getBlockSpacing(ThemeConfig theme) {
    return EdgeInsets.only(bottom: theme.spacing);
  }

  /// Get container padding from theme
  ///
  /// Returns EdgeInsets for consistent container padding.
  static EdgeInsets getContainerPadding(ThemeConfig theme) {
    return EdgeInsets.all(theme.spacing);
  }
}

/// Extension on BuildContext for easy theme access
///
/// Usage:
/// ```dart
/// final theme = context.builderTheme;
/// ```
extension BuilderThemeContext on BuildContext {
  /// Get the current builder theme from inherited widget
  ///
  /// Falls back to default config if not found.
  ThemeConfig get builderTheme {
    final inherited =
        dependOnInheritedWidgetOfExactType<BuilderThemeInherited>();
    return inherited?.theme ?? ThemeConfig.defaultConfig;
  }
}

/// Inherited widget for providing ThemeConfig down the widget tree
///
/// Usage:
/// ```dart
/// BuilderThemeProvider(
///   theme: myTheme,
///   child: MyWidget(),
/// )
/// ```
class BuilderThemeProvider extends StatelessWidget {
  final ThemeConfig theme;
  final Widget child;

  const BuilderThemeProvider({
    super.key,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BuilderThemeInherited(
      theme: theme,
      child: child,
    );
  }
}

/// Internal inherited widget for theme propagation
class BuilderThemeInherited extends InheritedWidget {
  final ThemeConfig theme;

  const BuilderThemeInherited({
    super.key,
    required this.theme,
    required super.child,
  });

  @override
  bool updateShouldNotify(BuilderThemeInherited oldWidget) {
    return theme != oldWidget.theme;
  }
}

/// Mixin for blocks that support ThemeConfig
///
/// Provides helper methods for blocks to access theme values
/// with fallback to defaults.
mixin ThemeAwareBlock {
  /// Get primary color from theme or fallback to default
  Color getPrimaryColor(ThemeConfig? theme) {
    return theme?.primaryColor ?? ThemeConfig.defaultConfig.primaryColor;
  }

  /// Get secondary color from theme or fallback to default
  Color getSecondaryColor(ThemeConfig? theme) {
    return theme?.secondaryColor ?? ThemeConfig.defaultConfig.secondaryColor;
  }

  /// Get button radius from theme or fallback to default
  double getButtonRadius(ThemeConfig? theme) {
    return theme?.buttonRadius ?? ThemeConfig.defaultConfig.buttonRadius;
  }

  /// Get card radius from theme or fallback to default
  double getCardRadius(ThemeConfig? theme) {
    return theme?.cardRadius ?? ThemeConfig.defaultConfig.cardRadius;
  }

  /// Get heading text size from theme or fallback to default
  double getHeadingSize(ThemeConfig? theme) {
    return theme?.textHeadingSize ?? ThemeConfig.defaultConfig.textHeadingSize;
  }

  /// Get body text size from theme or fallback to default
  double getBodySize(ThemeConfig? theme) {
    return theme?.textBodySize ?? ThemeConfig.defaultConfig.textBodySize;
  }

  /// Get spacing from theme or fallback to default
  double getSpacing(ThemeConfig? theme) {
    return theme?.spacing ?? ThemeConfig.defaultConfig.spacing;
  }

  /// Get background color from theme or fallback to default
  Color getBackgroundColor(ThemeConfig? theme) {
    return theme?.backgroundColor ?? ThemeConfig.defaultConfig.backgroundColor;
  }
}

/// Provider-based theme resolver for use with Riverpod
///
/// Creates a FutureProvider for loading published theme.
/// Usage with Riverpod in block widgets.
class ThemeResolverService {
  final ThemeService _themeService;

  ThemeResolverService({ThemeService? themeService})
      : _themeService = themeService ?? ThemeService();

  /// Load and resolve theme for runtime
  Future<ThemeConfig> loadRuntimeTheme(String appId) async {
    return await _themeService.loadPublishedTheme(appId);
  }

  /// Load and resolve theme for builder preview
  Future<ThemeConfig> loadBuilderTheme(String appId) async {
    return await _themeService.loadDraftTheme(appId);
  }

  /// Stream of runtime theme changes
  Stream<ThemeConfig> watchRuntimeTheme(String appId) {
    return _themeService.watchPublishedTheme(appId);
  }

  /// Stream of builder theme changes
  Stream<ThemeConfig> watchBuilderTheme(String appId) {
    return _themeService.watchDraftTheme(appId);
  }
}
