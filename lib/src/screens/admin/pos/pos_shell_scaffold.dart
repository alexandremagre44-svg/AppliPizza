// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/screens/admin/pos/pos_shell_scaffold.dart
// Reusable scaffold for POS screens

import 'package:flutter/material.dart';

/// Scaffold réutilisable spécifique pour les écrans POS
/// 
/// Ce widget fournit une structure cohérente pour tous les écrans
/// du module caisse (POS), incluant l'AppBar et le style général.
class PosShellScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  // Plus tard: restoName, currentUser, actions, etc.

  const PosShellScaffold({
    super.key,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(title ?? 'Caisse'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        // Plus tard: bouton retour admin, bouton paramètres, infos utilisateur, etc.
      ),
      body: child,
    );
  }
}
