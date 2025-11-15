# Reward System PRO - Guide Complet

## Vue d'ensemble

Le **Reward System PRO** est un système centralisé de récompenses basé sur des tickets avec date de validité. Il est conçu pour être réutilisable par plusieurs modules de l'application :
- La Roulette (déjà intégrée)
- Le système de fidélité (prêt pour intégration)
- Les campagnes promotionnelles (prêt pour intégration)

## Architecture

### 1. Modèles de données

#### `RewardType` (enum)
Types de récompenses disponibles :
- `percentageDiscount` : Réduction en pourcentage (ex: 20%)
- `fixedDiscount` : Réduction en montant fixe (ex: 5€)
- `freeProduct` : Produit spécifique offert
- `freeCategory` : Produit offert dans une catégorie
- `freeAnyPizza` : N'importe quelle pizza offerte
- `freeDrink` : Boisson offerte
- `custom` : Type personnalisé (pour extensions futures)

#### `RewardAction`
Représentation logique d'une récompense (le "blueprint").

```dart
RewardAction(
  type: RewardType.percentageDiscount,
  percentage: 20.0,
  source: 'roulette',
  label: '-20%',
  description: 'Réduction de 20% sur votre commande'
)
```

Champs principaux :
- `type` : Type de récompense
- `percentage` : Valeur pour réduction en %
- `amount` : Valeur pour réduction en €
- `productId` : ID du produit spécifique
- `categoryId` : ID de la catégorie
- `source` : Origine ('roulette', 'loyalty', 'promo')
- `label` : Libellé court (ex: "-20%")
- `description` : Description complète

#### `RewardTicket`
Ticket de récompense stocké dans Firestore.

```dart
RewardTicket(
  id: 'ticket_123',
  userId: 'user_abc',
  action: rewardAction,
  createdAt: DateTime.now(),
  expiresAt: DateTime.now().add(Duration(days: 30)),
  isUsed: false,
  usedAt: null
)
```

Structure Firestore : `users/{userId}/rewardTickets/{ticketId}`

Propriétés calculées :
- `isExpired` : true si expiré
- `isActive` : true si non utilisé et non expiré

### 2. Service Layer

#### `RewardService`
Service central pour la gestion des tickets dans Firestore.

**Méthodes principales :**

```dart
// Créer un ticket
Future<RewardTicket> createTicket({
  required String userId,
  required RewardAction action,
  required Duration validity,
})

// Récupérer les tickets d'un utilisateur
Future<List<RewardTicket>> getUserTickets(String userId)

// Marquer un ticket comme utilisé
Future<void> markTicketUsed(String userId, String ticketId)

// Stream temps réel des tickets
Stream<List<RewardTicket>> watchUserTickets(String userId)
```

**Méthodes d'extensibilité (TODO) :**
- `createTicketFromLoyalty()` : Pour système de fidélité
- `createTicketFromPromo()` : Pour campagnes promo
- `deleteExpiredTickets()` : Nettoyage automatique

### 3. Utilitaires

#### `roulette_reward_mapper.dart`
Mappe les segments de roulette vers le système de récompenses.

```dart
// Créer un ticket depuis un segment de roulette
Future<RewardTicket?> createTicketFromRouletteSegment({
  required String userId,
  required RouletteSegment segment,
  Duration validity = const Duration(days: 30),
})
```

## Intégrations

### 1. Roulette (✅ Intégrée)

Le système de roulette crée automatiquement des tickets au lieu d'appliquer directement les récompenses au panier.

**Flux :**
1. L'utilisateur tourne la roue
2. Un segment est sélectionné
3. Un `RewardTicket` est créé via `createTicketFromRouletteSegment()`
4. Le dialogue de résultat affiche le gain
5. L'utilisateur peut naviguer vers la page "Récompenses"

**Fichier modifié :** `lib/src/screens/roulette/roulette_screen.dart`

### 2. Page Récompenses (✅ Intégrée)

Affiche tous les tickets de l'utilisateur en temps réel.

