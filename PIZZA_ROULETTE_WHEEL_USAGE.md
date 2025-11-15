# PizzaRouletteWheel Widget - Guide d'utilisation

## Vue d'ensemble

Le widget `PizzaRouletteWheel` est un widget Flutter custom qui affiche une roue animée de type pizza avec des segments triangulaires. Il utilise uniquement Flutter pur (CustomPainter + AnimationController) sans dépendances externes.

## Caractéristiques

- ✅ **Pure Flutter** - Pas de packages externes (pas de flutter_fortune_wheel)
- ✅ **CustomPainter** - Dessin personnalisé des segments
- ✅ **Animation fluide** - Rotation avec courbe easeOutCubic
- ✅ **Probabilités** - Sélection basée sur les probabilités des segments
- ✅ **Responsive** - S'adapte automatiquement à la taille de l'écran
- ✅ **Material 3** - Style cohérent avec le Design System Deli'Zza
- ✅ **Contrôle externe** - Méthode `spin()` accessible via GlobalKey
- ✅ **Icônes Material** - Support des icônes pour chaque segment
- ✅ **Curseur fixe** - Indicateur en haut de la roue

## Signature du Widget

```dart
class PizzaRouletteWheel extends StatefulWidget {
  final List<RouletteSegment> segments;
  final void Function(RouletteSegment result) onResult;
  final bool isSpinning; // optionnel
}
```

### Paramètres

- **segments** : Liste des segments actifs, dans l'ordre de position
- **onResult** : Callback appelé quand la roue s'arrête sur un segment
- **isSpinning** : (Optionnel) Indicateur si la roue est en rotation

## Utilisation basique

```dart
import 'package:pizza_delizza/src/widgets/pizza_roulette_wheel.dart';
import 'package:pizza_delizza/src/models/roulette_config.dart';

// Créer une clé globale pour contrôler la roue
final GlobalKey<PizzaRouletteWheelState> wheelKey = GlobalKey();

// Définir les segments
final segments = [
  RouletteSegment(
    id: 'seg1',
    label: 'Pizza offerte',
    rewardId: 'free_pizza',
    probability: 10.0,
    color: Colors.red,
    iconName: 'local_pizza',
  ),
  RouletteSegment(
    id: 'seg2',
    label: '-20%',
    rewardId: 'discount_20',
    probability: 30.0,
    color: Colors.blue,
    iconName: 'percent',
  ),
  RouletteSegment(
    id: 'seg3',
    label: 'Raté',
    rewardId: 'none',
    probability: 60.0,
    color: Colors.grey,
    iconName: 'close',
  ),
];

// Utiliser le widget
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // La roue
          SizedBox(
            width: 400,
            height: 400,
            child: PizzaRouletteWheel(
              key: wheelKey,
              segments: segments,
              onResult: (segment) {
                print('Gagnant: ${segment.label}');
                // Afficher le résultat à l'utilisateur
              },
            ),
          ),
          const SizedBox(height: 32),
          // Bouton pour lancer la roue
          ElevatedButton(
            onPressed: () {
              wheelKey.currentState?.spin();
            },
            child: const Text('Tourner la roue'),
          ),
        ],
      ),
    ),
  );
}
```

## Exemple complet avec état

