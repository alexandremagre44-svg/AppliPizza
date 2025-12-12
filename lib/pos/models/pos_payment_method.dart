/// POS Payment Method - defines the payment method used for a POS order
/// 
/// This model represents the different payment methods available
/// in the POS system.
library;

/// Payment method types
enum PosPaymentMethod {
  /// Cash payment
  cash,
  
  /// Credit/debit card payment
  card,
  
  /// Other payment method
  other,
}

/// Extension to get display properties for payment methods
extension PosPaymentMethodX on PosPaymentMethod {
  /// Get display label for the payment method
  String get label {
    switch (this) {
      case PosPaymentMethod.cash:
        return 'Espèces';
      case PosPaymentMethod.card:
        return 'Carte bancaire';
      case PosPaymentMethod.other:
        return 'Autre';
    }
  }
  
  /// Get code for the payment method
  String get code {
    switch (this) {
      case PosPaymentMethod.cash:
        return 'cash';
      case PosPaymentMethod.card:
        return 'card';
      case PosPaymentMethod.other:
        return 'other';
    }
  }
  
  /// Create from code
  static PosPaymentMethod fromCode(String code) {
    switch (code) {
      case 'cash':
        return PosPaymentMethod.cash;
      case 'card':
        return PosPaymentMethod.card;
      case 'other':
        return PosPaymentMethod.other;
      default:
        return PosPaymentMethod.cash;
    }
  }
}
