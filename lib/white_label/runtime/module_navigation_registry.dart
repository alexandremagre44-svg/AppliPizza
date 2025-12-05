/// lib/white_label/runtime/module_navigation_registry.dart
///
/// Registry for managing module routes dynamically.
///
/// This registry centralizes all module routes and provides helpers
/// to register, retrieve, and manage routes for each module.
///
/// Purpose:
/// - Register routes for each module
/// - Retrieve routes by module ID
/// - List all registered modules
/// - Scan and auto-import routes from module directories
library;

import 'package:go_router/go_router.dart';
import '../core/module_id.dart';
import '../core/module_category.dart';

/// Route definition with metadata for module navigation.
class ModuleRouteDefinition {
  /// The GoRoute configuration.
  final GoRoute route;

  /// The module that owns this route.
  final ModuleId moduleId;

  /// Required access level for this route.
  final ModuleAccessLevel accessLevel;

  /// Whether this is the main route for the module.
  final bool isMainRoute;

  const ModuleRouteDefinition({
    required this.route,
    required this.moduleId,
    required this.accessLevel,
    this.isMainRoute = false,
  });
}

/// Registry for module routes.
///
/// This class manages all routes for white-label modules and provides
/// helpers to register, retrieve, and manage them.
class ModuleNavigationRegistry {
  /// Private constructor to prevent instantiation.
  ModuleNavigationRegistry._();

  /// Internal storage for module routes.
  static final Map<ModuleId, List<ModuleRouteDefinition>> _registry = {};

  /// Register routes for a module.
  ///
  /// This method registers a list of routes for a given module.
  /// Routes can be registered multiple times to add more routes.
  ///
  /// Example:
  /// ```dart
  /// ModuleNavigationRegistry.registerModuleRoutes(
  ///   ModuleId.loyalty,
  ///   [
  ///     ModuleRouteDefinition(
  ///       route: GoRoute(path: '/rewards', builder: ...),
  ///       moduleId: ModuleId.loyalty,
  ///       accessLevel: ModuleAccessLevel.client,
  ///       isMainRoute: true,
  ///     ),
  ///   ],
  /// );
  /// ```
  static void registerModuleRoutes(
    ModuleId moduleId,
    List<ModuleRouteDefinition> routes,
  ) {
    if (!_registry.containsKey(moduleId)) {
      _registry[moduleId] = [];
    }
    _registry[moduleId]!.addAll(routes);
  }

  /// Get all routes for a specific module.
  ///
  /// Returns an empty list if the module has no registered routes.
  ///
  /// Example:
  /// ```dart
  /// final routes = ModuleNavigationRegistry.getRoutesFor(ModuleId.loyalty);
  /// print('Loyalty has ${routes.length} routes');
  /// ```
  static List<ModuleRouteDefinition> getRoutesFor(ModuleId moduleId) {
    return _registry[moduleId] ?? [];
  }

  /// Get all GoRoute objects for a specific module.
  ///
  /// This is a convenience method that extracts just the GoRoute objects.
  ///
  /// Example:
  /// ```dart
  /// final goRoutes = ModuleNavigationRegistry.getGoRoutesFor(ModuleId.loyalty);
  /// ```
  static List<GoRoute> getGoRoutesFor(ModuleId moduleId) {
    return getRoutesFor(moduleId).map((def) => def.route).toList();
  }

  /// Get all registered modules.
  ///
  /// Returns a list of ModuleId for all modules that have registered routes.
  ///
  /// Example:
  /// ```dart
  /// final modules = ModuleNavigationRegistry.getAllRegisteredModules();
  /// print('${modules.length} modules registered');
  /// ```
  static List<ModuleId> getAllRegisteredModules() {
    return _registry.keys.toList();
  }

  /// Check if a module has registered routes.
  ///
  /// Returns true if the module has at least one registered route.
  ///
  /// Example:
  /// ```dart
  /// if (ModuleNavigationRegistry.hasRoutes(ModuleId.loyalty)) {
  ///   print('Loyalty module has routes');
  /// }
  /// ```
  static bool hasRoutes(ModuleId moduleId) {
    return _registry.containsKey(moduleId) && _registry[moduleId]!.isNotEmpty;
  }

