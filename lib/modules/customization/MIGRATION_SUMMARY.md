# Customization Module - Migration Summary

## Overview
Ce document résume la copie du code de personnalisation vers le module white-label.

## Structure du Module

```
lib/modules/customization/
  data/
    models/
      ├── customization_option.dart       # Ingredient + IngredientCategory
      └── customization_group.dart        # CustomizationGroup
    services/
      └── customization_service.dart      # Service Firestore + Mock
    providers/
      └── customization_providers.dart    # Providers Riverpod
  presentation/
    widgets/
      ├── pizza_customization_widget.dart      # 739 lignes
      ├── menu_customization_widget.dart       # 725 lignes
      ├── ingredient_selector_widget.dart      # 364 lignes
      ├── customization_option_tile.dart       # Composant option
      └── customization_group_section.dart     # Composant groupe
    pages/
      └── customization_page.dart         # TODO placeholder
```

## Code Source Original

Tous les fichiers copiés proviennent de :
- `lib/src/models/product.dart` (Ingredient, IngredientCategory)
- `lib/src/services/firestore_ingredient_service.dart`
- `lib/src/providers/ingredient_provider.dart`
- `lib/src/screens/home/pizza_customization_modal.dart`
- `lib/src/screens/menu/menu_customization_modal.dart`
- `lib/src/widgets/ingredient_selector.dart`

## Fonctionnalités Copiées

### Models
- **Ingredient**: Représente un ingrédient avec coût supplémentaire, catégorie, état actif
- **IngredientCategory**: Enum pour catégoriser les ingrédients (fromages, viandes, légumes, sauces, herbes)
- **CustomizationGroup**: Groupe d'options de personnalisation avec règles min/max

### Services
- Chargement des ingrédients depuis Firestore
- Stream en temps réel pour mise à jour automatique
- Filtrage par catégorie et état actif
- CRUD complet (Create, Read, Update, Delete)
- Implémentations réelle (Firebase) et mock

### Providers
- `customizationServiceProvider`: Service principal
- `ingredientStreamProvider`: Stream temps réel de tous les ingrédients
- `activeIngredientStreamProvider`: Stream des ingrédients actifs uniquement
- `ingredientsByCategoryProvider`: Filtre par catégorie

### Widgets
- **Pizza Customization**: Modal complet pour personnaliser une pizza
  - Sélection taille (Moyenne/Grande)
  - Retrait d'ingrédients de base
  - Ajout de suppléments par catégorie
  - Instructions spéciales
  - Calcul prix en temps réel
  
- **Menu Customization**: Modal pour composer un menu
  - Sélection pizzas selon menu
  - Sélection boissons selon menu
  - Validation complétude sélection
  
- **Ingredient Selector**: Widget réutilisable (déprécié)
  - Liste d'ingrédients avec checkboxes
  - Ajout manuel d'ingrédients

## État Actuel

### ✅ Complété
- Structure de dossiers créée
- Models copiés et typés
- Services copiés avec Firebase + Mock
- Providers Riverpod copiés
- Widgets principaux copiés (2030+ lignes)
- Composants UI créés (option tile, group section)

### ⚠️ Important
- **Code NON connecté** à l'application
- **Imports** pointent toujours vers lib/src/ (intentionnel)
- **Code original** reste la source active
- **Aucune modification** du code existant
- **App fonctionne** exactement comme avant

### 📋 TODO Futur
- Adapter les imports vers le module interne
- Créer les modèles manquants (Product, CartItem) dans le module
- Implémenter customization_page.dart
- Tests unitaires pour le module
- Migration progressive depuis lib/src/

## Dépendances Externes

Les fichiers copiés dépendent encore de :
- `../../models/product.dart` - Pour Product, CartItem
- `../../providers/cart_provider.dart` - Pour ajout au panier
- `../../design_system/app_theme.dart` - Pour le design system
- `package:flutter_riverpod` - Provider state management
- `package:uuid` - Génération d'IDs
- `package:cloud_firestore` - Base de données Firebase

## Statistiques

- **Fichiers copiés**: 10 fichiers
- **Lignes de code**: ~3500 lignes
- **Commits**: 2 commits (d11c4fe, 22e61b9)
- **Modification code existant**: 0 fichiers
- **Tests ajoutés**: 0 (TODO futur)

## Notes de Migration

1. **Phase actuelle**: Copie miroir du code existant
2. **Prochaine phase**: Adaptation des imports et création des modèles manquants
3. **Phase finale**: Migration progressive et activation du module
4. **Rollback**: Simple suppression du dossier lib/modules/

## Contact

Pour questions sur cette migration :
- Voir les commits: d11c4fe, 22e61b9
- README principal du module
- Documentation TODO dans chaque fichier
