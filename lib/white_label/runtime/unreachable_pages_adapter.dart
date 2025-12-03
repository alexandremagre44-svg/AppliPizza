/// lib/white_label/runtime/unreachable_pages_adapter.dart
/// Phase 4C: Adapter for hiding unreachable pages
///
/// This adapter determines which pages should be hidden based on
/// module status without deleting any files.
///
/// NON-INTRUSIVE: Only provides query methods, doesn't modify pages.
library;

import '../core/module_id.dart';
import '../core/module_runtime_mapping.dart';
import '../restaurant/restaurant_plan_unified.dart';
import 'module_route_resolver.dart';

/// Check if a page is reachable for a given plan.
///
/// A page is reachable if:
/// - It's a system page (always reachable), OR
/// - Its module is active in the plan
///
/// Example:
/// ```dart
/// if (isPageReachable('/rewards', plan)) {
///   // Show rewards page
/// }
/// ```
bool isPageReachable(String route, RestaurantPlanUnified? plan) {
  // If no plan, all pages are reachable (backward compatibility)
  if (plan == null) {
    return true;
  }

  // Resolve the route to determine module ownership
  final result = ModuleRouteResolver.resolveDetailed(route);

  // System routes are always reachable
  if (!result.requiresModule) {
    return true;
  }

  // Route belongs to a module - check if module is active
  if (result.moduleId != null) {
    return plan.hasModule(result.moduleId!);
  }

  // Unknown route - consider unreachable
  return false;
}

/// Check if a page should be hidden.
///
/// A page should be hidden if it's not reachable.
/// This is the inverse of `isPageReachable`.
///
/// Example:
/// ```dart
/// if (shouldHidePage('/roulette', plan)) {
///   // Don't show roulette in menu
/// }
/// ```
bool shouldHidePage(String route, RestaurantPlanUnified? plan) {
  return !isPageReachable(route, plan);
}

/// Check if a page is partially available.
///
/// A page is partially available if its module is partially implemented.
/// These pages might have limited functionality.
///
/// Example:
/// ```dart
/// if (isPagePartiallyAvailable('/newsletter', plan)) {
///   // Show with "beta" or "coming soon" badge
/// }
/// ```
bool isPagePartiallyAvailable(String route, RestaurantPlanUnified? plan) {
  // If no plan, assume full availability
  if (plan == null) {
    return false;
  }

  // Resolve the route
  final result = ModuleRouteResolver.resolveDetailed(route);

  // Only module routes can be partial
  if (result.moduleId == null) {
    return false;
  }

  // Check if module is partially implemented
  return ModuleRuntimeMapping.isPartiallyImplemented(result.moduleId!) &&
      plan.hasModule(result.moduleId!);
}

/// Get the reason why a page is unreachable.
///
/// Returns a human-readable message explaining why the page is not available.
///
/// Example:
/// ```dart
/// final reason = getUnreachableReason('/roulette', plan);
/// print(reason); // "Module 'roulette' is not active"
/// ```
String? getUnreachableReason(String route, RestaurantPlanUnified? plan) {
  // If page is reachable, no reason
  if (isPageReachable(route, plan)) {
    return null;
  }

  // If no plan, shouldn't be unreachable
  if (plan == null) {
    return null;
  }

  // Resolve the route
  final result = ModuleRouteResolver.resolveDetailed(route);

  // Unknown route
  if (!result.isResolved) {
    return 'Page not found';
  }

  // Module route that's not active
  if (result.moduleId != null) {
    final moduleId = result.moduleId!;
    final label = ModuleRuntimeMapping.getLabel(moduleId);

    if (!plan.hasModule(moduleId)) {
      return 'Module "$label" is not active';
    }

    if (ModuleRuntimeMapping.isPlanned(moduleId)) {
      return 'Module "$label" is not yet implemented';
    }
  }

  return 'Page is not available';
}

/// Get a list of all reachable page routes.
///
/// Returns routes for all pages that should be accessible.
///
/// Example:
/// ```dart
/// final reachable = getReachablePages(plan);
/// print('User can access: ${reachable.length} pages');
/// ```
List<String> getReachablePages(RestaurantPlanUnified plan) {
  final reachable = <String>[];

  // Add system routes (always reachable)
  reachable.addAll(ModuleRouteResolver.getSystemRoutes());

  // Add routes for active modules with pages
  for (final moduleId in plan.enabledModuleIds) {
    if (ModuleRuntimeMapping.getRuntimePage(moduleId)) {
      final route = ModuleRuntimeMapping.getRuntimeRoute(moduleId);
      if (route != null) {
        reachable.add(route);
      }
    }
  }

  return reachable;
}

