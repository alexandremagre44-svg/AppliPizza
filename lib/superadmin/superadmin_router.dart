/// lib/superadmin/superadmin_router.dart
///
/// Router interne du module Super-Admin.
/// Gère la navigation uniquement dans le contexte Super-Admin.
/// Ce router est totalement isolé du router principal de l'application.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'layout/superadmin_layout.dart';
import 'pages/dashboard_page.dart';
import 'pages/restaurants_list_page.dart';
import 'pages/restaurant_detail_page.dart';
import 'pages/restaurant_wizard/wizard_entry_page.dart';
import 'pages/restaurant_modules_page.dart';
import 'pages/modules/delivery/delivery_settings_page.dart';
import 'pages/users_page.dart';
import 'pages/modules_page.dart';
import 'pages/settings_page.dart';
import 'pages/logs_page.dart';

/// Routes du module Super-Admin.
class SuperAdminRoutes {
  /// Route racine du Super-Admin.
  static const String root = '/superadmin';

  /// Route du tableau de bord.
  static const String dashboard = '/superadmin/dashboard';

  /// Route de la liste des restaurants.
  static const String restaurants = '/superadmin/restaurants';

  /// Route de création de restaurant.
  static const String restaurantCreate = '/superadmin/restaurants/create';

  /// Route de détail d'un restaurant (avec paramètre :id).
  static const String restaurantDetail = '/superadmin/restaurants/:id';

  /// Route de gestion des modules d'un restaurant (avec paramètre :id).
  static const String restaurantModules = '/superadmin/restaurants/:id/modules';

  /// Route de configuration du module livraison d'un restaurant.
  static const String restaurantDeliverySettings =
      '/superadmin/restaurants/:id/modules/delivery';

  /// Route de gestion des utilisateurs.
  static const String users = '/superadmin/users';

  /// Route de gestion des modules.
  static const String modules = '/superadmin/modules';

  /// Route des paramètres.
  static const String settings = '/superadmin/settings';

  /// Route des logs d'activité.
  static const String logs = '/superadmin/logs';
}

/// Liste des routes Super-Admin à intégrer dans le router principal.
/// 
/// Cette liste contient le ShellRoute avec toutes les sous-routes du Super-Admin.
/// Elle peut être spreadée dans le router principal avec `...superAdminRoutes`.
final List<RouteBase> superAdminRoutes = [
  // ShellRoute applique le layout Super-Admin à toutes les sous-routes
  ShellRoute(
    builder: (context, state, child) {
      return SuperAdminLayout(body: child);
    },
    routes: [
      // Dashboard
      GoRoute(
        path: SuperAdminRoutes.dashboard,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: DashboardPage(),
        ),
      ),
      // Restaurants - Liste
      GoRoute(
        path: SuperAdminRoutes.restaurants,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: RestaurantsListPage(),
        ),
      ),
      // Restaurants - Création
      GoRoute(
        path: SuperAdminRoutes.restaurantCreate,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: WizardEntryPage(),
        ),
      ),
      // Restaurants - Détail
      GoRoute(
        path: SuperAdminRoutes.restaurantDetail,
        pageBuilder: (context, state) {
          final restaurantId = state.pathParameters['id'] ?? '';
          return NoTransitionPage(
            child: RestaurantDetailPage(restaurantId: restaurantId),
          );
        },
      ),
      // Restaurants - Modules
      GoRoute(
        path: SuperAdminRoutes.restaurantModules,
        pageBuilder: (context, state) {
          final restaurantId = state.pathParameters['id'] ?? '';
          final restaurantName = state.uri.queryParameters['name'];
          return NoTransitionPage(
            child: RestaurantModulesPage(
              restaurantId: restaurantId,
              restaurantName: restaurantName,
            ),
          );
        },
      ),
      // Restaurants - Delivery Settings
      GoRoute(
        path: SuperAdminRoutes.restaurantDeliverySettings,
        pageBuilder: (context, state) {
          final restaurantId = state.pathParameters['id'] ?? '';
          final restaurantName = state.uri.queryParameters['name'];
          return NoTransitionPage(
            child: DeliverySettingsPage(
              restaurantId: restaurantId,
              restaurantName: restaurantName,
            ),
          );
        },
      ),
      // Users
      GoRoute(
        path: SuperAdminRoutes.users,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: UsersPage(),
        ),
      ),
      // Modules
      GoRoute(
        path: SuperAdminRoutes.modules,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ModulesPage(),
        ),
      ),
      // Settings
      GoRoute(
        path: SuperAdminRoutes.settings,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SettingsPage(),
        ),
      ),
      // Logs
      GoRoute(
        path: SuperAdminRoutes.logs,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LogsPage(),
        ),
      ),
    ],
  ),
];

/// Configuration du router Super-Admin.
/// 
/// Ce router est conçu pour être utilisé de manière isolée.
/// Il utilise un ShellRoute pour appliquer le layout Super-Admin à toutes les pages.
GoRouter createSuperAdminRouter() {
  return GoRouter(
    initialLocation: SuperAdminRoutes.dashboard,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // TODO: Add Super-Admin authentication check here
      // For now, no auth verification (Phase 0 - structure only)
      
      // Si on accède à /superadmin, rediriger vers dashboard
      if (state.matchedLocation == SuperAdminRoutes.root) {
        return SuperAdminRoutes.dashboard;
      }
      
      return null;
    },
    routes: [
      // Utilise les routes Super-Admin partagées
      ...superAdminRoutes,
      // Route racine - redirige vers dashboard
      GoRoute(
        path: SuperAdminRoutes.root,
        redirect: (context, state) => SuperAdminRoutes.dashboard,
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${state.uri}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(SuperAdminRoutes.dashboard),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
