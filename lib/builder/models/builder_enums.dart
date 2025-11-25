// lib/builder/models/builder_enums.dart
// Enums for Builder B3 system

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

  /// Get BuilderPageId from string value
  static BuilderPageId fromString(String value) {
    return BuilderPageId.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BuilderPageId.home,
    );
  }

  /// Convert to JSON
  String toJson() => value;

  /// Create from JSON
  static BuilderPageId fromJson(String json) => fromString(json);
  
  /// List of system page IDs that cannot be manually created
  static const List<String> systemPageIds = ['profile', 'cart', 'rewards', 'roulette'];
  
  /// Check if this is a system page
  bool get isSystemPage => systemPageIds.contains(value);
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
  system('system', 'Module Système', '⚙️');

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
