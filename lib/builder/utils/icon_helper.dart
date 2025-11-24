// lib/builder/utils/icon_helper.dart
// Utility to convert icon name strings to IconData

import 'package:flutter/material.dart';

/// Helpers class for icon utilities
class IconHelper {
  /// Convert icon name string to IconData
  /// 
  /// Supports Material Icons by name.
  /// Examples: 'home', 'menu', 'shopping_cart', 'person'
  /// 
  /// Returns Icons.help_outline as fallback if icon not found.
  static IconData iconFromName(String iconName) {
    // Map of common icon names to their IconData
    final iconMap = <String, IconData>{
      // Navigation icons
      'home': Icons.home,
      'home_outlined': Icons.home_outlined,
      'menu': Icons.restaurant_menu,
      'restaurant_menu': Icons.restaurant_menu,
      'restaurant_menu_outlined': Icons.restaurant_menu_outlined,
      'shopping_cart': Icons.shopping_cart,
      'shopping_cart_outlined': Icons.shopping_cart_outlined,
      'person': Icons.person,
      'person_outlined': Icons.person_outline,
      'profile': Icons.person,
      
      // Admin icons
      'admin_panel_settings': Icons.admin_panel_settings,
      'admin_panel_settings_outlined': Icons.admin_panel_settings_outlined,
      'settings': Icons.settings,
      'settings_outlined': Icons.settings_outlined,
      
      // Common icons
      'help_outline': Icons.help_outline,
      'help': Icons.help,
      'info': Icons.info,
      'info_outlined': Icons.info_outline,
      'star': Icons.star,
      'star_outlined': Icons.star_outline,
      'favorite': Icons.favorite,
      'favorite_outlined': Icons.favorite_outline,
      'search': Icons.search,
      'notifications': Icons.notifications,
      'notifications_outlined': Icons.notifications_outlined,
      
      // Food & Restaurant icons
      'local_pizza': Icons.local_pizza,
      'local_pizza_outlined': Icons.local_pizza_outlined,
      'fastfood': Icons.fastfood,
      'restaurant': Icons.restaurant,
      'local_dining': Icons.local_dining,
      
      // Promotion & Offers
      'local_offer': Icons.local_offer,
      'local_offer_outlined': Icons.local_offer_outlined,
      'card_giftcard': Icons.card_giftcard,
      'card_giftcard_outlined': Icons.card_giftcard_outlined,
      'discount': Icons.discount,
      'discount_outlined': Icons.discount_outlined,
      
      // Contact & About
      'contact_page': Icons.contact_page,
      'contact_page_outlined': Icons.contact_page_outlined,
      'phone': Icons.phone,
      'phone_outlined': Icons.phone_outlined,
      'email': Icons.email,
      'email_outlined': Icons.email_outlined,
      
      // Other
      'dashboard': Icons.dashboard,
      'list': Icons.list,
      'grid_view': Icons.grid_view,
      'category': Icons.category,
      'category_outlined': Icons.category_outlined,
    };
    
    // Normalize icon name (lowercase, trim)
    final normalizedName = iconName.toLowerCase().trim();
    
    // Return icon from map or fallback
    return iconMap[normalizedName] ?? Icons.help_outline;
  }
  
  /// Get both outlined and filled versions of an icon
  /// Returns a tuple: (outlined, filled)
  /// 
  /// Attempts to find both outlined and filled versions.
  /// If outlined version doesn't exist, uses the filled version for both.
  static (IconData, IconData) getIconPair(String iconName) {
    // Normalize icon name
    final normalizedName = iconName.toLowerCase().trim();
    
    // Try to get outlined version first
    final outlinedName = normalizedName.endsWith('_outlined') 
        ? normalizedName 
        : '${normalizedName}_outlined';
    
    // Try to get filled version
    final filledName = normalizedName.replaceAll('_outlined', '');
    
    // Get the icons - if outlined doesn't exist, both will be the filled version
    final outlined = iconFromName(outlinedName);
    final filled = iconFromName(filledName);
    
    // If outlined is fallback but filled is not, use filled for both
    if (outlined == Icons.help_outline && filled != Icons.help_outline) {
      return (filled, filled);
    }
    
    return (outlined, filled);
  }
}
