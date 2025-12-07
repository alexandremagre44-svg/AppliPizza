# White Label System Pages Integration

## Overview

This document describes the integration of White Label (WL) system pages that are managed independently from the Builder. These pages are activated/deactivated based on the restaurant's WL plan configuration.

## Architecture Changes

### Before (Old System)
- Cart and Delivery modules were Builder blocks (`cart_module`, `delivery_module`)
- They appeared in the Builder's block selection dialog
- Admins could add/remove them as blocks on pages
- Mixed admin/runtime logic in the same components

### After (New System)
- Cart and Delivery are **system pages** managed by `SystemPageManager`
- They do NOT appear in the Builder's block selection
- They are automatically enabled/disabled based on the restaurant's WL plan
- Clear separation between system pages and builder-editable content

## System Pages

### SystemPageId Enum

```dart
enum SystemPageId {
  menu,    // Always active
  cart,    // Requires ordering module
  profile, // Always active
  admin,   // Always active (access controlled by auth)
}
```

### Page Activation Rules

| Page | Activation Rule | Module Required |
|------|----------------|-----------------|
| Menu | Always active | - |
| Cart | Enabled if ordering module is active | `ModuleId.ordering` |
| Profile | Always active | - |
| Admin | Always active (auth-controlled) | - |

## Provider: enabledSystemPagesProvider

Located in: `/lib/src/providers/restaurant_plan_provider.dart`

```dart
final enabledSystemPagesProvider = Provider<List<SystemPageId>>((ref) {
  final plan = ref.watch(restaurantPlanUnifiedProvider).asData?.value;
  
  final List<SystemPageId> enabledPages = [
    SystemPageId.menu,
    SystemPageId.profile,
  ];
  
  // Add cart if ordering module is enabled
  if (plan?.ordering?.enabled ?? false) {
    enabledPages.insert(1, SystemPageId.cart);
  }
  
  enabledPages.add(SystemPageId.admin);
  
  return enabledPages;
});
```

## Builder Changes

### Removed from Builder

1. **builder_modules.dart**
   - Removed `cart_module` from `builderModules` map
   - Removed `cart_module` from `moduleIdMapping`
   - Removed `cart_module` from `getModuleIdForBuilder()`
   - Removed `CartModuleWidget` class

2. **builder_block.dart**
   - Removed `cart_module` from `SystemBlock.availableModules`

3. **block_add_dialog.dart**
   - Added check to prevent adding WL system modules
   - Shows error message if user tries to add cart/delivery/click&collect

4. **system_block_preview.dart**
   - Shows neutral placeholder for WL system modules
   - Message: "[Module système – prévisualisation non disponible]"

5. **system_block_runtime.dart**
   - Added `_isWLSystemModule()` check
   - Returns placeholder widget for cart/delivery modules
   - Does not attempt to render these modules

6. **builder_navigation_service.dart**
   - Removed cart page from default page creation
   - Cart page no longer created in Builder initialization

## Runtime Integration

### Cart Screen

The cart screen (`/lib/src/screens/cart/cart_screen.dart`) remains unchanged and continues to work as a runtime page. It already checks for the delivery module using:

```dart
final deliveryConfig = ref.watch(deliveryConfigUnifiedProvider);
```

### Delivery Integration

The cart screen integrates delivery functionality when the delivery module is enabled:

1. Shows delivery address selection
2. Displays delivery fees
3. Shows time slot selection
4. Validates delivery address

### Navigation

The bottom navigation bar should be generated dynamically based on `enabledSystemPagesProvider`:

```dart
final enabledPages = ref.watch(enabledSystemPagesProvider);
final bottomNavItems = SystemPageManager.getBottomNavPages(enabledPages);
```

## Testing Scenarios

### Test Case 1: Plan WITHOUT Cart Module

**Configuration:**
- `ordering.enabled = false`

**Expected Behavior:**
- Bottom nav: Menu | Profile | Admin
- `/cart` route does not exist or returns 404
- No cart module appears in Builder
- Attempting to add cart module shows error

### Test Case 2: Cart Enabled, Delivery Disabled

**Configuration:**
- `ordering.enabled = true`
- `delivery.enabled = false`

**Expected Behavior:**
- Bottom nav: Menu | Cart | Profile | Admin
- Cart page works without delivery options
- No address/delivery fields shown
- Checkout button available

### Test Case 3: Cart + Delivery Both Enabled

**Configuration:**
- `ordering.enabled = true`
- `delivery.enabled = true`

**Expected Behavior:**
- Bottom nav: Menu | Cart | Profile | Admin
- Cart page includes:
  - Product list
  - Delivery address selection
  - Delivery time slots
  - Delivery fees in total
  - Full checkout flow

## Migration Guide

### For Existing Restaurants

If a restaurant already has `cart_module` blocks in their Builder pages:

1. **Data Migration**: These blocks will still exist in Firestore but will render as placeholders
2. **Preview Mode**: Shows "[Module système – prévisualisation non disponible]"
3. **Runtime Mode**: Shows same placeholder message
4. **Recommendation**: Admin should remove these blocks from their Builder pages

### Manual Cleanup

Admins can manually remove old cart_module blocks from their pages in the Builder editor.

## Files Modified

### Created Files
- `/lib/white_label/core/system_pages.dart` - System page manager

### Modified Files
- `/lib/builder/utils/builder_modules.dart` - Removed cart_module
- `/lib/builder/models/builder_block.dart` - Removed cart_module from availableModules
- `/lib/builder/editor/widgets/block_add_dialog.dart` - Prevent adding WL system modules
- `/lib/builder/blocks/system_block_preview.dart` - Placeholder for WL modules
- `/lib/builder/blocks/system_block_runtime.dart` - Placeholder for WL modules
- `/lib/builder/services/builder_navigation_service.dart` - Removed cart from defaults
- `/lib/src/providers/restaurant_plan_provider.dart` - Added enabledSystemPagesProvider

## Future Enhancements

1. **Dynamic Route Generation**: Generate routes for system pages based on enabled modules
2. **Custom System Page Widgets**: Allow registration of custom widgets for system pages
3. **System Page Templates**: Provide default templates for common system page layouts
4. **Migration Tool**: Automated tool to clean up old cart_module blocks from existing restaurants

## References

- [Builder B3 Documentation](./BUILDER_B3_MASTER_DOCUMENTATION.md)
- [White Label Architecture](./WHITE_LABEL_ARCHITECTURE_CORRECT.md)
- [Module Registry](./MODULE_RUNTIME_REGISTRY.md)
