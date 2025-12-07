# Builder B3 - Restaurant Plan Module Filtering

## Overview

This document describes how the Builder B3 editor has been connected to the Restaurant Plan White Label (WL) system to ensure that the "Add Block" modal respects the enabled/disabled modules configured in SuperAdmin.

## Problem Statement

Previously, the Builder B3 editor would display ALL system modules in the "Add Block" modal, regardless of whether those modules were enabled or disabled in the restaurant's SuperAdmin configuration. This created a confusing user experience where disabled modules (like Roulette, Loyalty, Promotions) would appear as available options even though they were turned OFF in the plan.

## Solution

The solution involves propagating the `RestaurantPlanUnified` object from the editor through to the `BlockAddDialog` so that it can filter the available system modules based on the plan configuration.

### Key Components

1. **RestaurantPlanUnified**: The source of truth for which modules are enabled/disabled for a restaurant
2. **SystemBlock.getFilteredModules(plan)**: The filtering function that returns only modules allowed by the plan
3. **builder_modules.dart**: Contains the mapping between Builder module IDs and WL ModuleIds

### Implementation Details

#### 1. Builder Page Editor Screen (`builder_page_editor_screen.dart`)

**Changes:**
- Added state variable `_restaurantPlan` to store the plan
- Modified `_buildEditor()` to store the plan in state
- Updated `_buildResponsiveLayout()` signature to accept plan parameter
- Modified `_showAddBlockDialog()` to pass `_restaurantPlan` to `BlockAddDialog.show()`

**Code Flow:**
```
build() 
  → watch restaurantPlanUnifiedProvider 
  → _buildEditor(plan) 
  → store in _restaurantPlan 
  → _buildResponsiveLayout(responsive, plan)
  → _showAddBlockDialog() uses _restaurantPlan
```

#### 2. Block Add Dialog (`block_add_dialog.dart`)

**Changes:**
- Changed from `ConsumerWidget` to `StatelessWidget` (no longer loads plan internally)
- Added `restaurantPlan` parameter to constructor and `show()` method
- Updated `_buildSystemModulesList()` to use `SystemBlock.getFilteredModules(plan)`
- Added warning message when plan is null (strict filtering mode)
- Added info message when no modules are available

**Filtering Logic:**
```dart
final moduleIds = SystemBlock.getFilteredModules(restaurantPlan);
```

This single line is the KEY CHANGE that connects SuperAdmin configuration to Builder availability.

### Filtering Behavior

#### When plan is loaded (normal case):
- Modules are filtered based on `plan.hasModule(moduleId)`
- Always-visible modules (menu_catalog, profile_module) are shown regardless
- Legacy modules without WL mapping are always shown

#### When plan is null:
- **OLD BEHAVIOR**: Would show all modules (fallback)
- **NEW BEHAVIOR**: Shows EMPTY list (strict filtering)
- Warning message displayed: "Plan non chargé → seuls les modules toujours visibles sont affichés"

**Note**: In the current implementation, `SystemBlock.getFilteredModules(null)` returns an empty list `[]`. This is intentional to prevent showing modules when the plan is not loaded. When the plan IS loaded, the always-visible modules (menu_catalog, profile_module) are included via the `SystemModules.alwaysVisible` check inside `getFilteredModules()`.

### Module Mapping

The connection between Builder modules and WL modules is defined in `builder_modules.dart`:

```dart
const Map<String, ModuleId> moduleIdMapping = {
  'menu_catalog': ModuleId.ordering,
  'profile_module': ModuleId.ordering,
  'roulette_module': ModuleId.roulette,
  'loyalty_module': ModuleId.loyalty,
  'rewards_module': ModuleId.loyalty,
  'click_collect_module': ModuleId.clickAndCollect,
  'kitchen_module': ModuleId.kitchen_tablet,
  'staff_module': ModuleId.staff_tablet,
  'promotions_module': ModuleId.promotions,
  'newsletter_module': ModuleId.newsletter,
  // Legacy modules without mapping are always visible
};
```

### Always-Visible Modules

