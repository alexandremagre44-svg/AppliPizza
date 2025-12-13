/// lib/src/providers/order_type_validator_provider.dart
///
/// Provider pour le service de validation des types de commande.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../white_label/runtime/module_gate_provider.dart';
import '../services/order_type_validator.dart';

/// Provider pour le service OrderTypeValidator.
///
/// Crée un validateur basé sur le ModuleGate courant.
///
/// Usage:
/// ```dart
/// final validator = ref.watch(orderTypeValidatorProvider);
/// validator.validateOrderType('delivery');
/// ```
final orderTypeValidatorProvider = Provider<OrderTypeValidator>(
  (ref) {
    final gate = ref.watch(moduleGateProvider);
    return OrderTypeValidator(gate);
  },
  dependencies: [moduleGateProvider],
);

/// Provider strict pour le service OrderTypeValidator.
///
/// Utilise le ModuleGate strict (refuse tout quand plan absent).
final strictOrderTypeValidatorProvider = Provider<OrderTypeValidator>(
  (ref) {
    final gate = ref.watch(strictModuleGateProvider);
    return OrderTypeValidator(gate);
  },
  dependencies: [strictModuleGateProvider],
);
