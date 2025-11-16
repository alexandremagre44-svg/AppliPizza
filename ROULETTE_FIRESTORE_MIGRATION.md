# 🔥 Guide de Migration Firestore de la Roulette

## Vue d'ensemble

Ce document décrit la migration complète du système de roulette vers une architecture Firestore unifiée et cohérente.

---

## 📊 Ancienne vs Nouvelle Structure

### ❌ Ancienne Structure (Obsolète)

```
app_roulette_config/main        ⛔ SUPPRIMÉ
  - isActive: bool
  - displayLocation: string
  - delaySeconds: number
  - maxUsesPerDay: number
  - segments: array[]
  
marketing/roulette_settings    ⛔ SUPPRIMÉ
  (configuration marketing obsolète)
```

### ✅ Nouvelle Structure (Actuelle)

```
config/roulette_rules          ✅ DOCUMENT UNIQUE
  - isEnabled: bool
  - cooldownHours: number
  - maxPlaysPerDay: number
  - allowedStartHour: number
  - allowedEndHour: number
  - weeklyLimit: number
  - monthlyLimit: number
  - messageDisabled: string
  - messageUnavailable: string
  - messageCooldown: string

roulette_segments/{segmentId}  ✅ COLLECTION
  - id: string
  - label: string
  - description: string?
  - iconName: string?
  - isActive: bool
  - probability: number
  - rewardType: string
  - rewardId: string?
  - rewardValue: number?
  - productId: string?
  - weight: number
  - position: number
  - colorHex: string
```

---

## 🔄 Changements de Champs

### RouletteRules

| Ancien Nom | Nouveau Nom | Type | Description |
|------------|-------------|------|-------------|
| `minDelayHours` | `cooldownHours` | number | Délai entre les tirages |
| `dailyLimit` | `maxPlaysPerDay` | number | Nombre max de tirages par jour |
| - | `messageDisabled` | string | Message quand désactivé |
| - | `messageUnavailable` | string | Message quand indisponible |
| - | `messageCooldown` | string | Message en période de cooldown |

**Rétrocompatibilité:** Les anciens noms `minDelayHours` et `dailyLimit` sont toujours supportés et automatiquement convertis lors de la lecture depuis Firestore.

---

## 🛠️ Services Mis à Jour

### RouletteRulesService ✅

**Chemin Firestore:** `config/roulette_rules`

```dart
class RouletteRulesService {
  // Récupère les règles depuis config/roulette_rules
  Future<RouletteRules?> getRules();
  
  // Sauvegarde les règles dans config/roulette_rules
  Future<void> saveRules(RouletteRules rules);
  
  // Vérifie l'éligibilité d'un utilisateur
  Future<RouletteStatus> checkEligibility(String userId);
  
  // Enregistre un tirage dans l'audit trail
  Future<void> recordSpinAudit({...});
  
  // Stream temps réel des règles
  Stream<RouletteRules?> watchRules();
}
```

### RouletteSegmentService ✅

**Chemin Firestore:** `roulette_segments/{segmentId}`

```dart
class RouletteSegmentService {
  // Récupère tous les segments
  Future<List<RouletteSegment>> getAllSegments();
  
  // Récupère uniquement les segments actifs
  Future<List<RouletteSegment>> getActiveSegments();
  
  // CRUD operations
  Future<bool> createSegment(RouletteSegment segment);
  Future<bool> updateSegment(RouletteSegment segment);
  Future<bool> deleteSegment(String id);
  
  // Stream temps réel des segments
  Stream<List<RouletteSegment>> watchSegments();
}
```

### RouletteService ⚠️ (Simplifié)

Le service `RouletteService` a été simplifié et n'est plus qu'une façade légère:

**Avant:**
- ❌ `getRouletteConfig()` - Lisait depuis `app_roulette_config/main`
- ❌ `saveRouletteConfig()` - Écrivait dans `app_roulette_config/main`
- ❌ `initializeDefaultConfig()` - Créait la config obsolète

