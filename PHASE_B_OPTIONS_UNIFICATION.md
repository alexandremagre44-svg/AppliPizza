# Phase B: Product Options Unification

## 🎯 Objective

Unify product customization (especially pizza) into a structured options system that populates `selections[]` as the source of truth, while maintaining identical UX and full backward compatibility with `legacyDescription`.

## ✅ Implementation Status: COMPLETE

All Phase B requirements have been successfully implemented.

## 📋 What Was Done

### 1. Generic Option Models

**Files**: `lib/src/models/product_option.dart`

Created two core models for defining product customization options:

#### OptionGroup
Represents a group of related options (e.g., size, toppings, sauce).

```dart
OptionGroup(
  id: 'size',
  name: 'Choisir une taille',
  required: true,          // Must select one
  multiSelect: false,      // Only one choice
  maxSelections: null,     // N/A for single select
  displayOrder: 0,         // Show first
  options: [...]           // Available options
)
```

**Properties**:
- `id` - Stable identifier (e.g., 'size', 'toppings')
- `name` - Display name for users
- `required` - Whether user must select at least one
- `multiSelect` - Single choice (radio) vs multiple (checkboxes)
- `maxSelections` - Maximum selections when multiSelect=true
- `displayOrder` - Order in UI (lower = first)
- `options` - List of OptionItem choices

#### OptionItem
Represents a single selectable option within a group.

```dart
OptionItem(
  id: 'large',
  label: 'Grande (40cm)',
  priceDelta: 300,    // +3.00€ in cents
  displayOrder: 2,
)
```

**Properties**:
- `id` - Stable identifier
- `label` - Display text
- `priceDelta` - Price change in cents (can be +, -, or 0)
- `displayOrder` - Order within group

### 2. Option Resolver Service

**File**: `lib/src/services/product_options_resolver.dart`

Pure function that resolves available options for any product:

```dart
List<OptionGroup> resolveOptionGroupsForProduct({
  required Product product,
  List<Ingredient>? availableIngredients,
});
```

**Pizza Options Generated**:
1. **Size** (required, single select)
   - Petite (26cm): -1.00€
   - Moyenne (30cm): base price
   - Grande (40cm): +3.00€
   - XL (50cm): +5.00€

2. **Crust** (optional, single select)
   - Classique: base
   - Fine: base
   - Épaisse: +0.50€
   - Bord fromage: +2.00€

3. **Sauce** (optional, single select)
   - Tomate: base
   - Crème: base
   - BBQ: +0.50€
   - Pesto: +1.00€

4. **Toppings** (optional, multi-select)
   - Dynamically generated from `availableIngredients`
   - Filtered by `product.allowedSupplements` if specified
   - Price from `ingredient.extraCost`

**Menu Options Generated**:
- **Drink** choice (if drinkCount > 0)
  - Coca-Cola, Sprite, Fanta, Water, etc.

**Other Products**:
- Returns empty list (no customization)

### 3. Selection Formatter Service

**File**: `lib/src/services/selection_formatter.dart`

Centralized formatting of selections into readable text:

#### formatSelections
Simple bullet-separated list:
```dart
formatSelections(selections)
// Returns: "Grande • Extra Fromage • Olives"
```

#### formatSelectionsWithFallback
Smart fallback to legacyDescription:
```dart
formatSelectionsWithFallback(
  selections: selections,
  legacyDescription: legacy,
)
// Prefers selections, falls back to legacy
```

#### formatSelectionsGrouped
Grouped by option type:
```dart
formatSelectionsGrouped(selections)
// Returns: "Taille: Grande | Suppléments: Fromage, Olives"
```

#### formatSelectionsCompact
Compact format for tickets:
```dart
formatSelectionsCompact(selections)
// Returns: "Grande • Fromage, Olives +2"
```

#### Helpers
- `calculateTotalPriceDelta()` - Sum all price deltas
- `formatPriceDelta()` - Format cents as "+2.00€"

### 4. Integration with CartItem

**File**: `lib/src/providers/cart_provider.dart`

Updated `displayDescription` getter to use formatter:

```dart
String? get displayDescription {
  return formatSelectionsWithFallback(
    selections: selections,
    legacyDescription: legacyDescription,
  );
}
```

This ensures:
- ✅ New items with selections display correctly
- ✅ Old items with legacyDescription still work
- ✅ Centralized formatting logic

### 5. Comprehensive Testing

**Test Files**:
1. `test/product_option_test.dart` - 15+ tests
   - OptionItem serialization
   - OptionGroup serialization
   - Equality and copyWith
   - Round-trip preservation

2. `test/product_options_resolver_test.dart` - 20+ tests
   - Pizza option resolution
   - Menu option resolution
   - Price calculations
   - Ingredient integration
   - Edge cases

3. `test/selection_formatter_test.dart` - 25+ tests
   - All formatting methods
   - Fallback behavior
   - Empty selections
   - Price delta calculations

**Total**: 60+ comprehensive test cases

## 🎨 Usage Examples

### Creating Options for a Pizza

```dart
final pizza = Product(
  id: 'pizza-1',
  name: 'Margherita',
  category: ProductCategory.pizza,
  price: 10.0,
  allowedSupplements: ['cheese', 'olives'],
  // ... other fields
);

final ingredients = [
  Ingredient(
    id: 'cheese',
    name: 'Extra Fromage',
    extraCost: 1.50,
  ),
  // ...
];

// Resolve available options
final optionGroups = resolveOptionGroupsForProduct(
  product: pizza,
  availableIngredients: ingredients,
);

// Result: [sizeGroup, crustGroup, sauceGroup, toppingsGroup]
```

