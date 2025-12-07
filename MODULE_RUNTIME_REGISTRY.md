# Module Runtime Registry

## Overview

The **ModuleRuntimeRegistry** is a parallel registry system designed specifically for White-Label (WL) modules. It works independently from the existing BlockType renderer system, providing a clean separation of concerns and preventing collisions.

## Architecture

### Two Parallel Systems

1. **BlockType System** (Existing)
   - Used for standard Builder blocks: hero, text, banner, product_list, etc.
   - Managed by `BuilderBlockRuntimeRegistry`
   - Renders blocks based on `BlockType` enum

2. **Module Runtime Registry** (New)
   - Used for White-Label modules: delivery_module, loyalty_module, etc.
   - Managed by `ModuleRuntimeRegistry`
   - Renders modules based on module ID strings

### Benefits

- **No Collision**: WL modules don't interfere with BlockType system
- **Clean Separation**: Clear distinction between blocks and modules
- **Extensible**: Easy to add new modules without modifying existing code
- **Simple API**: Register once, use anywhere

## Usage

### Registering a Module

In `lib/builder/runtime/builder_block_runtime_registry.dart`:

```dart
void registerWhiteLabelModules() {
  ModuleRuntimeRegistry.register(
    'delivery_module',
    (ctx) => const DeliveryModuleWidget(),
  );
  
  // Add more modules here...
}
```

Call this function during app initialization in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... other initialization ...
  
  // Register White-Label modules
  registerWhiteLabelModules();
  
  runApp(MyApp());
}
```

### Rendering a Module

The `SystemBlockRuntime` widget automatically checks the registry:

```dart
Widget _buildModuleWidget(BuildContext context, String moduleType, ThemeConfig theme) {
  // PRIORITY 1: Check ModuleRuntimeRegistry
  if (ModuleRuntimeRegistry.contains(moduleType)) {
    final widget = ModuleRuntimeRegistry.build(moduleType, context);
    if (widget != null) {
      return widget;
    }
    return UnknownModuleWidget(moduleId: moduleType);
  }
  
  // PRIORITY 2-3: Fallback to legacy systems
  // ...
}
```

### Priority Order

When rendering a system block with a module type, the system checks in this order:

1. **ModuleRuntimeRegistry** - New WL module system
2. **builder_modules.dart** - Builder modules (menu_catalog, cart_module, etc.)
3. **Legacy modules** - Hardcoded modules (roulette, loyalty, rewards, accountActivity)

## Module ID Mapping

White-Label modules are mapped to ModuleId for plan validation:

| Builder Module ID | ModuleId Code | Description |
|-------------------|---------------|-------------|
| `delivery_module` | `delivery` | Delivery configuration and zones |
| `click_collect_module` | `click_and_collect` | Click & Collect settings |
| `loyalty_module` | `loyalty` | Loyalty points and tiers |
| `rewards_module` | `loyalty` | Rewards catalog |
| `promotions_module` | `promotions` | Promotions management |
| `newsletter_module` | `newsletter` | Newsletter subscription |
| `kitchen_module` | `kitchen_tablet` | Kitchen display |
| `staff_module` | `staff_tablet` | Staff POS interface |

This mapping is defined in `lib/builder/utils/builder_modules.dart`:

```dart
ModuleId? getModuleIdForBuilder(String builderModuleId) {
  switch (builderModuleId) {
    case 'delivery_module':
      return ModuleId.delivery;
    // ... other mappings
  }
}
```

## Adding a New Module

### Step 1: Create the Widget

Create a new widget file in `lib/builder/runtime/modules/`:

```dart
// lib/builder/runtime/modules/my_module_widget.dart
import 'package:flutter/material.dart';

class MyModuleWidget extends StatelessWidget {
  const MyModuleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text('My Module'),
    );
  }
}
```

### Step 2: Register the Module

Add the registration in `registerWhiteLabelModules()`:

```dart
void registerWhiteLabelModules() {
  // ... existing registrations ...
  
  ModuleRuntimeRegistry.register(
    'my_module',
    (ctx) => const MyModuleWidget(),
  );
}
```

### Step 3: Add Module Mapping (Optional)

If the module requires plan validation, add mapping in `builder_modules.dart`:

```dart
ModuleId? getModuleIdForBuilder(String builderModuleId) {
  switch (builderModuleId) {
    // ... existing cases ...
    
    case 'my_module':
      return ModuleId.myFeature;
  }
}
```

### Step 4: Add to SystemBlock.availableModules

Add the module ID to the list in `builder_block.dart`:

```dart
static const List<String> availableModules = [
  // ... existing modules ...
  'my_module',
];
```

That's it! The module is now available in the Builder runtime.

## Testing

Tests are located in `test/builder/module_runtime_registry_test.dart`.

Run tests with:

```bash
flutter test test/builder/module_runtime_registry_test.dart
```

## Fallback Widget

If a module is referenced but not registered, the `UnknownModuleWidget` is displayed:

- Shows an orange warning container
- Displays the module ID
- Provides a helpful message about registration

This prevents crashes and makes debugging easier.

## Key Files

- `lib/builder/runtime/module_runtime_registry.dart` - Registry implementation
- `lib/builder/runtime/builder_block_runtime_registry.dart` - Registration function
- `lib/builder/blocks/system_block_runtime.dart` - Module rendering logic
- `lib/builder/utils/builder_modules.dart` - Module ID mappings
- `lib/main.dart` - Initialization call
- `test/builder/module_runtime_registry_test.dart` - Test suite

## Backward Compatibility

The system maintains full backward compatibility:

- Legacy modules (roulette, loyalty, rewards, accountActivity) still work
- Builder modules (menu_catalog, cart_module, etc.) still work
- Existing BlockType system is completely unchanged
- New WL modules use the parallel registry system

## Future Enhancements

Potential future improvements:

1. **Lazy Loading**: Load module widgets on demand
2. **Hot Reload**: Support dynamic module registration
3. **Module Metadata**: Add description, icon, etc. to registry
4. **Module Dependencies**: Handle inter-module dependencies
5. **Module Lifecycle**: Add init/dispose hooks for modules

## Support

For questions or issues, refer to:
- Code comments in `module_runtime_registry.dart`
- Existing module implementations in `lib/builder/runtime/modules/`
- Test examples in `test/builder/module_runtime_registry_test.dart`
