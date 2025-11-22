// lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

// Importez vos écrans
import 'src/screens/splash/splash_screen.dart';
import 'src/screens/auth/login_screen.dart';
import 'src/screens/auth/signup_screen.dart';
import 'src/screens/home/home_screen.dart'; 
import 'src/screens/home/home_screen_b2.dart'; // NEW: HomeScreen based on AppConfig B2
import 'src/screens/menu/menu_screen.dart';
import 'src/screens/menu/menu_screen_b3.dart'; // B3: Dynamic page architecture 
import 'src/screens/dynamic/dynamic_page_screen.dart'; // B3 Phase 2: Dynamic page screen
import 'src/screens/cart/cart_screen.dart';
import 'src/screens/checkout/checkout_screen.dart';
import 'src/screens/profile/profile_screen.dart'; 
import 'src/screens/product_detail/product_detail_screen.dart';
// Studio V2 - Official professional studio (only version exposed via routes).
import 'src/studio/screens/studio_v2_screen.dart';
import 'src/studio/screens/theme_manager_screen.dart';
import 'src/studio/screens/media_manager_screen.dart';
// Studio B2 - New admin interface for AppConfig B2 management
import 'src/admin/studio_b2/studio_b2_page.dart';
// Studio B3 - Page editor for dynamic pages
import 'src/admin/studio_b3/studio_b3_page.dart';
import 'src/kitchen/kitchen_page.dart';
import 'src/screens/roulette/roulette_screen.dart';
import 'src/screens/client/rewards/rewards_screen.dart';

// Admin screens imports
import 'src/screens/admin/admin_studio_screen.dart';
import 'src/screens/admin/products_admin_screen.dart';
import 'src/screens/admin/product_form_screen.dart';
import 'src/screens/admin/mailing_admin_screen.dart';
import 'src/screens/admin/promotions_admin_screen.dart';
import 'src/screens/admin/promotion_form_screen.dart';
import 'src/screens/admin/ingredients_admin_screen.dart';
import 'src/screens/admin/ingredient_form_screen.dart';
import 'src/screens/admin/studio/roulette_admin_settings_screen.dart';
import 'src/screens/admin/studio/roulette_segments_list_screen.dart';

// Staff Tablet imports
import 'src/staff_tablet/screens/staff_tablet_pin_screen.dart';
import 'src/staff_tablet/screens/staff_tablet_catalog_screen.dart';
import 'src/staff_tablet/screens/staff_tablet_checkout_screen.dart';
import 'src/staff_tablet/screens/staff_tablet_history_screen.dart';
import 'src/staff_tablet/providers/staff_tablet_auth_provider.dart';

