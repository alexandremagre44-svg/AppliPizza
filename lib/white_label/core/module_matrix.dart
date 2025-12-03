// lib/white_label/core/module_matrix.dart
// Phase 4A: Module Matrix - Metadata and documentation layer
//
// This file provides an independent metadata layer on top of the existing
// module system. It does NOT replace ModuleDefinition or ModuleRegistry.
// 
// Purpose:
// - Document implementation status of all modules
// - Track which modules have pages, builder blocks, routes
// - Provide metadata for Phase 4B (runtime mapping + nav + builder integration)

/// Category for grouping modules by functional domain.
/// 
/// This is separate from the existing ModuleCategory in module_category.dart
/// and provides a higher-level categorization for documentation purposes.
enum ModuleCategory {
  /// Core functionality (ordering, delivery, etc.)
  core,
  
  /// Payment-related modules
  payment,
  
  /// Engagement features (loyalty, roulette, etc.)
  engagement,
  
  /// User experience modules (theme, pages builder, etc.)
  ux,
  
  /// Operations modules (kitchen tablet, staff, etc.)
  operations,
  
  /// White-label specific features
  whiteLabel,
  
  /// Other/uncategorized
  other,
}

/// Implementation status of a module.
enum ModuleStatus {
  /// Fully implemented with page, logic, and (optionally) builder block
  implemented,
  
  /// Partially implemented (some features missing or skeleton only)
  partial,
  
  /// Planned but not yet implemented
  planned,
}

/// Metadata definition for a module.
/// 
/// This is a documentation/metadata layer that complements the existing
/// ModuleDefinition in module_definition.dart. It tracks additional
/// information about implementation status, routing, and builder integration.
class ModuleDefinitionMeta {
  /// Module identifier (matches ModuleId.code)
  final String id;
  
  /// Human-readable label
  final String label;
  
  /// Functional category
  final ModuleCategory category;
  
  /// Current implementation status
  final ModuleStatus status;
  
  /// Whether this module has a dedicated screen/page
  final bool hasPage;
  
  /// Whether this module has a Builder B3 block
  final bool hasBuilderBlock;
  
  /// Whether this is a premium/paid module
  final bool premium;
  
  /// Default route for this module's main page (if any)
  final String? defaultRoute;
  
  /// Tags for filtering and categorization
  final List<String> tags;
  
  const ModuleDefinitionMeta({
    required this.id,
    required this.label,
    required this.category,
    required this.status,
    required this.hasPage,
    required this.hasBuilderBlock,
    required this.premium,
    required this.defaultRoute,
    this.tags = const [],
  });
  
  @override
  String toString() {
    return 'ModuleDefinitionMeta('
        'id: $id, '
        'status: $status, '
        'hasPage: $hasPage, '
        'hasBuilderBlock: $hasBuilderBlock, '
        'route: $defaultRoute'
        ')';
  }
}