**Sections :**
- **Récompenses disponibles** : Tickets actifs avec bouton "Utiliser maintenant"
- **Historique** : Tickets expirés ou utilisés (affichage discret)

**Navigation :**
- Depuis le menu principal ou la roulette
- Route : `/rewards` ou `RewardsScreen()`

**Fichier :** `lib/src/screens/client/rewards/rewards_screen.dart`

### 3. Sélecteur de produits (✅ Implémenté)

Écran de sélection pour les produits gratuits.

**Utilisé pour :**
- `freeProduct` : Affiche le produit spécifique
- `freeCategory` : Affiche tous les produits de la catégorie
- `freeAnyPizza` : Affiche toutes les pizzas
- `freeDrink` : Affiche toutes les boissons

**Fonctionnement :**
1. L'utilisateur clique sur "Utiliser maintenant"
2. Navigation vers `RewardProductSelectorScreen`
3. Sélection du produit
4. Ajout au panier avec prix = 0€
5. Marquage du ticket comme utilisé

**Fichier :** `lib/src/screens/client/rewards/reward_product_selector_screen.dart`

### 4. Panier (✅ Intégré)

Le panier a été étendu pour supporter les tickets de récompenses.

**Nouveau champ dans `CartState` :**
```dart
final RewardTicket? appliedTicket;
```

**Nouvelle méthode :**
```dart
Future<void> applyTicket(RewardTicket ticket)
```

**Gestion des types de récompenses :**
- **Réductions (% ou €)** : Appliquées directement au panier, ticket marqué comme utilisé
- **Produits gratuits** : Gérés via `RewardProductSelectorScreen`

**Validation :**
- Le ticket ne doit pas être déjà utilisé
- Le ticket ne doit pas être expiré

**Fichier :** `lib/src/providers/cart_provider.dart`

## Utilisation

### Créer un ticket manuellement

```dart
final rewardService = RewardService();

final action = RewardAction(
  type: RewardType.percentageDiscount,
  percentage: 15.0,
  source: 'loyalty',
  label: '-15%',
  description: 'Réduction de fidélité de 15%',
);

final ticket = await rewardService.createTicket(
  userId: 'user_123',
  action: action,
  validity: Duration(days: 30),
);
```

### Récupérer les tickets d'un utilisateur

```dart
final rewardService = RewardService();
final tickets = await rewardService.getUserTickets('user_123');

// Filtrer les tickets actifs
final activeTickets = tickets.where((t) => t.isActive).toList();
```

### Utiliser un ticket

```dart
final cartNotifier = ref.read(cartProvider.notifier);
await cartNotifier.applyTicket(ticket);
```

## Extensibilité

### Système de fidélité (TODO)

Le système est prêt pour intégrer les points de fidélité :

```dart
// Dans RewardService
Future<RewardTicket> createTicketFromLoyalty({
  required String userId,
  required int pointsCost,
  required RewardAction action,
  Duration validity = const Duration(days: 30),
}) async {
  // TODO: Implémenter
  // - Vérifier que l'utilisateur a assez de points
  // - Déduire les points
  // - Créer le ticket
  // - Enregistrer la transaction
}
```

**Points d'intégration suggérés :**
1. Ajouter un bouton "Échanger des points" dans `RewardsScreen`
2. Créer un écran de catalogue de récompenses échangeables
3. Appeler `createTicketFromLoyalty()` lors de l'échange

### Campagnes promotionnelles (TODO)

Le système est prêt pour les campagnes marketing :

```dart
// Dans RewardService
Future<RewardTicket> createTicketFromPromo({
  required String userId,
  required String campaignId,
  required RewardAction action,
  Duration validity = const Duration(days: 15),
}) async {
  // TODO: Implémenter
  // - Vérifier que la campagne est active
  // - Vérifier l'éligibilité de l'utilisateur
  // - Créer le ticket
  // - Enregistrer la participation
}
```

**Points d'intégration suggérés :**
1. Détecter les codes promo saisis
2. Afficher des pop-ups promotionnels
3. Créer des tickets automatiquement lors d'événements (anniversaire, etc.)

