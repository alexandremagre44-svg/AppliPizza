/// lib/white_label/runtime/module_route_resolver.dart
/// Phase 4B: Route to module resolution
///
/// This file provides route resolution by mapping routes to ModuleId.
///
/// This is a NON-INTRUSIVE layer that:
/// - Does NOT modify existing navigation
/// - Does NOT modify go_router configuration
/// - Does NOT modify module_registry.dart
///
/// Purpose:
/// - Identify which module owns a route
/// - Prevent phantom routes (routes without modules)
/// - Enable runtime validation
library;

import 'package:go_router/go_router.dart';
import '../core/module_id.dart';
import '../core/module_matrix.dart';
import '../core/module_runtime_mapping.dart';
import '../restaurant/restaurant_plan_unified.dart';
import 'module_navigation_registry.dart';

/// Result of route resolution.
///
/// Contains information about a resolved route including the module
/// that owns it and whether the resolution was successful.
class RouteResolutionResult {
  /// The module that owns this route, or null if not found.
  final ModuleId? moduleId;

  /// The route that was resolved.
  final String route;

  /// Whether the route was successfully resolved to a module.
  final bool isResolved;

  /// Whether this route requires a module (not a system route).
  final bool requiresModule;

  const RouteResolutionResult({
    required this.moduleId,
    required this.route,
    required this.isResolved,
    required this.requiresModule,
  });

  /// Create a successful resolution result.
  factory RouteResolutionResult.success({
    required ModuleId moduleId,
    required String route,
  }) {
    return RouteResolutionResult(
      moduleId: moduleId,
      route: route,
      isResolved: true,
      requiresModule: true,
    );
  }

  /// Create a system route result (doesn't require a module).
  factory RouteResolutionResult.systemRoute({
    required String route,
  }) {
    return RouteResolutionResult(
      moduleId: null,
      route: route,
      isResolved: true,
      requiresModule: false,
    );
  }

  /// Create a failed resolution result.
  factory RouteResolutionResult.notFound({
    required String route,
  }) {
    return RouteResolutionResult(
      moduleId: null,
      route: route,
      isResolved: false,
      requiresModule: true,
    );
  }

  @override
  String toString() {
    if (!requiresModule) {
      return 'RouteResolutionResult(route: $route, systemRoute: true)';
    }
    if (isResolved && moduleId != null) {
      return 'RouteResolutionResult(route: $route, module: ${moduleId!.code})';
    }
    return 'RouteResolutionResult(route: $route, notFound: true)';
  }
}

/// Resolver for mapping routes to modules.
///
/// This class uses moduleMatrix and ModuleRuntimeMapping to determine
/// which module owns a given route.
class ModuleRouteResolver {
  /// Private constructor to prevent instantiation.
  /// All methods are static.
  ModuleRouteResolver._();

  /// Resolve all routes for a given restaurant plan.
  ///
  /// This function generates a list of GoRoute objects based on the modules
  /// enabled in the restaurant plan. Only routes for enabled modules are included.
  ///
  /// The function:
  /// - Iterates through all modules in the plan
  /// - Checks if each module is enabled
  /// - Retrieves routes from ModuleNavigationRegistry
  /// - Returns only routes for enabled modules
  ///
  /// Example:
  /// ```dart
  /// final plan = await ref.read(restaurantPlanUnifiedProvider.future);
  /// final routes = ModuleRouteResolver.resolveRoutesFor(plan);
  /// ```
  ///
  /// Returns an empty list if plan is null or has no enabled modules.
  static List<GoRoute> resolveRoutesFor(RestaurantPlanUnified? plan) {
    // If no plan, return empty list
    if (plan == null) {
      return [];
    }

    final routes = <GoRoute>[];

    // Iterate through all registered modules
    for (final moduleId in ModuleNavigationRegistry.getAllRegisteredModules()) {
      // Check if module is enabled in the plan
      if (plan.hasModule(moduleId)) {
        // Get routes for this module
        final moduleRoutes = ModuleNavigationRegistry.getGoRoutesFor(moduleId);
        routes.addAll(moduleRoutes);
      }
    }

    return routes;
  }

