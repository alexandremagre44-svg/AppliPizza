# Test de l'alignement visuel-récompense de la roulette

## 🎯 Objectif

Vérifier que le segment VISUEL sur lequel la roue s'arrête correspond EXACTEMENT à la récompense appliquée.

## 🐛 Bug corrigé

**Avant:** La roue s'arrêtait visuellement sur "Raté !" mais le popup affichait "+50 points" et les points étaient crédités.

**Après:** Le segment affiché sous le curseur correspond toujours à la récompense appliquée.

## 📋 Vérification rapide avec les logs console

Les logs console suivent maintenant le flux complet. Cherchez ces marqueurs:

```
📋 [ROULETTE SCREEN] Loaded 6 active segments:
  [0] seg_1: "+100 points" (RewardType.bonusPoints, prob=30.0%)
  [1] seg_2: "Pizza offerte" (RewardType.freePizza, prob=5.0%)
  [2] seg_3: "+50 points" (RewardType.bonusPoints, prob=25.0%)
  [3] seg_4: "Raté !" (RewardType.none, prob=20.0%)
  [4] seg_5: "Boisson offerte" (RewardType.freeDrink, prob=10.0%)
  [5] seg_6: "Dessert offert" (RewardType.freeDessert, prob=10.0%)

🎯 [ROULETTE] Selected winning segment:
  - Index: 2
  - ID: seg_3
  - Label: +50 points
  - RewardType: RewardType.bonusPoints
  - RewardValue: 50.0
  - Target angle: 3.6652 rad (210.00°)

🎁 [ROULETTE SCREEN] Received result from wheel:
  - Index in segments list: 2
  - ID: seg_3
  - Label: +50 points
  - RewardType: RewardType.bonusPoints
  - RewardValue: 50.0

💰 [REWARD] Creating reward for segment: +50 points (RewardType.bonusPoints)

🔄 [MAPPER] Processing segment: seg_3 (+50 points)
  - RewardType: RewardType.bonusPoints
  - RewardValue: 50.0
  ➜ Bonus points: adding 50 points to user xxx

  ✓ Added 50 points to user: xxx
```

**✅ Vérification:** Tous les logs doivent montrer le MÊME ID de segment (seg_3) et le MÊME label (+50 points).

## 🧪 Cas de test manuels

### Test 1: Distribution normale - Plusieurs spins

**Configuration:**
- Segments par défaut avec probabilités normales
- Au moins 6 segments actifs

**Procédure:**
1. Ouvrir l'écran roulette
2. Noter le solde de points de fidélité initial
3. Cliquer sur "Tourner la roue"
4. Observer visuellement où la roue s'arrête
5. Lire le message du popup
6. Vérifier le solde de points après

**Répéter 10 fois** en vérifiant:

| Segment visuel | Popup attendu | Points ajoutés | Ticket créé |
|----------------|---------------|----------------|-------------|
| +100 points | "Félicitations ! +100 points" | +100 | Non |
| +50 points | "Félicitations ! +50 points" | +50 | Non |
| Raté ! | "Dommage..." | 0 | Non |
| Pizza offerte | "Félicitations ! Pizza gratuite" | 0 | Oui (Pizza) |
| Boisson offerte | "Félicitations ! Boisson gratuite" | 0 | Oui (Boisson) |
| Dessert offert | "Félicitations ! Dessert gratuit" | 0 | Oui (Dessert) |

**Résultat attendu:**
- ✅ Le segment visuel correspond toujours au popup
- ✅ Les points sont ajoutés correctement (ou pas)
- ✅ Les tickets sont créés correctement (ou pas)
- ✅ "Raté !" ne crée jamais de points ni de tickets

### Test 2: Forcer 100% sur un segment

**Configuration:**
1. Aller dans Firebase Console → `roulette_segments`
2. Mettre UN segment à `probability: 100`
3. Mettre TOUS les autres à `probability: 0`

**Procédure:**
1. Recharger l'écran roulette
2. Faire tourner la roue
3. Vérifier le résultat

**Répéter 5 fois**

**Résultat attendu:**
- ✅ La roue s'arrête TOUJOURS visuellement sur le segment à 100%
- ✅ Le popup affiche TOUJOURS la même récompense
- ✅ La récompense est TOUJOURS appliquée correctement

**Variantes à tester:**
- Forcer seg_1 (+100 points) à 100%
- Forcer seg_4 (Raté !) à 100%
- Forcer seg_2 (Pizza) à 100%

### Test 3: Désactiver un segment

**Configuration:**
1. Aller dans Firebase Console → `roulette_segments`
2. Mettre UN segment à `isActive: false`
3. Garder les autres à `isActive: true`

**Procédure:**
1. Recharger l'écran roulette
2. Compter les segments visibles sur la roue
3. Faire tourner la roue plusieurs fois

**Résultat attendu:**
- ✅ La roue affiche N-1 segments (un de moins)
- ✅ Le segment désactivé n'est pas visible
- ✅ Le segment désactivé n'est jamais sélectionné
- ✅ Les autres segments fonctionnent normalement

