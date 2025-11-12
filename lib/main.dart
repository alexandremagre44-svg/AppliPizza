// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Importez vos écrans
import 'src/screens/splash/splash_screen.dart';
import 'src/screens/auth/login_screen.dart';
import 'src/screens/home/home_screen.dart'; 
import 'src/screens/menu/menu_screen.dart'; 
import 'src/screens/cart/cart_screen.dart';
import 'src/screens/checkout/checkout_screen.dart';
import 'src/screens/profile/profile_screen.dart'; 
import 'src/screens/product_detail/product_detail_screen.dart';
import 'src/screens/admin/admin_dashboard_screen.dart';
import 'src/screens/admin/admin_pizza_screen.dart';
import 'src/screens/admin/admin_menu_screen.dart';
import 'src/screens/admin/admin_drinks_screen.dart';
import 'src/screens/admin/admin_desserts_screen.dart';
import 'src/screens/admin/admin_page_builder_screen.dart';
import 'src/screens/admin/admin_mailing_screen.dart';
import 'src/screens/admin/admin_orders_screen.dart';
import 'src/kitchen/kitchen_page.dart';

// Importez le composant de barre de navigation
import 'src/widgets/scaffold_with_nav_bar.dart'; 
import 'src/models/product.dart';
import 'src/theme/app_theme.dart';
import 'src/core/constants.dart';
import 'src/providers/auth_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pizza Deli\'Zza',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: _buildRouter(ref),
    );
  }

  GoRouter _buildRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) async {
        final authState = ref.read(authProvider);
        final isLoggingIn = state.matchedLocation == AppRoutes.login;
        
        // Si on est sur le splash ou login, laisser passer
        if (state.matchedLocation == AppRoutes.splash || isLoggingIn) {
          return null;
        }
        
        // Si pas connecté, rediriger vers login
        if (!authState.isLoggedIn) {
          return AppRoutes.login;
        }
        
        return null;
      },
      routes: [
        // Splash Screen
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        // Login Screen
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        // ShellRoute pour les écrans AVEC barre de navigation
        ShellRoute(
          builder: (context, state, child) {
            return ScaffoldWithNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: AppRoutes.menu,
              builder: (context, state) => const MenuScreen(),
            ),
            GoRoute(
              path: AppRoutes.cart,
              builder: (context, state) => const CartScreen(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
            // Routes Admin dans le shell pour bottom bar
            GoRoute(
              path: '/admin',
              builder: (context, state) => const AdminDashboardScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminPizza,
              builder: (context, state) => const AdminPizzaScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminMenu,
              builder: (context, state) => const AdminMenuScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminDrinks,
              builder: (context, state) => const AdminDrinksScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminDesserts,
              builder: (context, state) => const AdminDessertsScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminPageBuilder,
              builder: (context, state) => const AdminPageBuilderScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminMailing,
              builder: (context, state) => const AdminMailingScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminOrders,
              builder: (context, state) => const AdminOrdersScreen(),
            ),
          ],
        ),
        // Route Indépendante pour l'écran de Détail
        GoRoute(
          path: AppRoutes.productDetail,
          builder: (context, state) {
            final product = state.extra as Product;
            return ProductDetailScreen(product: product);
          },
        ),
        // Route Checkout
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        // Route Kitchen Mode
        GoRoute(
          path: AppRoutes.kitchen,
          builder: (context, state) => const KitchenPage(),
        ),
      ],
    );
  }
}
