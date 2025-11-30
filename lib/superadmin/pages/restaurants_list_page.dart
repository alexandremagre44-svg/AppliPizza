/// lib/superadmin/pages/restaurants_list_page.dart
///
/// Page liste des restaurants du module Super-Admin.
/// Affiche tous les restaurants avec leurs informations principales.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/superadmin_mock_providers.dart';
import '../models/restaurant_meta.dart';

/// Page liste des restaurants du Super-Admin.
class RestaurantsListPage extends ConsumerWidget {
  const RestaurantsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(mockRestaurantsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Actions header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${restaurants.length} restaurants',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/superadmin/restaurants/create');
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Restaurant'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Liste des restaurants
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemCount: restaurants.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  return _RestaurantListItem(restaurant: restaurant);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget item de la liste des restaurants.
class _RestaurantListItem extends StatelessWidget {
  final RestaurantMeta restaurant;

  const _RestaurantListItem({required this.restaurant});

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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go('/superadmin/restaurants/${restaurant.id}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.restaurant,
                size: 24,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${restaurant.brandName} • ${restaurant.type}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Modules count badge
            if (restaurant.modulesEnabled.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${restaurant.modulesEnabled.length} modules',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(restaurant.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
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
            const SizedBox(width: 12),
            // Arrow
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
