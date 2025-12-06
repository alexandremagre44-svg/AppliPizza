// lib/builder/providers/theme_providers.dart
// Riverpod providers for ThemeConfig in Builder B3 system
//
// Provides theme configuration for:
// - Builder editor (draft theme)
// - Client runtime (published theme)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme_config.dart';
import '../services/theme_service.dart';
import '../../src/providers/restaurant_provider.dart';
import '../../src/providers/restaurant_plan_provider.dart';

/// Service provider for ThemeService
/// Provides singleton instance of the theme service with restaurant plan integration
///
/// This provider now depends on currentRestaurantProvider to ensure proper
/// scoping of theme operations per restaurant. The service will check if the
/// theme module is enabled before performing any operations.
final themeServiceProvider = Provider<ThemeService>(
  (ref) {
    // Watch the unified plan to get module configuration
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    
    // Extract the plan if available
    final plan = planAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );
    
    return ThemeService(restaurantPlan: plan);
  },
  dependencies: [currentRestaurantProvider, restaurantPlanUnifiedProvider],
);

/// Provider for published theme configuration
///
/// Used by client runtime to get the published theme.
/// Falls back to default config if no published theme exists.
///
/// Usage:
/// ```dart
/// final themeAsync = ref.watch(publishedThemeProvider);
/// themeAsync.when(
///   data: (theme) => BuilderThemeProvider(theme: theme, child: ...),
///   loading: () => LoadingIndicator(),
///   error: (_, __) => BuilderThemeProvider(theme: ThemeConfig.defaultConfig, child: ...),
/// );
/// ```
final publishedThemeProvider = FutureProvider<ThemeConfig>(
  (ref) async {
    final service = ref.watch(themeServiceProvider);
    final appId = ref.watch(currentRestaurantProvider).id;
    return await service.loadPublishedTheme(appId);
  },
  dependencies: [currentRestaurantProvider],
);

/// Stream provider for real-time published theme updates
///
/// Use this when you need live updates as the published theme changes.
final publishedThemeStreamProvider = StreamProvider<ThemeConfig>(
  (ref) {
    final service = ref.watch(themeServiceProvider);
    final appId = ref.watch(currentRestaurantProvider).id;
    return service.watchPublishedTheme(appId);
  },
  dependencies: [currentRestaurantProvider],
);

/// Provider for draft theme configuration
///
/// Used by Builder editor to get the draft theme for editing.
/// Falls back to default config if no draft theme exists.
///
/// Usage:
/// ```dart
/// final draftThemeAsync = ref.watch(draftThemeProvider);
/// ```
final draftThemeProvider = FutureProvider<ThemeConfig>(
  (ref) async {
    final service = ref.watch(themeServiceProvider);
    final appId = ref.watch(currentRestaurantProvider).id;
    return await service.loadDraftTheme(appId);
  },
  dependencies: [currentRestaurantProvider],
);

/// Stream provider for real-time draft theme updates
///
/// Use this in the Builder editor for live preview updates.
final draftThemeStreamProvider = StreamProvider<ThemeConfig>(
  (ref) {
    final service = ref.watch(themeServiceProvider);
    final appId = ref.watch(currentRestaurantProvider).id;
    return service.watchDraftTheme(appId);
  },
  dependencies: [currentRestaurantProvider],
);

/// StateNotifier for managing draft theme edits in the Builder
///
/// Provides methods for:
/// - Loading draft theme
/// - Updating theme values
/// - Saving draft
/// - Publishing theme
/// - Resetting to defaults
class DraftThemeNotifier extends StateNotifier<AsyncValue<ThemeConfig>> {
  final ThemeService _service;
  final String _appId;
  bool _hasUnsavedChanges = false;

  DraftThemeNotifier({
    required ThemeService service,
    required String appId,
  })  : _service = service,
        _appId = appId,
        super(const AsyncValue.loading()) {
    _loadTheme();
  }

  /// Whether there are unsaved changes
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  /// Load the draft theme from Firestore
  Future<void> _loadTheme() async {
    try {
      state = const AsyncValue.loading();
      final theme = await _service.loadDraftTheme(_appId);
      state = AsyncValue.data(theme);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reload the draft theme
  Future<void> reload() async {
    await _loadTheme();
    _hasUnsavedChanges = false;
  }

  /// Update theme with partial updates
  ///
  /// This immediately updates the local state and marks as having unsaved changes.
  /// Call [save] to persist changes to Firestore.
  void updateTheme(Map<String, dynamic> updates) {
    state.whenData((currentTheme) {
      final updatedTheme = currentTheme.mergeForPreview(updates);
      state = AsyncValue.data(updatedTheme);
      _hasUnsavedChanges = true;
    });
  }

  /// Save the current draft theme to Firestore
  Future<void> save() async {
    final currentTheme = state.valueOrNull;
    if (currentTheme == null) return;

    try {
      await _service.saveDraftTheme(_appId, currentTheme);
      _hasUnsavedChanges = false;
    } catch (e) {
      rethrow;
    }
  }

  /// Publish the current draft theme
  ///
  /// This copies the draft to published, making it visible to clients.
  Future<void> publish({String? userId}) async {
    // First save any pending changes
    await save();
    
    // Then publish
    await _service.publishTheme(_appId, userId: userId);
  }

  /// Reset to default theme
  Future<void> resetToDefaults({String? userId}) async {
    await _service.resetToDefaults(_appId, userId: userId);
    await reload();
  }

  /// Discard changes and reload from Firestore
  Future<void> discardChanges() async {
    await reload();
  }
}

/// Provider for DraftThemeNotifier
///
/// Usage in Builder editor:
/// ```dart
/// final draftNotifier = ref.watch(draftThemeNotifierProvider.notifier);
/// final draftState = ref.watch(draftThemeNotifierProvider);
///
/// // Update theme
/// draftNotifier.updateTheme({'primaryColor': '#FF0000'});
///
/// // Save changes
/// await draftNotifier.save();
///
/// // Publish theme
/// await draftNotifier.publish(userId: 'admin');
/// ```
final draftThemeNotifierProvider =
    StateNotifierProvider<DraftThemeNotifier, AsyncValue<ThemeConfig>>(
  (ref) {
    final service = ref.watch(themeServiceProvider);
    final appId = ref.watch(currentRestaurantProvider).id;
    return DraftThemeNotifier(service: service, appId: appId);
  },
  dependencies: [currentRestaurantProvider],
);

/// Provider for checking if theme has been published
final hasPublishedThemeProvider = FutureProvider<bool>(
  (ref) async {
    final service = ref.watch(themeServiceProvider);
    final appId = ref.watch(currentRestaurantProvider).id;
    return await service.hasPublishedTheme(appId);
  },
  dependencies: [currentRestaurantProvider],
);

/// Provider for checking if draft theme exists
final hasDraftThemeProvider = FutureProvider<bool>(
  (ref) async {
    final service = ref.watch(themeServiceProvider);
    final appId = ref.watch(currentRestaurantProvider).id;
    return await service.hasDraftTheme(appId);
  },
  dependencies: [currentRestaurantProvider],
);
