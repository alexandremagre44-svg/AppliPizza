/// lib/src/services/adapters/loyalty_adapter.dart
///
/// Adapter non-intrusif pour le service de fidélité.
///
/// Lit la configuration depuis RestaurantPlanUnified et adapte
/// le comportement sans modifier loyalty_service.dart.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../white_label/restaurant/restaurant_plan_unified.dart';
import '../../../white_label/modules/marketing/loyalty/loyalty_module_config.dart';
import '../../providers/restaurant_plan_provider.dart';

/// Adapter pour le module de fidélité.
///
/// Fournit un accès à la configuration de fidélité depuis le plan unifié.
class LoyaltyAdapter {
  final WidgetRef ref;

  LoyaltyAdapter(this.ref);

  /// Vérifie si le module de fidélité est activé.
  bool get isEnabled {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    
    if (plan == null) return false;
    
    return plan.loyalty?.enabled ?? false;
  }

  /// Récupère la configuration du module de fidélité.
  LoyaltyModuleConfig? get config {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    
    return plan?.loyalty;
  }

  /// Récupère les paramètres de fidélité.
  Map<String, dynamic>? get settings {
    return config?.settings;
  }

  /// Active ou désactive le module (pour usage administratif uniquement).
  ///
  /// Note: Cette méthode ne modifie PAS le service existant.
  /// Elle met à jour uniquement la configuration dans le plan unifié.
  Future<void> setEnabled(bool enabled) async {
    // TODO: Implémenter la mise à jour via le service SuperAdmin
    // Ne pas modifier loyalty_service.dart
    throw UnimplementedError('Mise à jour via SuperAdmin uniquement');
  }

  /// Applique les paramètres du plan unifié au service de fidélité existant.
  ///
  /// Cette méthode configure le service sans le modifier directement.
  void apply() {
    if (!isEnabled) {
      // Module désactivé, pas d'action
      return;
    }

    // Les services existants continuent de fonctionner
    // Cette méthode sert de hook pour les adaptations futures
  }
}

/// Provider pour l'adapter de fidélité.
final loyaltyAdapterProvider = Provider<LoyaltyAdapter>((ref) {
  return LoyaltyAdapter(ref);
});