## Design System

Tous les écrans utilisent le **Material 3 Design System** de l'application :

- `AppColors` : Palette de couleurs (primary, success, error, etc.)
- `AppTextStyles` : Styles de texte (displaySmall, titleLarge, bodyMedium, etc.)
- `AppSpacing` : Espacements cohérents (xs, sm, md, lg, xl, etc.)
- `AppRadius` : Bordures arrondies (button, card, dialog, etc.)
- `AppShadows` : Ombres Material 3

## Firestore Structure

```
users/
  {userId}/
    rewardTickets/
      {ticketId}/
        - type: string
        - percentage: number (optional)
        - amount: number (optional)
        - productId: string (optional)
        - categoryId: string (optional)
        - source: string
        - label: string
        - description: string
        - createdAt: timestamp
        - expiresAt: timestamp
        - isUsed: boolean
        - usedAt: timestamp (optional)
```

## Sécurité Firestore

Les règles Firestore doivent être mises à jour pour protéger les tickets :

```javascript
match /users/{userId}/rewardTickets/{ticketId} {
  // L'utilisateur peut lire ses propres tickets
  allow read: if request.auth != null && request.auth.uid == userId;
  
  // Seuls les admins peuvent créer/modifier des tickets
  allow create, update: if request.auth != null 
    && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
  
  // Les tickets ne peuvent pas être supprimés
  allow delete: if false;
}
```

## Tests recommandés

### Tests unitaires
- Validation des modèles (RewardAction, RewardTicket)
- Conversion Firestore (toMap, fromMap)
- Logique métier (isExpired, isActive)

### Tests d'intégration
- Création de tickets via RewardService
- Marquage de tickets comme utilisés
- Application de tickets au panier
- Navigation entre les écrans

### Tests UI
- Affichage des tickets actifs/expirés
- Sélection de produits gratuits
- Application de réductions au panier

## Maintenance

### Nettoyage automatique

Utiliser la méthode `deleteExpiredTickets()` pour nettoyer les vieux tickets :

```dart
// Exemple : Cloud Function déclenchée quotidiennement
final rewardService = RewardService();
await rewardService.deleteExpiredTickets(userId);
```

Suggéré : Supprimer les tickets utilisés depuis plus de 90 jours.

### Monitoring

Points à surveiller :
- Nombre de tickets créés par jour
- Taux d'utilisation des tickets
- Taux d'expiration des tickets
- Temps moyen entre création et utilisation

## Contraintes respectées

✅ Pas de modification de `PizzaRouletteWheel`  
✅ Pas de modification de `RouletteSettingsScreen`  
✅ Pas de modification des écrans admin  
✅ Pas de casse de la logique existante du panier/commandes  
✅ Utilisation du Material 3 Design System  
✅ Architecture modulaire et extensible  

## Fichiers créés

- `lib/src/models/reward_action.dart`
- `lib/src/models/reward_ticket.dart`
- `lib/src/services/reward_service.dart`
- `lib/src/utils/roulette_reward_mapper.dart`
- `lib/src/screens/client/rewards/reward_product_selector_screen.dart`

## Fichiers modifiés

- `lib/src/screens/client/rewards/rewards_screen.dart`
- `lib/src/providers/cart_provider.dart`
- `lib/src/screens/roulette/roulette_screen.dart`

## Prochaines étapes recommandées

1. **Tests** : Ajouter des tests unitaires et d'intégration
2. **Firestore Rules** : Mettre à jour les règles de sécurité
3. **Cloud Functions** : Ajouter un nettoyage automatique des tickets expirés
4. **Analytics** : Intégrer Firebase Analytics pour suivre l'utilisation
5. **Notifications** : Notifier les utilisateurs avant expiration des tickets
6. **Fidélité** : Implémenter `createTicketFromLoyalty()`
7. **Promos** : Implémenter `createTicketFromPromo()`

## Support

Pour toute question ou problème, consulter le code source avec les commentaires détaillés dans chaque fichier.
