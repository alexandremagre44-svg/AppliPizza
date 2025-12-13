/// lib/src/services/selection_formatter.dart
///
/// PHASE B: Centralized service for formatting order selections into readable text.
/// 
/// Provides helpers to generate human-readable descriptions from structured
/// OrderOptionSelection data, with fallback to legacyDescription.
library;

import '../models/order_option_selection.dart';

/// Formats a list of order option selections into a human-readable string.
/// 
/// Example:
/// ```dart
/// final selections = [
///   OrderOptionSelection(optionGroupId: 'size', optionId: 'large', label: 'Grande', priceDelta: 300),
///   OrderOptionSelection(optionGroupId: 'topping', optionId: 'cheese', label: 'Extra Fromage', priceDelta: 150),
/// ];
/// 
/// formatSelections(selections);
/// // Returns: "Grande • Extra Fromage"
/// ```
/// 
/// Returns null if selections is empty.
String? formatSelections(List<OrderOptionSelection> selections) {
  if (selections.isEmpty) {
    return null;
  }

  return selections.map((s) => s.label).join(' • ');
}

/// Formats selections with optional fallback to legacy description.
/// 
/// This is the recommended method for displaying order item descriptions
/// as it handles both new structured data and old legacy text.
/// 
/// Priority:
/// 1. If selections is not empty, format and return them
/// 2. Otherwise, return legacyDescription
/// 3. If both are null/empty, return null
String? formatSelectionsWithFallback({
  required List<OrderOptionSelection> selections,
  String? legacyDescription,
}) {
  final formatted = formatSelections(selections);
  return formatted ?? legacyDescription;
}

/// Formats selections grouped by option group.
/// 
/// Example output: "Taille: Grande | Suppléments: Extra Fromage, Olives"
/// 
/// Returns null if selections is empty.
String? formatSelectionsGrouped(List<OrderOptionSelection> selections) {
  if (selections.isEmpty) {
    return null;
  }

  // Group by optionGroupId
  final grouped = <String, List<OrderOptionSelection>>{};
  for (final selection in selections) {
    grouped.putIfAbsent(selection.optionGroupId, () => []).add(selection);
  }

  // Format each group
  final parts = <String>[];
  for (final entry in grouped.entries) {
    final groupId = entry.key;
    final groupSelections = entry.value;
    
    // Get group name from first selection (simplified)
    final labels = groupSelections.map((s) => s.label).join(', ');
    
    // Try to make a readable group name
    final groupName = _getGroupDisplayName(groupId);
    parts.add('$groupName: $labels');
  }

  return parts.join(' | ');
}

/// Converts a technical group ID to a readable display name.
String _getGroupDisplayName(String groupId) {
  switch (groupId) {
    case 'size':
      return 'Taille';
    case 'crust':
      return 'Pâte';
    case 'sauce':
      return 'Sauce';
    case 'toppings':
      return 'Suppléments';
    case 'drink':
      return 'Boisson';
    default:
      // Capitalize first letter
      return groupId.isNotEmpty
          ? groupId[0].toUpperCase() + groupId.substring(1)
          : groupId;
  }
}

/// Generates a compact summary for display in cart or tickets.
/// 
/// Prioritizes the most important information (size, main customizations).
/// Falls back to simple comma-separated list if no special handling.
String? formatSelectionsCompact(List<OrderOptionSelection> selections) {
  if (selections.isEmpty) {
    return null;
  }

  // Find size selection (most important)
  final sizeSelection = selections.firstWhere(
    (s) => s.optionGroupId == 'size',
    orElse: () => OrderOptionSelection(
      optionGroupId: '',
      optionId: '',
      label: '',
      priceDelta: 0,
    ),
  );

  final parts = <String>[];
  
  if (sizeSelection.optionGroupId.isNotEmpty) {
    parts.add(sizeSelection.label);
  }

  // Add other selections (excluding size)
  final otherSelections = selections
      .where((s) => s.optionGroupId != 'size')
      .map((s) => s.label)
      .toList();
  
  if (otherSelections.isNotEmpty) {
    // Limit to first 3 for compactness
    final displayed = otherSelections.take(3).join(', ');
    final remaining = otherSelections.length - 3;
    
    if (remaining > 0) {
      parts.add('$displayed +$remaining');
    } else {
      parts.add(displayed);
    }
  }

  return parts.isEmpty ? null : parts.join(' • ');
}

/// Calculates the total price delta from selections.
/// 
/// Returns the sum of all priceDelta values in cents.
int calculateTotalPriceDelta(List<OrderOptionSelection> selections) {
  return selections.fold<int>(0, (sum, selection) => sum + selection.priceDelta);
}

/// Formats price delta as a readable string.
/// 
/// Example: 200 -> "+2.00€", -50 -> "-0.50€", 0 -> ""
String formatPriceDelta(int deltaCents) {
  if (deltaCents == 0) return '';
  
  final sign = deltaCents > 0 ? '+' : '';
  final euros = (deltaCents / 100).toStringAsFixed(2);
  return '$sign$euros€';
}
