// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import '../../src/design_system/colors.dart';
import '../../white_label/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final displayName = _displayNameController.text.trim();
      final role = UserRole.client;

      final authService = ref.read(firebaseAuthServiceProvider);
      final result = await authService.signUp(
        email,
        password,
        displayName: displayName.isEmpty ? null : displayName,
        role: role,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: context.onPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Compte créé avec succès ! Vous pouvez maintenant vous connecter.',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Retourner à l'écran de connexion
          context.go(AppRoutes.login);
        } else {
          setState(() {
            _errorMessage = result['error'] as String;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: context.primaryColor,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(VisualConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
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
                          size: 70,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Titre
                    Text(
                      'Créer un compte',
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            color: context.onPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 32,
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
                    const SizedBox(height: 40),

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
                          // Message d'erreur
                          if (_errorMessage != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.error),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: AppColors.error),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Nom d'affichage
                          TextFormField(
                            controller: _displayNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nom (optionnel)',
                              prefixIcon: Icon(Icons.person_outline),
                              hintText: 'Votre nom',
                            ),
                          ),
                          const SizedBox(height: 16),

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
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
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
                          const SizedBox(height: 16),

                          // Confirmer mot de passe
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirmer le mot de passe',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirmation requise';
                              }
                              if (value != _passwordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Bouton d'inscription
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignup,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(context.onPrimary),
                                      ),
                                    )
                                  : const Text('Créer le compte', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Lien vers connexion
                          TextButton(
                            onPressed: () {
                              context.go(AppRoutes.login);
                            },
                            child: const Text('Déjà un compte ? Se connecter'),
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
    );
  }
}
