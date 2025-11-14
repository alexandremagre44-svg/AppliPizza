// test/features/content/content_service_test.dart
// Tests for ContentService

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_delizza/src/features/content/data/content_service.dart';
import 'package:pizza_delizza/src/features/content/data/models/content_string_model.dart';

void main() {
  group('ContentService', () {
    test('ContentString model creates properly from data', () {
      final contentString = ContentString(
        key: 'test_key',
        values: {'fr': 'Test value'},
        metadata: {
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
      );

      expect(contentString.key, 'test_key');
      expect(contentString.values['fr'], 'Test value');
    });

    test('ContentString.toFirestore creates proper structure', () {
      final contentString = ContentString(
        key: 'test_key',
        values: {'fr': 'Test value'},
        metadata: {
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      );

      final firestore = contentString.toFirestore();
      
      expect(firestore['key'], 'test_key');
      expect(firestore['value']['fr'], 'Test value');
      expect(firestore['metadata'], isNotNull);
    });

    test('ContentString copyWith works correctly', () {
      final original = ContentString(
        key: 'test_key',
        values: {'fr': 'Test value'},
      );

      final copied = original.copyWith(
        values: {'fr': 'Updated value'},
      );

      expect(copied.key, 'test_key');
      expect(copied.values['fr'], 'Updated value');
    });

    test('ContentString equality is based on key', () {
      final content1 = ContentString(
        key: 'test_key',
        values: {'fr': 'Value 1'},
      );

      final content2 = ContentString(
        key: 'test_key',
        values: {'fr': 'Value 2'},
      );

      expect(content1, equals(content2));
      expect(content1.hashCode, equals(content2.hashCode));
    });
  });
}
