/// lib/src/services/product_options_resolver.dart
///
/// PHASE B: Pure function to resolve option groups for a product.
/// 
/// This service provides a centralized way to determine what customization
/// options are available for each product type. It unifies existing pizza
/// customization logic and can be extended for other product types.
/// 
/// IMPORTANT: This phase does NOT depend on CashierProfile.
library;

import '../models/product.dart';
import '../models/product_option.dart';

/// Resolves the list of option groups available for a given product.
/// 
/// This is a pure function that takes a product and returns the applicable
/// option groups based on product category and configuration.
/// 
/// Example usage:
/// ```dart
/// final product = Product(...);  // A pizza product
/// final optionGroups = resolveOptionGroupsForProduct(product: product);
/// // Returns: [sizeGroup, toppingsGroup, ...]
/// ```
/// 
/// Returns an empty list if the product has no customization options.
List<OptionGroup> resolveOptionGroupsForProduct({
  required Product product,
  List<Ingredient>? availableIngredients,
}) {
  final groups = <OptionGroup>[];

  // Pizza-specific options
  if (product.category == ProductCategory.pizza) {
    groups.addAll(_resolvePizzaOptions(product, availableIngredients));
  }

  // Menu-specific options
  if (product.isMenu) {
    groups.addAll(_resolveMenuOptions(product));
  }

  // Sort by displayOrder
  groups.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

  return groups;
}

/// Resolves pizza-specific option groups.
List<OptionGroup> _resolvePizzaOptions(
  Product product,
  List<Ingredient>? availableIngredients,
) {
  final groups = <OptionGroup>[];

  // 1. Size selection (required, single choice)
  groups.add(OptionGroup(
    id: 'size',
    name: 'Choisir une taille',
    required: true,
    multiSelect: false,
    displayOrder: 0,
    options: [
      OptionItem(
        id: 'small',
        label: 'Petite (26cm)',
        priceDelta: -100, // -1.00€
        displayOrder: 0,
      ),
      OptionItem(
        id: 'medium',
        label: 'Moyenne (30cm)',
        priceDelta: 0, // Base price
        displayOrder: 1,
      ),
      OptionItem(
        id: 'large',
        label: 'Grande (40cm)',
        priceDelta: 300, // +3.00€
        displayOrder: 2,
      ),
      OptionItem(
        id: 'xl',
        label: 'XL (50cm)',
        priceDelta: 500, // +5.00€
        displayOrder: 3,
      ),
    ],
  ));

  // 2. Crust type (optional, single choice)
  groups.add(OptionGroup(
    id: 'crust',
    name: 'Type de pâte',
    required: false,
    multiSelect: false,
    displayOrder: 1,
    options: [
      OptionItem(
        id: 'classic',
        label: 'Classique',
        priceDelta: 0,
        displayOrder: 0,
      ),
      OptionItem(
        id: 'thin',
        label: 'Fine',
        priceDelta: 0,
        displayOrder: 1,
      ),
      OptionItem(
        id: 'thick',
        label: 'Épaisse',
        priceDelta: 50, // +0.50€
        displayOrder: 2,
      ),
      OptionItem(
        id: 'cheesy_crust',
        label: 'Bord fromage',
        priceDelta: 200, // +2.00€
        displayOrder: 3,
      ),
    ],
  ));

  // 3. Base sauce (optional, single choice)
  groups.add(OptionGroup(
    id: 'sauce',
    name: 'Sauce de base',
    required: false,
    multiSelect: false,
    displayOrder: 2,
    options: [
      OptionItem(
        id: 'tomato',
        label: 'Tomate',
        priceDelta: 0,
        displayOrder: 0,
      ),
      OptionItem(
        id: 'cream',
        label: 'Crème',
        priceDelta: 0,
        displayOrder: 1,
      ),
      OptionItem(
        id: 'bbq',
        label: 'BBQ',
        priceDelta: 50, // +0.50€
        displayOrder: 2,
      ),
      OptionItem(
        id: 'pesto',
        label: 'Pesto',
        priceDelta: 100, // +1.00€
        displayOrder: 3,
      ),
    ],
  ));

  // 4. Extra toppings (optional, multiple choices)
  // Use ingredients from availableIngredients if provided,
  // otherwise use product's allowedSupplements
  if (availableIngredients != null && availableIngredients.isNotEmpty) {
    // Filter to allowed supplements if product specifies them
    final allowedIngredients = product.allowedSupplements.isNotEmpty
        ? availableIngredients
            .where((ing) => product.allowedSupplements.contains(ing.id))
            .toList()
        : availableIngredients;

    if (allowedIngredients.isNotEmpty) {
      // Sort by category and then by order
      final sortedIngredients = List<Ingredient>.from(allowedIngredients)
        ..sort((a, b) {
          final categoryCompare = a.category.index.compareTo(b.category.index);
          if (categoryCompare != 0) return categoryCompare;
          return a.order.compareTo(b.order);
        });

      groups.add(OptionGroup(
        id: 'toppings',
        name: 'Suppléments',
        required: false,
        multiSelect: true,
        maxSelections: null, // Unlimited
        displayOrder: 3,
        options: sortedIngredients.map((ingredient) {
          return OptionItem(
            id: ingredient.id,
            label: ingredient.name,
            priceDelta: (ingredient.extraCost * 100).round(), // Convert € to cents
            displayOrder: ingredient.order,
          );
        }).toList(),
      ));
    }
  } else if (product.allowedSupplements.isNotEmpty) {
    // Fallback: create basic options from allowed supplement IDs
    groups.add(OptionGroup(
      id: 'toppings',
      name: 'Suppléments',
      required: false,
      multiSelect: true,
      maxSelections: null,
      displayOrder: 3,
      options: product.allowedSupplements.asMap().entries.map((entry) {
        final ingredientId = entry.value;
        return OptionItem(
          id: ingredientId,
          label: _formatIngredientLabel(ingredientId), // Capitalize and format
          priceDelta: 150, // Default +1.50€
          displayOrder: entry.key,
        );
      }).toList(),
    ));
  }

  return groups;
}

