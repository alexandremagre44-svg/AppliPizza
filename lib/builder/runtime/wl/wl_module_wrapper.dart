import 'package:flutter/material.dart';

/// Standard wrapper for all White-Label modules
/// 
/// Ensures proper layout constraints for modules rendered within the Builder grid.
/// - maxWidth: 600px (prevents infinite width)
/// - minWidth/minHeight: 0 (allows shrinking)
/// - Align: centers the module horizontally
/// 
/// All WL modules MUST be wrapped with this to avoid layout issues like:
/// - "Cannot hit test a render box with no size"
/// - Infinite constraint errors
/// - Scroll conflicts with parent ListView
/// 
/// IMPORTANT: This wrapper does ONLY layout. No BuildContext manipulation,
/// no global keys, no navigation, no overlay, no inherited widgets.
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
    // Ultra-simple layout wrapper - no IntrinsicHeight to avoid layout issues
    // Just constrain width and center horizontally
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          minWidth: 0,
          minHeight: 0,
        ),
        child: child,
      ),
    );
  }
}
