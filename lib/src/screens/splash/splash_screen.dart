// lib/src/screens/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../../builder/services/builder_navigation_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    
    _controller.forward();
    
    // Navigate using smart routing after animation
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _handleSmartNavigation();
      }
    });
  }

  /// Smart navigation logic to prevent navigating to disabled pages.
  /// 
  /// Navigation decision flow:
  /// 1. Check auth state - if not logged in, navigate to '/login'
  /// 2. If logged in, fetch enabled bottom bar pages from Firestore
  /// 3. If pages exist and first page has a valid route, navigate there
  /// 4. Fallback to '/home' if no active pages or on error
  Future<void> _handleSmartNavigation() async {
    // Check authentication state
    final auth = ref.read(authProvider);
    
    if (!auth.isLoggedIn) {
      // Not logged in - go to login page
      if (mounted) {
        context.go('/login');
      }
      return;
    }
    
    // User is logged in - determine the best page to navigate to
    try {
      final appId = ref.read(currentRestaurantProvider).id;
      final pages = await BuilderNavigationService(appId).getBottomBarPages();
      
      if (!mounted) return;
      
      if (pages.isNotEmpty) {
        // Validate the route before navigation
        final firstRoute = pages.first.route;
        if (firstRoute.isNotEmpty && firstRoute.startsWith('/')) {
          // Navigate to the first available page's route
          context.go(firstRoute);
        } else {
          // Invalid route format - fallback to home
          context.go('/home');
        }
      } else {
        // Fallback: no active pages found (rare case)
        context.go('/home');
      }
    } catch (e) {
      // Error fetching pages - fallback to home
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get restaurant name dynamically for de-branding
    // Using ref.watch to ensure UI rebuilds if restaurant config changes
    final restaurantName = ref.watch(currentRestaurantProvider).name;
    // Use theme's primary color instead of hardcoded AppColors.primaryRed
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      // refactor splash screen → app_theme standard (solid color, no gradient)
      body: Container(
        decoration: BoxDecoration(
          color: primaryColor,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Enhanced Pizza Icon
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_pizza,
                      size: 90,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // App Name with shadow - dynamically uses restaurant name
                  Text(
                    restaurantName,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                      fontFamily: 'Poppins',
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'À emporter uniquement',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Enhanced Loading indicator
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
