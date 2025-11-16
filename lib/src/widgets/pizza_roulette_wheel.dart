// lib/src/widgets/pizza_roulette_wheel.dart
// FortuneWheel-based pizza roulette wheel widget - Clean and stable implementation

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import '../models/roulette_config.dart';

/// FortuneWheel-based widget that displays an animated pizza-style roulette wheel
/// 
/// This widget uses the flutter_fortune_wheel package for a stable, index-based
/// implementation. The wheel animates smoothly to the specified index.
/// 
/// IMPORTANT: This widget does NOT select the winning segment or index.
/// The parent MUST call the service to get the winning INDEX and pass it to spinToIndex().
/// 
/// INDEX-BASED ARCHITECTURE:
/// - Single list of segments shared between screen and widget
/// - Service returns an index (not an object)
/// - Widget animates to the index
/// - Screen retrieves the segment via segments[index]
/// - Perfect synchronization, no instance errors
/// 
/// Usage:
/// ```dart
/// final GlobalKey<PizzaRouletteWheelState> wheelKey = GlobalKey();
/// final RouletteSegmentService segmentService = RouletteSegmentService();
/// 
/// // 1. Create ONE list
/// final segments = await segmentService.getActiveSegments();
/// 
/// PizzaRouletteWheel(
///   key: wheelKey,
///   segments: segments,
///   onResult: (segment) {
///     print('Winner: ${segment.label}');
///   },
/// )
/// 
/// // 2. Get winning index from service
/// final int index = segmentService.pickIndex(segments);
/// 
/// // 3. Animate to that index
/// wheelKey.currentState?.spinToIndex(index);
/// 
/// // 4. Retrieve the segment
/// final result = segments[index];
/// ```
class PizzaRouletteWheel extends StatefulWidget {
  /// List of active segments in display order
  final List<RouletteSegment> segments;
  
  /// Callback invoked when the wheel stops on a winning segment
  final void Function(RouletteSegment result) onResult;
  
  /// Optional flag to indicate if wheel is currently spinning
  final bool isSpinning;

  /// Creates a PizzaRouletteWheel widget
  const PizzaRouletteWheel({
    super.key,
    required this.segments,
    required this.onResult,
    this.isSpinning = false,
  });

  @override
  State<PizzaRouletteWheel> createState() => PizzaRouletteWheelState();
}

/// Public state class to allow external control via GlobalKey
class PizzaRouletteWheelState extends State<PizzaRouletteWheel> {
  final StreamController<int> _controller = StreamController<int>();
  int? _lastIndex;

  @override
  void initState() {
    super.initState();
    // LOG: Verify segment order received by wheel widget
    print('[ROULETTE ORDER] Wheel initialized with: ${widget.segments.map((s) => s.label).toList()}');
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  /// Public method to trigger the wheel spin to a specific segment index
  /// This is the INDEX-BASED entry point - the widget receives only an index
  /// 
  /// The parent (roulette_screen) must:
  /// 1. Create ONE list of segments
  /// 2. Call the service to get the winning index
  /// 3. Pass the index to this method
  /// 4. Retrieve the segment via segments[index] when done
  /// 
  /// Example usage:
  /// ```dart
  /// final segments = await segmentService.getActiveSegments();
  /// final index = segmentService.pickIndex(segments);
  /// wheelKey.currentState?.spinToIndex(index);
  /// // Result will be segments[index]
  /// ```
  void spinToIndex(int index) {
    if (widget.segments.isEmpty) {
      return;
    }
    
    if (index < 0 || index >= widget.segments.length) {
      print('⚠️ [WIDGET] Invalid index: $index (segments length: ${widget.segments.length})');
      return;
    }
    
    final targetSegment = widget.segments[index];
    
    // DEBUG LOG: Winning index received from parent
    print('🎯 [WIDGET] Spinning to index: $index');
    print('  - Segment ID: ${targetSegment.id}');
    print('  - Label: ${targetSegment.label}');
    print('  - RewardType: ${targetSegment.rewardType}');
    print('  - RewardValue: ${targetSegment.rewardValue}');
    
    _lastIndex = index;
    _controller.add(index);
  }

  /// DEPRECATED: Use spinToIndex() instead
  /// This method is kept for backward compatibility but should NOT be used
  @Deprecated('Use spinToIndex(int) instead')
  void spinWithResult(RouletteSegment targetSegment) {
    final index = widget.segments.indexOf(targetSegment);
    if (index == -1) {
      print('⚠️ [WIDGET] Segment not found in list, cannot spin');
      return;
    }
    spinToIndex(index);
  }

  /// DEPRECATED: Use spinWithResult() instead
  /// This method is kept for backward compatibility but should NOT be used
  @Deprecated('Use spinWithResult(RouletteSegment) instead')
  void spin() {
    // This should never be called in the new architecture
    // If it is called, throw an error to alert the developer
    throw UnsupportedError(
      'spin() is deprecated. Use spinWithResult(RouletteSegment) instead.\n'
      'The widget should NOT select the winning segment.\n'
      'Call rouletteSegmentService.pickRandomSegment() from the parent and pass the result to spinWithResult().'
    );
  }

  void _onAnimationEnd() {
    if (_lastIndex != null && _lastIndex! >= 0 && _lastIndex! < widget.segments.length) {
      final segment = widget.segments[_lastIndex!];
      print('🎁 [WIDGET] Animation ended on index: $_lastIndex (${segment.label})');
      widget.onResult(segment);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.segments.isEmpty) {
      return const Center(
        child: Text('No segments available'),
      );
    }

    return FortuneWheel(
      selected: _controller.stream,
      animateFirst: false,
      onAnimationEnd: _onAnimationEnd,
      indicators: const [
        FortuneIndicator(
          alignment: Alignment.topCenter,
          child: TriangleIndicator(
            color: Colors.red,
            width: 30.0,
            height: 40.0,
          ),
        ),
      ],
      items: [
        for (final segment in widget.segments)
          FortuneItem(
            child: Text(
              segment.label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: segment.color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            style: FortuneItemStyle(
              color: segment.color,
              borderColor: Colors.white,
              borderWidth: 2,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
