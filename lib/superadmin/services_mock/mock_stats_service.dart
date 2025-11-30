/// lib/superadmin/services_mock/mock_stats_service.dart
///
/// Service mock pour les statistiques dans le module Super-Admin.
/// Fournit des données fictives pour le développement et les tests.
library;

/// Classe représentant des statistiques globales mock.
class MockStats {
  /// Nombre total de restaurants.
  final int totalRestaurants;

  /// Nombre de restaurants actifs.
  final int activeRestaurants;

  /// Nombre total d'utilisateurs.
  final int totalUsers;

  /// Nombre de commandes du jour.
  final int todayOrders;

  /// Chiffre d'affaires du jour.
  final double todayRevenue;

  /// Nombre de modules activés.
  final int activeModules;

  const MockStats({
    required this.totalRestaurants,
    required this.activeRestaurants,
    required this.totalUsers,
    required this.todayOrders,
    required this.todayRevenue,
    required this.activeModules,
  });
}

/// Service mock pour les statistiques du tableau de bord Super-Admin.
class MockStatsService {
  /// Statistiques mock globales pour le développement.
  static const MockStats _mockStats = MockStats(
    totalRestaurants: 5,
    activeRestaurants: 3,
    totalUsers: 5,
    todayOrders: 127,
    todayRevenue: 3542.50,
    activeModules: 4,
  );

  /// Retourne les statistiques globales mock.
  MockStats getGlobalStats() {
    return _mockStats;
  }

  /// Retourne le nombre total de restaurants.
  int get totalRestaurants => _mockStats.totalRestaurants;

  /// Retourne le nombre de restaurants actifs.
  int get activeRestaurants => _mockStats.activeRestaurants;

  /// Retourne le nombre total d'utilisateurs.
  int get totalUsers => _mockStats.totalUsers;

  /// Retourne le nombre de commandes du jour.
  int get todayOrders => _mockStats.todayOrders;

  /// Retourne le chiffre d'affaires du jour.
  double get todayRevenue => _mockStats.todayRevenue;

  /// Retourne le nombre de modules activés.
  int get activeModules => _mockStats.activeModules;
}
