// lib/src/models/page_schema.dart
// Dynamic page schema models for B3 architecture
// This allows building pages dynamically from JSON configurations

/// Enum for widget block types
enum WidgetBlockType {
  text('text'),
  image('image'),
  button('button'),
  productList('product_list'),
  categoryList('category_list'),
  banner('banner'),
  heroAdvanced('hero_advanced'), // B3.5.A: Advanced hero block with image, overlay, gradient, CTAs
  custom('custom');

  const WidgetBlockType(this.value);
  final String value;

  static WidgetBlockType fromString(String value) {
    return WidgetBlockType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WidgetBlockType.custom,
    );
  }
}

/// Enum for data source types
enum DataSourceType {
  static('static'),
  products('products'),
  categories('categories'),
  firestore('firestore'),
  api('api');

  const DataSourceType(this.value);
  final String value;

  static DataSourceType fromString(String value) {
    return DataSourceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DataSourceType.static,
    );
  }
}

/// Data source configuration for widget blocks
class DataSource {
  final String id;
  final DataSourceType type;
  final Map<String, dynamic> config;

  DataSource({
    required this.id,
    required this.type,
    required this.config,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'config': config,
    };
  }

  factory DataSource.fromJson(Map<String, dynamic> json) {
    return DataSource(
      id: json['id'] as String,
      type: DataSourceType.fromString(json['type'] as String? ?? 'static'),
      config: json['config'] as Map<String, dynamic>? ?? {},
    );
  }

  DataSource copyWith({
    String? id,
    DataSourceType? type,
    Map<String, dynamic>? config,
  }) {
    return DataSource(
      id: id ?? this.id,
      type: type ?? this.type,
      config: config ?? this.config,
    );
  }
}

/// Widget block configuration for a page
class WidgetBlock {
  final String id;
  final WidgetBlockType type;
  final int order;
  final bool visible;
  final Map<String, dynamic> properties;
  final DataSource? dataSource;
  final Map<String, dynamic>? styling;
  final Map<String, dynamic>? actions;

  WidgetBlock({
    required this.id,
    required this.type,
    required this.order,
    required this.visible,
    required this.properties,
    this.dataSource,
    this.styling,
    this.actions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'order': order,
      'visible': visible,
      'properties': properties,
      'dataSource': dataSource?.toJson(),
      'styling': styling,
      'actions': actions,
    };
  }

  factory WidgetBlock.fromJson(Map<String, dynamic> json) {
    return WidgetBlock(
      id: json['id'] as String,
      type: WidgetBlockType.fromString(json['type'] as String? ?? 'custom'),
      order: json['order'] as int? ?? 0,
      visible: json['visible'] as bool? ?? true,
      properties: json['properties'] as Map<String, dynamic>? ?? {},
      dataSource: json['dataSource'] != null
          ? DataSource.fromJson(json['dataSource'] as Map<String, dynamic>)
          : null,
      styling: json['styling'] as Map<String, dynamic>?,
      actions: json['actions'] as Map<String, dynamic>?,
    );
  }

  WidgetBlock copyWith({
    String? id,
    WidgetBlockType? type,
    int? order,
    bool? visible,
    Map<String, dynamic>? properties,
    DataSource? dataSource,
    Map<String, dynamic>? styling,
    Map<String, dynamic>? actions,
  }) {
    return WidgetBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      order: order ?? this.order,
      visible: visible ?? this.visible,
      properties: properties ?? this.properties,
      dataSource: dataSource ?? this.dataSource,
      styling: styling ?? this.styling,
      actions: actions ?? this.actions,
    );
  }
}

/// Page schema configuration for dynamic pages
class PageSchema {
  final String id;
  final String name;
  final String route;
  final bool enabled;
  final List<WidgetBlock> blocks;
  final Map<String, dynamic>? metadata;

  PageSchema({
    required this.id,
    required this.name,
    required this.route,
    required this.enabled,
    required this.blocks,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'route': route,
      'enabled': enabled,
      'blocks': blocks.map((b) => b.toJson()).toList(),
      'metadata': metadata,
    };
  }

