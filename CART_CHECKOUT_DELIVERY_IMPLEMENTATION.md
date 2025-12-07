# Cart + Checkout + Delivery System - Implementation Guide

## Vue d'ensemble

Cette implémentation fournit un système complet de panier, checkout et livraison intégré dans l'architecture White-Label existante.

## Architecture

### Structure des fichiers

```
lib/
├── white_label/
│   └── modules/
│       ├── payment/
│       │   └── payments_core/
│       │       ├── payment_service.dart       # Service de panier et checkout
│       │       ├── payment_service_provider.dart  # Providers Riverpod
│       │       ├── order_model.dart          # Modèle de commande
│       │       ├── payments_module_config.dart
│       │       ├── payments_module_definition.dart
│       │       └── payments_core.dart        # Export file
│       └── core/
│           └── delivery/
│               ├── delivery_runtime_service.dart  # Services de livraison
│               ├── delivery_runtime_provider.dart # Providers Riverpod
│               ├── delivery_area.dart
│               ├── delivery_settings.dart
│               ├── delivery_module_config.dart
│               ├── delivery_module_definition.dart
│               └── delivery.dart             # Export file
└── builder/
    └── runtime/
        └── modules/
            ├── payment_module_client_widget.dart  # Widget de checkout
            └── payment_module_wrapper.dart        # Wrapper Riverpod
```

## Composants principaux

### 1. CartService (`payment_service.dart`)

Service de gestion du panier avec persistance locale.

**Fonctionnalités :**
- `add()` - Ajoute un produit au panier
- `remove()` - Supprime un produit
- `updateQty()` - Met à jour la quantité
- `clear()` - Vide le panier
- `subtotal` - Calcule le sous-total
- `createOrder()` - Crée une commande dans Firestore

**Persistance :**
- Utilise SharedPreferences pour sauvegarder le panier
- Chargement automatique au démarrage via `loadFromPreferences()`

**État du checkout :**
- `CheckoutState` stocke les informations de livraison/retrait
- `updateCheckoutState()` met à jour l'état

### 2. DeliveryRuntimeService (`delivery_runtime_service.dart`)

Service de gestion des livraisons avec calcul de frais et créneaux.

**Fonctionnalités :**
- `calculateDeliveryFee()` - Calcule les frais de livraison
- `validateAddress()` - Valide une adresse de livraison
- `listTimeSlots()` - Liste les créneaux disponibles
- `getActiveZones()` - Retourne les zones actives

**Calcul des frais :**
- Basé sur les zones de livraison (`DeliveryArea`)
- Support de la livraison gratuite (seuil configurable)
- Extraction automatique du code postal

### 3. PaymentModuleClientWidget

Widget de checkout complet avec :
- Affichage des articles du panier
- Résumé des prix (sous-total, frais de livraison, total)
- Section livraison (si module activé)
- Section click & collect (si module activé)
- Validation de formulaire
- Bouton de paiement

### 4. Riverpod Providers

**CartService :**
```dart
final cartServiceProvider = Provider<CartService>((ref) { ... });
final cartItemCountProvider = Provider<int>((ref) { ... });
final cartSubtotalProvider = Provider<double>((ref) { ... });
final isCartEmptyProvider = Provider<bool>((ref) { ... });
```

**Delivery :**
```dart
final deliverySettingsProvider = FutureProvider<DeliverySettings>((ref) { ... });
final deliveryRuntimeServiceProvider = Provider<DeliveryRuntimeService?>((ref) { ... });
final deliveryTimeslotsProvider = Provider<List<String>>((ref) { ... });
final activeDeliveryZonesProvider = Provider<List<DeliveryZone>>((ref) { ... });
```

## Utilisation

### 1. Ajouter un produit au panier

```dart
class MyProductWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartService = ref.read(cartServiceProvider);
    
    return ElevatedButton(
      onPressed: () {
        cartService.add(
          'product-id',
          'Pizza Margherita',
          9.99,
          1, // quantité
          imageUrl: 'https://...',
        );
      },
      child: Text('Ajouter au panier'),
    );
  }
}
```

### 2. Afficher le nombre d'articles

```dart
class CartBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(cartItemCountProvider);
    
    return Badge(
      label: Text('$itemCount'),
      child: Icon(Icons.shopping_cart),
    );
  }
}
```

### 3. Afficher le widget de checkout

Le widget de checkout est automatiquement enregistré dans le système de modules.

**Dans Builder B3 :**
Ajoutez un bloc "system" avec `moduleType: "payment_module"`

**En code direct :**
```dart
Consumer(
  builder: (context, ref, child) {
    return PaymentModuleWrapper();
  },
)
```

### 4. Créer une commande

