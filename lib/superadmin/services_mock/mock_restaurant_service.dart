/// lib/superadmin/services_mock/mock_restaurant_service.dart
///
/// Service mock pour la gestion des restaurants dans le module Super-Admin.
/// Fournit des données fictives pour le développement et les tests.
library;

import '../models/restaurant_meta.dart';

/// Service mock pour les opérations sur les restaurants.
class MockRestaurantService {
  /// Liste mock de restaurants pour le développement.
  static final List<RestaurantMeta> _mockRestaurants = [
    RestaurantMeta(
      id: 'resto-001',
      name: 'Pizza Delizza - Paris',
      type: 'pizzeria',
      status: 'active',
      createdAt: DateTime(2023, 1, 15),
    ),
    RestaurantMeta(
      id: 'resto-002',
      name: 'Pizza Delizza - Lyon',
      type: 'pizzeria',
      status: 'active',
      createdAt: DateTime(2023, 3, 20),
    ),
    RestaurantMeta(
      id: 'resto-003',
      name: 'Pizza Delizza - Marseille',
      type: 'pizzeria',
      status: 'pending',
      createdAt: DateTime(2023, 6, 10),
    ),
    RestaurantMeta(
      id: 'resto-004',
      name: 'Burger Express - Paris',
      type: 'fast-food',
      status: 'inactive',
      createdAt: DateTime(2022, 11, 5),
    ),
    RestaurantMeta(
      id: 'resto-005',
      name: 'Pizza Delizza - Bordeaux',
      type: 'pizzeria',
      status: 'active',
      createdAt: DateTime(2023, 9, 1),
    ),
  ];

  /// Retourne la liste de tous les restaurants mock.
  List<RestaurantMeta> getAllRestaurants() {
    return List.unmodifiable(_mockRestaurants);
  }

  /// Retourne un restaurant par son identifiant, ou null si non trouvé.
  RestaurantMeta? getRestaurantById(String id) {
    try {
      return _mockRestaurants.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Retourne les restaurants filtrés par statut.
  List<RestaurantMeta> getRestaurantsByStatus(String status) {
    return _mockRestaurants.where((r) => r.status == status).toList();
  }

  /// Retourne le nombre total de restaurants.
  int get totalCount => _mockRestaurants.length;

  /// Retourne le nombre de restaurants actifs.
  int get activeCount =>
      _mockRestaurants.where((r) => r.status == 'active').length;

  /// Retourne le nombre de restaurants en attente.
  int get pendingCount =>
      _mockRestaurants.where((r) => r.status == 'pending').length;
}
