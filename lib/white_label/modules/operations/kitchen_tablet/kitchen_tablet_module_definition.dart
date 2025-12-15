import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// @deprecated Kitchen tablet is now part of the POS module (ModuleId.pos).
/// This file is kept for backward compatibility but should not be used.
/// Use ModuleId.pos for all POS-related functionality including kitchen display.
@Deprecated('Use ModuleId.pos instead - kitchen tablet is part of POS module')
ModuleDefinition get kitchenTabletModuleDefinition => const ModuleDefinition(
      id: ModuleId.pos,  // Kitchen display is part of POS
      category: ModuleCategory.operations,
      name: 'POS / Caisse',
      description: 'Point de vente complet avec interface staff, affichage cuisine, gestion des commandes et paiements.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [ModuleId.ordering],
    );

// Kitchen display functionality is now internal to the POS module.
// All routes, widgets, screens, and providers are controlled by ModuleId.pos.
