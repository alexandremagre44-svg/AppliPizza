// lib/builder/theme/builder_theme_adapter.dart
// Adapter to convert BuilderThemeConfig to Flutter ThemeData
//
// This adapter transforms the builder's ThemeConfig model into a standard
// Flutter ThemeData that can be used with MaterialApp or MaterialTheme.
//
// Usage:
// ```dart
// final themeConfig = await themeService.loadPublishedTheme(appId);
// final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);
// MaterialApp(theme: themeData, ...);
// ```

import 'package:flutter/material.dart';
import '../models/theme_config.dart';

/// Adapter to convert BuilderThemeConfig to Flutter ThemeData.
///
/// This class provides the conversion logic to transform the builder's
/// custom theme configuration into a standard Flutter ThemeData that can
/// be applied to the entire application.
///
/// Features:
/// - Full Material Design 3 support
/// - Automatic color scheme generation from primary/secondary colors
/// - Consistent styling across all widgets
/// - Brightness mode support (light/dark/auto)
/// - Typography customization
/// - Border radius and spacing integration
class BuilderThemeAdapter {
  /// Converts a BuilderThemeConfig to Flutter ThemeData.
  ///
  /// This method takes a [config] containing custom theme values and
  /// generates a complete ThemeData with proper Material Design styling.
  ///
  /// Parameters:
  /// - [config]: The builder theme configuration to convert.
  ///
  /// Returns:
  /// A ThemeData object ready to be used with MaterialApp.
  ///
  /// Example:
  /// ```dart
  /// final themeConfig = ThemeConfig(
  ///   primaryColor: Colors.red,
  ///   secondaryColor: Colors.blue,
  ///   backgroundColor: Colors.grey[100]!,
  ///   buttonRadius: 8.0,
  ///   cardRadius: 12.0,
  ///   textHeadingSize: 24.0,
  ///   textBodySize: 16.0,
  ///   spacing: 16.0,
  ///   brightnessMode: BrightnessMode.light,
  ///   updatedAt: DateTime.now(),
  /// );
  /// final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);
  /// ```
  static ThemeData toFlutterTheme(ThemeConfig config) {
    // Determine brightness based on config
    final brightness = _getBrightness(config.brightnessMode);
    
    // Calculate contrast colors for text
    final onPrimary = _contrastColor(config.primaryColor);
    final onSecondary = _contrastColor(config.secondaryColor);
    final onBackground = _contrastColor(config.backgroundColor);
    
    // Build color scheme
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: config.primaryColor,
      onPrimary: onPrimary,
      primaryContainer: config.primaryColor.withOpacity(0.12),
      onPrimaryContainer: config.primaryColor,
      secondary: config.secondaryColor,
      onSecondary: onSecondary,
      secondaryContainer: config.secondaryColor.withOpacity(0.12),
      onSecondaryContainer: config.secondaryColor,
      tertiary: config.secondaryColor,
      onTertiary: onSecondary,
      tertiaryContainer: config.secondaryColor.withOpacity(0.12),
      onTertiaryContainer: config.secondaryColor,
      error: const Color(0xFFD32F2F), // Material red
      onError: Colors.white,
      errorContainer: const Color(0xFFFFCDD2),
      onErrorContainer: const Color(0xFF5F0000),
      surface: brightness == Brightness.light 
          ? Colors.white 
          : const Color(0xFF121212),
      onSurface: brightness == Brightness.light 
          ? Colors.black87 
          : Colors.white,
      onSurfaceVariant: brightness == Brightness.light 
          ? Colors.black54 
          : Colors.white70,
      outline: Colors.grey.shade400,
      outlineVariant: Colors.grey.shade200,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: brightness == Brightness.light 
          ? const Color(0xFF121212) 
          : Colors.white,
      onInverseSurface: brightness == Brightness.light 
          ? Colors.white 
          : Colors.black87,
      inversePrimary: brightness == Brightness.light
          ? config.primaryColor.withOpacity(0.7)
          : config.primaryColor.withOpacity(1.3),
    );

    // Build text theme with custom sizes
    final textTheme = _buildTextTheme(
      headingSize: config.textHeadingSize,
      bodySize: config.textBodySize,
      color: onBackground,
    );

