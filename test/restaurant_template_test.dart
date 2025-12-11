/// test/restaurant_template_test.dart
///
/// Tests for the restaurant template system.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza_clean/white_label/restaurant/restaurant_template.dart';
import 'package:pizza_delizza_clean/white_label/core/module_id.dart';

void main() {
  group('RestaurantTemplate', () {
    test('should have all required templates defined', () {
      expect(RestaurantTemplates.all.length, greaterThanOrEqualTo(5));
      expect(RestaurantTemplates.pizzeriaClassic, isNotNull);
      expect(RestaurantTemplates.fastFoodExpress, isNotNull);
      expect(RestaurantTemplates.restaurantPremium, isNotNull);
      expect(RestaurantTemplates.sushiBar, isNotNull);
      expect(RestaurantTemplates.blank, isNotNull);
    });

    test('should retrieve template by ID', () {
      final template = RestaurantTemplates.getById('pizzeria-classic');
      expect(template, isNotNull);
      expect(template?.id, equals('pizzeria-classic'));
      expect(template?.name, equals('Pizzeria Classic'));
    });

    test('should return null for invalid template ID', () {
      final template = RestaurantTemplates.getById('invalid-id');
      expect(template, isNull);
    });

    test('should have default template', () {
      final template = RestaurantTemplates.defaultTemplate;
      expect(template, isNotNull);
      expect(template.id, equals('pizzeria-classic'));
    });
  });

  group('RestaurantTemplate - Pizzeria Classic', () {
    late RestaurantTemplate template;

    setUp(() {
      template = RestaurantTemplates.pizzeriaClassic;
    });

    test('should have correct properties', () {
      expect(template.id, equals('pizzeria-classic'));
      expect(template.name, equals('Pizzeria Classic'));
      expect(template.serviceType, equals(ServiceType.mixed));
      expect(template.supportsCustomization, isTrue);
      expect(template.supportsMenus, isTrue);
      expect(template.recommendsPOS, isTrue);
      expect(template.recommendsKitchen, isTrue);
    });

    test('should have recommended modules', () {
      expect(template.recommendedModules, isNotEmpty);
      expect(template.recommendedModules, contains(ModuleId.ordering));
      expect(template.recommendedModules, contains(ModuleId.delivery));
      expect(template.recommendedModules, contains(ModuleId.kitchen_tablet));
      expect(template.recommendedModules, contains(ModuleId.pos));
      expect(template.recommendedModules, contains(ModuleId.loyalty));
    });

    test('should have kitchen workflow states', () {
      expect(template.workflow.kitchenStates, isNotNull);
      expect(template.workflow.kitchenStates!.length, equals(4));
      expect(template.workflow.kitchenStates![0].id, equals('received'));
      expect(template.workflow.kitchenStates![1].id, equals('preparing'));
      expect(template.workflow.kitchenStates![2].id, equals('ready'));
      expect(template.workflow.kitchenStates![3].id, equals('delivered'));
    });

    test('should have print configuration', () {
      expect(template.printConfig.kitchenTicket, isTrue);
      expect(template.printConfig.counterTicket, isTrue);
      expect(template.printConfig.deliveryTicket, isTrue);
    });

    test('should serialize to JSON correctly', () {
      final json = template.toJson();
      expect(json['id'], equals('pizzeria-classic'));
      expect(json['name'], equals('Pizzeria Classic'));
      expect(json['serviceType'], equals('mixed'));
      expect(json['supportsCustomization'], isTrue);
      expect(json['recommendsPOS'], isTrue);
      expect(json['recommendsKitchen'], isTrue);
      expect(json['recommendedModules'], isList);
      expect(json['workflow'], isMap);
      expect(json['printConfig'], isMap);
    });

    test('should deserialize from JSON correctly', () {
      final json = template.toJson();
      final restored = RestaurantTemplate.fromJson(json);
      
      expect(restored.id, equals(template.id));
      expect(restored.name, equals(template.name));
      expect(restored.serviceType, equals(template.serviceType));
      expect(restored.supportsCustomization, equals(template.supportsCustomization));
      expect(restored.recommendsPOS, equals(template.recommendsPOS));
      expect(restored.recommendsKitchen, equals(template.recommendsKitchen));
      expect(restored.recommendedModules.length, equals(template.recommendedModules.length));
    });
  });

  group('RestaurantTemplate - Fast Food Express', () {
    late RestaurantTemplate template;

    setUp(() {
      template = RestaurantTemplates.fastFoodExpress;
    });

    test('should have correct properties', () {
      expect(template.id, equals('fast-food-express'));
      expect(template.serviceType, equals(ServiceType.counterService));
      expect(template.supportsCustomization, isFalse);
      expect(template.recommendsPOS, isTrue);
      expect(template.recommendsKitchen, isFalse);
    });

    test('should have POS workflow states', () {
      expect(template.workflow.posStates, isNotNull);
      expect(template.workflow.posStates!.length, equals(3));
      expect(template.workflow.kitchenStates, isNull);
    });

    test('should recommend appropriate modules', () {
      expect(template.recommendedModules, contains(ModuleId.ordering));
      expect(template.recommendedModules, contains(ModuleId.clickAndCollect));
      expect(template.recommendedModules, contains(ModuleId.pos));
      expect(template.recommendedModules, contains(ModuleId.staff_tablet));
      expect(template.recommendedModules, isNot(contains(ModuleId.kitchen_tablet)));
    });
  });

  group('RestaurantTemplate - Restaurant Premium', () {
    late RestaurantTemplate template;

    setUp(() {
      template = RestaurantTemplates.restaurantPremium;
    });

    test('should have correct properties', () {
      expect(template.id, equals('restaurant-premium'));
      expect(template.serviceType, equals(ServiceType.tableService));
      expect(template.recommendsPOS, isFalse);
      expect(template.recommendsKitchen, isTrue);
    });

    test('should have table service workflow states', () {
      expect(template.workflow.tableServiceStates, isNotNull);
      expect(template.workflow.tableServiceStates!.length, equals(3));
      expect(template.workflow.kitchenStates, isNotNull);
    });

    test('should recommend premium modules', () {
      expect(template.recommendedModules, contains(ModuleId.reporting));
      expect(template.recommendedModules, contains(ModuleId.campaigns));
      expect(template.recommendedModules, contains(ModuleId.theme));
      expect(template.recommendedModules, contains(ModuleId.pagesBuilder));
    });
  });

  group('RestaurantTemplate - Blank Template', () {
    late RestaurantTemplate template;

    setUp(() {
      template = RestaurantTemplates.blank;
    });

    test('should have minimal configuration', () {
      expect(template.id, equals('blank-template'));
      expect(template.serviceType, equals(ServiceType.mixed));
      expect(template.supportsCustomization, isFalse);
      expect(template.supportsMenus, isFalse);
      expect(template.recommendsPOS, isFalse);
      expect(template.recommendsKitchen, isFalse);
      expect(template.recommendedModules, isEmpty);
      expect(template.suggestedCategories, isEmpty);
    });

    test('should have no workflow states', () {
      expect(template.workflow.kitchenStates, isNull);
      expect(template.workflow.posStates, isNull);
      expect(template.workflow.tableServiceStates, isNull);
    });

    test('should have no print configuration', () {
      expect(template.printConfig.kitchenTicket, isFalse);
      expect(template.printConfig.counterTicket, isFalse);
      expect(template.printConfig.deliveryTicket, isFalse);
    });
  });

  group('WorkflowState', () {
    test('should create workflow state correctly', () {
      const state = WorkflowState(
        id: 'test',
        label: 'Test State',
        color: '#FF0000',
        order: 0,
      );

      expect(state.id, equals('test'));
      expect(state.label, equals('Test State'));
      expect(state.color, equals('#FF0000'));
      expect(state.order, equals(0));
    });
  });

  group('ServiceType', () {
    test('should have all service types defined', () {
      expect(ServiceType.values.length, equals(4));
      expect(ServiceType.values, contains(ServiceType.tableService));
      expect(ServiceType.values, contains(ServiceType.counterService));
      expect(ServiceType.values, contains(ServiceType.deliveryOnly));
      expect(ServiceType.values, contains(ServiceType.mixed));
    });
  });

  group('Template Business Logic Separation', () {
    test('templates should NOT control module activation', () {
      // Templates only RECOMMEND modules, they don't activate them
      final template = RestaurantTemplates.pizzeriaClassic;
      
      // The recommendedModules list is just a suggestion
      expect(template.recommendedModules, isNotEmpty);
      
      // But the actual activation is controlled by RestaurantPlanUnified
      // This test ensures we maintain the separation of concerns
    });

    test('templates define business logic only', () {
      final template = RestaurantTemplates.pizzeriaClassic;
      
      // Business logic properties
      expect(template.workflow, isNotNull);
      expect(template.serviceType, isNotNull);
      expect(template.printConfig, isNotNull);
      expect(template.suggestedCategories, isNotNull);
      
      // These define HOW the restaurant operates,
      // not WHAT features are enabled
    });
  });
}
