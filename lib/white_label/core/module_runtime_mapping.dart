/// lib/white_label/core/module_runtime_mapping.dart
/// Phase 4B: Runtime mapping layer for modules
///
/// This file provides runtime intelligence for modules by bridging
/// ModuleId enum with the metadata from module_matrix.dart.
///
/// This is a NON-INTRUSIVE layer that:
/// - Does NOT modify module_registry.dart
/// - Does NOT modify business services
/// - Does NOT modify existing navigation
/// - Does NOT modify Builder B3
///
/// Purpose:
/// - Map ModuleId to runtime routes
/// - Map ModuleId to pages
/// - Check if modules have builder blocks
/// - Check implementation status
library;

import 'module_id.dart';
import 'module_matrix.dart';

/// Runtime mapping layer for modules.
///
/// This class bridges the gap between ModuleId enum (used in code)
/// and ModuleDefinitionMeta (used for metadata/documentation).
///
/// It provides runtime intelligence about modules without modifying
/// the existing module system.
class ModuleRuntimeMapping {
  /// Private constructor to prevent instantiation.
  /// All methods are static.
  ModuleRuntimeMapping._();

  /// Get the runtime route for a module.
  ///
  /// Returns the default route from moduleMatrix, or null if:
  /// - The module doesn't have a page
  /// - The module is not found in the matrix
  ///
  /// Example:
  /// ```dart
  /// final route = ModuleRuntimeMapping.getRuntimeRoute(ModuleId.loyalty);
  /// print(route); // "/rewards"
  /// ```
  static String? getRuntimeRoute(ModuleId id) {
    final meta = _getModuleMeta(id);
    return meta?.defaultRoute;
  }

  /// Get the runtime page indicator for a module.
  ///
  /// Returns true if the module has a dedicated page.
  ///
  /// Example:
  /// ```dart
  /// final hasPage = ModuleRuntimeMapping.getRuntimePage(ModuleId.roulette);
  /// print(hasPage); // true
  /// ```
  static bool getRuntimePage(ModuleId id) {
    final meta = _getModuleMeta(id);
    return meta?.hasPage ?? false;
  }

  /// Check if a module has a Builder B3 block.
  ///
  /// Returns true if the module provides builder blocks that can be
  /// used in the pages builder (Builder B3).
  ///
  /// Example:
  /// ```dart
  /// final hasBlock = ModuleRuntimeMapping.hasBuilderBlock(ModuleId.loyalty);
  /// print(hasBlock); // true
  /// ```
  static bool hasBuilderBlock(ModuleId id) {
    final meta = _getModuleMeta(id);
    return meta?.hasBuilderBlock ?? false;
  }

  /// Check if a module is fully implemented.
  ///
  /// Returns true if the module status is 'implemented' in the matrix.
  /// Fully implemented modules have all features working.
  ///
  /// Example:
  /// ```dart
  /// final implemented = ModuleRuntimeMapping.isImplemented(ModuleId.roulette);
  /// print(implemented); // true
  /// ```
  static bool isImplemented(ModuleId id) {
    final meta = _getModuleMeta(id);
    return meta?.status == ModuleStatus.implemented;
  }

  /// Check if a module is partially implemented.
  ///
  /// Returns true if the module status is 'partial' in the matrix.
  /// Partially implemented modules have some features but not all.
  ///
  /// Example:
  /// ```dart
  /// final partial = ModuleRuntimeMapping.isPartiallyImplemented(ModuleId.newsletter);
  /// print(partial); // true
  /// ```
  static bool isPartiallyImplemented(ModuleId id) {
    final meta = _getModuleMeta(id);
    return meta?.status == ModuleStatus.partial;
  }

  /// Check if a module is planned but not implemented.
  ///
  /// Returns true if the module status is 'planned' in the matrix.
  /// Planned modules are in the roadmap but not yet started.
  ///
  /// Example:
  /// ```dart
  /// final planned = ModuleRuntimeMapping.isPlanned(ModuleId.wallet);
  /// print(planned); // true
  /// ```
  static bool isPlanned(ModuleId id) {
    final meta = _getModuleMeta(id);
    return meta?.status == ModuleStatus.planned;
  }

  /// Check if a module is ready for production use.
  ///
  /// A module is considered ready if it's fully implemented.
  /// This is a convenience method that's semantically clearer than isImplemented.
  ///
  /// Example:
  /// ```dart
  /// final ready = ModuleRuntimeMapping.isReady(ModuleId.loyalty);
  /// print(ready); // true
  /// ```
  static bool isReady(ModuleId id) {
    return isImplemented(id);
  }

