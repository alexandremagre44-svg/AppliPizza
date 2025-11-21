// lib/src/models/theme_config.dart
// Theme configuration model for global app customization

import 'package:flutter/material.dart';

/// Configuration for app theme colors
class ThemeColorsConfig {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color error;

  const ThemeColorsConfig({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.error,
  });

  factory ThemeColorsConfig.defaultConfig() {
    return const ThemeColorsConfig(
      primary: Color(0xFFD32F2F),
      secondary: Color(0xFF8E4C4C),
      background: Color(0xFFF5F5F5),
      surface: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF323232),
      textSecondary: Color(0xFF5A5A5A),
      success: Color(0xFF4CAF50),
      warning: Color(0xFFFF9800),
      error: Color(0xFFC62828),
    );
  }

  factory ThemeColorsConfig.fromMap(Map<String, dynamic> map) {
    return ThemeColorsConfig(
      primary: Color(map['primary'] ?? 0xFFD32F2F),
      secondary: Color(map['secondary'] ?? 0xFF8E4C4C),
      background: Color(map['background'] ?? 0xFFF5F5F5),
      surface: Color(map['surface'] ?? 0xFFFFFFFF),
      textPrimary: Color(map['textPrimary'] ?? 0xFF323232),
      textSecondary: Color(map['textSecondary'] ?? 0xFF5A5A5A),
      success: Color(map['success'] ?? 0xFF4CAF50),
      warning: Color(map['warning'] ?? 0xFFFF9800),
      error: Color(map['error'] ?? 0xFFC62828),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primary': primary.value,
      'secondary': secondary.value,
      'background': background.value,
      'surface': surface.value,
      'textPrimary': textPrimary.value,
      'textSecondary': textSecondary.value,
      'success': success.value,
      'warning': warning.value,
      'error': error.value,
    };
  }

  ThemeColorsConfig copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return ThemeColorsConfig(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }
}

/// Configuration for typography
class TypographyConfig {
  final double baseSize;
  final double scaleFactor;
  final String fontFamily;

  const TypographyConfig({
    required this.baseSize,
    required this.scaleFactor,
    required this.fontFamily,
  });

  factory TypographyConfig.defaultConfig() {
    return const TypographyConfig(
      baseSize: 14.0,
      scaleFactor: 1.2,
      fontFamily: 'Roboto',
    );
  }

  factory TypographyConfig.fromMap(Map<String, dynamic> map) {
    return TypographyConfig(
      baseSize: (map['baseSize'] ?? 14.0).toDouble(),
      scaleFactor: (map['scaleFactor'] ?? 1.2).toDouble(),
      fontFamily: map['fontFamily'] ?? 'Roboto',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baseSize': baseSize,
      'scaleFactor': scaleFactor,
      'fontFamily': fontFamily,
    };
  }

