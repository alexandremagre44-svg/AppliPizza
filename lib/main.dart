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
import 'src/screens/menu/menu_screen.dart';
import 'src/screens/cart/cart_screen.dart';
import 'src/screens/checkout/checkout_screen.dart';
import 'src/screens/profile/profile_screen.dart'; 
import 'src/screens/product_detail/product_detail_screen.dart';
import 'screens/kitchen_tablet/kitchen_tablet_screen.dart';
import 'src/screens/roulette/roulette_screen.dart';
import 'src/screens/client/rewards/rewards_screen.dart';

// Delivery screens imports
import 'src/screens/delivery/delivery_address_screen.dart';
import 'src/screens/delivery/delivery_area_selector_screen.dart';
import 'src/screens/delivery/delivery_tracking_screen.dart';

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

// White-Label Admin Widgets
import 'white_label/widgets/admin/payment_admin_settings_screen.dart';

// White-Label Runtime Widgets
import 'white_label/widgets/runtime/subscribe_newsletter_screen.dart';

// Staff Tablet imports
import 'src/staff_tablet/screens/staff_tablet_pin_screen.dart';
import 'src/staff_tablet/screens/staff_tablet_catalog_screen.dart';
import 'src/staff_tablet/screens/staff_tablet_checkout_screen.dart';
import 'src/staff_tablet/screens/staff_tablet_history_screen.dart';
import 'src/staff_tablet/providers/staff_tablet_auth_provider.dart';

// POS (Caisse) Module - Phase 1
import 'src/screens/admin/pos/pos_screen.dart';

// Kitchen Module - Minimal screen
import 'src/screens/kitchen/kitchen_screen.dart';

// Importez le composant de barre de navigation
import 'src/widgets/scaffold_with_nav_bar.dart';
import 'src/widgets/restaurant_scope.dart';
import 'src/models/product.dart';
import 'src/models/order.dart';
import 'src/models/restaurant_config.dart';
import 'src/theme/app_theme.dart';
import 'src/core/constants.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/restaurant_provider.dart';
import 'src/providers/restaurant_plan_provider.dart';
import 'src/navigation/module_route_guards.dart';
import 'white_label/core/module_id.dart';
import 'white_label/runtime/module_runtime_adapter.dart';
import 'white_label/runtime/router_guard.dart';
import 'white_label/runtime/register_module_routes.dart';
import 'white_label/runtime/module_guards.dart';
// WHITE-LABEL V2: Unified Theme System (Single Source of Truth)
import 'white_label/theme/unified_theme_provider.dart' show unifiedThemeProvider as unifiedThemeProviderV2;

// Builder B3 imports for dynamic pages
import 'builder/models/models.dart';
import 'builder/runtime/runtime.dart';
import 'builder/runtime/builder_block_runtime_registry.dart';

