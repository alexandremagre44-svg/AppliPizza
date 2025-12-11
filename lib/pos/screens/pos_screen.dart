/// POS Screen - Main entry point for the POS system
/// 
/// This screen automatically routes to either desktop or mobile layout
/// based on screen width.
library;

import 'package:flutter/material.dart';
import 'pos_screen_desktop.dart';
import 'pos_screen_mobile.dart';

/// Main POS Screen with responsive routing
class PosScreen extends StatelessWidget {
  const PosScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Route to desktop or mobile based on screen width
        if (constraints.maxWidth >= 800) {
          return const PosScreenDesktop();
        } else {
          return const PosScreenMobile();
        }
      },
    );
  }
}
