# Résumé Visuel du Système de Fidélité

## 📱 Interface Utilisateur

### Page Profil - Nouvelle Section Fidélité

```
┌─────────────────────────────────────┐
│   ⭐ Programme de Fidélité          │
├─────────────────────────────────────┤
│                                     │
│  ┌──────────────────────────────┐  │
│  │  🏆 Niveau GOLD              │  │
│  │  5000 points à vie           │  │
│  │                         -10% │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │  Points Fidélité        ⭐   │  │
│  │  850 pts                     │  │
│  │                              │  │
│  │  Progression vers pizza:    │  │
│  │  ████████░░░░ 85%            │  │
│  │  Plus que 150 points         │  │
│  └──────────────────────────────┘  │
│                                     │
│  Récompenses disponibles:           │
│  🍕 Pizza Gratuite                  │
│  🥤 Boisson Gratuite                │
│                                     │
│  ┌──────────────────────────────┐  │
│  │ 🎰 Tourner la Roue (2 dispos)│  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

### Page Checkout - Réductions VIP

```
┌─────────────────────────────────────┐
│   Récapitulatif                     │
├─────────────────────────────────────┤
│  2x Pizza Margherita      20.00 €  │
│  1x Coca-Cola              3.00 €  │
│  ─────────────────────────────────  │
│  Sous-total               23.00 €  │
│  Réduction VIP GOLD ⭐    -2.30 €  │
│  Frais de service          5.00 €  │
│  ─────────────────────────────────  │
│  Total                    25.70 €  │
└─────────────────────────────────────┘
│                                     │
│  Utiliser des récompenses           │
│  ☑ 🍕 Pizza Gratuite                │
│  ☐ 🥤 Boisson Gratuite              │
└─────────────────────────────────────┘
```

## 🎯 Flux Utilisateur

### 1. Inscription/Connexion
```
Utilisateur → FirebaseAuthService
                    ↓
            LoyaltyService.initializeLoyalty()
                    ↓
            Profil créé avec:
            - loyaltyPoints: 0
            - lifetimePoints: 0
            - vipTier: "bronze"
            - rewards: []
            - availableSpins: 0
```

### 2. Passer une Commande
```
Utilisateur passe commande (25.00€)
                    ↓
        FirebaseOrderService.createOrder()
                    ↓
    LoyaltyService.addPointsFromOrder()
                    ↓
        Calcul: 25.00€ × 10 = 250 points
                    ↓
        loyaltyPoints: 0 → 250
        lifetimePoints: 0 → 250
                    ↓
        Vérifications:
        - 250 ÷ 1000 = 0 pizza gratuite
        - 250 ÷ 500 = 0 tour de roue
        - vipTier reste "bronze"
```

### 3. Atteindre 1000 Points
```
Utilisateur a 1250 points
                    ↓
    Calcul automatique:
    - 1250 ÷ 1000 = 1 pizza gratuite
    - Reste: 1250 % 1000 = 250 points
                    ↓
    Mise à jour:
    - loyaltyPoints: 250
    - rewards: [{ type: "free_pizza", ... }]
                    ↓
    Affichage dans profil:
    "🍕 Pizza Gratuite"
```

### 4. Devenir Silver (2000+ pts lifetime)
```
Utilisateur a 2100 points lifetime
                    ↓
    VipTier.getTierFromLifetimePoints(2100)
                    ↓
    vipTier: "bronze" → "silver"
                    ↓
    Au checkout:
    - Réduction de 5% appliquée
    - Badge SILVER ⭐ affiché
```

### 5. Tourner la Roue
```
Utilisateur clique "Tourner la Roue"
                    ↓
    LoyaltyService.spinRewardWheel()
                    ↓
    Génération aléatoire:
    - 5% chance: Rien
    - 20% chance: 50-200 points bonus
    - 30% chance: Boisson gratuite
    - 45% chance: Dessert gratuit
                    ↓
    Résultat: "Boisson gratuite"
                    ↓
    Mise à jour:
    - availableSpins: 1 → 0
    - rewards: [..., { type: "free_drink" }]
                    ↓
    Popup: "Félicitations ! 🥤"
```

## 📊 Progression des Niveaux

```
Points Lifetime:

    0 ────────── 2000 ────────── 5000 ─────────→
    │              │                │
  BRONZE         SILVER           GOLD
   0% off         5% off          10% off
    🥉             🥈              🏆
```

## 🎁 Système de Récompenses

### Attribution Automatique

```
Commandes → Points → Paliers → Récompenses

1. Tous les 1000 points:
   └→ 🍕 Pizza Gratuite

