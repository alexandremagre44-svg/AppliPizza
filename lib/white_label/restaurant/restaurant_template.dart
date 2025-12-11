/// lib/white_label/restaurant/restaurant_template.dart
///
/// Système de templates métier pour définir le comportement des restaurants.
///
/// Les templates définissent la LOGIQUE MÉTIER (workflow, types de produits, etc.)
/// mais NE CONTRÔLENT PAS les modules business (qui sont activés par le SuperAdmin).
library;

import '../core/module_id.dart';

/// Type de service supporté par le restaurant.
enum ServiceType {
  /// Service à table uniquement
  tableService,
  
  /// Service au comptoir uniquement
  counterService,
  
  /// Livraison uniquement
  deliveryOnly,
  
  /// Mixte (table + comptoir + livraison)
  mixed,
}

/// État d'une commande dans le workflow cuisine.
class WorkflowState {
  /// Identifiant unique de l'état
  final String id;
  
  /// Libellé affiché
  final String label;
  
  /// Couleur associée (hex format)
  final String color;
  
  /// Ordre d'affichage
  final int order;
  
  const WorkflowState({
    required this.id,
    required this.label,
    required this.color,
    required this.order,
  });
}

/// Configuration de workflow pour un template.
class WorkflowConfig {
  /// États du workflow cuisine (si module kitchen activé)
  final List<WorkflowState>? kitchenStates;
  
  /// États du workflow POS/comptoir (si module POS activé)
  final List<WorkflowState>? posStates;
  
  /// États du workflow salle (si service à table)
  final List<WorkflowState>? tableServiceStates;
  
  const WorkflowConfig({
    this.kitchenStates,
    this.posStates,
    this.tableServiceStates,
  });
}

/// Configuration d'impression pour un template.
class PrintConfig {
  /// Ticket cuisine activé
  final bool kitchenTicket;
  
  /// Ticket comptoir activé
  final bool counterTicket;
  
  /// Ticket de livraison activé
  final bool deliveryTicket;
  
  const PrintConfig({
    this.kitchenTicket = false,
    this.counterTicket = false,
    this.deliveryTicket = false,
  });
}

/// Template métier définissant le comportement d'un restaurant.
///
/// Le template définit:
/// - Le workflow de commande (cuisine ou non)
/// - Les types de produits et catégories suggérées
/// - La structure des menus et personnalisations
/// - Le type de service (table, comptoir, livraison, mixte)
/// - Les états de commande par défaut
/// - Les types d'impressions (ticket cuisine, ticket comptoir)
/// - Le POS recommandé ou non
///
/// ⚠️ IMPORTANT: Le template NE contrôle PAS les modules business.
/// Les modules sont activés uniquement par le SuperAdmin.
class RestaurantTemplate {
  /// Identifiant unique du template
  final String id;
  
  /// Nom du template
  final String name;
  
  /// Description du template
  final String description;
  
  /// Icône du template
  final String iconName;
  
  /// Type de service supporté
  final ServiceType serviceType;
  
  /// Support de la personnalisation des produits (ex: pizza)
  final bool supportsCustomization;
  
  /// Support des menus composés
  final bool supportsMenus;
  
  /// Catégories de produits suggérées
  final List<String> suggestedCategories;
  
  /// Configuration du workflow
  final WorkflowConfig workflow;
  
  /// Configuration d'impression
  final PrintConfig printConfig;
  
  /// POS recommandé (mais pas obligatoire)
  final bool recommendsPOS;
  
  /// Kitchen recommandée (mais pas obligatoire)
  final bool recommendsKitchen;
  
  /// Modules recommandés (suggestions uniquement, pas d'activation automatique)
  final List<ModuleId> recommendedModules;
  
