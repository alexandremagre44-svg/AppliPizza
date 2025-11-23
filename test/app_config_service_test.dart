// Test for AppConfigService migration functionality
// This test validates the V2 to B3 migration logic

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza_clean/src/models/app_config.dart';
import 'package:pizza_delizza_clean/src/models/page_schema.dart';

void main() {
  group('B3 Migration Tests', () {
    test('PageSchema should have correct structure for home_b3', () {
      final homePage = PageSchema.homeB3();
      
      expect(homePage.id, equals('home_b3'));
      expect(homePage.name, equals('Accueil B3'));
      expect(homePage.route, equals('/home-b3'));
      expect(homePage.enabled, isTrue);
      expect(homePage.blocks, isNotEmpty);
      expect(homePage.blocks.length, greaterThan(0));
    });

    test('PageSchema should have correct structure for menu_b3', () {
      final menuPage = PageSchema.menuB3();
      
      expect(menuPage.id, equals('menu_b3'));
      expect(menuPage.name, equals('Menu B3'));
      expect(menuPage.route, equals('/menu-b3'));
      expect(menuPage.enabled, isTrue);
      expect(menuPage.blocks, isNotEmpty);
    });

    test('PageSchema should have correct structure for categories_b3', () {
      final categoriesPage = PageSchema.categoriesB3();
      
      expect(categoriesPage.id, equals('categories_b3'));
      expect(categoriesPage.name, equals('Catégories B3'));
      expect(categoriesPage.route, equals('/categories-b3'));
      expect(categoriesPage.enabled, isTrue);
      expect(categoriesPage.blocks, isNotEmpty);
    });

    test('PageSchema should have correct structure for cart_b3', () {
      final cartPage = PageSchema.cartB3();
      
      expect(cartPage.id, equals('cart_b3'));
      expect(cartPage.name, equals('Panier B3'));
      expect(cartPage.route, equals('/cart-b3'));
      expect(cartPage.enabled, isTrue);
      expect(cartPage.blocks, isNotEmpty);
    });

    test('PagesConfig.initial should create all 4 mandatory pages', () {
      final pagesConfig = PagesConfig.initial();
      
      expect(pagesConfig.pages.length, equals(4));
      
      final homeB3 = pagesConfig.findById('home_b3');
      expect(homeB3, isNotNull);
      expect(homeB3?.route, equals('/home-b3'));
      
      final menuB3 = pagesConfig.findById('menu_b3');
      expect(menuB3, isNotNull);
      expect(menuB3?.route, equals('/menu-b3'));
      
      final categoriesB3 = pagesConfig.findById('categories_b3');
      expect(categoriesB3, isNotNull);
      expect(categoriesB3?.route, equals('/categories-b3'));
      
      final cartB3 = pagesConfig.findById('cart_b3');
      expect(cartB3, isNotNull);
      expect(cartB3?.route, equals('/cart-b3'));
    });

    test('WidgetBlock types should match expected mappings', () {
      final homePage = PageSchema.homeB3();
      
      // Check for hero block
      final heroBlock = homePage.blocks.firstWhere(
        (block) => block.type == WidgetBlockType.heroAdvanced,
        orElse: () => throw Exception('Hero block not found'),
      );
      expect(heroBlock.properties['title'], isNotNull);
      expect(heroBlock.properties['subtitle'], isNotNull);
      
      // Check for promo banner block
      final promoBlock = homePage.blocks.firstWhere(
        (block) => block.type == WidgetBlockType.promoBanner,
        orElse: () => throw Exception('Promo banner block not found'),
      );
      expect(promoBlock.properties['title'], isNotNull);
      
      // Check for product slider block
      final productSliderBlock = homePage.blocks.firstWhere(
        (block) => block.type == WidgetBlockType.productSlider,
        orElse: () => throw Exception('Product slider block not found'),
      );
      expect(productSliderBlock.dataSource, isNotNull);
      expect(productSliderBlock.dataSource?.type, equals(DataSourceType.products));
    });

    test('AppConfig.initial should include B3 pages', () {
      final config = AppConfig.initial(appId: 'test_app');
      
      expect(config.pages, isNotNull);
      expect(config.pages.pages.length, equals(4));
      expect(config.version, equals(1));
    });

    test('WidgetBlock should serialize and deserialize correctly', () {
      final block = WidgetBlock(
        id: 'test_block',
        type: WidgetBlockType.heroAdvanced,
        order: 1,
        visible: true,
        properties: {
          'title': 'Test Title',
          'subtitle': 'Test Subtitle',
        },
        dataSource: DataSource(
          id: 'test_source',
          type: DataSourceType.products,
          config: {'category': 'pizza'},
        ),
      );

      final json = block.toJson();
      final deserializedBlock = WidgetBlock.fromJson(json);

      expect(deserializedBlock.id, equals(block.id));
      expect(deserializedBlock.type, equals(block.type));
      expect(deserializedBlock.order, equals(block.order));
      expect(deserializedBlock.visible, equals(block.visible));
      expect(deserializedBlock.properties['title'], equals('Test Title'));
      expect(deserializedBlock.dataSource?.type, equals(DataSourceType.products));
    });

    test('PageSchema should serialize and deserialize correctly', () {
      final page = PageSchema(
        id: 'test_page',
        name: 'Test Page',
        route: '/test',
        enabled: true,
        blocks: [
          WidgetBlock(
            id: 'block_1',
            type: WidgetBlockType.text,
            order: 1,
            visible: true,
            properties: {'text': 'Hello'},
          ),
        ],
        metadata: {'version': 1},
      );

      final json = page.toJson();
      final deserializedPage = PageSchema.fromJson(json);

      expect(deserializedPage.id, equals(page.id));
      expect(deserializedPage.name, equals(page.name));
      expect(deserializedPage.route, equals(page.route));
      expect(deserializedPage.enabled, equals(page.enabled));
      expect(deserializedPage.blocks.length, equals(1));
      expect(deserializedPage.metadata?['version'], equals(1));
    });

    test('HomeSectionType conversion should work correctly', () {
      expect(HomeSectionType.hero.value, equals('hero'));
      expect(HomeSectionType.promoBanner.value, equals('promo_banner'));
      expect(HomeSectionType.popup.value, equals('popup'));
      
      expect(HomeSectionType.fromString('hero'), equals(HomeSectionType.hero));
      expect(HomeSectionType.fromString('promo_banner'), equals(HomeSectionType.promoBanner));
      expect(HomeSectionType.fromString('invalid'), equals(HomeSectionType.custom));
    });

    test('WidgetBlockType conversion should work correctly', () {
      expect(WidgetBlockType.heroAdvanced.value, equals('hero_advanced'));
      expect(WidgetBlockType.promoBanner.value, equals('promo_banner'));
      expect(WidgetBlockType.productList.value, equals('product_list'));
      expect(WidgetBlockType.categoryList.value, equals('category_list'));
      
      expect(WidgetBlockType.fromString('hero_advanced'), equals(WidgetBlockType.heroAdvanced));
      expect(WidgetBlockType.fromString('promo_banner'), equals(WidgetBlockType.promoBanner));
      expect(WidgetBlockType.fromString('invalid'), equals(WidgetBlockType.custom));
    });
  });
}
