# Guide de test pour l'offset visuel de la roulette

## 🎯 Objectif

Trouver la bonne valeur d'offset visuel pour aligner parfaitement le segment 0 sous l'aiguille au démarrage de la roulette.

## 🔧 Modification appliquée

Le code a été modifié dans `lib/src/widgets/pizza_roulette_wheel.dart` pour ajouter un offset visuel constant au painter.

### Changement dans la classe `_WheelPainter`

**Ajout de la constante `_visualOffset`:**
```dart
// Visual offset to align the wheel correctly with the needle
// This constant adjusts the initial drawing position of segments
// 
// TEST VALUES (uncomment the one that aligns segment 0 under the needle):
// static const double _visualOffset = math.pi / 6;      // +π/6 ≈ +30°
static const double _visualOffset = -math.pi / 6;     // -π/6 ≈ -30°
// static const double _visualOffset = math.pi / 3;      // +π/3 ≈ +60°
// static const double _visualOffset = -math.pi / 3;     // -π/3 ≈ -60°
```

**Modification de la ligne de calcul startAngle (ligne 344):**
```dart
// AVANT:
final startAngle = (i * anglePerSegment - math.pi / 2) + anglePerSegment;

// APRÈS:
final startAngle = i * anglePerSegment - math.pi / 2 + _visualOffset;
```

## 📋 Procédure de test

### Étape 1: Premier test avec -π/6 (valeur actuelle)

1. Lancer l'application Flutter:
   ```bash
   flutter run
   ```

2. Naviguer vers l'écran de la roulette

3. **SANS FAIRE TOURNER LA ROUE**, observer la position initiale:
   - Le segment 0 (premier segment) doit être aligné sous l'aiguille rouge en haut
   - L'aiguille doit pointer vers le centre du segment 0

4. Noter le résultat:
   - ✅ Parfaitement aligné → **Garder -π/6**
   - ❌ Décalé vers la gauche → Essayer une valeur positive (+π/6 ou +π/3)
   - ❌ Décalé vers la droite → Essayer une valeur négative plus grande (-π/3)

### Étape 2: Test des autres valeurs si nécessaire

Si -π/6 n'est pas parfait, tester les autres valeurs:

#### Pour tester +π/6:
1. Ouvrir `lib/src/widgets/pizza_roulette_wheel.dart`
2. Commenter la ligne actuelle et décommenter +π/6:
   ```dart
   static const double _visualOffset = math.pi / 6;      // +π/6 ≈ +30°
   // static const double _visualOffset = -math.pi / 6;     // -π/6 ≈ -30°
   ```
3. Sauvegarder et hot reload (appuyer sur `r` dans le terminal Flutter)
4. Observer l'alignement

#### Pour tester +π/3:
1. Commenter les autres et décommenter +π/3:
   ```dart
   static const double _visualOffset = math.pi / 3;      // +π/3 ≈ +60°
   ```
2. Hot reload et observer

#### Pour tester -π/3:
1. Commenter les autres et décommenter -π/3:
   ```dart
   static const double _visualOffset = -math.pi / 3;     // -π/3 ≈ -60°
   ```
2. Hot reload et observer

### Étape 3: Vérification avec rotation

Une fois la bonne valeur trouvée:

1. Faire tourner la roue plusieurs fois
2. Vérifier que:
   - ✅ La roue s'arrête toujours sur le bon segment
   - ✅ La récompense affichée correspond au segment visuel
   - ✅ Les points/tickets sont correctement appliqués
   - ✅ Les logs console montrent une cohérence complète

### Étape 4: Nettoyage final

Une fois la bonne valeur identifiée:

1. Supprimer les lignes commentées des autres valeurs
2. Garder seulement:
   ```dart
   // Visual offset to align the wheel correctly with the needle
   static const double _visualOffset = [VALEUR_CORRECTE];
   ```

## 🎨 Aide visuelle

```
Position de l'aiguille (fixe en haut):
           ▼
       ┌───▼───┐
       │ SEG 0 │  ← Ce segment doit être centré sous l'aiguille
       │       │
  ┌────┼───────┼────┐
  │SEG5│       │SEG1│
  │    │ ROUE  │    │
  │    │       │    │
  └────┼───────┼────┘
       │       │
       │SEG2-4 │
       └───────┘

Décalage visuel:
- Offset négatif (-π/6, -π/3) → Rotation horaire
- Offset positif (+π/6, +π/3) → Rotation anti-horaire
```

## ✅ Critères de succès

La bonne valeur d'offset est trouvée quand:

1. **Au repos (sans tourner):**
   - Le segment 0 est parfaitement centré sous l'aiguille
   - Les bords du segment 0 sont symétriques par rapport à l'aiguille

2. **Après rotation:**
   - La récompense sélectionnée correspond au segment visuel
   - Les logs console montrent le même segment du début à la fin
   - Les points/tickets sont correctement appliqués

3. **Pour tous les segments:**
   - Chaque segment peut être gagné
   - L'alignement est parfait pour tous les segments

## 📊 Tableau de test

| Valeur offset | Angle | Alignement segment 0 | Récompenses correctes | Garder? |
|--------------|-------|---------------------|----------------------|---------|
| -π/6         | -30°  | ⬜ À tester         | ⬜ À tester          | ⬜      |
| +π/6         | +30°  | ⬜ À tester         | ⬜ À tester          | ⬜      |
| +π/3         | +60°  | ⬜ À tester         | ⬜ À tester          | ⬜      |
| -π/3         | -60°  | ⬜ À tester         | ⬜ À tester          | ⬜      |

Cocher ✅ pour la valeur qui donne le meilleur alignement.

## 🔍 Logs à surveiller

Les logs console doivent montrer:

```
📋 [ROULETTE SCREEN] Loaded N active segments:
  [0] seg_xxx: "Label du segment 0" (...)
  [1] seg_yyy: "Label du segment 1" (...)
  ...

🎯 [ROULETTE] Selected winning segment:
  - Index: X
  - ID: seg_xxx
  - Label: [MÊME QUE LE SEGMENT VISUEL]
```

Le segment affiché visuellement DOIT correspondre au segment dans les logs.

## ⚠️ Important

Cette modification est **UNIQUEMENT visuelle**. Elle n'affecte PAS:
- ❌ La logique de sélection des récompenses
- ❌ Les probabilités des segments
- ❌ Le calcul de l'angle cible dans `_calculateTargetAngle`
- ❌ L'animation de rotation

Elle affecte SEULEMENT:
- ✅ L'orientation initiale du dessin de la roue
- ✅ La position visuelle des segments au repos

## 🐛 En cas de problème

Si aucune des 4 valeurs ne donne un alignement parfait:

1. Vérifier la configuration des segments dans Firestore:
   - Les segments doivent être ordonnés par `position: 0, 1, 2, ...`
   - Tous les segments actifs doivent avoir `isActive: true`

2. Vérifier le nombre de segments:
   - La formule suppose un nombre quelconque de segments >= 3
   - Plus il y a de segments, plus l'offset nécessaire peut être fin

3. Vérifier la cohérence:
   - S'assurer que les logs montrent les segments dans le bon ordre
   - Le segment 0 dans les logs doit être le premier segment visuel

## 📝 Notes

- Le hot reload Flutter (`r`) permet de tester rapidement différentes valeurs
- Pas besoin de redémarrer l'application complète
- Si vous utilisez un émulateur/simulateur, prenez des captures d'écran pour comparer
- La valeur finale sera commitée dans le code après validation
