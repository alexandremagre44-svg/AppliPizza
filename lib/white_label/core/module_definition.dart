import 'module_category.dart';

/// Définition complète d'un module de l'application white-label.
///
/// Cette classe contient toutes les métadonnées décrivant un module :
/// son identifiant, sa catégorie, son nom, sa description, et ses contraintes.
///
/// Usage : utilisé par le ModuleRegistry pour enregistrer tous les modules
/// disponibles, par le SuperAdmin pour afficher les modules, et par le
/// générateur d'app pour savoir quels modules inclure.
class ModuleDefinition {
  /// Identifiant unique du module.
  final String id;

  /// Catégorie du module (core, payment, marketing, etc.).
  final ModuleCategory category;

  /// Nom lisible du module.
  final String name;

  /// Description courte du module.
  final String description;

  /// Indique si le module est premium (payant / plan supérieur).
  final bool isPremium;

  /// Indique si le module nécessite une configuration avant utilisation.
  final bool requiresConfiguration;

  /// Liste des modules dont celui-ci dépend.
  final List<String> dependencies;

  /// Constructeur const pour une définition de module.
  const ModuleDefinition({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    this.isPremium = false,
    this.requiresConfiguration = false,
    this.dependencies = const [],
  });

  @override
  String toString() {
    return 'ModuleDefinition('
        'id: $id, '
        'category: ${category.label}, '
        'name: $name, '
        'isPremium: $isPremium, '
        'requiresConfiguration: $requiresConfiguration, '
        'dependencies: $dependencies'
        ')';
  }

  // TODO: Ajouter un champ "icon" (IconData) pour l'affichage UI
  // TODO: Ajouter un champ "routeName" pour le routing runtime
  // TODO: Ajouter un champ "settingsScreenBuilder" pour l'écran de config
  // TODO: Ajouter un champ "version" pour le versioning des modules
}
