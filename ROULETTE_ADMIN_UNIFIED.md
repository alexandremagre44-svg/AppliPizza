# Roulette Admin - Configuration Unifiée

## 📋 Vue d'ensemble

La configuration de la roulette a été **complètement unifiée** pour garantir son bon fonctionnement côté client.

## 🏗️ Architecture

### Écrans Admin (2 écrans unifiés)

1. **Roue de la chance** (`roulette_segments_list_screen.dart`)
   - Gestion des segments de la roulette
   - Création, modification, suppression des segments
   - Activation/désactivation des segments
   - Probabilités et récompenses

2. **Paramètres de la roulette** (`roulette_admin_settings_screen.dart`) ⭐ NOUVEAU
   - Configuration globale (enabled/disabled)
   - Cooldown entre utilisations (en minutes)
   - Limites d'utilisation (jour/semaine/mois)
   - Plages horaires autorisées (début-fin)

### Services

- **RouletteRulesService** → Gestion des règles et configuration
- **RouletteSegmentService** → Gestion des segments
- **RouletteService** → Gestion des spins utilisateur

### Modèles

- **RouletteRules** → Configuration des règles
- **RouletteSegment** → Définition d'un segment
- **RouletteStatus** → Statut d'éligibilité

## 🗄️ Structure Firestore

### Collection: `config`

**Document: `roulette_rules`**

```json
{
  "enabled": true,
  "minDelayHours": 24,
  "dailyLimit": 1,
  "weeklyLimit": 0,
  "monthlyLimit": 0,
  "allowedStartHour": 9,
  "allowedEndHour": 22
}
```

### Collection: `roulette_segments`

**Document: `[segment_id]`**

```json
{
  "id": "seg_1",
  "label": "+100 points",
  "rewardId": "bonus_points_100",
  "probability": 30.0,
  "color": "#FFD700",
  "description": "Gagnez 100 points de fidélité",
  "rewardType": "none",
  "iconName": "stars",
  "isActive": true,
  "position": 1,
  "type": "bonus_points",
  "value": 100,
  "weight": 30.0
}
```

## ✅ Supprimés (ancienne logique)

- ❌ `roulette_settings_screen.dart` (ancien)
- ❌ `roulette_rules_admin_screen.dart` (fusionné)
- ❌ `roulette_settings.dart` (modèle obsolète)
- ❌ `roulette_settings_service.dart` (service obsolète)
- ❌ Collection `marketing/roulette_settings` (obsolète)

## 🔄 Flux de fonctionnement

### Côté Admin

1. Admin configure les segments dans "Roue de la chance"
2. Admin configure les règles dans "Paramètres de la roulette"
3. Les données sont sauvegardées dans:
   - `config/roulette_rules` pour les règles
   - `roulette_segments` pour les segments

### Côté Client

1. L'utilisateur accède à la page d'accueil
2. Le widget `_buildRouletteBanner()` vérifie:
   - Si `enabled = true` dans `config/roulette_rules`
   - Si l'heure actuelle est dans la plage autorisée
3. Si toutes les conditions sont OK → bannière affichée
4. L'utilisateur clique sur "Jouer"
5. `RouletteRulesService.checkEligibility()` vérifie:
   - Roulette activée
   - Plage horaire OK
   - Cooldown respecté
   - Limites journalières/hebdomadaires/mensuelles
6. Si éligible → la roue tourne
7. Résultat enregistré dans `user_roulette_spins`

## 🎯 Tests à effectuer

- [ ] Segments actifs → roulette visible côté client
- [ ] Segments inactifs → "Roulette non disponible"
- [ ] `enabled = false` → bannière masquée
- [ ] Cooldown respecté (ex: 1440 min = 24h)
- [ ] Limite journalière respectée (ex: 1 spin/jour)
- [ ] Plages horaires respectées (ex: 9h-22h)
- [ ] Création de ticket reward fonctionne

## 📝 Notes importantes

1. **Cooldown** : Stocké en heures dans Firestore (`minDelayHours`) mais affiché en minutes dans l'admin
2. **Limites** : 0 = illimité
3. **Horaires** : Format 24h (0-23)
4. **Segments** : Au moins 1 segment actif requis pour que la roulette fonctionne

## 🔒 Contraintes respectées

✅ Aucune modification des écrans client (sauf home_screen pour utiliser le nouveau service)  
✅ Aucune modification du système de rewards  
✅ Travail uniquement dans admin/studio et services roulette  
✅ Pas de changement dans fidélité, catalogue, menu, caisse, panier  
✅ Design système inchangé
