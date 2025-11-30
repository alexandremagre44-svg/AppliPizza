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
  /// Returns Icons.layers as fallback if icon not found (default for custom pages).
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
      'dashboard': Icons.dashboard,
      'dashboard_outlined': Icons.dashboard_outlined,
      'explore': Icons.explore,
      'explore_outlined': Icons.explore_outlined,
      'search': Icons.search,
      'list': Icons.list,
      'grid_view': Icons.grid_view,
      'layers': Icons.layers,
      'layers_outlined': Icons.layers_outlined,
      
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
      'notifications': Icons.notifications,
      'notifications_outlined': Icons.notifications_outlined,
      'bookmark': Icons.bookmark,
      'bookmark_outlined': Icons.bookmark_outline,
      'thumb_up': Icons.thumb_up,
      'thumb_up_outlined': Icons.thumb_up_outlined,
      'share': Icons.share,
      'share_outlined': Icons.share_outlined,
      'send': Icons.send,
      'send_outlined': Icons.send_outlined,
      'add_circle': Icons.add_circle,
      'add_circle_outlined': Icons.add_circle_outline,
      
      // Food & Restaurant icons
      'local_pizza': Icons.local_pizza,
      'local_pizza_outlined': Icons.local_pizza_outlined,
      'fastfood': Icons.fastfood,
      'fastfood_outlined': Icons.fastfood_outlined,
      'restaurant': Icons.restaurant,
      'restaurant_outlined': Icons.restaurant_outlined,
      'local_dining': Icons.local_dining,
      'local_dining_outlined': Icons.local_dining_outlined,
      'local_cafe': Icons.local_cafe,
      'local_cafe_outlined': Icons.local_cafe_outlined,
      'local_bar': Icons.local_bar,
      'local_bar_outlined': Icons.local_bar_outlined,
      'cake': Icons.cake,
      'cake_outlined': Icons.cake_outlined,
      
      // Commerce icons
      'shopping_bag': Icons.shopping_bag,
      'shopping_bag_outlined': Icons.shopping_bag_outlined,
      'store': Icons.store,
      'store_outlined': Icons.store_outlined,
      'local_offer': Icons.local_offer,
      'local_offer_outlined': Icons.local_offer_outlined,
      'discount': Icons.discount,
      'discount_outlined': Icons.discount_outlined,
      'card_giftcard': Icons.card_giftcard,
      'card_giftcard_outlined': Icons.card_giftcard_outlined,
      'loyalty': Icons.loyalty,
      'loyalty_outlined': Icons.loyalty_outlined,
      'payments': Icons.payments,
      'payments_outlined': Icons.payments_outlined,
      
      // Content icons
      'article': Icons.article,
      'article_outlined': Icons.article_outlined,
      'photo': Icons.photo,
      'photo_outlined': Icons.photo_outlined,
      'videocam': Icons.videocam,
      'videocam_outlined': Icons.videocam_outlined,
      'event': Icons.event,
      'event_outlined': Icons.event_outlined,
      'campaign': Icons.campaign,
      'campaign_outlined': Icons.campaign_outlined,
      'announcement': Icons.announcement,
      'announcement_outlined': Icons.announcement_outlined,
      
      // Contact & About
      'group': Icons.group,
      'group_outlined': Icons.group_outlined,
      'contact_page': Icons.contact_page,
      'contact_page_outlined': Icons.contact_page_outlined,
      'phone': Icons.phone,
      'phone_outlined': Icons.phone_outlined,
      'email': Icons.email,
      'email_outlined': Icons.email_outlined,
      'location_on': Icons.location_on,
      'location_on_outlined': Icons.location_on_outlined,
      'schedule': Icons.schedule,
      'schedule_outlined': Icons.schedule_outlined,
      'chat': Icons.chat,
      'chat_outlined': Icons.chat_outlined,
      
      // Misc icons
      'casino': Icons.casino,
      'casino_outlined': Icons.casino_outlined,
      'emoji_events': Icons.emoji_events,
      'emoji_events_outlined': Icons.emoji_events_outlined,
      'celebration': Icons.celebration,
      'celebration_outlined': Icons.celebration_outlined,
      'flash_on': Icons.flash_on,
      'flash_on_outlined': Icons.flash_on_outlined,
      'new_releases': Icons.new_releases,
      'new_releases_outlined': Icons.new_releases_outlined,
      'trending_up': Icons.trending_up,
      'trending_up_outlined': Icons.trending_up_outlined,
      'verified': Icons.verified,
      'verified_outlined': Icons.verified_outlined,
      'workspace_premium': Icons.workspace_premium,
      'workspace_premium_outlined': Icons.workspace_premium_outlined,
      
      // Other
      'category': Icons.category,
      'category_outlined': Icons.category_outlined,
    };
    
    // Normalize icon name (lowercase, trim)
    final normalizedName = iconName.toLowerCase().trim();
    
    // Return icon from map or fallback to layers (default for custom pages)
    return iconMap[normalizedName] ?? Icons.layers;
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
    if (outlined == Icons.layers && filled != Icons.layers) {
      return (filled, filled);
    }
    
    return (outlined, filled);
  }
}
