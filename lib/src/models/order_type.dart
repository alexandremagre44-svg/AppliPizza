// lib/src/models/order_type.dart
/// 
/// Order type enumeration for POS
library;

/// Order type for delivery/service mode
class OrderType {
  /// Dine-in / Sur place
  static const String dineIn = 'dine_in';
  
  /// Takeaway / À emporter
  static const String takeaway = 'takeaway';
  
  /// Delivery / Livraison
  static const String delivery = 'delivery';
  
  /// Click & Collect
  static const String clickCollect = 'click_collect';
  
  /// All available order types
  static List<String> get all => [dineIn, takeaway, delivery, clickCollect];
  
  /// Get display label
  static String getLabel(String type) {
    switch (type) {
      case dineIn:
        return 'Sur place';
      case takeaway:
        return 'À emporter';
      case delivery:
        return 'Livraison';
      case clickCollect:
        return 'Click & Collect';
      default:
        return type;
    }
  }
  
  /// Get icon
  static String getIcon(String type) {
    switch (type) {
      case dineIn:
        return 'restaurant';
      case takeaway:
        return 'shopping_bag';
      case delivery:
        return 'delivery_dining';
      case clickCollect:
        return 'store';
      default:
        return 'shopping_cart';
    }
  }
}