Certain core modules are always visible in the Builder regardless of plan configuration:

```dart
class SystemModules {
  static const List<String> alwaysVisible = [
    'menu_catalog',    // Core product catalog - always needed
    'profile_module',  // User profile - always needed
  ];
}
```

## Testing

### Manual Test Cases

#### Test Case 1: Selective Module Activation
**Setup:**
- In SuperAdmin, enable only: Commandes en ligne, Livraison, Click & Collect, Thème
- Disable: Fidélité, Roulette, Promotions, Newsletter, Tablette

**Expected Result:**
- Open Builder, click "Ajouter un bloc"
- "Modules système" section shows only:
  - menu_catalog (always visible)
  - profile_module (always visible)
  - click_collect_module (enabled in plan)
- Disabled modules (roulette, loyalty, promotions, newsletter) do NOT appear

#### Test Case 2: Minimal Configuration
**Setup:**
- In SuperAdmin, disable all optional WL features
- Keep only minimum required modules

**Expected Result:**
- Open Builder, click "Ajouter un bloc"
- System modules list drastically reduced
- App does not crash
- Existing system pages remain editable
- Cannot add new blocks for disabled modules

#### Test Case 3: Plan Not Loaded
**Setup:**
- Simulate plan loading failure or null plan

**Expected Result:**
- BlockAddDialog displays warning message
- Shows only always-visible modules OR empty list
- Does NOT show all modules (old behavior)
- No crash or error

## Architecture Benefits

1. **Single Source of Truth**: SuperAdmin plan configuration is the only source of truth
2. **No Duplication**: No need to maintain separate lists in Builder
3. **Automatic Sync**: Changes in SuperAdmin immediately reflect in Builder
4. **Type Safety**: Uses strongly-typed ModuleId enum
5. **Graceful Degradation**: Safe behavior when plan is null
6. **Clear Feedback**: Warning messages inform users of filtering state

## Related Files

- `lib/builder/editor/builder_page_editor_screen.dart`: Main editor screen
- `lib/builder/editor/widgets/block_add_dialog.dart`: Add block modal dialog
- `lib/builder/models/builder_block.dart`: SystemBlock class and filtering logic
- `lib/builder/utils/builder_modules.dart`: Module mapping configuration
- `lib/src/providers/restaurant_plan_provider.dart`: Plan provider
- `lib/white_label/restaurant/restaurant_plan_unified.dart`: Plan model

## Future Improvements

1. **Loading State**: Show loading indicator while plan is being fetched (currently assumes plan is already loaded)
2. **Error Handling**: Better error messages when plan fails to load
3. **Module Dependencies**: Handle modules that depend on other modules
4. **Preview Mode**: Show disabled modules with visual indication they're disabled (rather than hiding them)
5. **Permissions**: Consider user roles when filtering modules (admin vs regular user)

## Breaking Changes

**⚠️ IMPORTANT**: The behavior when `plan` is null has changed:

- **Before**: Would show all modules (permissive fallback)
- **After**: Shows empty list (strict filtering)

This is intentional to prevent users from adding modules that might not work. Callers must ensure the plan is loaded before showing the dialog. In practice, the editor already loads the plan via `restaurantPlanUnifiedProvider`, so this should not cause issues.

## Verification Checklist

Before deploying this change, verify:

- [ ] Plan loads correctly in Builder editor
- [ ] Modules are filtered according to SuperAdmin config
- [ ] Always-visible modules always appear
- [ ] Disabled modules do NOT appear
- [ ] No runtime errors when plan is null
- [ ] Warning messages display correctly
- [ ] Empty state message displays when no modules available
- [ ] Existing system pages remain editable
- [ ] Cannot add blocks for disabled modules

## Conclusion

This patch creates a clean, minimal connection between SuperAdmin configuration and Builder availability. The changes are surgical and focused, touching only the necessary files to propagate the plan through the editor to the module selection dialog.

The key insight is that `SystemBlock.getFilteredModules(plan)` already existed and contained all the filtering logic. We simply needed to ensure the plan was passed to it from the editor.
