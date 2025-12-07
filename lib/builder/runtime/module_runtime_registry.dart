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

/// Type definition for module runtime widget builders
///
/// Takes a BuildContext and returns a Widget to render the module.
typedef ModuleRuntimeBuilder = Widget Function(BuildContext context);

/// Registry dedicated to White-Label modules.
///
/// Works independently from the BlockType renderer system used for Builder blocks.
/// This provides a clean separation between:
/// - Standard builder blocks (hero, text, banner, etc.) → BlockType system
/// - White-Label modules (delivery, loyalty, etc.) → This registry
///
/// Keys are module IDs coming from builder_modules.dart
/// (ex: "delivery_module", "loyalty_module", etc.)
class ModuleRuntimeRegistry {
  // Private constructor - this class is not meant to be instantiated
  ModuleRuntimeRegistry._();

  /// Internal registry mapping module IDs to their widget builders
  static final Map<String, ModuleRuntimeBuilder> _registry = {};

  /// Register a White-Label module with its widget builder
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
  static void register(String moduleId, ModuleRuntimeBuilder builder) {
    _registry[moduleId] = builder;
  }

  /// Build a White-Label module widget
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
  static Widget? build(String moduleId, BuildContext context) {
    final builder = _registry[moduleId];
    return builder?.call(context);
  }

  /// Check if a module is registered
  ///
  /// [moduleId] - The module identifier to check
  ///
  /// Returns true if the module is registered, false otherwise.
  static bool contains(String moduleId) {
    return _registry.containsKey(moduleId);
  }

  /// Get all registered module IDs
  ///
  /// Returns a list of all module IDs currently registered.
  static List<String> getRegisteredModules() {
    return _registry.keys.toList();
  }

  /// Unregister a module (useful for testing)
  ///
  /// [moduleId] - The module identifier to unregister
  ///
  /// Returns true if the module was unregistered, false if it wasn't registered.
  static bool unregister(String moduleId) {
    return _registry.remove(moduleId) != null;
  }

  /// Clear all registered modules (useful for testing)
  static void clear() {
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
