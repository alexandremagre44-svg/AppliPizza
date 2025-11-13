# Guide du Système de Fidélité - Pizza Deli'Zza

## Vue d'ensemble

Le système de fidélité a été intégré dans l'application Pizza Deli'Zza pour récompenser les clients fidèles avec des points, des niveaux VIP, et des récompenses exclusives.

## Architecture

### Modèles

#### `LoyaltyReward` (`lib/src/models/loyalty_reward.dart`)
- **Types de récompenses** :
  - `free_pizza` : Pizza gratuite
  - `bonus_points` : Points bonus
  - `free_drink` : Boisson gratuite
  - `free_dessert` : Dessert gratuit
  
- **Propriétés** :
  - `type` : Type de récompense
  - `value` : Valeur (utilisé pour bonus_points)
  - `used` : État d'utilisation
  - `createdAt` : Date de création
  - `usedAt` : Date d'utilisation

#### `VipTier`
- **Niveaux** :
  - `bronze` : < 2000 points à vie (0% de réduction)
  - `silver` : ≥ 2000 points à vie (5% de réduction)
  - `gold` : ≥ 5000 points à vie (10% de réduction)

### Services

#### `LoyaltyService` (`lib/src/services/loyalty_service.dart`)

Singleton gérant toute la logique de fidélité :

##### Méthodes principales

**`initializeLoyalty(String uid)`**
- Initialise le profil de fidélité d'un utilisateur
- Appelé automatiquement lors du login/signup
- Crée les champs Firestore nécessaires

**`addPointsFromOrder(String uid, double orderTotalInEuros)`**
- Ajoute des points après une commande payée
- Règle : 1€ = 10 points
- Gère automatiquement :
  - Attribution de pizzas gratuites (chaque 1000 points)
  - Calcul du niveau VIP
  - Attribution de tours de roue (chaque 500 points lifetime)

**`spinRewardWheel(String uid)`**
- Fait tourner la roue de récompenses
- Probabilités :
  - 5% : Rien
  - 20% : Bonus points (50-200)
  - 30% : Boisson gratuite
  - 45% : Dessert gratuit
- Consomme 1 `availableSpins`

**`useReward(String uid, String rewardType)`**
- Marque une récompense comme utilisée
- Appelé lors du checkout

**`applyVipDiscount(String vipTier, double total)`**
- Calcule le total avec réduction VIP appliquée

### Structure Firestore

Collection : `users/{uid}`

Nouveaux champs ajoutés :
```json
{
  "loyaltyPoints": 250,
  "lifetimePoints": 1250,
  "vipTier": "bronze",
  "rewards": [
    {
      "type": "free_pizza",
      "value": null,
      "used": false,
      "createdAt": Timestamp,
      "usedAt": null
    }
  ],
  "availableSpins": 2,
  "updatedAt": Timestamp
}
```

### Intégrations

#### FirebaseAuthService
Appelle `LoyaltyService().initializeLoyalty()` lors de :
- Login
- Signup

#### FirebaseOrderService
Appelle `LoyaltyService().addPointsFromOrder()` après la création d'une commande.

#### CheckoutScreen
- Affiche les réductions VIP
- Permet de sélectionner et utiliser des récompenses
- Applique automatiquement la réduction VIP au total

#### ProfileScreen
- Affiche les points de fidélité actuels
- Montre la progression vers la prochaine pizza gratuite
- Affiche le niveau VIP et ses avantages
- Liste les récompenses disponibles
- Bouton "Tourner la Roue" si des spins sont disponibles

## Règles de Gestion

### Attribution de points
- **1€ dépensé = 10 points**
- Les points sont ajoutés à la fois à `loyaltyPoints` et `lifetimePoints`
- `loyaltyPoints` : solde actuel (décrementé lors de l'échange contre des pizzas)
- `lifetimePoints` : total cumulé (jamais décrementé, utilisé pour le niveau VIP)

### Pizzas gratuites
- **1000 points = 1 pizza gratuite**
- Automatiquement créée et ajoutée aux récompenses
- Les points sont retirés du solde `loyaltyPoints`

### Niveau VIP
- Calculé automatiquement basé sur `lifetimePoints`
- **Bronze** (défaut) : < 2000 points → 0% de réduction
- **Silver** : 2000-4999 points → 5% de réduction
- **Gold** : ≥ 5000 points → 10% de réduction

### Tours de roue
- **1 tour gratuit tous les 500 points lifetime**
- Exemple : 
  - 0-499 pts : 0 tours
  - 500-999 pts : 1 tour
  - 1000-1499 pts : 2 tours
  - etc.

### Utilisation des récompenses
Au checkout, le client peut :
1. Sélectionner les récompenses à utiliser
2. Les récompenses sont marquées comme `used: true` après confirmation
3. `usedAt` est enregistré avec timestamp

## Tests

Des tests unitaires sont fournis dans `test/services/loyalty_service_test.dart` pour :
- Calcul des niveaux VIP
- Calcul des réductions
- Conversion JSON des récompenses
- Calcul des points
- Calcul des pizzas gratuites
- Calcul des tours de roue

## Compatibilité

✅ **Pas de breaking changes**
- Le système est totalement additionnel
- N'affecte pas les fonctionnalités existantes :
  - Panier
  - Commandes
  - Admin
  - Cuisine
- Les utilisateurs existants verront leurs profils automatiquement initialisés au prochain login

## Sécurité Firestore

Les règles Firestore existantes permettent :
- Aux utilisateurs de lire leur propre profil
- Aux utilisateurs de mettre à jour leur profil (sauf le champ `role`)
- Cela inclut les nouveaux champs de fidélité

## Évolutions futures possibles

1. **Historique des récompenses** : Afficher l'historique complet des récompenses gagnées et utilisées
2. **Notifications** : Notifier les clients quand ils gagnent des récompenses ou changent de niveau
3. **Récompenses personnalisées** : Admin peut créer des récompenses spéciales
4. **Badges** : Système de badges pour les achievements
5. **Parrainage** : Points bonus pour avoir parrainé un ami
6. **Double points** : Événements avec points doublés
7. **Leaderboard** : Classement des meilleurs clients

## Support

Pour toute question ou problème, consultez :
- Ce guide
- Le code source avec commentaires détaillés
- Les tests unitaires pour exemples d'utilisation
