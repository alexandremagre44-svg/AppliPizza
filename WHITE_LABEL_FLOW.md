# White-Label Navigation Flow

## System Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        APP STARTUP                              │
│  main() → registerAllModuleRoutes()                            │
│  → Registers all module routes in ModuleNavigationRegistry     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  USER NAVIGATES TO ROUTE                        │
│  Example: context.go('/roulette')                              │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              LAYER 1: GLOBAL ROUTE GUARD                        │
│  whiteLabelRouteGuard(state, plan)                             │
│  ├─ Check if route requires a module                           │
│  ├─ Resolve route → module mapping                             │
│  └─ If module disabled → redirect to /home                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼ (if allowed)
┌─────────────────────────────────────────────────────────────────┐
│              LAYER 2: LOCAL WIDGET GUARD                        │
│  ModuleGuard(module: ModuleId.roulette, child: ...)           │
│  ├─ Read RestaurantPlanUnified                                 │
│  ├─ Check plan.hasModule(ModuleId.roulette)                   │
│  ├─ Check ModuleRuntimeMapping.isImplemented()                │
│  └─ If disabled → redirect to /home                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼ (if allowed)
┌─────────────────────────────────────────────────────────────────┐
│              LAYER 3: ROLE GUARD (if needed)                    │
│  AdminGuard / StaffGuard / KitchenGuard                        │
│  ├─ Read authProvider                                          │
│  ├─ Check user.isAdmin / isStaff / hasKitchenAccess          │
│  └─ If unauthorized → redirect to /menu                        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼ (if authorized)
┌─────────────────────────────────────────────────────────────────┐
│                    SCREEN RENDERED                              │
│  User sees the requested screen                                │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
┌───────────────────┐
│  Firestore DB     │
│  restaurants/     │
│  {id}/plan        │
└─────────┬─────────┘
          │
          │ Loaded by
          ▼
┌───────────────────────────────┐
│ RestaurantPlanUnified         │
│ - restaurantId: string        │
│ - activeModules: ['loyalty',  │
│   'roulette', 'delivery']     │
│ - hasModule(moduleId): bool   │
└─────────┬─────────────────────┘
          │
          │ Used by
          ▼
┌───────────────────────────────┐
│ ModuleRouteResolver           │
│ - resolveRoutesFor(plan)      │
│ - Returns List<GoRoute>       │
└─────────┬─────────────────────┘
          │
          │ Provides routes to
          ▼
┌───────────────────────────────┐
│ GoRouter (main.dart)          │
│ - All routes registered       │
│ - Guards protect each route   │
└─────────┬─────────────────────┘
          │
          │ Renders
          ▼
┌───────────────────────────────┐
│ User Interface                │
│ - Only shows enabled modules  │
│ - Only allows authorized      │
│   access                      │
└───────────────────────────────┘
```

## Module Check Flow

```
Widget needs to check if module is enabled:
                             
┌─────────────────────────────────┐
│  Widget Code                    │
│  isModuleEnabled(ref, ModuleId) │
└─────────────┬───────────────────┘
              │
              ▼
┌─────────────────────────────────┐
│  module_helpers.dart            │
│  - Read restaurantPlanProvider  │
│  - Check plan.hasModule()       │
│  - Return bool                  │
└─────────────┬───────────────────┘
              │
              ▼
┌─────────────────────────────────┐
│  Widget Decision                │
│  if (enabled) {                 │
│    show content                 │
│  } else {                       │
│    hide / fallback              │
│  }                              │
└─────────────────────────────────┘
```

## Example: Roulette Module Access

```
User clicks "Roulette" button → context.go('/roulette')
                              
                              ▼
                              
Step 1: Global Guard Check
  - Is '/roulette' a system route? NO
  - Which module owns '/roulette'? → ModuleId.roulette
  - Is roulette in plan.activeModules? → CHECK PLAN
    ├─ YES → Continue
    └─ NO → Redirect to /home

                              ▼
                              
Step 2: Widget Guard Check (ModuleGuard)
  - Read plan from provider
  - Check plan.hasModule(ModuleId.roulette)
    ├─ YES → Continue
    └─ NO → Redirect to /home
    
                              ▼
                              
Step 3: Implementation Check
  - Is module implemented?
  - ModuleRuntimeMapping.isImplemented(ModuleId.roulette)
    ├─ YES → Continue
    └─ NO (planned) → Redirect to /home

                              ▼
                              
Step 4: Render Screen
  - RouletteScreen() rendered
  - User can spin the wheel
