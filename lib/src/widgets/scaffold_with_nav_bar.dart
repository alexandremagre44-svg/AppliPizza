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

    // Liste des items selon le rôle
    final items = <BottomNavigationBarItem>[
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
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
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
    if (location.startsWith('/admin') && isAdmin) {
      return 4;
    }
    return 0;
  }

  // Logique pour naviguer au clic
  void _onItemTapped(BuildContext context, int index, bool isAdmin) {
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
      case 4:
        if (isAdmin) {
          context.go('/admin');
        }
        break;
    }
  }
}
