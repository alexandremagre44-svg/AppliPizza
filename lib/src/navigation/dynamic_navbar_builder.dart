/// lib/src/navigation/dynamic_navbar_builder.dart
///
/// Constructeur dynamique de la barre de navigation basé sur les modules actifs.
///
/// Ce builder adapte la navbar selon le RestaurantPlanUnified sans modifier
/// le ScaffoldWithNavBar existant. Il filtre les onglets selon les modules.
///
/// IMPORTANT: Ce builder NE MODIFIE PAS le comportement existant.
/// Il fournit des utilitaires pour construire des navbars filtrées.
library;

import 'package:flutter/material.dart';
import '../../white_label/core/module_id.dart';
import '../../white_label/restaurant/restaurant_plan_unified.dart';
import '../../builder/models/models.dart';

/// Résultat de la construction d'items de navigation filtrés.
class FilteredNavItems {
  final List<BottomNavigationBarItem> items;
  final List<BuilderPage> pages;
  final Map<int, int> indexMapping; // mapping: filtered index -> original index

  const FilteredNavItems({
    required this.items,
    required this.pages,
    required this.indexMapping,
  });

  /// Convertit un index filtré en index original.
  int? getOriginalIndex(int filteredIndex) {
    return indexMapping[filteredIndex];
  }

  /// Retourne true si la liste est vide.
  bool get isEmpty => items.isEmpty;

  /// Retourne le nombre d'items.
  int get length => items.length;
}

/// Builder dynamique pour la barre de navigation.
///
/// Filtre les items de navigation selon les modules actifs dans le plan unifié.
class DynamicNavbarBuilder {
  /// Filtre les pages de la navbar selon les modules actifs.
  ///
  /// Supprime les pages dont le module requis n'est pas activé.
  static FilteredNavItems filterNavItems({
    required List<BuilderPage> originalPages,
    required List<BottomNavigationBarItem> originalItems,
    required RestaurantPlanUnified? plan,
  }) {
    if (plan == null || originalPages.length != originalItems.length) {
      // Si pas de plan ou tailles différentes, retourner les originaux
      return FilteredNavItems(
        items: originalItems,
        pages: originalPages,
        indexMapping: Map.fromIterable(
          List.generate(originalItems.length, (i) => i),
          key: (i) => i,
          value: (i) => i,
        ),
      );
    }

    final filteredItems = <BottomNavigationBarItem>[];
    final filteredPages = <BuilderPage>[];
    final indexMapping = <int, int>{};
    
    for (var i = 0; i < originalPages.length; i++) {
      final page = originalPages[i];
      final item = originalItems[i];
      
      // Vérifier si le module requis est actif
      final requiredModule = _getRequiredModuleForRoute(page.route);
      
      if (requiredModule == null) {
        // Pas de module requis, toujours inclure
        indexMapping[filteredItems.length] = i;
        filteredItems.add(item);
        filteredPages.add(page);
      } else {
        // Module requis, vérifier s'il est actif
        if (plan.hasModule(requiredModule)) {
          indexMapping[filteredItems.length] = i;
          filteredItems.add(item);
          filteredPages.add(page);
        }
        // Sinon, on skip cette page
      }
    }

    return FilteredNavItems(
      items: filteredItems,
      pages: filteredPages,
      indexMapping: indexMapping,
    );
  }

