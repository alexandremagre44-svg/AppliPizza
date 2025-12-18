// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/screens/admin/pos/pos_screen.dart
// Main POS (Point of Sale) screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pos_shell_scaffold.dart';
import 'widgets/pos_catalog_view.dart';
import 'widgets/pos_cart_panel_v2.dart';
import 'widgets/pos_actions_panel_v2.dart';

/// Écran principal de la caisse (POS)
/// 
/// Utilise une structure à 3 colonnes:
/// - Colonne 1: Catalogue produits (réutilise la logique staff tablet)
/// - Colonne 2: Panier avec résumé
/// - Colonne 3: Actions caisse (Encaisser, Annuler, Paiement)
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
        // Colonne 1: Catalogue produits
        Expanded(
          flex: 2,
          child: Builder(
            builder: (context) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: const PosCatalogView(),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        
        // Colonne 2: Panier
        Expanded(
          flex: 1,
          child: Builder(
            builder: (context) => Container(
              color: Theme.of(context).colorScheme.surface,
              child: const PosCartPanelV2(),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        
        // Colonne 3: Actions caisse
        SizedBox(
          width: 300,
          child: Builder(
            builder: (context) => Container(
              color: Theme.of(context).colorScheme.surface,
              child: const PosActionsPanelV2(),
            ),
          ),
        ),
      ],
    );
  }

  /// Layout mobile (colonnes empilées)
  Widget _buildMobileLayout(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        // Catalog takes most of the space
        Expanded(
          flex: 3,
          child: Builder(
            builder: (context) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: const PosCatalogView(),
            ),
          ),
        ),
        const Divider(height: 1),
        // Cart and actions split the bottom
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) => Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: const PosCartPanelV2(),
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 200,
                child: Builder(
                  builder: (context) => Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: const PosActionsPanelV2(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
