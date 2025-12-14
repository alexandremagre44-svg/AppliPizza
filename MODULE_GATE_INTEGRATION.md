# Module Gate - Guide d'intégration

Ce document explique comment intégrer ModuleGate dans les services et l'UI existants.

## Architecture

```
RestaurantPlanUnified (Firestore)
         ↓
   ModuleGate (Service central)
         ↓
   ┌─────────────┬────────────────┬───────────────┐
   ↓             ↓                ↓               ↓
Services       UI Widgets      Validators    Route Guards
```

## 1. Intégration dans les Services

### Option A: Injection via le constructeur

```dart
class MyOrderService {
  final OrderTypeValidator validator;
  
  MyOrderService({required this.validator});
  
  Future<String> createOrder({
    required List<CartItem> items,
    required String orderType,
    // ...
  }) async {
    // Valider le type de commande
    validator.validateOrderType(orderType);
    
    // Créer la commande
    final order = Order.fromCart(items, total, ...);
    
    // Valider la commande complète
    validator.validateOrder(order, orderType);
    
    // Procéder à la création
    // ...
  }
}
```

### Option B: Provider Riverpod

```dart
// Dans le provider
final myOrderServiceProvider = Provider<MyOrderService>((ref) {
  final validator = ref.watch(orderTypeValidatorProvider);
  return MyOrderService(validator: validator);
});

// Dans le service
class MyOrderService with OrderTypeValidation {
  @override
  final OrderTypeValidator validator;
  
  MyOrderService({required this.validator});
  
  Future<String> createOrder(...) async {
    // Utiliser le mixin
    validateOrderBeforeCreation(order, orderType);
    // ...
  }
}
```

## 2. Intégration dans l'UI

### Filtrer les types de commande disponibles

```dart
class OrderTypeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenir les types autorisés depuis ModuleGate
    final allowedTypes = ref.watch(allowedOrderTypesProvider);
    
    return Column(
      children: [
        for (final type in allowedTypes)
          RadioListTile(
            title: Text(OrderType.getLabel(type)),
            value: type,
            groupValue: selectedType,
            onChanged: (value) => setState(() => selectedType = value),
          ),
      ],
    );
  }
}
```

### Affichage conditionnel basé sur un module

```dart
class DeliveryOptionsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Vérifier si le module delivery est activé
    final isDeliveryEnabled = ref.watch(
      moduleEnabledProvider(ModuleId.delivery)
    );
    
    if (!isDeliveryEnabled) {
      return const SizedBox.shrink(); // Masquer complètement
    }
    
    return Column(
      children: [
        // Formulaire d'adresse
        // ...
      ],
    );
  }
}
```

### Click & Collect conditionnel

```dart
class ClickAndCollectWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(
      moduleEnabledProvider(ModuleId.clickAndCollect)
    );
    
    if (!isEnabled) {
      return const SizedBox.shrink();
    }
    
    final config = ref.watch(clickAndCollectConfigUnifiedProvider);
    final settings = config?.settings;
    
    return Column(
      children: [
        // Sélection du point de retrait
        if (settings != null)
          PickupPointSelector(points: settings.activePickupPoints),
        
        // Sélection du créneau
        if (settings != null)
          TimeSlotSelector(slots: settings.timeSlots),
      ],
    );
  }
}
```

## 3. Validation côté Backend

### Dans POS Order Service

```dart
// lib/src/services/pos_order_service.dart

import 'order_type_validator.dart';

class PosOrderService {
  final OrderTypeValidator? validator; // Optionnel pour rétrocompatibilité
  
  Future<String> createDraftOrder({
    required String orderType,
    // ...
  }) async {
    // NOUVEAU: Valider le type si validateur disponible
    if (validator != null) {
      validator.validateOrderType(orderType);
    }
    
    // Logique existante...
  }
}
```

### Dans Customer Order Service

```dart
// lib/src/services/customer_order_service.dart

class CustomerOrderService {
  final OrderTypeValidator? validator;
  
  Future<CustomerOrderResult> createOrderWithPayment({
    required String orderType,
    // ...
  }) async {
    // NOUVEAU: Valider avant création
    if (validator != null) {
      final order = Order.fromCart(...);
      validator.validateOrder(order, orderType);
    }
    
    // Logique existante...
  }
}
```

## 4. Guards de Route

