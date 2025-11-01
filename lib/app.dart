import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'src/screens/cart/cart_screen.dart';
import 'src/screens/home/home_screen.dart';
import 'src/screens/menu/menu_screen.dart';
import 'src/screens/profile/profile_screen.dart';
import 'src/screens/main_shell.dart';

// Gestionnaire d'état de la navigation
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Configuration du routeur (utilise ShellRoute pour le BottomNav)
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // MainShell gère la BottomNavigationBar
          return MainShell(child: child); 
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
      // Ajoutez ici des routes modales ou des pages sans BottomNav si nécessaire
    ],
  );
});

class PizzaDelizzaApp extends ConsumerWidget {
  const PizzaDelizzaApp({super.key});

  @override
  Widget build(BuildContextcontext, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Pizza Delizza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          accentColor: const Color(0xFFB00020),
        ),
        // Utilise un style de bouton textuel clair pour les liens
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFB00020),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