  const RestaurantTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.serviceType,
    required this.supportsCustomization,
    required this.supportsMenus,
    required this.suggestedCategories,
    required this.workflow,
    required this.printConfig,
    required this.recommendsPOS,
    required this.recommendsKitchen,
    required this.recommendedModules,
  });
  
  /// Sérialise le template en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'serviceType': serviceType.name,
      'supportsCustomization': supportsCustomization,
      'supportsMenus': supportsMenus,
      'suggestedCategories': suggestedCategories,
      'workflow': {
        'kitchenStates': workflow.kitchenStates?.map((s) => {
          'id': s.id,
          'label': s.label,
          'color': s.color,
          'order': s.order,
        }).toList(),
        'posStates': workflow.posStates?.map((s) => {
          'id': s.id,
          'label': s.label,
          'color': s.color,
          'order': s.order,
        }).toList(),
        'tableServiceStates': workflow.tableServiceStates?.map((s) => {
          'id': s.id,
          'label': s.label,
          'color': s.color,
          'order': s.order,
        }).toList(),
      },
      'printConfig': {
        'kitchenTicket': printConfig.kitchenTicket,
        'counterTicket': printConfig.counterTicket,
        'deliveryTicket': printConfig.deliveryTicket,
      },
      'recommendsPOS': recommendsPOS,
      'recommendsKitchen': recommendsKitchen,
      'recommendedModules': recommendedModules.map((m) => m.code).toList(),
    };
  }
  
  /// Désérialise un template depuis JSON
  factory RestaurantTemplate.fromJson(Map<String, dynamic> json) {
    return RestaurantTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == json['serviceType'],
        orElse: () => ServiceType.mixed,
      ),
      supportsCustomization: json['supportsCustomization'] as bool? ?? false,
      supportsMenus: json['supportsMenus'] as bool? ?? false,
      suggestedCategories: (json['suggestedCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      workflow: WorkflowConfig(
        kitchenStates: (json['workflow']?['kitchenStates'] as List<dynamic>?)
            ?.map((s) => WorkflowState(
              id: s['id'] as String,
              label: s['label'] as String,
              color: s['color'] as String,
              order: s['order'] as int,
            ))
            .toList(),
        posStates: (json['workflow']?['posStates'] as List<dynamic>?)
            ?.map((s) => WorkflowState(
              id: s['id'] as String,
              label: s['label'] as String,
              color: s['color'] as String,
              order: s['order'] as int,
            ))
            .toList(),
        tableServiceStates: (json['workflow']?['tableServiceStates'] as List<dynamic>?)
            ?.map((s) => WorkflowState(
              id: s['id'] as String,
              label: s['label'] as String,
              color: s['color'] as String,
              order: s['order'] as int,
            ))
            .toList(),
      ),
      printConfig: PrintConfig(
        kitchenTicket: json['printConfig']?['kitchenTicket'] as bool? ?? false,
        counterTicket: json['printConfig']?['counterTicket'] as bool? ?? false,
        deliveryTicket: json['printConfig']?['deliveryTicket'] as bool? ?? false,
      ),
      recommendsPOS: json['recommendsPOS'] as bool? ?? false,
      recommendsKitchen: json['recommendsKitchen'] as bool? ?? false,
      recommendedModules: (json['recommendedModules'] as List<dynamic>?)
          ?.map((code) => ModuleId.values.firstWhere(
            (m) => m.code == code,
            orElse: () => ModuleId.ordering,
          ))
          .toList() ?? [],
    );
  }
}

/// Templates disponibles dans l'application.
class RestaurantTemplates {
  /// Pizzeria Classic - Template complet pour pizzerias
  static const pizzeriaClassic = RestaurantTemplate(
    id: 'pizzeria-classic',
    name: 'Pizzeria Classic',
    description: 'Template complet pour pizzeria avec workflow cuisine et personnalisation avancée',
    iconName: 'local_pizza',
    serviceType: ServiceType.mixed,
    supportsCustomization: true,
    supportsMenus: true,
    suggestedCategories: ['Pizzas', 'Menus', 'Boissons', 'Desserts', 'Entrées'],
    workflow: WorkflowConfig(
      kitchenStates: [
        WorkflowState(id: 'received', label: 'Reçue', color: '#FFA726', order: 0),
        WorkflowState(id: 'preparing', label: 'En préparation', color: '#42A5F5', order: 1),
        WorkflowState(id: 'ready', label: 'Prête', color: '#66BB6A', order: 2),
        WorkflowState(id: 'delivered', label: 'Livrée', color: '#78909C', order: 3),
      ],
    ),
    printConfig: PrintConfig(
      kitchenTicket: true,
      counterTicket: true,
      deliveryTicket: true,
    ),
    recommendsPOS: true,
    recommendsKitchen: true,
    recommendedModules: [
      ModuleId.ordering,
      ModuleId.delivery,
      ModuleId.clickAndCollect,
      ModuleId.kitchen_tablet,
      ModuleId.pos,
      ModuleId.loyalty,
      ModuleId.roulette,
      ModuleId.promotions,
    ],
  );
  
  /// Fast Food Express - Template optimisé pour restauration rapide
  static const fastFoodExpress = RestaurantTemplate(
    id: 'fast-food-express',
    name: 'Fast Food Express',
    description: 'Template optimisé pour la restauration rapide avec service au comptoir',
    iconName: 'fastfood',
    serviceType: ServiceType.counterService,
    supportsCustomization: false,
    supportsMenus: true,
    suggestedCategories: ['Burgers', 'Menus', 'Boissons', 'Desserts', 'Accompagnements'],
    workflow: WorkflowConfig(
      posStates: [
        WorkflowState(id: 'paid', label: 'Payée', color: '#66BB6A', order: 0),
        WorkflowState(id: 'preparing', label: 'Préparation', color: '#42A5F5', order: 1),
        WorkflowState(id: 'ready', label: 'Prête comptoir', color: '#FFA726', order: 2),
      ],
    ),
    printConfig: PrintConfig(
      counterTicket: true,
    ),
    recommendsPOS: true,
    recommendsKitchen: false,
    recommendedModules: [
      ModuleId.ordering,
      ModuleId.clickAndCollect,
      ModuleId.pos,
      ModuleId.staff_tablet,
      ModuleId.promotions,
    ],
  );
  
