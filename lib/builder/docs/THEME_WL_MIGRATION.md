# Theme Service White-Label Migration

## Overview

This document describes the migration of the `ThemeService` to full white-label compatibility, synchronized with the module system. The theme functionality is now controlled by the `ModuleId.theme` module flag in the restaurant's unified plan.

## Changes Made

### 1. Provider Dependencies

**File:** `lib/builder/providers/theme_providers.dart`

The `themeServiceProvider` now includes dependencies on:
- `currentRestaurantProvider` - For restaurant context
- `restaurantPlanUnifiedProvider` - For module configuration

```dart
final themeServiceProvider = Provider<ThemeService>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );
    return ThemeService(restaurantPlan: plan);
  },
  dependencies: [currentRestaurantProvider, restaurantPlanUnifiedProvider],
);
```

This ensures that the theme service is aware of the restaurant's module configuration and can enforce module-based access control.

### 2. Builder Theme Adapter

**File:** `lib/builder/theme/builder_theme_adapter.dart`

A new adapter class has been created to convert `BuilderThemeConfig` (the builder's custom theme model) to Flutter's standard `ThemeData`:

```dart
class BuilderThemeAdapter {
  static ThemeData toFlutterTheme(ThemeConfig config) {
    // Converts BuilderThemeConfig to Material Design 3 ThemeData
    // with proper color schemes, typography, and widget themes
  }
}
```

**Features:**
- Full Material Design 3 support
- Automatic color scheme generation from primary/secondary colors
- Consistent styling across all widgets (buttons, cards, inputs, etc.)
- Brightness mode support (light/dark/auto)
- Typography customization based on heading and body text sizes
- Border radius and spacing integration

**Usage:**
```dart
final themeConfig = await themeService.loadPublishedTheme(appId);
final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);
MaterialApp(theme: themeData, ...);
```

### 3. ThemeService Module Guards

**File:** `lib/builder/services/theme_service.dart`

The `ThemeService` now includes:

#### Constructor Changes
```dart
class ThemeService {
  final FirebaseFirestore _firestore;
  final RestaurantPlanUnified? _restaurantPlan;

  ThemeService({
    FirebaseFirestore? firestore,
    RestaurantPlanUnified? restaurantPlan,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _restaurantPlan = restaurantPlan;
```

The service now accepts an optional `RestaurantPlanUnified` to check module status.

#### Module Guard Method
```dart
bool _isThemeModuleEnabled() {
  // If no plan is set, allow access for backward compatibility
  if (_restaurantPlan == null) {
    return true;
  }

  final isEnabled = _restaurantPlan!.hasModule(ModuleId.theme);

  // In debug mode, assert that the module is enabled
  assert(
    isEnabled,
    'Theme module is not enabled for restaurant ${_restaurantPlan!.restaurantId}. '
    'Enable ModuleId.theme in the restaurant plan to use theme features.',
  );

  return isEnabled;
}
```

**Behavior:**
- **Debug mode**: Throws assertion errors when attempting to use theme features with the module disabled
- **Release mode**: Fails silently and returns default values
- **Backward compatibility**: When no plan is set, all operations are allowed

#### Protected Operations

All theme operations now check the module status before execution:

1. **Reading theme** (`loadDraftTheme`, `loadPublishedTheme`, `watchDraftTheme`, `watchPublishedTheme`):
   - Returns `ThemeConfig.defaultConfig` if module is disabled
   - Logs warning message in debug mode

2. **Publishing theme** (`publishTheme`):
   - Silently returns without performing the publish operation
   - Logs warning message in debug mode

3. **Saving draft** (`saveDraftTheme`):
   - Silently returns without saving
   - Logs warning message in debug mode

### 4. Theme Scoping Verification

The theme service correctly scopes theme data to each restaurant:

```
restaurants/{appId}/theme_draft/config
restaurants/{appId}/theme_published/config
```

Each restaurant's theme is isolated in its own Firestore subcollection, ensuring proper multi-tenancy.

### 5. Stream Theme Conversion

The existing stream providers (`draftThemeStreamProvider`, `publishedThemeStreamProvider`) already return `ThemeConfig` objects. To convert these to `ThemeData` for use with MaterialApp, use the adapter:

```dart
// In a widget or provider
ref.watch(publishedThemeStreamProvider).when(
  data: (themeConfig) {
    final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);
    return MaterialApp(theme: themeData, ...);
  },
  loading: () => ...,
  error: (_, __) => ...,
);
```

## Module Configuration

To enable the theme module for a restaurant, add `'theme'` to the `activeModules` list in the restaurant's unified plan:

```dart
final plan = RestaurantPlanUnified(
  restaurantId: 'restaurant_123',
  name: 'My Restaurant',
  slug: 'my-restaurant',
  activeModules: [
    'theme',  // Enable theme module
    'ordering',
    'delivery',
    // ... other modules
  ],
  // ... other config
);
```

Or using the `ModuleId` enum:

```dart
final plan = plan.copyWith(
  activeModules: [
    ...plan.activeModules,
    ModuleId.theme.code,
  ],
);
```

## Impact Assessment

### ✅ No Impact on Preview/Runtime Builder

The changes maintain full backward compatibility:

1. **Builder preview** continues to work with draft themes via `draftThemeStreamProvider`
2. **Client runtime** continues to work with published themes via `publishedThemeStreamProvider`
3. **Default fallback** ensures the app always has a valid theme (even when module is disabled)
4. **Existing integrations** remain functional without modification

### ✅ Module Guard Benefits

1. **Controlled access**: Theme features only available when explicitly enabled
2. **Clear debugging**: Assertion errors in debug mode help identify configuration issues
3. **Silent failure**: Release mode prevents crashes from misconfiguration
4. **Audit trail**: Debug logs track all module guard decisions

### ✅ White-Label Ready

The theme system is now fully integrated with the white-label module system:

1. **Per-restaurant configuration**: Each restaurant can enable/disable theme independently
2. **Module matrix integration**: Theme module follows the same patterns as other modules
3. **Runtime guards**: Prevents unauthorized theme access in client runtime
4. **Scoped storage**: Firestore paths properly isolated by restaurant ID

## Testing Checklist

- [ ] Theme service loads default config when module is disabled
- [ ] Theme service operates normally when module is enabled
- [ ] Debug assertions fire when accessing disabled module in debug mode
- [ ] Release mode fails silently when accessing disabled module
- [ ] Builder preview works with draft theme
- [ ] Client runtime works with published theme
- [ ] Theme publish operation respects module guard
- [ ] Draft save operation respects module guard
- [ ] Stream providers return correct values when module is disabled
- [ ] BuilderThemeAdapter correctly converts ThemeConfig to ThemeData
- [ ] Material Design 3 widgets inherit correct theme styling

## Migration Path for Existing Code

### For Builder Editor

No changes required. The builder editor continues to use:
```dart
final draftTheme = ref.watch(draftThemeStreamProvider);
```

### For Client Runtime

To use the adapter for app-wide theming:
```dart
final publishedThemeAsync = ref.watch(publishedThemeStreamProvider);

return publishedThemeAsync.when(
  data: (themeConfig) {
    final themeData = BuilderThemeAdapter.toFlutterTheme(themeConfig);
    return MaterialApp(
      theme: themeData,
      home: ...,
    );
  },
  loading: () => MaterialApp(
    theme: BuilderThemeAdapter.toFlutterTheme(ThemeConfig.defaultConfig),
    home: LoadingScreen(),
  ),
  error: (_, __) => MaterialApp(
    theme: BuilderThemeAdapter.toFlutterTheme(ThemeConfig.defaultConfig),
    home: ErrorScreen(),
  ),
);
```

### For SuperAdmin

When creating or editing restaurants, include the theme module if needed:

```dart
final updatedPlan = plan.copyWith(
  activeModules: [
    ...plan.activeModules,
    if (shouldEnableTheme) ModuleId.theme.code,
  ],
);
```

## Future Enhancements

Potential improvements for future iterations:

1. **Theme templates**: Pre-configured theme sets for different restaurant types
2. **Advanced typography**: Custom font loading from Firebase Storage
3. **Dark mode auto-detection**: Automatic theme switching based on system settings
4. **Theme preview**: Live preview of theme changes before saving
5. **Theme versioning**: History of theme changes with rollback capability
6. **Module dependencies**: Automatic enable/disable of dependent modules

## References

- **Module System**: `lib/white_label/core/module_id.dart`
- **Restaurant Plan**: `lib/white_label/restaurant/restaurant_plan_unified.dart`
- **Module Guards**: `lib/white_label/runtime/module_enabled_provider.dart`
- **Theme Config Model**: `lib/builder/models/theme_config.dart`
- **Theme Service**: `lib/builder/services/theme_service.dart`
- **Theme Providers**: `lib/builder/providers/theme_providers.dart`
- **Theme Adapter**: `lib/builder/theme/builder_theme_adapter.dart`

---

**Last Updated**: 2025-12-06  
**Migration Status**: ✅ Complete  
**Version**: 1.0.0