  factory PageSchema.fromJson(Map<String, dynamic> json) {
    return PageSchema(
      id: json['id'] as String,
      name: json['name'] as String,
      route: json['route'] as String,
      enabled: json['enabled'] as bool? ?? true,
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((b) => WidgetBlock.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  PageSchema copyWith({
    String? id,
    String? name,
    String? route,
    bool? enabled,
    List<WidgetBlock>? blocks,
    Map<String, dynamic>? metadata,
  }) {
    return PageSchema(
      id: id ?? this.id,
      name: name ?? this.name,
      route: route ?? this.route,
      enabled: enabled ?? this.enabled,
      blocks: blocks ?? this.blocks,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Configuration for dynamic pages section in AppConfig
class PagesConfig {
  final List<PageSchema> pages;

  PagesConfig({
    required this.pages,
  });

  Map<String, dynamic> toJson() {
    return {
      'pages': pages.map((p) => p.toJson()).toList(),
    };
  }

  factory PagesConfig.fromJson(Map<String, dynamic> json) {
    return PagesConfig(
      pages: (json['pages'] as List<dynamic>?)
              ?.map((p) => PageSchema.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  PagesConfig copyWith({
    List<PageSchema>? pages,
  }) {
    return PagesConfig(
      pages: pages ?? this.pages,
    );
  }

  factory PagesConfig.empty() {
    return PagesConfig(
      pages: [],
    );
  }

  /// Create initial PagesConfig with default B3 pages
  factory PagesConfig.initial() {
    return PagesConfig(
      pages: [
        _createDefaultMenuPage(),
        _createDefaultCategoriesPage(),
        _createDefaultCartPage(),
      ],
    );
  }

  /// Create default menu page
  static PageSchema _createDefaultMenuPage() {
    return PageSchema(
      id: 'menu_b3',
      name: 'Menu B3',
      route: '/menu-b3',
      enabled: true,
      blocks: [
        WidgetBlock(
          id: 'banner_menu',
          type: WidgetBlockType.banner,
          order: 1,
          visible: true,
          properties: {
            'text': '🍕 Notre Menu',
          },
          styling: {
            'backgroundColor': '#D62828',
            'textColor': '#FFFFFF',
            'padding': 16.0,
          },
        ),
        WidgetBlock(
          id: 'title_menu',
          type: WidgetBlockType.text,
          order: 2,
          visible: true,
          properties: {
            'text': 'Découvrez nos pizzas',
            'fontSize': 24.0,
            'bold': true,
            'align': 'center',
          },
          styling: {
            'padding': {'top': 24.0, 'bottom': 16.0, 'left': 16.0, 'right': 16.0},
          },
        ),
        WidgetBlock(
          id: 'products_menu',
          type: WidgetBlockType.productList,
          order: 3,
          visible: true,
          properties: {
            'title': 'Nos Pizzas',
          },
          dataSource: DataSource(
            id: 'all_products',
            type: DataSourceType.products,
            config: {'category': 'pizza'},
          ),
          styling: {
            'padding': 8.0,
          },
        ),
      ],
      metadata: {
        'description': 'Page menu dynamique B3',
        'version': 1,
      },
    );
  }

  /// Create default categories page
  static PageSchema _createDefaultCategoriesPage() {
    return PageSchema(
      id: 'categories_b3',
      name: 'Catégories B3',
      route: '/categories-b3',
      enabled: true,
      blocks: [
        WidgetBlock(
          id: 'banner_categories',
          type: WidgetBlockType.banner,
          order: 1,
          visible: true,
          properties: {
            'text': '📂 Catégories',
          },
          styling: {
            'backgroundColor': '#2E7D32',
            'textColor': '#FFFFFF',
            'padding': 16.0,
          },
        ),
        WidgetBlock(
          id: 'title_categories',
          type: WidgetBlockType.text,
          order: 2,
          visible: true,
          properties: {
            'text': 'Explorez nos catégories',
            'fontSize': 24.0,
            'bold': true,
            'align': 'center',
          },
          styling: {
            'padding': {'top': 24.0, 'bottom': 16.0, 'left': 16.0, 'right': 16.0},
          },
        ),
        WidgetBlock(
          id: 'categories_list',
          type: WidgetBlockType.categoryList,
          order: 3,
          visible: true,
          properties: {
            'title': 'Toutes les catégories',
          },
          dataSource: DataSource(
            id: 'all_categories',
            type: DataSourceType.categories,
            config: {},
          ),
          styling: {
            'padding': 8.0,
          },
        ),
      ],
      metadata: {
        'description': 'Page catégories dynamique B3',
        'version': 1,
      },
    );
  }

  /// Create default cart page
  static PageSchema _createDefaultCartPage() {
    return PageSchema(
      id: 'cart_b3',
      name: 'Panier B3',
      route: '/cart-b3',
      enabled: true,
      blocks: [
        WidgetBlock(
          id: 'banner_cart',
          type: WidgetBlockType.banner,
          order: 1,
          visible: true,
          properties: {
            'text': '🛒 Votre Panier',
          },
          styling: {
            'backgroundColor': '#1976D2',
            'textColor': '#FFFFFF',
            'padding': 16.0,
          },
        ),
        WidgetBlock(
          id: 'empty_cart_message',
          type: WidgetBlockType.text,
          order: 2,
          visible: true,
          properties: {
            'text': 'Votre panier est vide',
            'fontSize': 20.0,
            'bold': true,
            'align': 'center',
          },
          styling: {
            'color': '#666666',
            'padding': {'top': 48.0, 'bottom': 24.0, 'left': 16.0, 'right': 16.0},
          },
        ),
        WidgetBlock(
          id: 'empty_cart_subtitle',
          type: WidgetBlockType.text,
          order: 3,
          visible: true,
          properties: {
            'text': 'Ajoutez des produits depuis notre menu pour commencer votre commande',
            'fontSize': 16.0,
            'align': 'center',
          },
          styling: {
            'color': '#999999',
            'padding': {'top': 0.0, 'bottom': 32.0, 'left': 16.0, 'right': 16.0},
          },
        ),
        WidgetBlock(
          id: 'back_to_menu_button',
          type: WidgetBlockType.button,
          order: 4,
          visible: true,
          properties: {
            'label': 'Retour au menu',
          },
          actions: {
            'onTap': 'navigate:/menu-b3',
          },
          styling: {
            'backgroundColor': '#D62828',
            'textColor': '#FFFFFF',
            'padding': 16.0,
          },
        ),
      ],
      metadata: {
        'description': 'Page panier dynamique B3',
        'version': 1,
      },
    );
  }

  /// Find a page by route
  PageSchema? findByRoute(String route) {
    try {
      return pages.firstWhere(
        (p) => p.route == route && p.enabled,
      );
    } catch (e) {
      return null;
    }
  }

  /// Find a page by id
  PageSchema? findById(String id) {
    try {
      return pages.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a page by route (alias for findByRoute)
  /// 
  /// Convenience method with shorter name for common use case.
  /// Use this when you want to retrieve a page for display.
  /// Returns null if page not found or disabled.
  PageSchema? getPage(String route) {
    return findByRoute(route);
  }

  /// Check if a page exists for a given route
  bool hasPage(String route) {
    return pages.any((p) => p.route == route && p.enabled);
  }
}
