// lib/src/screens/admin/pos/pos_shell_scaffold.dart
// Reusable scaffold for POS screens - ShopCaisse Theme

import 'package:flutter/material.dart';
import 'design/pos_theme.dart';

/// Scaffold réutilisable spécifique pour les écrans POS
/// 
/// Ce widget fournit une structure cohérente pour tous les écrans
/// du module caisse (POS), incluant l'AppBar et le style ShopCaisse.
class PosShellScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;

  const PosShellScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PosColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.point_of_sale,
              color: PosColors.textOnPrimary,
              size: 24,
            ),
            const SizedBox(width: PosSpacing.sm),
            Text(title ?? 'Caisse'),
          ],
        ),
        backgroundColor: PosColors.primary,
        foregroundColor: PosColors.textOnPrimary,
        elevation: 0,
        actions: actions,
      ),
      body: child,
    );
  }
}
