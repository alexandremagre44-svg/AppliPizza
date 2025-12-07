// lib/builder/runtime/module_runtime_registry.dart
// Registry dedicated to White-Label modules runtime rendering
//
// This registry works independently from the BlockType renderer system
// used for Builder blocks. It provides a parallel, clean architecture
// for rendering White-Label modules without collisions.
//
// Keys are module IDs coming from builder_modules.dart
// (ex: "delivery_module", "loyalty_module", etc.)

import 'package:flutter/material.dart';

/// Type definition for module admin widget builders (for Builder UI)
///
/// Takes a BuildContext and returns a Widget to render the module in admin/builder mode.
typedef ModuleAdminBuilder = Widget Function(BuildContext context);

/// Type definition for module client widget builders (for Client App)
///
/// Takes a BuildContext and returns a Widget to render the module in client/runtime mode.
typedef ModuleClientBuilder = Widget Function(BuildContext context);

/// Type definition for module runtime widget builders (legacy, for backward compatibility)
///
/// Takes a BuildContext and returns a Widget to render the module.
@Deprecated('Use ModuleAdminBuilder or ModuleClientBuilder instead')
typedef ModuleRuntimeBuilder = Widget Function(BuildContext context);

/// Registry dedicated to White-Label modules.
///
/// Works independently from the BlockType renderer system used for Builder blocks.
/// This provides a clean separation between:
/// - Standard builder blocks (hero, text, banner, etc.) → BlockType system
/// - White-Label modules (delivery, loyalty, etc.) → This registry
///
/// Supports dual widget system:
/// - ADMIN widgets: Shown in Builder UI (configuration, settings)
/// - CLIENT widgets: Shown in Client App (user-facing functionality)
///
/// Keys are module IDs coming from builder_modules.dart
/// (ex: "delivery_module", "loyalty_module", etc.)
class ModuleRuntimeRegistry {
  // Private constructor - this class is not meant to be instantiated
  ModuleRuntimeRegistry._();

  /// Internal registry mapping module IDs to their admin widget builders
  static final Map<String, ModuleAdminBuilder> _adminWidgets = {};

  /// Internal registry mapping module IDs to their client widget builders
  static final Map<String, ModuleClientBuilder> _clientWidgets = {};

  /// Legacy internal registry mapping module IDs to their widget builders
  /// @deprecated Use _adminWidgets and _clientWidgets instead
  static final Map<String, ModuleRuntimeBuilder> _registry = {};

  /// Register an ADMIN widget for a White-Label module
  ///
  /// This widget will be shown in the Builder UI (admin/configuration mode).
  ///
  /// [moduleId] - The module identifier (e.g., "delivery_module")
  /// [builder] - Function that creates the admin widget
  ///
  /// Example:
  /// ```dart
  /// ModuleRuntimeRegistry.registerAdmin(
  ///   'delivery_module',
  ///   (ctx) => const DeliveryModuleAdminWidget(),
  /// );
  /// ```
  static void registerAdmin(String moduleId, ModuleAdminBuilder builder) {
    _adminWidgets[moduleId] = builder;
  }

  /// Register a CLIENT widget for a White-Label module
  ///
  /// This widget will be shown in the Client App (user-facing mode).
  ///
  /// [moduleId] - The module identifier (e.g., "delivery_module")
  /// [builder] - Function that creates the client widget
  ///
  /// Example:
  /// ```dart
  /// ModuleRuntimeRegistry.registerClient(
  ///   'delivery_module',
  ///   (ctx) => const DeliveryClientWidget(),
  /// );
  /// ```
  static void registerClient(String moduleId, ModuleClientBuilder builder) {
    _clientWidgets[moduleId] = builder;
  }

  /// Register a White-Label module with its widget builder (legacy method)
  ///
  /// @deprecated Use registerAdmin and registerClient instead for dual widget support
  ///
  /// [moduleId] - The module identifier (e.g., "delivery_module")
  /// [builder] - Function that creates the module widget
  ///
  /// Example:
  /// ```dart
  /// ModuleRuntimeRegistry.register(
  ///   'delivery_module',
  ///   (ctx) => const DeliveryModuleWidget(),
  /// );
  /// ```
  @Deprecated('Use registerAdmin and registerClient instead')
  static void register(String moduleId, ModuleRuntimeBuilder builder) {
    _registry[moduleId] = builder;
    // For backward compatibility, also register as admin widget
    _adminWidgets[moduleId] = builder;
  }

