/// lib/white_label/runtime/service_guard.dart
/// Runtime Service Guard Layer
///
/// This layer provides guards for business services to ensure they only
/// operate when their corresponding modules are enabled.
///
/// NON-INTRUSIVE: Does not modify existing services.
/// Creates wrapper layer that can be used optionally.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/module_id.dart';
import '../core/module_runtime_mapping.dart';
import '../restaurant/restaurant_plan_unified.dart';
import '../../src/providers/restaurant_plan_provider.dart';

/// Exception thrown when attempting to use a disabled module.
class ModuleDisabledException implements Exception {
  /// The module that is disabled.
  final ModuleId moduleId;

  /// The operation that was attempted.
  final String operation;

  /// Human-readable message.
  final String message;

  ModuleDisabledException({
    required this.moduleId,
    required this.operation,
  }) : message = 'Module "${moduleId.code}" is disabled. Cannot perform: $operation';

  @override
  String toString() => 'ModuleDisabledException: $message';
}

/// Exception thrown when attempting to use a partially implemented module
/// without explicit acknowledgment.
class ModulePartiallyImplementedException implements Exception {
  /// The module that is partially implemented.
  final ModuleId moduleId;

  /// The operation that was attempted.
  final String operation;

  /// Human-readable message.
  final String message;

  ModulePartiallyImplementedException({
    required this.moduleId,
    required this.operation,
  }) : message = 'Module "${moduleId.code}" is partially implemented. '
            'Operation "$operation" may have limited functionality.';

  @override
  String toString() => 'ModulePartiallyImplementedException: $message';
}

/// Service guard for protecting business operations.
///
/// This class provides utilities to check if modules are enabled
/// before allowing service operations to proceed.
///
/// Usage:
/// ```dart
/// final guard = ServiceGuard(plan);
/// guard.ensureEnabled(ModuleId.loyalty, 'addPoints');
/// // Throws ModuleDisabledException if loyalty is disabled
/// ```
class ServiceGuard {
  /// The restaurant plan to check against.
  final RestaurantPlanUnified? plan;

  /// Whether to allow operations when plan is null (backward compatibility).
  final bool allowWhenPlanNull;

  /// Whether to throw exceptions for partially implemented modules.
  final bool strictPartialCheck;

  ServiceGuard({
    required this.plan,
    this.allowWhenPlanNull = true,
    this.strictPartialCheck = false,
  });

  /// Check if a module is enabled.
  ///
  /// Returns true if:
  /// - Plan is null and allowWhenPlanNull is true (backward compatibility)
  /// - Module is active in the plan
  ///
  /// Returns false if:
  /// - Module is not active in the plan
  bool isEnabled(ModuleId moduleId) {
    // If no plan, allow operations (backward compatibility)
    if (plan == null) {
      return allowWhenPlanNull;
    }

    return plan!.hasModule(moduleId);
  }

  /// Check if a module is partially enabled.
  ///
  /// Returns true if the module is active but only partially implemented.
  bool isPartiallyEnabled(ModuleId moduleId) {
    if (!isEnabled(moduleId)) {
      return false;
    }

    return ModuleRuntimeMapping.isPartiallyImplemented(moduleId);
  }

  /// Ensure a module is enabled before proceeding.
  ///
  /// Throws [ModuleDisabledException] if the module is not enabled.
  /// Throws [ModulePartiallyImplementedException] if the module is partially
  /// implemented and strictPartialCheck is true.
  ///
  /// Use this at the beginning of service methods to guard operations.
  ///
  /// Example:
  /// ```dart
  /// Future<void> addPoints(String userId, int points) async {
  ///   guard.ensureEnabled(ModuleId.loyalty, 'addPoints');
  ///   // Proceed with operation
  /// }
  /// ```
  void ensureEnabled(ModuleId moduleId, [String operation = 'operation']) {
    if (!isEnabled(moduleId)) {
      throw ModuleDisabledException(
        moduleId: moduleId,
        operation: operation,
      );
    }

    if (strictPartialCheck && isPartiallyEnabled(moduleId)) {
      throw ModulePartiallyImplementedException(
        moduleId: moduleId,
        operation: operation,
      );
    }

    // Log warning for partial modules in debug mode
    if (kDebugMode && isPartiallyEnabled(moduleId)) {
      debugPrint('⚠️ [ServiceGuard] Module ${moduleId.code} is partially implemented. Operation: $operation');
    }
  }

