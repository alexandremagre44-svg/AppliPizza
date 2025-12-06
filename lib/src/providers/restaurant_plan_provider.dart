/// lib/src/providers/restaurant_plan_provider.dart
///
/// Providers Riverpod pour exposer le RestaurantPlan et les feature flags
/// au runtime client.
///
/// Ces providers sont prêts à être consommés en Phase C2.
/// Pour l'instant, ils ne sont PAS utilisés dans l'UI.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../white_label/core/module_id.dart';
import '../../white_label/modules/core/delivery/delivery_module_config.dart';
import '../../white_label/modules/core/delivery/delivery_settings.dart';
import '../../white_label/modules/core/ordering/ordering_module_config.dart';
import '../../white_label/modules/marketing/loyalty/loyalty_module_config.dart';
import '../../white_label/modules/marketing/promotions/promotions_module_config.dart';
import '../../white_label/modules/marketing/roulette/roulette_module_config.dart';
import '../../white_label/restaurant/restaurant_feature_flags.dart';
import '../../white_label/restaurant/restaurant_plan.dart';
import '../../white_label/restaurant/restaurant_plan_unified.dart';
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
final restaurantPlanProvider = FutureProvider<RestaurantPlan?>(
  (ref) async {
    final service = ref.watch(restaurantPlanRuntimeServiceProvider);
    final restaurantConfig = ref.watch(currentRestaurantProvider);

    final restaurantId = restaurantConfig.id;
    if (restaurantId.isEmpty) return null;

    return service.loadPlan(restaurantId);
  },
  dependencies: [currentRestaurantProvider],
);

/// Provider pour charger le RestaurantPlanUnified du restaurant courant.
///
/// Utilise [currentRestaurantProvider] pour déterminer quel restaurant charger.
/// Retourne null si pas de restaurantId ou si le plan n'existe pas.
/// 
/// Ce provider remplace progressivement [restaurantPlanProvider] pour utiliser
/// le nouveau modèle unifié.
final restaurantPlanUnifiedProvider = FutureProvider<RestaurantPlanUnified?>(
  (ref) async {
    final service = ref.watch(restaurantPlanRuntimeServiceProvider);
    final restaurantConfig = ref.watch(currentRestaurantProvider);

    final restaurantId = restaurantConfig.id;
    if (restaurantId.isEmpty) return null;

    return service.loadUnifiedPlan(restaurantId);
  },
  dependencies: [currentRestaurantProvider],
);

/// Provider dérivé pour les feature flags du restaurant courant (version unifiée).
///
/// Permet de vérifier rapidement si un module est activé à partir du plan unifié:
/// ```dart
/// final flags = ref.watch(restaurantFeatureFlagsUnifiedProvider);
/// if (flags?.has(ModuleId.delivery) ?? false) {
///   // Module livraison activé
/// }
/// ```
/// 
/// IMPORTANT: C'est le SEUL endroit où RestaurantFeatureFlags doit être instancié.
/// RestaurantFeatureFlags est maintenant un proxy vers RestaurantPlanUnified.
final restaurantFeatureFlagsUnifiedProvider =
    Provider<RestaurantFeatureFlags?>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);

    return planAsync.maybeWhen(
      data: (plan) => plan != null ? RestaurantFeatureFlags(plan) : null,
      orElse: () => null,
    );
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Provider dérivé pour les feature flags du restaurant courant.
///
/// DEPRECATED: Utilisez [restaurantFeatureFlagsUnifiedProvider] à la place.
/// 
/// Ce provider est maintenant un alias vers le provider unifié pour assurer
/// la rétrocompatibilité. RestaurantPlanUnified est la source unique de vérité.
///
/// Permet de vérifier rapidement si un module est activé:
/// ```dart
/// final flags = ref.watch(restaurantFeatureFlagsProvider);
/// if (flags?.has(ModuleId.delivery) ?? false) {
///   // Module livraison activé
/// }
/// ```
final restaurantFeatureFlagsProvider =
    Provider<RestaurantFeatureFlags?>(
  (ref) {
    // Délègue vers le provider unifié (source unique de vérité)
    return ref.watch(restaurantFeatureFlagsUnifiedProvider);
  },
  dependencies: [restaurantFeatureFlagsUnifiedProvider],
);

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
final deliverySettingsProvider = Provider<DeliverySettings?>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanProvider);
    final plan = planAsync.asData?.value;

    if (plan == null) return null;

    final config = plan.getModuleConfig(ModuleId.delivery);
    if (config == null || !config.enabled) return null;

    // Reconstruire DeliverySettings à partir de config.settings
    return DeliverySettings.fromJson(
      Map<String, dynamic>.from(config.settings),
    );
  },
  dependencies: [restaurantPlanProvider],
);

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

/// Provider pour les paramètres de livraison depuis le plan unifié.
///
/// Retourne null si:
/// - Le plan unifié n'est pas chargé
/// - Le module delivery n'existe pas dans le plan
///
/// Exemple d'utilisation:
/// ```dart
/// final deliveryConfig = ref.watch(deliveryConfigUnifiedProvider);
/// if (deliveryConfig != null && deliveryConfig.enabled) {
///   final settings = deliveryConfig.settings;
///   // Utiliser les settings
/// }
/// ```
final deliveryConfigUnifiedProvider = Provider<DeliveryModuleConfig?>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    if (plan == null) return null;

    return plan.delivery;
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Provider pour vérifier si le module de livraison est activé (version unifiée).
///
/// Shortcut pratique pour les vérifications rapides.
final isDeliveryEnabledUnifiedProvider = Provider<bool>((ref) {
  final config = ref.watch(deliveryConfigUnifiedProvider);
  return config?.enabled ?? false;
});

/// Provider pour les paramètres de commande depuis le plan unifié.
final orderingConfigUnifiedProvider = Provider<OrderingModuleConfig?>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    if (plan == null) return null;

    return plan.ordering;
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Provider pour les paramètres de fidélité depuis le plan unifié.
final loyaltyConfigUnifiedProvider = Provider<LoyaltyModuleConfig?>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    if (plan == null) return null;

    return plan.loyalty;
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Provider pour vérifier si le module fidélité est activé (version unifiée).
final isLoyaltyEnabledUnifiedProvider = Provider<bool>((ref) {
  final config = ref.watch(loyaltyConfigUnifiedProvider);
  return config?.enabled ?? false;
});

/// Provider pour les paramètres de roulette depuis le plan unifié.
final rouletteConfigUnifiedProvider = Provider<RouletteModuleConfig?>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    if (plan == null) return null;

    return plan.roulette;
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Provider pour vérifier si le module roulette est activé (version unifiée).
final isRouletteEnabledUnifiedProvider = Provider<bool>((ref) {
  final config = ref.watch(rouletteConfigUnifiedProvider);
  return config?.enabled ?? false;
});

/// Provider pour les paramètres de promotions depuis le plan unifié.
final promotionsConfigUnifiedProvider = Provider<PromotionsModuleConfig?>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    if (plan == null) return null;

    return plan.promotions;
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Provider pour vérifier si le module promotions est activé (version unifiée).
final isPromotionsEnabledUnifiedProvider = Provider<bool>((ref) {
  final config = ref.watch(promotionsConfigUnifiedProvider);
  return config?.enabled ?? false;
});

/// Provider pour le branding depuis le plan unifié.
final brandingConfigUnifiedProvider = Provider<BrandingConfig?>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    if (plan == null) return null;

    return plan.branding;
  },
  dependencies: [restaurantPlanUnifiedProvider],
);
