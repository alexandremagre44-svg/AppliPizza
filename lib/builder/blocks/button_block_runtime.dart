// lib/builder/blocks/button_block_runtime.dart
// Runtime version of ButtonBlock

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/builder_block.dart';
import '../../src/theme/app_theme.dart';
import '../../src/core/constants.dart';

class ButtonBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const ButtonBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final label = block.getConfig<String>('label') ?? 'Bouton';
    final alignment = block.getConfig<String>('alignment') ?? 'center';
    final style = block.getConfig<String>('style') ?? 'primary';
    final action = block.getConfig<String>('action') ?? 'menu';

    // Determine alignment
    Alignment widgetAlignment;
    switch (alignment) {
      case 'left':
        widgetAlignment = Alignment.centerLeft;
        break;
      case 'right':
        widgetAlignment = Alignment.centerRight;
        break;
      default:
        widgetAlignment = Alignment.center;
    }

    // Build button based on style
    Widget button;
    switch (style) {
      case 'secondary':
        button = OutlinedButton(
          onPressed: () => _handleAction(context, action),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        );
        break;
      case 'outline':
        button = OutlinedButton(
          onPressed: () => _handleAction(context, action),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
          ),
          child: Text(label),
        );
        break;
      default: // primary
        button = ElevatedButton(
          onPressed: () => _handleAction(context, action),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        );
    }

    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: Align(
        alignment: widgetAlignment,
        child: button,
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'menu':
        context.go(AppRoutes.menu);
        break;
      case 'cart':
        context.push(AppRoutes.cart);
        break;
      case 'profile':
        context.push(AppRoutes.profile);
        break;
      default:
        context.go(AppRoutes.menu);
    }
  }
}
