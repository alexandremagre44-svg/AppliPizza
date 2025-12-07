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
import 'wl/wl_module_wrapper.dart';

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

/// Legacy function for wrapping module widgets with safe layout constraints.
///
/// **Deprecated**: Use ModuleRuntimeRegistry.wrapModuleSafe() instead.
/// This function will be removed in a future version.
///
/// @deprecated Use ModuleRuntimeRegistry.wrapModuleSafe() instead
@Deprecated('Use ModuleRuntimeRegistry.wrapModuleSafe() instead')
Widget wrapModuleSafe(Widget child) {
  return ModuleRuntimeRegistry.wrapModuleSafe(child);
}

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

  /// Wrap a module widget with safe layout constraints
  /// 
  /// This wrapper is automatically applied to all WL modules
  /// to prevent layout issues in the Builder grid.
  /// 
  /// The wrapper provides:
  /// - Maximum width constraint (600px default)
  /// - IntrinsicHeight for proper height calculation
  /// - Center alignment for horizontal centering
  /// 
  /// This prevents errors like:
  /// - "Cannot hit test a render box with no size"
  /// - Infinite constraint errors from scroll widgets
  /// - Layout conflicts with parent ListView
  /// 
  /// Example:
  /// ```dart
  /// return ModuleRuntimeRegistry.wrapModuleSafe(MyModuleWidget());
  /// ```
  static Widget wrapModuleSafe(Widget child) => WLModuleWrapper(child: child);

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
  /// [context] - The build context (MUST be valid and mounted)
  ///
  /// Returns the admin widget if registered, null otherwise.
  /// The widget is automatically wrapped in wrapModuleSafe for layout safety.
  ///
  /// SAFE: No context storage, no async operations, no navigation.
  /// Just builds widget and wraps it with layout constraints.
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
    if (builder == null) return null;
    
    // Build the widget (no side effects)
    final widget = builder(context);
    
    // Wrap with safe layout constraints (no context manipulation)
    return wrapModuleSafe(widget);
  }

  /// Build a CLIENT widget for a White-Label module
  ///
  /// [moduleId] - The module identifier to build
  /// [context] - The build context (MUST be valid and mounted)
  ///
  /// Returns the client widget if registered, null otherwise.
  /// The widget is automatically wrapped in wrapModuleSafe for layout safety.
  ///
  /// SAFE: No context storage, no async operations, no navigation.
  /// Just builds widget and wraps it with layout constraints.
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
    if (builder == null) return null;
    
    // Build the widget (no side effects)
    final widget = builder(context);
    
    // Wrap with safe layout constraints (no context manipulation)
    return wrapModuleSafe(widget);
  }

  /// Build a White-Label module widget (legacy method)
  ///
  /// @deprecated Use buildAdmin or buildClient instead
  ///
  /// [moduleId] - The module identifier to build
  /// [context] - The build context (MUST be valid and mounted)
  ///
  /// Returns the module widget if registered, null otherwise.
  /// The widget is automatically wrapped in wrapModuleSafe for layout safety.
  ///
  /// SAFE: No context storage, no async operations, no navigation.
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
    if (builder == null) return null;
    
    // Build the widget (no side effects)
    final widget = builder(context);
    
    // Wrap with safe layout constraints (no context manipulation)
    return wrapModuleSafe(widget);
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
///
/// This is an ultra-simple, safe widget with no complex layout,
/// no Overlay, no MouseRegion, or any other potentially problematic widgets.
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
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(
        'Module "$moduleId" non disponible',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