### Test 4: Validation de chaque type de segment

#### A. Segment points bonus
- **Visuel:** S'arrête sur "+50 points" ou "+100 points"
- **Popup:** "Félicitations ! +X points"
- **Vérification:** Solde de fidélité augmente de X points
- **Pas de ticket créé**

#### B. Segment "Raté !"
- **Visuel:** S'arrête sur "Raté !"
- **Popup:** "Dommage... Réessayez demain"
- **Vérification:** Aucun point ajouté, aucun ticket créé
- **Console:** Doit afficher "no ticket created"

#### C. Segment pizza gratuite
- **Visuel:** S'arrête sur "Pizza offerte"
- **Popup:** "Félicitations ! Une pizza gratuite"
- **Vérification:** Aller dans l'écran Récompenses, voir le ticket Pizza

#### D. Segment boisson gratuite
- **Visuel:** S'arrête sur "Boisson offerte"
- **Popup:** "Félicitations ! Une boisson gratuite"
- **Vérification:** Aller dans l'écran Récompenses, voir le ticket Boisson

#### E. Segment dessert gratuit
- **Visuel:** S'arrête sur "Dessert offert"
- **Popup:** "Félicitations ! Un dessert gratuit"
- **Vérification:** Aller dans l'écran Récompenses, voir le ticket Dessert

## 🔍 Vérification dans Firestore

Après les spins, vérifier dans Firestore:

### Collection `user_roulette_spins`
- ✅ Un document créé pour chaque spin
- ✅ `segmentId` correspond au segment visuel
- ✅ `resultType` correspond au type de récompense
- ✅ `timestamp` est correct

### Collection `reward_tickets`
- ✅ Tickets créés pour les segments de produits gratuits
- ✅ PAS de tickets pour les segments "Raté !"
- ✅ PAS de tickets pour les points bonus (ajoutés directement)
- ✅ `source` = "roulette"

### Collection `loyalty_accounts`
- ✅ Le solde augmente pour les segments bonus_points
- ✅ PAS d'augmentation pour les segments "Raté !"
- ✅ Le journal des transactions montre la source "roulette"

## ⚠️ Critères de succès

Le fix est réussi si:
1. ✅ Le segment visuel correspond TOUJOURS à la récompense
2. ✅ Les logs console montrent le même segment du début à la fin
3. ✅ Les points sont ajoutés/non ajoutés correctement
4. ✅ Les tickets sont créés/non créés correctement
5. ✅ Tous les cas de test passent
6. ✅ Aucun crash ni erreur

## 🐛 Signaler un problème

Si vous trouvez un décalage:
1. Copier la sortie complète de la console
2. Faire une capture d'écran de la roue arrêtée
3. Faire une capture d'écran du popup
4. Noter la configuration des segments dans Firestore
5. Signaler avec toutes ces informations

Inclure ces détails:
- Sur quel segment la roue s'est-elle arrêtée visuellement?
- Qu'affichait le popup?
- Quelle récompense a été réellement appliquée?
- Que montrent les logs console?
- Configuration des segments (IDs, labels, positions, probabilités)

## 📐 Détails techniques

### Correction appliquée

Le calcul d'angle dans `_calculateTargetAngle` prend maintenant en compte l'offset de `-π/2` utilisé pour dessiner les segments.

**Avant (incorrect):**
```dart
final segmentCenterAngle = segmentIndex * anglePerSegment + anglePerSegment / 2;
final targetAngle = (2 * math.pi - segmentCenterAngle) % (2 * math.pi);
```

**Après (correct):**
```dart
// Les segments sont dessinés en commençant à -π/2 (position haute)
final segmentCenterAngle = segmentIndex * anglePerSegment - math.pi / 2 + anglePerSegment / 2;
// Le curseur est en haut (angle = -π/2)
final targetAngle = (-math.pi / 2 - segmentCenterAngle) % (2 * math.pi);
```

### Vérification mathématique

Pour une roue à 6 segments, tous les segments s'alignent maintenant parfaitement à 270° (position du curseur):

| Segment | Centre dessin | Rotation cible | Position finale | Aligné? |
|---------|---------------|----------------|-----------------|---------|
| 0 | -60° | 330° | 270° | ✅ |
| 1 | 0° | 270° | 270° | ✅ |
| 2 | 60° | 210° | 270° | ✅ |
| 3 | 120° | 150° | 270° | ✅ |
| 4 | 180° | 90° | 270° | ✅ |
| 5 | 240° | 30° | 270° | ✅ |

### Architecture garantie

Le système applique maintenant ces garanties:

1. **UNE seule liste** de segments chargée de Firestore (ordonnée par `position`)
2. **UN seul index** gagnant sélectionné (basé sur les probabilités)
3. **CE MÊME segment** utilisé pour:
   - L'animation visuelle
   - La création de la récompense
   - L'enregistrement dans Firestore

**AUCUNE** re-tri, modification ou recalcul de liste entre la sélection et la récompense.

Le même objet `RouletteSegment` circule dans tout le processus, garantissant l'alignement parfait.