  /// Build an ADMIN widget for a White-Label module
  ///
  /// [moduleId] - The module identifier to build
  /// [context] - The build context
  ///
  /// Returns the admin widget if registered, null otherwise.
  ///
  /// Example:
  /// ```dart
  /// final widget = ModuleRuntimeRegistry.buildAdmin('delivery_module', context);
  /// if (widget != null) {
  ///   return widget;
  /// }
  /// ```
  static Widget? buildAdmin(String moduleId, BuildContext context) {
    final builder = _adminWidgets[moduleId];
    return builder?.call(context);
  }

  /// Build a CLIENT widget for a White-Label module
  ///
  /// [moduleId] - The module identifier to build
  /// [context] - The build context
  ///
  /// Returns the client widget if registered, null otherwise.
  ///
  /// Example:
  /// ```dart
  /// final widget = ModuleRuntimeRegistry.buildClient('delivery_module', context);
  /// if (widget != null) {
  ///   return widget;
  /// }
  /// ```
  static Widget? buildClient(String moduleId, BuildContext context) {
    final builder = _clientWidgets[moduleId];
    return builder?.call(context);
  }

  /// Build a White-Label module widget (legacy method)
  ///
  /// @deprecated Use buildAdmin or buildClient instead
  ///
  /// [moduleId] - The module identifier to build
  /// [context] - The build context
  ///
  /// Returns the module widget if registered, null otherwise.
  ///
  /// Example:
  /// ```dart
  /// final widget = ModuleRuntimeRegistry.build('delivery_module', context);
  /// if (widget != null) {
  ///   return widget;
  /// }
  /// ```
  @Deprecated('Use buildAdmin or buildClient instead')
  static Widget? build(String moduleId, BuildContext context) {
    final builder = _registry[moduleId];
    return builder?.call(context);
  }

  /// Check if a module is registered (checks both admin and client registries)
  ///
  /// [moduleId] - The module identifier to check
  ///
  /// Returns true if the module is registered (in either registry), false otherwise.
  static bool contains(String moduleId) {
    return _adminWidgets.containsKey(moduleId) || 
           _clientWidgets.containsKey(moduleId) ||
           _registry.containsKey(moduleId);
  }

  /// Check if an admin widget is registered for a module
  ///
  /// [moduleId] - The module identifier to check
  ///
  /// Returns true if an admin widget is registered, false otherwise.
  static bool containsAdmin(String moduleId) {
    return _adminWidgets.containsKey(moduleId);
  }

  /// Check if a client widget is registered for a module
  ///
  /// [moduleId] - The module identifier to check
  ///
  /// Returns true if a client widget is registered, false otherwise.
  static bool containsClient(String moduleId) {
    return _clientWidgets.containsKey(moduleId);
  }

  /// Get all registered module IDs (from all registries)
  ///
  /// Returns a list of all module IDs currently registered.
  static List<String> getRegisteredModules() {
    final allModules = <String>{
      ..._adminWidgets.keys,
      ..._clientWidgets.keys,
      ..._registry.keys,
    };
    return allModules.toList();
  }

  /// Unregister a module (useful for testing)
  ///
  /// Removes the module from all registries.
  ///
  /// [moduleId] - The module identifier to unregister
  ///
  /// Returns true if the module was unregistered from any registry, false otherwise.
  static bool unregister(String moduleId) {
    final removedAdmin = _adminWidgets.remove(moduleId) != null;
    final removedClient = _clientWidgets.remove(moduleId) != null;
    final removedLegacy = _registry.remove(moduleId) != null;
    return removedAdmin || removedClient || removedLegacy;
  }

  /// Clear all registered modules (useful for testing)
  static void clear() {
    _adminWidgets.clear();
    _clientWidgets.clear();
    _registry.clear();
  }
}

/// Fallback widget displayed when a module is not registered
///
/// This widget is shown when a SystemBlock references a module ID
/// that hasn't been registered in the ModuleRuntimeRegistry.
class UnknownModuleWidget extends StatelessWidget {
  /// The module ID that couldn't be found
  final String moduleId;

  const UnknownModuleWidget({
    super.key,
    required this.moduleId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.shade300,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.extension_off,
            size: 48,
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: 12),
          Text(
            'Module non enregistré',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Module ID: "$moduleId"',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ce module doit être enregistré dans\nModuleRuntimeRegistry pour être affiché.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
