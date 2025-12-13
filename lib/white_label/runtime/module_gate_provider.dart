/// lib/white_label/runtime/module_gate_provider.dart
///
/// Providers Riverpod pour exposer ModuleGate au runtime.
///
/// Ces providers permettent d'accéder à la couche de modularité
/// depuis n'importe quel widget ou service de l'application.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../src/providers/restaurant_plan_provider.dart';
import 'module_gate.dart';

/// Provider principal pour ModuleGate.
///
/// Crée une instance de ModuleGate basée sur le plan restaurant courant.
///
/// Usage:
/// ```dart
/// final gate = ref.watch(moduleGateProvider);
/// if (gate.isModuleEnabled(ModuleId.delivery)) {
///   // Module livraison activé
/// }
/// ```
final moduleGateProvider = Provider<ModuleGate>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    return ModuleGate(
      plan: plan,
      allowWhenPlanNull: true,
    );
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Provider strict pour ModuleGate.
///
/// Refuse toutes les opérations quand le plan n'est pas disponible.
/// Utile pour les opérations sensibles nécessitant une configuration explicite.
///
/// Usage:
/// ```dart
/// final gate = ref.watch(strictModuleGateProvider);
/// ```
final strictModuleGateProvider = Provider<ModuleGate>(
  (ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    return ModuleGate(
      plan: plan,
      allowWhenPlanNull: false,
    );
  },
  dependencies: [restaurantPlanUnifiedProvider],
);

/// Provider pour vérifier si un type de commande est autorisé.
///
/// Raccourci pratique pour les vérifications rapides d'un type spécifique.
///
/// Usage:
/// ```dart
/// final isDeliveryAllowed = ref.watch(orderTypeAllowedProvider('delivery'));
/// if (isDeliveryAllowed) {
///   // Afficher l'option livraison
/// }
/// ```
final orderTypeAllowedProvider = Provider.family<bool, String>(
  (ref, orderType) {
    final gate = ref.watch(moduleGateProvider);
    return gate.isOrderTypeAllowed(orderType);
  },
  dependencies: [moduleGateProvider],
);

/// Provider pour obtenir la liste des types de commande autorisés.
///
/// Retourne une liste de codes OrderType basée sur les modules actifs.
///
/// Usage:
/// ```dart
/// final allowedTypes = ref.watch(allowedOrderTypesProvider);
/// for (final type in allowedTypes) {
///   // Construire les boutons de sélection
/// }
/// ```
final allowedOrderTypesProvider = Provider<List<String>>(
  (ref) {
    final gate = ref.watch(moduleGateProvider);
    return gate.allowedOrderTypes();
  },
  dependencies: [moduleGateProvider],
);

/// Extension pour WidgetRef facilitant l'accès au ModuleGate.
extension ModuleGateRefExtension on WidgetRef {
  /// Obtient le ModuleGate depuis ce ref.
  ModuleGate get moduleGate => read(moduleGateProvider);

  /// Obtient le ModuleGate strict depuis ce ref.
  ModuleGate get strictModuleGate => read(strictModuleGateProvider);
}
