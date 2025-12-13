/// lib/src/services/guarded_order_service.dart
///
/// Service wrapper that adds order type validation based on ModuleGate.
///
/// This service wraps existing order services (POS, Customer) and ensures
/// that order types are validated before creation.
library;

import '../models/order.dart';
import 'order_type_validator.dart';

/// Mixin for order services that need order type validation.
///
/// Add this mixin to any service that creates orders to automatically
/// get validation capabilities via OrderTypeValidator.
mixin OrderTypeValidation {
  /// The validator to use for order type checks.
  OrderTypeValidator get validator;

  /// Validates an order before creation.
  ///
  /// This should be called at the beginning of any order creation method.
  /// Throws appropriate exceptions if validation fails.
  ///
  /// Usage:
  /// ```dart
  /// Future<String> createOrder(..., String orderType) async {
  ///   validateOrderBeforeCreation(order, orderType);
  ///   // Proceed with creation
  /// }
  /// ```
  void validateOrderBeforeCreation(Order order, String orderType) {
    validator.validateOrder(order, orderType);
  }

  /// Checks if an order type is allowed (non-throwing).
  ///
  /// Use this for UI checks or to provide user feedback.
  bool isOrderTypeAllowed(String orderType) {
    return validator.isOrderTypeAllowed(orderType);
  }

  /// Gets the list of allowed order types.
  List<String> getAllowedOrderTypes() {
    return validator.getAllowedOrderTypes();
  }
}

/// Helper class to wrap validation results.
class OrderValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? errorField;

  const OrderValidationResult({
    required this.isValid,
    this.errorMessage,
    this.errorField,
  });

  factory OrderValidationResult.valid() {
    return const OrderValidationResult(isValid: true);
  }

  factory OrderValidationResult.invalid({
    required String message,
    String? field,
  }) {
    return OrderValidationResult(
      isValid: false,
      errorMessage: message,
      errorField: field,
    );
  }

  @override
  String toString() {
    if (isValid) return 'OrderValidationResult(valid)';
    return 'OrderValidationResult(invalid: $errorMessage${errorField != null ? " [field: $errorField]" : ""})';
  }
}

/// Extension methods for easier validation in services.
extension OrderTypeValidationExtension on OrderTypeValidator {
  /// Validates an order and returns a result instead of throwing.
  ///
  /// Useful for UI validation where you want to display errors
  /// without exception handling.
  OrderValidationResult validateOrderSafe(Order order, String orderType) {
    try {
      validateOrder(order, orderType);
      return OrderValidationResult.valid();
    } on OrderTypeNotAllowedException catch (e) {
      return OrderValidationResult.invalid(
        message: e.message,
        field: 'orderType',
      );
    } on OrderValidationException catch (e) {
      return OrderValidationResult.invalid(
        message: e.message,
        field: e.field,
      );
    } catch (e) {
      return OrderValidationResult.invalid(
        message: 'Erreur de validation: $e',
      );
    }
  }
}
