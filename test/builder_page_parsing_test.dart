// Test for BuilderPage.fromJson parsing safety
// Validates the _safeLayoutParse helper handles edge cases

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/builder/models/builder_page.dart';
import 'package:pizza_delizza/builder/models/builder_enums.dart';

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
          {'invalid': 'block'},  // Missing required fields
        ],
        'publishedLayout': [],
      };

      // Should not throw, should return empty list
      final page = BuilderPage.fromJson(json);
      
      expect(page.draftLayout, isEmpty);
      expect(page.publishedLayout, isEmpty);
    });

    test('fromJson should use default values for missing fields', () {
      final json = {
        'pageId': 'home',
        'appId': 'test_app',
      };

      final page = BuilderPage.fromJson(json);
      
      expect(page.name, equals('Page'));
      expect(page.route, equals('/'));
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
  });
}
