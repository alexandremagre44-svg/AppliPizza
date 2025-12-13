/// lib/src/services/cart_item_builder.dart
///
/// PHASE C1: Helper service to build CartItem with selections from UI choices.
/// 
/// This service provides a centralized way to convert user selections
/// from customization modals into OrderOptionSelection objects and create
/// CartItem instances with properly populated selections[].
library;

import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/product_option.dart';
import '../models/order_option_selection.dart';
import '../providers/cart_provider.dart';
import '../services/selection_formatter.dart';

const _uuid = Uuid();

/// Builds a CartItem from product and user option selections.
/// 
/// PHASE C1: This is the bridge between UI and structured data.
/// 
/// Example usage:
/// ```dart
/// final item = buildCartItemWithSelections(
///   product: pizza,
///   selectedOptions: {
///     'size': sizeOptionItem,
///     'toppings': [cheeseItem, olivesItem],
///   },
///   quantity: 1,
/// );
/// // item.selections contains OrderOptionSelection objects
/// // item.legacyDescription is generated as fallback
/// ```
CartItem buildCartItemWithSelections({
  required Product product,
  required Map<String, dynamic> selectedOptions,
  int quantity = 1,
}) {
  final selections = <OrderOptionSelection>[];

  // Convert selected options to OrderOptionSelection
  for (final entry in selectedOptions.entries) {
    final groupId = entry.key;
    final value = entry.value;

    if (value is OptionItem) {
      // Single selection (e.g., size, crust, sauce, cooking)
      selections.add(OrderOptionSelection(
        optionGroupId: groupId,
        optionId: value.id,
        label: value.label,
        priceDelta: value.priceDelta,
      ));
    } else if (value is List<OptionItem>) {
      // Multiple selections (e.g., toppings)
      for (final item in value) {
        selections.add(OrderOptionSelection(
          optionGroupId: groupId,
          optionId: item.id,
          label: item.label,
          priceDelta: item.priceDelta,
        ));
      }
    }
  }

  // Calculate final price with options
  final totalPriceDelta = calculateTotalPriceDelta(selections);
  final finalPrice = product.price + (totalPriceDelta / 100);

  // Generate legacy description as fallback (for old UI components)
  final legacyDescription = formatSelections(selections);

  return CartItem(
    id: _uuid.v4(),
    productId: product.id,
    productName: product.name,
    price: finalPrice,
    quantity: quantity,
    imageUrl: product.imageUrl,
    selections: selections, // SOURCE OF TRUTH (Phase A/B)
    customDescription: legacyDescription, // Fallback for display
    isMenu: product.isMenu,
  );
}

/// Validates that all required option groups have selections.
/// 
/// Returns error message if validation fails, null if valid.
String? validateRequiredSelections({
  required List<OptionGroup> optionGroups,
  required Map<String, dynamic> selectedOptions,
}) {
  for (final group in optionGroups) {
    if (!group.required) continue;

    final selection = selectedOptions[group.id];
    
    if (selection == null) {
      return '${group.name} est requis';
    }

    // Check for empty list in multi-select
    if (selection is List && selection.isEmpty) {
      return '${group.name} est requis';
    }
  }

  return null; // All required selections present
}

/// Helper to create a selections map entry for single selection.
/// 
/// Usage in UI:
/// ```dart
/// final selectedOptions = <String, dynamic>{};
/// selectedOptions['size'] = largeOptionItem;
/// ```
void selectSingleOption(
  Map<String, dynamic> selectedOptions,
  String groupId,
  OptionItem optionItem,
) {
  selectedOptions[groupId] = optionItem;
}

/// Helper to toggle a multi-select option.
/// 
/// Usage in UI:
/// ```dart
/// final selectedOptions = <String, dynamic>{
///   'toppings': <OptionItem>[],
/// };
/// toggleMultiSelectOption(selectedOptions, 'toppings', cheeseOptionItem);
/// ```
void toggleMultiSelectOption(
  Map<String, dynamic> selectedOptions,
  String groupId,
  OptionItem optionItem,
) {
  final list = selectedOptions[groupId] as List<OptionItem>? ?? <OptionItem>[];
  
  if (list.any((item) => item.id == optionItem.id)) {
    list.removeWhere((item) => item.id == optionItem.id);
  } else {
    list.add(optionItem);
  }
  
  selectedOptions[groupId] = list;
}