**Après:**
- ✅ `recordSpin()` - Enregistre un tirage
- ✅ `getUserSpinHistory()` - Récupère l'historique
- ✅ `spinWheel()` - Logique de sélection probabiliste

---

## 📱 Écrans Mis à Jour

### RouletteCardWidget ✅

Widget dans le profil utilisateur qui affiche l'état de la roulette.

**États possibles:**
- `loading` - Chargement en cours
- `disabled` - Roulette désactivée (affiche `messageDisabled`)
- `unavailable` - Pas de segments actifs (affiche `messageUnavailable`)
- `cooldown` - En période de cooldown (affiche message avec temps restant)
- `timeRestricted` - Hors des horaires autorisés
- `ready` - Prêt à jouer

```dart
RouletteCardWidget(
  texts: rewardsTexts.roulette,
  userId: userId,
)
```

### RouletteScreen ✅

Écran principal de la roue avec vérification d'éligibilité.

**Intégrations:**
- ✅ Lit `config/roulette_rules` pour les règles
- ✅ Lit `roulette_segments` pour les segments actifs
- ✅ Utilise `checkEligibility()` pour vérifier l'accès
- ✅ Crée des tickets via `createTicketFromRouletteSegment()`

### RouletteAdminSettingsScreen ✅

Écran admin pour configurer les règles.

**Fonctionnalités:**
- Activation/désactivation globale
- Configuration du cooldown (en heures)
- Configuration des limites (jour/semaine/mois)
- Configuration des horaires autorisés
- Personnalisation des messages

---

## 🔍 Vérifications Essentielles

### 1. Roulette désactivée (`isEnabled = false`)

```dart
if (!rules.isEnabled) {
  // Afficher: rules.messageDisabled
  // État: RouletteWidgetState.disabled
}
```

### 2. Aucun segment actif

```dart
if (activeSegments.isEmpty) {
  // Afficher: rules.messageUnavailable
  // État: RouletteWidgetState.unavailable
}
```

### 3. Hors horaires autorisés

```dart
if (!isWithinAllowedHours(currentHour, rules)) {
  // Afficher: "Disponible de {allowedStartHour}h à {allowedEndHour}h"
  // État: RouletteWidgetState.timeRestricted
}
```

### 4. En période de cooldown

```dart
if (hoursSinceLastSpin < rules.cooldownHours) {
  // Afficher: "Prochain tirage dans X heures"
  // État: RouletteWidgetState.cooldown
}
```

### 5. Tout OK ✅

```dart
if (allChecksPass) {
  // État: RouletteWidgetState.ready
  // Bouton "Tourner la roue" actif
}
```

---

## 📦 Intégration avec le Reward System

Après un tirage gagnant, le système crée automatiquement un ticket de récompense:

```dart
// Dans roulette_screen.dart
await _createRewardTicket(segment);

// Utilise roulette_reward_mapper.dart
final ticket = await createTicketFromRouletteSegment(
  userId: userId,
  segment: segment,
);
```

**Stockage du ticket:**
```
users/{userId}/rewardTickets/{ticketId}
  - id: string
  - userId: string
  - action: RewardAction
  - createdAt: timestamp
  - expiresAt: timestamp
  - isUsed: bool
  - usedAt: timestamp?
```

---

## 🧪 Tests de Validation

### Scénarios à tester

1. ✅ **Roulette désactivée**
   - `isEnabled = false`
   - Vérifie que le bouton est grisé
   - Vérifie l'affichage du `messageDisabled`

2. ✅ **Aucun segment actif**
   - Tous les segments ont `isActive = false`
   - Vérifie que la roue est indisponible
   - Vérifie l'affichage du `messageUnavailable`

3. ✅ **Hors horaires**
   - `allowedStartHour = 11, allowedEndHour = 22`
   - Tester à 8h du matin
   - Vérifie l'affichage du message horaire

4. ✅ **Cooldown actif**
   - `cooldownHours = 24`
   - Utilisateur a joué il y a 12h
   - Vérifie l'affichage du message de cooldown

