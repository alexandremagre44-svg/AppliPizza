# Système de Configuration des Segments de la Roue de la Chance

## Vue d'ensemble

Ce système permet aux administrateurs de configurer les segments de la "Roue de la chance" via le Studio Builder. Il utilise Material 3 et le Design System Pizza Deli'Zza.

## Architecture

### Modèle de données

#### RewardType Enum
- `none`: Aucun gain (perdu)
- `percentageDiscount`: Réduction en pourcentage
- `fixedAmountDiscount`: Réduction en montant fixe (€)
- `freeProduct`: Produit gratuit
- `freeDrink`: Boisson gratuite

#### RouletteSegment
Champs principaux:
- `id` (String): Identifiant unique
- `label` (String): Texte affiché sur la roue
- `description` (String?, optionnel): Description du gain
- `rewardType` (RewardType): Type de gain
- `rewardValue` (double?, optionnel): Valeur numérique (pourcentage ou montant)
- `productId` (String?, optionnel): ID du produit pour free_product/free_drink
- `probability` (double): Probabilité (0-100)
- `colorHex` (String): Couleur du segment
- `iconName` (String?, optionnel): Nom de l'icône Material
- `isActive` (bool): Segment actif ou non
- `position` (int): Ordre d'affichage

### Services

#### RouletteSegmentService
Service dédié pour les opérations CRUD sur les segments individuels.

**Collection Firestore**: `roulette_segments`

Méthodes principales:
- `getAllSegments()`: Récupère tous les segments
- `getActiveSegments()`: Récupère uniquement les segments actifs
- `getSegmentById(String id)`: Récupère un segment par son ID
- `createSegment(RouletteSegment)`: Crée un nouveau segment
- `updateSegment(RouletteSegment)`: Met à jour un segment existant
- `deleteSegment(String id)`: Supprime un segment
- `watchSegments()`: Stream pour mises à jour en temps réel
- `initializeDefaultSegments()`: Initialise avec des segments par défaut

### Écrans

#### RouletteSegmentsListScreen
Écran de liste des segments avec:
- Cartes Material 3 pour chaque segment
- Aperçu de la couleur (cercle)
- Label et type de gain
- Badge de probabilité
- Switch actif/inactif
- Bouton d'édition
- Bouton flottant pour créer un nouveau segment
- Informations récapitulatives (total des probabilités)

#### RouletteSegmentEditorScreen
Formulaire d'édition/création avec:
- Champ label (obligatoire)
- Champ description (optionnel)
- Dropdown type de gain
- Champ valeur de gain (conditionnel selon le type)
- Sélecteur de produit/boisson (conditionnel)
- Champ probabilité (%)
- Sélecteur de couleur (prédéfini + personnalisé)
- Sélecteur d'icône
- Switch actif/inactif
- Bouton de sauvegarde
- Bouton de suppression (en édition)

### Intégration

Le système est intégré dans le `AdminStudioScreen` avec une nouvelle entrée:
- Icône: `Icons.casino_rounded`
- Titre: "Roue de la chance"
- Sous-titre: "Segments et configuration"

## Compatibilité

Le système maintient la **rétrocompatibilité** avec l'ancienne structure:
- Les champs legacy (`type`, `value`, `weight`) sont conservés
- La nouvelle collection `roulette_segments` est séparée de la configuration principale
- Les services existants (`RouletteService`) ne sont pas modifiés

## Design System

Tous les composants utilisent strictement:
- **AppColors**: Couleurs Material 3 Pizza Deli'Zza
- **AppSpacing**: Espacements cohérents
- **AppRadius**: Bordures arrondies
- **AppTextStyles**: Styles de texte Material 3

Couleurs prédéfinies pour les segments:
- Rouge (#D32F2F)
- Or (#FFD700)
- Teal (#4ECDC4)
- Bleu (#3498DB)
- Violet (#9B59B6)
- Gris (#95A5A6)
- Rose (#E91E63)
- Vert (#4CAF50)
- Orange (#FF9800)
- Cyan (#00BCD4)

Icônes disponibles:
- `local_pizza`: Pizza
- `local_drink`: Boisson
- `cake`: Dessert
- `stars`: Étoiles/Points
- `percent`: Pourcentage
- `euro`: Euro
- `close`: Perdu
- `card_giftcard`: Cadeau

## Utilisation

### Créer un nouveau segment

1. Aller dans Studio > "Roue de la chance"
2. Cliquer sur le bouton flottant "Nouveau segment"
3. Remplir le formulaire:
   - Label (obligatoire)
   - Description (optionnel)
   - Type de gain
   - Valeur/Produit selon le type
   - Probabilité (%)
   - Couleur
   - Icône
   - État actif/inactif
4. Cliquer sur "Sauvegarder"

### Modifier un segment

1. Dans la liste, cliquer sur une carte de segment
2. Modifier les champs souhaités
3. Cliquer sur "Sauvegarder"
4. Ou cliquer sur l'icône de suppression pour supprimer

### Activer/Désactiver un segment

Utiliser directement le switch sur la carte du segment dans la liste.

## Bonnes pratiques

1. **Probabilités**: La somme des probabilités devrait être égale à 100%
   - Un avertissement s'affiche si ce n'est pas le cas
   
2. **Segments actifs**: Seuls les segments actifs apparaissent sur la roue

3. **Couleurs contrastées**: Utilisez des couleurs suffisamment différentes pour distinguer les segments

4. **Labels courts**: Les labels doivent être lisibles sur la roue

## Exemples de segments

### Points de fidélité
- **Label**: "+100 points"
- **Type**: Aucun gain (géré par le système de fidélité)
- **Probabilité**: 30%
- **Couleur**: Or
- **Icône**: stars

### Pizza offerte
- **Label**: "Pizza offerte"
- **Type**: Produit gratuit
- **Produit**: [Sélectionner une pizza]
- **Probabilité**: 5%
- **Couleur**: Rouge
- **Icône**: local_pizza

### Réduction
- **Label**: "-10%"
- **Type**: Réduction en %
- **Valeur**: 10
- **Probabilité**: 20%
- **Couleur**: Bleu
- **Icône**: percent

### Perdu
- **Label**: "Raté !"
- **Type**: Aucun gain
- **Probabilité**: 20%
- **Couleur**: Gris
- **Icône**: close

## Structure des fichiers

```
lib/src/
├── models/
│   └── roulette_config.dart          # Extended RouletteSegment + RewardType enum
├── services/
│   └── roulette_segment_service.dart # CRUD service for segments
└── screens/admin/studio/
    ├── roulette_segments_list_screen.dart   # List screen
    └── roulette_segment_editor_screen.dart  # Editor screen
```

## Firestore Structure

### Collection: `roulette_segments`

Document structure:
```json
{
  "id": "seg_1",
  "label": "Pizza offerte",
  "description": "Une pizza gratuite",
  "rewardType": "free_product",
  "rewardValue": null,
  "productId": "pizza_margherita_id",
  "probability": 5.0,
  "colorHex": "#FF6B6B",
  "iconName": "local_pizza",
  "isActive": true,
  "position": 1,
  "rewardId": "free_pizza",
  "type": "free_pizza",
  "value": null,
  "weight": 5.0
}
```

## Notes techniques

- Utilise `flutter_colorpicker` pour le sélecteur de couleur personnalisé
- Utilise `uuid` pour générer des IDs uniques
- Les produits et boissons sont chargés depuis `FirestoreProductService`
- Validation de formulaire avec `FormKey`
- RefreshIndicator pour rafraîchir la liste
- Stream support pour mises à jour en temps réel (si nécessaire)
