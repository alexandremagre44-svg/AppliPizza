# Module Runtime Registry Architecture

## System Overview

This document provides a visual representation of the Module Runtime Registry architecture and how it integrates with the existing Builder system.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Builder System                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  BuilderPage                                                    │
│    ├─ BuilderBlock (type: hero)      ──┐                       │
│    ├─ BuilderBlock (type: text)      ──┼─► BlockType System   │
│    ├─ BuilderBlock (type: banner)    ──┘   (Unchanged)         │
│    │                                                            │
│    └─ BuilderBlock (type: system)    ──┐                       │
│         └─ moduleType: "delivery_module" │                     │
│                                          │                      │
│                                          ▼                      │
│                         ┌────────────────────────────┐          │
│                         │  SystemBlockRuntime        │          │
│                         │  _buildModuleWidget()      │          │
│                         └────────────────────────────┘          │
│                                     │                           │
│                                     ▼                           │
│              ┌──────────────────────────────────────┐           │
│              │      Priority Check System           │           │
│              └──────────────────────────────────────┘           │
│                                                                 │
│  ┌─────────────┬───────────────────┬─────────────────────┐     │
│  │ Priority 1  │    Priority 2     │     Priority 3      │     │
│  │             │                   │                     │     │
│  ▼             ▼                   ▼                     │     │
│  ModuleRuntime  builder_modules   Legacy Modules        │     │
│  Registry       .dart              (hardcoded)          │     │
│  (NEW)          (existing)         (backward compat)    │     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Module Rendering Flow

### Flow Diagram

```
User adds SystemBlock with moduleType="delivery_module"
                    │
                    ▼
         SystemBlockRuntime.build()
                    │
                    ▼
      _buildModuleWidget("delivery_module")
                    │
                    ▼
    ┌───────────────────────────────────────┐
    │ ModuleRuntimeRegistry.contains()?     │
    └───────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
       YES                     NO
        │                       │
        ▼                       ▼
    ModuleRuntime         builder_modules
    Registry.build()      .renderModule()
        │                       │
        ▼                       ▼
    DeliveryModule         (existing logic)
    Widget ✓
```

## Module Registration Flow

### Initialization Sequence

```
Application Startup
        │
        ▼
    main() function
        │
        ├─► registerAllModuleRoutes()
        │
        └─► registerWhiteLabelModules()  ← NEW
                │
                ▼
    ┌───────────────────────────────────┐
    │ ModuleRuntimeRegistry.register()  │
    │                                   │
    │  "delivery_module" →              │
    │    DeliveryModuleWidget           │
    └───────────────────────────────────┘
                │
                ▼
    Registry Ready for Runtime
```

## Registry Internal Structure

```
┌─────────────────────────────────────────────────────┐
│         ModuleRuntimeRegistry                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│  _registry: Map<String, ModuleRuntimeBuilder>      │
│                                                     │
│  {                                                  │
│    "delivery_module": (ctx) => DeliveryWidget(),   │
│    "loyalty_module": (ctx) => LoyaltyWidget(),     │
│    "rewards_module": (ctx) => RewardsWidget(),     │
│    ...                                              │
│  }                                                  │
│                                                     │
│  Methods:                                           │
│  ├─ register(id, builder)    // Add module         │
│  ├─ build(id, context)       // Create widget      │
│  ├─ contains(id)             // Check if exists    │
│  ├─ unregister(id)           // Remove module      │
│  └─ clear()                  // Clear all          │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Parallel Systems Comparison

### BlockType System (Existing)

```
┌──────────────────────────────────────┐
│   BuilderBlockRuntimeRegistry        │
├──────────────────────────────────────┤
│                                      │
│  BlockType.hero    → HeroBlock       │
│  BlockType.text    → TextBlock       │
│  BlockType.banner  → BannerBlock     │
│  BlockType.system  → SystemBlock     │
│                                      │
│  Used for: Standard builder blocks   │
│  Enum-based: BlockType enum          │
│  Scope: Preview + Runtime            │
│                                      │
└──────────────────────────────────────┘
```

### Module Registry (New)

```
┌──────────────────────────────────────┐
│   ModuleRuntimeRegistry              │
├──────────────────────────────────────┤
│                                      │
│  "delivery_module" → DeliveryWidget  │
│  "loyalty_module"  → LoyaltyWidget   │
│  "rewards_module"  → RewardsWidget   │
│                                      │
│  Used for: White-Label modules       │
│  String-based: module ID strings     │
│  Scope: Runtime only                 │
│                                      │
└──────────────────────────────────────┘
```

## Module ID Mapping

### Builder ID → ModuleId Code

```
Builder System          White-Label System
     │                        │
     ▼                        ▼
"delivery_module"  ─────►  ModuleId.delivery
     │                        │
     │                        ▼
     │                   code: "delivery"
     │                        │
     │                        ▼
     └────────────────► Plan Validation