```

## Example: POS (Staff Tablet) Access

```
Admin clicks "Caisse" → context.go('/pos')
                              
                              ▼
                              
Step 1: Global Guard Check
  - Is '/pos' a system route? NO
  - Which module owns '/pos'? → ModuleId.staff_tablet
  - Is staff_tablet in plan.activeModules? → CHECK PLAN
    ├─ YES → Continue
    └─ NO → Redirect to /home

                              ▼
                              
Step 2: Combined Module + Role Guard (ModuleAndRoleGuard)
  A) Module Check:
     - Read plan from provider
     - Check plan.hasModule(ModuleId.staff_tablet)
       ├─ YES → Continue to role check
       └─ NO → Redirect to /home
  
  B) Role Check:
     - Read authProvider
     - Check user.isAdmin
       ├─ YES → Continue
       └─ NO → Redirect to /menu

                              ▼
                              
Step 3: Render Screen
  - PosScreen() rendered
  - Admin can use the POS
```

## Builder B3 Integration

```
Builder B3 renders a custom page with blocks
                              
                              ▼
                              
Roulette Block in Builder:
  - Block has property: requiredModule = ModuleId.roulette
  - Block builder code checks:
  
    if (!isModuleEnabled(ref, ModuleId.roulette)) {
      return SizedBox.shrink(); // Hide block
    }
    
    return RouletteButtonWidget(); // Show block
                              
                              ▼
                              
Result in UI:
  - If roulette enabled → Button visible
  - If roulette disabled → Button hidden (invisible)
```

## Complete Request Flow with Debugging

```
1. User Navigation Request
   └─> context.go('/rewards')
   
2. Global Router Redirect Check
   └─> whiteLabelRouteGuard(state, plan)
       ├─ 🔍 Debug: "Checking route: /rewards"
       ├─ Resolve: /rewards → ModuleId.loyalty
       ├─ Check: plan.hasModule(ModuleId.loyalty) → true
       └─ ✅ Log: "Route allowed (global)"

3. GoRouter finds matching route
   └─> GoRoute(path: '/rewards', builder: ...)
   
4. Widget Guard Check
   └─> ModuleGuard(module: ModuleId.loyalty, ...)
       ├─ 🔍 Debug: "Checking module: loyalty"
       ├─ Read: restaurantPlanUnifiedProvider
       ├─ Check: plan.hasModule(ModuleId.loyalty) → true
       ├─ Check: ModuleRuntimeMapping.isImplemented() → true
       └─ ✅ Log: "Access granted to loyalty"

5. Render Child Widget
   └─> BuilderPageLoader(
         pageId: BuilderPageId.rewards,
         fallback: RewardsScreen(),
       )
       
6. Screen Displayed
   └─> User sees rewards screen
```

## Error Cases

### Case 1: Module Disabled

```
User → /roulette (but roulette module is OFF)

Global Guard:
  - Check: plan.hasModule(ModuleId.roulette) → false
  - 🔒 Log: "Blocking route /roulette - module disabled"
  - Action: return '/home'

Router:
  - Redirect to /home
  - User never sees roulette screen
```

### Case 2: Unauthorized Role

```
Non-admin user → /pos

Global Guard:
  - Check: plan.hasModule(ModuleId.staff_tablet) → true
  - ✅ Pass (module enabled)

ModuleAndRoleGuard:
  - Module Check: hasModule(staff_tablet) → true ✅
  - Role Check: user.isAdmin → false ❌
  - 🔒 Log: "Access denied - user is not admin"
  - Action: redirect to /menu

Router:
  - Redirect to /menu
  - User sees "Access denied" message
```

### Case 3: Module Not Implemented

```
User → /wallet (planned but not implemented)

Global Guard:
  - Check: plan.hasModule(ModuleId.wallet) → true
  - Resolve: wallet exists in plan

ModuleGuard:
  - Module Check: hasModule(wallet) → true
  - Implementation: isPlanned(wallet) → true
  - 🔒 Log: "Module planned but not implemented"
  - Action: redirect to /home

Router:
  - Redirect to /home
```

## Summary

The white-label navigation system provides:

1. **Triple-layer security**:
   - Global route guard
   - Local module guard
   - Role-based guard

2. **Centralized management**:
   - ModuleNavigationRegistry
   - ModuleRouteResolver
   - Single source of truth

3. **Easy debugging**:
   - Detailed logs at each layer
   - Clear error messages
   - Visual indicators

4. **Flexible architecture**:
   - Easy to add new modules
   - Easy to modify access rules
   - Backward compatible

This ensures that only authorized users can access the features their restaurant has enabled.
