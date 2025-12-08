# BlockType.module Rendering Flow Diagram

## Overview

This diagram illustrates the complete rendering flow for `BlockType.module` blocks from page load to final widget display.

## Client Side Rendering Flow

```
┌────────────────────────────────────────────────────────────────────┐
│                    DynamicBuilderPageScreen                         │
│  - Loads published page from Firestore                             │
│  - Passes blocks to BuilderRuntimeRenderer                          │
└───────────────────────────────┬────────────────────────────────────┘
                                │
                                ↓
┌────────────────────────────────────────────────────────────────────┐
│                    BuilderRuntimeRenderer                           │
│  - Filters active blocks (isActive == true)                        │
│  - Sorts blocks by order                                           │
│  - Wraps each block in ModuleAwareBlock                            │
└───────────────────────────────┬────────────────────────────────────┘
                                │
                                ↓
                    ┌───────────┴───────────┐
                    │  For Each Block:      │
                    └───────────┬───────────┘
                                ↓
┌────────────────────────────────────────────────────────────────────┐
│                      ModuleAwareBlock                               │
│  - Checks block.requiredModule                                     │
│  - Hides block if module disabled                                  │
│  - Calls BuilderBlockRuntimeRegistry.render()                      │
└───────────────────────────────┬────────────────────────────────────┘
                                │
                                ↓
┌────────────────────────────────────────────────────────────────────┐
│              BuilderBlockRuntimeRegistry.render()                   │
│  - Gets renderer for block.type                                    │
│  - Passes isPreview = false (runtime mode)                         │
└───────────────────────────────┬────────────────────────────────────┘
                                │
                                ↓
                    ┌───────────┴───────────┐
                    │ Is block.type ==      │
                    │ BlockType.module?     │
                    └───────┬───────────────┘
                           YES
                            │
                            ↓
┌────────────────────────────────────────────────────────────────────┐
│          SystemBlockRuntime (Runtime Mode, isPreview=false)        │
│  - Called by registry for BlockType.module                         │
│  - Executes _buildModuleWidget()                                   │
└───────────────────────────────┬────────────────────────────────────┘
                                │
                                ↓
┌────────────────────────────────────────────────────────────────────┐
│              SystemBlockRuntime._buildModuleWidget()                │
│  Line 180: Check if block.type == BlockType.module                 │
│  Line 184: Get moduleId = block.config['moduleId']                 │
│  Line 187: Detect context (admin vs runtime)                       │
└───────────────────────────────┬────────────────────────────────────┘
                                │
                                ↓
                    ┌───────────┴────────────┐
                    │ Is Admin Context?      │
                    └───┬────────────────┬───┘
                       NO               YES
                        │                │
                        ↓                ↓
         ┌──────────────────┐  ┌──────────────────┐
         │ Runtime Context  │  │  Admin Context   │
         │  (Client App)    │  │   (Builder)      │
         └────────┬─────────┘  └────────┬─────────┘
                  │                     │
                  ↓                     ↓
  ┌───────────────────────────────────────────────────────────┐
  │      ModuleRuntimeRegistry.buildClient(moduleId)          │
  │  - Looks up client widget for moduleId                    │
  │  - Returns widget if registered                           │
  │  - Returns null if not found                              │
  └─────────────────────┬─────────────────────────────────────┘
                        │
                        ↓
            ┌───────────┴────────────┐
            │   Widget Found?        │
            └───┬────────────────┬───┘
               YES               NO
                │                │
                ↓                ↓
        ┌──────────────┐  ┌──────────────────────────────┐
        │ Return       │  │ FALLBACK LEVEL 1:            │
        │ Client       │  │ buildAdmin(moduleId)         │
        │ Widget       │  │  - Try admin widget instead  │
        └──────────────┘  └──────────┬───────────────────┘
                                     │
                                     ↓
                         ┌───────────┴────────────┐
                         │   Widget Found?        │
                         └───┬────────────────┬───┘
                            YES               NO
                             │                │
                             ↓                ↓
                     ┌──────────────┐  ┌─────────────────────┐
                     │ Return       │  │ FALLBACK LEVEL 2:   │
                     │ Admin        │  │ UnknownModuleWidget │
                     │ Widget       │  │  - moduleId shown   │
                     └──────────────┘  │  - "non disponible" │
                                       └─────────────────────┘
```

## Widget Type Matrix

| Context | Preferred Widget | Fallback Widget | Final Fallback |
|---------|-----------------|-----------------|----------------|
| **Runtime** | buildClient() | buildAdmin() | UnknownModule |
| **Admin/Preview** | buildAdmin() | buildAdmin() | UnknownModule |

## Example: Delivery Module Rendering

### Scenario 1: Client Side (Happy Path)

