// MIGRATED to WL V2 Theme - Uses theme colors
/// lib/superadmin/pages/restaurant_detail_page.dart
///
/// Page détail d'un restaurant du module Super-Admin.
/// Affiche les informations complètes d'un restaurant.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/superadmin_restaurants_provider.dart';
import '../models/restaurant_meta.dart';
import '../../white_label/core/module_id.dart';
import '../../white_label/core/module_registry.dart';

/// Page détail d'un restaurant du Super-Admin.
class RestaurantDetailPage extends ConsumerWidget {
  /// Identifiant du restaurant à afficher.
  final String restaurantId;

  const RestaurantDetailPage({
    super.key,
    required this.restaurantId,
  });

  Color _getStatusColor(RestaurantStatus status) {
    switch (status) {
      case RestaurantStatus.active:
        return AppColors.success;
      case RestaurantStatus.pending:
        return AppColors.warning;
      case RestaurantStatus.suspended:
        return AppColors.error;
      case RestaurantStatus.archived:
        return Colors.grey;
      case RestaurantStatus.draft:
        return context.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(superAdminRestaurantDocProvider(restaurantId));
    final unifiedPlanAsync = ref.watch(superAdminRestaurantUnifiedPlanProvider(restaurantId));

    // Handle loading state
    if (restaurantAsync.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Handle error or not found
    if (restaurantAsync.hasError || restaurantAsync.value == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Restaurant not found: $restaurantId',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (restaurantAsync.hasError) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  restaurantAsync.error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colorScheme.surfaceVariant // was Colors.grey.shade600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/superadmin/restaurants'),
              child: const Text('Back to list'),
            ),
          ],
        ),
      );
    }

    final restaurant = restaurantAsync.value!;

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
          // Restaurant info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.onPrimary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colorScheme.surfaceVariant // was Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceVariant // was Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        size: 32,
                        color: context.colorScheme.surfaceVariant // was Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  restaurant.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(restaurant.status)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  restaurant.status.value.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(restaurant.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurant.brandName,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colorScheme.surfaceVariant // was Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                // Details
                _DetailRow(label: 'ID', value: restaurant.id),
                _DetailRow(label: 'Slug', value: restaurant.slug),
                _DetailRow(label: 'Brand', value: restaurant.brandName),
                _DetailRow(label: 'Type', value: restaurant.type),
                _DetailRow(
                  label: 'Template',
                  value: restaurant.templateId ?? 'None',
                ),
                _DetailRow(
                  label: 'Created At',
                  value:
                      '${restaurant.createdAt.day}/${restaurant.createdAt.month}/${restaurant.createdAt.year}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Modules section
          unifiedPlanAsync.when(
            data: (unifiedPlan) {
              if (unifiedPlan == null) {
                // Plan unifié manquant
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.warning.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning.shade700,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plan unifié manquant',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ce restaurant utilise un plan legacy. Les modules et configurations détaillées ne sont pas disponibles.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.warning.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Afficher les modules depuis le plan unifié
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.onPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colorScheme.surfaceVariant // was Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enabled Modules',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (unifiedPlan.activeModules.isEmpty)
                      Text(
                        'No modules enabled',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colorScheme.surfaceVariant // was Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      _ModulesGrid(activeModules: unifiedPlan.activeModules),
                  ],
                ),
              );
            },
            loading: () => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.onPrimary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colorScheme.surfaceVariant // was Colors.grey.shade200),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.shade200),
              ),
              child: Text(
                'Error loading plan: $error',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.error.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Branding section
          unifiedPlanAsync.when(
            data: (unifiedPlan) {
              if (unifiedPlan?.branding == null) {
                return const SizedBox.shrink();
              }

              final branding = unifiedPlan!.branding!;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.onPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colorScheme.surfaceVariant // was Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Branding',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (branding.brandName != null)
                      _DetailRow(
                        label: 'Nom de marque',
                        value: branding.brandName!,
                      ),
                    if (branding.accentColor != null)
                      _ColorDetailRow(
                        label: 'Accent color',
                        colorHex: branding.accentColor!,
                      ),
                    if (branding.primaryColor != null)
                      _ColorDetailRow(
                        label: 'Primary color',
                        colorHex: branding.primaryColor!,
                      ),
                    _DetailRow(
                      label: 'Mode sombre',
                      value: branding.darkModeEnabled ? 'Activé' : 'Désactivé',
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          // Debug/Info section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceVariant // was Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colorScheme.surfaceVariant // was Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Debug Info',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'Restaurant ID',
                  value: restaurantId,
                ),
                unifiedPlanAsync.when(
                  data: (plan) => _DetailRow(
                    label: 'Plan unifié',
                    value: plan != null ? '✓ Présent' : '✗ Manquant',
                  ),
                  loading: () => _DetailRow(
                    label: 'Plan unifié',
                    value: 'Chargement...',
                  ),
                  error: (_, __) => _DetailRow(
                    label: 'Plan unifié',
                    value: '✗ Erreur',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Actions buttons
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.onPrimary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colorScheme.surfaceVariant // was Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // Modules button
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go(
                          '/superadmin/restaurants/${restaurant.id}/modules'
                          '?name=${Uri.encodeComponent(restaurant.name)}',
                        );
                      },
                      icon: const Icon(Icons.extension, size: 18),
                      label: const Text('Gérer les modules'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        foregroundColor: context.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    // Theme button
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go(
                          '/superadmin/restaurants/${restaurant.id}/theme'
                          '?name=${Uri.encodeComponent(restaurant.name)}',
                        );
                      },
                      icon: const Icon(Icons.palette, size: 18),
                      label: const Text('Éditer le thème'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: context.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    // Diagnostic WL button
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go(
                          '/superadmin/restaurants/${restaurant.id}/diagnostic',
                        );
                      },
                      icon: const Icon(Icons.bug_report, size: 18),
                      label: const Text('Diagnostic WL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: context.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    // TODO: Add more action buttons
                    OutlinedButton.icon(
                      onPressed: null, // TODO: implement
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Modifier'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: null, // TODO: implement
                      icon: const Icon(Icons.people, size: 18),
                      label: const Text('Utilisateurs'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher une ligne de détail.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: context.colorScheme.surfaceVariant // was Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher une ligne de détail avec couleur.
class _ColorDetailRow extends StatelessWidget {
  final String label;
  final String colorHex;

  const _ColorDetailRow({
    required this.label,
    required this.colorHex,
  });

  Color _parseColor(String hex) {
    // Parse une couleur hex en Color Flutter
    // Supporte les formats: #RGB, #RRGGBB, #AARRGGBB
    try {
      String hexColor = hex.replaceAll('#', '').toUpperCase();
      
      if (hexColor.length == 6) {
        // Format RRGGBB -> ajouter l'alpha FF
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        // Format AARRGGBB
        return Color(int.parse(hexColor, radix: 16));
      } else if (hexColor.length == 3) {
        // Format RGB -> RRGGBB
        hexColor = hexColor.split('').map((c) => c + c).join();
        return Color(int.parse('FF$hexColor', radix: 16));
      }
    } on FormatException catch (_) {
      // Couleur invalide
    }
    return context.colorScheme.surfaceVariant // was Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: context.colorScheme.surfaceVariant // was Colors.grey.shade600,
              ),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _parseColor(colorHex),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: context.colorScheme.surfaceVariant // was Colors.grey.shade300),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              colorHex,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher la grille de modules actifs.
class _ModulesGrid extends StatelessWidget {
  final List<String> activeModules;

  const _ModulesGrid({required this.activeModules});

  String _getModuleLabel(String moduleCode) {
    // Cherche le module dans le registre
    final moduleId = ModuleId.values.where((m) => m.code == moduleCode).firstOrNull;
    if (moduleId != null) {
      return moduleId.label;
    }
    // Si le module n'est pas trouvé dans le registry, retourner le code
    return moduleCode;
  }

  @override
  Widget build(BuildContext context) {
    // Construire la liste de tous les modules avec leur statut
    final allModules = ModuleId.values.map((moduleId) {
      final isActive = activeModules.contains(moduleId.code);
      return {
        'id': moduleId,
        'code': moduleId.code,
        'label': moduleId.label,
        'active': isActive,
      };
    }).toList();

    return Column(
      children: allModules.map((module) {
        final isActive = module['active'] as bool;
        final label = module['label'] as String;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.cancel,
                size: 20,
                color: isActive ? AppColors.success : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive
                        ? const Color(0xFF1A1A2E)
                        : context.colorScheme.surfaceVariant // was Colors.grey.shade500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.success.shade50
                      : context.colorScheme.surfaceVariant // was Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? AppColors.success.shade700
                        : context.colorScheme.surfaceVariant // was Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
