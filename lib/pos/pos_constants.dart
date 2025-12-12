/// POS Constants - Configuration values for the POS system
/// 
/// This file contains configurable constants that can be adjusted
/// per restaurant or deployment.
library;

/// POS Configuration Constants
class PosConstants {
  /// Maximum number of tables available for selection
  /// This should be configured per restaurant
  static const int maxTableCount = 40;
  
  /// Number of columns in the table selector grid
  static const int tableSelectorColumns = 5;
  
  /// Number of columns in the product grid (desktop)
  static const int productGridColumns = 3;
  
  /// Breakpoint for switching between desktop and mobile layouts
  static const double mobileBreakpoint = 800.0;
  
  /// Default currency symbol
  /// TODO: Make this configurable per restaurant
  static const String currencySymbol = '€';
  
  /// Default payment method
  static const String defaultPaymentMethod = 'cash';
  
  /// Maximum items per order
  static const int maxOrderItems = 100;
  
  /// Order submission timeout in seconds
  static const int orderSubmissionTimeout = 30;
}
