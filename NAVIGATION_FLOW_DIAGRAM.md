# Navigation Flow Diagram

## Overview Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    ScaffoldWithNavBar                           │
│                                                                 │
│  1. Load builder pages from Firestore                          │
│  2. Load RestaurantPlanUnified (active modules)                │
│  3. Get admin status from auth                                 │
│                          ↓                                      │
│            UnifiedNavBarController.computeNavBarItems()         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              UnifiedNavBarController                            │
│                                                                 │
│  Step 1: GATHER                                                 │
│  ├─ System pages (menu, cart?, profile)                        │
│  ├─ Builder pages (displayLocation == 'bottomBar')             │
│  └─ Module pages (none currently)                              │
│                                                                 │
│  Step 2: FILTER                                                 │
│  ├─ Check module activation (plan.activeModules)               │
│  ├─ Check builder visibility (isEnabled, isActive)             │
│  ├─ Check module requirements (page.modules)                   │
│  └─ Check user role (admin-only pages)                         │
│                                                                 │
│  Step 3: DEDUPLICATE                                            │
│  └─ Prefer builder over system (same route)                    │
│                                                                 │
│  Step 4: ORDER                                                  │
│  ├─ Builder tabs (by bottomNavIndex)                           │
│  ├─ System tabs (menu → cart → profile)                        │
│  └─ Module tabs (none currently)                               │
│                                                                 │
│  Step 5: RETURN List<NavBarItem>                               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    ScaffoldWithNavBar                           │
│                                                                 │
│  1. Convert NavBarItem → BottomNavigationBarItem                │
│  2. Add admin tab if isAdmin                                   │
│  3. Calculate current index                                    │
│  4. Render BottomNavigationBar                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Detailed Decision Tree

```
For each potential tab:

┌─────────────────────────────────────┐
│  Is it a system page?               │
└───────────┬─────────────────────────┘
            │
    ┌───────┴────────┐
    │ YES            │ NO
    │                │
    ↓                ↓
┌───────────────┐  ┌──────────────────────┐
│ Menu?         │  │ Is it a builder page? │
│ → Always show │  └──────────┬───────────┘
└───────────────┘             │
                      ┌───────┴────────┐
┌───────────────┐    │ YES            │ NO
│ Cart?         │    │                │
│ → Check if    │    ↓                ↓
│   'ordering'  │  ┌────────────────────────┐
│   active      │  │ displayLocation        │
└───────────────┘  │ == 'bottomBar'?        │
                   └──────────┬─────────────┘
┌───────────────┐             │
│ Profile?      │     ┌───────┴────────┐
│ → Always show │     │ YES            │ NO → HIDE
└───────────────┘     │                │
                      ↓                │
            ┌──────────────────┐      │
            │ isActive == true?│      │
            └────────┬─────────┘      │
                     │                │
            ┌────────┴────────┐       │
            │ YES             │ NO → HIDE
            │                 │
            ↓                 │
  ┌─────────────────────┐    │
  │ isEnabled == true?  │    │
  └──────────┬──────────┘    │
             │                │
    ┌────────┴────────┐       │
    │ YES             │ NO → HIDE
    │                 │
    ↓                 │
┌────────────────────────┐   │
│ page.modules empty?    │   │
└──────────┬─────────────┘   │
           │                 │
  ┌────────┴────────┐        │
  │ YES             │ NO     │
  │                 │        │
  ↓                 ↓        │
┌──────────┐  ┌───────────────────┐
│ SHOW     │  │ At least one       │
│          │  │ required module    │
│          │  │ active?            │
│          │  └────────┬───────────┘
│          │           │
│          │  ┌────────┴────────┐
│          │  │ YES             │ NO → HIDE
│          │  │                 │
│          │  ↓                 │
│          │ ┌──────────┐       │
│          │ │ SHOW     │       │
└──────────┘ └──────────┘       │
                                │
                         ┌──────┴──────┐
                         │   HIDE      │
                         └─────────────┘
```

## Example Scenarios

### Scenario 1: Basic Restaurant (No Modules)