/// Central registry of all module metadata.
/// 
/// This map documents the current state of all modules in the system,
/// including their implementation status, pages, routes, and builder blocks.
const Map<String, ModuleDefinitionMeta> moduleMatrix = {
  // ============================================================================
  // CORE MODULES
  // ============================================================================
  
  'ordering': ModuleDefinitionMeta(
    id: 'ordering',
    label: 'Commandes en ligne',
    category: ModuleCategory.core,
    status: ModuleStatus.implemented,
    hasPage: true,
    hasBuilderBlock: false,
    premium: false,
    defaultRoute: '/menu',
    tags: ['core', 'ordering', 'essential'],
  ),
  
  'delivery': ModuleDefinitionMeta(
    id: 'delivery',
    label: 'Livraison',
    category: ModuleCategory.core,
    status: ModuleStatus.implemented,
    hasPage: true,
    hasBuilderBlock: false,
    premium: false,
    defaultRoute: '/delivery',
    tags: ['core', 'delivery', 'logistics'],
  ),
  
  'click_and_collect': ModuleDefinitionMeta(
    id: 'click_and_collect',
    label: 'Click & Collect',
    category: ModuleCategory.core,
    status: ModuleStatus.implemented,
    hasPage: true,
    hasBuilderBlock: false,
    premium: false,
    defaultRoute: '/click-collect',
    tags: ['core', 'pickup', 'logistics'],
  ),
  
  // ============================================================================
  // PAYMENT MODULES
  // ============================================================================
  
  'payments': ModuleDefinitionMeta(
    id: 'payments',
    label: 'Paiements',
    category: ModuleCategory.payment,
    status: ModuleStatus.implemented,
    hasPage: true,
    hasBuilderBlock: false,
    premium: false,
    defaultRoute: '/checkout',
    tags: ['payment', 'core', 'essential'],
  ),
  
  'payment_terminal': ModuleDefinitionMeta(
    id: 'payment_terminal',
    label: 'Terminal de paiement',
    category: ModuleCategory.payment,
    status: ModuleStatus.partial,
    hasPage: false,
    hasBuilderBlock: false,
    premium: true,
    defaultRoute: null,
    tags: ['payment', 'hardware', 'premium'],
  ),
  
  'wallet': ModuleDefinitionMeta(
    id: 'wallet',
    label: 'Portefeuille',
    category: ModuleCategory.payment,
    status: ModuleStatus.planned,
    hasPage: false,
    hasBuilderBlock: false,
    premium: true,
    defaultRoute: '/wallet',
    tags: ['payment', 'premium', 'future'],
  ),
  
  // ============================================================================
  // ENGAGEMENT MODULES (Marketing/Loyalty)
  // ============================================================================
  
  'loyalty': ModuleDefinitionMeta(
    id: 'loyalty',
    label: 'Fidélité',
    category: ModuleCategory.engagement,
    status: ModuleStatus.implemented,
    hasPage: true,
    hasBuilderBlock: true,
    premium: false,
    defaultRoute: '/rewards',
    tags: ['engagement', 'loyalty', 'marketing'],
  ),
  
  'roulette': ModuleDefinitionMeta(
    id: 'roulette',
    label: 'Roulette',
    category: ModuleCategory.engagement,
    status: ModuleStatus.implemented,
    hasPage: true,
    hasBuilderBlock: true,
    premium: true,
    defaultRoute: '/roulette',
    tags: ['engagement', 'gamification', 'marketing', 'premium'],
  ),
  
  'promotions': ModuleDefinitionMeta(
    id: 'promotions',
    label: 'Promotions',
    category: ModuleCategory.engagement,
    status: ModuleStatus.implemented,
    hasPage: true,
    hasBuilderBlock: true,
    premium: false,
    defaultRoute: '/promotions',
    tags: ['engagement', 'marketing', 'promo'],
  ),
  
  'newsletter': ModuleDefinitionMeta(
    id: 'newsletter',
    label: 'Newsletter',
    category: ModuleCategory.engagement,
    status: ModuleStatus.partial,
    hasPage: false,
    hasBuilderBlock: false,
    premium: true,
    defaultRoute: null,
    tags: ['engagement', 'marketing', 'email', 'premium'],
  ),
  
  'campaigns': ModuleDefinitionMeta(
    id: 'campaigns',
    label: 'Campagnes',
    category: ModuleCategory.engagement,
    status: ModuleStatus.partial,
    hasPage: false,
    hasBuilderBlock: false,
    premium: true,
    defaultRoute: null,
    tags: ['engagement', 'marketing', 'premium'],
  ),
  
  // ============================================================================
  // UX MODULES (Appearance/Customization)
  // ============================================================================
  
  'theme': ModuleDefinitionMeta(
    id: 'theme',
    label: 'Thème',
    category: ModuleCategory.ux,
    status: ModuleStatus.implemented,
    hasPage: false,
    hasBuilderBlock: false,
    premium: false,
    defaultRoute: null,
    tags: ['ux', 'appearance', 'branding'],
  ),
  
  'pages_builder': ModuleDefinitionMeta(
    id: 'pages_builder',
    label: 'Constructeur de pages',
    category: ModuleCategory.ux,
    status: ModuleStatus.implemented,
    hasPage: true,
    hasBuilderBlock: false,
    premium: true,
    defaultRoute: null,
    tags: ['ux', 'builder', 'premium', 'b3'],
  ),
  
  // ============================================================================
  // OPERATIONS MODULES
  // ============================================================================
  
  'kitchen_tablet': ModuleDefinitionMeta(
    id: 'kitchen_tablet',
    label: 'Tablette cuisine',
    category: ModuleCategory.operations,
    status: ModuleStatus.implemented,
    hasPage: true,
    hasBuilderBlock: false,
    premium: true,
    defaultRoute: '/kitchen',
    tags: ['operations', 'kitchen', 'tablet', 'premium'],
  ),
  
  'staff_tablet': ModuleDefinitionMeta(
    id: 'staff_tablet',
    label: 'Caisse / Staff Tablet',
    category: ModuleCategory.operations,
    status: ModuleStatus.implemented,
    hasPage: true,
    hasBuilderBlock: false,
    premium: true,
    defaultRoute: '/pos',
    tags: ['operations', 'staff', 'tablet', 'pos', 'caisse', 'premium'],
  ),
  
  'time_recorder': ModuleDefinitionMeta(
    id: 'time_recorder',
    label: 'Pointeuse',
    category: ModuleCategory.operations,
    status: ModuleStatus.planned,
    hasPage: false,
    hasBuilderBlock: false,
    premium: true,
    defaultRoute: null,
    tags: ['operations', 'hr', 'premium', 'future'],
  ),

  'pos': ModuleDefinitionMeta(
    id: 'pos',
    label: 'POS',
    category: ModuleCategory.operations,
    status: ModuleStatus.implemented,
    hasPage: true,
    hasBuilderBlock: false,
    premium: false,
    defaultRoute: '/pos',
    tags: ['staff', 'operations'],
  ),

  'kitchen': ModuleDefinitionMeta(
    id: 'kitchen',
    label: 'Cuisine',
    category: ModuleCategory.operations,
    status: ModuleStatus.implemented,
    hasPage: true,
    hasBuilderBlock: false,
    premium: false,
    defaultRoute: '/kitchen',
    tags: ['staff', 'operations'],
  ),
  
  // ============================================================================
  // ANALYTICS MODULES
  // ============================================================================
  
  'reporting': ModuleDefinitionMeta(
    id: 'reporting',
    label: 'Reporting',
    category: ModuleCategory.other,
    status: ModuleStatus.partial,
    hasPage: true,
    hasBuilderBlock: false,
    premium: false,
    defaultRoute: '/admin/reports',
    tags: ['analytics', 'reporting', 'admin'],
  ),
  
  'exports': ModuleDefinitionMeta(
    id: 'exports',
    label: 'Exports',
    category: ModuleCategory.other,
    status: ModuleStatus.partial,
    hasPage: false,
    hasBuilderBlock: false,
    premium: true,
    defaultRoute: null,
    tags: ['analytics', 'export', 'data', 'premium'],
  ),
};