  /// Restaurant Premium - Template haut de gamme avec service à table
  static const restaurantPremium = RestaurantTemplate(
    id: 'restaurant-premium',
    name: 'Restaurant Premium',
    description: 'Template haut de gamme avec service à table et toutes fonctionnalités',
    iconName: 'restaurant',
    serviceType: ServiceType.tableService,
    supportsCustomization: false,
    supportsMenus: true,
    suggestedCategories: ['Entrées', 'Plats', 'Desserts', 'Vins', 'Boissons'],
    workflow: WorkflowConfig(
      tableServiceStates: [
        WorkflowState(id: 'sent', label: 'Envoyée', color: '#42A5F5', order: 0),
        WorkflowState(id: 'preparing', label: 'En préparation', color: '#FFA726', order: 1),
        WorkflowState(id: 'served', label: 'Servie', color: '#66BB6A', order: 2),
      ],
      kitchenStates: [
        WorkflowState(id: 'received', label: 'Reçue', color: '#FFA726', order: 0),
        WorkflowState(id: 'preparing', label: 'En cours', color: '#42A5F5', order: 1),
        WorkflowState(id: 'ready', label: 'Prête', color: '#66BB6A', order: 2),
      ],
    ),
    printConfig: PrintConfig(
      kitchenTicket: true,
    ),
    recommendsPOS: false,
    recommendsKitchen: true,
    recommendedModules: [
      ModuleId.ordering,
      ModuleId.delivery,
      ModuleId.kitchen_tablet,
      ModuleId.loyalty,
      ModuleId.promotions,
      ModuleId.campaigns,
      ModuleId.timeRecorder,
      ModuleId.reporting,
      ModuleId.theme,
      ModuleId.pagesBuilder,
    ],
  );
  
  /// Sushi Bar - Template pour restaurants de sushi
  static const sushiBar = RestaurantTemplate(
    id: 'sushi-bar',
    name: 'Sushi Bar',
    description: 'Template spécialisé pour restaurant de sushi avec livraison',
    iconName: 'set_meal',
    serviceType: ServiceType.mixed,
    supportsCustomization: false,
    supportsMenus: true,
    suggestedCategories: ['Sushis', 'Makis', 'Menus', 'Boissons', 'Desserts'],
    workflow: WorkflowConfig(
      kitchenStates: [
        WorkflowState(id: 'received', label: 'Reçue', color: '#FFA726', order: 0),
        WorkflowState(id: 'preparing', label: 'En préparation', color: '#42A5F5', order: 1),
        WorkflowState(id: 'ready', label: 'Prête', color: '#66BB6A', order: 2),
        WorkflowState(id: 'delivered', label: 'Livrée', color: '#78909C', order: 3),
      ],
    ),
    printConfig: PrintConfig(
      kitchenTicket: true,
      deliveryTicket: true,
    ),
    recommendsPOS: true,
    recommendsKitchen: true,
    recommendedModules: [
      ModuleId.ordering,
      ModuleId.delivery,
      ModuleId.clickAndCollect,
      ModuleId.kitchen_tablet,
      ModuleId.pos,
      ModuleId.loyalty,
      ModuleId.promotions,
    ],
  );
  
  /// Blank Template - Template vide pour configuration manuelle
  static const blank = RestaurantTemplate(
    id: 'blank-template',
    name: 'Template Vide',
    description: 'Commencez de zéro et configurez manuellement tous les aspects',
    iconName: 'add_box',
    serviceType: ServiceType.mixed,
    supportsCustomization: false,
    supportsMenus: false,
    suggestedCategories: [],
    workflow: WorkflowConfig(),
    printConfig: PrintConfig(),
    recommendsPOS: false,
    recommendsKitchen: false,
    recommendedModules: [],
  );
  
  /// Liste de tous les templates disponibles
  static const List<RestaurantTemplate> all = [
    pizzeriaClassic,
    fastFoodExpress,
    restaurantPremium,
    sushiBar,
    blank,
  ];
  
  /// Récupère un template par son ID
  static RestaurantTemplate? getById(String? id) {
    if (id == null) return null;
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// Récupère le template par défaut (Pizzeria Classic)
  static RestaurantTemplate get defaultTemplate => pizzeriaClassic;
}
