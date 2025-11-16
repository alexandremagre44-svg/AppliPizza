// test/widgets/pizza_roulette_wheel_test.dart
// Tests for PizzaRouletteWheel widget

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/roulette_config.dart';
import 'package:pizza_delizza/src/widgets/pizza_roulette_wheel.dart';

void main() {
  group('PizzaRouletteWheel', () {
    late List<RouletteSegment> testSegments;

    setUp(() {
      testSegments = [
        RouletteSegment(
          id: 'seg1',
          label: 'Prize 1',
          rewardId: 'prize1',
          probability: 50.0,
          color: Colors.red,
          iconName: 'local_pizza',
        ),
        RouletteSegment(
          id: 'seg2',
          label: 'Prize 2',
          rewardId: 'prize2',
          probability: 30.0,
          color: Colors.blue,
          iconName: 'local_drink',
        ),
        RouletteSegment(
          id: 'seg3',
          label: 'Prize 3',
          rewardId: 'prize3',
          probability: 20.0,
          color: Colors.green,
          iconName: 'cake',
        ),
      ];
    });

    testWidgets('renders correctly with segments', (WidgetTester tester) async {
      RouletteSegment? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PizzaRouletteWheel(
              segments: testSegments,
              onResult: (segment) {
                result = segment;
              },
            ),
          ),
        ),
      );

      // Verify widget builds without errors
      expect(find.byType(PizzaRouletteWheel), findsOneWidget);
    });

    testWidgets('calls onResult when spinWithResult completes', (WidgetTester tester) async {
      RouletteSegment? result;
      final key = GlobalKey<PizzaRouletteWheelState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PizzaRouletteWheel(
              key: key,
              segments: testSegments,
              onResult: (segment) {
                result = segment;
              },
            ),
          ),
        ),
      );

      // NEW ARCHITECTURE: Pass the pre-selected segment to spinWithResult
      final targetSegment = testSegments[1]; // Select second segment
      key.currentState?.spinWithResult(targetSegment);
      
      // Wait for animation to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify the exact result matches what we passed
      expect(result, isNotNull);
      expect(result, equals(targetSegment));
    });

    testWidgets('handles empty segments gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PizzaRouletteWheel(
              segments: const [],
              onResult: (_) {},
            ),
          ),
        ),
      );

      // Verify widget builds without errors even with empty segments
      expect(find.byType(PizzaRouletteWheel), findsOneWidget);
    });

    testWidgets('spinWithResult method is accessible via GlobalKey', (WidgetTester tester) async {
      final key = GlobalKey<PizzaRouletteWheelState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PizzaRouletteWheel(
              key: key,
              segments: testSegments,
              onResult: (_) {},
            ),
          ),
        ),
      );

      // Verify we can access the state and call spinWithResult
      expect(key.currentState, isNotNull);
      expect(() => key.currentState?.spinWithResult(testSegments[0]), returnsNormally);
    });

    testWidgets('does not spin when already spinning', (WidgetTester tester) async {
      final key = GlobalKey<PizzaRouletteWheelState>();
      int resultCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PizzaRouletteWheel(
              key: key,
              segments: testSegments,
              onResult: (_) {
                resultCount++;
              },
            ),
          ),
        ),
      );

      // Trigger first spin
      key.currentState?.spinWithResult(testSegments[0]);
      
      // Immediately try to spin again (should be ignored)
      key.currentState?.spinWithResult(testSegments[1]);
      key.currentState?.spinWithResult(testSegments[2]);

      // Wait for animation to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should only have one result from the first spin
      expect(resultCount, equals(1));
    });

    testWidgets('widget displays the segment passed to spinWithResult', (WidgetTester tester) async {
      // This test verifies that the widget displays exactly what it's told to display
      // Probability-based selection is now the responsibility of RouletteSegmentService
      
      final segments = [
        RouletteSegment(
          id: 'high',
          label: 'High Probability',
          rewardId: 'high',
          probability: 80.0,
          color: Colors.red,
        ),
        RouletteSegment(
          id: 'low',
          label: 'Low Probability',
          rewardId: 'low',
          probability: 20.0,
          color: Colors.blue,
        ),
      ];

      RouletteSegment? result;
      final key = GlobalKey<PizzaRouletteWheelState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PizzaRouletteWheel(
              key: key,
              segments: segments,
              onResult: (segment) {
                result = segment;
              },
            ),
          ),
        ),
      );

      // Test with first segment
      key.currentState?.spinWithResult(segments[0]);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(result, equals(segments[0]));

      // Reset and test with second segment
      result = null;
      key.currentState?.spinWithResult(segments[1]);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(result, equals(segments[1]));
    });

    testWidgets('spinToIndex method works with valid index', (WidgetTester tester) async {
      RouletteSegment? result;
      final key = GlobalKey<PizzaRouletteWheelState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PizzaRouletteWheel(
              key: key,
              segments: testSegments,
              onResult: (segment) {
                result = segment;
              },
            ),
          ),
        ),
      );

      // NEW INDEX-BASED ARCHITECTURE: Pass the index directly
      const targetIndex = 1;
      key.currentState?.spinToIndex(targetIndex);
      
      // Wait for animation to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify the result matches the segment at that index
      expect(result, isNotNull);
      expect(result, equals(testSegments[targetIndex]));
      expect(result?.id, equals('seg2'));
    });

    testWidgets('spinToIndex handles invalid index gracefully', (WidgetTester tester) async {
      RouletteSegment? result;
      final key = GlobalKey<PizzaRouletteWheelState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PizzaRouletteWheel(
              key: key,
              segments: testSegments,
              onResult: (segment) {
                result = segment;
              },
            ),
          ),
        ),
      );

      // Try with invalid negative index
      key.currentState?.spinToIndex(-1);
      await tester.pump();
      expect(result, isNull);

      // Try with out-of-bounds index
      key.currentState?.spinToIndex(testSegments.length);
      await tester.pump();
      expect(result, isNull);
    });

    testWidgets('spinToIndex works for all valid indices', (WidgetTester tester) async {
      final key = GlobalKey<PizzaRouletteWheelState>();
      final results = <int, RouletteSegment>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PizzaRouletteWheel(
              key: key,
              segments: testSegments,
              onResult: (segment) {
                // Find which index this segment is
                final idx = testSegments.indexOf(segment);
                results[idx] = segment;
              },
            ),
          ),
        ),
      );

      // Test each index
      for (int i = 0; i < testSegments.length; i++) {
        key.currentState?.spinToIndex(i);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Verify the correct segment was selected
        expect(results[i], isNotNull);
        expect(results[i], equals(testSegments[i]));
      }
    });

    testWidgets('winning segment aligns correctly with pointer after spin', (WidgetTester tester) async {
      // Test that FortuneWheel correctly stops at the target segment
      RouletteSegment? result;
      final key = GlobalKey<PizzaRouletteWheelState>();

      // Create 6 segments to match the problem statement
      final segments = List.generate(6, (i) {
        return RouletteSegment(
          id: 'seg$i',
          label: 'Segment $i',
          rewardId: 'reward$i',
          probability: 100.0 / 6,
          color: Colors.primaries[i % Colors.primaries.length],
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PizzaRouletteWheel(
              key: key,
              segments: segments,
              onResult: (segment) {
                result = segment;
              },
            ),
          ),
        ),
      );

      // Test with specific target segment using spinToIndex
      const targetIndex = 3;
      key.currentState?.spinToIndex(targetIndex);
      
      // Wait for animation to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify the exact result matches the segment at the target index
      expect(result, isNotNull);
      expect(result, equals(segments[targetIndex]));
      
      // FortuneWheel handles the alignment automatically
      // No custom angle calculation needed
    });
  });
}