// Importez le composant de barre de navigation
import 'src/widgets/scaffold_with_nav_bar.dart'; 
import 'src/models/product.dart';
import 'src/theme/app_theme.dart';
import 'src/core/constants.dart';
import 'src/providers/auth_provider.dart';
// B3 Phase 2: AppConfig for dynamic pages
import 'src/services/app_config_service.dart';
import 'src/models/page_schema.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase App Check
  // DISABLED on Web in debug mode to prevent errors during development
  // ENABLED on Android/iOS for production security
  if (!(kIsWeb && kDebugMode)) {
    await FirebaseAppCheck.instance.activate(
      // For Android: Use Play Integrity API in production
      androidProvider: kDebugMode 
        ? AndroidProvider.debug 
        : AndroidProvider.playIntegrity,
      // For iOS: Use App Attest in production  
      appleProvider: kDebugMode
        ? AppleProvider.debug
        : AppleProvider.appAttest,
      // For Web: Use reCAPTCHA (only in production)
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    );
  }
  
  // Initialize Firebase Crashlytics
  // DISABLED on Web platform (Crashlytics not supported on Web)
  if (!kIsWeb) {
    // Enable/disable collection based on debug mode
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    
    // Pass all uncaught errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
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
            // HomeScreenB2 - Test route for new AppConfig B2 architecture
            GoRoute(
              path: '/home-b2',
              builder: (context, state) => const HomeScreenB2(),
            ),
            // HomeB3 - B3 Phase 6: Dynamic home page
            GoRoute(
              path: AppRoutes.homeB3,
              builder: (context, state) => _buildDynamicPage(context, ref, AppRoutes.homeB3),
            ),
            GoRoute(
              path: AppRoutes.menu,
              builder: (context, state) => const MenuScreen(),
            ),
            // MenuScreenB3 - Test route for B3 dynamic page architecture
            GoRoute(
              path: AppRoutes.menuB3,
              builder: (context, state) => const MenuScreenB3(),
            ),
            // B3 Phase 2: Dynamic page routes from AppConfig
            GoRoute(
              path: AppRoutes.categoriesB3,
              builder: (context, state) => _buildDynamicPage(context, ref, AppRoutes.categoriesB3),
            ),
            GoRoute(
              path: AppRoutes.cartB3,
              builder: (context, state) => _buildDynamicPage(context, ref, AppRoutes.cartB3),
            ),
            GoRoute(
              path: AppRoutes.cart,
              builder: (context, state) => const CartScreen(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
            // Admin Menu - Main entry point for all admin tools
            GoRoute(
              path: AppRoutes.adminStudio,
              builder: (context, state) {
                // PROTECTION: Admin menu is reserved for admins
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  // Redirect to home if not admin
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.home);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const AdminStudioScreen();
              },
            ),
            // Studio V2 Editor - Direct access to content editor
            GoRoute(
              path: AppRoutes.adminStudioV2,
              builder: (context, state) {
                // PROTECTION: Studio V2 is reserved for admins
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  // Redirect to home if not admin
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.home);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const StudioV2Screen();
              },
            ),
            // Studio B2 - New admin interface for AppConfig management
            GoRoute(
              path: '/admin/studio-b2',
              builder: (context, state) {
                // PROTECTION: Studio B2 is reserved for admins
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  // Redirect to home if not admin
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.home);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const StudioB2Page();
              },
            ),
            // Studio B3 - Page editor for dynamic pages
            GoRoute(
              path: AppRoutes.adminStudioB3,
              builder: (context, state) {
                // PROTECTION: Studio B3 is reserved for admins
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  // Redirect to home if not admin
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.home);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const StudioB3Page();
              },
            ),
            // Deprecated routes - redirect to admin menu
            GoRoute(
              path: AppRoutes.adminStudioNew,
              redirect: (context, state) => AppRoutes.adminStudio,
            ),
            // Theme Manager V3 route
            GoRoute(
              path: AppRoutes.adminStudioV3Theme,
              builder: (context, state) {
                // PROTECTION: Admin only
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.home);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const ThemeManagerScreen();
              },
            ),
            // Media Manager V3 route
            GoRoute(
              path: AppRoutes.adminStudioV3Media,
              builder: (context, state) {
                // PROTECTION: Admin only
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.home);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const MediaManagerScreen();
              },
            ),
            // Deprecated routes - redirect to Studio V2
            GoRoute(
              path: AppRoutes.adminHero,
              redirect: (context, state) => AppRoutes.adminStudio,
            ),
            GoRoute(
              path: AppRoutes.adminBanner,
              redirect: (context, state) => AppRoutes.adminStudio,
            ),
            GoRoute(
              path: AppRoutes.adminPopups,
              redirect: (context, state) => AppRoutes.adminStudio,
            ),
            GoRoute(
              path: AppRoutes.adminTexts,
              redirect: (context, state) => AppRoutes.adminStudio,
            ),
            // Admin Management Routes
            GoRoute(
              path: AppRoutes.adminProducts,
              builder: (context, state) {
                // PROTECTION: Admin only
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.home);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const ProductsAdminScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.adminMailing,
              builder: (context, state) {
                // PROTECTION: Admin only
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.home);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const MailingAdminScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.adminPromotions,
              builder: (context, state) {
                // PROTECTION: Admin only
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.home);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const PromotionsAdminScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.adminIngredients,
              builder: (context, state) {
                // PROTECTION: Admin only
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.home);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const IngredientsAdminScreen();
              },
            ),
            // Roulette Admin Routes
            GoRoute(
              path: AppRoutes.adminRouletteSettings,
              builder: (context, state) {
                // PROTECTION: Admin only
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.home);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const RouletteAdminSettingsScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.adminRouletteSegments,
              builder: (context, state) {
                // PROTECTION: Admin only
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.home);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const RouletteSegmentsListScreen();
              },
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
            final userId = authState.userId ?? 'guest';
            return RouletteScreen(userId: userId);
          },
        ),
        // Route Rewards
        GoRoute(
          path: AppRoutes.rewards,
          builder: (context, state) => const RewardsScreen(),
        ),
        // Staff Tablet Routes (CAISSE - Admin Only)
        GoRoute(
          path: AppRoutes.staffTabletPin,
          builder: (context, state) {
            // PROTECTION: Staff tablet (CAISSE) est réservé aux admins
            final authState = ref.read(authProvider);
            if (!authState.isAdmin) {
              // Redirect to home if not admin
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(AppRoutes.home);
              });
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Accès réservé aux administrateurs'),
                    ],
                  ),
                ),
              );
            }
            return const StaffTabletPinScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.staffTabletCatalog,
          builder: (context, state) {
            // PROTECTION: Admin only
            final authState = ref.read(authProvider);
            if (!authState.isAdmin) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(AppRoutes.home);
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // Check if authenticated in staff tablet
            final staffAuth = ref.read(staffTabletAuthProvider);
            if (!staffAuth.isAuthenticated) {
              // Redirect to PIN screen if not authenticated
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(AppRoutes.staffTabletPin);
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return const StaffTabletCatalogScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.staffTabletCheckout,
          builder: (context, state) {
            // PROTECTION: Admin only
            final authState = ref.read(authProvider);
            if (!authState.isAdmin) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(AppRoutes.home);
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // Check if authenticated in staff tablet
            final staffAuth = ref.read(staffTabletAuthProvider);
            if (!staffAuth.isAuthenticated) {
              // Redirect to PIN screen if not authenticated
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(AppRoutes.staffTabletPin);
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return const StaffTabletCheckoutScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.staffTabletHistory,
          builder: (context, state) {
            // PROTECTION: Admin only
            final authState = ref.read(authProvider);
            if (!authState.isAdmin) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(AppRoutes.home);
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // Check if authenticated in staff tablet
            final staffAuth = ref.read(staffTabletAuthProvider);
            if (!staffAuth.isAuthenticated) {
              // Redirect to PIN screen if not authenticated
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(AppRoutes.staffTabletPin);
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return const StaffTabletHistoryScreen();
          },
        ),
      ],
    );
  }

  /// Build a dynamic page from AppConfig
  /// Returns DynamicPageScreen if page exists, otherwise PageNotFoundScreen
  /// 
  /// TODO Phase 3: Use a provider/state management for AppConfig instead of
  /// creating a new service instance on each build
  static Widget _buildDynamicPage(BuildContext context, WidgetRef ref, String route) {
    // For now, use the default config synchronously
    // In production, this should be fetched from Firestore via a provider
    final config = AppConfigService().getDefaultConfig('pizza_delizza');
    
    // Find the page by route
    final pageSchema = config.pages.getPage(route);
    
    if (pageSchema != null) {
      // B3 Migration Phase 6: Log successful page load
      if (route == AppRoutes.homeB3 || route == AppRoutes.menuB3 || route == AppRoutes.categoriesB3) {
        print('B3 Migration: ${pageSchema.name} loaded successfully (route: $route)');
      }
      return DynamicPageScreen(pageSchema: pageSchema);
    } else {
      print('B3 Migration: Page not found for route: $route');
      return PageNotFoundScreen(route: route);
    }
  }
}
