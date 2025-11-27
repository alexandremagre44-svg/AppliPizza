// Test for BuilderPage.fromJson parsing safety
// Validates the _safeLayoutParse helper handles edge cases

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/builder/models/builder_page.dart';
import 'package:pizza_delizza/builder/models/builder_block.dart';
import 'package:pizza_delizza/builder/models/builder_enums.dart';

/// Mock Timestamp class to simulate Firestore Timestamp in tests
/// This mimics the structure of cloud_firestore Timestamp
class MockTimestamp {
  final int seconds;
  final int nanoseconds;
  
  MockTimestamp(this.seconds, this.nanoseconds);
  
  DateTime toDate() {
    return DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000 + nanoseconds ~/ 1000000,
    );
  }
}

void main() {
  group('BuilderPage Parsing Tests', () {
    test('fromJson should handle null draftLayout', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
        'draftLayout': null,
        'publishedLayout': null,
      };

      final page = BuilderPage.fromJson(json);
      
      expect(page.draftLayout, isEmpty);
      expect(page.publishedLayout, isEmpty);
    });

    test('fromJson should handle string "none" in draftLayout (legacy data)', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
        'draftLayout': 'none',
        'publishedLayout': 'none',
      };

      // Should not throw, should return empty lists
      final page = BuilderPage.fromJson(json);
      
      expect(page.draftLayout, isEmpty);
      expect(page.publishedLayout, isEmpty);
    });

    test('fromJson should handle empty string in publishedLayout', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
        'draftLayout': '',
        'publishedLayout': '',
      };

      final page = BuilderPage.fromJson(json);
      
      expect(page.draftLayout, isEmpty);
      expect(page.publishedLayout, isEmpty);
    });

    test('fromJson should handle valid block lists', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
        'draftLayout': [
          {
            'id': 'block1',
            'type': 'hero',
            'order': 0,
            'isActive': true,
            'config': {},
          }
        ],
        'publishedLayout': [
          {
            'id': 'block2',
            'type': 'banner',
            'order': 0,
            'isActive': true,
            'config': {},
          }
        ],
      };

      final page = BuilderPage.fromJson(json);
      
      expect(page.draftLayout.length, equals(1));
      expect(page.draftLayout[0].id, equals('block1'));
      expect(page.publishedLayout.length, equals(1));
      expect(page.publishedLayout[0].id, equals('block2'));
    });

    test('fromJson should handle malformed block data gracefully', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
        'draftLayout': [
          'invalid_block',  // Not a Map, should be skipped
          {'invalid': 'block'},  // Missing standard fields but parseable with defaults
        ],
        'publishedLayout': [],
      };

      // Should not throw
      final page = BuilderPage.fromJson(json);
      
      // 'invalid_block' string should be skipped
      // {'invalid': 'block'} will be parsed with fallback defaults (id generated, type=text, etc.)
      expect(page.draftLayout.length, equals(1));
      expect(page.draftLayout[0].id, startsWith('block_'));  // Fallback ID
      expect(page.draftLayout[0].type, equals(BlockType.text));  // Default type
      expect(page.publishedLayout, isEmpty);
    });

    test('fromJson should use default values for missing fields', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
      };

      final page = BuilderPage.fromJson(json);
      
      // For 'home' page, systemConfig provides defaults
      expect(page.name, equals('Accueil'));  // From SystemPages.getConfig(home)
      expect(page.route, equals('/home'));   // From SystemPages.getConfig(home)
      expect(page.isActive, isTrue);
      expect(page.bottomNavIndex, equals(999));
      expect(page.draftLayout, isEmpty);
      expect(page.publishedLayout, isEmpty);
    });

    test('fromJson should correctly parse isActive and bottomNavIndex', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
        'isActive': true,
        'bottomNavIndex': 1,
      };

      final page = BuilderPage.fromJson(json);
      
      expect(page.isActive, isTrue);
      expect(page.bottomNavIndex, equals(1));
    });

    test('fromJson should handle missing isActive and bottomNavIndex with defaults', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
      };

      final page = BuilderPage.fromJson(json);
      
      expect(page.isActive, isTrue);  // Default value
      expect(page.bottomNavIndex, equals(999));  // Default value
    });

    test('activePublishedBlocks should return only active blocks from publishedLayout', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
        'publishedLayout': [
          {
            'id': 'block1',
            'type': 'hero',
            'order': 0,
            'isActive': true,
            'config': {},
          },
          {
            'id': 'block2',
            'type': 'banner',
            'order': 1,
            'isActive': false,
            'config': {},
          },
          {
            'id': 'block3',
            'type': 'text',
            'order': 2,
            'isActive': true,
            'config': {},
          }
        ],
      };

      final page = BuilderPage.fromJson(json);
      final activeBlocks = page.activePublishedBlocks;
      
      expect(activeBlocks.length, equals(2));
      expect(activeBlocks[0].id, equals('block1'));
      expect(activeBlocks[1].id, equals('block3'));
    });
    
    // TODO(builder-b3-safe-parsing) New tests for Timestamp and safe parsing
    
    test('fromJson should handle string dates in createdAt/updatedAt', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
        'createdAt': '2024-01-15T10:30:00.000Z',
        'updatedAt': '2024-01-16T15:45:00.000Z',
      };

      final page = BuilderPage.fromJson(json);
      
      expect(page.createdAt, isNotNull);
      expect(page.updatedAt, isNotNull);
      expect(page.createdAt.year, equals(2024));
      expect(page.createdAt.month, equals(1));
      expect(page.createdAt.day, equals(15));
    });
    
    test('fromJson should handle null dates with fallback to DateTime.now()', () {
      final beforeTest = DateTime.now();
      
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
        'createdAt': null,
        'updatedAt': null,
      };

      final page = BuilderPage.fromJson(json);
      
      final afterTest = DateTime.now();
      
      expect(page.createdAt, isNotNull);
      expect(page.updatedAt, isNotNull);
      // The fallback date should be between beforeTest and afterTest
      expect(page.createdAt.isAfter(beforeTest.subtract(Duration(seconds: 1))), isTrue);
      expect(page.createdAt.isBefore(afterTest.add(Duration(seconds: 1))), isTrue);
    });
    
    test('fromJson should handle integer milliseconds in dates', () {
      // 1705315800000 = 2024-01-15T10:30:00.000Z
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
        'createdAt': 1705315800000,
        'updatedAt': 1705320300000,
      };

      final page = BuilderPage.fromJson(json);
      
      expect(page.createdAt, isNotNull);
      expect(page.createdAt.year, equals(2024));
    });
    
    test('fromJson should skip malformed blocks and keep valid ones', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
        'publishedLayout': [
          {
            'id': 'valid_block',
            'type': 'hero',
            'order': 0,
            'isActive': true,
            'config': {},
          },
          'not_a_map',  // Should be skipped
          null,  // Should be skipped
          {
            'id': 'another_valid',
            'type': 'text',
            'order': 1,
            'isActive': true,
            'config': {},
          },
        ],
      };

      final page = BuilderPage.fromJson(json);
      
      // Should have 2 valid blocks, 2 invalid ones skipped
      expect(page.publishedLayout.length, equals(2));
      expect(page.publishedLayout[0].id, equals('valid_block'));
      expect(page.publishedLayout[1].id, equals('another_valid'));
    });
    
    test('fromJson should handle blocks with missing id by generating fallback', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
        'name': 'Home',
        'route': '/home',
        'publishedLayout': [
          {
            'type': 'hero',
            'order': 0,
            'isActive': true,
            'config': {},
            // id is missing - should generate fallback
          },
        ],
      };

      final page = BuilderPage.fromJson(json);
      
      expect(page.publishedLayout.length, equals(1));
      // Should have a generated fallback ID starting with 'block_'
      expect(page.publishedLayout[0].id, startsWith('block_'));
    });
    
    // Custom page tests
    test('fromJson should handle custom page with unknown pageId', () {
      final json = {
        'pageId': 'promo_noel',
        'appId': 'test_app',
        'name': 'Promo Noël',
        'route': '/page/promo_noel',
      };

      final page = BuilderPage.fromJson(json);
      
      // Custom page should have pageKey set
      expect(page.pageKey, equals('promo_noel'));
      // systemId should be null for unknown pages
      expect(page.systemId, isNull);
      // pageId should be null for custom pages (not defaulting to home)
      expect(page.pageId, isNull);
      // isCustomPage should be true
      expect(page.isCustomPage, isTrue);
      // Route should be preserved
      expect(page.route, equals('/page/promo_noel'));
    });
    
    test('fromJson should generate /page/<pageKey> route for custom pages with invalid route', () {
      final json = {
        'pageId': 'special_offer',
        'appId': 'test_app',
        'name': 'Special Offer',
        'route': '/',  // Invalid route
      };

      final page = BuilderPage.fromJson(json);
      
      // Route should be auto-generated for custom page
      expect(page.route, equals('/page/special_offer'));
      // pageId should be null for custom pages
      expect(page.pageId, isNull);
    });
    
    test('fromJson should correctly identify system pages', () {
      final json = {
        'pageId': 'menu',
        'appId': 'test_app',
        'name': 'Menu Test',
        'route': '/menu',
      };

      final page = BuilderPage.fromJson(json);
      
      // Menu is a known system page
      expect(page.pageKey, equals('menu'));
      expect(page.systemId, equals(BuilderPageId.menu));
      // pageId should equal systemId for system pages
      expect(page.pageId, equals(BuilderPageId.menu));
      expect(page.isCustomPage, isFalse);
    });
  });
  
  group('BuilderBlock Parsing Tests', () {
    test('fromJson should handle string dates', () {
      final json = {
        'id': 'block1',
        'type': 'hero',
        'order': 0,
        'isActive': true,
        'config': {},
        'createdAt': '2024-01-15T10:30:00.000Z',
        'updatedAt': '2024-01-16T15:45:00.000Z',
      };

      final block = BuilderBlock.fromJson(json);
      
      expect(block.createdAt, isNotNull);
      expect(block.updatedAt, isNotNull);
      expect(block.createdAt.year, equals(2024));
    });
    
    test('fromJson should handle null dates with fallback', () {
      final json = {
        'id': 'block1',
        'type': 'hero',
        'order': 0,
        'isActive': true,
        'config': {},
        'createdAt': null,
        'updatedAt': null,
      };

      final block = BuilderBlock.fromJson(json);
      
      expect(block.createdAt, isNotNull);
      expect(block.updatedAt, isNotNull);
    });
    
    test('fromJson should handle missing id with fallback', () {
      final json = {
        'type': 'hero',
        'order': 0,
        'isActive': true,
        'config': {},
      };

      final block = BuilderBlock.fromJson(json);
      
      expect(block.id, isNotEmpty);
      expect(block.id, startsWith('block_'));
    });
    
    test('fromJson should handle integer milliseconds dates', () {
      final json = {
        'id': 'block1',
        'type': 'hero',
        'order': 0,
        'isActive': true,
        'config': {},
        'createdAt': 1705315800000,
        'updatedAt': 1705320300000,
      };

      final block = BuilderBlock.fromJson(json);
      
      expect(block.createdAt.year, equals(2024));
    });
  });
}
