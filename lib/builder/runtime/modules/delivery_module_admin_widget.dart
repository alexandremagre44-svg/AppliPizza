// lib/builder/runtime/modules/delivery_module_admin_widget.dart
// Admin widget for delivery_module - shown in Builder UI
// 
// Full Material 3 implementation for Delivery module admin view

import 'package:flutter/material.dart';
import '../../../src/design_system/app_theme.dart';

/// Delivery Module Admin Widget
/// 
/// Theme-aware, Material 3 compliant widget for the Delivery module in Builder/Admin mode.
/// Displays a card with delivery information and configuration button.
/// This widget is shown in the Builder UI for administrators to configure delivery settings.
class DeliveryModuleAdminWidget extends StatelessWidget {
  const DeliveryModuleAdminWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Card(
        elevation: 2,
        shadowColor: AppColors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.local_shipping,
                size: 42,
                color: colorScheme.primary,
              ),

              SizedBox(height: AppSpacing.md),

              Text(
                "Livraison",
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: AppSpacing.xs),

              Text(
                "Gérez vos zones de livraison, vos frais, vos horaires et vos contraintes.",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: () {
                      // TODO: Navigate to delivery config
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    child: Text("Configurer"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
