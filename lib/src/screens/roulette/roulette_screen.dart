// lib/src/screens/roulette/roulette_screen.dart
// Client-side roulette wheel screen using custom PizzaRouletteWheel widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/roulette_config.dart';
import '../../services/roulette_segment_service.dart';
import '../../services/roulette_service.dart';
import '../../services/roulette_rules_service.dart';
import '../../widgets/pizza_roulette_wheel.dart';
import '../../providers/cart_provider.dart';
import '../../design_system/app_theme.dart';
import '../../core/constants.dart';
import '../../utils/roulette_reward_mapper.dart';

class RouletteScreen extends ConsumerStatefulWidget {
  final String userId;
  
  const RouletteScreen({super.key, required this.userId});

  @override
  ConsumerState<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends ConsumerState<RouletteScreen> {
  final RouletteSegmentService _segmentService = RouletteSegmentService();
  final RouletteService _rouletteService = RouletteService();
  final RouletteRulesService _rulesService = RouletteRulesService();
  final GlobalKey<PizzaRouletteWheelState> _wheelKey = GlobalKey<PizzaRouletteWheelState>();
  
  List<RouletteSegment> _segments = [];
  bool _isLoading = true;
  bool _isSpinning = false;
  bool _canSpin = false;
  RouletteSegment? _lastResult;
  RouletteStatus? _eligibilityStatus;
  
  @override
  void initState() {
    super.initState();
    _loadSegmentsAndCheckSpinAvailability();
  }

  Future<void> _loadSegmentsAndCheckSpinAvailability() async {
    setState(() => _isLoading = true);
    
    try {
      final segments = await _segmentService.getActiveSegments();
      final status = await _rulesService.checkEligibility(widget.userId);
      
      setState(() {
        _segments = segments;
        _eligibilityStatus = status;
        _canSpin = status.canSpin;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading segments: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onSpinPressed() {
    if (!_canSpin || _isSpinning || _segments.isEmpty) {
      return;
    }
    
    setState(() {
      _isSpinning = true;
      _lastResult = null;
    });
    
    // Trigger the wheel spin via GlobalKey
    _wheelKey.currentState?.spin();
  }

  Future<void> _onResult(RouletteSegment result) async {
    // Record the spin in Firestore
    await _rouletteService.recordSpin(widget.userId, result);
    
    setState(() {
      _lastResult = result;
      _isSpinning = false;
      _canSpin = false;
    });
    
    // NOUVEAU: Create reward ticket instead of applying directly to cart
    await _createRewardTicket(result);
    
    // Show result dialog after a brief delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _showResultDialog(result);
    }
  }

  /// Create a reward ticket from the roulette segment
  Future<void> _createRewardTicket(RouletteSegment segment) async {
    try {
      // Don't create tickets for "nothing" segments
      if (segment.rewardType == RewardType.none) {
        return;
      }

      // Create ticket using the mapper utility
      await createTicketFromRouletteSegment(
        userId: widget.userId,
        segment: segment,
      );
      
      print('Reward ticket created for segment: ${segment.label}');
    } catch (e) {
      print('Error creating reward ticket: $e');
    }
  }

  void _showResultDialog(RouletteSegment segment) {
    final isWin = segment.rewardType != RewardType.none;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialog,
        ),
        title: Row(
          children: [
            Icon(
              isWin ? Icons.celebration : Icons.sentiment_dissatisfied,
              color: isWin ? AppColors.success : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isWin ? 'Félicitations !' : 'Dommage...',
                style: AppTextStyles.titleLarge.copyWith(
                  color: isWin ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isWin 
                ? 'Vous avez gagné :'
                : 'Réessayez demain pour tenter votre chance !',
              style: AppTextStyles.bodyMedium,
            ),
            if (isWin) ...[
              const SizedBox(height: 16),
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: segment.color.withOpacity(0.1),
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: segment.color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    if (segment.iconName != null)
                      Icon(
                        _getIconData(segment.iconName!),
                        color: segment.color,
                        size: 32,
                      ),
                    if (segment.iconName != null) const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            segment.label,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: segment.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (segment.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              segment.description!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (segment.rewardType != RewardType.none) ...[
                const SizedBox(height: 16),
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: AppRadius.card,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getRewardInstructions(segment),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          if (isWin && segment.rewardType != RewardType.bonusPoints)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to rewards screen to see the ticket
                context.go(AppRoutes.rewards);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Voir mes récompenses'),
            ),
          if (isWin && segment.rewardType == RewardType.bonusPoints)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Super !'),
            ),
        ],
      ),
    );
  }

  String _getRewardInstructions(RouletteSegment segment) {
    switch (segment.rewardType) {
      case RewardType.bonusPoints:
        final points = segment.rewardValue?.toInt() ?? segment.value ?? 0;
        return '$points points ont été ajoutés à votre compte fidélité !';
      case RewardType.percentageDiscount:
        return 'Un ticket de réduction de ${segment.rewardValue?.toStringAsFixed(0)}% a été ajouté à vos récompenses.';
      case RewardType.fixedAmountDiscount:
        return 'Un ticket de réduction de ${segment.rewardValue?.toStringAsFixed(2)}€ a été ajouté à vos récompenses.';
      case RewardType.freeProduct:
        return 'Un ticket pour un produit gratuit a été ajouté à vos récompenses !';
      case RewardType.freeDrink:
        return 'Un ticket pour une boisson gratuite a été ajouté à vos récompenses !';
      case RewardType.freePizza:
        return 'Un ticket pour une pizza gratuite a été ajouté à vos récompenses !';
      case RewardType.freeDessert:
        return 'Un ticket pour un dessert gratuit a été ajouté à vos récompenses !';
      case RewardType.none:
        return '';
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_pizza':
        return Icons.local_pizza;
      case 'local_drink':
        return Icons.local_drink;
      case 'cake':
        return Icons.cake;
      case 'stars':
        return Icons.stars;
      case 'percent':
        return Icons.percent;
      case 'euro':
        return Icons.euro;
      case 'close':
        return Icons.close;
      case 'card_giftcard':
        return Icons.card_giftcard;
      default:
        return Icons.card_giftcard;
    }
  }

  String _formatNextEligibleTime(DateTime nextTime) {
    final now = DateTime.now();
    final difference = nextTime.difference(now);
    
    if (difference.inDays > 0) {
      return 'Disponible dans ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Disponible dans ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Disponible dans ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Disponible maintenant';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Roue de la Chance'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Show proper message when roulette is not configured or segments are empty
    if (_segments.isEmpty || (_eligibilityStatus != null && 
        _eligibilityStatus!.reason == 'La roulette n\'est pas encore configurée.')) {
      final isNotConfigured = _eligibilityStatus?.reason == 'La roulette n\'est pas encore configurée.';
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Roue de la Chance'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: AppSpacing.paddingXL,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.casino,
                  size: 80,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 24),
                Text(
                  isNotConfigured 
                      ? 'La roulette n\'est pas encore disponible.'
                      : 'La roue n\'est pas disponible',
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isNotConfigured
                      ? 'Veuillez réessayer plus tard.'
                      : 'Revenez plus tard pour tenter votre chance !',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roue de la Chance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Status banner if user can't spin
          if (!_canSpin && !_isSpinning && _eligibilityStatus != null)
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.warning,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _eligibilityStatus!.reason ?? 'Non disponible',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  if (_eligibilityStatus!.nextEligibleAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatNextEligibleTime(_eligibilityStatus!.nextEligibleAt!),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLG,
              child: Column(
                children: [
                  // Title
                  Text(
                    'Tentez votre chance !',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tournez la roue pour gagner des récompenses',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Pizza Roulette Wheel
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: PizzaRouletteWheel(
                      key: _wheelKey,
                      segments: _segments,
                      onResult: _onResult,
                      isSpinning: _isSpinning,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Result display
                  if (_lastResult != null)
                    Container(
                      padding: AppSpacing.paddingMD,
                      decoration: BoxDecoration(
                        color: _lastResult!.rewardType != RewardType.none
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.neutral200,
                        borderRadius: AppRadius.card,
                        border: Border.all(
                          color: _lastResult!.rewardType != RewardType.none
                              ? AppColors.success
                              : AppColors.neutral400,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _lastResult!.rewardType != RewardType.none
                                ? Icons.celebration
                                : Icons.sentiment_dissatisfied,
                            size: 48,
                            color: _lastResult!.rewardType != RewardType.none
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _lastResult!.rewardType != RewardType.none
                                ? 'Félicitations, vous avez gagné :'
                                : 'Dommage...',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _lastResult!.label,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Spin button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_canSpin && !_isSpinning) ? _onSpinPressed : null,
                      icon: Icon(
                        _isSpinning ? Icons.hourglass_empty : Icons.casino,
                      ),
                      label: Text(
                        _isSpinning 
                            ? 'La roue tourne...' 
                            : 'Tourner la roue',
                        style: AppTextStyles.titleMedium,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.neutral300,
                        disabledForegroundColor: AppColors.neutral600,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.button,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Info text with rules
                  Container(
                    padding: AppSpacing.paddingMD,
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: AppRadius.card,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.info,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Règles de la roulette',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vos gains sont automatiquement ajoutés à vos récompenses et utilisables sur votre prochaine commande.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
