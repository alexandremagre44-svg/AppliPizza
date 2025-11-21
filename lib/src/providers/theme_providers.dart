// lib/src/providers/theme_providers.dart
// Providers for theme management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme_config.dart';
import '../services/theme_service.dart';

/// Service provider
final themeServiceProvider = Provider<ThemeService>((ref) {
  return ThemeService();
});

/// Stream provider for theme config
final themeConfigStreamProvider = StreamProvider<ThemeConfig>((ref) {
  final service = ref.watch(themeServiceProvider);
  return service.watchThemeConfig();
});

/// Future provider for initial theme config load
final themeConfigProvider = FutureProvider<ThemeConfig>((ref) async {
  final service = ref.watch(themeServiceProvider);
  return service.getThemeConfig();
});

/// State provider for draft theme config (local changes before publish)
final draftThemeConfigProvider = StateProvider<ThemeConfig?>((ref) => null);

/// State provider for tracking unsaved changes
final hasUnsavedThemeChangesProvider = StateProvider<bool>((ref) => false);

/// State provider for loading state
final themeLoadingProvider = StateProvider<bool>((ref) => false);

/// State provider for saving state
final themeSavingProvider = StateProvider<bool>((ref) => false);
