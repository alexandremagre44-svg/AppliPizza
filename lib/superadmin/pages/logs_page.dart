// MIGRATED to WL V2 Theme - Uses theme colors
/// lib/superadmin/pages/logs_page.dart
///
/// Page des logs d'activité du module Super-Admin.
/// Affiche l'historique des actions effectuées dans le système.
library;

import 'package:flutter/material.dart';

import '../../src/design_system/colors.dart';
import '../../white_label/theme/theme_extensions.dart';

/// Page des logs d'activité du Super-Admin.
class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock logs data
    final mockLogs = [
      _LogEntry(
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        action: 'User Login',
        user: 'superadmin@delizza.com',
        details: 'Successful login from IP 192.168.1.1',
        level: 'info',
      ),
      _LogEntry(
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        action: 'Restaurant Updated',
        user: 'admin.paris@delizza.com',
        details: 'Modified settings for Pizza Delizza - Paris',
        level: 'info',
      ),
      _LogEntry(
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        action: 'Module Toggled',
        user: 'superadmin@delizza.com',
        details: 'Enabled Analytics module',
        level: 'warning',
      ),
      _LogEntry(
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        action: 'User Created',
        user: 'superadmin@delizza.com',
        details: 'Created new manager account',
        level: 'info',
      ),
      _LogEntry(
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        action: 'Permission Changed',
        user: 'superadmin@delizza.com',
        details: 'Updated roles for admin.lyon@delizza.com',
        level: 'warning',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec filtres
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activity Logs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Showing ${mockLogs.length} recent activities',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Filter placeholder
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: context.onPrimary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.outlineColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_list, size: 18, color: context.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Export placeholder
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement log export
                      debugPrint('TODO: Export logs');
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Logs list
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.onPrimary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.outlineVariant),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemCount: mockLogs.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: context.outlineVariant),
                itemBuilder: (context, index) {
                  final log = mockLogs[index];
                  return _LogListItem(log: log);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.primaryColor.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.primaryColor.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: context.primaryColor.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'TODO: Implement real-time log streaming and advanced filtering',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.primaryColor.shade700,
                      fontStyle: FontStyle.italic,
                    ),
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

/// Modèle pour une entrée de log.
class _LogEntry {
  final DateTime timestamp;
  final String action;
  final String user;
  final String details;
  final String level;

  const _LogEntry({
    required this.timestamp,
    required this.action,
    required this.user,
    required this.details,
    required this.level,
  });
}

/// Widget pour afficher une entrée de log.
class _LogListItem extends StatelessWidget {
  final _LogEntry log;

  const _LogListItem({required this.log});

  Color _getLevelColor(String level) {
    switch (level) {
      case 'error':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return context.primaryColor;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level indicator
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: _getLevelColor(log.level),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      log.action,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${log.user}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.details,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
          // Timestamp
          Text(
            _formatTimestamp(log.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}
