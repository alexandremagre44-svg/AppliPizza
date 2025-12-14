# System Module Categorization Implementation

## Overview

This implementation enforces strict separation between system modules and builder modules in the Pizza Deli'Zza Flutter White-Label application. System modules (POS, cart, ordering, payments) are prevented from appearing in the Pages Builder while maintaining full SuperAdmin control.

## Problem Statement

Previously, system modules like `cart_module` were being treated as regular builder blocks/pages, causing runtime errors when POS was disabled. The application needed:

1. Clear categorization of all modules
2. Automatic filtering of system modules from the Pages Builder
3. Silent handling when system modules are disabled
4. Full SuperAdmin control maintained

## Solution Architecture

### 1. Module Categorization (ModuleCategory enum)

Three primary categories were established:

- **`system`**: Core infrastructure modules (POS, ordering, payments, tablets)
  - Never appear in Pages Builder
  - Fixed routes/pages
  - Examples: pos, ordering, payments, paymentTerminal, wallet, kitchen_tablet, staff_tablet

- **`business`**: Business feature modules (delivery, loyalty, promotions)
  - Can appear in Builder if enabled
  - Examples: delivery, clickAndCollect, loyalty, roulette, promotions, newsletter

- **`visual`**: UI/appearance modules
  - Examples: theme, pagesBuilder

### 2. ModuleId Extension

Added `isSystemModule` helper:
```dart
bool get isSystemModule => category == ModuleCategory.system;
```

This provides a simple way to check if any module is a system module.

### 3. Builder Filtering

Modified `SystemBlock.getFilteredModules()` to:
- Accept a `RestaurantPlanUnified` plan
- Get builder modules using the WL → Builder mapping
- Filter out any modules where `wlModuleId.isSystemModule == true`
- Include always-visible modules (menu_catalog, profile_module)
- Log filtering decisions in debug mode

### 4. Runtime Guards

Updated `ModuleGuard` to:
- Check if a module is enabled in the plan
- For system modules that are OFF: return `SizedBox.shrink()` (silent)
- For other modules: show loading indicator during redirect
- Never show error UI to end users

### 5. Editor Safety

Enhanced `BlockAddDialog` to:
- Use `SystemBlock.getFilteredModules()` for the module list
- Check `moduleId.isSystemModule` before adding
- Show error snackbar if user attempts to add a system module
- Log attempted additions in debug mode

## Module Classification

### System Modules (Never in Builder)

| Module ID | Code | Description |
|-----------|------|-------------|
| pos | pos | Point of Sale/Caisse |
| ordering | ordering | Online ordering (includes cart) |
| payments | payments | Payment core |
| paymentTerminal | payment_terminal | Payment terminal |
| wallet | wallet | Electronic wallet |
| kitchen_tablet | kitchen_tablet | Kitchen display |
| staff_tablet | staff_tablet | Staff tablet |

### Business Modules (Builder if Enabled)

| Module ID | Code | Description |
|-----------|------|-------------|
| delivery | delivery | Delivery management |
| clickAndCollect | click_and_collect | Click & Collect |
| loyalty | loyalty | Loyalty program |
| roulette | roulette | Roulette game |
| promotions | promotions | Promotions |
| newsletter | newsletter | Newsletter |
| timeRecorder | time_recorder | Time tracking |
| reporting | reporting | Reports |
| exports | exports | Data exports |
| campaigns | campaigns | Marketing campaigns |

### Visual Modules

| Module ID | Code | Description |
|-----------|------|-------------|
| theme | theme | Theme customization |
| pagesBuilder | pages_builder | Pages builder |

## Behavior Matrix

| Scenario | SuperAdmin | Builder | Runtime | Client UI |
|----------|-----------|---------|---------|-----------|
| POS ON | Visible | Hidden | Active | Hidden from regular users |
| POS OFF | Visible | Hidden | Inactive | No access, silent redirect |
| Ordering ON | Visible | Hidden | Active | Cart works |
| Ordering OFF | Visible | Hidden | Inactive | No cart, silent redirect |
| Loyalty ON | Visible | Visible | Active | Shows in app if added |
| Loyalty OFF | Visible | Hidden | Inactive | Not accessible |

## Key Files Modified

1. **`lib/white_label/core/module_category.dart`**
   - Updated enum with system/business/visual categories
   - Added deprecation guidance for legacy categories
   - Enhanced documentation

2. **`lib/white_label/core/module_id.dart`**
   - Reassigned all modules to new categories
   - Added `isSystemModule` helper
   - Updated category getter

3. **`lib/builder/models/builder_block.dart`**
   - Enhanced `getFilteredModules()` with system module filtering
   - Added debug logging
   - Updated documentation

4. **`lib/white_label/runtime/module_guards.dart`**
   - Modified `_buildRedirectScreen()` to handle system modules silently
   - Returns `SizedBox.shrink()` for disabled system modules
   - Maintains loading indicator for other modules

5. **`lib/builder/editor/widgets/block_add_dialog.dart`**
   - Added system module safety check in `_addSystemBlock()`
   - Shows error snackbar if system module addition attempted
   - Enhanced debug logging

6. **`test/builder/system_module_filtering_test.dart`**
   - Comprehensive test suite for system module behavior
   - Validates categorization
   - Tests filtering logic
   - Ensures system modules never appear in Builder

## Debug Logging

All filtering decisions are logged in debug mode:

```dart
🔍 [SystemBlock.getFilteredModules] cart_module: no WL mapping, allowing (legacy)
🚫 [SystemBlock.getFilteredModules] pos_module: FILTERED OUT (system module: pos)
✅ [SystemBlock.getFilteredModules] loyalty_module: allowed (loyalty, category: Métier)
📦 [SystemBlock.getFilteredModules] Final modules: menu_catalog, profile_module, loyalty_module, roulette_module
```

## Testing

Created comprehensive test suite in `test/builder/system_module_filtering_test.dart`:

- System module identification tests
- Category assignment verification
- Filtering behavior validation
- Plan-based filtering tests
- Edge case coverage

## Backward Compatibility

- Legacy categories (core, payment, marketing, operations, appearance, staff, analytics) are maintained with deprecation warnings
- Deprecation messages include version info: "Will be removed in v2.0."
- All existing code continues to work
- Migration path is clear through deprecation messages

## Security Considerations

- No security vulnerabilities introduced (verified with CodeQL)
- No sensitive data exposed in logs
- Silent redirection prevents information leakage
- SuperAdmin permissions unchanged

## Benefits

1. **Clean Architecture**: Clear separation of concerns
2. **Extensible**: Easy to add new modules to any category
3. **Maintainable**: Well-documented with comprehensive tests
4. **Safe**: Multiple layers of protection against misuse
5. **User-Friendly**: No confusing error messages for end users
6. **Admin-Friendly**: Full control maintained in SuperAdmin

## Future Enhancements

Potential improvements for future versions:

1. Add icons to ModuleCategory for better UI representation
2. Add color coding for different module types in admin UI
3. Create admin dashboard showing module status by category
4. Add bulk module activation/deactivation by category
5. Generate automatic documentation from module metadata

## Conclusion

This implementation successfully prevents system modules from appearing in the Pages Builder while maintaining full SuperAdmin control. The solution is clean, extensible, well-tested, and includes comprehensive debug logging for troubleshooting.
