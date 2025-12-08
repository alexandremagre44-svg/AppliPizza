// lib/builder/utils/builder_modules.dart
// Utility file for Builder modules mapping
//
// This file defines the available modules that can be attached to pages.
// The runtime will use this mapping to render the appropriate widgets.

import 'package:flutter/foundation.dart';
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
  'profile_module': ModuleId.ordering,
  // Marketing modules
  'roulette_module': ModuleId.roulette,
  'loyalty_module': ModuleId.loyalty,
  'rewards_module': ModuleId.loyalty,
  // NOTE: cart_module and delivery_module REMOVED - they are system pages now
  // 'cart_module': ModuleId.ordering,  // REMOVED
  // 'delivery_module': ModuleId.delivery,  // REMOVED
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
/// 
/// Special handling for legacy aliases:
/// - 'roulette' and 'roulette_module' both map to ModuleId.roulette
/// - 'loyalty' and 'loyalty_module' both map to ModuleId.loyalty
/// - 'rewards' and 'rewards_module' both map to ModuleId.loyalty
///
/// FIX: Added explicit mappings for all WL modules
ModuleId? getModuleIdForBuilder(String builderModuleId) {
  // Explicit mapping for all modules to ensure Builder recognition
  switch (builderModuleId) {
    case 'roulette':
    case 'roulette_module':
      return ModuleId.roulette;
    
    // cart_module and delivery_module REMOVED - they are system pages
    // case 'cart_module': return ModuleId.ordering;  // REMOVED
    // case 'delivery_module': return ModuleId.delivery;  // REMOVED
    
    case 'click_collect_module':
      return ModuleId.clickAndCollect;
    
    case 'loyalty_module':
      return ModuleId.loyalty;
    
    case 'rewards_module':
      return ModuleId.loyalty;
    
    case 'promotions_module':
      return ModuleId.promotions;
    
    case 'newsletter_module':
      return ModuleId.newsletter;
    
    case 'kitchen_module':
      return ModuleId.kitchen_tablet;
    
    case 'staff_module':
      return ModuleId.staff_tablet;
  }
  
  // Fallback to existing mapping
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
/// This map contains ONLY core/legacy modules.
/// White-Label modules are now registered exclusively via ModuleRuntimeRegistry.
/// 
/// Core modules in this map:
/// - menu_catalog: Product catalog widget
/// - profile_module: User profile widget
/// - roulette_module: Roulette game widget
/// 
/// Note: All WL modules (cart, delivery, loyalty, rewards, etc.) have been removed
/// from this map and are now handled via ModuleRuntimeRegistry with proper
/// admin/client separation.
/// 
/// IMPORTANT: cart_module and delivery_module are NOT in the Builder.
/// They are system pages managed by the System Page Manager.
final Map<String, ModuleWidgetBuilder> builderModules = {
  'menu_catalog': (context) => const MenuCatalogRuntimeWidget(),
  'profile_module': (context) => const ProfileModuleWidget(),
  'roulette_module': (context) => const RouletteModuleWidget(),
  // Legacy modules only - NO WL modules here
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
/// 
/// NOTE: cart_module and delivery_module have been REMOVED.
/// They are now system pages managed outside the Builder.
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
  // NOTE: delivery_module and click_collect_module have been REMOVED from Builder.
  // They are now managed as system pages.
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

/// Mapping WL module ID → Builder module ID(s)
/// 
/// This is the source of truth for converting White Label module IDs
/// to Builder module IDs. Used by getBuilderModulesForPlan() to determine
/// which Builder modules should be visible based on the plan configuration.
/// 
/// WL modules not in this map will NOT appear in the Builder.
/// Note: pages_builder intentionally omitted (not displayed in Builder).
/// 
/// Special cases:
/// - loyalty WL module enables both loyalty_module AND rewards_module in Builder
/// - roulette WL module enables roulette_module in Builder
const Map<String, List<String>> wlToBuilderModules = {
  'ordering': ['cart_module'],
  'delivery': ['delivery_module'],
  'click_and_collect': ['click_collect_module'],
  'loyalty': ['loyalty_module', 'rewards_module'], // Loyalty enables both
  'roulette': ['roulette_module'],
  'promotions': ['promotions_module'],
  'newsletter': ['newsletter_module'],
  'kitchen_tablet': ['kitchen_module'],
  'staff_tablet': ['staff_module'],
  'theme': ['theme_module'],
  'reporting': ['reporting_module'],
  'exports': ['exports_module'],
  'campaigns': ['campaigns_module'],
};

/// Retourne les modules Builder visibles selon le plan WL
/// 
/// Returns list of builder module IDs that are available based on the plan:
/// - If plan is null, returns EMPTY LIST (strict filtering, no fallback)
/// - Converts enabled WL modules to Builder modules using wlToBuilderModules mapping
/// - Only returns modules that are actually defined in the Builder
/// - Handles 1-to-many mappings (e.g., loyalty → [loyalty_module, rewards_module])
/// 
/// This is the NEW implementation that uses the proper WL → Builder mapping
/// instead of checking moduleIdMapping in reverse.
List<String> getBuilderModulesForPlan(RestaurantPlanUnified? plan) {
  // STRICT FILTERING: If plan is null, return empty list
  if (plan == null) {
    if (kDebugMode) {
      debugPrint('[BuilderModules] Plan is null, returning empty module list');
    }
    return const <String>[];
  }
  
  final List<String> result = [];
  
  // Convert each enabled WL module to its Builder module ID(s)
  for (final moduleConfig in plan.modules.where((m) => m.enabled)) {
    final builderIds = wlToBuilderModules[moduleConfig.id];
    if (builderIds != null) {
      result.addAll(builderIds);
    }
  }
  
  if (kDebugMode) {
    debugPrint('[BuilderModules] Plan has ${plan.modules.length} modules, ${result.length} mapped to Builder');
    debugPrint('[BuilderModules] Builder modules: ${result.join(", ")}');
  }
  
  return result;
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

// CartModuleWidget REMOVED - Cart is now a system page, not a builder module.
// The cart functionality is handled by CartPageRuntime in the white_label/modules/payment/ folder.

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
