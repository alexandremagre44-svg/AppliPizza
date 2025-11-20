// Stub - Popups module
import 'package:flutter/material.dart';
import '../../../../models/popup_config.dart';

class StudioPopupsModule extends StatelessWidget {
  final List<PopupConfig> draftPopups;
  final Function(List<PopupConfig>) onUpdate;

  const StudioPopupsModule({
    super.key,
    required this.draftPopups,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Module Popups - En cours de développement'));
  }
}