  /// Check if a module exists in the module matrix.
  ///
  /// Returns true if the module has metadata defined.
  ///
  /// Example:
  /// ```dart
  /// final exists = ModuleRuntimeMapping.exists(ModuleId.roulette);
  /// print(exists); // true
  /// ```
  static bool exists(ModuleId id) {
    return _getModuleMeta(id) != null;
  }

  /// Get all routes for a list of active modules.
  ///
  /// Returns a map of moduleId.code -> route for all modules that have routes.
  /// Only includes modules from the provided list.
  ///
  /// Example:
  /// ```dart
  /// final routes = ModuleRuntimeMapping.getRoutesForModules([
  ///   ModuleId.loyalty,
  ///   ModuleId.roulette,
  /// ]);
  /// print(routes); // {"loyalty": "/rewards", "roulette": "/roulette"}
  /// ```
  static Map<String, String> getRoutesForModules(List<ModuleId> modules) {
    final routes = <String, String>{};
    for (final moduleId in modules) {
      final route = getRuntimeRoute(moduleId);
      if (route != null) {
        routes[moduleId.code] = route;
      }
    }
    return routes;
  }

  /// Get all modules that have pages.
  ///
  /// Returns a list of ModuleId for all modules with dedicated pages.
  ///
  /// Example:
  /// ```dart
  /// final withPages = ModuleRuntimeMapping.getModulesWithPages();
  /// print(withPages.length); // Number of modules with pages
  /// ```
  static List<ModuleId> getModulesWithPages() {
    final modules = <ModuleId>[];
    for (final moduleId in ModuleId.values) {
      if (getRuntimePage(moduleId)) {
        modules.add(moduleId);
      }
    }
    return modules;
  }

  /// Get all modules that have builder blocks.
  ///
  /// Returns a list of ModuleId for all modules with B3 blocks.
  ///
  /// Example:
  /// ```dart
  /// final withBlocks = ModuleRuntimeMapping.getModulesWithBuilderBlocks();
  /// print(withBlocks.length); // Number of modules with builder blocks
  /// ```
  static List<ModuleId> getModulesWithBuilderBlocks() {
    final modules = <ModuleId>[];
    for (final moduleId in ModuleId.values) {
      if (hasBuilderBlock(moduleId)) {
        modules.add(moduleId);
      }
    }
    return modules;
  }

  /// Get the implementation status summary.
  ///
  /// Returns a map with counts of modules by status.
  ///
  /// Example:
  /// ```dart
  /// final summary = ModuleRuntimeMapping.getStatusSummary();
  /// print(summary); // {implemented: 11, partial: 5, planned: 3}
  /// ```
  static Map<String, int> getStatusSummary() {
    var implemented = 0;
    var partial = 0;
    var planned = 0;

    for (final moduleId in ModuleId.values) {
      if (isImplemented(moduleId)) {
        implemented++;
      } else if (isPartiallyImplemented(moduleId)) {
        partial++;
      } else if (isPlanned(moduleId)) {
        planned++;
      }
    }

    return {
      'implemented': implemented,
      'partial': partial,
      'planned': planned,
    };
  }

  /// Get the module metadata from the matrix.
  ///
  /// This is an internal helper that maps ModuleId to ModuleDefinitionMeta.
  /// Returns null if the module is not found in the matrix.
  static ModuleDefinitionMeta? _getModuleMeta(ModuleId id) {
    // Map ModuleId enum to module_matrix string keys
    final code = id.code;
    return moduleMatrix[code];
  }

  /// Get the label for a module from the matrix.
  ///
  /// Returns the human-readable label, or the module code if not found.
  ///
  /// Example:
  /// ```dart
  /// final label = ModuleRuntimeMapping.getLabel(ModuleId.loyalty);
  /// print(label); // "Fidélité"
  /// ```
  static String getLabel(ModuleId id) {
    final meta = _getModuleMeta(id);
    return meta?.label ?? id.code;
  }

  /// Check if a module is premium.
  ///
  /// Returns true if the module requires a premium subscription.
  ///
  /// Example:
  /// ```dart
  /// final isPremium = ModuleRuntimeMapping.isPremium(ModuleId.roulette);
  /// print(isPremium); // true
  /// ```
  static bool isPremium(ModuleId id) {
    final meta = _getModuleMeta(id);
    return meta?.premium ?? false;
  }

  /// Get the category for a module from the matrix.
  ///
  /// Returns the module category or null if not found.
  ///
  /// Example:
  /// ```dart
  /// final category = ModuleRuntimeMapping.getCategory(ModuleId.loyalty);
  /// print(category); // ModuleCategory.engagement
  /// ```
  static ModuleCategory? getCategory(ModuleId id) {
    final meta = _getModuleMeta(id);
    return meta?.category;
  }
}