```dart
class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> {
  final GlobalKey<PizzaRouletteWheelState> _wheelKey = GlobalKey();
  bool _isSpinning = false;
  RouletteSegment? _result;

  void _handleSpin() {
    if (_isSpinning) return;
    
    setState(() {
      _isSpinning = true;
      _result = null;
    });
    
    _wheelKey.currentState?.spin();
  }

  void _handleResult(RouletteSegment segment) {
    setState(() {
      _isSpinning = false;
      _result = segment;
    });
    
    // Afficher un dialogue avec le résultat
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Résultat'),
        content: Text('Vous avez gagné: ${segment.label}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roue de la chance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 350,
              height: 350,
              child: PizzaRouletteWheel(
                key: _wheelKey,
                segments: segments,
                onResult: _handleResult,
                isSpinning: _isSpinning,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isSpinning ? null : _handleSpin,
              child: Text(_isSpinning ? 'Rotation...' : 'Tourner'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Text(
                'Dernier résultat: ${_result!.label}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

## Fonctionnement interne

### 1. Dessin de la roue (CustomPainter)

La roue est dessinée avec un `CustomPainter` qui:
- Calcule l'angle de chaque segment (360° / nombre de segments)
- Dessine chaque segment comme un arc de cercle avec sa couleur
- Ajoute les labels et icônes centrés sur chaque segment
- Applique un gradient de fond et une ombre
- Dessine un contour léger entre les segments

### 2. Animation de rotation

L'animation utilise un `AnimationController` avec:
- **Durée**: 4 secondes
- **Courbe**: `Curves.easeOutCubic` (démarrage rapide, ralentissement progressif)
- **Rotations**: 3-5 tours complets + angle final pour le segment gagnant

### 3. Sélection du segment gagnant

Le segment est sélectionné selon les probabilités:

```dart
// Exemple: segments avec probabilités 50%, 30%, 20%
// Total = 100%
// Random entre 0 et 100
// Si random <= 50 : segment 1
// Si random <= 80 : segment 2
// Si random <= 100 : segment 3
```

### 4. Calcul de l'angle cible

L'angle est calculé pour que le curseur en haut pointe vers le segment gagnant:

```dart
final anglePerSegment = 2 * π / segments.length;
final segmentCenterAngle = segmentIndex * anglePerSegment + anglePerSegment / 2;
final targetAngle = (2 * π - segmentCenterAngle) % (2 * π);
```

## Personnalisation

### Couleurs des segments

Utiliser les couleurs du segment directement:

```dart
RouletteSegment(
  color: const Color(0xFFD32F2F), // Rouge
  // ou
  color: Colors.blue.shade700,
)
```

### Icônes disponibles

Les icônes Material supportées:
- `local_pizza` - Pizza
- `local_drink` - Boisson
- `cake` - Dessert
- `stars` - Étoiles/Points
- `percent` - Pourcentage
- `euro` - Euro
- `close` - Perdu
- `card_giftcard` - Cadeau

### Taille du widget

Le widget est responsive et s'adapte à la taille du conteneur parent:

```dart
// Mobile
SizedBox(
  width: 300,
  height: 300,
  child: PizzaRouletteWheel(...),
)

// Tablette
SizedBox(
  width: 500,
  height: 500,
  child: PizzaRouletteWheel(...),
)

// Web (adaptatif)
LayoutBuilder(
  builder: (context, constraints) {
    final size = constraints.maxWidth * 0.6;
    return SizedBox(
      width: size,
      height: size,
      child: PizzaRouletteWheel(...),
    );
  },
)
```

## Bonnes pratiques

### 1. Probabilités

Assurez-vous que la somme des probabilités fait 100% (ou proche):

```dart
// Bon ✅
segments = [
  RouletteSegment(probability: 50.0, ...),
  RouletteSegment(probability: 30.0, ...),
  RouletteSegment(probability: 20.0, ...),
]; // Total = 100%

// Acceptable ✅ (sera normalisé)
segments = [
  RouletteSegment(probability: 5.0, ...),
  RouletteSegment(probability: 3.0, ...),
  RouletteSegment(probability: 2.0, ...),
]; // Total = 10% (ratios respectés)
```

### 2. Nombre de segments

- **Minimum**: 2 segments
- **Optimal**: 6-8 segments (lisibilité)
- **Maximum**: 12-16 segments (au-delà, les labels deviennent illisibles)

### 3. Labels courts

Utilisez des labels courts pour qu'ils restent lisibles sur la roue:

```dart
// Bon ✅
RouletteSegment(label: 'Pizza', ...)
RouletteSegment(label: '-20%', ...)

// À éviter ❌
RouletteSegment(label: 'Une pizza margherita offerte', ...)
```

### 4. Couleurs contrastées

Alternez les couleurs claires et foncées pour une meilleure visibilité:

```dart
segments = [
  RouletteSegment(color: Colors.red, ...),      // Foncé
  RouletteSegment(color: Colors.yellow, ...),   // Clair
  RouletteSegment(color: Colors.blue, ...),     // Foncé
  RouletteSegment(color: Colors.orange, ...),   // Clair
];
```

## Limitations

- Le widget ne gère pas l'UI environnante (bouton, titre, etc.)
- Une seule roue peut tourner à la fois par clé
- L'animation ne peut pas être interrompue une fois lancée
- Les segments doivent avoir au moins une couleur et un label

## Support et intégration

Le widget s'intègre parfaitement avec:
- RouletteService pour la logique métier
- Firebase pour la persistance des configurations
- Design System Deli'Zza pour le styling
- Navigation via go_router

## Tests

Des tests unitaires et de widgets sont disponibles dans:
```
test/widgets/pizza_roulette_wheel_test.dart
```

Ils couvrent:
- Le rendu correct du widget
- La sélection probabiliste des segments
- Le callback onResult
- Le contrôle via GlobalKey
- La gestion des cas limites (segments vides, etc.)
