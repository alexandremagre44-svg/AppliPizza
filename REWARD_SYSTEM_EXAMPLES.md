# Reward System - Exemples d'utilisation

Ce document contient des exemples pratiques d'utilisation du système de récompenses.

## Exemple 1 : Créer un ticket de réduction (20%)

```dart
import 'package:pizza_delizza/src/services/reward_service.dart';
import 'package:pizza_delizza/src/models/reward_action.dart';

void createPercentageDiscountTicket() async {
  final rewardService = RewardService();
  
  // Créer l'action de récompense
  final action = RewardAction(
    type: RewardType.percentageDiscount,
    percentage: 20.0,
    source: 'loyalty',
    label: '-20%',
    description: 'Réduction de 20% sur toute la commande',
  );
  
  // Créer le ticket (valable 30 jours)
  final ticket = await rewardService.createTicket(
    userId: 'user_123',
    action: action,
    validity: const Duration(days: 30),
  );
  
  print('Ticket créé : ${ticket.id}');
  print('Expire le : ${ticket.expiresAt}');
}
```

## Exemple 2 : Créer un ticket de réduction fixe (5€)

```dart
void createFixedDiscountTicket() async {
  final rewardService = RewardService();
  
  final action = RewardAction(
    type: RewardType.fixedDiscount,
    amount: 5.0,
    source: 'promo',
    label: '-5€',
    description: 'Réduction de 5€ sur votre commande',
  );
  
  final ticket = await rewardService.createTicket(
    userId: 'user_123',
    action: action,
    validity: const Duration(days: 15),
  );
  
  print('Ticket de réduction fixe créé : ${ticket.id}');
}
```

## Exemple 3 : Créer un ticket pizza gratuite

```dart
void createFreePizzaTicket() async {
  final rewardService = RewardService();
  
  final action = RewardAction(
    type: RewardType.freeAnyPizza,
    categoryId: 'Pizza', // Catégorie des pizzas
    source: 'roulette',
    label: 'Pizza offerte',
    description: 'Choisissez une pizza gratuite',
  );
  
  final ticket = await rewardService.createTicket(
    userId: 'user_123',
    action: action,
    validity: const Duration(days: 30),
  );
  
  print('Ticket pizza gratuite créé : ${ticket.id}');
}
```

## Exemple 4 : Créer un ticket produit spécifique gratuit

```dart
void createFreeSpecificProductTicket() async {
  final rewardService = RewardService();
  
  final action = RewardAction(
    type: RewardType.freeProduct,
    productId: 'pizza_margherita_123', // ID du produit spécifique
    source: 'loyalty',
    label: 'Margherita offerte',
    description: 'Pizza Margherita gratuite',
  );
  
  final ticket = await rewardService.createTicket(
    userId: 'user_123',
    action: action,
    validity: const Duration(days: 30),
  );
  
  print('Ticket produit spécifique créé : ${ticket.id}');
}
```

## Exemple 5 : Créer un ticket boisson gratuite

```dart
void createFreeDrinkTicket() async {
  final rewardService = RewardService();
  
  final action = RewardAction(
    type: RewardType.freeDrink,
    categoryId: 'Boissons',
    source: 'roulette',
    label: 'Boisson offerte',
    description: 'Choisissez une boisson gratuite',
  );
  
  final ticket = await rewardService.createTicket(
    userId: 'user_123',
    action: action,
    validity: const Duration(days: 30),
  );
  
  print('Ticket boisson gratuite créé : ${ticket.id}');
}
```

## Exemple 6 : Récupérer tous les tickets d'un utilisateur

```dart
void getUserTickets() async {
  final rewardService = RewardService();
  
  final tickets = await rewardService.getUserTickets('user_123');
  
  print('Total tickets : ${tickets.length}');
  
  // Filtrer les tickets actifs
  final activeTickets = tickets.where((t) => t.isActive).toList();
  print('Tickets actifs : ${activeTickets.length}');
  
  // Filtrer les tickets expirés
  final expiredTickets = tickets.where((t) => t.isExpired).toList();
  print('Tickets expirés : ${expiredTickets.length}');
  
  // Filtrer les tickets utilisés
  final usedTickets = tickets.where((t) => t.isUsed).toList();
  print('Tickets utilisés : ${usedTickets.length}');
}
```

## Exemple 7 : Écouter les tickets en temps réel (Stream)

```dart
import 'package:flutter/material.dart';

class MyTicketsWidget extends StatelessWidget {
  final String userId;
  
  const MyTicketsWidget({required this.userId});
  
  @override
  Widget build(BuildContext context) {
    final rewardService = RewardService();
    
    return StreamBuilder<List<RewardTicket>>(
      stream: rewardService.watchUserTickets(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        
        if (snapshot.hasError) {
          return Text('Erreur : ${snapshot.error}');
        }
        
        final tickets = snapshot.data ?? [];
        final activeTickets = tickets.where((t) => t.isActive).toList();
        
        return ListView.builder(
          itemCount: activeTickets.length,
          itemBuilder: (context, index) {
            final ticket = activeTickets[index];
            return ListTile(
              title: Text(ticket.action.label ?? 'Récompense'),
              subtitle: Text('Expire le ${ticket.expiresAt}'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Utiliser le ticket
                },
                child: Text('Utiliser'),
              ),
            );
          },
        );
      },
    );
  }
}
```

