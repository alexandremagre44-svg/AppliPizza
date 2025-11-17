# Refonte du Module Ingrédients - Documentation

## Vue d'ensemble

Cette refonte transforme le module des ingrédients d'un système basé sur des snapshots (FutureProvider) vers un système temps réel basé sur des streams (StreamProvider). 

## Objectifs atteints ✅

### 1. Ingrédients dynamiques depuis Firestore
- ✅ Tous les ingrédients sont récupérés depuis la collection Firestore `ingredients`
- ✅ Aucune liste statique ou locale dans le code
- ✅ Pas de cache local - données toujours à jour

### 2. Mises à jour instantanées
- ✅ Toute création/modification d'un ingrédient apparaît immédiatement
- ✅ Les écrans "Créer une pizza" et "Modifier une pizza" se mettent à jour automatiquement
- ✅ L'écran d'administration se met à jour en temps réel

### 3. Architecture propre
- ✅ Service `FirestoreIngredientService` avec toutes les méthodes CRUD
- ✅ Providers Riverpod pour la gestion d'état
- ✅ Structure par features respectée
- ✅ Code documenté et lisible

## Architecture

### Service (`firestore_ingredient_service.dart`)

```dart
abstract class FirestoreIngredientService {
  // Méthode principale - Stream temps réel (RECOMMANDÉ)
  Stream<List<Ingredient>> watchIngredients();
  Stream<List<Ingredient>> getAllIngredients(); // alias
  
  // Méthodes CRUD
  Future<bool> addIngredient(Ingredient ingredient);
  Future<bool> updateIngredient(Ingredient ingredient);
  Future<bool> deleteIngredient(String ingredientId);
  
  // Méthodes legacy (snapshots) - maintenues pour compatibilité
  Future<List<Ingredient>> loadIngredients();
  Future<List<Ingredient>> loadActiveIngredients();
  Future<List<Ingredient>> loadIngredientsByCategory(IngredientCategory category);
}
```

### Providers (`ingredient_provider.dart`)

#### Providers recommandés (Streams)

```dart
// Tous les ingrédients en temps réel
final ingredientStreamProvider = StreamProvider<List<Ingredient>>(...)

// Ingrédients actifs en temps réel (filtrés)
final activeIngredientStreamProvider = StreamProvider<List<Ingredient>>(...)
```

#### Providers dépréciés (Futures)

```dart
// ⚠️ DÉPRÉCIÉ - utilisez ingredientStreamProvider
@Deprecated('...')
final ingredientListProvider = FutureProvider<List<Ingredient>>(...)

// ⚠️ DÉPRÉCIÉ - utilisez activeIngredientStreamProvider
@Deprecated('...')
final activeIngredientListProvider = FutureProvider<List<Ingredient>>(...)
```

### Modèle (`product.dart`)

```dart
class Ingredient {
  final String id;
  final String name;
  final double extraCost;
  final IngredientCategory category;
  final bool isActive;
  final String? iconName;
  final int order;
}

enum IngredientCategory {
  fromage, viande, legume, sauce, herbe, autre
}
```

## Fichiers modifiés

### Écrans de pizza (mise à jour vers StreamProvider)

1. **`product_form_screen.dart`**
   - Écran d'édition de produit (admin)
   - Utilise `ingredientStreamProvider` pour afficher les ingrédients disponibles
   - Les modifications d'ingrédients s'affichent immédiatement

2. **`pizza_customization_modal.dart`**
   - Modal de personnalisation de pizza (client)
   - Utilise `ingredientStreamProvider`
   - Affiche instantanément les nouveaux ingrédients disponibles

3. **`elegant_pizza_customization_modal.dart`**
   - Version élégante du modal de personnalisation
   - Utilise `ingredientStreamProvider`
   - Animations fluides avec données temps réel

4. **`staff_pizza_customization_modal.dart`**
   - Modal pour le module tablette staff
   - Utilise `ingredientStreamProvider`
   - Interface adaptée tablette avec données temps réel

5. **`product_detail_screen.dart`**
   - Écran de détail produit
   - Utilise `ingredientStreamProvider`
   - Affiche les noms des ingrédients à jour

### Écrans d'administration

6. **`ingredients_admin_screen.dart`**
   - Écran principal de gestion des ingrédients
   - Utilise `ingredientStreamProvider`
   - Plus besoin de `ref.invalidate()` - mise à jour automatique
   - Tabs par catégorie avec données temps réel

7. **`ingredient_form_screen.dart`**
   - Formulaire de création/modification d'ingrédient
   - Les modifications sont immédiatement visibles dans tous les écrans

### Widgets dépréciés

8. **`ingredient_selector.dart`**
   - ⚠️ Marqué comme déprécié
   - Contient une liste statique d'ingrédients (non recommandé)
   - Ne plus utiliser pour de nouvelles fonctionnalités