```
User loads page with delivery_module block
    ↓
BlockType.module detected
    ↓
moduleId = "delivery_module" extracted
    ↓
Runtime context detected
    ↓
ModuleRuntimeRegistry.buildClient("delivery_module")
    ↓
✅ DeliveryModuleClientWidget rendered
```

### Scenario 2: Only Admin Widget Available

```
User loads page with new_module block
    ↓
BlockType.module detected
    ↓
moduleId = "new_module" extracted
    ↓
Runtime context detected
    ↓
ModuleRuntimeRegistry.buildClient("new_module")
    ↓
❌ Returns null (no client widget)
    ↓
FALLBACK: ModuleRuntimeRegistry.buildAdmin("new_module")
    ↓
✅ NewModuleAdminWidget rendered (acceptable fallback)
```

### Scenario 3: Module Not Registered

```
User loads page with unknown_module block
    ↓
BlockType.module detected
    ↓
moduleId = "unknown_module" extracted
    ↓
Runtime context detected
    ↓
ModuleRuntimeRegistry.buildClient("unknown_module")
    ↓
❌ Returns null
    ↓
FALLBACK: ModuleRuntimeRegistry.buildAdmin("unknown_module")
    ↓
❌ Returns null
    ↓
FINAL FALLBACK: UnknownModuleWidget(moduleId: "unknown_module")
    ↓
⚠️ Error widget rendered with message
```

## Key Files and Line References

### Registry Configuration
- **File**: `lib/builder/runtime/builder_block_runtime_registry.dart`
- **Lines**: 189-198
- **Purpose**: Maps BlockType.module to SystemBlockRuntime

### Core Rendering Logic
- **File**: `lib/builder/blocks/system_block_runtime.dart`
- **Lines**: 180-201
- **Purpose**: Handles module rendering with fallbacks

### Module Registry
- **File**: `lib/builder/runtime/module_runtime_registry.dart`
- **Lines**: 193-202 (buildClient), 164-173 (buildAdmin)
- **Purpose**: Stores and retrieves module widgets

### Unknown Module Fallback
- **File**: `lib/builder/runtime/module_runtime_registry.dart`
- **Lines**: 305-326
- **Purpose**: Shows error widget for unregistered modules

## Module Registration

### Where Modules Are Registered

```
main.dart (line 91)
    ↓
registerWhiteLabelModules()
    ↓
ModuleRuntimeRegistry.registerClient("delivery_module", ...)
ModuleRuntimeRegistry.registerAdmin("delivery_module", ...)
    ↓
Modules ready for rendering
```

### Currently Registered Modules

1. ✅ delivery_module (Admin + Client)
2. ✅ click_collect_module (Admin + Client)
3. ✅ loyalty_module (Admin + Client)
4. ✅ rewards_module (Admin + Client)
5. ✅ promotions_module (Admin + Client)
6. ✅ newsletter_module (Admin + Client)
7. ✅ kitchen_module (Admin + Client)
8. ✅ staff_module (Admin + Client)
9. ✅ payment_module (Admin + Client)

## Context Detection

The system automatically detects whether it's running in:

- **Admin Context**: Builder editor, preview mode
- **Runtime Context**: Client app, production

**Detection Method** (line 313-332 in system_block_runtime.dart):
```dart
bool _isAdminContext(BuildContext context) {
  final route = ModalRoute.of(context);
  final routeName = route?.settings.name ?? '';
  return routeName.contains('/admin') || 
         routeName.contains('/builder') ||
         routeName.contains('/editor') ||
         routeName.contains('/studio');
}
```

## Error Handling

### Level 1: Missing Client Widget
**Action**: Try admin widget
**Result**: Admin widget displayed (acceptable)

### Level 2: Module Not Registered
**Action**: Show UnknownModuleWidget
**Result**: Error message displayed (graceful failure)

### Level 3: Missing moduleId
**Action**: Continue to legacy module handling
**Result**: Fallback to other module types or empty

## Performance Characteristics

| Operation | Complexity | Cost |
|-----------|-----------|------|
| Registry lookup | O(1) | HashMap |
| Context detection | O(1) | Route name check |
| Widget building | O(1) | Direct call |
| Fallback chain | O(1) | Max 2 lookups |

**Total**: Very efficient, no expensive operations

## Testing Coverage

✅ All scenarios covered by tests:
1. Client widget rendering
2. Admin widget fallback
3. Unknown module fallback
4. Preview vs runtime differentiation
5. Missing moduleId handling
6. Multiple blocks rendering

## Conclusion

The BlockType.module rendering system is:
- ✅ Complete and production-ready
- ✅ Fully tested with comprehensive test suite
- ✅ Well-documented with flow diagrams
- ✅ Efficient with O(1) operations
- ✅ Robust with multiple fallback levels
- ✅ Flexible supporting dual admin/client widgets

No modifications needed - the implementation is correct and working as specified.
