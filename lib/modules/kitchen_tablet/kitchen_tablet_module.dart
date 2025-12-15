// lib/modules/kitchen_tablet/kitchen_tablet_module.dart

import '../../white_label/core/module_id.dart';
import '../../white_label/restaurant/restaurant_plan_unified.dart';

/// Module Tablette Cuisine (Part of POS)
///
/// Kitchen display is now an internal component of the POS module.
/// Accessible uniquement via route directe `/kitchen` when POS is enabled.
/// 
/// @deprecated Kitchen tablet is now part of ModuleId.pos. Use ModuleId.pos instead.
class KitchenTabletModule {
  /// Route du module
  static const route = '/kitchen';

  /// Identifiant du module - now uses POS module ID
  static const moduleId = ModuleId.pos;

  /// Vérifie si le module est activé pour un restaurant
  /// Kitchen display requires POS module to be enabled
  static bool isEnabled(RestaurantPlanUnified plan) =>
      plan.activeModules.contains('pos');
}
