// lib/src/studio/widgets/studio_v2_widget.dart
// Reusable Studio V2 Widget - Wraps the Studio V2 functionality in a widget

import 'package:flutter/material.dart';
import '../screens/studio_v2_screen.dart';

/// Reusable Studio V2 Widget
/// 
/// This widget wraps the StudioV2Screen to make it more accessible
/// and reusable throughout the application. It can be embedded in
/// different contexts (full screen, dialog, etc.)
class StudioV2Widget extends StatelessWidget {
  const StudioV2Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudioV2Screen();
  }
}

/// Helper method to open Studio V2 in a full screen dialog
void openStudioV2Dialog(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const StudioV2Widget(),
      fullscreenDialog: true,
    ),
  );
}

/// Helper method to open Studio V2 in a modal bottom sheet (for tablets)
void openStudioV2BottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const StudioV2Widget(),
  );
}
