import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module POS (Point de Vente).
///
/// Le module POS est un module système racine qui englobe toutes les
/// fonctionnalités de point de vente:
/// - Interface staff / tablette caisse
/// - Affichage cuisine (Kitchen Display System)
/// - Gestion des commandes et sessions caisse
/// - Paiements locaux
///
/// IMPORTANT: Ce module est OPTIONNEL et contrôlé uniquement par le SuperAdmin.
/// Si POS = OFF, aucune fonctionnalité POS ne doit être disponible dans l'app.
ModuleDefinition get posModuleDefinition => const ModuleDefinition(
      id: ModuleId.pos,
      category: ModuleCategory.operations,
      name: 'POS / Caisse',
      description:
          'Point de vente complet avec interface staff, affichage cuisine, gestion des commandes et paiements.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [ModuleId.ordering, ModuleId.payments],
    );

// Note: Staff tablet and kitchen display are internal components of POS,
// not separate modules. All functionality is controlled by ModuleId.pos.
