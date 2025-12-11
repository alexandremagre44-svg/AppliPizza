/// POS Cart Item - represents an item in the POS cart
/// 
/// This model extends the concept of a cart item specifically for POS usage,
/// with support for customizations and menu items.
library;

/// POS Cart Item model
class PosCartItem {
  /// Unique identifier for this cart item
  final String id;
  
  /// Product ID from the catalog
  final String productId;
  
  /// Product name
  final String productName;
  
  /// Unit price
  final double price;
  
  /// Quantity
  int quantity;
  
  /// Product image URL
  final String imageUrl;
  
  /// Custom description (e.g., "Sans oignons", "Pizza personnalisée")
  final String? customDescription;
  
  /// Whether this is a menu item
  final bool isMenu;
  
  /// Sub-items for menu composition
  final List<PosCartItem>? menuItems;
  
  PosCartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl = '',
    this.customDescription,
    this.isMenu = false,
    this.menuItems,
  });
  
  /// Calculate total price for this item
  double get total => price * quantity;
  
  /// Create a copy with modified fields
  PosCartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? imageUrl,
    String? customDescription,
    bool? isMenu,
    List<PosCartItem>? menuItems,
  }) {
    return PosCartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      customDescription: customDescription ?? this.customDescription,
      isMenu: isMenu ?? this.isMenu,
      menuItems: menuItems ?? this.menuItems,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'customDescription': customDescription,
      'isMenu': isMenu,
      'menuItems': menuItems?.map((item) => item.toJson()).toList(),
    };
  }
  
  /// Create from JSON
  factory PosCartItem.fromJson(Map<String, dynamic> json) {
    return PosCartItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String? ?? '',
      customDescription: json['customDescription'] as String?,
      isMenu: json['isMenu'] as bool? ?? false,
      menuItems: (json['menuItems'] as List<dynamic>?)
          ?.map((item) => PosCartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
