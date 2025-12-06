// lib/builder/utils/builder_modules.dart
// Utility file for Builder modules mapping
//
// This file defines the available modules that can be attached to pages.
// The runtime will use this mapping to render the appropriate widgets.

import 'package:flutter/material.dart';
import '../runtime/modules/menu_catalog_runtime_widget.dart';
import '../runtime/modules/profile_module_widget.dart';
import '../runtime/modules/roulette_module_widget.dart';
import '../../white_label/core/module_id.dart';

/// Builder modules configuration
/// 
/// Maps module IDs to their widget builders.
/// This is used by the runtime to render modules on pages.
/// 
/// Available modules:
/// - menu_catalog: Product catalog widget
/// - cart_module: Shopping cart widget
/// - profile_module: User profile widget
/// - roulette_module: Roulette game widget
/// 
/// Usage in runtime:
/// ```dart
/// final widget = builderModules['menu_catalog']?.call(context);
/// if (widget != null) {
///   return widget;
/// }
/// ```
/// 
/// Note: The actual widget implementations are in the runtime,
/// this file provides the mapping structure only.

/// Module widget builder type
typedef ModuleWidgetBuilder = Widget Function(BuildContext context);

/// Placeholder widget builder for modules
/// 
/// Returns a placeholder widget with the module name.
/// Replace with actual widget implementations in runtime.
Widget _placeholderModule(BuildContext context, String moduleName) {
  return Center(
    child: Text('Module: $moduleName (to implement)'),
  );
}



/// Module ID mapping
/// 
/// Maps Builder module IDs to their corresponding white-label ModuleId codes.
/// This ensures compatibility between the Builder system and white-label module checking.
/// 
/// Builder IDs -> White-label codes:
/// - 'menu_catalog' -> 'ordering'
/// - 'cart_module' -> 'ordering'
/// - 'profile_module' -> 'ordering' (part of core ordering system)
/// - 'roulette_module' -> 'roulette'
final Map<String, String> moduleIdMapping = {
  'menu_catalog': ModuleId.ordering.code,
  'cart_module': ModuleId.ordering.code,
  'profile_module': ModuleId.ordering.code,
  'roulette_module': ModuleId.roulette.code,
  // Aliases for backward compatibility
  'roulette': ModuleId.roulette.code,
};

/// Get the white-label ModuleId code for a Builder module ID
/// 
/// Returns null if the module ID is not mapped.
String? getModuleIdCode(String builderModuleId) {
  return moduleIdMapping[builderModuleId];
}

/// Get the ModuleId enum for a Builder module ID
/// 
/// Returns null if the module ID is not mapped or invalid.
ModuleId? getModuleId(String builderModuleId) {
  final code = moduleIdMapping[builderModuleId];
  if (code == null) return null;
  
  for (final moduleId in ModuleId.values) {
    if (moduleId.code == code) {
      return moduleId;
    }
  }
  return null;
}

/// Builder modules mapping
/// 
/// Maps module IDs to their widget builders.
/// 
/// All runtime widgets are imported and available directly.
final Map<String, ModuleWidgetBuilder> builderModules = {
  'menu_catalog': (context) => const MenuCatalogRuntimeWidget(),
  'cart_module': (context) => const CartModuleWidget(),
  'profile_module': (context) => const ProfileModuleWidget(),
  'roulette_module': (context) => const RouletteModuleWidget(),
};

/// Module configuration
/// 
/// Contains metadata about each module for the editor.
class ModuleConfig {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isSystemModule;
  
  const ModuleConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isSystemModule = false,
  });
}

/// Available module configurations
/// 
/// Used by the editor to display module options.
const List<ModuleConfig> availableModules = [
  ModuleConfig(
    id: 'menu_catalog',
    name: 'Catalogue Menu',
    description: 'Affiche la liste des produits avec catégories et filtres',
    icon: 'restaurant_menu',
    isSystemModule: false,
  ),
  ModuleConfig(
    id: 'cart_module',
    name: 'Panier',
    description: 'Panier et validation de commande',
    icon: 'shopping_cart',
    isSystemModule: true,
  ),
  ModuleConfig(
    id: 'profile_module',
    name: 'Profil Utilisateur',
    description: 'Widget du profil avec informations et paramètres',
    icon: 'person',
    isSystemModule: true,
  ),
  ModuleConfig(
    id: 'roulette_module',
    name: 'Roue de la Chance',
    description: 'Widget de la roulette pour gagner des récompenses',
    icon: 'casino',
    isSystemModule: false,
  ),
];

/// Get module configuration by ID
ModuleConfig? getModuleConfig(String moduleId) {
  try {
    return availableModules.firstWhere((m) => m.id == moduleId);
  } catch (e) {
    return null;
  }
}

/// Check if a module ID is valid
bool isValidModuleId(String moduleId) {
  return availableModules.any((m) => m.id == moduleId);
}

/// Get all module IDs
List<String> getAllModuleIds() {
  return availableModules.map((m) => m.id).toList();
}

/// Get system modules only
List<ModuleConfig> getSystemModules() {
  return availableModules.where((m) => m.isSystemModule).toList();
}

/// Get non-system modules only
List<ModuleConfig> getNonSystemModules() {
  return availableModules.where((m) => !m.isSystemModule).toList();
}

/// Register a custom module widget builder
/// 
/// Used by the runtime to register actual widget implementations.
/// 
/// Example:
/// ```dart
/// registerModuleBuilder('menu_catalog', (context) => MenuCatalogWidget());
/// ```
void registerModuleBuilder(String moduleId, ModuleWidgetBuilder builder) {
  if (!isValidModuleId(moduleId)) {
    throw ArgumentError('Invalid module ID: $moduleId');
  }
  builderModules[moduleId] = builder;
}

/// Get the widget builder for a module
/// 
/// Returns null if the module ID is not found.
ModuleWidgetBuilder? getModuleBuilder(String moduleId) {
  return builderModules[moduleId];
}

/// Render a module widget
/// 
/// Returns the module widget or a placeholder if not found.
Widget renderModule(BuildContext context, String moduleId) {
  final builder = builderModules[moduleId];
  if (builder != null) {
    return builder(context);
  }
  return _placeholderModule(context, 'Module inconnu: $moduleId');
}

/// Future-proof cart module widget with payment callbacks
/// 
/// This widget is designed to be extended with payment integrations (Stripe, PayPal)
/// Callbacks are optional and not used yet, but ready for future implementation
class CartModuleWidget extends StatelessWidget {
  /// Called when user requests checkout (optional, for future use)
  final VoidCallback? onCheckoutRequested;
  
  /// Called when user selects a payment method (optional, for future use)
  /// paymentMethod can be: 'stripe', 'paypal', 'cash', etc.
  final void Function(String paymentMethod)? onPaymentSelected;
  
  const CartModuleWidget({
    super.key,
    this.onCheckoutRequested,
    this.onPaymentSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Module Panier',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Widget du panier d\'achat',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Future-proof pour Stripe/PayPal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blue[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
