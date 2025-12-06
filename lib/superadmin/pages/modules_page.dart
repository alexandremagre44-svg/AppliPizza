/// lib/superadmin/pages/modules_page.dart
///
/// Page gestion des modules du module Super-Admin.
/// Affiche la liste des modules disponibles et leur état d'activation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/superadmin_mock_providers.dart';
import '../models/module_meta.dart';

/// Page gestion des modules du Super-Admin.
class ModulesPage extends ConsumerWidget {
  const ModulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(mockModulesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade300, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ MOCK PAGE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This page is not connected to the real WhiteLabel system. Use the Restaurant Modules page for actual module configuration.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Modules (Mock)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${modules.where((m) => m.enabled).length} of ${modules.length} modules enabled',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Grid de modules
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return _ModuleCard(module: module);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget carte de module.
class _ModuleCard extends StatelessWidget {
  final ModuleMeta module;

  const _ModuleCard({required this.module});

  IconData _getModuleIcon(String name) {
    switch (name.toLowerCase()) {
      case 'roulette':
        return Icons.casino;
      case 'loyalty':
        return Icons.card_giftcard;
      case 'kitchen display':
        return Icons.kitchen;
      case 'staff tablet':
        return Icons.tablet_android;
      case 'delivery tracking':
        return Icons.local_shipping;
      case 'analytics':
        return Icons.analytics;
      case 'multi-language':
        return Icons.language;
      case 'push notifications':
        return Icons.notifications;
      default:
        return Icons.extension;
    }
  }

  Color _getCategoryColor(ModuleCategory category) {
    switch (category) {
      case ModuleCategory.core:
        return Colors.blue;
      case ModuleCategory.marketing:
        return Colors.purple;
      case ModuleCategory.operations:
        return Colors.orange;
      case ModuleCategory.integration:
        return Colors.teal;
      case ModuleCategory.advanced:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = module.available;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: module.enabled ? Colors.green.shade200 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: module.enabled
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getModuleIcon(module.name),
                  size: 24,
                  color: module.enabled
                      ? Colors.green.shade600
                      : Colors.grey.shade600,
                ),
              ),
              Switch(
                value: module.enabled,
                onChanged: isAvailable
                    ? (value) {
                        // TODO: Implement module toggle
                        debugPrint('TODO: Toggle module ${module.name} to $value');
                      }
                    : null,
                activeColor: Colors.green,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  module.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isAvailable
                        ? const Color(0xFF1A1A2E)
                        : Colors.grey.shade500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor(module.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  module.category.displayName,
                  style: TextStyle(
                    fontSize: 9,
                    color: _getCategoryColor(module.category),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            module.enabled 
                ? 'Enabled' 
                : (isAvailable ? 'Disabled' : 'Not available'),
            style: TextStyle(
              fontSize: 12,
              color: module.enabled 
                  ? Colors.green 
                  : (isAvailable ? Colors.grey : Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }
}
