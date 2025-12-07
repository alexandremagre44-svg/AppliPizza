// lib/builder/blocks/system_block_runtime.dart
// Runtime version of SystemBlock - renders existing application modules
// Phase 5: Pure StatelessWidget, no ConsumerWidget, layout logic only
// ThemeConfig Integration: Uses theme cardRadius, primaryColor, and spacing
//
// Removed in Phase 5 refactor:
// - flutter_riverpod (no ConsumerWidget)
// - Direct widget imports (LoyaltySectionWidget, etc.)
// - Provider-based data fetching
// All data is now demo data; real data comes from parent widgets.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/builder_block.dart';
import '../models/theme_config.dart';
import '../utils/block_config_helper.dart';
import '../utils/builder_modules.dart' as builder_modules;
import '../runtime/builder_theme_resolver.dart';

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
/// 
/// ThemeConfig: Uses theme.cardRadius, theme.primaryColor, theme.spacing
class SystemBlockRuntime extends StatelessWidget {
  final BuilderBlock block;
  
  /// Maximum content width in pixels (optional constraint)
  final double? maxContentWidth;
  
  /// Optional theme config override
  /// If null, uses theme from context
  final ThemeConfig? themeConfig;
  
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
    this.themeConfig,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get theme (from prop or context)
    final theme = themeConfig ?? context.builderTheme;
    
    // Get the module type from config
    final moduleType = helper.getString('moduleType', defaultValue: '');
    
    // Get styling configuration via BlockConfigHelper - use theme spacing as default
    final padding = helper.getEdgeInsets('padding', defaultValue: EdgeInsets.all(theme.spacing));
    final margin = helper.getEdgeInsets('margin');
    final backgroundColor = helper.getColor('backgroundColor');
    final height = helper.has('height') ? helper.getDouble('height') : null;
    
    // Build the module widget with error handling
    Widget moduleWidget = _buildModuleWidgetSafe(context, moduleType, theme);
    
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
  Widget _buildModuleWidgetSafe(BuildContext context, String moduleType, ThemeConfig theme) {
    try {
      return _buildModuleWidget(context, moduleType, theme);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error building system module "$moduleType": $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return _buildErrorFallback(moduleType, e.toString());
    }
  }

  /// Routes to the appropriate module builder based on type
  Widget _buildModuleWidget(BuildContext context, String moduleType, ThemeConfig theme) {
    // First check if it's a new-style module from builder_modules
    // These are: menu_catalog, cart_module, profile_module, roulette_module
    if (_isBuilderModule(moduleType)) {
      return _buildBuilderModule(context, moduleType, theme);
    }
    
    // Legacy module types (for backward compatibility)
    switch (moduleType) {
      case 'roulette':
        return _buildRouletteModule(context, theme);
      case 'loyalty':
        return _buildLoyaltyModule(context, theme);
      case 'rewards':
        return _buildRewardsModule(context, theme);
      case 'accountActivity':
        return _buildAccountActivityModule(context, theme);
      default:
        return _buildUnknownModule(moduleType, theme);
    }
  }
  
  /// Check if moduleType is a builder module (from builder_modules.dart)
  /// 
  /// FIX: Added all WL modules to builder modules list
  bool _isBuilderModule(String moduleType) {
    const builderModules = [
      'menu_catalog',
      'cart_module',
      'profile_module',
      'roulette_module',
      // WL modules
      'delivery_module',
      'click_collect_module',
      'loyalty_module',
      'rewards_module',
      'promotions_module',
      'newsletter_module',
      'kitchen_module',
      'staff_module',
    ];
    return builderModules.contains(moduleType);
  }
  