    return ThemeData(
      useMaterial3: true,
      
      // Color scheme
      colorScheme: colorScheme,
      
      // Background colors
      scaffoldBackgroundColor: config.backgroundColor,
      canvasColor: colorScheme.surface,
      
      // App bar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: config.primaryColor,
        foregroundColor: onPrimary,
        titleTextStyle: TextStyle(
          fontSize: config.textHeadingSize * 0.833, // ~20px for 24px heading
          fontWeight: FontWeight.w600,
          color: onPrimary,
        ),
        iconTheme: IconThemeData(color: onPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: onPrimary, size: 24),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
          foregroundColor: onPrimary,
          elevation: 2,
          shadowColor: config.primaryColor.withOpacity(0.3),
          padding: EdgeInsets.symmetric(
            horizontal: config.spacing * 1.5,
            vertical: config.spacing * 0.75,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonRadius),
          ),
          textStyle: TextStyle(
            fontSize: config.textBodySize * 0.875, // ~14px for 16px body
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: config.primaryColor,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: config.spacing * 1.5,
            vertical: config.spacing * 0.75,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonRadius),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: config.primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: config.spacing,
            vertical: config.spacing * 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonRadius),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: config.primaryColor,
          side: BorderSide(color: Colors.grey.shade400),
          padding: EdgeInsets.symmetric(
            horizontal: config.spacing * 1.5,
            vertical: config.spacing * 0.75,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonRadius),
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: config.spacing,
          vertical: config.spacing,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.buttonRadius),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.buttonRadius),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.buttonRadius),
          borderSide: BorderSide(color: config.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.buttonRadius),
          borderSide: const BorderSide(color: Color(0xFFD32F2F)),
        ),
        labelStyle: TextStyle(
          fontSize: config.textBodySize,
          color: Colors.grey.shade600,
        ),
        hintStyle: TextStyle(
          fontSize: config.textBodySize,
          color: Colors.grey.shade500,
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: config.primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: TextStyle(
          fontSize: config.textBodySize * 0.75, // ~12px for 16px body
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: config.textBodySize * 0.75,
        ),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardRadius),
        ),
      ),
      
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey.shade900,
        contentTextStyle: const TextStyle(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.buttonRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: config.primaryColor.withOpacity(0.12),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.buttonRadius),
        ),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),
      
      // Text theme
      textTheme: textTheme,
      
      // Colors
      splashColor: config.primaryColor.withOpacity(0.1),
      highlightColor: config.primaryColor.withOpacity(0.05),
      hoverColor: Colors.grey.shade50,
      focusColor: config.primaryColor.withOpacity(0.1),
      disabledColor: Colors.grey.shade400,
    );
  }

  /// Builds a text theme with custom heading and body sizes.
  static TextTheme _buildTextTheme({
    required double headingSize,
    required double bodySize,
    required Color color,
  }) {
    return TextTheme(
      // Display styles (largest)
      displayLarge: TextStyle(fontSize: headingSize * 1.5, fontWeight: FontWeight.bold, color: color),
      displayMedium: TextStyle(fontSize: headingSize * 1.333, fontWeight: FontWeight.bold, color: color),
      displaySmall: TextStyle(fontSize: headingSize * 1.167, fontWeight: FontWeight.bold, color: color),
      
      // Headline styles
      headlineLarge: TextStyle(fontSize: headingSize, fontWeight: FontWeight.bold, color: color),
      headlineMedium: TextStyle(fontSize: headingSize * 0.917, fontWeight: FontWeight.w600, color: color),
      headlineSmall: TextStyle(fontSize: headingSize * 0.833, fontWeight: FontWeight.w600, color: color),
      
      // Title styles
      titleLarge: TextStyle(fontSize: bodySize * 1.375, fontWeight: FontWeight.w600, color: color),
      titleMedium: TextStyle(fontSize: bodySize * 1.125, fontWeight: FontWeight.w600, color: color),
      titleSmall: TextStyle(fontSize: bodySize, fontWeight: FontWeight.w600, color: color),
      
      // Body styles
      bodyLarge: TextStyle(fontSize: bodySize * 1.125, fontWeight: FontWeight.normal, color: color),
      bodyMedium: TextStyle(fontSize: bodySize, fontWeight: FontWeight.normal, color: color),
      bodySmall: TextStyle(fontSize: bodySize * 0.875, fontWeight: FontWeight.normal, color: color),
      
      // Label styles (smallest)
      labelLarge: TextStyle(fontSize: bodySize * 0.875, fontWeight: FontWeight.w600, color: color),
      labelMedium: TextStyle(fontSize: bodySize * 0.75, fontWeight: FontWeight.w600, color: color),
      labelSmall: TextStyle(fontSize: bodySize * 0.625, fontWeight: FontWeight.w600, color: color),
    );
  }

  /// Gets brightness from BrightnessMode.
  ///
  /// Note: For BrightnessMode.auto, this returns Brightness.light.
  /// The actual platform brightness should be resolved at the widget level
  /// using ThemeConfig.getEffectiveBrightness(context).
  static Brightness _getBrightness(BrightnessMode mode) {
    switch (mode) {
      case BrightnessMode.dark:
        return Brightness.dark;
      case BrightnessMode.light:
      case BrightnessMode.auto:
      default:
        return Brightness.light;
    }
  }

  /// Calculates the contrast color (black or white) for a given background.
  ///
  /// Uses luminance to determine if text should be black or white
  /// for optimal readability on the given background color.
  static Color _contrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