```dart
// Dans votre système de routing

class ModuleRouteGuard {
  final ModuleGate gate;
  
  bool canActivateDelivery() {
    return gate.isModuleEnabled(ModuleId.delivery);
  }
  
  bool canActivateClickAndCollect() {
    return gate.isModuleEnabled(ModuleId.clickAndCollect);
  }
}

// Utilisation avec GoRouter
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/delivery',
      builder: (context, state) => DeliveryPage(),
      redirect: (context, state) {
        final gate = ref.read(moduleGateProvider);
        if (!gate.isModuleEnabled(ModuleId.delivery)) {
          return '/'; // Rediriger si module désactivé
        }
        return null;
      },
    ),
  ],
);
```

## 5. Tests

### Test d'un Service avec Validation

```dart
test('createOrder rejects delivery when module disabled', () async {
  // Setup: Module delivery désactivé
  final plan = RestaurantPlanUnified(
    restaurantId: 'test',
    name: 'Test',
    slug: 'test',
    activeModules: [], // Pas de delivery
  );
  
  final gate = ModuleGate(plan: plan);
  final validator = OrderTypeValidator(gate);
  final service = MyOrderService(validator: validator);
  
  // Test: Tenter de créer une commande delivery
  expect(
    () => service.createOrder(orderType: 'delivery', ...),
    throwsA(isA<OrderTypeNotAllowedException>()),
  );
});
```

## 6. Migration Progressive

Pour intégrer ModuleGate sans casser le code existant:

1. **Phase 1**: Ajouter `OrderTypeValidator?` optionnel aux services
2. **Phase 2**: Injecter le validateur via les providers
3. **Phase 3**: Rendre le validateur obligatoire
4. **Phase 4**: Supprimer l'ancien code de vérification

```dart
// Phase 1 - Rétrocompatible
class MyService {
  final OrderTypeValidator? validator;
  
  Future<void> createOrder(String type) async {
    if (validator != null) {
      validator.validateOrderType(type); // Nouvelle logique
    }
    // Ancienne logique continue de fonctionner
  }
}

// Phase 3 - Obligatoire
class MyService {
  final OrderTypeValidator validator; // Plus optionnel
  
  Future<void> createOrder(String type) async {
    validator.validateOrderType(type); // Toujours exécuté
  }
}
```

## Exemples Complets

### Service POS avec Validation

```dart
final posOrderServiceProvider = Provider<PosOrderService>((ref) {
  final appId = ref.watch(currentRestaurantProvider).id;
  final validator = ref.watch(orderTypeValidatorProvider);
  
  return PosOrderService(
    appId: appId,
    validator: validator,
  );
});
```

### Page de Commande Client

```dart
class OrderPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowedTypes = ref.watch(allowedOrderTypesProvider);
    final selectedType = ref.watch(selectedOrderTypeProvider);
    
    return Column(
      children: [
        // Sélection du type (filtré par ModuleGate)
        OrderTypeSelector(allowedTypes: allowedTypes),
        
        // Formulaire conditionnel pour Delivery
        if (selectedType == 'delivery')
          DeliveryForm(),
        
        // Formulaire conditionnel pour Click & Collect
        if (selectedType == 'click_collect')
          ClickAndCollectForm(),
        
        // Bouton de validation
        ElevatedButton(
          onPressed: () => _submitOrder(ref),
          child: Text('Commander'),
        ),
      ],
    );
  }
  
  Future<void> _submitOrder(WidgetRef ref) async {
    final service = ref.read(customerOrderServiceProvider);
    final validator = ref.read(orderTypeValidatorProvider);
    
    // Validation côté client
    final order = _buildOrder();
    final result = validator.validateOrderSafe(order, selectedType);
    
    if (!result.isValid) {
      _showError(result.errorMessage);
      return;
    }
    
    // Création de la commande (validée aussi côté service)
    await service.createOrderWithPayment(...);
  }
}
```

## Points Clés

1. **UN SEUL POINT DE VÉRITÉ**: ModuleGate lit RestaurantPlanUnified
2. **VALIDATION À DEUX NIVEAUX**:
   - UI: Pour l'UX (masquer/afficher)
   - Service: Pour la sécurité (rejeter si module OFF)
3. **RÉTROCOMPATIBILITÉ**: Injection optionnelle puis obligatoire
4. **TESTABILITÉ**: ModuleGate.permissive() pour les tests

## Résultat Final

Quand un module est OFF:
- ✅ Type de commande INVISIBLE dans l'UI
- ✅ Type de commande NON sélectionnable
- ✅ Création REFUSÉE par les services
- ✅ Routes BLOQUÉES par les guards
- ✅ Tests garantissent le comportement