/// Get a list of all hidden page routes.
///
/// Returns routes for pages that should be hidden because their
/// modules are not active.
///
/// Example:
/// ```dart
/// final hidden = getHiddenPages(plan);
/// for (final route in hidden) {
///   print('Hide page: $route');
/// }
/// ```
List<String> getHiddenPages(RestaurantPlanUnified plan) {
  final hidden = <String>[];

  // Check all modules
  for (final moduleId in ModuleId.values) {
    // Skip modules that are active
    if (plan.hasModule(moduleId)) {
      continue;
    }

    // Skip modules without pages
    if (!ModuleRuntimeMapping.getRuntimePage(moduleId)) {
      continue;
    }

    // Add the route to hidden list
    final route = ModuleRuntimeMapping.getRuntimeRoute(moduleId);
    if (route != null) {
      hidden.add(route);
    }
  }

  return hidden;
}

/// Get a list of pages with partial availability.
///
/// Returns routes for pages whose modules are partially implemented.
///
/// Example:
/// ```dart
/// final partial = getPartiallyAvailablePages(plan);
/// for (final route in partial) {
///   print('Show "Beta" badge for: $route');
/// }
/// ```
List<String> getPartiallyAvailablePages(RestaurantPlanUnified plan) {
  final partial = <String>[];

  // Check active modules
  for (final moduleId in plan.enabledModuleIds) {
    // Check if partially implemented
    if (ModuleRuntimeMapping.isPartiallyImplemented(moduleId)) {
      // Check if has page
      if (ModuleRuntimeMapping.getRuntimePage(moduleId)) {
        final route = ModuleRuntimeMapping.getRuntimeRoute(moduleId);
        if (route != null) {
          partial.add(route);
        }
      }
    }
  }

  return partial;
}

/// Filter a list of routes based on reachability.
///
/// Returns only the routes that are reachable for the given plan.
///
/// Example:
/// ```dart
/// final allRoutes = ['/home', '/menu', '/rewards', '/roulette'];
/// final accessible = filterReachableRoutes(allRoutes, plan);
/// ```
List<String> filterReachableRoutes(
  List<String> routes,
  RestaurantPlanUnified? plan,
) {
  if (plan == null) {
    return routes; // All routes accessible without plan
  }

  return routes.where((route) => isPageReachable(route, plan)).toList();
}

/// Filter a list of routes to get only unreachable ones.
///
/// Returns only the routes that should be hidden.
///
/// Example:
/// ```dart
/// final allRoutes = ['/home', '/menu', '/rewards', '/roulette'];
/// final blocked = filterUnreachableRoutes(allRoutes, plan);
/// ```
List<String> filterUnreachableRoutes(
  List<String> routes,
  RestaurantPlanUnified? plan,
) {
  if (plan == null) {
    return []; // No routes blocked without plan
  }

  return routes.where((route) => shouldHidePage(route, plan)).toList();
}

/// Get page visibility summary.
///
/// Returns statistics about page visibility for the given plan.
///
/// Example:
/// ```dart
/// final summary = getPageVisibilitySummary(plan);
/// print('Reachable: ${summary['reachable']}');
/// print('Hidden: ${summary['hidden']}');
/// print('Partial: ${summary['partial']}');
/// ```
Map<String, dynamic> getPageVisibilitySummary(RestaurantPlanUnified plan) {
  final reachable = getReachablePages(plan);
  final hidden = getHiddenPages(plan);
  final partial = getPartiallyAvailablePages(plan);

  return {
    'reachable': reachable.length,
    'reachableRoutes': reachable,
    'hidden': hidden.length,
    'hiddenRoutes': hidden,
    'partial': partial.length,
    'partialRoutes': partial,
    'totalModules': ModuleId.values.length,
    'activeModules': plan.activeModules.length,
  };
}

/// Validate page visibility configuration.
///
/// Checks for potential issues with page visibility setup.
///
/// Returns a list of validation warnings (empty if everything is OK).
///
/// Example:
/// ```dart
/// final warnings = validatePageVisibility(plan);
/// if (warnings.isNotEmpty) {
///   print('Visibility issues: $warnings');
/// }
/// ```
List<String> validatePageVisibility(RestaurantPlanUnified plan) {
  final warnings = <String>[];

  // Check if there are any reachable pages
  final reachable = getReachablePages(plan);
  if (reachable.isEmpty) {
    warnings.add('No reachable pages found - user will have no accessible content');
  }

  // Check for active but unimplemented modules
  for (final moduleId in plan.enabledModuleIds) {
    if (ModuleRuntimeMapping.isPlanned(moduleId)) {
      final label = ModuleRuntimeMapping.getLabel(moduleId);
      warnings.add('Module "$label" is active but marked as planned (not implemented)');
    }
  }

  // Check for modules without pages
  var modulesWithoutPages = 0;
  for (final moduleId in plan.enabledModuleIds) {
    if (!ModuleRuntimeMapping.getRuntimePage(moduleId)) {
      modulesWithoutPages++;
    }
  }

  if (modulesWithoutPages > 0) {
    warnings.add('$modulesWithoutPages active modules have no dedicated pages');
  }

  return warnings;
}
