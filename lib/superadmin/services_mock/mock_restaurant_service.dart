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
      slug: 'pizza-delizza-paris',
      brandName: 'Pizza Delizza',
      type: 'pizzeria',
      templateId: 'template-pizza-01',
      modulesEnabled: ['roulette', 'loyalty', 'kitchen'],
      status: RestaurantStatus.active,
      createdAt: DateTime(2023, 1, 15),
    ),
    RestaurantMeta(
      id: 'resto-002',
      name: 'Pizza Delizza - Lyon',
      slug: 'pizza-delizza-lyon',
      brandName: 'Pizza Delizza',
      type: 'pizzeria',
      templateId: 'template-pizza-01',
      modulesEnabled: ['roulette', 'loyalty'],
      status: RestaurantStatus.active,
      createdAt: DateTime(2023, 3, 20),
    ),
    RestaurantMeta(
      id: 'resto-003',
      name: 'Pizza Delizza - Marseille',
      slug: 'pizza-delizza-marseille',
      brandName: 'Pizza Delizza',
      type: 'pizzeria',
      templateId: 'template-pizza-01',
      modulesEnabled: ['loyalty'],
      status: RestaurantStatus.pending,
      createdAt: DateTime(2023, 6, 10),
    ),
    RestaurantMeta(
      id: 'resto-004',
      name: 'Burger Express - Paris',
      slug: 'burger-express-paris',
      brandName: 'Burger Express',
      type: 'fast-food',
      templateId: 'template-burger-01',
      modulesEnabled: ['kitchen', 'staff-tablet'],
      status: RestaurantStatus.suspended,
      createdAt: DateTime(2022, 11, 5),
    ),
    RestaurantMeta(
      id: 'resto-005',
      name: 'Pizza Delizza - Bordeaux',
      slug: 'pizza-delizza-bordeaux',
      brandName: 'Pizza Delizza',
      type: 'pizzeria',
      templateId: 'template-pizza-01',
      modulesEnabled: ['roulette', 'loyalty', 'kitchen', 'analytics'],
      status: RestaurantStatus.active,
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
  List<RestaurantMeta> getRestaurantsByStatus(RestaurantStatus status) {
    return _mockRestaurants.where((r) => r.status == status).toList();
  }

  /// Retourne les restaurants filtrés par statut (string pour compatibilité).
  List<RestaurantMeta> getRestaurantsByStatusString(String status) {
    return _mockRestaurants
        .where((r) => r.status.value == status)
        .toList();
  }

  /// Retourne les restaurants par marque.
  List<RestaurantMeta> getRestaurantsByBrand(String brandName) {
    return _mockRestaurants.where((r) => r.brandName == brandName).toList();
  }

  /// Retourne les restaurants qui ont un module spécifique activé.
  List<RestaurantMeta> getRestaurantsWithModule(String moduleName) {
    return _mockRestaurants.where((r) => r.hasModule(moduleName)).toList();
  }

  /// Retourne le nombre total de restaurants.
  int get totalCount => _mockRestaurants.length;

  /// Retourne le nombre de restaurants actifs.
  int get activeCount =>
      _mockRestaurants.where((r) => r.status == RestaurantStatus.active).length;

  /// Retourne le nombre de restaurants en attente.
  int get pendingCount =>
      _mockRestaurants.where((r) => r.status == RestaurantStatus.pending).length;

  /// Retourne le nombre de restaurants suspendus.
  int get suspendedCount =>
      _mockRestaurants.where((r) => r.status == RestaurantStatus.suspended).length;
}
