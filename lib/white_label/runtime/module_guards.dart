/// lib/white_label/runtime/module_guards.dart
///
/// Generic guards for protecting routes based on modules and roles.
///
/// These guards provide automatic redirection and access control
/// based on module status and user roles.
///
/// Purpose:
/// - ModuleGuard: Check if module is enabled
/// - AdminGuard: Check if user is admin
/// - StaffGuard: Check if user is staff
/// - KitchenGuard: Check if user has kitchen access
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/module_id.dart';
import '../core/module_runtime_mapping.dart';
import '../../src/providers/restaurant_plan_provider.dart';
import '../../src/providers/auth_provider.dart';
import '../../src/core/constants.dart';

/// Generic guard for module-based route protection.
///
/// This guard checks if a module is enabled before allowing access.
/// If the module is disabled, it redirects to a fallback route.
class ModuleGuard extends ConsumerWidget {
  /// The module required to access this route.
  final ModuleId module;

  /// The child widget to display if access is granted.
  final Widget child;

  /// The fallback route to redirect to if access is denied.
  final String fallbackRoute;

  /// Whether to show a loading indicator while checking.
  final bool showLoading;

  /// Whether to log access attempts (for debugging).
  final bool logAccess;

  const ModuleGuard({
    required this.module,
    required this.child,
    this.fallbackRoute = AppRoutes.home,
    this.showLoading = true,
    this.logAccess = true,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);

    return planAsync.when(
      data: (plan) {
        // Check if plan exists
        if (plan == null) {
          if (logAccess && kDebugMode) {
            debugPrint('🔒 [ModuleGuard] No plan loaded, redirecting from ${module.label}');
          }
          _redirect(context, fallbackRoute);
          return _buildRedirectScreen();
        }

        // Check if module is enabled
        final isEnabled = plan.hasModule(module);
        
        if (!isEnabled) {
          if (logAccess && kDebugMode) {
            debugPrint('🔒 [ModuleGuard] Module ${module.label} is disabled, redirecting to $fallbackRoute');
          }
          _redirect(context, fallbackRoute);
          return _buildRedirectScreen();
        }

        // Check if module is implemented
        if (ModuleRuntimeMapping.isPlanned(module)) {
          if (logAccess && kDebugMode) {
            debugPrint('⚠️ [ModuleGuard] Module ${module.label} is planned but not implemented, redirecting');
          }
          _redirect(context, fallbackRoute);
          return _buildRedirectScreen();
        }

        if (logAccess && kDebugMode) {
          debugPrint('✅ [ModuleGuard] Access granted to ${module.label}');
        }

        // Access granted
        return child;
      },
      loading: () {
        if (showLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
      error: (error, stack) {
        if (kDebugMode) {
          debugPrint('❌ [ModuleGuard] Error loading plan: $error');
        }
        _redirect(context, fallbackRoute);
        return _buildRedirectScreen();
      },
    );
  }

  void _redirect(BuildContext context, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go(route);
      }
    });
  }

  Widget _buildRedirectScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Guard for admin-only routes.
///
/// This guard checks if the user has admin privileges before allowing access.
class AdminGuard extends ConsumerWidget {
  /// The child widget to display if access is granted.
  final Widget child;

  /// The fallback route to redirect to if access is denied.
  final String fallbackRoute;

  /// Whether to show a loading indicator while checking.
  final bool showLoading;

  /// Whether to log access attempts (for debugging).
  final bool logAccess;

