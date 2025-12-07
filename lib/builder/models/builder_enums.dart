// lib/builder/models/builder_enums.dart
// Enums for Builder B3 system

import 'system_pages.dart';

/// Page identifiers for different app pages
/// 
/// Extensible enum for multi-page support.
/// Each page represents a distinct section of the app.
enum BuilderPageId {
  /// Main landing page
  home('home', 'Accueil'),
  
  /// Menu/product catalog page
  menu('menu', 'Menu'),
  
  /// Promotions page
  promo('promo', 'Promotions'),
  
  /// About us page
  about('about', 'À propos'),
  
  /// Contact page
  contact('contact', 'Contact'),
  
  // ==================== SYSTEM PAGES ====================
  
  /// User profile page (system page)
  profile('profile', 'Profil'),
  
  /// Shopping cart page (system page)
  cart('cart', 'Panier'),
  
  /// Rewards page (system page)
  rewards('rewards', 'Récompenses'),
  
  /// Roulette game page (system page)
  roulette('roulette', 'Roulette');

  const BuilderPageId(this.value, this.label);
  
  final String value;
  final String label;

  /// Get BuilderPageId from string value (nullable)
  /// 
  /// Returns null if the value doesn't match any known system page.
  /// This allows custom pages to be handled properly without forcing
  /// them to fallback to home.
  static BuilderPageId? tryFromString(String value) {
    final found = BuilderPageId.values.where((e) => e.value == value);
    if (found.isNotEmpty) {
      return found.first;
    }
    return null;
  }

  /// Get BuilderPageId from string value
  /// 
  /// @deprecated Use [tryFromString] instead for safe nullable result.
  /// 
  /// IMPORTANT: Throws [FormatException] if the value doesn't match
  /// any known pageId. This prevents unknown pages from silently falling
  /// back to home (which would cause page context mismatch).
  /// 
  /// Use [tryFromString] for safe fallback to null instead.
  /// 
  /// Throws: [FormatException] if value is not a known page ID
  static BuilderPageId fromString(String value) {
    final found = tryFromString(value);
    if (found != null) {
      return found;
    }
    throw FormatException(
      'Unknown page ID: $value. Use BuilderPageId.tryFromString for nullable result.',
    );
  }

  /// Convert to JSON
  String toJson() => value;

  /// Create from JSON (nullable version for custom pages)
  /// Returns null if the value doesn't match a known system page
  static BuilderPageId? tryFromJson(String json) => tryFromString(json);

  /// Create from JSON
  /// 
  /// @deprecated Use [tryFromJson] instead for safe nullable result.
  /// 
  /// Throws: [FormatException] if value is not a known page ID
  static BuilderPageId fromJson(String json) => fromString(json);
  
  /// List of known page IDs for the Builder system
  /// 
  /// This list includes all BuilderPageId values:
  /// - home, menu, promo, about, contact (content pages, isSystemPage: false)
  /// - profile, cart, rewards, roulette (protected functional pages, isSystemPage: true)
  /// 
  /// Note: The isSystemPage property is determined by the SystemPages registry,
  /// not by membership in this list. This list is primarily used for ID validation.
  static const List<String> systemPageIds = [
    'home',
    'menu', 
    'promo',
    'about',
    'contact',
    'profile',
    'cart',
    'rewards',
    'roulette',
  ];
  
  /// Check if this is a protected system page
  /// 
  /// FIX M3: Aligned with SystemPages registry to use a single source of truth.
  /// This getter now delegates to SystemPages.isSystemPage() when the config exists.
  /// 
  /// Protected system pages (cart, profile, rewards, roulette) return true.
  /// Content pages (home, menu, promo, about, contact) return false per SystemPages config.
  /// 
  /// Note: "protected" means the page cannot be deleted and its pageId cannot be changed.
  bool get isSystemPage {
    // Check if this page is in the SystemPages registry
    final config = SystemPages.getConfig(this);
    if (config != null) {
      return config.isSystemPage;
    }
    // All BuilderPageId values should be in the registry
    // If not found, default to false (not protected)
    return false;
  }
}

/// Block types for different content components
/// 
/// Extensible enum for modular block system.
/// Each block type has specific rendering and configuration.
enum BlockType {
  /// Hero banner with image and CTA
  hero('hero', 'Hero Banner', '🖼️'),
  
  /// Promotional banner
  banner('banner', 'Bannière', '🎨'),
  
  /// Text content block
  text('text', 'Texte', '📝'),
  
  /// Product listing/grid
  productList('product_list', 'Liste Produits', '🍕'),
  
  /// Information/notice block
  info('info', 'Information', 'ℹ️'),
  
  /// Spacer for layout
  spacer('spacer', 'Espaceur', '⬜'),
  
  /// Image block
  image('image', 'Image', '🖼️'),
  
  /// Button/CTA block
  button('button', 'Bouton', '🔘'),
  
  /// Category navigation
  categoryList('category_list', 'Catégories', '📂'),
  
  /// Custom HTML block
  html('html', 'HTML Personnalisé', '💻'),
  
  /// System module block (non-configurable, positionable modules)
  system('system', 'Module Système', '⚙️'),
  
  /// Module block (White-Label modules with admin/client separation)
  module('module', 'Module WL', '🔌');

  const BlockType(this.value, this.label, this.icon);
  
  final String value;
  final String label;
  final String icon;

  /// Get BlockType from string value
  static BlockType fromString(String value) {
    return BlockType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BlockType.text,
    );
  }

  /// Convert to JSON
  String toJson() => value;

  /// Create from JSON
  static BlockType fromJson(String json) => fromString(json);
}

/// Block alignment options
enum BlockAlignment {
  left('left', 'Gauche'),
  center('center', 'Centre'),
  right('right', 'Droite');

  const BlockAlignment(this.value, this.label);
  
  final String value;
  final String label;

  static BlockAlignment fromString(String value) {
    return BlockAlignment.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BlockAlignment.left,
    );
  }

  String toJson() => value;
  static BlockAlignment fromJson(String json) => fromString(json);
}

/// Block visibility options
enum BlockVisibility {
  /// Always visible
  visible('visible', 'Visible'),
  
  /// Hidden
  hidden('hidden', 'Masqué'),
  
  /// Visible only on mobile
  mobileOnly('mobile_only', 'Mobile uniquement'),
  
  /// Visible only on desktop
  desktopOnly('desktop_only', 'Desktop uniquement');

  const BlockVisibility(this.value, this.label);
  
  final String value;
  final String label;

  static BlockVisibility fromString(String value) {
    return BlockVisibility.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BlockVisibility.visible,
    );
  }

  String toJson() => value;
  static BlockVisibility fromJson(String json) => fromString(json);
}

/// Page type enum for distinguishing templates from blank pages
/// 
/// Used to identify the origin/type of a page:
/// - template: Created from a predefined template (template A)
/// - blank: Created as an empty page (template B)
/// - system: System page (profile, cart, rewards, roulette)
/// - custom: Custom page created by user
enum BuilderPageType {
  /// Page created from a predefined template
  template('template', 'Template'),
  
  /// Blank/empty page
  blank('blank', 'Page Vierge'),
  
  /// System page (profile, cart, rewards, roulette)
  system('system', 'Page Système'),
  
  /// Custom page created by user
  custom('custom', 'Page Personnalisée');

  const BuilderPageType(this.value, this.label);
  
  final String value;
  final String label;

  static BuilderPageType fromString(String value) {
    return BuilderPageType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BuilderPageType.custom,
    );
  }

  String toJson() => value;
  static BuilderPageType fromJson(String json) => fromString(json);
}
