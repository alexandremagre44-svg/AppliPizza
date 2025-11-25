// lib/builder/blocks/system_block_runtime.dart
// Runtime version of SystemBlock - renders existing application modules
// Phase 5: Pure StatelessWidget, no ConsumerWidget, layout logic only
//
// Removed in Phase 5 refactor:
// - flutter_riverpod (no ConsumerWidget)
// - Direct widget imports (LoyaltySectionWidget, etc.)
// - Provider-based data fetching
// All data is now demo data; real data comes from parent widgets.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../utils/block_config_helper.dart';

/// System Block Runtime Widget
/// 
/// Phase 5 compliant: Pure StatelessWidget, no ConsumerWidget.
/// All business logic and data fetching is handled by parent widgets.
/// This widget only handles layout and visual rendering.
/// 
/// Supported modules:
/// - roulette: Roulette wheel access card
/// - loyalty: Loyalty points section
/// - rewards: Rewards tickets widget
/// - accountActivity: Account activity widget
/// 
/// Configuration via BlockConfigHelper:
/// - moduleType: Required - the type of system module to render
/// - padding: Optional padding around the module (in pixels)
/// - margin: Optional margin around the module (in pixels)
/// - backgroundColor: Optional background color (hex string)
/// - height: Optional fixed height (in pixels)
class SystemBlockRuntime extends StatelessWidget {
  final BuilderBlock block;
  
  /// Maximum content width in pixels (optional constraint)
  final double? maxContentWidth;
  
  // Demo data constants for Phase 5 compliance
  // In production, real data comes from parent widgets via providers
  static const int _demoLoyaltyPoints = 350;
  static const double _demoLoyaltyProgress = 0.35;
  static const int _demoOrdersCount = 12;
  static const int _demoFavoritesCount = 5;

  const SystemBlockRuntime({
    super.key,
    required this.block,
    this.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get the module type from config
    final moduleType = helper.getString('moduleType', defaultValue: '');
    
    // Get styling configuration via BlockConfigHelper
    final padding = helper.getEdgeInsets('padding', defaultValue: const EdgeInsets.all(16));
    final margin = helper.getEdgeInsets('margin');
    final backgroundColor = helper.getColor('backgroundColor');
    final height = helper.has('height') ? helper.getDouble('height') : null;
    
    // Build the module widget with error handling
    Widget moduleWidget = _buildModuleWidgetSafe(context, moduleType);
    
    // Apply padding
    moduleWidget = Padding(
      padding: padding,
      child: moduleWidget,
    );
    
    // Apply height constraint if specified
    if (height != null && height > 0) {
      moduleWidget = SizedBox(
        height: height,
        child: moduleWidget,
      );
    }
    
    // Apply background and margin if specified
    if (margin != EdgeInsets.zero || backgroundColor != null) {
      moduleWidget = Container(
        margin: margin,
        decoration: backgroundColor != null
            ? BoxDecoration(color: backgroundColor)
            : null,
        child: moduleWidget,
      );
    }
    
    // Apply max content width constraint if specified
    if (maxContentWidth != null) {
      moduleWidget = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth!),
          child: moduleWidget,
        ),
      );
    }
    
    // Ensure full width
    return SizedBox(
      width: double.infinity,
      child: moduleWidget,
    );
  }

  /// Safely builds the module widget with error handling
  /// Returns a fallback widget if an exception occurs
  Widget _buildModuleWidgetSafe(BuildContext context, String moduleType) {
    try {
      return _buildModuleWidget(context, moduleType);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error building system module "$moduleType": $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return _buildErrorFallback(moduleType, e.toString());
    }
  }

  /// Routes to the appropriate module builder based on type
  Widget _buildModuleWidget(BuildContext context, String moduleType) {
    switch (moduleType) {
      case 'roulette':
        return _buildRouletteModule(context);
      case 'loyalty':
        return _buildLoyaltyModule(context);
      case 'rewards':
        return _buildRewardsModule(context);
      case 'accountActivity':
        return _buildAccountActivityModule(context);
      default:
        return _buildUnknownModule(moduleType);
    }
  }

  /// Build Roulette module - access card for roulette game
  /// Phase 5: No providers, pure UI widget
  Widget _buildRouletteModule(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade400,
            Colors.purple.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.casino,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Roue de la Chance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tentez votre chance et gagnez des récompenses !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/roulette');
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Jouer maintenant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Loyalty module - loyalty section display
  /// Phase 5: No providers, uses demo data for display
  Widget _buildLoyaltyModule(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: Colors.amber.shade700, size: 28),
              const SizedBox(width: 12),
              Text(
                'Programme Fidélité',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_demoLoyaltyPoints points',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Bronze',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _demoLoyaltyProgress,
              minHeight: 8,
              backgroundColor: Colors.amber.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Encore 650 pts pour une pizza gratuite',
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Rewards module - rewards tickets display
  /// Phase 5: No providers, shows placeholder when no rewards
  Widget _buildRewardsModule(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 48,
            color: Colors.orange.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Mes récompenses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune récompense disponible',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange.shade600,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/rewards');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
              side: BorderSide(color: Colors.orange.shade300),
            ),
            child: const Text('Voir toutes les récompenses'),
          ),
        ],
      ),
    );
  }

  /// Build Account Activity module - orders and favorites display
  /// Phase 5: No providers, uses demo data for display
  Widget _buildAccountActivityModule(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                'Activité du compte',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityRow(
            context,
            icon: Icons.shopping_bag_outlined,
            label: 'Mes commandes',
            count: _demoOrdersCount,
            onTap: () => Navigator.of(context).pushNamed('/orders'),
          ),
          const SizedBox(height: 12),
          _buildActivityRow(
            context,
            icon: Icons.favorite_outline,
            label: 'Mes favoris',
            count: _demoFavoritesCount,
            onTap: () => Navigator.of(context).pushNamed('/favorites'),
          ),
        ],
      ),
    );
  }

  /// Helper to build activity row
  Widget _buildActivityRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade600, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.blue.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  /// Build unknown module placeholder
  Widget _buildUnknownModule(String moduleType) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 12),
          Text(
            'Module système inconnu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Type: $moduleType',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error fallback widget
  Widget _buildErrorFallback(String moduleType, String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Erreur de rendu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Module: $moduleType',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade600,
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 10,
                color: Colors.red.shade500,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
