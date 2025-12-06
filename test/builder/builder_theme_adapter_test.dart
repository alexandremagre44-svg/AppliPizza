/// test/builder/builder_theme_adapter_test.dart
///
/// Tests for BuilderThemeAdapter to verify correct conversion
/// from BuilderThemeConfig to Flutter ThemeData.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza_clean/builder/theme/builder_theme_adapter.dart';
import 'package:pizza_delizza_clean/builder/models/theme_config.dart';

void main() {
  group('BuilderThemeAdapter - ThemeData Conversion', () {
    test('converts default config to valid ThemeData', () {
      final themeConfig = ThemeConfig.defaultConfig;
      final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);

      expect(themeData, isNotNull);
      expect(themeData.useMaterial3, isTrue);
      expect(themeData.colorScheme.primary, equals(themeConfig.primaryColor));
      expect(themeData.colorScheme.secondary, equals(themeConfig.secondaryColor));
      expect(themeData.scaffoldBackgroundColor, equals(themeConfig.backgroundColor));
    });

    test('converts custom colors correctly', () {
      final themeConfig = ThemeConfig(
        primaryColor: const Color(0xFF1976D2), // Blue
        secondaryColor: const Color(0xFF388E3C), // Green
        backgroundColor: const Color(0xFFFAFAFA), // Light grey
        buttonRadius: 12.0,
        cardRadius: 16.0,
        textHeadingSize: 28.0,
        textBodySize: 18.0,
        spacing: 20.0,
        brightnessMode: BrightnessMode.light,
        updatedAt: DateTime.now(),
      );

      final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);

      expect(themeData.colorScheme.primary.value, equals(0xFF1976D2));
      expect(themeData.colorScheme.secondary.value, equals(0xFF388E3C));
      expect(themeData.scaffoldBackgroundColor.value, equals(0xFFFAFAFA));
    });

    test('applies correct border radius to buttons', () {
      final themeConfig = ThemeConfig(
        primaryColor: Colors.red,
        secondaryColor: Colors.blue,
        backgroundColor: Colors.white,
        buttonRadius: 24.0, // Large radius
        cardRadius: 12.0,
        textHeadingSize: 24.0,
        textBodySize: 16.0,
        spacing: 16.0,
        brightnessMode: BrightnessMode.light,
        updatedAt: DateTime.now(),
      );

      final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);

      final elevatedButtonShape = themeData.elevatedButtonTheme.style
          ?.shape?.resolve({});
      expect(elevatedButtonShape, isA<RoundedRectangleBorder>());
      
      final roundedBorder = elevatedButtonShape as RoundedRectangleBorder;
      expect(roundedBorder.borderRadius, equals(BorderRadius.circular(24.0)));
    });

    test('applies correct border radius to cards', () {
      final themeConfig = ThemeConfig(
        primaryColor: Colors.red,
        secondaryColor: Colors.blue,
        backgroundColor: Colors.white,
        buttonRadius: 8.0,
        cardRadius: 20.0, // Large radius
        textHeadingSize: 24.0,
        textBodySize: 16.0,
        spacing: 16.0,
        brightnessMode: BrightnessMode.light,
        updatedAt: DateTime.now(),
      );

      final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);

      expect(themeData.cardTheme.shape, isA<RoundedRectangleBorder>());
      
      final cardShape = themeData.cardTheme.shape as RoundedRectangleBorder;
      expect(cardShape.borderRadius, equals(BorderRadius.circular(20.0)));
    });

    test('uses correct typography sizes', () {
      final themeConfig = ThemeConfig(
        primaryColor: Colors.red,
        secondaryColor: Colors.blue,
        backgroundColor: Colors.white,
        buttonRadius: 8.0,
        cardRadius: 12.0,
        textHeadingSize: 30.0,
        textBodySize: 18.0,
        spacing: 16.0,
        brightnessMode: BrightnessMode.light,
        updatedAt: DateTime.now(),
      );

      final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);

      // Check heading size
      expect(themeData.textTheme.headlineLarge?.fontSize, equals(30.0));
      
      // Check body size
      expect(themeData.textTheme.bodyMedium?.fontSize, equals(18.0));
    });

    test('handles dark mode correctly', () {
      final themeConfig = ThemeConfig(
        primaryColor: Colors.blue,
        secondaryColor: Colors.green,
        backgroundColor: const Color(0xFF121212),
        buttonRadius: 8.0,
        cardRadius: 12.0,
        textHeadingSize: 24.0,
        textBodySize: 16.0,
        spacing: 16.0,
        brightnessMode: BrightnessMode.dark,
        updatedAt: DateTime.now(),
      );

      final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);

      expect(themeData.colorScheme.brightness, equals(Brightness.dark));
      expect(themeData.colorScheme.surface, equals(const Color(0xFF121212)));
    });

    test('handles light mode correctly', () {
      final themeConfig = ThemeConfig(
        primaryColor: Colors.blue,
        secondaryColor: Colors.green,
        backgroundColor: Colors.white,
        buttonRadius: 8.0,
        cardRadius: 12.0,
        textHeadingSize: 24.0,
        textBodySize: 16.0,
        spacing: 16.0,
        brightnessMode: BrightnessMode.light,
        updatedAt: DateTime.now(),
      );

      final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);

      expect(themeData.colorScheme.brightness, equals(Brightness.light));
      expect(themeData.colorScheme.surface, equals(Colors.white));
    });

    test('auto mode defaults to light', () {
      final themeConfig = ThemeConfig(
        primaryColor: Colors.blue,
        secondaryColor: Colors.green,
        backgroundColor: Colors.white,
        buttonRadius: 8.0,
        cardRadius: 12.0,
        textHeadingSize: 24.0,
        textBodySize: 16.0,
        spacing: 16.0,
        brightnessMode: BrightnessMode.auto,
        updatedAt: DateTime.now(),
      );

      final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);

      // Auto mode should default to light in the adapter
      expect(themeData.colorScheme.brightness, equals(Brightness.light));
    });

    test('calculates correct contrast colors', () {
      // Test with dark primary (should have white text)
      final darkTheme = ThemeConfig(
        primaryColor: const Color(0xFF1976D2), // Dark blue
        secondaryColor: Colors.grey,
        backgroundColor: Colors.white,
        buttonRadius: 8.0,
        cardRadius: 12.0,
        textHeadingSize: 24.0,
        textBodySize: 16.0,
        spacing: 16.0,
        brightnessMode: BrightnessMode.light,
        updatedAt: DateTime.now(),
      );

      final darkThemeData = BuilderThemeAdapter.toFlutterTheme(darkTheme);
      
      // Dark primary should have white text
      expect(darkThemeData.colorScheme.onPrimary, equals(Colors.white));

      // Test with light primary (should have black text)
      final lightTheme = darkTheme.copyWith(
        primaryColor: const Color(0xFFFFEB3B), // Yellow (light)
      );

      final lightThemeData = BuilderThemeAdapter.toFlutterTheme(lightTheme);
      
      // Light primary should have black text
      expect(lightThemeData.colorScheme.onPrimary, equals(Colors.black));
    });

    test('applies spacing to button padding', () {
      final themeConfig = ThemeConfig(
        primaryColor: Colors.red,
        secondaryColor: Colors.blue,
        backgroundColor: Colors.white,
        buttonRadius: 8.0,
        cardRadius: 12.0,
        textHeadingSize: 24.0,
        textBodySize: 16.0,
        spacing: 24.0, // Large spacing
        brightnessMode: BrightnessMode.light,
        updatedAt: DateTime.now(),
      );

      final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);

      final buttonPadding = themeData.elevatedButtonTheme.style
          ?.padding?.resolve({});
      
      expect(buttonPadding, isNotNull);
      expect(buttonPadding, equals(EdgeInsets.symmetric(
        horizontal: 24.0 * 1.5,
        vertical: 24.0 * 0.75,
      )));
    });

    test('configures all Material 3 widget themes', () {
      final themeConfig = ThemeConfig.defaultConfig;
      final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);

      // Verify all major widget themes are configured
      expect(themeData.appBarTheme, isNotNull);
      expect(themeData.cardTheme, isNotNull);
      expect(themeData.elevatedButtonTheme, isNotNull);
      expect(themeData.filledButtonTheme, isNotNull);
      expect(themeData.textButtonTheme, isNotNull);
      expect(themeData.outlinedButtonTheme, isNotNull);
      expect(themeData.inputDecorationTheme, isNotNull);
      expect(themeData.bottomNavigationBarTheme, isNotNull);
      expect(themeData.dialogTheme, isNotNull);
      expect(themeData.snackBarTheme, isNotNull);
      expect(themeData.chipTheme, isNotNull);
      expect(themeData.dividerTheme, isNotNull);
    });

    test('maintains consistency across multiple conversions', () {
      final themeConfig = ThemeConfig.defaultConfig;
      
      final themeData1 = BuilderThemeAdapter.toFlutterTheme(themeConfig);
      final themeData2 = BuilderThemeAdapter.toFlutterTheme(themeConfig);

      // Both conversions should produce identical color schemes
      expect(themeData1.colorScheme.primary, equals(themeData2.colorScheme.primary));
      expect(themeData1.colorScheme.secondary, equals(themeData2.colorScheme.secondary));
      expect(themeData1.scaffoldBackgroundColor, equals(themeData2.scaffoldBackgroundColor));
    });
  });
}