  /// Resolve routes for enabled modules only.
  ///
  /// Similar to resolveRoutesFor but also filters by implementation status.
  /// Only includes routes for modules that are:
  /// - Enabled in the plan
  /// - Fully implemented or partially implemented
  ///
  /// Skips planned modules even if enabled in the plan.
  ///
  /// Example:
  /// ```dart
  /// final routes = ModuleRouteResolver.resolveImplementedRoutesFor(plan);
  /// ```
  static List<GoRoute> resolveImplementedRoutesFor(RestaurantPlanUnified? plan) {
    if (plan == null) {
      return [];
    }

    final routes = <GoRoute>[];

    for (final moduleId in ModuleNavigationRegistry.getAllRegisteredModules()) {
      // Check if module is enabled
      if (plan.hasModule(moduleId)) {
        // Check if module is implemented (not just planned)
        if (ModuleRuntimeMapping.isImplemented(moduleId) ||
            ModuleRuntimeMapping.isPartiallyImplemented(moduleId)) {
          final moduleRoutes = ModuleNavigationRegistry.getGoRoutesFor(moduleId);
          routes.addAll(moduleRoutes);
        }
      }
    }

    return routes;
  }

  /// Get all enabled module IDs from a plan.
  ///
  /// Returns a list of ModuleId for all modules that are:
  /// - Enabled in the plan
  /// - Have registered routes
  ///
  /// Example:
  /// ```dart
  /// final enabledModules = ModuleRouteResolver.getEnabledModulesWithRoutes(plan);
  /// ```
  static List<ModuleId> getEnabledModulesWithRoutes(RestaurantPlanUnified? plan) {
    if (plan == null) {
      return [];
    }

    final modules = <ModuleId>[];

    for (final moduleId in ModuleNavigationRegistry.getAllRegisteredModules()) {
      if (plan.hasModule(moduleId)) {
        modules.add(moduleId);
      }
    }

    return modules;
  }

  /// Resolve a route to its owning module.
  ///
  /// Returns:
  /// - A ModuleId if the route belongs to a module
  /// - null if the route is a system route (doesn't require a module)
  /// - null if the route is not found
  ///
  /// Use [resolveDetailed] for more information about the resolution.
  ///
  /// Example:
  /// ```dart
  /// final module = ModuleRouteResolver.resolve('/rewards');
  /// print(module); // ModuleId.loyalty
  ///
  /// final system = ModuleRouteResolver.resolve('/home');
  /// print(system); // null (system route)
  /// ```
  static ModuleId? resolve(String route) {
    final result = resolveDetailed(route);
    return result.moduleId;
  }

  /// Resolve a route with detailed information.
  ///
  /// Returns a [RouteResolutionResult] with full details about the resolution:
  /// - Whether the route was resolved
  /// - Which module owns it (if any)
  /// - Whether it's a system route
  ///
  /// Example:
  /// ```dart
  /// final result = ModuleRouteResolver.resolveDetailed('/roulette');
  /// if (result.isResolved && result.moduleId != null) {
  ///   print('Route belongs to: ${result.moduleId!.label}');
  /// }
  /// ```
  static RouteResolutionResult resolveDetailed(String route) {
    // Normalize the route
    final normalizedRoute = _normalizeRoute(route);

    // Check if it's a system route first
    if (_isSystemRoute(normalizedRoute)) {
      return RouteResolutionResult.systemRoute(route: normalizedRoute);
    }

    // Try to find the module by exact match first
    final exactMatch = _findModuleByExactRoute(normalizedRoute);
    if (exactMatch != null) {
      return RouteResolutionResult.success(
        moduleId: exactMatch,
        route: normalizedRoute,
      );
    }

    // Try to find by prefix match
    final prefixMatch = _findModuleByRoutePrefix(normalizedRoute);
    if (prefixMatch != null) {
      return RouteResolutionResult.success(
        moduleId: prefixMatch,
        route: normalizedRoute,
      );
    }

    // Route not found
    return RouteResolutionResult.notFound(route: normalizedRoute);
  }

  /// Check if a route belongs to a specific module.
  ///
  /// Returns true if the route is owned by the specified module.
  ///
  /// Example:
  /// ```dart
  /// final belongs = ModuleRouteResolver.belongsToModule('/rewards', ModuleId.loyalty);
  /// print(belongs); // true
  /// ```
  static bool belongsToModule(String route, ModuleId moduleId) {
    final resolved = resolve(route);
    return resolved == moduleId;
  }

  /// Check if a route is valid (exists in the system).
  ///
  /// Returns true if the route is either a system route or belongs to a module.
  ///
  /// Example:
  /// ```dart
  /// final valid = ModuleRouteResolver.isValidRoute('/rewards');
  /// print(valid); // true
  /// ```
  static bool isValidRoute(String route) {
    final result = resolveDetailed(route);
    return result.isResolved;
  }

