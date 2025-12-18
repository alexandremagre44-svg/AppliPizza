// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/staff_tablet/screens/staff_tablet_pin_screen.dart

import 'package:flutter/material.dart';
import '../../src/design_system/colors.dart';
import '../../white_label/theme/theme_extensions.dart';
import '../../design_system/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/staff_tablet_auth_provider.dart';
import '../../providers/auth_provider.dart';

class StaffTabletPinScreen extends ConsumerStatefulWidget {
  const StaffTabletPinScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StaffTabletPinScreen> createState() => _StaffTabletPinScreenState();
}

class _StaffTabletPinScreenState extends ConsumerState<StaffTabletPinScreen> {
  String _enteredPin = '';
  bool _isError = false;

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _isError = false;
      });

      // Auto-submit when 4 digits entered
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _isError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final authNotifier = ref.read(staffTabletAuthProvider.notifier);
    final isValid = await authNotifier.authenticate(_enteredPin);

    if (isValid) {
      if (mounted) {
        context.go('/staff-tablet/catalog');
      }
    } else {
      setState(() {
        _isError = true;
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // PROTECTION: Vérifier que l'utilisateur est admin
    final authState = ref.watch(authProvider);
    
    // Si l'utilisateur n'est pas admin, afficher un écran non autorisé
    if (!authState.isAdmin) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.error[900]!,
                AppColors.error[700]!,
              ],
            ),
          ),
          child: Center(
            child: Card(
              margin: EdgeInsets.all(AppSpacing.xl),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 80,
                      color: AppColors.error,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      'Accès non autorisé',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Le module CAISSE est réservé aux administrateurs uniquement.',
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: () => context.go('/menu'),
                      icon: const Icon(Icons.home),
                      label: const Text('Retour à l\'accueil'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
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
    
    // Si admin, afficher l'écran PIN normal
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A237E), // Deep blue
              const Color(0xFF311B92), // Deep purple
              AppColors.primarySwatch[900]!,
            ],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(40),
            child: Card(
              elevation: 20,
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo/Title with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primarySwatch[600]!,
                                  AppColors.primarySwatch[800]!,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.point_of_sale_rounded,
                              size: 64,
                              color: context.onPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Mode Caisse',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.surfaceVariant ,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Entrez votre code PIN',
                      style: TextStyle(
                        fontSize: 17,
                        color: context.colorScheme.surfaceVariant ,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 44),

                    // PIN dots display with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = index < _enteredPin.length;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFilled
                                  ? (_isError ? AppColors.error[600] : AppColors.primary)
                                  : Colors.transparent,
                              border: Border.all(
                                color: _isError
                                    ? AppColors.error[600]!
                                    : (isFilled ? AppColors.primary : context.textSecondary),
                                width: 2.5,
                              ),
                              boxShadow: isFilled
                                  ? [
                                      BoxShadow(
                                        color: (_isError ? AppColors.error : AppColors.primary)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ),
                    
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isError
                          ? Padding(
                              padding: const EdgeInsets.only(top: 20),
                              key: const ValueKey('error'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.error[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppColors.error[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Code PIN incorrect',
                                      style: TextStyle(
                                        color: AppColors.error[700],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(height: 52, key: ValueKey('empty')),
                    ),

                    const SizedBox(height: 36),

                    // Number pad with improved design
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ...[1, 2, 3, 4, 5, 6, 7, 8, 9].map((num) => _buildNumberButton(num.toString())),
                        const SizedBox(), // Empty space
                        _buildNumberButton('0'),
                        _buildBackspaceButton(),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Back to home button with better styling
                    TextButton.icon(
                      onPressed: () => context.go('/menu'),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: context.colorScheme.surfaceVariant ,
                        size: 20,
                      ),
                      label: Text(
                        'Retour à l\'accueil',
                        style: TextStyle(
                          color: context.colorScheme.surfaceVariant ,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
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

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberPressed(number),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceVariant ,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colorScheme.surfaceVariant ,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: context.colorScheme.surfaceVariant ,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onBackspace,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primarySwatch[200]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.backspace_rounded,
              size: 28,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
