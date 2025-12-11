# GUIDE D'INTÉGRATION DES MODULES

Ce guide explique comment intégrer les modules finalisés dans l'application.

---

## 📦 1. CLICK & COLLECT - SÉLECTEUR DE POINTS

### Intégration dans le Checkout

**Fichier**: `lib/src/screens/checkout/checkout_screen.dart`

```dart
import '../../../white_label/widgets/runtime/point_selector_screen.dart';
import '../../../white_label/core/module_id.dart';

// Dans _CheckoutScreenState, ajouter :
PickupPoint? _selectedPickupPoint;

// Dans le build, ajouter un bouton conditionnel :
final plan = ref.watch(restaurantPlanProvider);
if (plan?.hasModule(ModuleId.clickAndCollect) == true) {
  Card(
    child: ListTile(
      leading: const Icon(Icons.location_on),
      title: const Text('Point de retrait'),
      subtitle: _selectedPickupPoint != null
          ? Text(_selectedPickupPoint!.name)
          : const Text('Sélectionner un point'),
      trailing: const Icon(Icons.chevron_right),
      onTap: _selectPickupPoint,
    ),
  ),
}

// Ajouter la méthode :
Future<void> _selectPickupPoint() async {
  final point = await Navigator.push<PickupPoint>(
    context,
    MaterialPageRoute(
      builder: (context) => const PointSelectorScreen(),
    ),
  );
  
  if (point != null) {
    setState(() {
      _selectedPickupPoint = point;
    });
    
    // Optionnel : Sauvegarder dans le panier
    ref.read(cartProvider.notifier).setPickupPoint(point);
  }
}

// Dans _confirmOrder(), valider le point sélectionné :
if (plan?.hasModule(ModuleId.clickAndCollect) == true && 
    _selectedPickupPoint == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Veuillez sélectionner un point de retrait'),
      backgroundColor: Colors.red,
    ),
  );
  return;
}
```

### Configuration des Points de Retrait

**À créer**: `lib/white_label/widgets/admin/pickup_points_admin_screen.dart`

```dart
// Écran admin pour gérer les points de retrait
class PickupPointsAdminScreen extends ConsumerWidget {
  const PickupPointsAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implémenter CRUD des points de retrait
    // - Liste des points
    // - Ajouter/modifier/supprimer
    // - Activer/désactiver temporairement
    // - Configuration horaires
  }
}
```

### Stockage Firestore

**Collection**: `restaurants/{restaurantId}/pickupPoints`

```javascript
{
  "id": "point_1",
  "name": "Restaurant Principal",
  "address": "123 Rue de la Pizza",
  "city": "Paris",
  "postalCode": "75001",
  "phone": "+33123456789",
  "hours": "Lun-Dim: 11h-22h",
  "latitude": 48.8566,
  "longitude": 2.3522,
  "isAvailable": true,
  "createdAt": "2025-12-09T10:00:00Z",
  "updatedAt": "2025-12-09T10:00:00Z"
}
```

---

## 💳 2. PAIEMENTS - CONFIGURATION ADMIN

### Intégration dans le Routing Admin

**Fichier**: `lib/main.dart` ou routing file

```dart
import 'package:go_router/go_router.dart';
import 'white_label/widgets/admin/payment_admin_settings_screen.dart';

// Dans la configuration des routes :
GoRoute(
  path: '/admin/payments',
  name: 'adminPayments',
  builder: (context, state) => const PaymentAdminSettingsScreen(),
),
```

### Ajout dans le Menu Admin

**Fichier**: Admin navigation/menu

```dart
// Ajouter dans le menu latéral ou navigation principale
final plan = ref.watch(restaurantPlanProvider);

if (plan?.hasModule(ModuleId.payments) == true) {
  ListTile(
    leading: const Icon(Icons.payment),
    title: const Text('Configuration Paiements'),
    onTap: () => context.push('/admin/payments'),
  ),
}
```

### Sauvegarde Configuration Firestore

**À implémenter dans PaymentAdminSettingsScreen**:

