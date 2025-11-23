// lib/modules/customization/presentation/pages/customization_page.dart
// TODO: Implémenter la page de personnalisation lors de la migration

import 'package:flutter/material.dart';

/// Page de personnalisation d'un article
class CustomizationPage extends StatelessWidget {
  const CustomizationPage({super.key});
  
  /// Bridge constructor pour créer depuis l'ancienne page
  /// TODO: À implémenter lors de la Phase 3 de migration
  /// @param legacy L'ancienne page de customization
  /// IMPORTANT: Ce constructeur n'est PAS utilisé dans l'app actuelle
  factory CustomizationPage.bridgeFromLegacy(dynamic legacyPage) {
    // TODO: Mapping depuis pizza_customization_modal.dart ou menu_customization_modal.dart
    // Permet de créer la nouvelle page depuis l'ancienne interface
    throw UnimplementedError('Bridge non implémenté - Phase 3');
  }
  
  /// Bridge constructor pour créer depuis des paramètres legacy
  /// TODO: À implémenter lors de la Phase 3 de migration
  factory CustomizationPage.fromLegacyParams({
    required dynamic product,
    required dynamic ingredients,
  }) {
    // TODO: Créer la page avec les paramètres de l'ancien système
    throw UnimplementedError('Bridge non implémenté - Phase 3');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnalisation'),
      ),
      body: const Center(
        child: Text('TODO: Implémenter la page de personnalisation'),
      ),
    );
  }
}
