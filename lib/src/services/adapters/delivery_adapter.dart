/// lib/src/services/adapters/delivery_adapter.dart
///
/// Adapter non-intrusif pour le service de livraison.
///
/// Lit la configuration depuis RestaurantPlanUnified et adapte
/// le comportement sans modifier les services de livraison existants.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../white_label/restaurant/restaurant_plan_unified.dart';
import '../../../white_label/modules/core/delivery/delivery_module_config.dart';
import '../../../white_label/modules/core/delivery/delivery_settings.dart';
import '../../providers/restaurant_plan_provider.dart';

/// Adapter pour le module de livraison.
///
/// Fournit un accès à la configuration de livraison depuis le plan unifié.
class DeliveryAdapter {
  final WidgetRef ref;

  DeliveryAdapter(this.ref);

  /// Vérifie si le module de livraison est activé.
  bool get isEnabled {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    
    if (plan == null) return false;
    
    return plan.delivery?.enabled ?? false;
  }

  /// Récupère la configuration du module de livraison.
  DeliveryModuleConfig? get config {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    
    return plan?.delivery;
  }

  /// Récupère les paramètres de livraison.
  DeliverySettings? get settings {
    return config?.settings;
  }

  /// Applique les paramètres du plan unifié aux services existants.
  ///
  /// Cette méthode configure les services sans les modifier directement.
  void apply() {
    if (!isEnabled) {
      // Module désactivé, pas d'action
      return;
    }

    // Les services existants continuent de fonctionner
    // Cette méthode sert de hook pour les adaptations futures
  }
}

/// Provider pour l'adapter de livraison.
final deliveryAdapterProvider = Provider<DeliveryAdapter>((ref) {
  return DeliveryAdapter(ref);
});
