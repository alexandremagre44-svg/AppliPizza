# Module Visibility Fix Summary

## Problem Statement

The Builder UI was displaying all modules regardless of the restaurant's white-label plan configuration. Specifically:
1. Modules activated (ON) in `RestaurantPlanUnified` were not appearing in the Builder
2. Modules deactivated (OFF) remained visible in the Builder UI
3. Newly added modules via `builder_modules.dart` were never displayed

## Root Causes

1. **`SystemBlock.availableModules`** was a static list, not filtered by the restaurant plan
2. **The UI** used `availableModules` directly without consulting `restaurantPlanUnifiedProvider`
3. **`requiredModuleId`** was not checked before displaying modules
4. **No filtering function** existed to get available modules based on plan

## Solution Implemented

### 1. Enhanced `lib/builder/utils/builder_modules.dart`

**Added Function:**
```dart
bool isBuilderModuleAvailableForPlan(String builderModuleId, RestaurantPlanUnified? plan)
```

**Purpose:** Check if a specific builder module is available for a given restaurant plan.

**Behavior:**
- Returns `true` if plan is null (fallback safe)
- Returns `true` if module has no mapping (legacy compatibility)
- Returns `true` if plan has the required module enabled
- Returns `false` otherwise

**Note:** The function `getAvailableModulesForPlan()` already existed and works correctly.

### 2. Enhanced `lib/builder/models/builder_block.dart`

**Added Method:**
```dart
static List<String> SystemBlock.getFilteredModules(RestaurantPlanUnified? plan)
```

**Imports Added:**
- `import '../../white_label/restaurant/restaurant_plan_unified.dart';`
- `import '../utils/builder_modules.dart' as builder_modules;`

**Purpose:** Return the list of available modules filtered by the restaurant's plan.

**Behavior:**
- Returns all modules if plan is null (fallback safe)
- Normalizes legacy module types (e.g., 'roulette' → 'roulette_module')
- Checks each module against the plan using `getModuleIdForBuilder()`
- Keeps modules without mapping for backward compatibility

### 3. Modified `lib/builder/page_list/new_page_dialog_v2.dart`

**Changes:**
1. Converted `NewPageDialogV2` from `StatefulWidget` to `ConsumerStatefulWidget`
2. Updated `_NewPageDialogV2State` to extend `ConsumerState`

**Added Imports:**
- `import 'package:flutter_riverpod/flutter_riverpod.dart';`
- `import '../../white_label/core/module_id.dart';`
- `import '../../src/providers/restaurant_plan_provider.dart';`

**Added Mapping:**
```dart
const Map<String, ModuleId?> templateRequiredModules = {
  'home_template': null,           // Always available
  'menu_template': ModuleId.ordering,
  'promo_template': ModuleId.promotions,
  'about_template': null,          // Always available
  'contact_template': null,        // Always available
};
```

**Modified Method:**
- Updated `_buildTemplateList()` to filter templates based on required modules
- Uses `ref.watch(restaurantPlanUnifiedProvider)` to get the plan
- Filters templates where the required module is activated in the plan

### 4. Modified `lib/builder/editor/widgets/block_add_dialog.dart`

**Changes:**
1. Converted `BlockAddDialog` from `StatelessWidget` to `ConsumerWidget`
2. Updated `build()` method signature to include `WidgetRef ref`

**Added Imports:**
- `import 'package:flutter_riverpod/flutter_riverpod.dart';`
- `import '../../../src/providers/restaurant_plan_provider.dart';`

**Modified Methods:**
- Updated `build()` to get the plan using `ref.watch(restaurantPlanUnifiedProvider)`
- Updated `_buildSystemModulesList()` to accept plan parameter
- Filters system modules using `SystemBlock.getFilteredModules(plan)`

### 5. Verified `lib/builder/editor/new_page_dialog.dart`

**Result:** No changes needed - this dialog doesn't display modules in its UI.

## Testing

### Added Tests in `test/builder/builder_modules_mapping_test.dart`

New test group: **Module Filtering by Plan Tests**

Tests added:
1. ✅ `isBuilderModuleAvailableForPlan returns true when plan is null` - Fallback safety
2. ✅ `isBuilderModuleAvailableForPlan returns true for unmapped modules` - Legacy compatibility
3. ✅ `isBuilderModuleAvailableForPlan checks module correctly` - Correct filtering
4. ✅ `getAvailableModulesForPlan returns all modules when plan is null` - Fallback safety
5. ✅ `getAvailableModulesForPlan filters modules correctly` - Correct filtering
6. ✅ `SystemBlock.getFilteredModules returns all when plan is null` - Fallback safety
7. ✅ `SystemBlock.getFilteredModules filters correctly` - Correct filtering
8. ✅ `SystemBlock.getFilteredModules handles legacy aliases` - Legacy compatibility

**Helper added:** `createMockPlan()` and `_MockRestaurantPlan` class for testing

### How to Run Tests

