/// lib/superadmin/layout/superadmin_layout.dart
///
/// Layout principal du module Super-Admin.
/// Structure en 3 parties : sidebar à gauche, header en haut, zone centrale.
library;

import 'package:flutter/material.dart';

import 'superadmin_sidebar.dart';
import 'superadmin_header.dart';
import '../../white_label/theme/theme_extensions.dart';

/// Widget Layout principal pour le module Super-Admin.
/// 
/// Structure :
/// - Colonne gauche : [SuperAdminSidebar]
/// - En haut : [SuperAdminHeader]
/// - Zone centrale : [body] (contenu de la page)
class SuperAdminLayout extends StatelessWidget {
  /// Contenu principal de la page.
  final Widget body;

  const SuperAdminLayout({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Row(
        children: [
          // Sidebar à gauche
          const SuperAdminSidebar(),
          // Zone principale (header + body)
          Expanded(
            child: Column(
              children: [
                // Header en haut
                const SuperAdminHeader(),
                // Zone centrale (contenu de la page)
                Expanded(
                  child: body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
