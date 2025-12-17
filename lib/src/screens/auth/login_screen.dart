// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';
import '../../../builder/services/builder_navigation_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Micro-animation: Entrée fluide de l'écran de connexion
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Navigate to the first page in bottom navigation (dynamic landing page)
  /// Uses the same logic as SplashScreen for consistency
  Future<void> _navigateToDynamicLandingPage() async {
    try {
      final appId = ref.read(currentRestaurantProvider).id;
      final pages = await BuilderNavigationService(appId).getBottomBarPages();
      
      if (!mounted) return;
      
      if (pages.isNotEmpty) {
        final firstRoute = pages.first.route;
        if (firstRoute.isNotEmpty && firstRoute.startsWith('/')) {
          debugPrint('[Landing] Initial route = $firstRoute (from pages.first after login)');
          context.go(firstRoute);
          return;
        }
      }
    } catch (e) {
      debugPrint('[Landing] Error loading dynamic landing page: $e');
    }
    
    // Fallback to /menu if no valid pages found
    if (mounted) {
      debugPrint('[Landing] Initial route = /menu (fallback after login)');
      context.go(AppRoutes.menu);
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await ref.read(authProvider.notifier).login(email, password);

      if (mounted) {
        if (success) {
          // Navigate to dynamic landing page (first page in bottomNav)
          await _navigateToDynamicLandingPage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: context.onPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(ref.read(authProvider).error ?? 'Erreur de connexion'),
                  ),
                ],
              ),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Fond rouge uni (pas de gradient) selon la charte officielle
          color: context.primaryColor,
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(VisualConstants.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    // Logo with enhanced styling
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: context.onPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: context.colorScheme.shadow.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_pizza,
                          size: 80,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Titre with white color for gradient background
                    Text(
                      'Pizza Deli\'Zza',
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            color: context.onPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 36,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: context.colorScheme.shadow.withOpacity(0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Votre pizza à portée de main',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: context.onPrimary.withOpacity(0.95),
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // Card container for form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: context.onPrimary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: context.colorScheme.shadow.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Connexion',
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: AppTheme.textDark,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              hintText: 'votre@email.com',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email requis';
                              }
                              if (!value.contains('@')) {
                                return 'Email invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Mot de passe
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mot de passe requis';
                              }
                              if (value.length < 6) {
                                return 'Minimum 6 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Bouton de connexion
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authState.isLoading ? null : _handleLogin,
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(context.onPrimary),
                                      ),
                                    )
                                  : const Text('Se connecter', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Lien vers inscription
                          TextButton(
                            onPressed: () {
                              context.go('/signup');
                            },
                            child: const Text('Pas de compte ? Créer un compte'),
                          ),
                        ],
                      ),
                    ),
                    ],
                  ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