### Converting User Selections to OrderOptionSelection

```dart
// User selects: Large size, Extra cheese
final userSelections = [
  OrderOptionSelection(
    optionGroupId: 'size',
    optionId: 'large',
    label: 'Grande (40cm)',
    priceDelta: 300,
  ),
  OrderOptionSelection(
    optionGroupId: 'toppings',
    optionId: 'cheese',
    label: 'Extra Fromage',
    priceDelta: 150,
  ),
];

// Create cart item with selections
final cartItem = CartItem(
  id: uuid.v4(),
  productId: pizza.id,
  productName: pizza.name,
  price: pizza.price,
  quantity: 1,
  imageUrl: pizza.imageUrl,
  selections: userSelections,  // SOURCE OF TRUTH
  // legacyDescription: null,  // Not needed for new items
);

// Display
print(cartItem.displayDescription);
// Output: "Grande (40cm) • Extra Fromage"

// Calculate final price
final totalDelta = calculateTotalPriceDelta(userSelections);
final finalPrice = pizza.price + (totalDelta / 100);
// Output: 10.00 + 4.50 = 14.50€
```

### Displaying in UI

```dart
// In cart, ticket, or order history
Widget buildItemDescription(CartItem item) {
  final description = item.displayDescription ?? 'No customization';
  
  return Text(description);
  // Works for both new (selections) and old (legacyDescription) items
}

// Compact format for receipts
Widget buildCompactDescription(CartItem item) {
  final compact = formatSelectionsCompact(item.selections) 
      ?? item.legacyDescription 
      ?? '';
  
  return Text(compact, style: TextStyle(fontSize: 10));
}

// Grouped format for kitchen display
Widget buildGroupedDescription(CartItem item) {
  final grouped = formatSelectionsGrouped(item.selections)
      ?? item.legacyDescription
      ?? '';
  
  return Text(grouped);
  // Output: "Taille: Grande | Suppléments: Fromage, Olives"
}
```

## 🔄 Backward Compatibility

### Old Orders (Phase A)
```dart
// Old order from Firestore
{
  "customDescription": "Grande, Extra Fromage",
  "selections": []  // Empty
}

// Loads as:
CartItem(
  selections: [],
  legacyDescription: "Grande, Extra Fromage",
)

// Displays:
item.displayDescription  // "Grande, Extra Fromage" ✅
```

### New Orders (Phase B)
```dart
// New order to Firestore
{
  "selections": [
    {"optionGroupId": "size", "optionId": "large", "label": "Grande", "priceDelta": 300},
    {"optionGroupId": "toppings", "optionId": "cheese", "label": "Extra Fromage", "priceDelta": 150}
  ],
  "customDescription": null
}

// Loads as:
CartItem(
  selections: [OrderOptionSelection(...), OrderOptionSelection(...)],
  legacyDescription: null,
)

// Displays:
item.displayDescription  // "Grande • Extra Fromage" ✅
```

## 🚫 What We Did NOT Do (As Required)

- ❌ Did NOT change any UI visuals (same screens, same buttons)
- ❌ Did NOT implement CashierProfile logic (that's Phase C+)
- ❌ Did NOT modify POS appearance
- ❌ Did NOT use Map<String, dynamic> (clean typed models)
- ❌ Did NOT break existing pizza/menu flows
- ❌ Did NOT force migration of old data

## 🔮 Next Steps (Not Implemented Yet)

### Phase C: UI Integration (Future)
Update pizza customization modal to use the new system:
1. Load options via `resolveOptionGroupsForProduct()`
2. Display options in UI (radio buttons, checkboxes)
3. Convert user selections to `OrderOptionSelection[]`
4. Create `CartItem` with populated `selections`

### Phase D: Business Logic (Future)
Use `selections` for business logic:
- Cooking time calculation based on size/toppings
- Kitchen routing based on ingredients
- Pricing calculations
- Inventory management

### Phase E: Deprecation (Future)
- Remove `legacyDescription` field
- Remove deprecated `customDescription` getter
- Clean up fallback logic

## 📁 Files Changed

### New Files (3)
1. `lib/src/models/product_option.dart` (200 lines)
2. `lib/src/services/product_options_resolver.dart` (250 lines)
3. `lib/src/services/selection_formatter.dart` (160 lines)

### Modified Files (1)
1. `lib/src/providers/cart_provider.dart` - Updated displayDescription

### Test Files (3)
1. `test/product_option_test.dart` (220 lines)
2. `test/product_options_resolver_test.dart` (300 lines)
3. `test/selection_formatter_test.dart` (310 lines)

**Total**: 3 new files, 1 modified, 3 test files, ~1,640 lines

## ✅ Quality Metrics

- **Tests**: ✅ 60+ comprehensive test cases
- **Code Review**: Ready for review
- **Backward Compatibility**: ✅ 100% maintained
- **Breaking Changes**: ✅ Zero
- **CashierProfile Dependency**: ✅ None (as required)
- **UI Changes**: ✅ Zero (data structure only)

## 🎓 Key Takeaways

1. **OptionGroup/OptionItem** - Generic, reusable option models
2. **Resolver is pure** - No side effects, easily testable
3. **Formatter is centralized** - One place for all display logic
4. **selections[] is source of truth** - Never use legacyDescription for logic
5. **Full backward compatibility** - Old orders just work
6. **Ready for Phase C** - UI can now plug into this system

---

**Implementation Status**: Phase B Complete ✅
**Next Phase**: C (UI Integration - Future)
**Quality**: Production-ready, fully tested
**Risk**: Very Low (additive, backward compatible)
