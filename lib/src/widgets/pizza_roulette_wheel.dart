// lib/src/widgets/pizza_roulette_wheel.dart
// Custom animated pizza roulette wheel widget - Pure Flutter implementation

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/roulette_config.dart';

/// Custom Flutter widget that displays an animated pizza-style roulette wheel
/// 
/// This widget draws a wheel divided into segments (triangular sections) based
/// on the provided configuration. Each segment has its own color, label, and
/// optional icon. The wheel can be spun with smooth animations and uses
/// probability-based selection to determine the winning segment.
/// 
/// Usage:
/// ```dart
/// final GlobalKey<PizzaRouletteWheelState> wheelKey = GlobalKey();
/// 
/// PizzaRouletteWheel(
///   segments: segments,
///   onResult: (segment) {
///     print('Winner: ${segment.label}');
///   },
/// )
/// 
/// // To spin the wheel:
/// wheelKey.currentState?.spin();
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Public method to trigger the wheel spin
  /// This can be called from outside using a GlobalKey
  void spin() {
    if (_isSpinning || widget.segments.isEmpty) {
      return;
    }
    
    setState(() {
      _isSpinning = true;
    });
    
    // Select winning segment based on probabilities
    _selectedSegment = _selectWinningSegment();
    
    // Calculate target rotation angle for the winning segment
    final targetAngle = _calculateTargetAngle(_selectedSegment!);
    
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

  /// Selects a winning segment based on probability distribution
  RouletteSegment _selectWinningSegment() {
    final segments = widget.segments;
    
    // Calculate total probability
    final totalProbability = segments.fold<double>(
      0.0,
      (sum, segment) => sum + segment.probability,
    );
    
    // Generate random number between 0 and total probability
    final random = math.Random().nextDouble() * totalProbability;
    
    // Find the segment that matches the random value
    double cumulativeProbability = 0.0;
    for (final segment in segments) {
      cumulativeProbability += segment.probability;
      if (random <= cumulativeProbability) {
        return segment;
      }
    }
    
    // Fallback to last segment (should not happen with valid probabilities)
    return segments.last;
  }

  /// Calculates the target angle to position the winning segment at the top
  double _calculateTargetAngle(RouletteSegment winningSegment) {
    final segments = widget.segments;
    final segmentIndex = segments.indexOf(winningSegment);
    
    if (segmentIndex == -1) {
      return 0.0;
    }
    
    // Calculate angle per segment
    final anglePerSegment = 2 * math.pi / segments.length;
    
    // Calculate the center angle of the winning segment
    final segmentCenterAngle = segmentIndex * anglePerSegment + anglePerSegment / 2;
    
    // We want the cursor at top (0 degrees) to point to this segment
    // So we need to rotate by (2*pi - segmentCenterAngle) to align it
    final targetAngle = (2 * math.pi - segmentCenterAngle) % (2 * math.pi);
    
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
      final startAngle = i * anglePerSegment - math.pi / 2; // Start from top
      
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
