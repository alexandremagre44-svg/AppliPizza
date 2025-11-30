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
    ModuleMeta(
      id: 'roulette',
      name: 'Roulette',
      description: 'Interactive wheel game for customer engagement',
      category: ModuleCategory.marketing,
      enabled: true,
      available: true,
    ),
    ModuleMeta(
      id: 'loyalty',
      name: 'Loyalty',
      description: 'Customer loyalty program with points and rewards',
      category: ModuleCategory.marketing,
      enabled: true,
      available: true,
    ),
    ModuleMeta(
      id: 'kitchen-display',
      name: 'Kitchen Display',
      description: 'Real-time order display for kitchen staff',
      category: ModuleCategory.operations,
      enabled: true,
      available: true,
    ),
    ModuleMeta(
      id: 'staff-tablet',
      name: 'Staff Tablet',
      description: 'POS interface for staff order management',
      category: ModuleCategory.operations,
      enabled: true,
      available: true,
    ),
    ModuleMeta(
      id: 'delivery-tracking',
      name: 'Delivery Tracking',
      description: 'Real-time delivery tracking for customers',
      category: ModuleCategory.integration,
      enabled: false,
      available: false,
    ),
    ModuleMeta(
      id: 'analytics',
      name: 'Analytics',
      description: 'Advanced analytics and reporting dashboard',
      category: ModuleCategory.advanced,
      enabled: false,
      available: true,
    ),
    ModuleMeta(
      id: 'multi-language',
      name: 'Multi-language',
      description: 'Multi-language support for international customers',
      category: ModuleCategory.core,
      enabled: false,
      available: true,
    ),
    ModuleMeta(
      id: 'push-notifications',
      name: 'Push Notifications',
      description: 'Push notifications for orders and promotions',
      category: ModuleCategory.marketing,
      enabled: true,
      available: true,
    ),
  ];
});

// =============================================================================
// Navigation State Provider
// =============================================================================

/// Provider pour stocker le titre de la page courante dans le header.
final currentPageTitleProvider = StateProvider<String>((ref) {
  return 'Dashboard';
});
