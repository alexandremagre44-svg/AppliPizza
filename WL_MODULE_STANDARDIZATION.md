# White-Label Module Standardization - Implementation Summary

## Overview

This document describes the standardization of all White-Label (WL) modules to fix layout issues and establish a consistent architecture.

## Problems Fixed

1. ✅ **Hit-test errors** - "Cannot hit test a render box with no size"
2. ✅ **Illegal SingleChildScrollView** - Created infinite constraints in modules
3. ✅ **Missing maxWidth constraints** - Modules had unbounded width
4. ✅ **Incorrect builder_modules fallback** - WL modules pointed to Admin even on client side
5. ✅ **Unclear Admin/Client separation** - No clear runtime distinction

## Architecture Changes

### 1. WL Module Wrapper (`lib/builder/runtime/wl/wl_module_wrapper.dart`)

Created a standard wrapper that ALL WL modules must use:

```dart
class WLModuleWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;  // Default: 600px
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: IntrinsicHeight(child: child),
      ),
    );
  }
}
```

**Benefits:**
- Prevents infinite width constraints
- Ensures proper height calculation with IntrinsicHeight
- Centers modules horizontally
- Consistent 600px max width across all modules

### 2. ModuleRuntimeRegistry Auto-Wrapping

Updated `lib/builder/runtime/module_runtime_registry.dart`:

```dart
static Widget wrapModuleSafe(Widget child) => WLModuleWrapper(child: child);

static Widget? buildAdmin(String moduleId, BuildContext context) {
  final builder = _adminWidgets[moduleId];
  if (builder == null) return null;
  return wrapModuleSafe(builder(context));  // ← Auto-wrap
}

static Widget? buildClient(String moduleId, BuildContext context) {
  final builder = _clientWidgets[moduleId];
  if (builder == null) return null;
  return wrapModuleSafe(builder(context));  // ← Auto-wrap
}
```

**Benefits:**
- All modules automatically wrapped
- No need to remember to wrap manually
- Consistent layout behavior

### 3. DeliveryModuleClientWidget Fix

**BEFORE:**
```dart
return SingleChildScrollView(  // ❌ Creates infinite constraints
  child: Padding(
    padding: EdgeInsets.all(AppSpacing.lg),
    child: Card(...)
  ),
);
```

**AFTER:**
```dart
return Card(  // ✅ Direct return with constraints
  margin: EdgeInsets.all(AppSpacing.lg),
  child: Padding(
    padding: EdgeInsets.all(AppSpacing.lg),
    child: Column(
      mainAxisSize: MainAxisSize.min,  // ← CRITICAL
      // ...
    ),
  ),
);
```

**Benefits:**
- No infinite constraints from scroll widget
- Proper sizing with mainAxisSize.min
- Wrapper handles width constraints

### 4. Builder Modules Cleanup

Updated `lib/builder/utils/builder_modules.dart`:

**REMOVED all WL modules:**
```dart
// ❌ REMOVED:
// 'delivery_module': (context) => const DeliveryModuleAdminWidget(),
// 'click_collect_module': (context) => const ClickCollectModuleWidget(),
// 'loyalty_module': (context) => const LoyaltyModuleWidget(),
// ... etc
```

**KEPT only core modules:**
```dart
final Map<String, ModuleWidgetBuilder> builderModules = {
  'menu_catalog': (context) => const MenuCatalogRuntimeWidget(),
  'cart_module': (context) => const CartModuleWidget(),
  'profile_module': (context) => const ProfileModuleWidget(),
  'roulette_module': (context) => const RouletteModuleWidget(),
  // Legacy modules only - NO WL modules here
};
```

**Benefits:**
- Clear separation: Core modules vs WL modules
- WL modules exclusively via ModuleRuntimeRegistry
- No confusion about which system to use

### 5. WL Module Registration

Updated `lib/builder/runtime/builder_block_runtime_registry.dart`:

```dart
void registerWhiteLabelModules() {
  // Delivery Module
  ModuleRuntimeRegistry.registerAdmin('delivery_module', (ctx) => const DeliveryModuleAdminWidget());
  ModuleRuntimeRegistry.registerClient('delivery_module', (ctx) => const DeliveryModuleClientWidget());

  // Click & Collect Module
  ModuleRuntimeRegistry.registerAdmin('click_collect_module', (ctx) => const ClickCollectModuleWidget());
  ModuleRuntimeRegistry.registerClient('click_collect_module', (ctx) => const ClickCollectModuleWidget());

  // Loyalty Module
  ModuleRuntimeRegistry.registerAdmin('loyalty_module', (ctx) => const LoyaltyModuleWidget());
  ModuleRuntimeRegistry.registerClient('loyalty_module', (ctx) => const LoyaltyModuleWidget());

  // Rewards Module
  ModuleRuntimeRegistry.registerAdmin('rewards_module', (ctx) => const RewardsModuleWidget());
  ModuleRuntimeRegistry.registerClient('rewards_module', (ctx) => const RewardsModuleWidget());

  // Promotions Module
  ModuleRuntimeRegistry.registerAdmin('promotions_module', (ctx) => const PromotionsModuleWidget());
  ModuleRuntimeRegistry.registerClient('promotions_module', (ctx) => const PromotionsModuleWidget());

  // Newsletter Module
  ModuleRuntimeRegistry.registerAdmin('newsletter_module', (ctx) => const NewsletterModuleWidget());
  ModuleRuntimeRegistry.registerClient('newsletter_module', (ctx) => const NewsletterModuleWidget());

  // Kitchen Module
  ModuleRuntimeRegistry.registerAdmin('kitchen_module', (ctx) => const KitchenModuleWidget());
  ModuleRuntimeRegistry.registerClient('kitchen_module', (ctx) => const KitchenModuleWidget());

  // Staff Module
  ModuleRuntimeRegistry.registerAdmin('staff_module', (ctx) => const StaffModuleWidget());
  ModuleRuntimeRegistry.registerClient('staff_module', (ctx) => const StaffModuleWidget());
}
```