**Input:**
- Active modules: `[]`
- Builder pages: none
- Is admin: false

**Flow:**
```
System Pages:
  ├─ Menu → ✅ SHOW (always)
  ├─ Cart → ❌ HIDE (ordering not active)
  └─ Profile → ✅ SHOW (always)

Builder Pages: (none)

Module Pages: (none)

Final Result: [Menu, Profile]
```

### Scenario 2: Restaurant with Ordering

**Input:**
- Active modules: `['ordering']`
- Builder pages: none
- Is admin: false

**Flow:**
```
System Pages:
  ├─ Menu → ✅ SHOW (always)
  ├─ Cart → ✅ SHOW (ordering active)
  └─ Profile → ✅ SHOW (always)

Builder Pages: (none)

Module Pages: (none)

Final Result: [Menu, Cart, Profile]
```

### Scenario 3: Restaurant with Custom Promo Page

**Input:**
- Active modules: `[]`
- Builder pages: [Promo (route: /promo, displayLocation: bottomBar, isActive: true, isEnabled: true)]
- Is admin: false

**Flow:**
```
System Pages:
  ├─ Menu → ✅ SHOW (always)
  ├─ Cart → ❌ HIDE (ordering not active)
  └─ Profile → ✅ SHOW (always)

Builder Pages:
  └─ Promo → ✅ SHOW (bottomBar, active, enabled)

Module Pages: (none)

Ordering:
  1. Promo (builder, order: 0)
  2. Menu (system, order: 100)
  3. Profile (system, order: 102)

Final Result: [Promo, Menu, Profile]
```

### Scenario 4: Builder Overrides System

**Input:**
- Active modules: `['ordering']`
- Builder pages: [Custom Menu (route: /menu, systemId: menu, displayLocation: bottomBar)]
- Is admin: false

**Flow:**
```
System Pages:
  ├─ Menu → 🔄 (exists)
  ├─ Cart → ✅ SHOW (ordering active)
  └─ Profile → ✅ SHOW (always)

Builder Pages:
  └─ Custom Menu → ✅ SHOW (route: /menu)

Deduplication:
  ├─ /menu (builder) → KEEP
  └─ /menu (system) → REMOVE (duplicate)

Final Result: [Custom Menu, Cart, Profile]
```

### Scenario 5: Disabled Builder Page

**Input:**
- Active modules: `[]`
- Builder pages: [Promo (displayLocation: bottomBar, isActive: false)]
- Is admin: false

**Flow:**
```
System Pages:
  ├─ Menu → ✅ SHOW (always)
  ├─ Cart → ❌ HIDE (ordering not active)
  └─ Profile → ✅ SHOW (always)

Builder Pages:
  └─ Promo → ❌ HIDE (isActive: false)

Final Result: [Menu, Profile]
```

### Scenario 6: Builder Page with Module Requirement

**Input:**
- Active modules: `[]`
- Builder pages: [Rewards (displayLocation: bottomBar, modules: ['loyalty'])]
- Is admin: false

**Flow:**
```
System Pages:
  ├─ Menu → ✅ SHOW (always)
  ├─ Cart → ❌ HIDE (ordering not active)
  └─ Profile → ✅ SHOW (always)

Builder Pages:
  └─ Rewards → ❌ HIDE (requires loyalty, but loyalty not active)

Final Result: [Menu, Profile]
```

## Key Takeaways

1. **System pages** (menu, profile) are always visible
2. **Cart** only appears when `ordering` module is active
3. **Builder pages** must pass ALL checks:
   - displayLocation == 'bottomBar'
   - isActive == true
   - isEnabled == true
   - Required modules (if any) are active
4. **Ordering**: Builder first, then system, then modules
5. **Deduplication**: Builder overrides system for same route
6. **Loyalty/Roulette**: Never get tabs (inside Profile)

## Architecture Benefits

✅ **Single Decision Point** - All logic in one place
✅ **Predictable** - Deterministic ordering
✅ **Testable** - Clear input/output
✅ **Maintainable** - One file to update
✅ **Extensible** - Easy to add new rules
