// lib/src/widgets/scaffold_with_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalItems = ref.watch(cartProvider.select((cart) => cart.totalItems));
    final isAdmin = ref.watch(authProvider.select((auth) => auth.isAdmin));
    final currentIndex = _calculateSelectedIndex(context, isAdmin);

    // Liste des items selon le rôle - Admin en premier si admin
    final items = <BottomNavigationBarItem>[
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Accueil',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.restaurant_menu_outlined),
        activeIcon: Icon(Icons.restaurant_menu),
        label: 'Menu',
      ),
      BottomNavigationBarItem(
        icon: badges.Badge(
          showBadge: totalItems > 0,
          badgeContent: Text(
            totalItems.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          child: const Icon(Icons.shopping_cart_outlined),
        ),
        activeIcon: const Icon(Icons.shopping_cart),
        label: 'Panier',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 13,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          onTap: (int index) => _onItemTapped(context, index, isAdmin),
          items: items,
        ),
      ),
    );
  }

  // Logique pour trouver l'index de la page courante
  static int _calculateSelectedIndex(BuildContext context, bool isAdmin) {
    final String location = GoRouterState.of(context).uri.toString();
    
    // Si admin, le layout est différent (Admin en premier)
    if (isAdmin) {
      if (location.startsWith('/admin')) {
        return 0; // Admin en position 0
      }
      if (location.startsWith('/home')) {
        return 1; // Accueil en position 1
      }
      if (location.startsWith('/menu')) {
        return 2; // Menu en position 2
      }
      if (location.startsWith('/cart')) {
        return 3; // Panier en position 3
      }
      if (location.startsWith('/profile')) {
        return 4; // Profil en position 4
      }
      return 1; // Default à Accueil
    } else {
      // Layout normal pour utilisateurs non-admin
      if (location.startsWith('/home')) {
        return 0;
      }
      if (location.startsWith('/menu')) {
        return 1;
      }
      if (location.startsWith('/cart')) {
        return 2;
      }
      if (location.startsWith('/profile')) {
        return 3;
      }
      return 0;
    }
  }

  // Logique pour naviguer au clic
  void _onItemTapped(BuildContext context, int index, bool isAdmin) {
    if (isAdmin) {
      // Layout admin : Studio Builder, Accueil, Menu, Panier, Profil
      switch (index) {
        case 0:
          context.go('/admin/studio');
          break;
        case 1:
          context.go('/home');
          break;
        case 2:
          context.go('/menu');
          break;
        case 3:
          context.go('/cart');
          break;
        case 4:
          context.go('/profile');
          break;
      }
    } else {
      // Layout normal : Accueil, Menu, Panier, Profil
      switch (index) {
        case 0:
          context.go('/home');
          break;
        case 1:
          context.go('/menu');
          break;
        case 2:
          context.go('/cart');
          break;
        case 3:
          context.go('/profile');
          break;
      }
    }
  }
}