```dart
Future<void> _saveSettings() async {
  final restaurantId = ref.read(currentRestaurantProvider)?.id;
  if (restaurantId == null) return;

  final config = PaymentsModuleConfig(
    enabled: _stripeEnabled || _offlineEnabled || _terminalEnabled,
    settings: {
      'stripe': {
        'enabled': _stripeEnabled,
        'testMode': _stripeTestMode,
        'publicKey': _stripePublicKeyController.text,
        'secretKey': _stripeSecretKeyController.text, // À chiffrer !
        'acceptedMethods': {
          'card': _acceptCard,
          'applePay': _acceptApplePay,
          'googlePay': _acceptGooglePay,
        },
      },
      'offline': {
        'enabled': _offlineEnabled,
      },
      'terminal': {
        'enabled': _terminalEnabled,
        'provider': _terminalProviderController.text,
      },
      'currency': _currency,
    },
  );

  await FirebaseFirestore.instance
      .collection('restaurants')
      .doc(restaurantId)
      .update({
    'plan.payments': config.toJson(),
  });
}
```

### Intégration dans le Checkout

**Fichier**: `lib/src/screens/checkout/checkout_screen.dart`

```dart
// Afficher les options de paiement basées sur la config
final paymentsConfig = plan?.payments;

if (paymentsConfig?.enabled == true) {
  // Afficher sélecteur de mode de paiement
  final settings = paymentsConfig!.settings;
  
  if (settings['stripe']?['enabled'] == true) {
    // Option paiement CB en ligne
  }
  
  if (settings['offline']?['enabled'] == true) {
    // Option paiement à la livraison
  }
  
  if (settings['terminal']?['enabled'] == true) {
    // Option paiement sur place (TPE)
  }
}
```

---

## 📧 3. NEWSLETTER - INSCRIPTION CLIENT

### Intégration dans le Routing Client

**Fichier**: `lib/main.dart` ou routing file

```dart
import 'white_label/widgets/runtime/subscribe_newsletter_screen.dart';

GoRoute(
  path: '/newsletter',
  name: 'newsletter',
  builder: (context, state) => const SubscribeNewsletterScreen(),
),
```

### Ajout dans le Profil Utilisateur

**Fichier**: Profile screen ou settings

```dart
final plan = ref.watch(restaurantPlanProvider);

if (plan?.hasModule(ModuleId.newsletter) == true) {
  ListTile(
    leading: const Icon(Icons.email),
    title: const Text('Newsletter'),
    subtitle: const Text('Restez informé de nos actualités'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.push('/newsletter'),
  ),
}
```

### Bouton Flottant sur la Home

```dart
// Option : Ajouter un CTA newsletter sur la page d'accueil
if (plan?.hasModule(ModuleId.newsletter) == true) {
  final isSubscribed = ref.watch(newsletterSubscriptionProvider);
  
  if (!isSubscribed) {
    // Afficher bannière ou bouton d'incitation
    Card(
      color: Colors.blue.shade50,
      child: InkWell(
        onTap: () => context.push('/newsletter'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.email, color: Colors.blue),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Inscrivez-vous à notre newsletter !'),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Sauvegarde Firestore

**Collection**: `restaurants/{restaurantId}/newsletter_subscribers`

```dart
Future<void> _subscribe() async {
  final restaurantId = ref.read(currentRestaurantProvider)?.id;
  final userId = ref.read(authProvider).userId;
  
  if (restaurantId == null) return;

  final subscriberData = {
    'email': _emailController.text,
    'name': _nameController.text,
    'userId': userId,
    'acceptPromotions': _acceptPromotions,
    'subscribedAt': FieldValue.serverTimestamp(),
    'source': 'app',
    'isActive': true,
  };

  await FirebaseFirestore.instance
      .collection('restaurants')
      .doc(restaurantId)
      .collection('newsletter_subscribers')
      .doc(_emailController.text)
      .set(subscriberData);

  // Optionnel : Mettre à jour le profil utilisateur
  if (userId != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'newsletterSubscribed': true,
      'newsletterRestaurants': FieldValue.arrayUnion([restaurantId]),
    });
  }

  ref.read(newsletterSubscriptionProvider.notifier).state = true;
}
```

---

## 🍳 4. KITCHEN TABLET - WEBSOCKET TEMPS RÉEL

### Installation Package

**Fichier**: `pubspec.yaml`

```yaml
dependencies:
  web_socket_channel: ^2.4.0
