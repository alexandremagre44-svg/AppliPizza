/// lib/superadmin/pages/restaurant_detail_page.dart
///
/// Page détail d'un restaurant du module Super-Admin.
/// Affiche les informations complètes d'un restaurant.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/superadmin_mock_providers.dart';
import '../models/restaurant_meta.dart';

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
        return Colors.green;
      case RestaurantStatus.pending:
        return Colors.orange;
      case RestaurantStatus.suspended:
        return Colors.red;
      case RestaurantStatus.archived:
        return Colors.grey;
      case RestaurantStatus.draft:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(mockRestaurantsProvider);
    final restaurant = restaurants.where((r) => r.id == restaurantId).firstOrNull;

    if (restaurant == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Restaurant not found: $restaurantId',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/superadmin/restaurants'),
              child: const Text('Back to list'),
            ),
          ],
        ),
      );
    }

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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
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
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        size: 32,
                        color: Colors.grey.shade600,
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
                              color: Colors.grey.shade600,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
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
                if (restaurant.modulesEnabled.isEmpty)
                  Text(
                    'No modules enabled',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: restaurant.modulesEnabled.map((module) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          module,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      );
                    }).toList(),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
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
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
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
                color: Colors.grey.shade600,
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
