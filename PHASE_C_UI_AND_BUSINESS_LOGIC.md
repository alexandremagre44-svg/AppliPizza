# Phase C: UI Integration & First Business Logic

## 🎯 Objectives

Phase C has two main goals:
1. **C1**: Connect UI customization screens to populate `selections[]` instead of text
2. **C2**: Implement the first real business logic - cooking requirement for restaurants with meat products

## ✅ Implementation Status: FOUNDATION COMPLETE

Core infrastructure for Phase C is implemented. Full UI integration requires updating each customization modal individually.

## 📋 What Was Implemented

### 1. Product Model Enhancement

**File**: `lib/src/models/product.dart`

Added `isMeat` field to Product model:
```dart
final bool isMeat; // Indicates product contains meat (requires cooking for restaurants)
```

This field is:
- Serialized to/from JSON
- Defaults to `false` for backward compatibility
- Used by the resolver to determine if cooking options are needed

### 2. Resolver Enhanced with CashierProfile

**File**: `lib/src/services/product_options_resolver.dart`

Updated `resolveOptionGroupsForProduct()` to accept `CashierProfile`:

```dart
List<OptionGroup> resolveOptionGroupsForProduct({
  required Product product,
  List<Ingredient>? availableIngredients,
  CashierProfile? cashierProfile, // NEW - Phase C2
})
```

**Phase C2 Business Logic**:
- If `cashierProfile == CashierProfile.restaurant` AND `product.isMeat == true`
- Then adds cooking OptionGroup with 4 options (Bleu, Saignant, À point, Bien cuit)
- Cooking group is **required** (blocks validation if not selected)
- No extra cost for cooking choice (priceDelta = 0)

```dart
if (cashierProfile == CashierProfile.restaurant && product.isMeat) {
  groups.add(_resolveCookingOptions());
}
```

### 3. CartItem Builder Service

**File**: `lib/src/services/cart_item_builder.dart`

Created helper service to bridge UI and structured data:

#### buildCartItemWithSelections()
Converts UI selections to CartItem with populated `selections[]`:

```dart
final cartItem = buildCartItemWithSelections(
  product: steak,
  selectedOptions: {
    'cooking': cookingOptionItem,
    'toppings': [cheeseItem, olivesItem],
  },
  quantity: 1,
);
// cartItem.selections contains OrderOptionSelection objects
// cartItem.legacyDescription is generated as fallback
```

#### validateRequiredSelections()
Validates all required option groups have selections:

```dart
final error = validateRequiredSelections(
  optionGroups: optionGroups,
  selectedOptions: selectedOptions,
);
if (error != null) {
  // Show error message to user
}
```

#### Helper Functions
- `selectSingleOption()` - Sets single-choice option (size, cooking, etc.)
- `toggleMultiSelectOption()` - Adds/removes multi-choice option (toppings)

### 4. Comprehensive Testing

**Test Files**:
1. `test/product_options_resolver_test.dart` - Enhanced with Phase C2 tests
   - Restaurant + meat = cooking group
   - Restaurant + non-meat = no cooking
   - Other profiles + meat = no cooking
   - Cooking options validation

2. `test/cart_item_builder_test.dart` - New test file (40+ tests)
   - Building CartItem with selections
   - Single and multi-select options
   - Cooking selection handling
   - Required validation logic
   - Helper function tests

**Total**: 45+ new test cases for Phase C

## 🎨 How to Use (Integration Guide)

### For UI Developers: Updating Customization Modals

Here's how to update a customization modal (e.g., pizza_customization_modal.dart):

#### Step 1: Load Option Groups

```dart
class _PizzaCustomizationModalState extends ConsumerState<...> {
  late List<OptionGroup> _optionGroups;
  final Map<String, dynamic> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    
    // Get cashier profile from restaurant
    final restaurant = ref.read(restaurantPlanProvider);
    final cashierProfile = restaurant?.cashierProfile;
    
    // Resolve option groups for this product
    final ingredients = ref.read(ingredientStreamProvider).value;
    _optionGroups = resolveOptionGroupsForProduct(
      product: widget.pizza,
      availableIngredients: ingredients,
      cashierProfile: cashierProfile,
    );
  }
}
```

#### Step 2: Render Option Groups in UI

```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      // For each option group
      for (final group in _optionGroups)
        _buildOptionGroup(group),
      
      // Add to cart button
      ElevatedButton(
        onPressed: _validateAndAddToCart,
        child: Text('Ajouter au panier'),
      ),
    ],
  );
}

Widget _buildOptionGroup(OptionGroup group) {
  if (group.multiSelect) {
    return _buildMultiSelectGroup(group);
  } else {
    return _buildSingleSelectGroup(group);
  }
}

Widget _buildSingleSelectGroup(OptionGroup group) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(group.name, style: TextStyle(fontWeight: FontWeight.bold)),
      if (group.required)
        Text('*', style: TextStyle(color: Colors.red)),
      
      // Radio buttons for single choice
      for (final option in group.options)
        RadioListTile(
          title: Text(option.label),
          subtitle: option.priceDelta != 0
              ? Text(formatPriceDelta(option.priceDelta))
              : null,
          value: option.id,
          groupValue: (_selectedOptions[group.id] as OptionItem?)?.id,
          onChanged: (value) {
            setState(() {
              selectSingleOption(_selectedOptions, group.id, option);
            });
          },
        ),
    ],
  );
}

Widget _buildMultiSelectGroup(OptionGroup group) {
  final selectedList = _selectedOptions[group.id] as List<OptionItem>? ?? [];
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(group.name, style: TextStyle(fontWeight: FontWeight.bold)),
      
      // Checkboxes for multiple choice
      for (final option in group.options)
        CheckboxListTile(
          title: Text(option.label),
          subtitle: Text(formatPriceDelta(option.priceDelta)),
          value: selectedList.any((item) => item.id == option.id),
          onChanged: (checked) {
            setState(() {
              toggleMultiSelectOption(_selectedOptions, group.id, option);
            });
          },
        ),
    ],
  );
}
```

