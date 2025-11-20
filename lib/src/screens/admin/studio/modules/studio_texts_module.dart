// Stub - Texts module
import 'package:flutter/material.dart';
import '../../../../models/app_texts_config.dart';

class StudioTextsModule extends StatelessWidget {
  final AppTextsConfig? draftTextsConfig;
  final Function(AppTextsConfig) onUpdate;

  const StudioTextsModule({
    super.key,
    required this.draftTextsConfig,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Module Textes - En cours de développement'));
  }
}
