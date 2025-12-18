// lib/src/kitchen/widgets/kitchen_status_badge.dart

import 'package:flutter/material.dart';
import '../kitchen_constants.dart';
import '../../white_label/theme/theme_extensions.dart';

/// Badge de statut pour le mode cuisine
/// Affiche le statut avec la couleur appropriée et une animation légère
class KitchenStatusBadge extends StatefulWidget {
  final String status;
  final bool animate;

  const KitchenStatusBadge({
    Key? key,
    required this.status,
    this.animate = false,
  }) : super(key: key);

  @override
  State<KitchenStatusBadge> createState() => _KitchenStatusBadgeState();
}

class _KitchenStatusBadgeState extends State<KitchenStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(KitchenStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = KitchenConstants.getStatusColor(widget.status);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animate ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: widget.animate
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
            ),
            child: Text(
              widget.status.toUpperCase(),
              style: const TextStyle(
                color: context.surfaceColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
