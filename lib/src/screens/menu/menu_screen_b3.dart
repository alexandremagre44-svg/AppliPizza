// lib/src/screens/menu/menu_screen_b3.dart
// Test screen for B3 dynamic page architecture
// Demonstrates rendering a page from PageSchema

import 'package:flutter/material.dart';
import '../../models/page_schema.dart';
import '../../widgets/page_renderer.dart';

/// Test screen for B3 dynamic menu page
class MenuScreenB3 extends StatelessWidget {
  const MenuScreenB3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a sample PageSchema for testing
    final pageSchema = _createSamplePageSchema();
    
    return PageRenderer(pageSchema: pageSchema);
  }

  /// Create a sample PageSchema for demonstration
  PageSchema _createSamplePageSchema() {
    return PageSchema(
      id: 'menu_b3_test',
      name: 'Menu B3 - Test',
      route: '/menu-b3',
      enabled: true,
      blocks: [
        // Hero banner
        WidgetBlock(
          id: 'banner_1',
          type: WidgetBlockType.banner,
          order: 1,
          visible: true,
          properties: {
            'text': '🍕 Menu Dynamique B3',
          },
          styling: {
            'backgroundColor': '#D62828',
            'textColor': '#FFFFFF',
            'padding': 16.0,
          },
        ),
        
        // Welcome text
        WidgetBlock(
          id: 'text_1',
          type: WidgetBlockType.text,
          order: 2,
          visible: true,
          properties: {
            'text': 'Bienvenue sur notre menu dynamique !',
            'fontSize': 24.0,
            'bold': true,
            'align': 'center',
          },
          styling: {
            'padding': {
              'top': 24.0,
              'bottom': 8.0,
              'left': 16.0,
              'right': 16.0,
            },
          },
        ),
        
        // Description text
        WidgetBlock(
          id: 'text_2',
          type: WidgetBlockType.text,
          order: 3,
          visible: true,
          properties: {
            'text': 'Cette page est générée dynamiquement à partir d\'un schéma JSON. '
                    'Aucune modification du code Flutter n\'est nécessaire pour changer le contenu.',
            'fontSize': 16.0,
            'align': 'center',
          },
          styling: {
            'color': '#666666',
            'padding': {
              'top': 0.0,
              'bottom': 24.0,
              'left': 16.0,
              'right': 16.0,
            },
          },
        ),
        
        // Sample image
        WidgetBlock(
          id: 'image_1',
          type: WidgetBlockType.image,
          order: 4,
          visible: true,
          properties: {
            'url': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800',
            'height': 250.0,
            'fit': 'cover',
          },
          styling: {
            'padding': 16.0,
          },
        ),
        
        // Product list placeholder
        WidgetBlock(
          id: 'products_1',
          type: WidgetBlockType.productList,
          order: 5,
          visible: true,
          properties: {
            'title': 'Nos Pizzas',
          },
          dataSource: DataSource(
            id: 'pizzas',
            type: DataSourceType.products,
            config: {
              'category': 'pizza',
              'limit': 10,
            },
          ),
          styling: {
            'padding': 8.0,
          },
        ),
        
        // Category list placeholder
        WidgetBlock(
          id: 'categories_1',
          type: WidgetBlockType.categoryList,
          order: 6,
          visible: true,
          properties: {
            'title': 'Catégories',
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
        
        // CTA button
        WidgetBlock(
          id: 'button_1',
          type: WidgetBlockType.button,
          order: 7,
          visible: true,
          properties: {
            'label': 'Commander maintenant',
          },
          actions: {
            'onTap': 'navigate:/cart',
          },
          styling: {
            'backgroundColor': '#D62828',
            'textColor': '#FFFFFF',
            'padding': 16.0,
          },
        ),
        
        // Info text
        WidgetBlock(
          id: 'text_3',
          type: WidgetBlockType.text,
          order: 8,
          visible: true,
          properties: {
            'text': 'Architecture B3 - Phase 1\n'
                    'Cette page démontre le système de pages dynamiques.\n'
                    'Les DataSources (produits, catégories) seront connectés en Phase 2.',
            'fontSize': 14.0,
            'align': 'center',
          },
          styling: {
            'color': '#999999',
            'padding': {
              'top': 24.0,
              'bottom': 24.0,
              'left': 16.0,
              'right': 16.0,
            },
          },
        ),
      ],
      metadata: {
        'version': 1,
        'description': 'Page de test pour l\'architecture B3',
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }
}
