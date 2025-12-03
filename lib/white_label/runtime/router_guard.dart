/// lib/white_label/runtime/router_guard.dart
/// Phase 4C: WhiteLabel-aware route guard for go_router
///
/// This guard validates routes against active modules and redirects
/// appropriately when modules are disabled.
///
/// NON-INTRUSIVE: Does not modify existing router configuration.
/// Just adds validation layer on top.
library;

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../core/module_id.dart';
import '../core/module_runtime_mapping.dart';
import '../restaurant/restaurant_plan_unified.dart';
import 'module_route_resolver.dart';

/// WhiteLabel route guard for go_router.
///
/// This function validates that routes belong to active modules.
/// If a module is disabled, it redirects to a safe fallback.
///
/// Rules:
/// 1. System routes (home, menu, cart, etc.) are always allowed
/// 2. Module routes are checked against active modules
/// 3. Disabled modules → redirect to /home
/// 4. Partially implemented modules → allow but log warning
/// 5. Unknown routes → let router handle (fallback)
///
/// Example usage in GoRouter:
/// ```dart
/// GoRouter(
///   redirect: (context, state) {
///     final plan = ref.read(restaurantPlanUnifiedProvider).value;
///     return whiteLabelRouteGuard(state, plan);
///   },
///   ...
/// )
/// ```
String? whiteLabelRouteGuard(
  GoRouterState state,
  RestaurantPlanUnified? plan,
) {
  // If no plan loaded, allow all routes (backward compatibility)
  if (plan == null) {
    return null;
  }

  final route = state.matchedLocation;

  // Skip validation for certain routes
  if (_shouldSkipValidation(route)) {
    return null;
  }

  // Resolve the route to determine if it belongs to a module
  final result = ModuleRouteResolver.resolveDetailed(route);

  // System route - always allow
  if (!result.requiresModule) {
    return null;
  }

  // Route belongs to a module
  if (result.moduleId != null) {
    final moduleId = result.moduleId!;

    // Check if module is active
    if (!plan.hasModule(moduleId)) {
      if (kDebugMode) {
        debugPrint('🚫 [RouteGuard] Blocking route $route - module ${moduleId.code} is disabled');
      }
      return '/home'; // Redirect to safe fallback
    }

    // Check if module is partially implemented - allow but warn
    if (ModuleRuntimeMapping.isPartiallyImplemented(moduleId)) {
      if (kDebugMode) {
        debugPrint('⚠️ [RouteGuard] Allowing route $route - module ${moduleId.code} is partially implemented');
      }
    }

    // Module is active and implemented - allow
    return null;
  }

  // Unknown/phantom route - let router handle it (404 or custom page)
  if (result.requiresModule && !result.isResolved) {
    if (kDebugMode) {
      debugPrint('⚠️ [RouteGuard] Unknown route: $route (no module owns it)');
    }
  }

  // Let router handle unknown routes
  return null;
}

/// Check if route validation should be skipped.
///
/// Certain routes bypass module validation:
/// - Auth routes (login, signup)
/// - Admin routes (for authorized users)
/// - SuperAdmin routes
/// - Builder routes
bool _shouldSkipValidation(String route) {
  // Auth routes
  if (route == '/login' || route == '/signup' || route == '/splash') {
    return true;
  }

  // Admin routes (handled by separate auth guards)
  if (route.startsWith('/admin')) {
    return true;
  }

  // SuperAdmin routes
  if (route.startsWith('/superadmin')) {
    return true;
  }

  // Builder preview/editor routes
  if (route.startsWith('/builder') || route.startsWith('/preview')) {
    return true;
  }

  // Staff tablet routes (handled by separate auth)
  if (route.startsWith('/staff-tablet')) {
    return true;
  }

  // Kitchen tablet routes
  if (route.startsWith('/kitchen')) {
    return true;
  }

  return false;
}