/// Resolves menu-specific option groups.
List<OptionGroup> _resolveMenuOptions(Product product) {
  final groups = <OptionGroup>[];

  // For menus, we could add drink selection, dessert selection, etc.
  // This is a placeholder for future menu customization
  
  // Example: Drink choice for menus
  if (product.drinkCount > 0) {
    groups.add(OptionGroup(
      id: 'drink',
      name: 'Choisir une boisson',
      required: true,
      multiSelect: false,
      displayOrder: 10,
      options: [
        OptionItem(
          id: 'cola',
          label: 'Coca-Cola',
          priceDelta: 0,
          displayOrder: 0,
        ),
        OptionItem(
          id: 'cola_zero',
          label: 'Coca-Cola Zero',
          priceDelta: 0,
          displayOrder: 1,
        ),
        OptionItem(
          id: 'sprite',
          label: 'Sprite',
          priceDelta: 0,
          displayOrder: 2,
        ),
        OptionItem(
          id: 'fanta',
          label: 'Fanta',
          priceDelta: 0,
          displayOrder: 3,
        ),
        OptionItem(
          id: 'water',
          label: 'Eau',
          priceDelta: 0,
          displayOrder: 4,
        ),
      ],
    ));
  }

  return groups;
}

/// Formats an ingredient ID into a readable label.
/// 
/// Converts underscores/hyphens to spaces and capitalizes words.
String _formatIngredientLabel(String ingredientId) {
  // Replace underscores and hyphens with spaces
  final words = ingredientId.replaceAll(RegExp(r'[_-]'), ' ').split(' ');
  
  // Capitalize each word
  final capitalized = words.map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
  
  return capitalized;
}

/// Helper to calculate the total price including option selections.
/// 
/// Takes a base price and a list of selected options, returns final price.
double calculatePriceWithOptions({
  required double basePrice,
  required List<OptionItem> selectedOptions,
}) {
  final totalDeltaCents = selectedOptions.fold<int>(
    0,
    (sum, option) => sum + option.priceDelta,
  );
  return basePrice + (totalDeltaCents / 100);
}
