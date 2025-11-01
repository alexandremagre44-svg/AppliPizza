// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Importez vos écrans
import 'src/screens/home/home_screen.dart'; 
import 'src/screens/menu/menu_screen.dart'; 
import 'src/screens/cart/cart_screen.dart'; 
import 'src/screens/profile/profile_screen.dart'; 
import 'src/screens/product_detail/product_detail_screen.dart'; 

// Importez le composant de barre de navigation (maintenant créé)
import 'src/widgets/scaffold_with_nav_bar.dart'; 
import 'src/models/product.dart'; 

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Définir le thème de base
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFB00020), // Rouge principal
        primary: const Color(0xFFB00020),
        secondary: const Color(0xFFFFC107), // Jaune/Ambre
      ),
      scaffoldBackgroundColor: Colors.grey[50],
      useMaterial3: true,
      // Thème des textes
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
      ),
    );

    // 2. CORRECTION : Utiliser copyWith pour créer le CardThemeData à partir du thème de base.
    final finalTheme = baseTheme.copyWith(
      cardTheme: baseTheme.cardTheme.copyWith( // Ceci garantit que l'objet est de type CardThemeData
        elevation: 4,
        shape: const RoundedRectangleBorder( 
            borderRadius: BorderRadius.all(Radius.circular(12)), 
        ),
      ),
    );

    return MaterialApp.router(
      title: 'Pizza Deli\'Zza',
      theme: finalTheme, // Utilisation du thème corrigé
      routerConfig: _router,
    );
  }
}

// Configuration de la navigation GoRouter
final _router = GoRouter(
  initialLocation: '/home',
  routes: [
    // 1. ShellRoute pour les écrans AVEC barre de navigation
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child); 
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MenuScreen(),
        ),
        GoRoute(
          path: '/cart', 
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    // 2. Route Indépendante pour l'écran de Détail
    GoRoute(
      path: '/details',
      builder: (context, state) {
        final product = state.extra as Product; 
        return ProductDetailScreen(product: product);
      },
    ),
  ],
);