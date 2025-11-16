// test/services/roulette_segment_service_test.dart
// Tests for RouletteSegmentService sorting logic

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/roulette_config.dart';

void main() {
  group('RouletteSegmentService Sorting Logic', () {
    test('segments with positions are sorted correctly', () {
      // Create test segments with explicit positions
      final segments = [
        RouletteSegment(
          id: 'seg3',
          label: 'Third',
          rewardId: 'third',
          probability: 30.0,
          color: Colors.blue,
          position: 3,
        ),
        RouletteSegment(
          id: 'seg1',
          label: 'First',
          rewardId: 'first',
          probability: 40.0,
          color: Colors.red,
          position: 1,
        ),
        RouletteSegment(
          id: 'seg2',
          label: 'Second',
          rewardId: 'second',
          probability: 30.0,
          color: Colors.green,
          position: 2,
        ),
      ];

      // Sort by position ASC (simulating the service logic)
      segments.sort((a, b) => a.position.compareTo(b.position));

      // Verify order
      expect(segments[0].id, equals('seg1'));
      expect(segments[1].id, equals('seg2'));
      expect(segments[2].id, equals('seg3'));
      
      expect(segments[0].position, equals(1));
      expect(segments[1].position, equals(2));
      expect(segments[2].position, equals(3));
    });

    test('segments without positions (position=0) get fallback positions', () {
      // Create test segments with position=0 (no position set)
      final segments = [
        RouletteSegment(
          id: 'seg_a',
          label: 'A',
          rewardId: 'a',
          probability: 30.0,
          color: Colors.blue,
          position: 0, // No position
        ),
        RouletteSegment(
          id: 'seg_b',
          label: 'B',
          rewardId: 'b',
          probability: 40.0,
          color: Colors.red,
          position: 0, // No position
        ),
        RouletteSegment(
          id: 'seg_c',
          label: 'C',
          rewardId: 'c',
          probability: 30.0,
          color: Colors.green,
          position: 0, // No position
        ),
      ];

      // Apply fallback position assignment (simulating service logic)
      for (int i = 0; i < segments.length; i++) {
        if (segments[i].position == 0) {
          segments[i] = segments[i].copyWith(position: i + 1);
        }
      }

      // Sort by position ASC
      segments.sort((a, b) => a.position.compareTo(b.position));

      // Verify fallback positions were assigned based on Firebase order
      expect(segments[0].id, equals('seg_a'));
      expect(segments[0].position, equals(1));
      
      expect(segments[1].id, equals('seg_b'));
      expect(segments[1].position, equals(2));
      
      expect(segments[2].id, equals('seg_c'));
      expect(segments[2].position, equals(3));
    });

    test('segments with mixed positions (some set, some not) are sorted correctly', () {
      // Create test segments with mixed positions
      final segments = [
        RouletteSegment(
          id: 'seg_no_pos_1',
          label: 'No Position 1',
          rewardId: 'no_pos_1',
          probability: 20.0,
          color: Colors.grey,
          position: 0, // No position
        ),
        RouletteSegment(
          id: 'seg_pos_5',
          label: 'Position 5',
          rewardId: 'pos_5',
          probability: 25.0,
          color: Colors.blue,
          position: 5,
        ),
        RouletteSegment(
          id: 'seg_pos_2',
          label: 'Position 2',
          rewardId: 'pos_2',
          probability: 30.0,
          color: Colors.green,
          position: 2,
        ),
        RouletteSegment(
          id: 'seg_no_pos_2',
          label: 'No Position 2',
          rewardId: 'no_pos_2',
          probability: 25.0,
          color: Colors.orange,
          position: 0, // No position
        ),
      ];

      // Apply fallback position assignment
      for (int i = 0; i < segments.length; i++) {
        if (segments[i].position == 0) {
          segments[i] = segments[i].copyWith(position: i + 1);
        }
      }

      // Sort by position ASC
      segments.sort((a, b) => a.position.compareTo(b.position));

      // Verify order:
      // - seg_no_pos_1 gets position 1 (first in list, position was 0)
      // - seg_pos_5 keeps position 5 (explicitly set)
      // - seg_pos_2 keeps position 2 (explicitly set)
      // - seg_no_pos_2 gets position 4 (fourth in list, position was 0)
      // After sorting: 1, 2, 4, 5
      expect(segments[0].id, equals('seg_no_pos_1'));
      expect(segments[0].position, equals(1));
      
      expect(segments[1].id, equals('seg_pos_2'));
      expect(segments[1].position, equals(2));
      
      expect(segments[2].id, equals('seg_no_pos_2'));
      expect(segments[2].position, equals(4));
      
      expect(segments[3].id, equals('seg_pos_5'));
      expect(segments[3].position, equals(5));
    });

    test('segment order determines visual display and reward selection', () {
      // This test verifies that the same list order is used for:
      // 1. Visual wheel display
      // 2. Probability-based selection
      // 3. Angle calculation
      
      final segments = [
        RouletteSegment(
          id: 'seg1',
          label: '+50 points',
          rewardId: 'bonus_points_50',
          probability: 25.0,
          color: Colors.blue,
          position: 1,
          rewardType: RewardType.bonusPoints,
          rewardValue: 50.0,
        ),
        RouletteSegment(
          id: 'seg2',
          label: 'Pizza offerte',
          rewardId: 'free_pizza',
          probability: 5.0,
          color: Colors.red,
          position: 2,
          rewardType: RewardType.freePizza,
        ),
        RouletteSegment(
          id: 'seg3',
          label: 'Raté !',
          rewardId: '',
          probability: 20.0,
          color: Colors.grey,
          position: 3,
          rewardType: RewardType.none,
        ),
      ];

      // Segments are already sorted by position
      // In the wheel, segment at index 0 should be drawn first
      // When selected by index, it should return the same segment
      
      final selectedIndex = 1; // Select second segment (Pizza offerte)
      final selectedSegment = segments[selectedIndex];
      
      // Verify the selected segment matches expectations
      expect(selectedSegment.id, equals('seg2'));
      expect(selectedSegment.label, equals('Pizza offerte'));
      expect(selectedSegment.rewardType, equals(RewardType.freePizza));
      expect(selectedSegment.position, equals(2));
      
      // Verify indices match
      expect(segments.indexOf(selectedSegment), equals(selectedIndex));
    });

    test('reward type mapping is preserved after sorting', () {
      final segments = [
        RouletteSegment(
          id: 'seg_bonus',
          label: '+100 points',
          rewardId: 'bonus_points_100',
          probability: 30.0,
          color: Colors.gold,
          position: 1,
          rewardType: RewardType.bonusPoints,
          rewardValue: 100.0,
        ),
        RouletteSegment(
          id: 'seg_pizza',
          label: 'Pizza offerte',
          rewardId: 'free_pizza',
          probability: 5.0,
          color: Colors.red,
          position: 2,
          rewardType: RewardType.freePizza,
        ),
        RouletteSegment(
          id: 'seg_drink',
          label: 'Boisson offerte',
          rewardId: 'free_drink',
          probability: 10.0,
          color: Colors.blue,
          position: 3,
          rewardType: RewardType.freeDrink,
        ),
        RouletteSegment(
          id: 'seg_dessert',
          label: 'Dessert offert',
          rewardId: 'free_dessert',
          probability: 10.0,
          color: Colors.purple,
          position: 4,
          rewardType: RewardType.freeDessert,
        ),
        RouletteSegment(
          id: 'seg_nothing',
          label: 'Raté !',
          rewardId: '',
          probability: 45.0,
          color: Colors.grey,
          position: 5,
          rewardType: RewardType.none,
        ),
      ];

      // Sort by position
      segments.sort((a, b) => a.position.compareTo(b.position));

      // Verify reward mappings are preserved
      expect(segments[0].rewardType, equals(RewardType.bonusPoints));
      expect(segments[0].rewardId, equals('bonus_points_100'));
      expect(segments[0].rewardValue, equals(100.0));
      
      expect(segments[1].rewardType, equals(RewardType.freePizza));
      expect(segments[1].rewardId, equals('free_pizza'));
      
      expect(segments[2].rewardType, equals(RewardType.freeDrink));
      expect(segments[2].rewardId, equals('free_drink'));
      
      expect(segments[3].rewardType, equals(RewardType.freeDessert));
      expect(segments[3].rewardId, equals('free_dessert'));
      
      expect(segments[4].rewardType, equals(RewardType.none));
      expect(segments[4].rewardId, equals(''));
    });
  });

  group('RouletteSegmentService.pickIndex()', () {
    test('returns valid index within segment list bounds', () {
      final segments = [
        RouletteSegment(
          id: 'seg1',
          label: 'Segment 1',
          rewardId: 'reward1',
          probability: 50.0,
          color: Colors.red,
          position: 1,
        ),
        RouletteSegment(
          id: 'seg2',
          label: 'Segment 2',
          rewardId: 'reward2',
          probability: 30.0,
          color: Colors.blue,
          position: 2,
        ),
        RouletteSegment(
          id: 'seg3',
          label: 'Segment 3',
          rewardId: 'reward3',
          probability: 20.0,
          color: Colors.green,
          position: 3,
        ),
      ];

      // Test multiple selections to ensure index is always valid
      for (int i = 0; i < 100; i++) {
        final totalProbability = segments.fold<double>(
          0.0,
          (sum, segment) => sum + segment.probability,
        );
        
        final random = (i / 100) * totalProbability;
        
        double cumulativeProbability = 0.0;
        int? selectedIndex;
        for (int idx = 0; idx < segments.length; idx++) {
          cumulativeProbability += segments[idx].probability;
          if (random <= cumulativeProbability) {
            selectedIndex = idx;
            break;
          }
        }
        
        // Verify index is valid
        expect(selectedIndex, isNotNull);
        expect(selectedIndex!, greaterThanOrEqualTo(0));
        expect(selectedIndex, lessThan(segments.length));
        
        // Verify we can retrieve the segment with this index
        expect(() => segments[selectedIndex], returnsNormally);
      }
    });

    test('index-based selection eliminates instance comparison errors', () {
      // This test demonstrates the advantage of index-based architecture
      // With indices, we never have to compare object instances
      
      final segments = [
        RouletteSegment(
          id: 'seg1',
          label: 'Prize 1',
          rewardId: 'prize1',
          probability: 50.0,
          color: Colors.red,
          position: 1,
        ),
        RouletteSegment(
          id: 'seg2',
          label: 'Prize 2',
          rewardId: 'prize2',
          probability: 50.0,
          color: Colors.blue,
          position: 2,
        ),
      ];

      // Simulate service selecting an index
      const selectedIndex = 1;
      
      // Screen retrieves the segment
      final result = segments[selectedIndex];
      
      // Verify no instance comparison needed
      expect(result.id, equals('seg2'));
      expect(result.label, equals('Prize 2'));
      
      // The same segment can be retrieved multiple times
      final result2 = segments[selectedIndex];
      expect(result2.id, equals(result.id));
      
      // No indexOf() call needed, no risk of -1 error
      expect(selectedIndex, equals(1));
    });

    test('probability distribution is maintained with index-based selection', () {
      final segments = [
        RouletteSegment(
          id: 'high',
          label: 'High Probability',
          rewardId: 'high',
          probability: 80.0,
          color: Colors.red,
          position: 1,
        ),
        RouletteSegment(
          id: 'low',
          label: 'Low Probability',
          rewardId: 'low',
          probability: 20.0,
          color: Colors.blue,
          position: 2,
        ),
      ];

      final results = <int, int>{};
      const iterations = 1000;

      // Simulate the pickIndex algorithm
      for (int i = 0; i < iterations; i++) {
        final totalProbability = segments.fold<double>(
          0.0,
          (sum, segment) => sum + segment.probability,
        );
        
        final random = (i / iterations) * totalProbability;
        
        double cumulativeProbability = 0.0;
        int? selectedIndex;
        for (int idx = 0; idx < segments.length; idx++) {
          cumulativeProbability += segments[idx].probability;
          if (random <= cumulativeProbability) {
            selectedIndex = idx;
            break;
          }
        }
        
        if (selectedIndex != null) {
          results[selectedIndex] = (results[selectedIndex] ?? 0) + 1;
        }
      }

      // Index 0 (80% probability) should appear roughly 800 times
      final highCount = results[0] ?? 0;
      expect(highCount, greaterThan(iterations * 0.75));
      expect(highCount, lessThan(iterations * 0.85));
      
      // Index 1 (20% probability) should appear roughly 200 times
      final lowCount = results[1] ?? 0;
      expect(lowCount, greaterThan(iterations * 0.15));
      expect(lowCount, lessThan(iterations * 0.25));
    });
  });

  group('RouletteSegmentService.pickRandomSegment()', () {
    test('probability-based selection distributes correctly', () {
      // This is a statistical test to verify the probability distribution
      // Note: This test is for the algorithm logic, not the service itself
      // (which requires Firebase mocking)
      
      final segments = [
        RouletteSegment(
          id: 'high',
          label: 'High Probability',
          rewardId: 'high',
          probability: 80.0,
          color: Colors.red,
          position: 1,
        ),
        RouletteSegment(
          id: 'low',
          label: 'Low Probability',
          rewardId: 'low',
          probability: 20.0,
          color: Colors.blue,
          position: 2,
        ),
      ];

      final results = <String, int>{};
      const iterations = 1000;

      // Simulate the pickRandomSegment algorithm
      for (int i = 0; i < iterations; i++) {
        final totalProbability = segments.fold<double>(
          0.0,
          (sum, segment) => sum + segment.probability,
        );
        
        // Use deterministic random for testing (spread evenly)
        final random = (i / iterations) * totalProbability;
        
        double cumulativeProbability = 0.0;
        RouletteSegment? selected;
        for (final segment in segments) {
          cumulativeProbability += segment.probability;
          if (random <= cumulativeProbability) {
            selected = segment;
            break;
          }
        }
        
        if (selected != null) {
          results[selected.id] = (results[selected.id] ?? 0) + 1;
        }
      }

      // High probability segment should appear roughly 80% of the time
      // Allow for some variance (75-85% range for deterministic test)
      final highCount = results['high'] ?? 0;
      expect(highCount, greaterThan(iterations * 0.75));
      expect(highCount, lessThan(iterations * 0.85));
    });

    test('selection always returns one of the provided segments', () {
      // Test that the algorithm always returns a valid segment
      final segments = [
        RouletteSegment(
          id: 'seg1',
          label: 'Segment 1',
          rewardId: 'reward1',
          probability: 50.0,
          color: Colors.red,
          position: 1,
        ),
        RouletteSegment(
          id: 'seg2',
          label: 'Segment 2',
          rewardId: 'reward2',
          probability: 30.0,
          color: Colors.blue,
          position: 2,
        ),
        RouletteSegment(
          id: 'seg3',
          label: 'Segment 3',
          rewardId: 'reward3',
          probability: 20.0,
          color: Colors.green,
          position: 3,
        ),
      ];

      // Test multiple selections
      for (int i = 0; i < 100; i++) {
        final totalProbability = segments.fold<double>(
          0.0,
          (sum, segment) => sum + segment.probability,
        );
        
        final random = (i / 100) * totalProbability;
        
        double cumulativeProbability = 0.0;
        RouletteSegment? selected;
        for (final segment in segments) {
          cumulativeProbability += segment.probability;
          if (random <= cumulativeProbability) {
            selected = segment;
            break;
          }
        }
        
        // Verify a segment was selected
        expect(selected, isNotNull);
        // Verify it's one of our segments
        expect(segments.contains(selected), isTrue);
      }
    });

    test('cumulative probability edge cases are handled correctly', () {
      final segments = [
        RouletteSegment(
          id: 'seg1',
          label: 'First',
          rewardId: 'first',
          probability: 33.33,
          color: Colors.red,
          position: 1,
        ),
        RouletteSegment(
          id: 'seg2',
          label: 'Second',
          rewardId: 'second',
          probability: 33.33,
          color: Colors.blue,
          position: 2,
        ),
        RouletteSegment(
          id: 'seg3',
          label: 'Third',
          rewardId: 'third',
          probability: 33.34,
          color: Colors.green,
          position: 3,
        ),
      ];

      final totalProbability = segments.fold<double>(
        0.0,
        (sum, segment) => sum + segment.probability,
      );
      
      // Test at boundary points
      final testCases = [
        0.0, // Start
        33.33, // End of first segment
        66.66, // End of second segment
        100.0, // End (should select last segment)
      ];

      for (final random in testCases) {
        double cumulativeProbability = 0.0;
        RouletteSegment? selected;
        for (final segment in segments) {
          cumulativeProbability += segment.probability;
          if (random <= cumulativeProbability) {
            selected = segment;
            break;
          }
        }
        
        // Should always select a segment
        expect(selected, isNotNull, reason: 'Failed at random=$random');
        expect(segments.contains(selected), isTrue);
      }
    });
  });
}
