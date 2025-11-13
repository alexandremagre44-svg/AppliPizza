// Test pour les modèles HomeConfig, HeroConfig, PromoBannerConfig, ContentBlock
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/home_config.dart';

void main() {
  group('HomeConfig Model Tests', () {
    test('HomeConfig.initial() devrait créer une config par défaut', () {
      final config = HomeConfig.initial();

      expect(config.id, 'main');
      expect(config.hero, isNotNull);
      expect(config.promoBanner, isNotNull);
      expect(config.blocks, isEmpty);
    });

    test('HomeConfig toJson devrait sérialiser correctement', () {
      final config = HomeConfig(
        id: 'main',
        hero: HeroConfig(
          isActive: true,
          imageUrl: 'https://test.com/hero.jpg',
          title: 'Bienvenue',
          subtitle: 'Découvrez nos pizzas',
          ctaText: 'Voir le menu',
          ctaAction: '/menu',
        ),
        promoBanner: PromoBannerConfig(
          isActive: true,
          text: 'Promo -20%',
          backgroundColor: '#D32F2F',
          textColor: '#FFFFFF',
        ),
        blocks: [
          ContentBlock(
            id: 'block1',
            type: 'featuredProducts',
            title: 'Nos spécialités',
            maxItems: 6,
            order: 0,
          ),
        ],
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = config.toJson();

      expect(json['id'], 'main');
      expect(json['hero'], isNotNull);
      expect(json['promoBanner'], isNotNull);
      expect(json['blocks'], isA<List>());
      expect(json['blocks'].length, 1);
      expect(json['updatedAt'], isA<String>());
    });

    test('HomeConfig fromJson devrait désérialiser correctement', () {
      final json = {
        'id': 'main',
        'hero': {
          'isActive': true,
          'imageUrl': 'https://test.com/hero.jpg',
          'title': 'Bienvenue',
          'subtitle': 'Découvrez nos pizzas',
          'ctaText': 'Voir le menu',
          'ctaAction': '/menu',
        },
        'promoBanner': {
          'isActive': true,
          'text': 'Promo -20%',
          'backgroundColor': '#D32F2F',
          'textColor': '#FFFFFF',
        },
        'blocks': [
          {
            'id': 'block1',
            'type': 'featuredProducts',
            'title': 'Nos spécialités',
            'maxItems': 6,
            'order': 0,
            'isActive': true,
          },
        ],
        'updatedAt': '2024-01-01T00:00:00.000',
      };

      final config = HomeConfig.fromJson(json);

      expect(config.id, 'main');
      expect(config.hero, isNotNull);
      expect(config.hero!.title, 'Bienvenue');
      expect(config.promoBanner, isNotNull);
      expect(config.promoBanner!.text, 'Promo -20%');
      expect(config.blocks.length, 1);
      expect(config.blocks[0].title, 'Nos spécialités');
    });

    test('HomeConfig copyWith devrait créer une copie avec modifications', () {
      final config = HomeConfig(
        id: 'main',
        blocks: [],
        updatedAt: DateTime(2024, 1, 1),
      );

      final updatedConfig = config.copyWith(
        blocks: [
          ContentBlock(
            id: 'new-block',
            type: 'bestSellers',
            title: 'Best-sellers',
          ),
        ],
      );

      expect(updatedConfig.id, 'main');
      expect(updatedConfig.blocks.length, 1);
      expect(updatedConfig.blocks[0].title, 'Best-sellers');
    });
  });

  group('HeroConfig Tests', () {
    test('HeroConfig toJson devrait sérialiser correctement', () {
      final hero = HeroConfig(
        isActive: true,
        imageUrl: 'https://test.com/hero.jpg',
        title: 'Bienvenue',
        subtitle: 'Découvrez nos pizzas',
        ctaText: 'Voir le menu',
        ctaAction: '/menu',
      );

      final json = hero.toJson();

      expect(json['isActive'], true);
      expect(json['imageUrl'], 'https://test.com/hero.jpg');
      expect(json['title'], 'Bienvenue');
      expect(json['subtitle'], 'Découvrez nos pizzas');
      expect(json['ctaText'], 'Voir le menu');
      expect(json['ctaAction'], '/menu');
    });

    test('HeroConfig fromJson devrait désérialiser correctement', () {
      final json = {
        'isActive': true,
        'imageUrl': 'https://test.com/hero.jpg',
        'title': 'Bienvenue',
        'subtitle': 'Découvrez nos pizzas',
        'ctaText': 'Voir le menu',
        'ctaAction': '/menu',
      };

      final hero = HeroConfig.fromJson(json);

      expect(hero.isActive, true);
      expect(hero.imageUrl, 'https://test.com/hero.jpg');
      expect(hero.title, 'Bienvenue');
      expect(hero.subtitle, 'Découvrez nos pizzas');
      expect(hero.ctaText, 'Voir le menu');
      expect(hero.ctaAction, '/menu');
    });

    test('HeroConfig copyWith devrait créer une copie avec modifications', () {
      final hero = HeroConfig(
        isActive: false,
        imageUrl: '',
        title: 'Titre original',
        subtitle: '',
        ctaText: '',
        ctaAction: '',
      );

      final updated = hero.copyWith(
        isActive: true,
        title: 'Nouveau titre',
      );

      expect(updated.isActive, true);
      expect(updated.title, 'Nouveau titre');
      expect(updated.imageUrl, ''); // Unchanged
    });
  });

  group('PromoBannerConfig Tests', () {
    test('PromoBannerConfig toJson devrait sérialiser correctement', () {
      final banner = PromoBannerConfig(
        isActive: true,
        text: 'Promo -20%',
        backgroundColor: '#D32F2F',
        textColor: '#FFFFFF',
      );

      final json = banner.toJson();

      expect(json['isActive'], true);
      expect(json['text'], 'Promo -20%');
      expect(json['backgroundColor'], '#D32F2F');
      expect(json['textColor'], '#FFFFFF');
    });

    test('PromoBannerConfig fromJson devrait désérialiser correctement', () {
      final json = {
        'isActive': true,
        'text': 'Promo -20%',
        'backgroundColor': '#D32F2F',
        'textColor': '#FFFFFF',
      };

      final banner = PromoBannerConfig.fromJson(json);

      expect(banner.isActive, true);
      expect(banner.text, 'Promo -20%');
      expect(banner.backgroundColor, '#D32F2F');
      expect(banner.textColor, '#FFFFFF');
    });

    test('isCurrentlyActive devrait retourner false si isActive est false', () {
      final banner = PromoBannerConfig(
        isActive: false,
        text: 'Promo',
      );

      expect(banner.isCurrentlyActive, false);
    });

    test('isCurrentlyActive devrait retourner true si dans la période', () {
      final now = DateTime.now();
      final banner = PromoBannerConfig(
        isActive: true,
        text: 'Promo',
        startDate: now.subtract(Duration(days: 1)),
        endDate: now.add(Duration(days: 1)),
      );

      expect(banner.isCurrentlyActive, true);
    });

    test('isCurrentlyActive devrait retourner false si avant startDate', () {
      final now = DateTime.now();
      final banner = PromoBannerConfig(
        isActive: true,
        text: 'Promo',
        startDate: now.add(Duration(days: 1)),
      );

      expect(banner.isCurrentlyActive, false);
    });

    test('isCurrentlyActive devrait retourner false si après endDate', () {
      final now = DateTime.now();
      final banner = PromoBannerConfig(
        isActive: true,
        text: 'Promo',
        endDate: now.subtract(Duration(days: 1)),
      );

      expect(banner.isCurrentlyActive, false);
    });
  });

  group('ContentBlock Tests', () {
    test('ContentBlock toJson devrait sérialiser correctement', () {
      final block = ContentBlock(
        id: 'block1',
        type: 'featuredProducts',
        title: 'Nos spécialités',
        content: 'Description',
        productIds: ['p1', 'p2'],
        maxItems: 6,
        isActive: true,
        order: 0,
      );

      final json = block.toJson();

      expect(json['id'], 'block1');
      expect(json['type'], 'featuredProducts');
      expect(json['title'], 'Nos spécialités');
      expect(json['content'], 'Description');
      expect(json['productIds'], ['p1', 'p2']);
      expect(json['maxItems'], 6);
      expect(json['isActive'], true);
      expect(json['order'], 0);
    });

    test('ContentBlock fromJson devrait désérialiser correctement', () {
      final json = {
        'id': 'block1',
        'type': 'featuredProducts',
        'title': 'Nos spécialités',
        'content': 'Description',
        'productIds': ['p1', 'p2'],
        'maxItems': 6,
        'isActive': true,
        'order': 0,
      };

      final block = ContentBlock.fromJson(json);

      expect(block.id, 'block1');
      expect(block.type, 'featuredProducts');
      expect(block.title, 'Nos spécialités');
      expect(block.content, 'Description');
      expect(block.productIds, ['p1', 'p2']);
      expect(block.maxItems, 6);
      expect(block.isActive, true);
      expect(block.order, 0);
    });

    test('ContentBlock copyWith devrait créer une copie avec modifications', () {
      final block = ContentBlock(
        id: 'block1',
        type: 'featuredProducts',
        title: 'Titre original',
      );

      final updated = block.copyWith(
        title: 'Nouveau titre',
        maxItems: 8,
      );

      expect(updated.id, 'block1');
      expect(updated.type, 'featuredProducts');
      expect(updated.title, 'Nouveau titre');
      expect(updated.maxItems, 8);
    });
  });

  group('ColorConverter Tests', () {
    test('hexToColor devrait convertir un hex en Color', () {
      final colorValue = ColorConverter.hexToColor('#FF0000');
      
      expect(colorValue, isNotNull);
      // FF (alpha) + FF0000 (rouge) = 0xFFFF0000
      expect(colorValue, 0xFFFF0000);
    });

    test('hexToColor sans # devrait fonctionner', () {
      final colorValue = ColorConverter.hexToColor('FF0000');
      
      expect(colorValue, isNotNull);
      expect(colorValue, 0xFFFF0000);
    });

    test('hexToColor avec alpha devrait fonctionner', () {
      final colorValue = ColorConverter.hexToColor('#80FF0000');
      
      expect(colorValue, isNotNull);
      expect(colorValue, 0x80FF0000);
    });

    test('hexToColor avec valeur invalide devrait retourner null', () {
      final colorValue = ColorConverter.hexToColor('invalid');
      
      expect(colorValue, isNull);
    });

    test('hexToColor avec null devrait retourner null', () {
      final colorValue = ColorConverter.hexToColor(null);
      
      expect(colorValue, isNull);
    });

    test('colorToHex devrait convertir Color en hex avec alpha', () {
      final hex = ColorConverter.colorToHex(0xFFFF0000);
      
      expect(hex, '#FFFF0000');
    });

    test('colorToHexWithoutAlpha devrait convertir Color en hex sans alpha', () {
      final hex = ColorConverter.colorToHexWithoutAlpha(0xFFFF0000);
      
      expect(hex, '#FF0000');
    });
  });
}