5. ✅ **Tout fonctionnel**
   - `isEnabled = true`
   - Segments actifs présents
   - Horaires OK
   - Cooldown expiré
   - Vérifie que le bouton est actif et cliquable

---

## 🎯 Objectif Final

### ✅ Ce qui est maintenant garanti:

1. **Structure Firestore unifiée**
   - ✅ Une seule source de vérité pour les règles: `config/roulette_rules`
   - ✅ Segments stockés dans: `roulette_segments/{segmentId}`
   - ❌ Plus de collections obsolètes (`app_roulette_config`, `marketing/roulette_settings`)

2. **Configuration Admin → Impact Client Direct**
   - ✅ Changement de `isEnabled` → Roue immédiatement (dés)activée
   - ✅ Modification des horaires → Application immédiate
   - ✅ Ajout/suppression de segments → Visible instantanément
   - ✅ Messages personnalisés → Affichés côté client

3. **Firestore Propre et Cohérent**
   - ✅ Nommage des champs standardisé
   - ✅ Documentation à jour
   - ✅ Tests couvrant les cas d'usage principaux
   - ✅ Rétrocompatibilité assurée

---

## 📝 Migration des Données Existantes

Si vous avez des données dans l'ancienne structure, voici comment migrer:

### Étape 1: Exporter les données existantes

```javascript
// Firebase Console > Firestore
// Exporter app_roulette_config/main
```

### Étape 2: Créer le document de règles

```javascript
// Créer manuellement dans Firestore:
// Collection: config
// Document: roulette_rules
{
  "isEnabled": true,
  "cooldownHours": 24,
  "maxPlaysPerDay": 1,
  "allowedStartHour": 0,
  "allowedEndHour": 23,
  "weeklyLimit": 0,
  "monthlyLimit": 0,
  "messageDisabled": "La roulette est actuellement désactivée",
  "messageUnavailable": "La roulette n'est pas disponible",
  "messageCooldown": "Revenez demain pour retenter votre chance"
}
```

### Étape 3: Migrer les segments

```javascript
// Pour chaque segment dans app_roulette_config/main.segments[]
// Créer un document dans roulette_segments/{segmentId}
{
  "id": "seg_1",
  "label": "+100 points",
  "description": "Gagnez 100 points de fidélité",
  "iconName": "stars",
  "isActive": true,
  "probability": 30.0,
  "rewardType": "none",
  "rewardId": "bonus_points_100",
  "rewardValue": null,
  "productId": null,
  "weight": 30.0,
  "position": 1,
  "colorHex": "#FFD700"
}
```

### Étape 4: Supprimer les anciennes collections

```javascript
// Après vérification que tout fonctionne:
// Supprimer app_roulette_config/
// Supprimer marketing/roulette_settings (si existe)
```

---

## 🔧 Support et Dépannage

### La roue ne s'affiche pas?

1. Vérifier que `config/roulette_rules` existe
2. Vérifier que `isEnabled = true`
3. Vérifier qu'il y a des segments actifs dans `roulette_segments`

### Les messages ne s'affichent pas correctement?

1. Vérifier que les champs `messageDisabled`, `messageUnavailable`, `messageCooldown` existent dans `config/roulette_rules`
2. Vérifier que les valeurs ne sont pas vides
3. Redémarrer l'application pour recharger la config

### Les changements admin ne sont pas visibles côté client?

1. Vérifier que vous modifiez bien `config/roulette_rules` (pas l'ancienne collection)
2. Vérifier que les segments sont dans `roulette_segments` (pas dans `app_roulette_config`)
3. Les changements sont en temps réel via les streams Firestore

---

## ✨ Conclusion

Cette migration assure:
- ✅ Une structure Firestore claire et maintenable
- ✅ Une cohérence entre admin et client
- ✅ Des messages personnalisables
- ✅ Une meilleure expérience utilisateur
- ✅ Une base solide pour les évolutions futures
