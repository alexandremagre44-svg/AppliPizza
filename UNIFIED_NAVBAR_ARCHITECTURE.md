# Unified Navigation Bar Architecture

## Overview

This document describes the unified navigation bar system that centralizes all visibility logic for the bottom navigation tabs in the AppliPizza application.

## Problem Statement

Previously, the bottom navigation system had scattered visibility logic across multiple files:
- `ScaffoldWithNavBar` had its own filtering
- `NavbarModuleAdapter` provided additional filtering
- `DynamicNavbarBuilder` had module-based logic
- Builder pages had their own visibility settings

This led to:
- Inconsistent behavior
- Difficult maintenance
- Hard to understand which rules applied when
- Potential for bugs when adding new features

## Solution: UnifiedNavBarController

The `UnifiedNavBarController` centralizes ALL navigation visibility logic in one place.

### Architecture

```
UnifiedNavBarController
 ├─ gathers: system pages (menu, cart, profile)
 ├─ gathers: builder dynamic pages
 ├─ gathers: WL module pages
 ├─ filters visibility (WL + builder + role)
 └─ returns final tab list
```

### Key Components

#### 1. NavBarItem Model
```dart
class NavBarItem {
  final String route;
  final String label;
  final String icon;
  final NavItemSource source;  // system/module/builder
  final int order;
  final bool isSystemPage;
  final ModuleId? moduleId;
  final BuilderPage? builderPage;
}
```

#### 2. NavItemSource Enum
```dart
enum NavItemSource {
  system,   // System pages (menu, cart, profile)
  builder,  // Builder dynamic pages
  module,   // Module-driven pages
}
```

#### 3. Main Method: computeNavBarItems()

```dart
static List<NavBarItem> computeNavBarItems({
  required List<BuilderPage> builderPages,
  required RestaurantPlanUnified? plan,
  required bool isAdmin,
})
```

This method:
1. **Collects** all possible tab entries from:
   - System pages (menu, cart, profile)
   - Builder-managed pages (displayLocation == 'bottomBar')
   - Module pages (future expansion)

2. **Filters** them based on:
   - `RestaurantPlanUnified.activeModules` - module activation
   - Builder page settings (`isEnabled`, `isActive`)
   - Page module requirements (`page.modules` list)
   - User role (admin-only pages)

3. **Removes duplicates** - prefers builder over system

4. **Orders** items correctly:
   - Builder custom tabs first
   - System pages next
   - Module tabs last (if any)

5. **Returns** final ordered list ready for rendering

## Visibility Rules

### Rule 1: System Pages
- **Menu** - Always visible
- **Cart** - Only visible if `plan.activeModules.contains('ordering')`
- **Profile** - Always visible

### Rule 2: Builder Pages
A builder page appears in the navbar if ALL of these are true:
- `page.displayLocation == 'bottomBar'`
- `page.isActive == true`
- `page.isEnabled == true`
- If `page.modules` is not empty, at least one module must be active

### Rule 3: Module Pages
- **Loyalty** - NO tab (accessible inside Profile)
- **Roulette** - NO tab (accessible inside Profile)
- Other modules - NO tabs currently (future expansion possible)

### Rule 4: Deduplication
If a builder page has the same route as a system page:
- Keep the builder page
- Remove the system page
- Log the override

## Integration with ScaffoldWithNavBar

The `ScaffoldWithNavBar` widget now uses the controller:

```dart
final navBarItems = UnifiedNavBarController.computeNavBarItems(
  builderPages: builderPages,
  plan: unifiedPlan,
  isAdmin: isAdmin,
);

final bottomNavItems = _convertToBottomNavItems(navBarItems, totalItems);
```

Helper methods:
- `_convertToBottomNavItems()` - converts to BottomNavigationBarItem
- `_calculateSelectedIndexFromNavBarItems()` - finds current tab
- `_onItemTappedFromNavBarItems()` - handles navigation

## Providers

### navBarItemsProvider
```dart
final navBarItemsProvider = FutureProvider.autoDispose<List<NavBarItem>>(...)
```

Returns the computed list of navigation items.

### isPageVisibleProvider
```dart
final isPageVisibleProvider = Provider.family<bool, String>(...)
```

Checks if a specific page route should be visible.

Usage:
```dart
final isCartVisible = ref.watch(isPageVisibleProvider('/cart'));
```

## Testing

Comprehensive test suite in `test/unified_navbar_controller_test.dart`:

- ✅ System page visibility
- ✅ Cart visibility based on ordering module
- ✅ Builder page filtering (isEnabled, isActive)
- ✅ Module requirements filtering
- ✅ Ordering logic
- ✅ Deduplication logic
- ✅ Hidden/internal pages exclusion
- ✅ Loyalty/roulette no-tab rule

## Benefits

1. **Single Source of Truth** - All visibility logic in one place
2. **Easier Maintenance** - One file to update for changes
3. **Better Testing** - Comprehensive unit tests
4. **Clear Visibility Rules** - Well-documented behavior
5. **Consistent Behavior** - No conflicting logic
6. **Future Expansion** - Easy to add new rules

## Migration Notes

### What Changed
- `ScaffoldWithNavBar` now uses `UnifiedNavBarController`
- Old filtering methods (`_buildNavigationItems`, `_applyModuleFiltering`) are now replaced

### What Didn't Change
- Builder editor (separate code path)
- Dynamic page routing (uses same BuilderPage data)
- Existing runtime screens (routing logic intact)
- Fallback navigation (still works for edge cases)

### Backward Compatibility
- ✅ All existing functionality preserved
- ✅ No breaking changes to routes
- ✅ No breaking changes to builder
- ✅ No breaking changes to modules

## Examples

### Example 1: Restaurant with Ordering Module

**Active modules:** `['ordering']`

**Result:**
1. Menu (system)
2. Cart (system - ordering active)
3. Profile (system)

### Example 2: Restaurant with Custom Builder Page

**Active modules:** `['ordering']`
**Builder pages:** 
- Promotions page (displayLocation: 'bottomBar', isActive: true)

**Result:**
1. Promotions (builder)
2. Menu (system)
3. Cart (system)
4. Profile (system)

### Example 3: Restaurant Without Ordering

**Active modules:** `[]`

**Result:**
1. Menu (system)
2. Profile (system)

Note: Cart is hidden because ordering module is not active.

### Example 4: Builder Override

**Active modules:** `['ordering']`
**Builder pages:**
- Custom Menu page (route: '/menu', displayLocation: 'bottomBar')

**Result:**
1. Custom Menu (builder - overrides system menu)
2. Cart (system)
3. Profile (system)

## Future Enhancements

Possible future additions:
1. Module pages with their own tabs (if needed)
2. Role-based filtering (non-admin users)
3. Conditional ordering based on restaurant settings
4. A/B testing support for navigation layouts
5. Analytics integration for tab usage

## Related Files

- `lib/src/navigation/unified_navbar_controller.dart` - Main controller
- `lib/src/widgets/scaffold_with_nav_bar.dart` - UI integration
- `test/unified_navbar_controller_test.dart` - Unit tests
- `lib/white_label/runtime/navbar_module_adapter.dart` - Legacy adapter (may be deprecated)
- `lib/src/navigation/dynamic_navbar_builder.dart` - Legacy builder (may be deprecated)

## Conclusion

The UnifiedNavBarController provides a clean, maintainable, and well-tested solution for managing bottom navigation visibility in a White-Label-aware application. All visibility rules are now centralized, documented, and tested.
