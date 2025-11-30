import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Pointeuse.
///
/// Ce module gère le temps de travail et le pointage du personnel,
/// permettant un suivi précis des heures travaillées.
ModuleDefinition get timeRecorderModuleDefinition => const ModuleDefinition(
      id: ModuleId.timeRecorder,
      category: ModuleCategory.operations,
      name: 'Pointeuse',
      description: 'Gestion du temps de travail et pointage du personnel.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter les rapports de temps et exports
