/// lib/white_label/runtime/runtime.dart
///
/// Runtime exports for white-label module system.
///
/// This file provides a single import point for all runtime
/// white-label features including guards, helpers, and registry.
library;

// Core exports
export '../core/module_id.dart';
export '../core/module_category.dart';
export '../core/module_matrix.dart';
export '../core/module_runtime_mapping.dart';

// Runtime exports
export 'module_guards.dart';
export 'module_helpers.dart';
export 'module_navigation_registry.dart';
export 'module_route_resolver.dart';
export 'router_guard.dart';

// Registration
export 'register_module_routes.dart';