  /// Get the main route for a module.
  ///
  /// Returns the route marked as `isMainRoute: true`, or the first route
  /// if no main route is specified.
  ///
  /// Returns null if the module has no routes.
  ///
  /// Example:
  /// ```dart
  /// final mainRoute = ModuleNavigationRegistry.getMainRoute(ModuleId.loyalty);
  /// if (mainRoute != null) {
  ///   context.go(mainRoute.route.path);
  /// }
  /// ```
  static ModuleRouteDefinition? getMainRoute(ModuleId moduleId) {
    final routes = getRoutesFor(moduleId);
    if (routes.isEmpty) return null;

    // Try to find a route marked as main
    try {
      return routes.firstWhere((route) => route.isMainRoute);
    } catch (_) {
      // If no main route, return the first one
      return routes.first;
    }
  }

  /// Get all routes filtered by access level.
  ///
  /// Returns all routes that require the specified access level.
  ///
  /// Example:
  /// ```dart
  /// final adminRoutes = ModuleNavigationRegistry.getRoutesByAccessLevel(
  ///   ModuleAccessLevel.admin,
  /// );
  /// ```
  static List<ModuleRouteDefinition> getRoutesByAccessLevel(
    ModuleAccessLevel accessLevel,
  ) {
    final filtered = <ModuleRouteDefinition>[];
    for (final routes in _registry.values) {
      filtered.addAll(
        routes.where((route) => route.accessLevel == accessLevel),
      );
    }
    return filtered;
  }

  /// Get all routes for modules with a specific access level.
  ///
  /// Returns a map of ModuleId -> routes for modules requiring the access level.
  ///
  /// Example:
  /// ```dart
  /// final adminModules = ModuleNavigationRegistry.getModulesByAccessLevel(
  ///   ModuleAccessLevel.admin,
  /// );
  /// ```
  static Map<ModuleId, List<ModuleRouteDefinition>> getModulesByAccessLevel(
    ModuleAccessLevel accessLevel,
  ) {
    final filtered = <ModuleId, List<ModuleRouteDefinition>>{};
    for (final entry in _registry.entries) {
      final matchingRoutes = entry.value
          .where((route) => route.accessLevel == accessLevel)
          .toList();
      if (matchingRoutes.isNotEmpty) {
        filtered[entry.key] = matchingRoutes;
      }
    }
    return filtered;
  }

  /// Clear all registered routes.
  ///
  /// This is useful for testing or reinitializing the registry.
  ///
  /// Example:
  /// ```dart
  /// ModuleNavigationRegistry.clear();
  /// ```
  static void clear() {
    _registry.clear();
  }

  /// Get a summary of registered routes.
  ///
  /// Returns a map with statistics about registered routes.
  ///
  /// Example:
  /// ```dart
  /// final summary = ModuleNavigationRegistry.getSummary();
  /// print('Total modules: ${summary['totalModules']}');
  /// print('Total routes: ${summary['totalRoutes']}');
  /// ```
  static Map<String, dynamic> getSummary() {
    var totalRoutes = 0;
    var clientRoutes = 0;
    var adminRoutes = 0;
    var staffRoutes = 0;
    var kitchenRoutes = 0;
    var systemRoutes = 0;

    for (final routes in _registry.values) {
      totalRoutes += routes.length;
      for (final route in routes) {
        switch (route.accessLevel) {
          case ModuleAccessLevel.client:
            clientRoutes++;
            break;
          case ModuleAccessLevel.admin:
            adminRoutes++;
            break;
          case ModuleAccessLevel.staff:
            staffRoutes++;
            break;
          case ModuleAccessLevel.kitchen:
            kitchenRoutes++;
            break;
          case ModuleAccessLevel.system:
            systemRoutes++;
            break;
        }
      }
    }

    return {
      'totalModules': _registry.length,
      'totalRoutes': totalRoutes,
      'clientRoutes': clientRoutes,
      'adminRoutes': adminRoutes,
      'staffRoutes': staffRoutes,
      'kitchenRoutes': kitchenRoutes,
      'systemRoutes': systemRoutes,
    };
  }

  /// Unregister all routes for a specific module.
  ///
  /// This removes all routes associated with the module.
  ///
  /// Example:
  /// ```dart
  /// ModuleNavigationRegistry.unregisterModule(ModuleId.loyalty);
  /// ```
  static void unregisterModule(ModuleId moduleId) {
    _registry.remove(moduleId);
  }
}