  /// Build a module from builder_modules.dart
  /// Uses the renderModule function which properly displays CartModuleWidget and others
  Widget _buildBuilderModule(BuildContext context, String moduleType, ThemeConfig theme) {
    try {
      // Use the renderModule function from builder_modules.dart
      // This renders the actual module widgets (CartModuleWidget, etc.)
      return builder_modules.renderModule(context, moduleType);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error rendering builder module "$moduleType": $e');
      }
      return _buildUnknownModule(moduleType, theme);
    }
  }
  
  /// Get icon for builder module
  IconData _getModuleIcon(String moduleType) {
    switch (moduleType) {
      case 'menu_catalog':
        return Icons.restaurant_menu;
      case 'cart_module':
        return Icons.shopping_cart;
      case 'profile_module':
        return Icons.person;
      case 'roulette_module':
        return Icons.casino;
      default:
        return Icons.extension;
    }
  }
  
  /// Get name for builder module
  String _getModuleName(String moduleType) {
    switch (moduleType) {
      case 'menu_catalog':
        return 'Catalogue Menu';
      case 'cart_module':
        return 'Module Panier';
      case 'profile_module':
        return 'Profil';
      case 'roulette_module':
        return 'Roulette';
      default:
        return 'Module inconnu';
    }
  }

  /// Build Roulette module - access card for roulette game
  /// Phase 5: No providers, pure UI widget
  /// Uses theme for cardRadius, spacing, and font sizes
  Widget _buildRouletteModule(BuildContext context, ThemeConfig theme) {
    return Container(
      padding: EdgeInsets.all(theme.spacing * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade400,
            Colors.purple.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(theme.cardRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.casino,
            size: 64,
            color: Colors.white,
          ),
          SizedBox(height: theme.spacing),
          Text(
            'Roue de la Chance',
            style: TextStyle(
              fontSize: theme.textHeadingSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: theme.spacing / 2),
          Text(
            'Tentez votre chance et gagnez des récompenses !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: theme.textBodySize * 0.875,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: theme.spacing),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/roulette');
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Jouer maintenant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple.shade700,
              padding: EdgeInsets.symmetric(horizontal: theme.spacing * 1.5, vertical: theme.spacing * 0.75),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(theme.buttonRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Loyalty module - loyalty section display
  /// Phase 5: No providers, uses demo data for display
  /// Uses theme for cardRadius, spacing, and font sizes
  Widget _buildLoyaltyModule(BuildContext context, ThemeConfig theme) {
    return Container(
      padding: EdgeInsets.all(theme.spacing * 1.25),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: Colors.amber.shade700, size: 28),
              SizedBox(width: theme.spacing * 0.75),
              Text(
                'Programme Fidélité',
                style: TextStyle(
                  fontSize: theme.textHeadingSize * 0.75,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_demoLoyaltyPoints points',
                style: TextStyle(
                  fontSize: theme.textHeadingSize * 1.15,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: theme.spacing * 0.75, vertical: theme.spacing * 0.375),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(theme.buttonRadius),
                ),
                child: Text(
                  'Bronze',
                  style: TextStyle(
                    fontSize: theme.textBodySize * 0.75,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacing * 0.75),
          ClipRRect(
            borderRadius: BorderRadius.circular(theme.buttonRadius / 2),
            child: LinearProgressIndicator(
              value: _demoLoyaltyProgress,
              minHeight: 8,
              backgroundColor: Colors.amber.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
            ),
          ),
          SizedBox(height: theme.spacing / 2),
          Text(
            'Encore 650 pts pour une pizza gratuite',
            style: TextStyle(
              fontSize: theme.textBodySize * 0.75,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Rewards module - rewards tickets display
  /// Phase 5: No providers, shows placeholder when no rewards
  /// Uses theme for cardRadius, spacing, and font sizes
  Widget _buildRewardsModule(BuildContext context, ThemeConfig theme) {
    return Container(
      padding: EdgeInsets.all(theme.spacing * 1.5),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(theme.cardRadius),
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
          SizedBox(height: theme.spacing * 0.75),
          Text(
            'Mes récompenses',
            style: TextStyle(
              fontSize: theme.textHeadingSize * 0.75,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          SizedBox(height: theme.spacing / 2),
          Text(
            'Aucune récompense disponible',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: theme.textBodySize * 0.875,
              color: Colors.orange.shade600,
            ),
          ),
          SizedBox(height: theme.spacing),
          OutlinedButton(
            onPressed: () {
              context.go('/rewards');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
              side: BorderSide(color: Colors.orange.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(theme.buttonRadius),
              ),
            ),
            child: const Text('Voir toutes les récompenses'),
          ),
        ],
      ),
    );
  }

  /// Build Account Activity module - orders and favorites display
  /// Phase 5: No providers, uses demo data for display
  /// Uses theme for cardRadius, spacing, and font sizes
  Widget _buildAccountActivityModule(BuildContext context, ThemeConfig theme) {
    return Container(
      padding: EdgeInsets.all(theme.spacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.blue.shade700, size: 24),
              SizedBox(width: theme.spacing / 2),
              Text(
                'Activité du compte',
                style: TextStyle(
                  fontSize: theme.textBodySize,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacing),
          _buildActivityRow(
            context,
            theme,
            icon: Icons.shopping_bag_outlined,
            label: 'Mes commandes',
            count: _demoOrdersCount,
            onTap: () => context.go('/orders'),
          ),
          SizedBox(height: theme.spacing * 0.75),
          _buildActivityRow(
            context,
            theme,
            icon: Icons.favorite_outline,
            label: 'Mes favoris',
            count: _demoFavoritesCount,
            onTap: () => context.go('/favorites'),
          ),
        ],
      ),
    );
  }

  /// Helper to build activity row
  Widget _buildActivityRow(
    BuildContext context,
    ThemeConfig theme, {
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.buttonRadius),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: theme.spacing / 2, horizontal: theme.spacing / 4),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade600, size: 24),
            SizedBox(width: theme.spacing * 0.75),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: theme.textBodySize * 0.875,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: theme.spacing * 0.625, vertical: theme.spacing / 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(theme.buttonRadius),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: theme.textBodySize * 0.875,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            SizedBox(width: theme.spacing / 2),
            Icon(Icons.chevron_right, color: Colors.blue.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  /// Build unknown module placeholder
  /// Shows when moduleType is not in the list of available modules
  /// Uses theme for cardRadius, spacing, and font sizes
  /// 
  /// FIX: Safe layout with SizedBox.expand to prevent "RenderBox was not laid out" errors
  Widget _buildUnknownModule(String moduleType, ThemeConfig theme) {
    // Get list of available modules from SystemBlock
    final availableModules = [
      'menu_catalog', 'cart_module', 'profile_module', 'roulette_module',
      'roulette', 'loyalty', 'rewards', 'accountActivity',
      'delivery_module', 'click_collect_module', 'loyalty_module', 'rewards_module',
      'promotions_module', 'newsletter_module', 'kitchen_module', 'staff_module'
    ];
    
    return SizedBox.expand(
      child: Container(
        color: Colors.amber[100],
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, size: 48, color: Colors.orange),
            const SizedBox(height: 12),
            const Text(
              "Module inconnu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("Type: '$moduleType'"),
            const SizedBox(height: 8),
            const Text(
              "Modules disponibles:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              availableModules.join(", "),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
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
