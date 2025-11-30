/// lib/superadmin/pages/restaurant_detail_page.dart
///
/// Page détail d'un restaurant du module Super-Admin.
/// Affiche les informations complètes d'un restaurant.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/superadmin_mock_providers.dart';

/// Page détail d'un restaurant du Super-Admin.
class RestaurantDetailPage extends ConsumerWidget {
  /// Identifiant du restaurant à afficher.
  final String restaurantId;

  const RestaurantDetailPage({
    super.key,
    required this.restaurantId,
  });

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
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${restaurant.id}',
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
                _DetailRow(label: 'Type', value: restaurant.type),
                _DetailRow(label: 'Status', value: restaurant.status),
                _DetailRow(
                  label: 'Created At',
                  value: '${restaurant.createdAt.day}/${restaurant.createdAt.month}/${restaurant.createdAt.year}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Placeholder for actions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Column(
              children: [
                Icon(Icons.construction, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'TODO: Implement Restaurant Management Actions',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '(Edit, Delete, Assign Users, Configure Modules...)',
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
