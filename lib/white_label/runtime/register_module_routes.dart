/// lib/white_label/runtime/register_module_routes.dart
///
/// Registration of all module routes.
///
/// This file registers all routes for each module into the
/// ModuleNavigationRegistry. It serves as a central location
/// to define and manage all module-specific routes.
///
/// This file should be called once during app initialization.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/module_id.dart';
import '../core/module_category.dart';
import '../../src/core/constants.dart';
import 'module_navigation_registry.dart';

// Import screens
import '../../src/screens/roulette/roulette_screen.dart';
import '../../src/screens/client/rewards/rewards_screen.dart';
import '../../src/screens/delivery/delivery_address_screen.dart';
import '../../src/screens/delivery/delivery_area_selector_screen.dart';
import '../../src/screens/delivery/delivery_tracking_screen.dart';
import '../../src/screens/kitchen/kitchen_screen.dart';
import '../../src/screens/admin/pos/pos_screen.dart';
import '../../src/staff_tablet/screens/staff_tablet_pin_screen.dart';
import '../../src/staff_tablet/screens/staff_tablet_catalog_screen.dart';
import '../../src/staff_tablet/screens/staff_tablet_checkout_screen.dart';
import '../../src/staff_tablet/screens/staff_tablet_history_screen.dart';
import '../../src/models/order.dart';

/// Register all module routes.
///
/// This function should be called once during app initialization
/// to register all available module routes.
///
/// Example:
/// ```dart
/// void main() {
///   registerAllModuleRoutes();
///   runApp(MyApp());
/// }
/// ```
void registerAllModuleRoutes() {
  _registerRouletteRoutes();
  _registerLoyaltyRoutes();
  _registerDeliveryRoutes();
  _registerKitchenRoutes();
  _registerStaffTabletRoutes();
  // Add more module registrations here as needed
}

/// Register roulette module routes.
void _registerRouletteRoutes() {
  ModuleNavigationRegistry.registerModuleRoutes(
    ModuleId.roulette,
    [
      ModuleRouteDefinition(
        route: GoRoute(
          path: '/roulette',
          builder: (context, state) {
            // Routes are protected by the global whiteLabelRouteGuard in main.dart
            // No additional guard needed here as the module check is done at the router level
            return const RouletteScreen();
          },
        ),
        moduleId: ModuleId.roulette,
        accessLevel: ModuleAccessLevel.client,
        isMainRoute: true,
      ),
    ],
  );
}

/// Register loyalty module routes.
void _registerLoyaltyRoutes() {
  ModuleNavigationRegistry.registerModuleRoutes(
    ModuleId.loyalty,
    [
      ModuleRouteDefinition(
        route: GoRoute(
          path: '/rewards',
          builder: (context, state) => const RewardsScreen(),
        ),
        moduleId: ModuleId.loyalty,
        accessLevel: ModuleAccessLevel.client,
        isMainRoute: true,
      ),
    ],
  );
}

/// Register delivery module routes.
void _registerDeliveryRoutes() {
  ModuleNavigationRegistry.registerModuleRoutes(
    ModuleId.delivery,
    [
      ModuleRouteDefinition(
        route: GoRoute(
          path: AppRoutes.deliveryAddress,
          builder: (context, state) => const DeliveryAddressScreen(),
        ),
        moduleId: ModuleId.delivery,
        accessLevel: ModuleAccessLevel.client,
        isMainRoute: true,
      ),
      ModuleRouteDefinition(
        route: GoRoute(
          path: AppRoutes.deliveryArea,
          builder: (context, state) => const DeliveryAreaSelectorScreen(),
        ),
        moduleId: ModuleId.delivery,
        accessLevel: ModuleAccessLevel.client,
      ),
      ModuleRouteDefinition(
        route: GoRoute(
          path: '/order/:id/tracking',
          builder: (context, state) {
            // Validate order data
            if (state.extra is! Order) {
              return const Scaffold(
                body: Center(
                  child: Text('Commande introuvable'),
                ),
              );
            }
            final order = state.extra as Order;
            return DeliveryTrackingScreen(order: order);
          },
        ),
        moduleId: ModuleId.delivery,
        accessLevel: ModuleAccessLevel.client,
      ),
    ],
  );
}

/// Register kitchen tablet module routes.
void _registerKitchenRoutes() {
  ModuleNavigationRegistry.registerModuleRoutes(
    ModuleId.kitchen_tablet,
    [
      ModuleRouteDefinition(
        route: GoRoute(
          path: AppRoutes.kitchen,
          name: 'kitchen',
          builder: (context, state) => const KitchenScreen(),
        ),
        moduleId: ModuleId.kitchen_tablet,
        accessLevel: ModuleAccessLevel.kitchen,
        isMainRoute: true,
      ),
    ],
  );
}

/// Register staff tablet (POS/Caisse) module routes.
void _registerStaffTabletRoutes() {
  ModuleNavigationRegistry.registerModuleRoutes(
    ModuleId.staff_tablet,
    [
      ModuleRouteDefinition(
        route: GoRoute(
          path: AppRoutes.pos,
          name: 'pos',
          builder: (context, state) => const PosScreen(),
        ),
        moduleId: ModuleId.staff_tablet,
        accessLevel: ModuleAccessLevel.admin,
        isMainRoute: true,
      ),
      ModuleRouteDefinition(
        route: GoRoute(
          path: AppRoutes.staffTabletPin,
          builder: (context, state) => const StaffTabletPinScreen(),
        ),
        moduleId: ModuleId.staff_tablet,
        accessLevel: ModuleAccessLevel.admin,
      ),
      ModuleRouteDefinition(
        route: GoRoute(
          path: AppRoutes.staffTabletCatalog,
          builder: (context, state) => const StaffTabletCatalogScreen(),
        ),
        moduleId: ModuleId.staff_tablet,
        accessLevel: ModuleAccessLevel.admin,
      ),
      ModuleRouteDefinition(
        route: GoRoute(
          path: AppRoutes.staffTabletCheckout,
          builder: (context, state) => const StaffTabletCheckoutScreen(),
        ),
        moduleId: ModuleId.staff_tablet,
        accessLevel: ModuleAccessLevel.admin,
      ),
      ModuleRouteDefinition(
        route: GoRoute(
          path: AppRoutes.staffTabletHistory,
          builder: (context, state) => const StaffTabletHistoryScreen(),
        ),
        moduleId: ModuleId.staff_tablet,
        accessLevel: ModuleAccessLevel.admin,
      ),
    ],
  );
}