```

### Implémentation Production WebSocket

**Fichier**: `lib/white_label/widgets/runtime/kitchen_websocket_service.dart`

Remplacer le placeholder par:

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

class KitchenWebSocketService {
  WebSocketChannel? _channel;
  
  Future<void> connect(String url, String restaurantId) async {
    try {
      _restaurantId = restaurantId;
      
      // Créer connexion WebSocket
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // Écouter les messages
      _channel!.stream.listen(
        (message) => _handleMessage(message),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnect(),
      );
      
      // Envoyer authentification
      _channel!.sink.add(jsonEncode({
        'type': 'authenticate',
        'restaurantId': restaurantId,
        'timestamp': DateTime.now().toIso8601String(),
      }));
      
      _isConnected = true;
      _connectionController.add(true);
      _startHeartbeat();
      
    } catch (e) {
      _handleError(e);
    }
  }
  
  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    if (_channel == null) return;
    
    _channel!.sink.add(jsonEncode({
      'type': 'order_status_update',
      'restaurantId': _restaurantId,
      'orderId': orderId,
      'status': status.name,
      'timestamp': DateTime.now().toIso8601String(),
    }));
  }
  
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: _heartbeatIntervalSeconds),
      (_) {
        if (_isConnected && _channel != null) {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        }
      },
    );
  }
  
  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
```

### Configuration Serveur WebSocket

**Fichier**: `lib/white_label/restaurant/restaurant_plan_unified.dart`

Ajouter dans `KitchenTabletModuleConfig`:

```dart
class KitchenTabletModuleConfig {
  final bool enabled;
  final Map<String, dynamic> settings;
  
  // Ajouter :
  String? get webSocketUrl => settings['webSocketUrl'] as String?;
  bool get useWebSocket => settings['useWebSocket'] as bool? ?? false;
  
  // ...
}
```

### Utilisation dans Kitchen Screen

**Fichier**: Kitchen tablet screen

```dart
class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> {
  late final KitchenWebSocketService _wsService;
  StreamSubscription<KitchenOrderEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  Future<void> _initializeWebSocket() async {
    final plan = ref.read(restaurantPlanProvider);
    final kitchenConfig = plan?.kitchenTablet;
    
    if (kitchenConfig?.useWebSocket == true) {
      _wsService = KitchenWebSocketService();
      
      final url = kitchenConfig!.webSocketUrl ?? 'ws://localhost:8080/kitchen';
      await _wsService.connect(url, plan!.restaurantId);
      
      // Écouter les événements
      _eventSubscription = _wsService.orderEvents.listen((event) {
        switch (event.type) {
          case OrderEventType.newOrder:
            _handleNewOrder(event);
            break;
          case OrderEventType.statusUpdate:
            _handleStatusUpdate(event);
            break;
          case OrderEventType.orderCancelled:
            _handleOrderCancelled(event);
            break;
        }
      });
      
      // Écouter statut connexion
      _wsService.connectionStatus.listen((connected) {
        if (!connected) {
          // Afficher warning déconnexion
        }
      });
    }
  }

  void _handleNewOrder(KitchenOrderEvent event) {
    // Jouer son notification
    // Afficher snackbar
    // Rafraîchir liste commandes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nouvelle commande : ${event.orderId}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _handleStatusUpdate(KitchenOrderEvent event) {
    // Mettre à jour UI
    setState(() {
      // Update order status in local state if needed
    });
  }

  void _handleOrderCancelled(KitchenOrderEvent event) {
    // Retirer commande de l'affichage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Commande annulée : ${event.orderId}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, OrderStatus newStatus) async {
    // Mettre à jour via WebSocket
    await _wsService.updateOrderStatus(orderId, newStatus);
    
    // Mettre à jour Firestore (backup)
    await ref
        .read(kitchenOrdersRuntimeServiceProvider)
        .updateOrderStatus(orderId, KitchenStatusX.fromOrderStatus(newStatus.name)!);
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _wsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI kitchen avec boutons de changement statut
    // qui appellent _updateOrderStatus
  }
}
```

