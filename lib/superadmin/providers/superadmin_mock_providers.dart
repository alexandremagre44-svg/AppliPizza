/// lib/superadmin/providers/superadmin_mock_providers.dart
///
/// Providers Riverpod mock pour le module Super-Admin.
/// Ces providers retournent des données mock simples pour le développement.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/restaurant_meta.dart';
import '../models/user_admin_meta.dart';
import '../models/module_meta.dart';
import '../services_mock/mock_restaurant_service.dart';
import '../services_mock/mock_user_service.dart';
import '../services_mock/mock_stats_service.dart';

// =============================================================================
// Services Providers
// =============================================================================

/// Provider pour le service mock des restaurants.
final mockRestaurantServiceProvider = Provider<MockRestaurantService>((ref) {
  return MockRestaurantService();
});

/// Provider pour le service mock des utilisateurs.
final mockUserServiceProvider = Provider<MockUserService>((ref) {
  return MockUserService();
});

/// Provider pour le service mock des statistiques.
final mockStatsServiceProvider = Provider<MockStatsService>((ref) {
  return MockStatsService();
});

// =============================================================================
// Data Providers
// =============================================================================

/// Provider qui retourne la liste mock des restaurants.
final mockRestaurantsProvider = Provider<List<RestaurantMeta>>((ref) {
  final service = ref.watch(mockRestaurantServiceProvider);
  return service.getAllRestaurants();
});

/// Provider qui retourne la liste mock des utilisateurs.
final mockUsersProvider = Provider<List<UserAdminMeta>>((ref) {
  final service = ref.watch(mockUserServiceProvider);
  return service.getAllUsers();
});

/// Provider qui retourne les statistiques mock globales.
final mockStatsProvider = Provider<MockStats>((ref) {
  final service = ref.watch(mockStatsServiceProvider);
  return service.getGlobalStats();
});

// =============================================================================
// Modules Providers
// =============================================================================

/// Liste mock des modules disponibles.
final mockModulesProvider = Provider<List<ModuleMeta>>((ref) {
  return const [
    ModuleMeta(name: 'Roulette', enabled: true),
    ModuleMeta(name: 'Loyalty', enabled: true),
    ModuleMeta(name: 'Kitchen Display', enabled: true),
    ModuleMeta(name: 'Staff Tablet', enabled: true),
    ModuleMeta(name: 'Delivery Tracking', enabled: false),
    ModuleMeta(name: 'Analytics', enabled: false),
    ModuleMeta(name: 'Multi-language', enabled: false),
    ModuleMeta(name: 'Push Notifications', enabled: true),
  ];
});

// =============================================================================
// Navigation State Provider
// =============================================================================

/// Provider pour stocker le titre de la page courante dans le header.
final currentPageTitleProvider = StateProvider<String>((ref) {
  return 'Dashboard';
});