/// Enhanced route guard with custom redirect logic.
///
/// This version allows specifying a custom redirect path instead of
/// always redirecting to /home.
///
/// Example:
/// ```dart
/// return whiteLabelRouteGuardWithRedirect(
///   state,
///   plan,
///   redirectTo: '/menu',
/// );
/// ```
String? whiteLabelRouteGuardWithRedirect(
  GoRouterState state,
  RestaurantPlanUnified? plan, {
  String redirectTo = '/home',
}) {
  // If no plan loaded, allow all routes
  if (plan == null) {
    return null;
  }

  final route = state.matchedLocation;

  // Skip validation for certain routes
  if (_shouldSkipValidation(route)) {
    return null;
  }

  // Resolve the route
  final result = ModuleRouteResolver.resolveDetailed(route);

  // System route - always allow
  if (!result.requiresModule) {
    return null;
  }

  // Route belongs to a module
  if (result.moduleId != null) {
    final moduleId = result.moduleId!;

    // Check if module is active
    if (!plan.hasModule(moduleId)) {
      if (kDebugMode) {
        debugPrint('🚫 [RouteGuard] Blocking route $route - module ${moduleId.code} is disabled, redirecting to $redirectTo');
      }
      return redirectTo;
    }

    // Check if module is partially implemented - allow but warn
    if (ModuleRuntimeMapping.isPartiallyImplemented(moduleId)) {
      if (kDebugMode) {
        debugPrint('⚠️ [RouteGuard] Allowing route $route - module ${moduleId.code} is partially implemented');
      }
    }
  }

  // Allow the route
  return null;
}

/// Check if a route is accessible for a given plan.
///
/// This is a helper function that can be used outside of go_router
/// to check if a route should be accessible.
///
/// Returns true if the route should be accessible, false otherwise.
///
/// Example:
/// ```dart
/// if (isRouteAccessible('/rewards', plan)) {
///   // Show rewards button
/// }
/// ```
bool isRouteAccessible(String route, RestaurantPlanUnified? plan) {
  // If no plan, all routes are accessible (backward compatibility)
  if (plan == null) {
    return true;
  }

  // Skip validation for certain routes
  if (_shouldSkipValidation(route)) {
    return true;
  }

  // Resolve the route
  final result = ModuleRouteResolver.resolveDetailed(route);

  // System route - always accessible
  if (!result.requiresModule) {
    return true;
  }

  // Route belongs to a module
  if (result.moduleId != null) {
    return plan.hasModule(result.moduleId!);
  }

  // Unknown route - not accessible
  return false;
}

/// Get a list of all accessible routes for a plan.
///
/// Returns a list of routes that are accessible based on active modules.
///
/// Example:
/// ```dart
/// final accessibleRoutes = getAccessibleRoutes(plan);
/// print('User can access: $accessibleRoutes');
/// ```
List<String> getAccessibleRoutes(RestaurantPlanUnified plan) {
  final accessible = <String>[];

  // Add system routes (always accessible)
  accessible.addAll(ModuleRouteResolver.getSystemRoutes());

  // Add routes for active modules
  final moduleRoutes = ModuleRouteResolver.getAllModuleRoutes();
  for (final entry in moduleRoutes.entries) {
    final route = entry.key;
    final moduleId = entry.value;

    if (plan.hasModule(moduleId)) {
      accessible.add(route);
    }
  }

  return accessible;
}

/// Get a list of blocked routes (modules disabled).
///
/// Returns a list of routes that are blocked because their modules
/// are not active in the plan.
///
/// Example:
/// ```dart
/// final blocked = getBlockedRoutes(plan);
/// if (blocked.contains('/roulette')) {
///   // Hide roulette button
/// }
/// ```
List<String> getBlockedRoutes(RestaurantPlanUnified plan) {
  final blocked = <String>[];

  // Check all module routes
  final moduleRoutes = ModuleRouteResolver.getAllModuleRoutes();
  for (final entry in moduleRoutes.entries) {
    final route = entry.key;
    final moduleId = entry.value;

    if (!plan.hasModule(moduleId)) {
      blocked.add(route);
    }
  }

  return blocked;
}

/// Validate route guard configuration.
///
/// This is a helper function to validate that the route guard is
/// properly configured and working.
///
/// Returns a list of validation errors (empty if valid).
///
/// Example:
/// ```dart
/// final errors = validateRouteGuard(plan);
/// if (errors.isNotEmpty) {
///   print('Route guard issues: $errors');
/// }
/// ```
List<String> validateRouteGuard(RestaurantPlanUnified plan) {
  final errors = <String>[];

  // Check if plan has any active modules
  if (plan.activeModules.isEmpty) {
    errors.add('Plan has no active modules');
  }

  // Check for conflicting module states
  for (final moduleId in plan.enabledModuleIds) {
    // Check if module exists in matrix
    if (!ModuleRuntimeMapping.exists(moduleId)) {
      errors.add('Module ${moduleId.code} is active but not found in matrix');
    }

    // Warn about planned modules
    if (ModuleRuntimeMapping.isPlanned(moduleId)) {
      errors.add('Module ${moduleId.code} is active but marked as planned (not implemented)');
    }
  }

  return errors;
}
