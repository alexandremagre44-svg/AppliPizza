// lib/src/screens/roulette/pizza_wheel_demo_screen.dart
// Demo screen for testing PizzaRouletteWheel widget

import 'package:flutter/material.dart';
import '../../models/roulette_config.dart';
import '../../widgets/pizza_roulette_wheel.dart';
import '../../design_system/app_theme.dart';

/// Demo screen to test the PizzaRouletteWheel widget
class PizzaWheelDemoScreen extends StatefulWidget {
  /// Creates a demo screen
  const PizzaWheelDemoScreen({super.key});

  @override
  State<PizzaWheelDemoScreen> createState() => _PizzaWheelDemoScreenState();
}

class _PizzaWheelDemoScreenState extends State<PizzaWheelDemoScreen> {
  final GlobalKey<PizzaRouletteWheelState> _wheelKey = GlobalKey();
  bool _isSpinning = false;
  RouletteSegment? _lastResult;
  int _spinCount = 0;

  // Demo segments with various configurations
  final List<RouletteSegment> _segments = [
    RouletteSegment(
      id: 'seg1',
      label: 'Pizza offerte',
      rewardId: 'free_pizza',
      probability: 5.0,
      color: const Color(0xFFD32F2F), // Rouge
      iconName: 'local_pizza',
      description: 'Une pizza gratuite',
      rewardType: RewardType.freeProduct,
    ),
    RouletteSegment(
      id: 'seg2',
      label: '-20%',
      rewardId: 'discount_20',
      probability: 15.0,
      color: const Color(0xFF3498DB), // Bleu
      iconName: 'percent',
      description: 'Réduction de 20%',
      rewardType: RewardType.percentageDiscount,
      rewardValue: 20.0,
    ),
    RouletteSegment(
      id: 'seg3',
      label: 'Boisson offerte',
      rewardId: 'free_drink',
      probability: 10.0,
      color: const Color(0xFF4ECDC4), // Teal
      iconName: 'local_drink',
      description: 'Une boisson gratuite',
      rewardType: RewardType.freeDrink,
    ),
    RouletteSegment(
      id: 'seg4',
      label: '+100 points',
      rewardId: 'points_100',
      probability: 25.0,
      color: const Color(0xFFFFD700), // Or
      iconName: 'stars',
      description: '100 points de fidélité',
      rewardType: RewardType.none,
    ),
    RouletteSegment(
      id: 'seg5',
      label: '-10%',
      rewardId: 'discount_10',
      probability: 20.0,
      color: const Color(0xFF9B59B6), // Violet
      iconName: 'percent',
      description: 'Réduction de 10%',
      rewardType: RewardType.percentageDiscount,
      rewardValue: 10.0,
    ),
    RouletteSegment(
      id: 'seg6',
      label: 'Dessert offert',
      rewardId: 'free_dessert',
      probability: 5.0,
      color: const Color(0xFFE91E63), // Rose
      iconName: 'cake',
      description: 'Un dessert gratuit',
      rewardType: RewardType.freeProduct,
    ),
    RouletteSegment(
      id: 'seg7',
      label: 'Raté !',
      rewardId: 'none',
      probability: 20.0,
      color: const Color(0xFF95A5A6), // Gris
      iconName: 'close',
      description: 'Pas de gain',
      rewardType: RewardType.none,
    ),
  ];

  void _handleSpin() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _lastResult = null;
    });

    _wheelKey.currentState?.spin();
  }

  void _handleResult(RouletteSegment segment) {
    setState(() {
      _isSpinning = false;
      _lastResult = segment;
      _spinCount++;
    });

    // Show result dialog after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showResultDialog(segment);
      }
    });
  }

  void _showResultDialog(RouletteSegment segment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              _getIconData(segment.iconName),
              color: segment.color,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Résultat'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              segment.label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (segment.description != null) ...[
              const SizedBox(height: 8),
              Text(
                segment.description!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.casino, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Probabilité: ${segment.probability.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSpin();
            },
            child: const Text('Retourner'),
          ),
        ],
      ),
    );
  }

  IconData? _getIconData(String? iconName) {
    if (iconName == null) return null;
    
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
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final wheelSize = screenWidth < 600 ? screenWidth * 0.85 : 450.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo: Roue de la chance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'Testez votre chance !',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tournez la roue et découvrez votre gain',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // The Wheel
                SizedBox(
                  width: wheelSize,
                  height: wheelSize,
                  child: PizzaRouletteWheel(
                    key: _wheelKey,
                    segments: _segments,
                    onResult: _handleResult,
                    isSpinning: _isSpinning,
                  ),
                ),

                const SizedBox(height: 48),

                // Spin Button
                SizedBox(
                  width: 200,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSpinning ? null : _handleSpin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: _isSpinning ? 0 : 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isSpinning)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          const Icon(Icons.play_arrow, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          _isSpinning ? 'Rotation...' : 'Tourner',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.casino,
                            label: 'Tours',
                            value: _spinCount.toString(),
                          ),
                          _buildStatItem(
                            icon: Icons.segment,
                            label: 'Segments',
                            value: _segments.length.toString(),
                          ),
                        ],
                      ),
                      if (_lastResult != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _getIconData(_lastResult!.iconName),
                              color: _lastResult!.color,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Dernier résultat:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _lastResult!.label,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