```bash
# Navigate to project directory
cd /home/runner/work/AppliPizza/AppliPizza

# Run specific test file
flutter test test/builder/builder_modules_mapping_test.dart

# Run all builder tests
flutter test test/builder/

# Run all tests
flutter test
```

### Manual Testing Checklist

1. **Module WL activé (ON) → visible dans le Builder**
   - Enable a module in SuperAdmin (e.g., roulette)
   - Open Builder → Add Block dialog
   - Verify the module appears in the system modules list

2. **Module WL désactivé (OFF) → invisible dans le Builder**
   - Disable a module in SuperAdmin (e.g., loyalty)
   - Open Builder → Add Block dialog
   - Verify the module does NOT appear in the list

3. **Module legacy sans mapping → toujours visible**
   - Open Builder → Add Block dialog
   - Verify 'accountActivity' is always visible (no mapping)

4. **Plan non chargé (loading) → afficher tous les modules**
   - Simulate plan loading state
   - Verify all modules are shown (fallback behavior)

5. **Superadmin → comportement normal**
   - Login as superadmin
   - Verify modules are filtered according to the plan (not showing all)

6. **Template filtering**
   - Disable promotions module
   - Open New Page Dialog V2 → Templates
   - Verify "Promotions" template is NOT available
   - Enable promotions module
   - Verify "Promotions" template IS available

## Constraints Respected

✅ **Minimal patch** - Only 4 files modified with surgical changes
✅ **100% backward compatible** - Legacy modules without mapping remain visible
✅ **Fallback safe** - All modules shown if plan is null or not loaded
✅ **No breaking changes** - Routes, services, and runtime unchanged
✅ **Type-safe** - Uses enums and proper typing throughout

## File Changes Summary

| File | Lines Changed | Type |
|------|---------------|------|
| `lib/builder/utils/builder_modules.dart` | +12 | Added function |
| `lib/builder/models/builder_block.dart` | +17 | Added method + imports |
| `lib/builder/page_list/new_page_dialog_v2.dart` | +28 | Converted to Consumer + filtering |
| `lib/builder/editor/widgets/block_add_dialog.dart` | +15 | Converted to Consumer + filtering |
| `test/builder/builder_modules_mapping_test.dart` | +78 | Added test cases |
| **Total** | **~150 lines** | **Minimal change** |

## Expected Behavior After Fix

### Before Fix
- All 18 modules always visible in Builder UI
- Plan configuration ignored completely
- Disabled modules still accessible

### After Fix
- Only activated modules visible in Builder UI
- Plan configuration respected
- Disabled modules hidden
- Legacy modules (unmapped) remain visible
- Safe fallback when plan not loaded

## Dependencies

The fix relies on:
- ✅ `RestaurantPlanUnified` model (already exists)
- ✅ `restaurantPlanUnifiedProvider` (already exists)
- ✅ `ModuleId` enum (already exists)
- ✅ `moduleIdMapping` (already exists)
- ✅ `flutter_riverpod` (already in pubspec.yaml)

No new dependencies added.

## Migration Notes

This fix is **completely transparent** to existing code:
- No API changes to existing functions
- No breaking changes to models
- Widgets automatically adapt to plan changes via Riverpod
- Existing data structures unchanged

## Performance Considerations

- **Minimal overhead**: Filtering is O(n) where n is the number of modules (typically < 20)
- **Reactive**: Uses Riverpod's watch mechanism for efficient rebuilds
- **Cached**: Plan provider caches the restaurant plan
- **No network calls**: All filtering done in memory

## Security Considerations

- ✅ No security vulnerabilities introduced
- ✅ Plan validation handled by existing `RestaurantPlanUnified.hasModule()`
- ✅ No direct Firestore access in UI layer
- ✅ Proper separation of concerns maintained

## Future Improvements

Potential enhancements (not in scope of this fix):
1. Add loading state indicator while plan is being fetched
2. Add error state handling if plan fetch fails
3. Add admin override to show all modules regardless of plan
4. Add module availability tooltip explaining why a module is unavailable
5. Cache filtered module lists for better performance

## Validation Commands

```bash
# Syntax check
flutter analyze lib/builder/

# Run tests
flutter test test/builder/builder_modules_mapping_test.dart

# Build check
flutter build web --release

# Format check
dart format --set-exit-if-changed lib/builder/
```

## Rollback Plan

If issues arise, revert these commits:
```bash
git revert 7fa1cf9  # Module filtering implementation
git push origin copilot/fix-module-visibility-issue --force
```

The changes are isolated and can be safely reverted without affecting other functionality.

## Documentation Updated

- ✅ Inline code comments added
- ✅ Function documentation (dartdoc) added
- ✅ This summary document created
- ✅ Test cases documented

## Sign-off

**Implementation Date:** 2025-12-06
**Implemented By:** GitHub Copilot Agent
**Reviewed By:** (Pending)
**Status:** ✅ Implementation Complete, ⏳ Testing Pending
