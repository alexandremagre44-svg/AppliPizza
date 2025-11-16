// lib/src/widgets/pizza_roulette_wheel.dart
// Custom animated pizza roulette wheel widget - Pure Flutter implementation

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/roulette_config.dart';

/// Custom Flutter widget that displays an animated pizza-style roulette wheel
/// 
/// This widget draws a wheel divided into segments (triangular sections) based
/// on the provided configuration. Each segment has its own color, label, and
/// optional icon. The wheel animates smoothly to the specified index.
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
class PizzaRouletteWheelState extends State<PizzaRouletteWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  double _currentRotation = 0.0;
  bool _isSpinning = false;
  RouletteSegment? _selectedSegment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _controller.addListener(() {
      setState(() {});
    });
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinComplete();
      }
    });
    
    // LOG: Verify segment order received by wheel widget
    print('[ROULETTE ORDER] Wheel initialized with: ${widget.segments.map((s) => s.label).toList()}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Public method to trigger the wheel spin to a specific segment index
  /// This is the NEW INDEX-BASED entry point - the widget receives only an index
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
    if (_isSpinning || widget.segments.isEmpty) {
      return;
    }
    
    if (index < 0 || index >= widget.segments.length) {
      print('⚠️ [WIDGET] Invalid index: $index (segments length: ${widget.segments.length})');
      return;
    }
    
    final targetSegment = widget.segments[index];
    
    setState(() {
      _isSpinning = true;
      _selectedSegment = targetSegment;
    });
    
    // DEBUG LOG: Winning index received from parent
    print('🎯 [WIDGET] Spinning to index: $index');
    print('  - Segment ID: ${targetSegment.id}');
    print('  - Label: ${targetSegment.label}');
    print('  - RewardType: ${targetSegment.rewardType}');
    print('  - RewardValue: ${targetSegment.rewardValue}');
    
    // Calculate target rotation angle for the winning segment index
    final targetAngle = _calculateTargetAngleFromIndex(index);
    
    print('  - Target angle: ${targetAngle.toStringAsFixed(4)} rad (${(targetAngle * 180 / math.pi).toStringAsFixed(2)}°)');
    
    // Add multiple full rotations for visual effect (3-5 full spins)
    final fullRotations = 3 + math.Random().nextDouble() * 2;
    final totalRotation = fullRotations * 2 * math.pi + targetAngle;
    
    _animation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation + totalRotation,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _controller.forward(from: 0);
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

  /// Calculates the target angle to position the winning segment at the top (INDEX-BASED)
  double _calculateTargetAngleFromIndex(int index) {
    final segments = widget.segments;

    // Trouver l'index via l'id
    if (index < 0 || index >= segments.length) {
      return 0.0;
    }

    final anglePerSegment = 2 * math.pi / segments.length;

    // Curseur fixé en haut (-π/2)
    const double cursorAngle = -math.pi / 2;

    // Angle de départ utilisé par le painter (sans offset)
    final double startAngle = index * anglePerSegment - math.pi / 2;
    final double centerAngle = startAngle + anglePerSegment / 2;

    // Angle cible : aligner le centre du segment sur le curseur
    double targetAngle = cursorAngle - centerAngle;

    // Normaliser 0 → 2π
    targetAngle %= (2 * math.pi);
    if (targetAngle < 0) targetAngle += 2 * math.pi;

    return targetAngle;
  }

  void _onSpinComplete() {
    setState(() {
      _currentRotation = _animation.value;
      _isSpinning = false;
    });
    
    if (_selectedSegment != null) {
      widget.onResult(_selectedSegment!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate wheel size based on available space
        final size = math.min(constraints.maxWidth, constraints.maxHeight) * 0.85;
        
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Wheel shadow
              Container(
                width: size + 8,
                height: size + 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              // Rotating wheel
              Transform.rotate(
                angle: _animation.value,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _WheelPainter(
                    segments: widget.segments,
                  ),
                ),
              ),
              // Center circle
              Container(
                width: size * 0.15,
                height: size * 0.15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Fixed cursor at top
              Positioned(
                top: 0,
                child: _buildCursor(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the fixed cursor/pointer at the top of the wheel
  Widget _buildCursor() {
    return CustomPaint(
      size: const Size(30, 40),
      painter: _CursorPainter(),
    );
  }
}

/// Custom painter for the roulette wheel segments
class _WheelPainter extends CustomPainter {
  final List<RouletteSegment> segments;

  // Visual offset to align the wheel correctly with the needle
  // This constant adjusts the initial drawing position of segments
  static const double _visualOffset = 0.0;

  _WheelPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw background gradient
    final backgroundPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          Colors.grey.shade100,
        ],
        stops: const [0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Draw wheel border
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(center, radius, borderPaint);
    
    // Calculate angle per segment
    final anglePerSegment = 2 * math.pi / segments.length;
    
    // Draw each segment
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final startAngle = i * anglePerSegment - math.pi / 2 + _visualOffset;
      
      _drawSegment(
        canvas,
        center,
        radius,
        startAngle,
        anglePerSegment,
        segment,
      );
    }
  }

  void _drawSegment(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    RouletteSegment segment,
  ) {
    // Draw segment background
    final paint = Paint()
      ..color = segment.color
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      )
      ..close();
    
    canvas.drawPath(path, paint);
    
    // Draw segment border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(path, borderPaint);
    
    // Draw text and icon
    final middleAngle = startAngle + sweepAngle / 2;
    final textRadius = radius * 0.65;
    final textX = center.dx + textRadius * math.cos(middleAngle);
    final textY = center.dy + textRadius * math.sin(middleAngle);
    
    // Save canvas state for rotation
    canvas.save();
    canvas.translate(textX, textY);
    canvas.rotate(middleAngle + math.pi / 2);
    
    // Draw icon if available
    if (segment.iconName != null) {
      _drawIcon(canvas, segment.iconName!, const Offset(0, -15));
    }
    
    // Draw label
    _drawText(
      canvas,
      segment.label,
      Offset.zero,
      segment.color,
    );
    
    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color bgColor) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: _getContrastColor(bgColor),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx - textPainter.width / 2,
        offset.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawIcon(Canvas canvas, String iconName, Offset offset) {
    final iconData = _getIconData(iconName);
    if (iconData == null) return;
    
    final textSpan = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 20,
        fontFamily: iconData.fontFamily,
        color: Colors.white,
      ),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx - textPainter.width / 2,
        offset.dy - textPainter.height / 2,
      ),
    );
  }

  /// Gets contrasting text color based on background color
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Maps icon name to IconData
  IconData? _getIconData(String iconName) {
    switch (iconName) {
      case 'local_pizza':
        return Icons.local_pizza;
      case 'local_drink':
        return Icons.local_drink;
      case 'cake':
        return Icons.cake;
      case 'stars':
        return Icons.stars;
      case 'percent':
        return Icons.percent;
      case 'euro':
        return Icons.euro;
      case 'close':
        return Icons.close;
      case 'card_giftcard':
        return Icons.card_giftcard;
      default:
        return null;
    }
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

/// Custom painter for the fixed cursor/pointer at the top
class _CursorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    
    // Draw shadow
    canvas.drawPath(path, shadowPaint);
    
    // Draw cursor
    canvas.drawPath(path, paint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_CursorPainter oldDelegate) => false;
}
