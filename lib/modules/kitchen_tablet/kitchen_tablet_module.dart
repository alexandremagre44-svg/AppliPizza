// lib/modules/kitchen_tablet/kitchen_tablet_module.dart

import '../../white_label/core/module_id.dart';
import '../../white_label/restaurant/restaurant_plan_unified.dart';

/// Module Tablette Cuisine
///
/// Module isolé pour l'interface professionnelle de cuisine sur tablette.
/// Accessible uniquement via route directe `/kitchen`.
class KitchenTabletModule {
  /// Route du module
  static const route = '/kitchen';

  /// Identifiant du module
  static const moduleId = ModuleId.kitchen_tablet;

  /// Vérifie si le module est activé pour un restaurant
  static bool isEnabled(RestaurantPlanUnified plan) =>
      plan.activeModules.contains('kitchen_tablet');
}
