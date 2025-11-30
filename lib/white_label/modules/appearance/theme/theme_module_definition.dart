import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Thème.
///
/// Ce module permet la personnalisation des couleurs, polices et
/// styles visuels de l'application.
ModuleDefinition get themeModuleDefinition => const ModuleDefinition(
      id: ModuleId.theme,
      category: ModuleCategory.appearance,
      name: 'Thème',
      description: 'Personnalisation des couleurs et du style de l\'app.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter l'intégration avec ThemeManager existant
