// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Importez vos écrans
import 'src/features/splash/presentation/screens/splash_screen.dart';
import 'src/features/auth/presentation/screens/login_screen.dart';
import 'src/features/auth/presentation/screens/signup_screen.dart';
import 'src/features/home/presentation/screens/home_screen.dart'; 
import 'src/features/menu/presentation/screens/menu_screen.dart'; 
import 'src/features/cart/presentation/screens/cart_screen.dart';
import 'src/features/checkout/presentation/screens/checkout_screen.dart';
import 'src/features/profile/presentation/screens/profile_screen.dart'; 
import 'src/features/product/presentation/screens/product_detail_screen.dart';
import 'src/features/shared/presentation/admin/admin_dashboard_screen.dart';
import 'src/features/product/presentation/admin/admin_pizza_screen.dart';
import 'src/features/product/presentation/admin/admin_menu_screen.dart';
import 'src/features/product/presentation/admin/admin_drinks_screen.dart';
import 'src/features/product/presentation/admin/admin_desserts_screen.dart';
import 'src/features/shared/presentation/admin/admin_page_builder_screen.dart';
import 'src/features/mailing/presentation/admin/admin_mailing_screen.dart';
import 'src/features/orders/presentation/admin/admin_orders_screen.dart';
import 'src/features/home/presentation/admin/studio_home_config_screen.dart';
import 'src/features/popups/presentation/admin/studio_popups_roulette_screen.dart';
import 'src/features/shared/presentation/admin/studio_texts_screen.dart';
import 'src/features/home/presentation/admin/studio_featured_products_screen.dart';
import 'src/features/mailing/presentation/admin/communication_promotions_screen.dart';
import 'src/features/loyalty/presentation/admin/communication_loyalty_screen.dart';
import 'src/features/content/presentation/admin/content_studio_screen.dart';
import 'src/kitchen/kitchen_page.dart';
import 'src/features/roulette/presentation/screens/roulette_screen.dart';

// Importez le composant de barre de navigation
import 'src/features/shared/widgets/scaffold_with_nav_bar.dart'; 
import 'src/features/product/data/models/product.dart';
import 'src/features/shared/theme/app_theme.dart';
import 'src/features/shared/constants/constants.dart';
import 'src/features/auth/application/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
    // Create a listenable that refreshes when auth state changes
    final authService = ref.read(firebaseAuthServiceProvider);
    final refreshListenable = GoRouterRefreshStream(authService.authStateChanges);
    
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: refreshListenable,
      redirect: (context, state) async {
        final authState = ref.read(authProvider);
        final isLoggingIn = state.matchedLocation == AppRoutes.login;
        final isSigningUp = state.matchedLocation == '/signup';
        
        // Si on est sur le splash, login ou signup, laisser passer
        if (state.matchedLocation == AppRoutes.splash || isLoggingIn || isSigningUp) {
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
        // Signup Screen
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
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
              path: AppRoutes.admin,
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
            // Studio routes
            GoRoute(
              path: AppRoutes.studioHomeConfig,
              builder: (context, state) => const StudioHomeConfigScreen(),
            ),
            GoRoute(
              path: AppRoutes.studioPopupsRoulette,
              builder: (context, state) => const StudioPopupsRouletteScreen(),
            ),
            GoRoute(
              path: AppRoutes.studioTexts,
              builder: (context, state) => const StudioTextsScreen(),
            ),
            GoRoute(
              path: AppRoutes.studioFeaturedProducts,
              builder: (context, state) => const StudioFeaturedProductsScreen(),
            ),
            GoRoute(
              path: AppRoutes.studioContent,
              builder: (context, state) => const ContentStudioScreen(),
            ),
            // Communication routes
            GoRoute(
              path: AppRoutes.communicationPromotions,
              builder: (context, state) => const CommunicationPromotionsScreen(),
            ),
            GoRoute(
              path: AppRoutes.communicationLoyalty,
              builder: (context, state) => const CommunicationLoyaltyScreen(),
            ),
          ],
        ),
        // Route Indépendante pour l'écran de Détail
        GoRoute(
          path: AppRoutes.productDetail,
          builder: (context, state) {
            // Secure data passing: validate type before casting
            if (state.extra is! Product) {
              // If invalid data, redirect to home
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(AppRoutes.home);
              });
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final product = state.extra as Product;
            return ProductDetailScreen(product: product);
          },
        ),
        // Route Checkout
        GoRoute(
          path: AppRoutes.checkout,
          builder: (context, state) => const CheckoutScreen(),
        ),
        // Route Kitchen Mode
        GoRoute(
          path: AppRoutes.kitchen,
          builder: (context, state) => const KitchenPage(),
        ),
        // Route Roulette
        GoRoute(
          path: AppRoutes.roulette,
          builder: (context, state) {
            // Get userId from auth state
            final authState = ref.read(authProvider);
            final userId = authState.userEmail ?? 'guest';
            return RouletteScreen(userId: userId);
          },
        ),
      ],
    );
  }
}
