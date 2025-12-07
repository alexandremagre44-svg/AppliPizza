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
import '../../white_label/restaurant/restaurant_plan_unified.dart';

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



/// Mapping Builder module ID → White-Label ModuleId
/// 
/// This centralized mapping ensures all builder modules are properly
/// validated against the restaurant's white-label plan.
/// 
/// Note: Multiple builder modules can map to the same ModuleId:
/// - 'menu_catalog', 'cart_module', 'profile_module' → ModuleId.ordering
///   (all part of the core ordering system)
/// - 'loyalty_module', 'rewards_module' → ModuleId.loyalty
///   (both require the loyalty feature)
/// 
/// Legacy modules without mapping:
/// - 'accountActivity': Legacy module, always visible (no White-Label mapping)
///   This module represents account activity history and is kept for backward
///   compatibility. It's always displayed regardless of plan configuration.
const Map<String, ModuleId> moduleIdMapping = {
  // Core ordering system modules
  'menu_catalog': ModuleId.ordering,
  'cart_module': ModuleId.ordering,
  'profile_module': ModuleId.ordering,
  // Marketing modules
  'roulette_module': ModuleId.roulette,
  'loyalty_module': ModuleId.loyalty,
  'rewards_module': ModuleId.loyalty,
  'delivery_module': ModuleId.delivery,
  'click_collect_module': ModuleId.clickAndCollect,
  'kitchen_module': ModuleId.kitchen_tablet,
  'staff_module': ModuleId.staff_tablet,
  'pos_module': ModuleId.staff_tablet,
  'promotions_module': ModuleId.promotions,
  'newsletter_module': ModuleId.newsletter,
  // Aliases for backward compatibility
  'roulette': ModuleId.roulette,
  'loyalty': ModuleId.loyalty,
  'rewards': ModuleId.loyalty,
  // NOTE: 'accountActivity' is intentionally NOT mapped (legacy, always visible)
};

/// Obtenir le ModuleId pour un ID builder
/// 
/// Returns null if the module ID is not mapped.
ModuleId? getModuleIdForBuilder(String builderModuleId) {
  return moduleIdMapping[builderModuleId];
}

/// Get the white-label ModuleId code for a Builder module ID
/// 
/// Returns null if the module ID is not mapped.
/// @deprecated Use getModuleIdForBuilder instead
@Deprecated('Use getModuleIdForBuilder instead')
String? getModuleIdCode(String builderModuleId) {
  return moduleIdMapping[builderModuleId]?.code;
}

/// Get the ModuleId enum for a Builder module ID
/// 
/// Returns null if the module ID is not mapped or invalid.
/// @deprecated Use getModuleIdForBuilder instead
@Deprecated('Use getModuleIdForBuilder instead')
ModuleId? getModuleId(String builderModuleId) {
  return moduleIdMapping[builderModuleId];
}

/// Vérifier si un module builder est activé dans le plan
/// 
/// Returns true if:
/// - plan is null (no restrictions)
/// - module has no requiredModuleId (always available)
/// - plan has the required module enabled
bool isBuilderModuleEnabled(String builderModuleId, RestaurantPlanUnified? plan) {
  if (plan == null) return true;
  final moduleId = moduleIdMapping[builderModuleId];
  if (moduleId == null) return true;
  return plan.hasModule(moduleId);
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
  final ModuleId? requiredModuleId;
  
  const ModuleConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isSystemModule = false,
    this.requiredModuleId,
  });
}

