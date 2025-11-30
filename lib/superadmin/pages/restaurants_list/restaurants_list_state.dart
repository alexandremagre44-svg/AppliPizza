/// lib/superadmin/pages/restaurants_list/restaurants_list_state.dart
///
/// State management pour la liste des restaurants créés via le Wizard.
/// Utilise StateNotifier pour gérer l'état en mémoire (100% mock).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/restaurant_blueprint.dart';

/// État de la liste des restaurants.
class RestaurantListState {
  /// Liste des restaurants.
  final List<RestaurantBlueprintLight> restaurants;

  /// Indique si un chargement est en cours.
  final bool isLoading;

  /// Message d'erreur éventuel.
  final String? error;

  /// Terme de recherche actuel.
  final String searchQuery;

  /// Filtre par type de restaurant.
  final RestaurantType? filterType;

  /// Constructeur principal.
  const RestaurantListState({
    this.restaurants = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filterType,
  });

  /// Factory pour créer un état initial avec des données mock.
  factory RestaurantListState.initial() {
    return RestaurantListState(
      restaurants: _generateMockRestaurants(),
    );
  }

  /// Crée une copie avec des valeurs modifiées.
  RestaurantListState copyWith({
    List<RestaurantBlueprintLight>? restaurants,
    bool? isLoading,
    String? error,
    String? searchQuery,
    RestaurantType? filterType,
    bool clearFilter = false,
  }) {
    return RestaurantListState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: clearFilter ? null : (filterType ?? this.filterType),
    );
  }

  /// Liste filtrée selon les critères de recherche et de type.
  List<RestaurantBlueprintLight> get filteredRestaurants {
    return restaurants.where((restaurant) {
      // Filtre par recherche (nom, slug, brand)
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesName = restaurant.name.toLowerCase().contains(query);
        final matchesSlug = restaurant.slug.toLowerCase().contains(query);
        final matchesBrand =
            restaurant.brand.brandName.toLowerCase().contains(query);
        if (!matchesName && !matchesSlug && !matchesBrand) {
          return false;
        }
      }

      // Filtre par type
      if (filterType != null && restaurant.type != filterType) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Nombre total de restaurants.
  int get totalCount => restaurants.length;

  /// Nombre de restaurants filtrés.
  int get filteredCount => filteredRestaurants.length;

  /// Vérifie si des filtres sont actifs.
  bool get hasActiveFilters => searchQuery.isNotEmpty || filterType != null;
}

/// Génère des restaurants mock pour la démo.
List<RestaurantBlueprintLight> _generateMockRestaurants() {
  return [
    RestaurantBlueprintLight(
      id: 'resto-001',
      name: 'La Bella Napoli',
      slug: 'bella-napoli',
      type: RestaurantType.restaurant,
      templateId: 'pizzeria-classic',
      brand: const RestaurantBrandLight(
        brandName: 'Bella Napoli',
        primaryColor: '#E63946',
        secondaryColor: '#1D3557',
        accentColor: '#F1FAEE',
        logoUrl: 'https://example.com/bella-napoli-logo.png',
      ),
      modules: const RestaurantModulesLight(
        ordering: true,
        delivery: true,
        clickAndCollect: true,
        payments: true,
        loyalty: true,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    RestaurantBlueprintLight(
      id: 'resto-002',
      name: 'Speed Burger',
      slug: 'speed-burger',
      type: RestaurantType.snack,
      templateId: 'fast-food-modern',
      brand: const RestaurantBrandLight(
        brandName: 'Speed Burger',
        primaryColor: '#FF6B35',
        secondaryColor: '#004E89',
        accentColor: '#FCBF49',
      ),
      modules: const RestaurantModulesLight(
        ordering: true,
        delivery: true,
        payments: true,
        kitchenTablet: true,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    RestaurantBlueprintLight(
      id: 'resto-003',
      name: 'Sushi Express',
      slug: 'sushi-express',
      type: RestaurantType.snackDelivery,
      templateId: 'asian-delivery',
      brand: const RestaurantBrandLight(
        brandName: 'Sushi Express',
        primaryColor: '#2D3047',
        secondaryColor: '#E84855',
        accentColor: '#FFFD82',
      ),
      modules: const RestaurantModulesLight(
        ordering: true,
        delivery: true,
        clickAndCollect: true,
        payments: true,
        roulette: true,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    RestaurantBlueprintLight(
      id: 'resto-004',
      name: 'Le Gourmet',
      slug: 'le-gourmet',
      type: RestaurantType.restaurant,
      templateId: 'premium-restaurant',
      brand: const RestaurantBrandLight(
        brandName: 'Le Gourmet',
        primaryColor: '#1A1A2E',
        secondaryColor: '#C5A880',
        accentColor: '#EAEAEA',
        logoUrl: 'https://example.com/gourmet-logo.png',
      ),
      modules: const RestaurantModulesLight(
        ordering: true,
        payments: true,
        loyalty: true,
        staffTablet: true,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    RestaurantBlueprintLight(
      id: 'resto-005',
      name: 'Tacos Locos',
      slug: 'tacos-locos',
      type: RestaurantType.snack,
      templateId: null, // Template personnalisé
      brand: const RestaurantBrandLight(
        brandName: 'Tacos Locos',
        primaryColor: '#F72585',
        secondaryColor: '#7209B7',
        accentColor: '#4CC9F0',
      ),
      modules: const RestaurantModulesLight(
        ordering: true,
        delivery: true,
        clickAndCollect: true,
        payments: true,
        kitchenTablet: true,
        staffTablet: true,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}

/// Notifier pour gérer l'état de la liste des restaurants.
class RestaurantListNotifier extends StateNotifier<RestaurantListState> {
  RestaurantListNotifier() : super(RestaurantListState.initial());

  /// Ajoute un nouveau restaurant à la liste.
  void addRestaurant(RestaurantBlueprintLight restaurant) {
    // Génère un ID si nécessaire
    final newRestaurant = restaurant.copyWith(
      id: restaurant.id.isEmpty
          ? 'resto-${DateTime.now().millisecondsSinceEpoch}'
          : null,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      restaurants: [...state.restaurants, newRestaurant],
    );
  }

  /// Supprime un restaurant par son ID.
  void removeRestaurant(String id) {
    state = state.copyWith(
      restaurants: state.restaurants.where((r) => r.id != id).toList(),
    );
  }

  /// Met à jour un restaurant existant.
  void updateRestaurant(RestaurantBlueprintLight restaurant) {
    final updatedRestaurant = restaurant.copyWith(
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      restaurants: state.restaurants.map((r) {
        return r.id == restaurant.id ? updatedRestaurant : r;
      }).toList(),
    );
  }

  /// Récupère un restaurant par son ID.
  RestaurantBlueprintLight? getRestaurantById(String id) {
    try {
      return state.restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Met à jour le terme de recherche.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Met à jour le filtre par type.
  void setFilterType(RestaurantType? type) {
    if (type == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterType: type);
    }
  }

  /// Efface tous les filtres.
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      clearFilter: true,
    );
  }

  /// Duplique un restaurant existant.
  void duplicateRestaurant(String id) {
    final original = getRestaurantById(id);
    if (original == null) return;

    final duplicate = original.copyWith(
      id: 'resto-${DateTime.now().millisecondsSinceEpoch}',
      name: '${original.name} (copie)',
      slug: '${original.slug}-copy',
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    state = state.copyWith(
      restaurants: [...state.restaurants, duplicate],
    );
  }

  /// Réinitialise la liste avec les données mock.
  void reset() {
    state = RestaurantListState.initial();
  }
}

/// Provider pour la liste des restaurants.
/// Auto-dispose pour nettoyer l'état quand on quitte la page.
final restaurantListProvider =
    StateNotifierProvider.autoDispose<RestaurantListNotifier, RestaurantListState>(
  (ref) => RestaurantListNotifier(),
);

/// Provider pour récupérer un restaurant par ID.
final restaurantByIdProvider =
    Provider.autoDispose.family<RestaurantBlueprintLight?, String>((ref, id) {
  final state = ref.watch(restaurantListProvider);
  try {
    return state.restaurants.firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
});
