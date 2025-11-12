# Correction des Zones de Tap en Mode Cuisine

## Problèmes Résolus

### 1. Zones Cliquables Trop Petites (50% + 50%)
**Problème**: Les zones de tap gauche/droite n'occupaient pas vraiment 50% de la largeur de la carte.

**Solution**: 
- Utilisation de `Row` avec deux widgets `Expanded` pour garantir une division exacte 50/50
- Remplacement de `Positioned` avec calcul de largeur par une approche plus robuste
- Ajout de `HitTestBehavior.opaque` pour assurer la détection des clics sur toute la zone

### 2. Logique d'Heure et Mise en Avant des Commandes Urgentes
**Problème**: Les commandes urgentes (proche du créneau de retrait) n'étaient pas suffisamment mises en évidence.

**Solution**:
- Calcul automatique du temps restant jusqu'au retrait
- Marquage comme "urgent" si le retrait est dans les 20 minutes (ou jusqu'à 5 minutes après)
- Indicateurs visuels pour les commandes urgentes:
  - Bordure ambre épaisse (4px)
  - Effet de lumière/glow ambre autour de la carte
  - Badge "URGENT" avec icône d'avertissement
  - Ombre portée plus prononcée

## Fonctionnement des Gestes

### Simple Clic (Tap)
- **Zone Gauche (50%)**: Change l'état vers le statut précédent
  - Exemple: "En préparation" → "En attente"
  - Retour haptique à chaque clic
  
- **Zone Droite (50%)**: Change l'état vers le statut suivant
  - Exemple: "En attente" → "En préparation"
  - Retour haptique à chaque clic

### Double Clic
- **N'importe où sur la carte**: Ouvre le popup de détail complet de la commande
- Fonctionne sur les deux zones (gauche et droite)

## Critères d'Urgence

Une commande est marquée comme **URGENTE** si:
- Elle a un créneau de retrait défini (`pickupDate` et `pickupTimeSlot`)
- Le temps jusqu'au retrait est ≤ 20 minutes
- Le temps jusqu'au retrait est ≥ -5 minutes (pour les retards légers)

## Modifications Techniques

### Fichiers Modifiés
- `lib/src/kitchen/widgets/kitchen_order_card.dart`

### Changements Principaux

#### 1. Structure des Zones de Tap
```dart
// Avant: Utilisation de Positioned avec calculs potentiellement inexacts
Positioned(
  left: 0,
  width: constraints.maxWidth * 0.5, // Peut ne pas faire exactement 50%
  ...
)

// Après: Utilisation de Row + Expanded pour garantir 50/50
Row(
  children: [
    Expanded(child: GestureDetector(...)), // Exactement 50%
    Expanded(child: GestureDetector(...)), // Exactement 50%
  ],
)
```

#### 2. Calcul de l'Urgence
```dart
// Nouveau code pour calculer les minutes jusqu'au retrait
final pickupDateTime = DateTime(...);
minutesUntilPickup = pickupDateTime.difference(DateTime.now()).inMinutes;
isUrgent = minutesUntilPickup <= 20 && minutesUntilPickup >= -5;
```

#### 3. Indicateurs Visuels d'Urgence
```dart
// Bordure ambre pour commandes urgentes
border: isUrgent 
  ? Border.all(color: Colors.amber, width: 4)
  : null,

// Effet de glow
boxShadow: isUrgent 
  ? [
      BoxShadow(
        color: Colors.amber.withOpacity(0.5),
        blurRadius: 20,
        spreadRadius: 4,
      ),
      ...
    ]
  : [...],
```

## Tests Recommandés

### Test 1: Zones de Tap 50/50
1. Lancer le mode cuisine
2. Cliquer sur le côté gauche d'une carte en attente
   - ✅ Vérifier: Aucun changement (pas de statut précédent)
3. Cliquer sur le côté droit d'une carte en attente
   - ✅ Vérifier: Passe à "En préparation"
4. Cliquer sur le côté gauche de la même carte
   - ✅ Vérifier: Retourne à "En attente"

### Test 2: Double Clic
1. Double-cliquer n'importe où sur une carte
   - ✅ Vérifier: Le popup de détail s'ouvre
2. Fermer le popup
3. Double-cliquer sur la zone gauche
   - ✅ Vérifier: Le popup s'ouvre (pas de changement d'état)