  TypographyConfig copyWith({
    double? baseSize,
    double? scaleFactor,
    String? fontFamily,
  }) {
    return TypographyConfig(
      baseSize: baseSize ?? this.baseSize,
      scaleFactor: scaleFactor ?? this.scaleFactor,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

/// Configuration for border radius
class RadiusConfig {
  final double small;
  final double medium;
  final double large;
  final double full;

  const RadiusConfig({
    required this.small,
    required this.medium,
    required this.large,
    required this.full,
  });

  factory RadiusConfig.defaultConfig() {
    return const RadiusConfig(
      small: 8.0,
      medium: 12.0,
      large: 16.0,
      full: 9999.0,
    );
  }

  factory RadiusConfig.fromMap(Map<String, dynamic> map) {
    return RadiusConfig(
      small: (map['small'] ?? 8.0).toDouble(),
      medium: (map['medium'] ?? 12.0).toDouble(),
      large: (map['large'] ?? 16.0).toDouble(),
      full: (map['full'] ?? 9999.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'small': small,
      'medium': medium,
      'large': large,
      'full': full,
    };
  }

  RadiusConfig copyWith({
    double? small,
    double? medium,
    double? large,
    double? full,
  }) {
    return RadiusConfig(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      full: full ?? this.full,
    );
  }
}

/// Configuration for shadows
class ShadowsConfig {
  final double card;
  final double modal;
  final double navbar;

  const ShadowsConfig({
    required this.card,
    required this.modal,
    required this.navbar,
  });

  factory ShadowsConfig.defaultConfig() {
    return const ShadowsConfig(
      card: 2.0,
      modal: 8.0,
      navbar: 4.0,
    );
  }

  factory ShadowsConfig.fromMap(Map<String, dynamic> map) {
    return ShadowsConfig(
      card: (map['card'] ?? 2.0).toDouble(),
      modal: (map['modal'] ?? 8.0).toDouble(),
      navbar: (map['navbar'] ?? 4.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'card': card,
      'modal': modal,
      'navbar': navbar,
    };
  }

  ShadowsConfig copyWith({
    double? card,
    double? modal,
    double? navbar,
  }) {
    return ShadowsConfig(
      card: card ?? this.card,
      modal: modal ?? this.modal,
      navbar: navbar ?? this.navbar,
    );
  }
}

/// Configuration for spacing
class SpacingConfig {
  final double paddingSmall;
  final double paddingMedium;
  final double paddingLarge;

  const SpacingConfig({
    required this.paddingSmall,
    required this.paddingMedium,
    required this.paddingLarge,
  });

  factory SpacingConfig.defaultConfig() {
    return const SpacingConfig(
      paddingSmall: 8.0,
      paddingMedium: 16.0,
      paddingLarge: 24.0,
    );
  }

  factory SpacingConfig.fromMap(Map<String, dynamic> map) {
    return SpacingConfig(
      paddingSmall: (map['paddingSmall'] ?? 8.0).toDouble(),
      paddingMedium: (map['paddingMedium'] ?? 16.0).toDouble(),
      paddingLarge: (map['paddingLarge'] ?? 24.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paddingSmall': paddingSmall,
      'paddingMedium': paddingMedium,
      'paddingLarge': paddingLarge,
    };
  }

  SpacingConfig copyWith({
    double? paddingSmall,
    double? paddingMedium,
    double? paddingLarge,
  }) {
    return SpacingConfig(
      paddingSmall: paddingSmall ?? this.paddingSmall,
      paddingMedium: paddingMedium ?? this.paddingMedium,
      paddingLarge: paddingLarge ?? this.paddingLarge,
    );
  }
}

/// Complete theme configuration model
class ThemeConfig {
  final ThemeColorsConfig colors;
  final TypographyConfig typography;
  final RadiusConfig radius;
  final ShadowsConfig shadows;
  final SpacingConfig spacing;
  final bool darkMode;
  final DateTime updatedAt;

  const ThemeConfig({
    required this.colors,
    required this.typography,
    required this.radius,
    required this.shadows,
    required this.spacing,
    required this.darkMode,
    required this.updatedAt,
  });

  factory ThemeConfig.defaultConfig() {
    return ThemeConfig(
      colors: ThemeColorsConfig.defaultConfig(),
      typography: TypographyConfig.defaultConfig(),
      radius: RadiusConfig.defaultConfig(),
      shadows: ShadowsConfig.defaultConfig(),
      spacing: SpacingConfig.defaultConfig(),
      darkMode: false,
      updatedAt: DateTime.now(),
    );
  }

  factory ThemeConfig.fromMap(Map<String, dynamic> map) {
    return ThemeConfig(
      colors: ThemeColorsConfig.fromMap(map['colors'] ?? {}),
      typography: TypographyConfig.fromMap(map['typography'] ?? {}),
      radius: RadiusConfig.fromMap(map['radius'] ?? {}),
      shadows: ShadowsConfig.fromMap(map['shadows'] ?? {}),
      spacing: SpacingConfig.fromMap(map['spacing'] ?? {}),
      darkMode: map['darkMode'] ?? false,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'colors': colors.toMap(),
      'typography': typography.toMap(),
      'radius': radius.toMap(),
      'shadows': shadows.toMap(),
      'spacing': spacing.toMap(),
      'darkMode': darkMode,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ThemeConfig copyWith({
    ThemeColorsConfig? colors,
    TypographyConfig? typography,
    RadiusConfig? radius,
    ShadowsConfig? shadows,
    SpacingConfig? spacing,
    bool? darkMode,
    DateTime? updatedAt,
  }) {
    return ThemeConfig(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      radius: radius ?? this.radius,
      shadows: shadows ?? this.shadows,
      spacing: spacing ?? this.spacing,
      darkMode: darkMode ?? this.darkMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
