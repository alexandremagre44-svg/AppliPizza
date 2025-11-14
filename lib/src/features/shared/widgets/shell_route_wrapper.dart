// lib/src/widgets/shell_route_wrapper.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellRouteWrapper extends StatelessWidget {
  final Widget body;
  final String currentPath;

  const ShellRouteWrapper({
    super.key,
    required this.body,
    required this.currentPath,
  });

  // Associe le chemin d'accès à l'index de la barre
  int _getSelectedIndex(String path) {
    if (path.startsWith('/home')) return 0;
    if (path.startsWith('/menu')) return 1;
    if (path.startsWith('/favorites')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0; // Défaut: Accueil
  }

  void _onItemTapped(BuildContext context, int index) {
    // Liste des chemins d'accès (l'ordre doit correspondre aux BottomNavigationBarItems)
    const tabs = ['/home', '/menu', '/favorites', '/profile'];
    // Navigue vers la nouvelle destination en utilisant GoRouter
    context.go(tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // L'écran enfant (HomeScreen, MenuScreen, etc.) sera affiché ici
      body: body, 
      
      // La BottomNavigationBar est ajoutée une seule fois ici
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getSelectedIndex(currentPath),
        onTap: (index) => _onItemTapped(context, index),
        selectedItemColor: const Color(0xFFB00020), // Couleur de la marque (rouge)
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}