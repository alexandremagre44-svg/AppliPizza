# BlockType.module Support - Complete Guide

## Overview

This guide provides a comprehensive overview of the `BlockType.module` support implementation in the AppliPizza project. This feature enables White-Label (WL) modules to be rendered as blocks within dynamically built pages.

## Quick Links

### For Developers
- 📖 [Complete Implementation Guide](../BLOCKTYPE_MODULE_SUPPORT.md) - Detailed technical documentation
- 🔄 [Flow Diagrams](blocktype_module_flow.md) - Visual rendering pipeline
- 🧪 [Test Suite](../test/builder/block_type_module_rendering_test.dart) - Comprehensive tests

### For Stakeholders
- 📊 [Executive Summary](../EXECUTIVE_SUMMARY.md) - High-level overview
- ✅ [Verification Checklist](../VERIFICATION_CHECKLIST.md) - Complete requirements check
- 📝 [PR Summary](../PR_SUMMARY_BLOCKTYPE_MODULE_VERIFICATION.md) - Detailed analysis

## What is BlockType.module?

`BlockType.module` is a block type that represents White-Label modules in the page builder system. Unlike standard blocks (hero, text, etc.), module blocks:

- **Use dynamic module IDs** instead of fixed types
- **Support dual widgets**: Admin widget (for builder preview) and Client widget (for runtime)
- **Are registered dynamically** via the `ModuleRuntimeRegistry`
- **Have proper fallbacks** for missing or unregistered modules

## Key Features

✅ **Dual Widget System**
- Admin widgets for builder/preview context
- Client widgets for runtime/production
- Automatic context detection

✅ **Intelligent Fallbacks**
1. Try client widget (runtime) or admin widget (preview)
2. Fallback to admin widget if client missing
3. Fallback to UnknownModuleWidget if module not registered

✅ **Module Registry**
- Centralized module registration
- HashMap-based O(1) lookup
- Support for 9+ registered modules

✅ **Production Ready**
- Comprehensive test coverage
- Robust error handling
- Zero performance overhead

## Current Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| Registry Entry | ✅ Implemented | builder_block_runtime_registry.dart:189-198 |
| Runtime Logic | ✅ Implemented | system_block_runtime.dart:180-201 |
| Module Registry | ✅ Implemented | module_runtime_registry.dart |
| Unknown Widget | ✅ Implemented | module_runtime_registry.dart:305-326 |
| Module Registration | ✅ Implemented | builder_block_runtime_registry.dart:433-524 |
| Test Suite | ✅ Complete | test/builder/block_type_module_rendering_test.dart |
| Documentation | ✅ Complete | Multiple files (see Quick Links) |

## Registered Modules

Currently, 9 White-Label modules are registered:

| Module ID | Purpose | Admin Widget | Client Widget |
|-----------|---------|--------------|---------------|
| delivery_module | Delivery options | ✅ | ✅ |
| click_collect_module | Pickup options | ✅ | ✅ |
| loyalty_module | Loyalty points | ✅ | ✅ |
| rewards_module | Rewards catalog | ✅ | ✅ |
| promotions_module | Active promos | ✅ | ✅ |
| newsletter_module | Email signup | ✅ | ✅ |
| kitchen_module | Kitchen interface | ✅ | ✅ |
| staff_module | Staff/POS interface | ✅ | ✅ |
| payment_module | Checkout flow | ✅ | ✅ |

## How It Works

### Simple Flow
```
1. Page loads with BlockType.module block
2. Registry routes to SystemBlockRuntime
3. SystemBlockRuntime extracts moduleId
4. ModuleRuntimeRegistry returns appropriate widget
5. Widget is rendered on page
```

### Detailed Flow
See [Flow Diagrams](blocktype_module_flow.md) for comprehensive visual representation.

## Usage Examples

### Creating a Module Block

```dart
// Method 1: Using factory
final block = SystemBlock.createModule('delivery_module');

// Method 2: Manual construction
final block = BuilderBlock(
  id: 'block_1',
  type: BlockType.module,
  order: 0,
  config: {'moduleId': 'delivery_module'},
);
```

### Registering a New Module

```dart
// In registerWhiteLabelModules() function
ModuleRuntimeRegistry.registerClient(
  'my_module',
  (ctx) => const MyModuleClientWidget(),
);

ModuleRuntimeRegistry.registerAdmin(
  'my_module',
  (ctx) => const MyModuleAdminWidget(),
);
```

### Using in a Page

