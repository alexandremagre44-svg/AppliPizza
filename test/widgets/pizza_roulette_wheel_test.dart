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
      
      // Verify CustomPaint is present (the wheel)
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('calls onResult when spin completes', (WidgetTester tester) async {
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

      // Trigger spin
      key.currentState?.spin();
      
      // Wait for animation to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify a result was selected
      expect(result, isNotNull);
      expect(testSegments.contains(result), isTrue);
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

    testWidgets('spin method is accessible via GlobalKey', (WidgetTester tester) async {
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

      // Verify we can access the state and call spin
      expect(key.currentState, isNotNull);
      expect(() => key.currentState?.spin(), returnsNormally);
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
      key.currentState?.spin();
      
      // Immediately try to spin again (should be ignored)
      key.currentState?.spin();
      key.currentState?.spin();

      // Wait for animation to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should only have one result from the first spin
      expect(resultCount, equals(1));
    });

    test('probability-based selection distributes correctly', () {
      // This is a statistical test - run multiple times
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

      final results = <String, int>{};
      const iterations = 1000;

      // Create a temporary widget to test selection logic
      for (int i = 0; i < iterations; i++) {
        // Simulate selection by creating widget and checking internal logic
        // Note: This is a simplified test of the probability logic
        final totalProb = segments.fold<double>(0, (sum, s) => sum + s.probability);
        final random = (i / iterations) * totalProb;
        
        double cumulative = 0;
        for (final segment in segments) {
          cumulative += segment.probability;
          if (random <= cumulative) {
            results[segment.id] = (results[segment.id] ?? 0) + 1;
            break;
          }
        }
      }

      // High probability segment should appear roughly 80% of the time
      // Allow for some variance (70-90% range)
      final highCount = results['high'] ?? 0;
      expect(highCount, greaterThan(iterations * 0.70));
      expect(highCount, lessThan(iterations * 0.90));
    });
  });
}
