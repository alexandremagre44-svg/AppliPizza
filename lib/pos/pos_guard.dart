/// POS Guard - Custom guard for POS routes
/// 
/// This guard implements special logic for POS access:
/// - Admins can ALWAYS access POS (regardless of module status)
/// - Non-admins cannot access POS at all
/// - POS is associated with staff_tablet or paymentTerminal modules
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../white_label/core/module_id.dart';
import '../src/providers/restaurant_plan_provider.dart';
import '../src/providers/auth_provider.dart';
import '../src/core/constants.dart';

/// POS Guard - Admin-only access with module awareness
///
/// Rules:
/// 1. Admin can ALWAYS access POS (even if modules are off)
/// 2. Non-admin can NEVER access POS
/// 3. POS is linked to staff_tablet or paymentTerminal modules
class PosGuard extends ConsumerWidget {
  /// The child widget to display if access is granted.
  final Widget child;
  
  /// The fallback route to redirect to if access is denied.
  final String fallbackRoute;
  
  /// Whether to show a loading indicator while checking.
  final bool showLoading;
  
  /// Whether to log access attempts (for debugging).
  final bool logAccess;
  
  const PosGuard({
    required this.child,
    this.fallbackRoute = AppRoutes.menu,
    this.showLoading = false,
    this.logAccess = true,
    super.key,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // Rule 1: Check if user is admin
    if (!authState.isAdmin) {
      if (logAccess && kDebugMode) {
        debugPrint('🔒 [PosGuard] Access denied - user is not admin, redirecting to $fallbackRoute');
      }
      _redirect(context, fallbackRoute);
      return _buildDeniedScreen();
    }
    
    // Rule 2: Admin always has access to POS
    if (logAccess && kDebugMode) {
      debugPrint('✅ [PosGuard] Admin access granted to POS');
    }
    
    // Optional: Check if either module is enabled (for informational purposes only)
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    planAsync.whenData((plan) {
      if (plan != null && logAccess && kDebugMode) {
        final hasStaffTablet = plan.hasModule(ModuleId.staff_tablet);
        final hasPaymentTerminal = plan.hasModule(ModuleId.paymentTerminal);
        
        if (!hasStaffTablet && !hasPaymentTerminal) {
          debugPrint('ℹ️ [PosGuard] Neither staff_tablet nor paymentTerminal module is enabled, but admin access is granted anyway');
        } else if (hasStaffTablet) {
          debugPrint('ℹ️ [PosGuard] staff_tablet module is enabled');
        } else if (hasPaymentTerminal) {
          debugPrint('ℹ️ [PosGuard] paymentTerminal module is enabled');
        }
      }
    });
    
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red[900]!,
              Colors.red[700]!,
            ],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32.0),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Accès non autorisé',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Le module POS (Caisse) est réservé aux administrateurs uniquement.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      final context = this.child.key as GlobalKey?;
                      if (context?.currentContext?.mounted == true) {
                        context!.currentContext!.go(AppRoutes.menu);
                      }
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Retour au menu'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
