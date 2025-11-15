// lib/src/screens/client/rewards/rewards_screen.dart
// Page Récompenses avec navigation vers la Roulette

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../roulette/roulette_screen.dart';
import '../../../providers/auth_provider.dart';

/// Page Récompenses
/// Affiche les informations sur les récompenses et permet d'accéder à la roue
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Récompenses'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSpacing.xl),
            
            // Hero section with icon
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            
            SizedBox(height: AppSpacing.xxl),
            
            // Title
            Text(
              'Tentez votre chance !',
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSpacing.md),
            
            // Description
            Text(
              'Tournez la roue et tentez de gagner des récompenses exclusives !',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSpacing.xxxl),
            
            // Main CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RouletteScreen(
                        userId: authState.userId ?? 'guest',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.casino, size: 28),
                label: Text(
                  'Tourner la roue',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: AppSpacing.xxxl),
            
            // Info cards
            _buildInfoCard(
              context,
              icon: Icons.stars,
              title: 'Récompenses variées',
              description: 'Gagnez des pizzas, boissons, desserts ou points de fidélité',
              color: Colors.amber,
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            _buildInfoCard(
              context,
              icon: Icons.calendar_today,
              title: 'Une chance par jour',
              description: 'Revenez chaque jour pour tenter votre chance',
              color: Colors.blue,
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            _buildInfoCard(
              context,
              icon: Icons.local_offer,
              title: 'Récompenses instantanées',
              description: 'Les gains sont automatiquement ajoutés à votre compte',
              color: Colors.green,
            ),
            
            SizedBox(height: AppSpacing.xxxl),
            
            // Placeholder for rewards history
            Container(
              padding: AppSpacing.paddingXL,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadius.card,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Historique des récompenses',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Vos récompenses apparaîtront ici',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.cardSmall,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