### Synchronisation Firestore ↔ WebSocket

**Pattern recommandé**: Dual write

```dart
// Quand la cuisine change un statut :
Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
  // 1. Envoyer via WebSocket (temps réel)
  await _wsService.updateOrderStatus(orderId, status);
  
  // 2. Sauvegarder dans Firestore (persistance)
  await FirebaseFirestore.instance
      .collection('orders')
      .doc(orderId)
      .update({
    'status': status.name,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

// Le client écoute Firestore pour la persistance
// et optionnellement WebSocket pour les updates temps réel
```

---

## 🔐 SÉCURITÉ

### Chiffrement des Clés API

```dart
// TODO: Utiliser flutter_secure_storage pour les clés sensibles
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

// Sauvegarder
await storage.write(
  key: 'stripe_secret_key_$restaurantId',
  value: secretKey,
);

// Lire
final secretKey = await storage.read(
  key: 'stripe_secret_key_$restaurantId',
);
```

### Validation Côté Serveur

**Important**: Toujours valider les paiements côté serveur (Cloud Functions).

```javascript
// Cloud Function pour Stripe
exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  // Vérifier authentification
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { amount, restaurantId } = data;
  
  // Récupérer config restaurant
  const restaurant = await admin.firestore()
    .collection('restaurants')
    .doc(restaurantId)
    .get();
  
  const stripeKey = restaurant.data()?.plan?.payments?.settings?.stripe?.secretKey;
  
  // Créer payment intent avec Stripe
  const stripe = require('stripe')(stripeKey);
  const paymentIntent = await stripe.paymentIntents.create({
    amount: amount,
    currency: 'eur',
  });
  
  return { clientSecret: paymentIntent.client_secret };
});
```

---

## 📊 TESTS

### Test Click & Collect

```dart
// test/widgets/point_selector_test.dart
void main() {
  testWidgets('Can select pickup point', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: PointSelectorScreen(),
        ),
      ),
    );
    
    // Vérifier affichage points
    expect(find.text('Restaurant Principal'), findsOneWidget);
    
    // Sélectionner un point
    await tester.tap(find.text('Restaurant Principal'));
    await tester.pump();
    
    // Vérifier sélection
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    
    // Confirmer
    await tester.tap(find.text('Confirmer le point de retrait'));
    await tester.pumpAndSettle();
    
    // Vérifier provider mis à jour
    // ...
  });
}
```

### Test Newsletter

```dart
// test/widgets/newsletter_test.dart
void main() {
  testWidgets('Can subscribe to newsletter', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SubscribeNewsletterScreen(),
        ),
      ),
    );
    
    // Remplir formulaire
    await tester.enterText(
      find.byType(TextFormField).first,
      'Jean Dupont',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'jean@example.com',
    );
    
    // Accepter conditions
    await tester.tap(find.byType(Checkbox).last);
    await tester.pump();
    
    // Soumettre
    await tester.tap(find.text('S\'inscrire à la newsletter'));
    await tester.pumpAndSettle();
    
    // Vérifier succès
    expect(find.text('Inscription réussie'), findsOneWidget);
  });
}
```

---

## 🚀 DÉPLOIEMENT

### Checklist Avant Production

- [ ] Tester chaque module avec module ON
- [ ] Tester chaque module avec module OFF
- [ ] Vérifier compatibilité existants restaurants
- [ ] Configurer WebSocket server URL
- [ ] Activer chiffrement clés Stripe
- [ ] Tester intégration checkout complète
- [ ] Valider formulaires et validations
- [ ] Tester reconnexion WebSocket
- [ ] Vérifier performances avec vrais données
- [ ] Documentation utilisateur créée

### Activation Progressive

1. **Phase 1**: Activer newsletter (moins critique)
2. **Phase 2**: Activer Click & Collect (si points configurés)
3. **Phase 3**: Activer admin paiements (test mode d'abord)
4. **Phase 4**: Activer WebSocket kitchen (monitoring actif)

---

**Dernière mise à jour**: 2025-12-09
**Version**: 1.0.0