## Exemple 8 : Utiliser un ticket dans le panier (Riverpod)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void applyTicketToCart(WidgetRef ref, RewardTicket ticket) async {
  final cartNotifier = ref.read(cartProvider.notifier);
  
  try {
    await cartNotifier.applyTicket(ticket);
    print('Ticket appliqué au panier avec succès !');
  } catch (e) {
    print('Erreur : $e');
  }
}
```

## Exemple 9 : Créer un ticket depuis un segment de roulette

```dart
import 'package:pizza_delizza/src/utils/roulette_reward_mapper.dart';
import 'package:pizza_delizza/src/models/roulette_config.dart';

void createTicketFromRoulette(RouletteSegment segment) async {
  // Le segment vient de la roulette après un spin
  final ticket = await createTicketFromRouletteSegment(
    userId: 'user_123',
    segment: segment,
    validity: const Duration(days: 30),
  );
  
  if (ticket != null) {
    print('Ticket créé depuis la roulette : ${ticket.id}');
    print('Type : ${ticket.action.type}');
    print('Label : ${ticket.action.label}');
  } else {
    print('Aucun ticket créé (segment "nothing")');
  }
}
```

## Exemple 10 : Marquer un ticket comme utilisé

```dart
void markTicketAsUsed(String userId, String ticketId) async {
  final rewardService = RewardService();
  
  try {
    await rewardService.markTicketUsed(userId, ticketId);
    print('Ticket marqué comme utilisé');
  } catch (e) {
    print('Erreur lors du marquage : $e');
  }
}
```

## Exemple 11 : Vérifier la validité d'un ticket

```dart
void checkTicketValidity(RewardTicket ticket) {
  if (ticket.isUsed) {
    print('❌ Ce ticket a déjà été utilisé le ${ticket.usedAt}');
    return;
  }
  
  if (ticket.isExpired) {
    print('❌ Ce ticket a expiré le ${ticket.expiresAt}');
    return;
  }
  
  if (ticket.isActive) {
    print('✅ Ce ticket est valide et peut être utilisé');
    print('Expire dans : ${ticket.expiresAt.difference(DateTime.now()).inDays} jours');
  }
}
```

## Exemple 12 : Nettoyer les tickets expirés d'un utilisateur

```dart
void cleanupExpiredTickets(String userId) async {
  final rewardService = RewardService();
  
  final deleted = await rewardService.deleteExpiredTickets(userId);
  print('$deleted tickets expirés supprimés');
}
```

## Exemple 13 : Widget personnalisé pour afficher un ticket

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RewardTicketCard extends StatelessWidget {
  final RewardTicket ticket;
  final VoidCallback onUse;
  
  const RewardTicketCard({
    required this.ticket,
    required this.onUse,
  });
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Text(
              ticket.action.label ?? 'Récompense',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            
            // Description
            if (ticket.action.description != null)
              Text(
                ticket.action.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            
            // Source
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Source : ${ticket.action.source ?? "Inconnu"}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            const SizedBox(height: 8),
            
            // Expiration
            Row(
              children: [
                Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Valable jusqu\'au ${dateFormat.format(ticket.expiresAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ticket.isActive ? onUse : null,
                child: Text(
                  ticket.isActive ? 'Utiliser' : 'Expiré',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Exemple 14 : Intégration avec le système de fidélité (TODO)

```dart
// TODO: À implémenter quand le système de fidélité sera prêt

void redeemLoyaltyPoints(String userId, int points) async {
  final rewardService = RewardService();
  
  // Exemple : 1000 points = 1 pizza gratuite
  if (points >= 1000) {
    final action = RewardAction(
      type: RewardType.freeAnyPizza,
      categoryId: 'Pizza',
      source: 'loyalty',
      label: 'Pizza offerte',
      description: 'Échangée contre 1000 points de fidélité',
    );
    
    final ticket = await rewardService.createTicketFromLoyalty(
      userId: userId,
      pointsCost: 1000,
      action: action,
      validity: const Duration(days: 30),
    );
    
    print('Ticket créé avec ${points} points : ${ticket.id}');
  }
}
```

## Exemple 15 : Intégration avec les campagnes promo (TODO)

```dart
// TODO: À implémenter quand le système de campagnes sera prêt

void createPromoTicket(String userId, String campaignId) async {
  final rewardService = RewardService();
  
  final action = RewardAction(
    type: RewardType.percentageDiscount,
    percentage: 15.0,
    source: 'promo',
    label: '-15%',
    description: 'Promotion spéciale',
  );
  
  final ticket = await rewardService.createTicketFromPromo(
    userId: userId,
    campaignId: campaignId,
    action: action,
    validity: const Duration(days: 7),
  );
  
  print('Ticket promo créé : ${ticket.id}');
}
```

## Notes importantes

1. **Validation** : Toujours vérifier `ticket.isActive` avant d'utiliser un ticket
2. **Gestion d'erreurs** : Entourer les appels async de try-catch
3. **Sécurité** : Les règles Firestore doivent protéger les tickets
4. **Performance** : Utiliser `watchUserTickets()` pour les mises à jour temps réel
5. **UX** : Afficher les dates d'expiration de manière claire
6. **Testing** : Tester tous les types de récompenses

## Ressources

- Guide complet : `REWARD_SYSTEM_GUIDE.md`
- Code source : `lib/src/services/reward_service.dart`
- Modèles : `lib/src/models/reward_*.dart`
- UI : `lib/src/screens/client/rewards/`
