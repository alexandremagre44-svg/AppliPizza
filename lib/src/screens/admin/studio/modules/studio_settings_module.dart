// Stub - Settings module
import 'package:flutter/material.dart';
import '../../../../models/home_layout_config.dart';

class StudioSettingsModule extends StatelessWidget {
  final HomeLayoutConfig? draftLayoutConfig;
  final Function(HomeLayoutConfig) onUpdate;

  const StudioSettingsModule({
    super.key,
    required this.draftLayoutConfig,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Module Paramètres - En cours de développement'));
  }
}
