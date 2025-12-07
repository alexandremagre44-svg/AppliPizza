import 'package:flutter/material.dart';

/// Standard wrapper for all White-Label modules
/// 
/// Ensures proper layout constraints for modules rendered within the Builder grid.
/// - maxWidth: 600px (prevents infinite width)
/// - IntrinsicHeight: ensures proper height calculation
/// - Center: centers the module horizontally
/// 
/// All WL modules MUST be wrapped with this to avoid layout issues like:
/// - "Cannot hit test a render box with no size"
/// - Infinite constraint errors
/// - Scroll conflicts with parent ListView
class WLModuleWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  
  const WLModuleWrapper({
    required this.child,
    this.maxWidth = 600,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: IntrinsicHeight(child: child),
      ),
    );
  }
}
