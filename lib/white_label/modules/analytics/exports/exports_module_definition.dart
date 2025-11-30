import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Exports.
///
/// Ce module permet l'export des données en différents formats
/// (CSV, Excel, PDF) pour analyse externe ou archivage.
ModuleDefinition get exportsModuleDefinition => const ModuleDefinition(
      id: ModuleId.exports,
      category: ModuleCategory.analytics,
      name: 'Exports',
      description: 'Export des données en CSV, Excel, etc.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [ModuleId.reporting],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter les templates d'export personnalisés