```

### Full Mapping Table

| Builder Module ID | ModuleId Enum | Code | Plan Feature |
|-------------------|---------------|------|--------------|
| delivery_module | ModuleId.delivery | "delivery" | Delivery zones |
| click_collect_module | ModuleId.clickAndCollect | "click_and_collect" | Click & Collect |
| loyalty_module | ModuleId.loyalty | "loyalty" | Loyalty program |
| rewards_module | ModuleId.loyalty | "loyalty" | Rewards catalog |
| promotions_module | ModuleId.promotions | "promotions" | Promotions |
| newsletter_module | ModuleId.newsletter | "newsletter" | Newsletter |
| kitchen_module | ModuleId.kitchen_tablet | "kitchen_tablet" | Kitchen display |
| staff_module | ModuleId.staff_tablet | "staff_tablet" | Staff POS |

## Error Handling

### Unregistered Module Flow

```
ModuleRuntimeRegistry.contains("unknown_module")
                │
                ▼
              FALSE
                │
                ▼
ModuleRuntimeRegistry.build("unknown_module")
                │
                ▼
             returns NULL
                │
                ▼
    UnknownModuleWidget displayed
                │
                ▼
    ┌───────────────────────────┐
    │ ⚠ Module non enregistré   │
    │ Module ID: "unknown_..."  │
    │ [Orange warning box]      │
    └───────────────────────────┘
```

## Testing Architecture

```
┌──────────────────────────────────────────────┐
│  test/builder/module_runtime_registry_test   │
├──────────────────────────────────────────────┤
│                                              │
│  Unit Tests:                                 │
│  ├─ register() / unregister()                │
│  ├─ build() with real BuildContext          │
│  ├─ contains() checking                      │
│  └─ clear() functionality                    │
│                                              │
│  Widget Tests:                               │
│  ├─ UnknownModuleWidget rendering            │
│  └─ Visual appearance validation             │
│                                              │
│  Integration Tests:                          │
│  └─ registerWhiteLabelModules() call         │
│                                              │
└──────────────────────────────────────────────┘
```

## Extensibility Pattern

### Adding a New Module

```
Step 1: Create Widget
    │
    ▼
lib/builder/runtime/modules/
    └─ new_module_widget.dart
    
Step 2: Register Module
    │
    ▼
registerWhiteLabelModules() {
    ModuleRuntimeRegistry.register(
        'new_module',
        (ctx) => NewModuleWidget()
    );
}

Step 3: Add Mapping (optional)
    │
    ▼
getModuleIdForBuilder() {
    case 'new_module':
        return ModuleId.newFeature;
}

Step 4: Add to Available List
    │
    ▼
SystemBlock.availableModules = [
    ...
    'new_module',
];

Done! Module ready to use ✓
```

## Benefits Summary

```
┌─────────────────────────────────────────────┐
│           Architecture Benefits             │
├─────────────────────────────────────────────┤
│                                             │
│  ✓ No Collision                             │
│    BlockType and Module systems separate    │
│                                             │
│  ✓ Clean Separation                         │
│    Clear distinction between blocks/modules │
│                                             │
│  ✓ Extensible                               │
│    Easy to add new modules                  │
│                                             │
│  ✓ Testable                                 │
│    Simple API, easy to test                 │
│                                             │
│  ✓ Backward Compatible                      │
│    All existing code still works            │
│                                             │
│  ✓ Maintainable                             │
│    Single responsibility principle          │
│                                             │
└─────────────────────────────────────────────┘
```

## Security Considerations

```
┌──────────────────────────────────────────────┐
│          Security Architecture               │
├──────────────────────────────────────────────┤
│                                              │
│  Plan Validation:                            │
│  ┌────────────────────────────────────────┐  │
│  │ Builder Module ID                      │  │
│  │         ▼                              │  │
│  │ getModuleIdForBuilder()                │  │
│  │         ▼                              │  │
│  │ ModuleId (with plan requirements)      │  │
│  │         ▼                              │  │
│  │ Restaurant Plan Check                  │  │
│  │         ▼                              │  │
│  │ Module enabled? → YES/NO               │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  Runtime Safety:                             │
│  ├─ Registry isolated from user input        │
│  ├─ No eval() or dynamic code execution      │
│  ├─ No SQL injection vectors                 │
│  └─ No XSS vulnerabilities                   │
│                                              │
└──────────────────────────────────────────────┘
```

## Performance Characteristics

```
Operation                Time Complexity    Space Complexity
─────────────────────────────────────────────────────────────
register(id, builder)    O(1)              O(n) for n modules
build(id, context)       O(1)              O(1)
contains(id)             O(1)              O(1)
unregister(id)           O(1)              O(1)
clear()                  O(n)              O(1)
getRegisteredModules()   O(n)              O(n)
```

## Future Enhancements

```
Potential Improvements:
├─ Lazy Loading
│  └─ Load module widgets on demand
│
├─ Module Metadata
│  └─ Icon, description, version in registry
│
├─ Module Dependencies
│  └─ Handle inter-module dependencies
│
├─ Module Lifecycle
│  └─ Init/dispose hooks for modules
│
└─ Hot Reload Support
   └─ Dynamic module registration at runtime
```

## Conclusion

The Module Runtime Registry provides a clean, parallel architecture for White-Label modules that:

1. **Works independently** from the BlockType system
2. **Prevents collisions** between blocks and modules
3. **Maintains compatibility** with all existing code
4. **Simplifies extension** with new modules
5. **Provides clear separation** of concerns

This architecture ensures the Builder system can grow to support many more modules without complexity or conflicts.
