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
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

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
                Icon(Icons.delivery_dining, color: colors.primary, size: 32),
                SizedBox(width: AppSpacing.md),
                Text(
                  "Livraison",
                  style: text.titleLarge.copyWith(color: colors.primary),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg),

            // Address section
            Text(
              "Votre adresse",
              style: text.labelLarge.copyWith(color: colors.onSurfaceVariant),
            ),

            SizedBox(height: AppSpacing.xs),

            TextField(
              controller: addressController,
              decoration: InputDecoration(
                hintText: "Saisissez votre adresse…",
                filled: true,
                fillColor: colors.surfaceContainerLow,
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
              style: text.labelLarge.copyWith(color: colors.onSurfaceVariant),
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
                  selectedColor: colors.primary.withOpacity(0.2),
                  checkmarkColor: colors.primary,
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
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
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