## Usage

### Dans un écran de pizza

```dart
class MyPizzaScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter les ingrédients en temps réel
    final ingredientsAsync = ref.watch(ingredientStreamProvider);
    
    return ingredientsAsync.when(
      data: (ingredients) {
        // Utiliser les ingrédients
        return ListView(
          children: ingredients.map((ing) => Text(ing.name)).toList(),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Erreur: $error'),
    );
  }
}
```

### Filtrer les ingrédients actifs

```dart
// Option 1: Utiliser le provider dédié
final activeIngredientsAsync = ref.watch(activeIngredientStreamProvider);

// Option 2: Filtrer manuellement
final ingredientsAsync = ref.watch(ingredientStreamProvider);
ingredientsAsync.whenData((allIngredients) {
  final activeIngredients = allIngredients.where((ing) => ing.isActive).toList();
  // ...
});
```

### Dans l'administration

```dart
class AdminScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(ingredientServiceProvider);
    
    // Créer un ingrédient
    await service.addIngredient(newIngredient);
    // Pas besoin de ref.invalidate() - mise à jour automatique!
    
    // Modifier un ingrédient
    await service.updateIngredient(updatedIngredient);
    // Pas besoin de ref.invalidate() - mise à jour automatique!
    
    // Supprimer un ingrédient
    await service.deleteIngredient(ingredientId);
    // Pas besoin de ref.invalidate() - mise à jour automatique!
  }
}
```

## Avantages de la nouvelle architecture

### 1. Temps réel
- ✅ Aucun délai entre la modification et l'affichage
- ✅ Tous les utilisateurs voient les modifications instantanément
- ✅ Synchronisation automatique entre les écrans

### 2. Simplicité
- ✅ Plus besoin de `ref.invalidate()` ou `refresh()`
- ✅ Moins de code boilerplate
- ✅ Moins de bugs de synchronisation

### 3. Performance
- ✅ Firestore optimise les transferts de données
- ✅ Seules les modifications sont envoyées
- ✅ Connexions persistantes réutilisées

### 4. Maintenabilité
- ✅ Une seule source de vérité (Firestore)
- ✅ Architecture claire et cohérente
- ✅ Code bien documenté

## Migration depuis l'ancienne architecture

### Avant (FutureProvider)
```dart
// ❌ Ancienne méthode
final ingredientsAsync = ref.watch(activeIngredientListProvider);
// ...
await service.saveIngredient(ingredient);
ref.invalidate(activeIngredientListProvider); // Nécessaire!
```

### Après (StreamProvider)
```dart
// ✅ Nouvelle méthode
final ingredientsAsync = ref.watch(ingredientStreamProvider);
// ...
await service.saveIngredient(ingredient);
// Automatique - pas besoin de invalidate!
```

## Tests

Pour tester le système en temps réel:

1. Ouvrir l'écran de création de pizza
2. Dans un autre onglet/fenêtre, ouvrir l'admin des ingrédients
3. Créer un nouvel ingrédient
4. ✅ L'ingrédient apparaît instantanément dans l'écran de création de pizza

## Structure Firestore

### Collection `ingredients`

```json
{
  "id": "auto-generated",
  "name": "Mozzarella",
  "extraCost": 1.5,
  "category": "fromage",
  "isActive": true,
  "iconName": "restaurant",
  "order": 1
}
```

### Index requis

- `order ASC, name ASC` (pour le tri)
- `isActive, order ASC, name ASC` (pour les ingrédients actifs)
- `category, isActive, order ASC, name ASC` (pour les filtres par catégorie)

## Dépannage

### Les modifications ne s'affichent pas
- Vérifier que vous utilisez `ingredientStreamProvider` et non `ingredientListProvider`
- Vérifier la connexion Firestore
- Vérifier les règles de sécurité Firestore

### Performance lente
- Vérifier les index Firestore
- Limiter le nombre d'ingrédients affichés si nécessaire
- Utiliser `activeIngredientStreamProvider` pour filtrer côté serveur

### Erreurs de compilation
- Les providers `FutureProvider` sont dépréciés mais toujours disponibles
- Remplacer progressivement par les `StreamProvider`

## Références

- [Riverpod StreamProvider](https://riverpod.dev/docs/providers/stream_provider)
- [Firestore Streams](https://firebase.google.com/docs/firestore/query-data/listen)
- [Flutter Consumer Widget](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/Consumer-class.html)

## Prochaines étapes (optionnel)

1. Ajouter des filtres avancés (recherche, tri)
2. Implémenter la pagination pour les grandes listes
3. Ajouter des analytics sur l'utilisation des ingrédients
4. Système de suggestions d'ingrédients basé sur la pizza

---

**Date de refonte**: 2025-11-17
**Version**: 1.0.0
**Auteur**: Copilot Agent