```dart
BuilderPage(
  pageId: 'home',
  blocks: [
    BuilderBlock(
      id: 'block_1',
      type: BlockType.module,
      order: 0,
      config: {'moduleId': 'delivery_module'},
    ),
    // ... other blocks
  ],
)
```

## Testing

### Running Tests

```bash
flutter test test/builder/block_type_module_rendering_test.dart
```

### Test Coverage

7 comprehensive test scenarios:
1. ✅ Client widget rendering
2. ✅ Admin widget fallback
3. ✅ Unknown module fallback
4. ✅ Preview vs runtime modes
5. ✅ Missing moduleId handling
6. ✅ Multiple blocks rendering
7. ✅ Module registration integration

## Troubleshooting

### Module Not Appearing

**Symptom**: Module block shows "non disponible" message

**Solutions**:
1. Check module is registered in `registerWhiteLabelModules()`
2. Verify `registerWhiteLabelModules()` is called in `main.dart`
3. Ensure moduleId in block config matches registered ID
4. Check console for registration errors

### Wrong Widget Showing

**Symptom**: Admin widget appears in client, or vice versa

**Solutions**:
1. Verify both admin and client widgets are registered
2. Check context detection logic in `_isAdminContext()`
3. Ensure route names follow convention (contain '/admin', '/builder', etc.)

### Layout Issues

**Symptom**: Module widget has layout constraints errors

**Solutions**:
1. Ensure widget is wrapped in `WLModuleWrapper` (automatic)
2. Check widget has proper constraints
3. Verify parent container provides bounded constraints

## Performance

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| Module lookup | O(1) | HashMap-based |
| Context detection | O(1) | Route name check |
| Widget building | O(1) | Direct call |
| Fallback chain | O(1) | Max 2 lookups |

**Conclusion**: Extremely efficient, no performance concerns.

## Architecture

### Design Principles

1. **Separation of Concerns**: Modules are independent from block system
2. **Fail-Safe**: Multiple fallback levels prevent crashes
3. **Flexible**: Easy to add new modules
4. **Testable**: Mockable and unit-testable
5. **Performant**: O(1) operations throughout

### Integration Points

- **Page Builder**: Creates blocks with BlockType.module
- **Runtime Renderer**: Renders blocks on client side
- **Module Registry**: Manages module widgets
- **Navigation System**: Provides context information

## Contributing

### Adding a New Module

1. Create admin widget (`lib/builder/runtime/modules/my_module_admin_widget.dart`)
2. Create client widget (`lib/builder/runtime/modules/my_module_client_widget.dart`)
3. Register in `registerWhiteLabelModules()` function
4. Add to imports in `builder_block_runtime_registry.dart`
5. Test thoroughly

### Modifying Rendering Logic

⚠️ **Important**: The core rendering logic is working correctly. Verify existing implementation before making changes.

See [Maintenance Guidelines](../BLOCKTYPE_MODULE_SUPPORT.md#maintenance-notes) for detailed instructions.

## Resources

### Documentation Files

1. **BLOCKTYPE_MODULE_SUPPORT.md** - Complete technical guide
2. **docs/blocktype_module_flow.md** - Visual flow diagrams
3. **VERIFICATION_CHECKLIST.md** - Requirements verification
4. **PR_SUMMARY_BLOCKTYPE_MODULE_VERIFICATION.md** - Analysis summary
5. **EXECUTIVE_SUMMARY.md** - Stakeholder overview
6. **This file** - Quick reference guide

### Code Files

1. **builder_block_runtime_registry.dart** - Registry configuration
2. **system_block_runtime.dart** - Runtime rendering logic
3. **module_runtime_registry.dart** - Module management
4. **test/builder/block_type_module_rendering_test.dart** - Test suite

## FAQ

**Q: Is this feature production-ready?**  
A: Yes, it's fully implemented, tested, and already in production.

**Q: Can I add my own modules?**  
A: Yes, follow the "Adding a New Module" guide above.

**Q: What happens if a module isn't registered?**  
A: The `UnknownModuleWidget` is shown with a helpful error message.

**Q: How do I test my module?**  
A: Add test scenarios to the test suite following existing examples.

**Q: Does this affect performance?**  
A: No, all operations are O(1) and very efficient.

## Support

For questions or issues:
1. Check this documentation
2. Review the test suite for examples
3. Consult the flow diagrams
4. File a GitHub issue if needed

## Version History

- **PR #339** (Dec 2025): Initial implementation
- **This PR** (Dec 2025): Comprehensive verification, tests, and documentation

## License

Same as parent project - AppliPizza

---

**Last Updated**: December 8, 2025  
**Status**: ✅ Complete and Production-Ready  
**Maintainer**: Development Team
