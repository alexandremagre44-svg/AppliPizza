// MIGRATED to WL V2 Theme - Uses theme colors
/// lib/superadmin/pages/settings_page.dart
///
/// Page paramètres du module Super-Admin.
/// Permet de configurer les paramètres globaux du système.
library;

import 'package:flutter/material.dart';

import '../../src/design_system/colors.dart';
import '../../white_label/theme/theme_extensions.dart';

/// Page paramètres du Super-Admin.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 24),
          // Settings sections placeholder
          _SettingsSection(
            title: 'General',
            icon: Icons.settings,
            children: const [
              _SettingsPlaceholderItem(label: 'Platform Name'),
              _SettingsPlaceholderItem(label: 'Default Language'),
              _SettingsPlaceholderItem(label: 'Timezone'),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Security',
            icon: Icons.security,
            children: const [
              _SettingsPlaceholderItem(label: 'Two-Factor Authentication'),
              _SettingsPlaceholderItem(label: 'Session Timeout'),
              _SettingsPlaceholderItem(label: 'Password Policy'),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Notifications',
            icon: Icons.notifications,
            children: const [
              _SettingsPlaceholderItem(label: 'Email Notifications'),
              _SettingsPlaceholderItem(label: 'Push Notifications'),
              _SettingsPlaceholderItem(label: 'Alert Preferences'),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Integrations',
            icon: Icons.integration_instructions,
            children: const [
              _SettingsPlaceholderItem(label: 'Payment Gateway'),
              _SettingsPlaceholderItem(label: 'Email Service'),
              _SettingsPlaceholderItem(label: 'Analytics'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget section de paramètres.
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, size: 22, color: const Color(0xFF1A1A2E)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.outlineVariant),
          ...children,
        ],
      ),
    );
  }
}

/// Widget placeholder pour un item de paramètre.
class _SettingsPlaceholderItem extends StatelessWidget {
  final String label;

  const _SettingsPlaceholderItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.neutral700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'TODO',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.neutral500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