  /// Ensure a module is enabled and fully implemented.
  ///
  /// Always throws [ModulePartiallyImplementedException] for partial modules,
  /// regardless of strictPartialCheck setting.
  ///
  /// Use this for operations that require full module functionality.
  void ensureFullyEnabled(ModuleId moduleId, [String operation = 'operation']) {
    if (!isEnabled(moduleId)) {
      throw ModuleDisabledException(
        moduleId: moduleId,
        operation: operation,
      );
    }

    if (isPartiallyEnabled(moduleId)) {
      throw ModulePartiallyImplementedException(
        moduleId: moduleId,
        operation: operation,
      );
    }
  }

  /// Check if operation is allowed (doesn't throw, just returns bool).
  ///
  /// Returns true if the module is enabled and operation can proceed.
  /// Returns false if the module is disabled.
  ///
  /// Use this when you want to gracefully handle disabled modules
  /// instead of throwing exceptions.
  ///
  /// Example:
  /// ```dart
  /// if (guard.isOperationAllowed(ModuleId.loyalty)) {
  ///   // Perform loyalty operation
  /// } else {
  ///   // Skip or show message
  /// }
  /// ```
  bool isOperationAllowed(ModuleId moduleId) {
    return isEnabled(moduleId) && !isPartiallyEnabled(moduleId);
  }

  /// Check if operation is allowed, considering partial modules.
  ///
  /// Returns true if module is enabled (even if partial).
  /// Returns false if module is disabled.
  bool isOperationAllowedPartial(ModuleId moduleId) {
    return isEnabled(moduleId);
  }

  /// Create a guard from a WidgetRef.
  ///
  /// Convenience factory that reads the restaurant plan from providers.
  ///
  /// Example:
  /// ```dart
  /// final guard = ServiceGuard.fromRef(ref);
  /// guard.ensureEnabled(ModuleId.loyalty, 'addPoints');
  /// ```
  factory ServiceGuard.fromRef(
    WidgetRef ref, {
    bool allowWhenPlanNull = true,
    bool strictPartialCheck = false,
  }) {
    final planAsync = ref.read(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    return ServiceGuard(
      plan: plan,
      allowWhenPlanNull: allowWhenPlanNull,
      strictPartialCheck: strictPartialCheck,
    );
  }

  /// Create a guard that always allows operations (no-op guard).
  ///
  /// Useful for testing or when you want to disable guards temporarily.
  factory ServiceGuard.permissive() {
    return ServiceGuard(
      plan: null,
      allowWhenPlanNull: true,
      strictPartialCheck: false,
    );
  }

  /// Create a guard that always denies operations (strict guard).
  ///
  /// Useful for testing failure scenarios.
  factory ServiceGuard.strict() {
    return ServiceGuard(
      plan: null,
      allowWhenPlanNull: false,
      strictPartialCheck: true,
    );
  }
}

/// Provider for ServiceGuard.
///
/// Automatically reads the current restaurant plan and creates a guard.
///
/// Usage:
/// ```dart
/// final guard = ref.watch(serviceGuardProvider);
/// guard.ensureEnabled(ModuleId.loyalty, 'addPoints');
/// ```
final serviceGuardProvider = Provider<ServiceGuard>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    return ServiceGuard(
      plan: plan,
      allowWhenPlanNull: true,
      strictPartialCheck: false,
    );
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Provider for strict ServiceGuard (throws on partial modules).
///
/// Use this when you need full module functionality.
final strictServiceGuardProvider = Provider<ServiceGuard>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    return ServiceGuard(
      plan: plan,
      allowWhenPlanNull: true,
      strictPartialCheck: true,
    );
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Helper extension for WidgetRef to easily create guards.
extension ServiceGuardRefExtension on WidgetRef {
  /// Get a service guard from this ref.
  ServiceGuard get serviceGuard => ServiceGuard.fromRef(this);

  /// Get a strict service guard from this ref.
  ServiceGuard get strictServiceGuard => ServiceGuard.fromRef(
        this,
        strictPartialCheck: true,
      );
}