/// Helper class to query the module matrix.
class ModuleMatrixHelper {
  /// Get all modules with a specific status.
  static List<ModuleDefinitionMeta> byStatus(ModuleStatus status) {
    return moduleMatrix.values
        .where((module) => module.status == status)
        .toList();
  }
  
  /// Get all modules in a specific category.
  static List<ModuleDefinitionMeta> byCategory(ModuleCategory category) {
    return moduleMatrix.values
        .where((module) => module.category == category)
        .toList();
  }
  
  /// Get all modules that have pages.
  static List<ModuleDefinitionMeta> withPages() {
    return moduleMatrix.values
        .where((module) => module.hasPage)
        .toList();
  }
  
  /// Get all modules that have builder blocks.
  static List<ModuleDefinitionMeta> withBuilderBlocks() {
    return moduleMatrix.values
        .where((module) => module.hasBuilderBlock)
        .toList();
  }
  
  /// Get all premium modules.
  static List<ModuleDefinitionMeta> premiumModules() {
    return moduleMatrix.values
        .where((module) => module.premium)
        .toList();
  }
  
  /// Get all free modules.
  static List<ModuleDefinitionMeta> freeModules() {
    return moduleMatrix.values
        .where((module) => !module.premium)
        .toList();
  }
  
  /// Get module by ID.
  static ModuleDefinitionMeta? getModule(String id) {
    return moduleMatrix[id];
  }
  
  /// Get all module IDs with routes.
  static Map<String, String> getRoutesMap() {
    final Map<String, String> routes = {};
    for (final module in moduleMatrix.values) {
      if (module.defaultRoute != null) {
        routes[module.id] = module.defaultRoute!;
      }
    }
    return routes;
  }
  
  /// Generate a status summary.
  static Map<ModuleStatus, int> getStatusSummary() {
    final summary = <ModuleStatus, int>{
      ModuleStatus.implemented: 0,
      ModuleStatus.partial: 0,
      ModuleStatus.planned: 0,
    };
    
    for (final module in moduleMatrix.values) {
      summary[module.status] = (summary[module.status] ?? 0) + 1;
    }
    
    return summary;
  }
  
  /// Generate a category summary.
  static Map<ModuleCategory, int> getCategorySummary() {
    final summary = <ModuleCategory, int>{};
    
    for (final module in moduleMatrix.values) {
      summary[module.category] = (summary[module.category] ?? 0) + 1;
    }
    
    return summary;
  }
}
