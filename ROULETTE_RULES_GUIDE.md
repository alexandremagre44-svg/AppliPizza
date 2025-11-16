# 🎰 Guide des Règles de la Roulette

## Vue d'ensemble

Ce guide documente le système complet de règles et d'éligibilité de la roulette implémenté dans l'application Pizza Delizza. Le système gère le cooldown, les limites d'utilisation, les plages horaires, et l'audit complet des tirages.

---

## 📋 Table des matières

1. [Architecture](#architecture)
2. [Services](#services)
3. [Configuration](#configuration)
4. [Interface Utilisateur](#interface-utilisateur)
5. [Administration](#administration)
6. [Audit Trail](#audit-trail)
7. [Intégration avec le Reward System](#intégration-avec-le-reward-system)
8. [Exemples d'utilisation](#exemples-dutilisation)

---

## 🏗️ Architecture

### Structure des fichiers

```
lib/src/
├── services/
│   ├── roulette_rules_service.dart        # Service de gestion des règles
│   ├── roulette_service.dart               # Service existant (legacy)
│   └── reward_service.dart                 # Service de récompenses
├── screens/
│   ├── roulette/
│   │   └── roulette_screen.dart           # Écran client avec vérification
│   ├── profile/
│   │   └── widgets/
│   │       └── roulette_card_widget.dart  # Widget avec status temps réel
│   └── admin/
│       └── roulette/
│           └── roulette_rules_admin_screen.dart  # Configuration admin
└── utils/
    └── roulette_reward_mapper.dart        # Mapping vers le reward system
```

### Modèles de données

#### RouletteStatus
```dart
class RouletteStatus {
  final bool canSpin;           // Peut tourner maintenant
  final String? reason;         // Raison du blocage
  final DateTime? nextEligibleAt; // Prochaine disponibilité
}
```

#### RouletteRules
```dart
class RouletteRules {
  final int cooldownHours;         // Délai minimum entre tirages (anciennement minDelayHours)
  final int maxPlaysPerDay;        // Limite journalière (anciennement dailyLimit, 0 = illimité)
  final int weeklyLimit;           // Limite hebdomadaire (0 = illimité)
  final int monthlyLimit;          // Limite mensuelle (0 = illimité)
  final int allowedStartHour;      // Heure de début (0-23)
  final int allowedEndHour;        // Heure de fin (0-23)
  final bool isEnabled;            // Activation globale
  final String messageDisabled;    // Message quand la roulette est désactivée
  final String messageUnavailable; // Message quand la roulette n'est pas disponible
  final String messageCooldown;    // Message quand l'utilisateur est en cooldown
}
```

**Note:** Les champs `minDelayHours` et `dailyLimit` sont toujours supportés pour la rétrocompatibilité mais sont automatiquement convertis en `cooldownHours` et `maxPlaysPerDay`.

---

## 🔧 Services

### RouletteRulesService

Service principal pour la gestion des règles et de l'éligibilité.

#### Méthodes principales

##### `checkEligibility(String userId)`
Vérifie l'éligibilité d'un utilisateur à tourner la roulette.

**Vérifications effectuées:**
1. ✅ Roulette globalement activée (utilise `messageDisabled` si désactivée)
2. ✅ Plage horaire autorisée
3. ✅ Utilisateur non banni
4. ✅ Cooldown respecté (cooldownHours)
5. ✅ Limite journalière non atteinte (maxPlaysPerDay)
6. ✅ Limite hebdomadaire non atteinte
7. ✅ Limite mensuelle non atteinte

**Exemple:**
```dart
final service = RouletteRulesService();
final status = await service.checkEligibility('user_123');

if (status.canSpin) {
  // Autoriser le tirage
} else {
  // Afficher: status.reason
  // Afficher: status.nextEligibleAt
}
```

##### `recordSpinAudit()`
Enregistre un tirage dans le trail d'audit Firestore.

**Paramètres:**
- `userId`: ID de l'utilisateur
- `segmentId`: ID du segment gagné
- `resultType`: Type de récompense
- `ticketId`: ID du ticket créé (optionnel)
- `expiration`: Date d'expiration du ticket
- `deviceInfo`: Info sur l'appareil

**Structure Firestore:**
```
/roulette_history/{userId}/{YYYY-MM-DD}/{entryId}
  - hour: 14
  - resultType: "free_pizza"
  - segmentId: "segment_5"
  - ticketId: "ticket_abc123"
  - expiration: "2024-11-22T14:00:00Z"
  - deviceInfo: "mobile_app"
  - usedAt: null
  - createdAt: "2024-11-15T14:00:00Z"
```

##### `getRules()` / `saveRules()`
Récupère et sauvegarde les règles depuis/vers Firestore.

**Localisation Firestore:**
```
/config/roulette_rules
```

---

## ⚙️ Configuration

### Configuration par défaut

```dart
RouletteRules(
  cooldownHours: 24,                      // 1 fois par jour
  maxPlaysPerDay: 1,                      // 1 tirage/jour
  weeklyLimit: 0,                         // Illimité
  monthlyLimit: 0,                        // Illimité
  allowedStartHour: 0,                    // Toute la journée
  allowedEndHour: 23,
  isEnabled: true,
  messageDisabled: 'La roulette est actuellement désactivée',
  messageUnavailable: 'La roulette n\'est pas disponible',
  messageCooldown: 'Revenez demain pour retenter votre chance',
)
```

### Exemples de configurations

#### Configuration standard (1 fois par jour)
```dart
cooldownHours: 24
maxPlaysPerDay: 1
weeklyLimit: 0
monthlyLimit: 0
allowedStartHour: 0
allowedEndHour: 23
messageDisabled: 'La roulette est temporairement désactivée'
messageUnavailable: 'La roulette n\'est pas encore disponible'
messageCooldown: 'Revenez demain pour retenter votre chance'
```

#### Configuration horaires restreints (11h-22h)
```dart
cooldownHours: 24
maxPlaysPerDay: 1
weeklyLimit: 7
monthlyLimit: 0
allowedStartHour: 11
allowedEndHour: 22
messageDisabled: 'La roulette est désactivée pour maintenance'
messageUnavailable: 'La roulette n\'est pas disponible actuellement'
messageCooldown: 'Vous avez déjà joué aujourd\'hui'
```

#### Configuration événement spécial
```dart
cooldownHours: 4                        // Tous les 4 heures
maxPlaysPerDay: 3                       // 3 fois par jour max
weeklyLimit: 10
monthlyLimit: 30
allowedStartHour: 0
allowedEndHour: 23
messageDisabled: 'L\'événement est terminé'
messageUnavailable: 'L\'événement n\'a pas encore commencé'
messageCooldown: 'Revenez dans 4 heures'
```

---

## 🎨 Interface Utilisateur

### RouletteScreen

L'écran principal de la roulette intègre le système d'éligibilité.

**Comportements:**
- ✅ Vérifie l'éligibilité au chargement
- ✅ Affiche une bannière d'avertissement si non éligible
- ✅ Désactive le bouton "Tourner" si non éligible
- ✅ Affiche le temps restant avant prochain tirage
- ✅ Affiche les règles en bas de l'écran

**Bannière d'avertissement:**
```
⚠️ Vous avez déjà joué aujourd'hui
   Disponible dans 15 heures
```

### RouletteCardWidget (Profile)

Widget sur l'écran profil affichant le statut temps réel.

**États visuels:**
1. **Eligible** - Icône dorée animée, bouton amber
2. **Non eligible** - Icône grisée, bouton désactivé
3. **Loading** - Spinner de chargement

**Affichage:**
```
🎰 Roulette de la chance

[Si eligible]
"Tentez votre chance pour gagner des récompenses"
[Bouton: "Jouer maintenant"]

[Si non eligible]
"Vous avez déjà joué aujourd'hui"
"Disponible dans 12 heures"
[Bouton désactivé: "Non disponible"]
```

---

## 👨‍💼 Administration

### RouletteRulesAdminScreen

Interface d'administration accessible via **Studio → Règles de la roulette**.

#### Sections du formulaire

##### 1. Activation générale
- Toggle ON/OFF pour activer/désactiver globalement
- Effet immédiat sur tous les utilisateurs

##### 2. Délai entre tirages
- Champ: Heures minimum entre deux tirages
- Exemple: 24h = 1 fois par jour
- Validation: ≥ 0

##### 3. Limites d'utilisation
- **Limite journalière** (tirages/jour, 0 = illimité)
- **Limite hebdomadaire** (tirages/semaine, 0 = illimité)
- **Limite mensuelle** (tirages/mois, 0 = illimité)

##### 4. Plages horaires
- **Heure de début** (0-23)
- **Heure de fin** (0-23)
- Supporte les plages traversant minuit (ex: 22h-2h)

**Navigation:**
```
Menu Admin → Studio → Règles de la roulette
```

**Sauvegarde:**
- Bouton "Enregistrer" dans l'AppBar
- Feedback: SnackBar de confirmation
- Retour automatique à l'écran précédent

---

## 📊 Audit Trail

### Structure de l'audit

Chaque tirage est enregistré dans Firestore pour analyse et reporting.

**Localisation:**
```
/roulette_history
  /{userId}
    /{YYYY-MM-DD}
      /{entryId}
        - hour: int
        - resultType: string
        - segmentId: string
        - ticketId: string?
        - expiration: timestamp?
        - deviceInfo: string
        - usedAt: timestamp?
        - createdAt: timestamp
```

### Données collectées

| Champ | Type | Description |
|-------|------|-------------|
| `hour` | int | Heure du tirage (0-23) |
| `resultType` | string | Type de récompense ou "none" |
| `segmentId` | string | ID du segment gagné |
| `ticketId` | string? | ID du ticket créé (si gain) |
| `expiration` | timestamp? | Expiration du ticket |
| `deviceInfo` | string | Info appareil (placeholder) |
| `usedAt` | timestamp? | Date d'utilisation (null au départ) |
| `createdAt` | timestamp | Date de création |

### Champ utilisateur

En plus de l'audit trail, le service met à jour:
```
/users/{userId}
  - lastSpinAt: timestamp
```

Ce champ permet le calcul du cooldown.

---

## 🎁 Intégration avec le Reward System

### Création de tickets

Le système crée automatiquement des **RewardTicket** pour chaque gain.

**Flow complet:**
```
1. Utilisateur tourne la roulette
2. Segment sélectionné aléatoirement
3. RouletteService.recordSpin() → Firestore
4. createTicketFromRouletteSegment()
   ├─ Génère ID unique: roulette_{segmentId}_{timestamp}
   ├─ Mappe segment → RewardAction
   ├─ Ajoute source: "roulette"
   ├─ Définit expiration: 7 jours
   ├─ Crée RewardTicket via RewardService
   └─ Enregistre dans roulette_history
5. Redirection → RewardsScreen
```

### Mapper: roulette_reward_mapper.dart

**Fonction principale:**
```dart
Future<RewardTicket?> createTicketFromRouletteSegment({
  required String userId,
  required RouletteSegment segment,
  Duration? validity,
})
```

**Mapping des types:**
- `percentageDiscount` → RewardType.percentageDiscount
- `fixedAmountDiscount` → RewardType.fixedDiscount
- `freeProduct` → RewardType.freeProduct
- `freeDrink` → RewardType.freeDrink
- `none` → Pas de ticket (enregistrement audit seulement)

**Propriétés ajoutées:**
- `source: "roulette"`
- `label`: Label du segment
- `description`: Description du segment
- Validité par défaut: 7 jours

---

## 💡 Exemples d'utilisation

### Vérifier l'éligibilité avant affichage

```dart
final service = RouletteRulesService();
final status = await service.checkEligibility(userId);

if (status.canSpin) {
  showRouletteButton();
} else {
  showIneligibilityMessage(status.reason);
  if (status.nextEligibleAt != null) {
    showCountdown(status.nextEligibleAt);
  }
}
```

### Afficher le temps restant

```dart
String formatNextEligibleTime(DateTime nextTime) {
  final now = DateTime.now();
  final difference = nextTime.difference(now);
  
  if (difference.inDays > 0) {
    return 'Disponible dans ${difference.inDays} jour(s)';
  } else if (difference.inHours > 0) {
    return 'Disponible dans ${difference.inHours} heure(s)';
  } else if (difference.inMinutes > 0) {
    return 'Disponible dans ${difference.inMinutes} minute(s)';
  } else {
    return 'Disponible maintenant';
  }
}
```

### Enregistrer un tirage avec audit

```dart
// Après le spin
final ticket = await createTicketFromRouletteSegment(
  userId: userId,
  segment: selectedSegment,
);

// L'audit est automatiquement enregistré dans createTicketFromRouletteSegment
// incluant le ticketId si un gain
```

### Configurer des horaires d'ouverture (11h-22h)

```dart
final rules = RouletteRules(
  minDelayHours: 24,
  dailyLimit: 1,
  weeklyLimit: 0,
  monthlyLimit: 0,
  allowedStartHour: 11,
  allowedEndHour: 22,
  isEnabled: true,
);

await RouletteRulesService().saveRules(rules);
```

---

## 🔒 Sécurité et Validation

### Vérifications côté serveur

Toutes les vérifications sont effectuées côté serveur (Firestore) :
- Cooldown basé sur `lastSpinAt` dans `/users/{userId}`
- Comptage des spins depuis `/roulette_history` et `/user_roulette_spins`
- Vérification du flag `isBanned`

### Points d'attention

1. **Aucun doublon**: Le système empêche plusieurs tirages simultanés
2. **Timestamps serveur**: Utilise `DateTime.now()` côté service
3. **Fallback**: Si l'audit trail échoue, utilise `/user_roulette_spins` (legacy)
4. **Firestore Rules**: Assurez-vous que les rules Firestore protègent:
   - `/config/roulette_rules` → Admin seulement
   - `/roulette_history/{userId}` → Lecture/écriture utilisateur propriétaire

---

## 📱 Routes et Navigation

### Routes utilisateur
- `/roulette?userId={id}` → RouletteScreen
- `/rewards` → RewardsScreen

### Routes admin
- Studio → **Règles de la roulette** → RouletteRulesAdminScreen

---

## 🎯 Résumé des règles par défaut

| Règle | Valeur | Description |
|-------|--------|-------------|
| **isEnabled** | `true` | Roulette active |
| **minDelayHours** | `24` | 1 fois par jour |
| **dailyLimit** | `1` | 1 tirage maximum/jour |
| **weeklyLimit** | `0` | Illimité |
| **monthlyLimit** | `0` | Illimité |
| **allowedStartHour** | `0` | Disponible 24h/24 |
| **allowedEndHour** | `23` | Disponible 24h/24 |

---

## ✅ Checklist de mise en production

- [ ] Configurer les Firestore Rules pour `/config/roulette_rules`
- [ ] Configurer les Firestore Rules pour `/roulette_history/{userId}`
- [ ] Définir les règles via l'admin (minDelayHours, limites, horaires)
- [ ] Tester l'éligibilité avec un compte test
- [ ] Vérifier l'audit trail dans Firestore
- [ ] Vérifier la création de RewardTicket
- [ ] Tester le cooldown (attendre minDelayHours)
- [ ] Tester les plages horaires (si configurées)
- [ ] Vérifier le comportement quand désactivé globalement

---

## 🐛 Troubleshooting

### La roulette n'est pas disponible

1. Vérifier que `isEnabled = true` dans `/config/roulette_rules`
2. Vérifier l'heure actuelle vs `allowedStartHour`/`allowedEndHour`
3. Vérifier `lastSpinAt` dans `/users/{userId}`
4. Vérifier les compteurs dans `/roulette_history/{userId}`

### Le cooldown ne fonctionne pas

1. Vérifier que `lastSpinAt` est mis à jour dans `/users/{userId}`
2. Vérifier que `minDelayHours` est configuré correctement
3. Vérifier le fuseau horaire (utilise l'heure locale du serveur)

### L'audit trail est vide

1. Vérifier les permissions Firestore pour `/roulette_history`
2. Vérifier que `recordSpinAudit()` est appelé après chaque tirage
3. Vérifier les logs dans la console pour erreurs

---

## 📚 Références

- **RewardTicket**: `/lib/src/models/reward_ticket.dart`
- **RewardAction**: `/lib/src/models/reward_action.dart`
- **RewardService**: `/lib/src/services/reward_service.dart`
- **RouletteSegment**: `/lib/src/models/roulette_config.dart`

---

## 🎉 Conclusion

Le système de règles de la roulette offre une configuration flexible et complète :
- ✅ Cooldown configurable
- ✅ Limites multiples (jour/semaine/mois)
- ✅ Plages horaires
- ✅ Audit complet
- ✅ Intégration transparente avec le Reward System PRO
- ✅ Interface admin intuitive
- ✅ UI client responsive avec feedback temps réel

Tous les textes sont routables via le système **Textes & Messages** pour permettre la personnalisation sans modifier le code.

---

**Dernière mise à jour:** 2024-11-15  
**Version:** 1.0.0
