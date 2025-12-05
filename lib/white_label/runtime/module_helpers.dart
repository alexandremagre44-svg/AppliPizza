/// lib/white_label/runtime/module_helpers.dart
///
/// Helper functions for checking module status and availability.
///
/// These helpers are designed to be used throughout the application,
/// including in the Builder B3 system, to conditionally show/hide
/// features based on module status.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/module_id.dart';
import '../../src/providers/restaurant_plan_provider.dart';

/// Check if a module is enabled for the current restaurant.
///
/// This is a synchronous check that looks at the current state of the
/// restaurant plan. Returns false if the plan is loading or not available.
///
/// Usage in widgets:
/// ```dart
/// if (isModuleEnabled(ref, ModuleId.roulette)) {
///   // Show roulette button
/// }
/// ```
///
/// Usage in Builder B3:
/// ```dart
/// // In block visibility check
/// if (!isModuleEnabled(ref, ModuleId.roulette)) {
///   return const SizedBox.shrink(); // Hide block
/// }
/// ```
bool isModuleEnabled(WidgetRef ref, ModuleId id) {
  final planAsync = ref.read(restaurantPlanUnifiedProvider);
  
  return planAsync.when(
    data: (plan) {
      if (plan == null) return false;
      return plan.hasModule(id);
    },
    loading: () => false,
    error: (_, __) => false,
  );
}

/// Check if multiple modules are all enabled.
///
/// Returns true only if ALL specified modules are enabled.
///
/// Example:
/// ```dart
/// if (areModulesEnabled(ref, [ModuleId.loyalty, ModuleId.roulette])) {
///   // Both loyalty and roulette are enabled
/// }
/// ```
bool areModulesEnabled(WidgetRef ref, List<ModuleId> modules) {
  for (final moduleId in modules) {
    if (!isModuleEnabled(ref, moduleId)) {
      return false;
    }
  }
  return true;
}

/// Check if at least one of the specified modules is enabled.
///
/// Returns true if ANY of the specified modules are enabled.
///
/// Example:
/// ```dart
/// if (isAnyModuleEnabled(ref, [ModuleId.delivery, ModuleId.clickAndCollect])) {
///   // Either delivery or click & collect is available
/// }
/// ```
bool isAnyModuleEnabled(WidgetRef ref, List<ModuleId> modules) {
  for (final moduleId in modules) {
    if (isModuleEnabled(ref, moduleId)) {
      return true;
    }
  }
  return false;
}

/// Watch a module's enabled status reactively.
///
/// This creates a provider that will rebuild widgets when the module
/// status changes. Use this for reactive UI updates.
///
/// Example:
/// ```dart
/// final isRouletteEnabled = watchModuleEnabled(ref, ModuleId.roulette);
/// if (isRouletteEnabled) {
///   // Show roulette content
/// }
/// ```
bool watchModuleEnabled(WidgetRef ref, ModuleId id) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  
  return planAsync.when(
    data: (plan) {
      if (plan == null) return false;
      return plan.hasModule(id);
    },
    loading: () => false,
    error: (_, __) => false,
  );
}

/// Get a list of all enabled module IDs.
///
/// Returns an empty list if no plan is loaded.
///
/// Example:
/// ```dart
/// final enabledModules = getEnabledModules(ref);
/// print('${enabledModules.length} modules enabled');
/// ```
List<ModuleId> getEnabledModules(WidgetRef ref) {
  final planAsync = ref.read(restaurantPlanUnifiedProvider);
  
  return planAsync.when(
    data: (plan) {
      if (plan == null) return [];
      return plan.enabledModuleIds;
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Check if a module is disabled.
///
/// Convenience method that returns the opposite of isModuleEnabled.
///
/// Example:
/// ```dart
/// if (isModuleDisabled(ref, ModuleId.roulette)) {
///   // Hide roulette-related UI
/// }
/// ```
bool isModuleDisabled(WidgetRef ref, ModuleId id) {
  return !isModuleEnabled(ref, id);
}
