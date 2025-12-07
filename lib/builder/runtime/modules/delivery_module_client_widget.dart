// lib/builder/runtime/modules/delivery_module_client_widget.dart
// Client widget for delivery_module - user-facing delivery functionality

import 'package:flutter/material.dart';
import '../../../src/design_system/app_theme.dart';

/// Delivery Client Widget
/// 
/// User-facing widget for the Delivery module in the client app.
/// Allows customers to enter their delivery address and select a delivery time slot.
/// 
/// Features:
/// - Address input field
/// - Time slot selection with choice chips
/// - Material 3 compliant design
/// - Form validation (button only enabled when address and slot selected)
class DeliveryClientWidget extends StatefulWidget {
  const DeliveryClientWidget({super.key});

  @override
  State<DeliveryClientWidget> createState() => _DeliveryClientWidgetState();
}

class _DeliveryClientWidgetState extends State<DeliveryClientWidget> {
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
    // Design System Usage:
    // - AppColors: Use static constants directly (e.g., AppColors.primary)
    // - AppTextStyles: Use static constants directly (e.g., AppTextStyles.titleLarge)
    // - AppRadius: Use static constants directly (e.g., AppRadius.card)
    // - AppSpacing: Use static constants directly (e.g., AppSpacing.lg)
    // NO .of(context) method exists - these are all static classes with constants
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
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
            SizedBox(height: AppSpacing.sm),

            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: slots.map((slot) {
                final selected = slot == selectedSlot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: selected,
                  onSelected: (_) => setState(() => selectedSlot = slot),
                  selectedColor: colorScheme.primary.withOpacity(0.2),
                  checkmarkColor: colorScheme.primary,
                );
              }).toList(),
            ),

            SizedBox(height: AppSpacing.xl),

            // Validation button
            FilledButton(
              onPressed: (addressController.text.isNotEmpty &&
                      selectedSlot != null)
                  ? () {
                      // TODO: Handle delivery validation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Livraison confirmée pour ${addressController.text} à $selectedSlot',
                          ),
                        ),
                      );
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
              ),
              child: const Text("Valider la livraison"),
            )
          ],
        ),
      ),
    );
  }
}