  /// Détermine le module requis pour une route donnée.
  ///
  /// Retourne null si la route ne nécessite pas de module spécifique.
  static ModuleId? _getRequiredModuleForRoute(String route) {
    // Routes système de base (toujours accessibles)
    if (route == '/home' ||
        route == '/menu' ||
        route == '/cart' ||
        route == '/profile' ||
        route == '/about' ||
        route == '/contact') {
      return null;
    }

    // Routes nécessitant des modules spécifiques
    if (route.startsWith('/delivery') || route == '/delivery') {
      return ModuleId.delivery;
    }
    if (route.startsWith('/rewards') || route == '/rewards') {
      return ModuleId.loyalty;
    }
    if (route.startsWith('/roulette') || route == '/roulette') {
      return ModuleId.roulette;
    }
    if (route.startsWith('/promotions') || route == '/promotions' || route == '/promo') {
      return ModuleId.promotions;
    }
    if (route.startsWith('/newsletter') || route == '/newsletter') {
      return ModuleId.newsletter;
    }
    if (route.startsWith('/kitchen') || route == '/kitchen') {
      return ModuleId.kitchen_tablet;
    }
    if (route.startsWith('/pos') || route == '/pos') {
      // Note: POS est accessible via staff_tablet OU payment_terminal
      // Cette méthode retourne staff_tablet pour compatibilité navbar
      // Pour vérifier l'accès POS complet, utiliser posRouteGuard() qui accepte les deux modules
      return ModuleId.staff_tablet;
    }

    // Route personnalisée ou inconnue, pas de module requis
    return null;
  }

  /// Vérifie si une route nécessite un module spécifique.
  static bool requiresModule(String route) {
    return _getRequiredModuleForRoute(route) != null;
  }

  /// Obtient le module requis pour une route.
  static ModuleId? getRequiredModule(String route) {
    return _getRequiredModuleForRoute(route);
  }

  /// Construit un ensemble minimal de navigation pour le fallback.
  ///
  /// Utilisé quand le plan n'est pas chargé ou en cas d'erreur.
  static FilteredNavItems buildFallbackNavItems({
    required int cartItemCount,
  }) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Accueil',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.restaurant_menu_outlined),
        label: 'Menu',
      ),
      BottomNavigationBarItem(
        icon: cartItemCount > 0
            ? Badge(
                label: Text(cartItemCount.toString()),
                child: const Icon(Icons.shopping_cart_outlined),
              )
            : const Icon(Icons.shopping_cart_outlined),
        label: 'Panier',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profil',
      ),
    ];

    // Créer des pages fictives pour le fallback
    final pages = [
      BuilderPage(
        pageKey: 'home',
        route: '/home',
        order: 0,
        name: 'Accueil',
        isActive: true,
        appId: 'fallback',
      ),
      BuilderPage(
        pageKey: 'menu',
        route: '/menu',
        order: 1,
        name: 'Menu',
        isActive: true,
        appId: 'fallback',
      ),
      BuilderPage(
        pageKey: 'cart',
        route: '/cart',
        order: 2,
        name: 'Panier',
        isActive: true,
        appId: 'fallback',
      ),
      BuilderPage(
        pageKey: 'profile',
        route: '/profile',
        order: 3,
        name: 'Profil',
        isActive: true,
        appId: 'fallback',
      ),
    ];

    return FilteredNavItems(
      items: items,
      pages: pages,
      indexMapping: {0: 0, 1: 1, 2: 2, 3: 3},
    );
  }

  /// Masque les onglets désactivés d'une navbar existante.
  ///
  /// Retourne une copie de la liste d'items avec les modules inactifs filtrés.
  static List<BottomNavigationBarItem> hideDisabledTabs({
    required List<BottomNavigationBarItem> items,
    required List<String> routes,
    required RestaurantPlanUnified? plan,
  }) {
    if (plan == null || items.length != routes.length) {
      return items;
    }

    final filteredItems = <BottomNavigationBarItem>[];

    for (var i = 0; i < items.length; i++) {
      final route = routes[i];
      final requiredModule = _getRequiredModuleForRoute(route);

      if (requiredModule == null || plan.hasModule(requiredModule)) {
        filteredItems.add(items[i]);
      }
    }

    return filteredItems;
  }

  /// Préserve l'ordre standard des onglets tout en filtrant.
  ///
  /// Garantit que l'ordre relatif des onglets reste cohérent.
  static FilteredNavItems preserveOrderWhileFiltering({
    required List<BuilderPage> pages,
    required List<BottomNavigationBarItem> items,
    required RestaurantPlanUnified? plan,
  }) {
    // Cette méthode est un alias de filterNavItems mais avec un nom explicite
    return filterNavItems(
      originalPages: pages,
      originalItems: items,
      plan: plan,
    );
  }
}
