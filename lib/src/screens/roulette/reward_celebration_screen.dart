// lib/src/screens/roulette/reward_celebration_screen.dart
// Celebration screen after winning a prize

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import '../../models/roulette_config.dart';
import '../../services/user_profile_service.dart';
import '../../design_system/app_theme.dart';

class RewardCelebrationScreen extends StatefulWidget {
  final RouletteSegment segment;
  final String userId;
  
  const RewardCelebrationScreen({
    super.key,
    required this.segment,
    required this.userId,
  });

  @override
  State<RewardCelebrationScreen> createState() => _RewardCelebrationScreenState();
}

class _RewardCelebrationScreenState extends State<RewardCelebrationScreen> 
    with SingleTickerProviderStateMixin {
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 5),
  );
  final UserProfileService _userProfileService = UserProfileService();
  
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  bool _isProcessing = true;
  bool _hasReward = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _scaleController.forward();
    _hasReward = widget.segment.rewardId != 'nothing';
    
    if (_hasReward) {
      _confettiController.play();
      _addRewardToProfile();
    } else {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _addRewardToProfile() async {
    // Add reward to user profile
    // This would depend on your user profile structure
    try {
      final profile = await _userProfileService.getUserProfile(widget.userId);
      
      if (profile != null) {
        // Add reward based on type
        if (widget.segment.rewardId.startsWith('bonus_points')) {
          // Extract points from rewardId like "bonus_points_100"
          final pointsStr = widget.segment.rewardId.split('_').last;
          final points = int.tryParse(pointsStr) ?? widget.segment.value ?? 0;
          
          if (points > 0) {
            final updatedPoints = (profile.loyaltyPoints ?? 0) + points;
            await _userProfileService.saveUserProfile(
              profile.copyWith(loyaltyPoints: updatedPoints),
            );
          }
        }
        // For other reward types (free_pizza, free_drink, etc.),
        // you would add them to the user's coupons/rewards list
        // This depends on your implementation of promotions/coupons
      }
    } catch (e) {
      print('Error adding reward to profile: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  IconData _getRewardIcon() {
    final rewardId = widget.segment.rewardId;
    if (rewardId.contains('pizza')) return Icons.local_pizza;
    if (rewardId.contains('drink')) return Icons.local_drink;
    if (rewardId.contains('dessert')) return Icons.cake;
    if (rewardId.contains('points')) return Icons.stars;
    return Icons.celebration;
  }

  String _getRewardMessage() {
    if (widget.segment.rewardId == 'nothing') {
      return 'Pas de chance cette fois !';
    }
    return 'Félicitations !';
  }

  String _getRewardDescription() {
    if (widget.segment.rewardId == 'nothing') {
      return 'Revenez demain pour retenter votre chance';
    }
    return 'Vous avez gagné : ${widget.segment.label}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _hasReward
                    ? [
                        AppColors.primaryRed,
                        AppColors.primaryRed.withOpacity(0.7),
                      ]
                    : [
                        AppColors.textLight,
                        AppColors.textLight.withOpacity(0.7),
                      ],
              ),
            ),
          ),
          
          // Confetti
          if (_hasReward) ...[
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: math.pi / 2,
                maxBlastForce: 10,
                minBlastForce: 5,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.1,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 0,
                maxBlastForce: 10,
                minBlastForce: 5,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.1,
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: math.pi,
                maxBlastForce: 10,
                minBlastForce: 5,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.1,
              ),
            ),
          ],
          
          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: AppSpacing.paddingXL,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated icon
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getRewardIcon(),
                          size: 80,
                          color: _hasReward 
                              ? AppColors.primaryRed 
                              : AppColors.textLight,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: AppSpacing.xxl),
                    
                    // Message
                    Text(
                      _getRewardMessage(),
                      style: AppTextStyles.displaySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: AppSpacing.lg),
                    
                    // Description
                    Container(
                      padding: AppSpacing.paddingLG,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.cardLarge,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getRewardDescription(),
                            style: AppTextStyles.titleLarge.copyWith(
                              color: _hasReward 
                                  ? AppColors.primaryRed 
                                  : AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          if (_isProcessing) ...[
                            SizedBox(height: AppSpacing.md),
                            const CircularProgressIndicator(),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Ajout de votre récompense...',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                          
                          if (!_isProcessing && _hasReward) ...[
                            SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.successGreen,
                                  size: 20,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Récompense ajoutée à votre profil',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.successGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    SizedBox(height: AppSpacing.xxl),
                    
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _hasReward 
                              ? AppColors.primaryRed 
                              : AppColors.textDark,
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.button,
                          ),
                        ),
                        child: const Text('Continuer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