**Benefits:**
- All 8 WL modules registered with dual system
- Admin and client versions clearly separated
- Some modules share implementation (placeholders for now)

### 6. Context Detection in SystemBlockRuntime

Updated `lib/builder/blocks/system_block_runtime.dart`:

```dart
Widget _buildModuleWidget(BuildContext context, String moduleType, ThemeConfig theme) {
  // PRIORITY 1: Check ModuleRuntimeRegistry for WL modules
  if (ModuleRuntimeRegistry.containsAdmin(moduleType) || 
      ModuleRuntimeRegistry.containsClient(moduleType)) {
    
    // Detect if we're in admin context
    final isAdminContext = _isAdminContext(context);
    
    Widget? widget;
    if (isAdminContext) {
      widget = ModuleRuntimeRegistry.buildAdmin(moduleType, context);
    } else {
      widget = ModuleRuntimeRegistry.buildClient(moduleType, context);
      // Fallback to admin if no client widget registered
      widget ??= ModuleRuntimeRegistry.buildAdmin(moduleType, context);
    }
    
    if (widget != null) {
      return widget;
    }
    return UnknownModuleWidget(moduleId: moduleType);
  }
  
  // PRIORITY 2: Legacy builder_modules (core modules only)
  // ...
}

bool _isAdminContext(BuildContext context) {
  final route = ModalRoute.of(context)?.settings.name ?? '';
  return route.contains('/admin') || 
         route.contains('/builder') ||
         route.contains('/editor');
}
```

**Benefits:**
- Automatic admin/client detection based on route
- Proper widget selection at runtime
- Fallback mechanism for missing client widgets

## Module Layout Rules

All WL modules MUST follow these rules:

### ✅ DO:
1. Use `mainAxisSize: MainAxisSize.min` on Column/Row
2. Return widgets directly (Card, Container, etc.)
3. Let WLModuleWrapper handle width constraints
4. Use IntrinsicHeight for proper sizing

### ❌ DON'T:
1. Use SingleChildScrollView in module root
2. Use ListView in module root
3. Create unbounded constraints
4. Set fixed heights unless necessary

## Testing

Created comprehensive test suite in `test/wl_module_wrapper_test.dart`:

- WLModuleWrapper constraint tests
- ModuleRuntimeRegistry registration tests
- Admin/client widget separation tests
- Auto-wrapping verification

## Files Changed

1. ✅ `lib/builder/runtime/wl/wl_module_wrapper.dart` - NEW
2. ✅ `lib/builder/runtime/module_runtime_registry.dart` - UPDATED
3. ✅ `lib/builder/runtime/modules/delivery_module_client_widget.dart` - FIXED
4. ✅ `lib/builder/utils/builder_modules.dart` - CLEANED UP
5. ✅ `lib/builder/runtime/builder_block_runtime_registry.dart` - UPDATED
6. ✅ `lib/builder/blocks/system_block_runtime.dart` - UPDATED
7. ✅ `test/wl_module_wrapper_test.dart` - NEW

## Result

✅ Layout stable - No more hit-test errors  
✅ Delivery is now a proper module card - No split page  
✅ No infinite constraints - Wrapper applied automatically  
✅ Clean WL registration - Only via ModuleRuntimeRegistry  
✅ Admin/Client perfectly separated - Automatic context detection  
✅ Legacy fallbacks removed - No more builder_modules vs Registry confusion

## Migration Guide for New WL Modules

To add a new WL module:

1. Create admin widget: `lib/builder/runtime/modules/{module}_admin_widget.dart`
2. Create client widget: `lib/builder/runtime/modules/{module}_client_widget.dart`
3. Follow layout rules (mainAxisSize.min, no scroll widgets)
4. Register in `registerWhiteLabelModules()`:
   ```dart
   ModuleRuntimeRegistry.registerAdmin('my_module', (ctx) => const MyModuleAdminWidget());
   ModuleRuntimeRegistry.registerClient('my_module', (ctx) => const MyModuleClientWidget());
   ```
5. No need to add to `builder_modules.dart`
6. No need to manually wrap - auto-wrapped by registry

## Future Enhancements

- [ ] Create separate admin widgets for modules currently using same widget
- [ ] Add module-specific configuration in admin widgets
- [ ] Implement full functionality in placeholder modules
- [ ] Add more comprehensive layout tests
- [ ] Document module data flow patterns