// SuperAdmin routes
import 'superadmin/superadmin_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register all module routes before running the app
  registerAllModuleRoutes();
  
  // Register White-Label modules in the runtime registry
  // This must be called before the app starts to ensure modules are available
  registerWhiteLabelModules();
  
  // Read APP_ID from environment variable with default fallback
  const appId = String.fromEnvironment('APP_ID', defaultValue: 'delizza');
  const appName = String.fromEnvironment('APP_NAME', defaultValue: 'Delizza Default');
  
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
    ProviderScope(
      child: RestaurantScope(
        restaurantId: appId,
        restaurantName: appName,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Phase 3: Load unified plan and apply module runtime adapter
    final unifiedPlanAsync = ref.watch(restaurantPlanUnifiedProvider);
    final unifiedPlan = unifiedPlanAsync.asData?.value;
    
    // Apply module runtime adapter (read-only, non-intrusive)
    if (unifiedPlan != null) {
      final runtimeContext = RuntimeContext(ref: ref);
      ModuleRuntimeAdapter.applyAll(runtimeContext, unifiedPlan);
    }
    
    // WHITE-LABEL V2: Use unified theme provider (SINGLE SOURCE OF TRUTH)
    // Workflow:
    // 1. ThemeSettingsProvider reads from RestaurantPlanUnified.modules.theme.settings
    // 2. UnifiedThemeAdapter converts ThemeSettings → ThemeData Material 3
    // 3. Fallback to AppTheme.lightTheme if module disabled or error
    //
    // This replaces the old unifiedThemeProvider from src/providers/theme_providers.dart
    final theme = ref.watch(unifiedThemeProviderV2);
    
    return MaterialApp.router(
      title: 'Pizza Deli\'Zza',
      theme: theme,
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
        
        // PROTECTION: SuperAdmin routes - only accessible to superadmins
        // If user is not a superadmin, redirect to menu. If superadmin, allow access (return null).
        if (state.matchedLocation.startsWith('/superadmin')) {
          if (!authState.isSuperAdmin) {
            return AppRoutes.menu;
          }
        }
        
        // Phase 4C: Apply WhiteLabel route guard
        // Check if route belongs to an active module
        final unifiedPlanAsync = ref.read(restaurantPlanUnifiedProvider);
        final plan = unifiedPlanAsync.asData?.value;
        final guardRedirect = whiteLabelRouteGuard(state, plan);
        if (guardRedirect != null) {
          return guardRedirect;
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
            // Main app routes - Builder-first with legacy fallback
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const BuilderPageLoader(
                pageId: BuilderPageId.home,
                fallback: HomeScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.menu,
              builder: (context, state) => const BuilderPageLoader(
                pageId: BuilderPageId.menu,
                fallback: MenuScreen(),
              ),
            ),
            // Dynamic Builder pages route
            GoRoute(
              path: '/page/:pageId',
              builder: (context, state) {
                final pageId = state.pathParameters['pageId'] ?? '';
                return DynamicBuilderPageScreen(pageKey: pageId);
              },
            ),
            // System pages - Cart MUST bypass Builder (WL Doctrine)
            // Cart is a system page that should NEVER exist in Builder
            GoRoute(
              path: AppRoutes.cart,
              builder: (context, state) => const CartScreen(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const BuilderPageLoader(
                pageId: BuilderPageId.profile,
                fallback: ProfileScreen(),
              ),
            ),
            // Module routes with guards
            GoRoute(
              path: '/rewards',
              builder: (context, state) {
                return ModuleGuard(
                  module: ModuleId.loyalty,
                  child: const BuilderPageLoader(
                    pageId: BuilderPageId.rewards,
                    fallback: RewardsScreen(),
                  ),
                );
              },
            ),
            GoRoute(
              path: '/roulette',
              builder: (context, state) {
                return ModuleGuard(
                  module: ModuleId.roulette,
                  child: const BuilderPageLoader(
                    pageId: BuilderPageId.roulette,
                    fallback: RouletteScreen(),
                  ),
                );
              },
            ),
            // Admin Menu - Main entry point for all admin tools
            GoRoute(
              path: AppRoutes.adminStudio,
              builder: (context, state) {
                // PROTECTION: Admin menu is reserved for admins
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  // Redirect to menu if not admin
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.menu);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const AdminStudioScreen();
              },
            ),

            // Admin Management Routes
            GoRoute(
              path: AppRoutes.adminProducts,
              builder: (context, state) {
                // PROTECTION: Admin only
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.menu);
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
                    context.go(AppRoutes.menu);
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
                    context.go(AppRoutes.menu);
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
                    context.go(AppRoutes.menu);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const IngredientsAdminScreen();
              },
            ),
            // Payment Admin Route (White-Label Module)
            GoRoute(
              path: '/admin/payments',
              name: 'adminPayments',
              builder: (context, state) {
                // PROTECTION: Admin only
                final authState = ref.read(authProvider);
                if (!authState.isAdmin) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go(AppRoutes.menu);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const PaymentAdminSettingsScreen();
              },
            ),
            // Newsletter Route (White-Label Module - Client)
            GoRoute(
              path: '/newsletter',
              name: 'newsletter',
              builder: (context, state) {
                return ModuleGuard(
                  module: ModuleId.newsletter,
                  child: const SubscribeNewsletterScreen(),
                );
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
                    context.go(AppRoutes.menu);
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
                    context.go(AppRoutes.menu);
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
                context.go(AppRoutes.menu);
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
        // Delivery Routes (with module guards)
        GoRoute(
          path: AppRoutes.deliveryAddress,
          builder: (context, state) {
            return ModuleGuard(
              module: ModuleId.delivery,
              child: const DeliveryAddressScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.deliveryArea,
          builder: (context, state) {
            return ModuleGuard(
              module: ModuleId.delivery,
              child: const DeliveryAreaSelectorScreen(),
            );
          },
        ),
        GoRoute(
          path: '/order/:id/tracking',
          builder: (context, state) {
            // Validate order data
            if (state.extra is! Order) {
              return Scaffold(
                appBar: AppBar(title: const Text('Erreur')),
                body: const Center(
                  child: Text('Commande introuvable'),
                ),
              );
            }
            final order = state.extra as Order;
            return ModuleGuard(
              module: ModuleId.delivery,
              child: DeliveryTrackingScreen(order: order),
            );
          },
        ),
        // Kitchen Module Route - Protected by module guard
        GoRoute(
          path: AppRoutes.kitchen,
          name: 'kitchen',
          builder: (context, state) {
            return ModuleAndRoleGuard(
              module: ModuleId.pos,
              requiresKitchen: true,
              child: const KitchenScreen(),
            );
          },
        ),
        // Staff Tablet Routes (with guards) - All part of POS module
        GoRoute(
          path: AppRoutes.staffTabletPin,
          builder: (context, state) {
            return ModuleAndRoleGuard(
              module: ModuleId.pos,
              requiresAdmin: true,
              child: const StaffTabletPinScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.staffTabletCatalog,
          builder: (context, state) {
            final authState = ref.read(authProvider);
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
            return ModuleAndRoleGuard(
              module: ModuleId.pos,
              requiresAdmin: true,
              child: const StaffTabletCatalogScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.staffTabletCheckout,
          builder: (context, state) {
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
            return ModuleAndRoleGuard(
              module: ModuleId.pos,
              requiresAdmin: true,
              child: const StaffTabletCheckoutScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.staffTabletHistory,
          builder: (context, state) {
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
            return ModuleAndRoleGuard(
              module: ModuleId.pos,
              requiresAdmin: true,
              child: const StaffTabletHistoryScreen(),
            );
          },
        ),
        // POS Route - Protected by module guard
        GoRoute(
          path: AppRoutes.pos,
          name: 'pos',
          builder: (context, state) {
            return ModuleAndRoleGuard(
              module: ModuleId.pos,
              requiresAdmin: true,
              child: const PosScreen(),
            );
          },
        ),
        // SuperAdmin parent route - redirects to dashboard
        GoRoute(
          path: SuperAdminRoutes.root,
          redirect: (ctx, state) => SuperAdminRoutes.dashboard,
        ),
        // SuperAdmin internal routes
        ...superAdminRoutes,
      ],
    );
  }

}