```dart
final cartService = ref.read(cartServiceProvider);
final restaurantId = ref.read(currentRestaurantProvider).id;

try {
  final orderId = await cartService.createOrder(restaurantId);
  // Navigation vers la confirmation
  context.go('/order-confirmation/$orderId');
} catch (e) {
  // Gestion d'erreur
}
```

## Configuration

### Paramètres de livraison

Les paramètres de livraison sont définis dans `DeliverySettings` :

```dart
DeliverySettings(
  minimumOrderAmount: 15.0,      // Montant minimum
  deliveryFee: 2.50,             // Frais de base
  freeDeliveryThreshold: 30.0,   // Livraison gratuite à partir de
  radiusKm: 5.0,                 // Rayon de livraison
  estimatedDeliveryMinutes: 30,  // Temps estimé
  areas: [                       // Zones de livraison
    DeliveryArea(
      id: 'zone-1',
      name: 'Centre-ville',
      postalCodes: ['75001', '75002'],
      deliveryFee: 2.00,
      minimumOrderAmount: 10.0,
    ),
  ],
)
```

### Activation des modules

Le système vérifie automatiquement l'activation des modules via `ModuleRuntimeAdapter` :

```dart
final deliveryEnabled = ModuleRuntimeAdapter.isModuleActiveById(
  plan,
  ModuleId.delivery,
);

final clickCollectEnabled = ModuleRuntimeAdapter.isModuleActiveById(
  plan,
  ModuleId.clickAndCollect,
);
```

## Modèle de données

### CartItem

```dart
class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  int quantity;
  final String? imageUrl;
  final String? customDescription;
  final bool isMenu;
}
```

### OrderModel

```dart
class OrderModel {
  final String id;
  final List<CartItem> items;
  final String? deliveryAddress;
  final String? deliverySlot;
  final String? deliveryZoneId;
  final String? clickCollectSlot;
  final bool isDelivery;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final DateTime createdAt;
  final String status;
  final String? userId;
}
```

## Firestore

### Structure des commandes

```
/restaurants/{restaurantId}/orders/{orderId}
  - id: string
  - items: array
    - id: string
    - productId: string
    - productName: string
    - price: number
    - quantity: number
    - imageUrl: string (optional)
  - deliveryAddress: string (optional)
  - deliverySlot: string (optional)
  - clickCollectSlot: string (optional)
  - isDelivery: boolean
  - subtotal: number
  - deliveryFee: number
  - total: number
  - createdAt: timestamp
  - status: string ('pending', 'confirmed', 'preparing', 'ready', 'delivering', 'completed')
  - userId: string (optional)
```

## Prochaines étapes

### TODO: Chargement Firestore des paramètres de livraison

Actuellement, `deliverySettingsProvider` retourne des paramètres par défaut. Pour charger depuis Firestore :

```dart
final deliverySettingsProvider = FutureProvider<DeliverySettings>((ref) async {
  final restaurantConfig = ref.watch(currentRestaurantProvider);
  
  final doc = await FirebaseFirestore.instance
      .collection('restaurants')
      .doc(restaurantConfig.id)
      .collection('settings')
      .doc('delivery')
      .get();
      
  if (doc.exists) {
    return DeliverySettings.fromJson(doc.data()!);
  }
  
  return DeliverySettings.defaults();
});
```

### TODO: Navigation vers confirmation de commande

Dans `payment_module_wrapper.dart`, implémenter la navigation complète :

```dart
onPaymentSuccess: () async {
  final restaurantId = ref.read(currentRestaurantProvider).id;
  final userId = ref.read(currentUserProvider)?.uid;
  
  try {
    final orderId = await cartService.createOrder(restaurantId, userId: userId);
    
    if (context.mounted) {
      context.go('/order-confirmation/$orderId');
    }
  } catch (e) {
    // Gestion d'erreur
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}
```

## Conformité architecturale

✅ **Tout le code vit dans le système de modules White-Label**
- `/lib/white_label/modules/payment/`
- `/lib/white_label/modules/core/delivery/`

✅ **Aucune modification du Builder B3**
- Système de blocs intact
- SystemBlock non modifié
- ModuleRuntimeRegistry utilisé correctement

✅ **Intégration Riverpod appropriée**
- Providers séparés et spécialisés
- Gestion d'état reactive
- Async/await géré correctement

✅ **Enregistrement des modules**
- `registerWhiteLabelModules()` dans `builder_block_runtime_registry.dart`
- Support admin/client séparé

✅ **Contraintes de layout respectées**
- Utilisation de `WLModuleWrapper`
- Pas de conflits avec le builder grid

## Support

Pour toute question ou problème, référez-vous à :
- `/lib/white_label/modules/payment/payments_core/` - Code du panier
- `/lib/white_label/modules/core/delivery/` - Code de livraison
- `/lib/builder/runtime/modules/payment_module_*` - Widgets UI
- `WHITE_LABEL_ARCHITECTURE_CORRECT.md` - Documentation WL