2. Tous les 500 points lifetime:
   └→ 🎰 1 Tour de Roue
        ├→ 20% : Bonus Points (50-200)
        ├→ 30% : 🥤 Boisson Gratuite
        ├→ 45% : 🍰 Dessert Gratuit
        └→  5% : Rien
```

### Utilisation au Checkout

```
1. Client sélectionne récompenses
   ☑ Pizza Gratuite
   ☐ Boisson Gratuite

2. Confirmation commande
   ↓
   LoyaltyService.useReward()

3. Récompense marquée:
   used: false → true
   usedAt: Timestamp
```

## 🔄 Cycle de Vie Complet

```
┌──────────────────────────────────────────────┐
│  1. INSCRIPTION                              │
│     loyaltyPoints: 0                         │
│     lifetimePoints: 0                        │
│     vipTier: "bronze"                        │
└──────────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────────┐
│  2. PREMIÈRE COMMANDE (50€)                  │
│     + 500 points                             │
│     loyaltyPoints: 500                       │
│     lifetimePoints: 500                      │
│     availableSpins: +1                       │
└──────────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────────┐
│  3. ACCUMULATION (150€ dépensés)             │
│     + 1500 points                            │
│     loyaltyPoints: 2000 → 1000 (1 pizza)    │
│     lifetimePoints: 2000                     │
│     vipTier: "bronze" → "silver"             │
│     rewards: [free_pizza]                    │
│     availableSpins: 4                        │
└──────────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────────┐
│  4. NIVEAU GOLD (500€+ dépensés)             │
│     lifetimePoints: 5000+                    │
│     vipTier: "gold"                          │
│     Réduction: 10% sur toutes commandes      │
└──────────────────────────────────────────────┘
```

## 💾 Structure Firestore

```javascript
users/{uid} {
  // Champs existants
  email: "client@example.com",
  role: "client",
  displayName: "Jean Dupont",
  createdAt: Timestamp,
  
  // Nouveaux champs fidélité
  loyaltyPoints: 850,           // Solde actuel
  lifetimePoints: 2350,         // Total cumulé
  vipTier: "silver",            // bronze | silver | gold
  availableSpins: 2,            // Tours de roue dispo
  rewards: [
    {
      type: "free_pizza",
      value: null,
      used: false,
      createdAt: Timestamp,
      usedAt: null
    },
    {
      type: "free_drink",
      value: null,
      used: true,
      createdAt: Timestamp,
      usedAt: Timestamp
    }
  ],
  updatedAt: Timestamp
}
```

## 🎨 Design System

### Couleurs par Niveau VIP

```
Bronze: #8D6E63 (Marron)
Silver: #BDBDBD (Gris argenté)  
Gold:   #F57C00 (Or/Ambre)
```

### Icônes

```
Points:        ⭐ stars
Pizza:         🍕 local_pizza
Boisson:       🥤 local_drink
Dessert:       🍰 cake
Roue:          🎰 casino
Bronze:        🏆 emoji_events
Silver:        🥈 military_tech
Gold:          👑 workspace_premium
Cadeau:        🎁 card_giftcard
```

## 📈 Exemples de Calcul

### Exemple 1: Nouveau client
```
Commande: 35.00€
Points gagnés: 350 pts
Total points: 350 pts
Pizzas gratuites: 0
Tours de roue: 0
Niveau: Bronze (0% off)
```

### Exemple 2: Client régulier
```
Lifetime: 1800 pts
Commande: 25.00€
Points gagnés: 250 pts
Total points actuel: 300 → 550 pts
Total lifetime: 1800 → 2050 pts
Pizzas gratuites: 0
Tours de roue: +1 (passage de 3 à 4 paliers de 500)
Niveau: Bronze → Silver (5% off)
Réduction appliquée: 25€ × 5% = 1.25€ économisés
```

### Exemple 3: VIP Gold
```
Lifetime: 5500 pts
Points actuels: 2300 pts
Commande: 100.00€
Points gagnés: 1000 pts
Total points: 2300 → 3300 pts
Pizzas gratuites: +3 (3300 ÷ 1000)
Points restants: 300 pts (3300 % 1000)
Niveau: Gold (10% off)
Réduction: 100€ × 10% = 10€ économisés
Prix final: 90€
Tours de roue: +2 (passage de 11 à 13 paliers)
```

Ce système est conçu pour :
✅ Récompenser la fidélité
✅ Encourager les commandes régulières
✅ Offrir des avantages progressifs
✅ Maintenir l'engagement client
✅ Être facile à comprendre et utiliser
