import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Tablette staff.
///
/// Ce module fournit une application pour les serveurs et le personnel
/// de salle, facilitant la prise de commandes et le service.
ModuleDefinition get staffTabletModuleDefinition => const ModuleDefinition(
      id: ModuleId.staff_tablet,
      category: ModuleCategory.operations,
      name: 'Tablette staff',
      description: 'Application pour les serveurs et le personnel de salle.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [ModuleId.ordering],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter la gestion des tables et des zones
