/// lib/src/providers/restaurant_plan_provider.dart
///
/// Providers Riverpod pour exposer le RestaurantPlan et les feature flags
/// au runtime client.
///
/// Ces providers sont prêts à être consommés en Phase C2.
/// Pour l'instant, ils ne sont PAS utilisés dans l'UI.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../white_label/core/module_id.dart';
import '../../white_label/modules/core/delivery/delivery_settings.dart';
import '../../white_label/restaurant/restaurant_feature_flags.dart';
import '../../white_label/restaurant/restaurant_plan.dart';
import '../services/restaurant_plan_runtime_service.dart';
import 'restaurant_provider.dart';

/// Provider pour le service RestaurantPlanRuntimeService.
final restaurantPlanRuntimeServiceProvider =
    Provider<RestaurantPlanRuntimeService>((ref) {
  return RestaurantPlanRuntimeService();
});

/// Provider pour charger le RestaurantPlan du restaurant courant.
///
/// Utilise [currentRestaurantProvider] pour déterminer quel restaurant charger.
/// Retourne null si pas de restaurantId ou si le plan n'existe pas.
final restaurantPlanProvider = FutureProvider<RestaurantPlan?>((ref) async {
  final service = ref.watch(restaurantPlanRuntimeServiceProvider);
  final restaurantConfig = ref.watch(currentRestaurantProvider);

  final restaurantId = restaurantConfig.id;
  if (restaurantId.isEmpty) return null;

  return service.loadPlan(restaurantId);
});

/// Provider dérivé pour les feature flags du restaurant courant.
///
/// Permet de vérifier rapidement si un module est activé:
/// ```dart
/// final flags = ref.watch(restaurantFeatureFlagsProvider);
/// if (flags?.has(ModuleId.delivery) ?? false) {
///   // Module livraison activé
/// }
/// ```
final restaurantFeatureFlagsProvider =
    Provider<RestaurantFeatureFlags?>((ref) {
  final planAsync = ref.watch(restaurantPlanProvider);

  return planAsync.maybeWhen(
    data: (plan) => plan != null
        ? RestaurantFeatureFlags.fromModules(plan.restaurantId, plan.modules)
        : null,
    orElse: () => null,
  );
});

/// Provider pour les paramètres de livraison du restaurant courant.
///
/// Retourne null si:
/// - Le plan n'est pas chargé
/// - Le module delivery n'existe pas
/// - Le module delivery n'est pas activé
///
/// Exemple d'utilisation (Phase C2):
/// ```dart
/// final settings = ref.watch(deliverySettingsProvider);
/// if (settings != null) {
///   final minOrder = settings.minimumOrderAmount;
///   final fee = settings.deliveryFee;
/// }
/// ```
final deliverySettingsProvider = Provider<DeliverySettings?>((ref) {
  final planAsync = ref.watch(restaurantPlanProvider);
  final plan = planAsync.asData?.value;

  if (plan == null) return null;

  final config = plan.getModuleConfig(ModuleId.delivery);
  if (config == null || !config.enabled) return null;

  // Reconstruire DeliverySettings à partir de config.settings
  return DeliverySettings.fromJson(
    Map<String, dynamic>.from(config.settings),
  );
});

/// Provider pour vérifier si le module de livraison est activé.
///
/// Shortcut pratique pour les vérifications rapides.
final isDeliveryEnabledProvider = Provider<bool>((ref) {
  final flags = ref.watch(restaurantFeatureFlagsProvider);
  return flags?.has(ModuleId.delivery) ?? false;
});

/// Provider pour vérifier si le module Click & Collect est activé.
///
/// Shortcut pratique pour les vérifications rapides.
final isClickAndCollectEnabledProvider = Provider<bool>((ref) {
  final flags = ref.watch(restaurantFeatureFlagsProvider);
  return flags?.has(ModuleId.clickAndCollect) ?? false;
});