4. Double-cliquer sur la zone droite
   - ✅ Vérifier: Le popup s'ouvre (pas de changement d'état)

### Test 3: Commandes Urgentes
1. Créer une commande avec un retrait dans 15 minutes
   - ✅ Vérifier: Bordure ambre visible
   - ✅ Vérifier: Badge "URGENT" affiché
   - ✅ Vérifier: Effet de glow autour de la carte
2. Créer une commande avec un retrait dans 30 minutes
   - ✅ Vérifier: Pas d'indicateur d'urgence
3. Créer une commande avec un retrait dans 2 minutes
   - ✅ Vérifier: Indicateur d'urgence présent

### Test 4: Feedback Haptique
1. Cliquer sur la zone gauche/droite
   - ✅ Vérifier: Sensation de vibration légère (si supporté)

## Bénéfices Utilisateur

### Pour le Personnel de Cuisine
1. **Zones plus grandes**: Plus facile de cliquer, moins d'erreurs
2. **50% garanti**: Chaque zone occupe vraiment la moitié de la carte
3. **Urgence visible**: Les commandes urgentes "sautent aux yeux"
4. **Feedback immédiat**: Retour haptique à chaque action
5. **Double clic intuitif**: Ouvrir les détails sans risque de changer l'état par erreur

### Prévention des Erreurs
- Séparation claire entre les actions de changement d'état (simple clic) et de consultation (double clic)
- Zones de tap plus grandes réduisent les clics manqués
- Indicateurs d'urgence aident à prioriser le travail

## Configuration

### Seuil d'Urgence (Modifiable)
Dans `kitchen_order_card.dart`, ligne ~92:
```dart
// Changer le seuil de 20 minutes si nécessaire
isUrgent = minutesUntilPickup <= 20 && minutesUntilPickup >= -5;
```

### Couleurs d'Urgence (Modifiable)
Dans `kitchen_order_card.dart`, lignes ~107-119:
```dart
border: isUrgent 
  ? Border.all(
      color: Colors.amber, // Changer ici pour une autre couleur
      width: 4,             // Changer l'épaisseur
    )
  : null,
```

## Notes de Développement

### Pourquoi Row + Expanded?
- `Row` avec `Expanded` garantit mathématiquement une division 50/50
- Plus fiable que des calculs manuels de largeur
- Meilleure gestion des arrondis et des pixels fractionnaires

### Pourquoi HitTestBehavior.opaque?
- Assure que les zones transparentes sont bien cliquables
- Sans cela, les clics pourraient "traverser" les zones vides

### Ordre des GestureDetector
- Les deux zones (gauche/droite) ont leur propre `onTap` ET `onDoubleTap`
- Flutter gère automatiquement la distinction entre simple et double clic
- Pas de conflit car chaque zone est indépendante

## Prochaines Améliorations Possibles

1. **Mode Debug**: Ajouter des overlays semi-transparents pour visualiser les zones
2. **Personnalisation**: Permettre de configurer le ratio (ex: 40/60 au lieu de 50/50)
3. **Sons**: Ajouter des sons différents pour gauche vs droite
4. **Animation**: Ajouter une animation de "pulse" sur les commandes très urgentes (<5 min)
5. **Historique**: Enregistrer qui a cliqué et quand pour audit

## Support

Pour toute question sur ces modifications:
1. Consulter ce document
2. Vérifier le code source dans `kitchen_order_card.dart`
3. Tester avec les scénarios ci-dessus

---

**Version**: 1.1.0  
**Date**: 2025-11-12  
**Auteur**: GitHub Copilot
