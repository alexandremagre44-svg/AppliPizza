// MIGRATED to WL V2 Theme - Uses theme colors
/// lib/superadmin/pages/restaurant_create_wizard.dart
///
/// Wizard de création d'un nouveau restaurant dans le module Super-Admin.
/// Permet de créer un restaurant étape par étape.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../src/design_system/colors.dart';
import '../../white_label/theme/theme_extensions.dart';

/// Page wizard de création de restaurant du Super-Admin.
class RestaurantCreateWizard extends StatelessWidget {
  const RestaurantCreateWizard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb / Back button
          Row(
            children: [
              TextButton.icon(
                onPressed: () => context.go('/superadmin/restaurants'),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back to restaurants'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Wizard placeholder
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: context.onPrimary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.outlineVariant),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.add_business,
                    size: 40,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Create New Restaurant',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Follow the wizard to configure a new restaurant',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                // Wizard steps placeholder
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.outlineVariant),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.construction, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'TODO: Implement Restaurant Creation Wizard',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Steps: Basic Info → Configuration → Modules → Users → Review',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