/// Available module configurations
/// 
/// Used by the editor to display module options.
const List<ModuleConfig> availableModules = [
  // Core modules
  ModuleConfig(
    id: 'menu_catalog',
    name: 'Catalogue Menu',
    description: 'Affiche la liste des produits avec catégories et filtres',
    icon: 'restaurant_menu',
    isSystemModule: false,
    requiredModuleId: ModuleId.ordering,
  ),
  ModuleConfig(
    id: 'cart_module',
    name: 'Panier',
    description: 'Panier et validation de commande',
    icon: 'shopping_cart',
    isSystemModule: true,
    requiredModuleId: ModuleId.ordering,
  ),
  ModuleConfig(
    id: 'profile_module',
    name: 'Profil Utilisateur',
    description: 'Widget du profil avec informations et paramètres',
    icon: 'person',
    isSystemModule: true,
    requiredModuleId: null, // Toujours disponible
  ),
  
  // Marketing modules
  ModuleConfig(
    id: 'roulette_module',
    name: 'Roue de la Chance',
    description: 'Widget de la roulette pour gagner des récompenses',
    icon: 'casino',
    isSystemModule: false,
    requiredModuleId: ModuleId.roulette,
  ),
  ModuleConfig(
    id: 'loyalty_module',
    name: 'Fidélité',
    description: 'Widget points de fidélité et niveau',
    icon: 'star',
    isSystemModule: false,
    requiredModuleId: ModuleId.loyalty,
  ),
  ModuleConfig(
    id: 'rewards_module',
    name: 'Récompenses',
    description: 'Liste des récompenses disponibles',
    icon: 'card_giftcard',
    isSystemModule: false,
    requiredModuleId: ModuleId.loyalty,
  ),
  ModuleConfig(
    id: 'promotions_module',
    name: 'Promotions',
    description: 'Affichage des promotions actives',
    icon: 'local_offer',
    isSystemModule: false,
    requiredModuleId: ModuleId.promotions,
  ),
  ModuleConfig(
    id: 'newsletter_module',
    name: 'Newsletter',
    description: 'Formulaire inscription newsletter',
    icon: 'email',
    isSystemModule: false,
    requiredModuleId: ModuleId.newsletter,
  ),
  
  // Operations modules
  ModuleConfig(
    id: 'delivery_module',
    name: 'Livraison',
    description: 'Sélection zone et adresse de livraison',
    icon: 'delivery_dining',
    isSystemModule: false,
    requiredModuleId: ModuleId.delivery,
  ),
  ModuleConfig(
    id: 'click_collect_module',
    name: 'Click & Collect',
    description: 'Sélection du créneau de retrait',
    icon: 'store',
    isSystemModule: false,
    requiredModuleId: ModuleId.clickAndCollect,
  ),
  ModuleConfig(
    id: 'kitchen_module',
    name: 'Cuisine',
    description: 'Affichage commandes cuisine (admin uniquement)',
    icon: 'kitchen',
    isSystemModule: true,
    requiredModuleId: ModuleId.kitchen_tablet,
  ),
  ModuleConfig(
    id: 'staff_module',
    name: 'Caisse Staff',
    description: 'Interface tablette staff (admin uniquement)',
    icon: 'point_of_sale',
    isSystemModule: true,
    requiredModuleId: ModuleId.staff_tablet,
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

/// Obtenir uniquement les modules actifs pour un restaurant
/// 
/// Filters availableModules based on the restaurant's plan:
/// - If plan is null, returns all modules
/// - If module has no requiredModuleId, it's always included
/// - Otherwise, checks if plan has the required module enabled
List<ModuleConfig> getAvailableModulesForPlan(RestaurantPlanUnified? plan) {
  if (plan == null) return availableModules;
  
  return availableModules.where((module) {
    if (module.requiredModuleId == null) return true;
    return plan.hasModule(module.requiredModuleId!);
  }).toList();
}

/// Vérifie si un module Builder spécifique est disponible pour un plan
/// 
/// Returns true if:
/// - plan is null (no restrictions - fallback safe)
/// - module has no requiredModuleId mapping (always available - legacy compatibility)
/// - plan has the required module enabled
bool isBuilderModuleAvailableForPlan(String builderModuleId, RestaurantPlanUnified? plan) {
  if (plan == null) return true; // Fallback safe
  final moduleId = moduleIdMapping[builderModuleId];
  if (moduleId == null) return true; // Module non mappé = toujours disponible (legacy)
  return plan.hasModule(moduleId);
}

/// Normalise un moduleType vers son ID canonique
/// 
/// Maps legacy module type aliases to their canonical IDs:
/// - 'roulette' -> 'roulette_module'
/// - 'loyalty' -> 'loyalty_module'
/// - 'rewards' -> 'rewards_module'
String normalizeModuleType(String moduleType) {
  const aliases = {
    'roulette': 'roulette_module',
    'loyalty': 'loyalty_module',
    'rewards': 'rewards_module',
  };
  return aliases[moduleType] ?? moduleType;
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

/// Valider le mapping des modules et retourner les résultats
/// 
/// Retourne une map contenant:
/// - unmappedBuilderModules: Liste des modules builder sans mapping WL
/// - unmappedWLModules: Liste des ModuleId WL non utilisés dans le builder
/// - legacyModules: Liste des modules legacy (toujours visibles)
/// - totalBuilderModules: Nombre total de modules builder
/// - totalWLModules: Nombre total de ModuleId WL
/// 
/// Utilisé pour diagnostiquer les problèmes de propagation entre SuperAdmin et Builder.
Map<String, dynamic> validateModuleMapping() {
  final allModuleIds = ModuleId.values;
  final builderModules = moduleIdMapping.keys.toList();
  final unmappedBuilderModules = <String>[];
  final mappingDetails = <String, String>{};

  // Vérifier chaque module builder
  for (final builderModule in builderModules) {
    final moduleId = getModuleIdForBuilder(builderModule);
    if (moduleId != null) {
      mappingDetails[builderModule] = moduleId.code;
    } else {
      unmappedBuilderModules.add(builderModule);
    }
  }

  // Modules WL non mappés dans le builder
  final unmappedWLModules = <String>[];
  final mappedModuleIds = moduleIdMapping.values.toSet();
  for (final moduleId in allModuleIds) {
    if (!mappedModuleIds.contains(moduleId)) {
      unmappedWLModules.add(moduleId.code);
    }
  }

  // Modules legacy (toujours visibles, pas de mapping)
  final legacyModules = ['accountActivity'];

  return {
    'unmappedBuilderModules': unmappedBuilderModules,
    'unmappedWLModules': unmappedWLModules,
    'legacyModules': legacyModules,
    'totalBuilderModules': builderModules.length,
    'totalWLModules': allModuleIds.length,
    'mappedCount': mappingDetails.length,
    'mapping': mappingDetails,
  };
}