  const AdminGuard({
    required this.child,
    this.fallbackRoute = AppRoutes.menu,
    this.showLoading = false,
    this.logAccess = true,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Check if user is admin
    if (!authState.isAdmin) {
      if (logAccess && kDebugMode) {
        debugPrint('🔒 [AdminGuard] Access denied - user is not admin, redirecting to $fallbackRoute');
      }
      _redirect(context, fallbackRoute);
      return _buildDeniedScreen();
    }

    if (logAccess && kDebugMode) {
      debugPrint('✅ [AdminGuard] Admin access granted');
    }

    return child;
  }

  void _redirect(BuildContext context, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go(route);
      }
    });
  }

  Widget _buildDeniedScreen() {
    if (showLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Accès réservé aux administrateurs',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

/// Guard for staff-only routes.
///
/// This guard checks if the user has staff privileges before allowing access.
/// Note: Currently, staff access is determined by admin status.
/// This can be extended to use a separate staff role in the future.
class StaffGuard extends ConsumerWidget {
  /// The child widget to display if access is granted.
  final Widget child;

  /// The fallback route to redirect to if access is denied.
  final String fallbackRoute;

  /// Whether to show a loading indicator while checking.
  final bool showLoading;

  /// Whether to log access attempts (for debugging).
  final bool logAccess;

  const StaffGuard({
    required this.child,
    this.fallbackRoute = AppRoutes.menu,
    this.showLoading = false,
    this.logAccess = true,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Check if user has staff access (currently admin = staff)
    // TODO: Implement separate staff role when available
    if (!authState.isAdmin) {
      if (logAccess && kDebugMode) {
        debugPrint('🔒 [StaffGuard] Access denied - user is not staff, redirecting to $fallbackRoute');
      }
      _redirect(context, fallbackRoute);
      return _buildDeniedScreen();
    }

    if (logAccess && kDebugMode) {
      debugPrint('✅ [StaffGuard] Staff access granted');
    }

    return child;
  }

  void _redirect(BuildContext context, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go(route);
      }
    });
  }

  Widget _buildDeniedScreen() {
    if (showLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Accès réservé au personnel',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

/// Guard for kitchen-only routes.
///
/// This guard checks if the user has kitchen access before allowing access.
/// Kitchen access is typically granted to kitchen staff and admins.
class KitchenGuard extends ConsumerWidget {
  /// The child widget to display if access is granted.
  final Widget child;

  /// The fallback route to redirect to if access is denied.
  final String fallbackRoute;

  /// Whether to show a loading indicator while checking.
  final bool showLoading;

  /// Whether to log access attempts (for debugging).
  final bool logAccess;

  const KitchenGuard({
    required this.child,
    this.fallbackRoute = AppRoutes.menu,
    this.showLoading = false,
    this.logAccess = true,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Check if user has kitchen access (currently admin = kitchen access)
    // TODO: Implement separate kitchen role when available
    if (!authState.isAdmin) {
      if (logAccess && kDebugMode) {
        debugPrint('🔒 [KitchenGuard] Access denied - user does not have kitchen access, redirecting to $fallbackRoute');
      }
      _redirect(context, fallbackRoute);
      return _buildDeniedScreen();
    }

    if (logAccess && kDebugMode) {
      debugPrint('✅ [KitchenGuard] Kitchen access granted');
    }

    return child;
  }

  void _redirect(BuildContext context, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go(route);
      }
    });
  }

  Widget _buildDeniedScreen() {
    if (showLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Accès réservé à la cuisine',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

/// Combined guard for module and role checks.
///
/// This guard combines both module and role checks in a single widget.
class ModuleAndRoleGuard extends ConsumerWidget {
  /// The module required to access this route.
  final ModuleId module;

  /// Whether admin access is required.
  final bool requiresAdmin;

  /// Whether staff access is required.
  final bool requiresStaff;

  /// Whether kitchen access is required.
  final bool requiresKitchen;

  /// The child widget to display if access is granted.
  final Widget child;

  /// The fallback route to redirect to if access is denied.
  final String fallbackRoute;

  const ModuleAndRoleGuard({
    required this.module,
    required this.child,
    this.requiresAdmin = false,
    this.requiresStaff = false,
    this.requiresKitchen = false,
    this.fallbackRoute = AppRoutes.home,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // First check module
    return ModuleGuard(
      module: module,
      fallbackRoute: fallbackRoute,
      logAccess: true,
      child: _buildRoleGuard(context),
    );
  }

  Widget _buildRoleGuard(BuildContext context) {
    // Then check role
    if (requiresAdmin) {
      return AdminGuard(
        fallbackRoute: fallbackRoute,
        child: child,
      );
    } else if (requiresStaff) {
      return StaffGuard(
        fallbackRoute: fallbackRoute,
        child: child,
      );
    } else if (requiresKitchen) {
      return KitchenGuard(
        fallbackRoute: fallbackRoute,
        child: child,
      );
    }

    // No role requirement
    return child;
  }
}
