/// lib/src/services/order_type_validator.dart
///
/// Service de validation des types de commande basé sur ModuleGate.
///
/// Ce service assure que les commandes ne peuvent être créées que si
/// le type de commande est autorisé par la configuration du restaurant.
library;

import '../../white_label/runtime/module_gate.dart';
import '../../white_label/core/module_id.dart';
import '../models/order.dart';

/// Exception levée quand un type de commande n'est pas autorisé.
class OrderTypeNotAllowedException implements Exception {
  final String orderType;
  final String message;

  OrderTypeNotAllowedException(this.orderType)
      : message =
            'Le type de commande "$orderType" n\'est pas autorisé pour ce restaurant.';

  @override
  String toString() => 'OrderTypeNotAllowedException: $message';
}

/// Exception levée quand les données obligatoires sont manquantes.
class OrderValidationException implements Exception {
  final String orderType;
  final String field;
  final String message;

  OrderValidationException({
    required this.orderType,
    required this.field,
  }) : message = 'Champ obligatoire manquant pour $orderType: $field';

  @override
  String toString() => 'OrderValidationException: $message';
}

/// Service de validation des types de commande.
///
/// Utilise ModuleGate pour déterminer si un type de commande est autorisé.
/// Valide également les données obligatoires selon le type de commande.
class OrderTypeValidator {
  final ModuleGate gate;

  const OrderTypeValidator(this.gate);

  /// Valide qu'un type de commande est autorisé.
  ///
  /// Lance [OrderTypeNotAllowedException] si le type n'est pas autorisé.
  void validateOrderType(String orderType) {
    if (!gate.isOrderTypeAllowed(orderType)) {
      throw OrderTypeNotAllowedException(orderType);
    }
  }

  /// Valide une commande complète avec ses données.
  ///
  /// Vérifie:
  /// 1. Que le type de commande est autorisé
  /// 2. Que les données obligatoires sont présentes
  ///
  /// Lance une exception si la validation échoue.
  void validateOrder(Order order, String orderType) {
    // 1. Vérifier que le type est autorisé
    validateOrderType(orderType);

    // 2. Valider les données spécifiques selon le type
    switch (orderType) {
      case 'delivery':
        _validateDeliveryOrder(order);
        break;
      case 'click_collect':
        _validateClickAndCollectOrder(order);
        break;
      case 'dine_in':
      case 'takeaway':
        // Services de base - pas de validation spécifique requise
        break;
      default:
        throw OrderTypeNotAllowedException(orderType);
    }
  }

  /// Valide les données d'une commande de livraison.
  void _validateDeliveryOrder(Order order) {
    if (order.deliveryMode != 'delivery') {
      throw OrderValidationException(
        orderType: 'delivery',
        field: 'deliveryMode',
      );
    }

    if (order.deliveryAddress == null) {
      throw OrderValidationException(
        orderType: 'delivery',
        field: 'deliveryAddress',
      );
    }

    final address = order.deliveryAddress!;
    if (address.address.isEmpty) {
      throw OrderValidationException(
        orderType: 'delivery',
        field: 'deliveryAddress.address',
      );
    }

    if (address.postalCode.isEmpty) {
      throw OrderValidationException(
        orderType: 'delivery',
        field: 'deliveryAddress.postalCode',
      );
    }

    // Validation du téléphone pour contact livreur
    if (order.customerPhone == null || order.customerPhone!.isEmpty) {
      throw OrderValidationException(
        orderType: 'delivery',
        field: 'customerPhone',
      );
    }
  }

  /// Valide les données d'une commande Click & Collect.
  void _validateClickAndCollectOrder(Order order) {
    // Pour Click & Collect, on nécessite:
    // - Une date de retrait
    // - Un créneau horaire
    // - Un nom client

    if (order.pickupDate == null || order.pickupDate!.isEmpty) {
      throw OrderValidationException(
        orderType: 'click_collect',
        field: 'pickupDate',
      );
    }

    if (order.pickupTimeSlot == null || order.pickupTimeSlot!.isEmpty) {
      throw OrderValidationException(
        orderType: 'click_collect',
        field: 'pickupTimeSlot',
      );
    }

    if (order.customerName == null || order.customerName!.isEmpty) {
      throw OrderValidationException(
        orderType: 'click_collect',
        field: 'customerName',
      );
    }

    // Téléphone recommandé pour Click & Collect
    if (order.customerPhone == null || order.customerPhone!.isEmpty) {
      throw OrderValidationException(
        orderType: 'click_collect',
        field: 'customerPhone',
      );
    }
  }

  /// Vérifie si un type de commande est autorisé (version non-throwing).
  ///
  /// Retourne true si le type est autorisé, false sinon.
  /// Utile pour les vérifications UI sans gestion d'exceptions.
  bool isOrderTypeAllowed(String orderType) {
    return gate.isOrderTypeAllowed(orderType);
  }

  /// Retourne la liste des types de commande autorisés.
  List<String> getAllowedOrderTypes() {
    return gate.allowedOrderTypes();
  }

  /// Vérifie si les modules nécessaires sont activés.
  bool isDeliveryEnabled() => gate.isModuleEnabled(ModuleId.delivery);
  bool isClickAndCollectEnabled() =>
      gate.isModuleEnabled(ModuleId.clickAndCollect);
}