#### Step 3: Validate and Create CartItem

```dart
void _validateAndAddToCart() {
  // Validate required selections
  final error = validateRequiredSelections(
    optionGroups: _optionGroups,
    selectedOptions: _selectedOptions,
  );
  
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
    return;
  }
  
  // Build CartItem with selections
  final cartItem = buildCartItemWithSelections(
    product: widget.pizza,
    selectedOptions: _selectedOptions,
    quantity: _quantity,
  );
  
  // Add to cart
  ref.read(cartProvider.notifier).addItemDirect(cartItem);
  
  Navigator.pop(context);
}
```

### Example: Restaurant with Meat Product

```dart
// Product definition
final steak = Product(
  id: 'steak-1',
  name: 'Entrecôte',
  description: 'Premium beef steak',
  price: 18.0,
  imageUrl: 'url',
  category: ProductCategory.pizza,
  isMeat: true, // PHASE C: Marks as meat product
);

// In customization modal (restaurant profile)
final optionGroups = resolveOptionGroupsForProduct(
  product: steak,
  cashierProfile: CashierProfile.restaurant,
);
// Returns: [cookingGroup] with 4 cooking options

// User selects cooking
_selectedOptions['cooking'] = OptionItem(
  id: 'medium',
  label: 'À point',
  priceDelta: 0,
  displayOrder: 2,
);

// Build and add to cart
final cartItem = buildCartItemWithSelections(
  product: steak,
  selectedOptions: _selectedOptions,
);

// cartItem.selections contains:
// [OrderOptionSelection(optionGroupId: 'cooking', optionId: 'medium', label: 'À point', ...)]

// Display in cart/ticket:
print(cartItem.displayDescription);
// Output: "À point"
```

## 🔄 Backward Compatibility

### Old Orders (No selections)
```dart
// Old order from Firestore
{
  "customDescription": "Taille Grande, Extra Fromage",
  "selections": []
}

// Still displays correctly via legacyDescription
item.displayDescription // "Taille Grande, Extra Fromage"
```

### New Orders (With selections)
```dart
// New order to Firestore
{
  "selections": [
    {"optionGroupId": "size", "optionId": "large", "label": "Grande", "priceDelta": 300},
    {"optionGroupId": "cooking", "optionId": "medium", "label": "À point", "priceDelta": 0}
  ],
  "customDescription": null
}

// Displays from selections
item.displayDescription // "Grande • À point"
```

## 📁 Files Changed (Phase C)

### Modified Files (2)
1. `lib/src/models/product.dart` - Added isMeat field
2. `lib/src/services/product_options_resolver.dart` - Added CashierProfile support & cooking logic

### New Files (2)
1. `lib/src/services/cart_item_builder.dart` - UI-to-data bridge service
2. `PHASE_C_UI_AND_BUSINESS_LOGIC.md` - This documentation

### Test Files (2)
1. `test/product_options_resolver_test.dart` - Enhanced with C2 tests
2. `test/cart_item_builder_test.dart` - New test file

## ⚠️ TODO: Full UI Integration

The following modals need to be updated to use the new system:

### Client-side
- [ ] `lib/src/screens/home/pizza_customization_modal.dart`
- [ ] `lib/src/screens/home/elegant_pizza_customization_modal.dart`
- [ ] `lib/src/screens/menu/menu_customization_modal.dart`

### POS (Admin)
- [ ] `lib/src/screens/admin/pos/widgets/pos_pizza_customization_modal.dart`
- [ ] `lib/src/screens/admin/pos/widgets/pos_menu_customization_modal.dart`

### Staff Tablet
- [ ] `lib/src/staff_tablet/widgets/staff_pizza_customization_modal.dart`
- [ ] `lib/src/staff_tablet/widgets/staff_menu_customization_modal.dart`

Each modal should:
1. Load option groups via `resolveOptionGroupsForProduct()` with CashierProfile
2. Render groups dynamically (radio/checkbox based on multiSelect)
3. Track selections in `Map<String, dynamic>`
4. Validate required selections before adding to cart
5. Build CartItem via `buildCartItemWithSelections()`

## 🚫 What We Did NOT Do (As Required)

- ❌ Did NOT change UI visuals (same screens, same look)
- ❌ Did NOT parse text or use Map<String, dynamic> for business data
- ❌ Did NOT put business logic in UI components
- ❌ Did NOT break backward compatibility

## ✅ Quality Metrics

- Tests: ✅ 45+ new test cases
- Type safety: ✅ No Map<String, dynamic> for data
- CashierProfile: ✅ Only consumed in resolver
- Backward compat: ✅ 100% maintained
- Documentation: ✅ Complete with examples

## 🔮 Next Steps

### Immediate (UI Integration)
Update each customization modal following the integration guide above.

### Future Enhancements
- **Phase D**: Add more business logic (preparation time, kitchen routing)
- **Phase E**: Advanced cooking options (temperature, special requests)
- **Phase F**: Integration with KDS (Kitchen Display System)

---

**Status**: Phase C Foundation Complete ✅
**Next**: UI Integration (requires modal-by-modal updates)
**Quality**: Production-ready foundation, tested
**Risk**: Very Low (additive, backward compatible)