  /// Check if a route is a phantom route.
  ///
  /// A phantom route is one that requires a module but no module owns it.
  ///
  /// Example:
  /// ```dart
  /// final phantom = ModuleRouteResolver.isPhantomRoute('/unknown-page');
  /// print(phantom); // true if no module owns this route
  /// ```
  static bool isPhantomRoute(String route) {
    final result = resolveDetailed(route);
    return !result.isResolved && result.requiresModule;
  }

  /// Get all routes for active modules.
  ///
  /// Returns a map of route -> ModuleId for all modules that have routes.
  ///
  /// Example:
  /// ```dart
  /// final routes = ModuleRouteResolver.getAllModuleRoutes();
  /// print(routes['/rewards']); // ModuleId.loyalty
  /// ```
  static Map<String, ModuleId> getAllModuleRoutes() {
    final routes = <String, ModuleId>{};

    for (final moduleId in ModuleId.values) {
      final route = ModuleRuntimeMapping.getRuntimeRoute(moduleId);
      if (route != null) {
        routes[route] = moduleId;
      }
    }

    return routes;
  }

  /// Normalize a route string.
  ///
  /// Removes query parameters, ensures leading slash, and trims.
  static String _normalizeRoute(String route) {
    // Remove query parameters
    var normalized = route.split('?').first;

    // Remove trailing slashes (except for root)
    if (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    // Ensure leading slash
    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }

    return normalized.trim();
  }

  /// Core system routes that don't require a module.
  /// These are application-level routes that always exist.
  static const List<String> _systemRoutes = [
    '/',
    '/home',
    '/menu',
    '/cart',
    '/profile',
    '/about',
    '/contact',
    '/login',
    '/signup',
    '/forgot-password',
    '/settings',
    '/orders',
    '/order-history',
    '/checkout',
  ];

  /// Check if a route is a system route (doesn't require a module).
  ///
  /// System routes are core application routes that don't depend on modules.
  static bool _isSystemRoute(String route) {
    return _systemRoutes.contains(route);
  }

  /// Find a module by exact route match.
  ///
  /// Returns the ModuleId if found, null otherwise.
  static ModuleId? _findModuleByExactRoute(String route) {
    // Build a reverse map: route -> moduleId
    for (final moduleId in ModuleId.values) {
      final moduleRoute = ModuleRuntimeMapping.getRuntimeRoute(moduleId);
      if (moduleRoute != null && _normalizeRoute(moduleRoute) == route) {
        return moduleId;
      }
    }
    return null;
  }

  /// Find a module by route prefix match.
  ///
  /// This handles cases like `/roulette/play` matching the roulette module.
  /// Returns the ModuleId if found, null otherwise.
  static ModuleId? _findModuleByRoutePrefix(String route) {
    ModuleId? bestMatch;
    int longestMatch = 0;

    for (final moduleId in ModuleId.values) {
      final moduleRoute = ModuleRuntimeMapping.getRuntimeRoute(moduleId);
      if (moduleRoute != null) {
        final normalizedModuleRoute = _normalizeRoute(moduleRoute);
        
        // Check if route starts with module route
        if (route.startsWith(normalizedModuleRoute)) {
          // Prefer longer matches (more specific)
          if (normalizedModuleRoute.length > longestMatch) {
            longestMatch = normalizedModuleRoute.length;
            bestMatch = moduleId;
          }
        }
      }
    }

    return bestMatch;
  }

  /// Get a list of all system routes.
  ///
  /// Returns all routes that don't require a module.
  ///
  /// Example:
  /// ```dart
  /// final systemRoutes = ModuleRouteResolver.getSystemRoutes();
  /// print(systemRoutes); // ["/", "/home", "/menu", ...]
  /// ```
  static List<String> getSystemRoutes() {
    return List.unmodifiable(_systemRoutes);
  }

  /// Validate a list of routes against active modules.
  ///
  /// Returns a list of phantom routes (routes that require modules but no module owns them).
  ///
  /// Example:
  /// ```dart
  /// final phantoms = ModuleRouteResolver.validateRoutes([
  ///   '/home',
  ///   '/rewards',
  ///   '/unknown',
  /// ]);
  /// print(phantoms); // ["/unknown"]
  /// ```
  static List<String> validateRoutes(List<String> routes) {
    final phantoms = <String>[];
    for (final route in routes) {
      if (isPhantomRoute(route)) {
        phantoms.add(route);
      }
    }
    return phantoms;
  }
}
