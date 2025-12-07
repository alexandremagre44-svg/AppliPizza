// lib/builder/runtime/modules/delivery_module_client_widget.dart
// Client widget for delivery_module - user-facing delivery functionality

import 'package:flutter/material.dart';
import '../../../src/design_system/app_theme.dart';

/// Delivery Module Client Widget
/// 
/// User-facing widget for the Delivery module in the client app.
/// Allows customers to enter their delivery address and select a delivery time slot.
/// 
/// Features:
/// - Address input field
/// - Time slot selection with choice chips
/// - Material 3 compliant design
/// - Form validation (button only enabled when address and slot selected)
/// - Properly constrained for use in Builder system
class DeliveryModuleClientWidget extends StatefulWidget {
  const DeliveryModuleClientWidget({super.key});

  @override
  State<DeliveryModuleClientWidget> createState() => _DeliveryModuleClientWidgetState();
}

class _DeliveryModuleClientWidgetState extends State<DeliveryModuleClientWidget> {
  String? selectedSlot;
  final addressController = TextEditingController();

  final slots = [
    "12:00 - 12:30",
    "12:30 - 13:00",
    "19:00 - 19:30",
    "19:30 - 20:00",
  ];

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // NO SingleChildScrollView - the wrapper handles constraints
    // NO margin on Card - the wrapper handles layout to prevent conflicts
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,  // ← CRITICAL: shrink to content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Icon(Icons.delivery_dining, color: colorScheme.primary, size: 32),
                SizedBox(width: AppSpacing.md),
                Text(
                  "Livraison",
                  style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            // Address section
            Text(
              "Votre adresse",
              style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            SizedBox(height: AppSpacing.xs),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                hintText: "Saisissez votre adresse…",
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: AppSpacing.lg),
            // Time slot section
            Text(
              "Créneau de livraison",
              style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: slots.map((slot) => ChoiceChip(
                label: Text(slot),
                selected: selectedSlot == slot,
                onSelected: (selected) {
                  setState(() => selectedSlot = selected ? slot : null);
                },
              )).toList(),
            ),
            SizedBox(height: AppSpacing.lg),
            // Confirm button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (addressController.text.isNotEmpty && selectedSlot != null)
                    ? () {
                        // Safe: Check if context is still mounted before showing snackbar
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Livraison confirmée: $selectedSlot')),
                          );
                        }
                      }
                    : null,
                child: const Text("Confirmer la livraison"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
