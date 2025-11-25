// lib/builder/runtime/modules/roulette_module_widget.dart
// Runtime widget for roulette_module
// 
// Wraps the existing RouletteScreen for use in Builder system

import 'package:flutter/material.dart';
import '../../../src/screens/roulette/roulette_screen.dart';

/// Roulette Module Widget
/// 
/// Wraps the existing RouletteScreen to make it usable as a Builder module
/// Note: RouletteScreen includes its own Scaffold, so this is a full-screen widget
class RouletteModuleWidget extends StatelessWidget {
  const RouletteModuleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the existing RouletteScreen widget
    // RouletteScreen has its own Scaffold with AppBar, so it's a complete screen
    return const RouletteScreen();
  }
}
