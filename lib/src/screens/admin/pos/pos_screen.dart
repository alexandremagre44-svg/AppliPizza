// lib/src/screens/admin/pos/pos_screen.dart
// Main POS (Point of Sale) screen - Phase 1 skeleton

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pos_shell_scaffold.dart';

/// Écran principal de la caisse (POS)
/// 
/// Phase 1: Structure squelette avec layout 3 colonnes
/// - Colonne 1: Catégories / Produits (à implémenter)
/// - Colonne 2: Panier (à implémenter)
/// - Colonne 3: Actions caisse (à implémenter)
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PosShellScaffold(
      title: 'Caisse',
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout: 3 columns on tablet/desktop, single column on mobile
          final isWideScreen = constraints.maxWidth > 800;

          if (isWideScreen) {
            return _buildThreeColumnLayout(context, colorScheme);
          } else {
            return _buildMobileLayout(context, colorScheme);
          }
        },
      ),
    );
  }

  /// Layout 3 colonnes pour tablette/desktop
  Widget _buildThreeColumnLayout(BuildContext context, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonne 1: Catégories / Produits
        Expanded(
          flex: 2,
          child: _buildProductsColumn(context, colorScheme),
        ),
        const VerticalDivider(width: 1),
        
        // Colonne 2: Panier
        Expanded(
          flex: 1,
          child: _buildCartColumn(context, colorScheme),
        ),
        const VerticalDivider(width: 1),
        
        // Colonne 3: Actions caisse
        SizedBox(
          width: 280,
          child: _buildActionsColumn(context, colorScheme),
        ),
      ],
    );
  }

  /// Layout mobile (colonnes empilées)
  Widget _buildMobileLayout(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProductsColumn(context, colorScheme),
          const Divider(height: 1),
          _buildCartColumn(context, colorScheme),
          const Divider(height: 1),
          _buildActionsColumn(context, colorScheme),
        ],
      ),
    );
  }

  /// Colonne 1: Produits (placeholder)
  Widget _buildProductsColumn(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produits',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Catégories et produits',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'À implémenter en Phase 2',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Colonne 2: Panier (placeholder)
  Widget _buildCartColumn(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panier',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Panier de commande',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'À implémenter en Phase 2',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Colonne 3: Actions caisse (placeholder)
  Widget _buildActionsColumn(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.point_of_sale,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Actions caisse',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paiement, infos client, etc.\nÀ implémenter en Phase 2',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
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
