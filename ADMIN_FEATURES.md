# 🛠️ Guide des Fonctionnalités Admin

Ce document décrit les nouvelles fonctionnalités de gestion admin implémentées pour Pizza Deli'Zza.

---

## 📋 Vue d'ensemble

L'interface admin a été considérablement enrichie pour permettre une gestion complète de tous les types de produits et l'organisation de leur affichage dans l'application.

### Nouvelles Fonctionnalités

1. ✅ **Gestion des Boissons** - CRUD complet
2. ✅ **Gestion des Desserts** - CRUD complet
3. ✅ **Mise en avant des produits** - Système de featured products
4. ✅ **Page Builder** - Interface pour gérer l'affichage

---

## 🎯 Accès aux Fonctionnalités

### Connexion Admin

```
Email: admin@delizza.com
Password: admin123
```

### Navigation

Depuis le **Dashboard Admin** (`/admin`), vous avez accès à 6 sections :

| Section | Description | Route |
|---------|-------------|-------|
| **Pizzas** | Gérer les pizzas | `/admin/pizza` |
| **Menus** | Gérer les menus | `/admin/menu` |
| **Boissons** | Gérer les boissons | `/admin/drinks` |
| **Desserts** | Gérer les desserts | `/admin/desserts` |
| **Page Builder** | Organiser l'affichage | `/admin/page-builder` |
| **Paramètres** | À venir | - |

---

## 🍕 Gestion des Produits

### Fonctionnalités Communes (tous types)

Chaque écran de gestion propose :

#### 1. Voir la liste
- Affichage en liste avec cartes enrichies
- Image, nom, description, prix
- Badge "Mise en avant" pour les produits featured
- État vide élégant si aucun produit

#### 2. Ajouter un produit
- Bouton **"+ Nouveau [Type]"** en bas à droite
- Formulaire modal avec validation :
  - **Nom** (requis)
  - **Description** (requis)
  - **Prix** (requis, nombre positif)
  - **URL Image** (optionnel)
  - **Mise en avant** (toggle)

#### 3. Modifier un produit
- Cliquer sur une carte ou le bouton "Modifier"
- Formulaire pré-rempli avec les données actuelles
- Sauvegarde avec confirmation visuelle

#### 4. Supprimer un produit
- Bouton de suppression sur chaque carte
- Dialogue de confirmation sécurisé
- Message de succès après suppression

### Spécificités par Type

#### 🍕 Pizzas
- **Catégorie** : `Pizza`
- **Couleur** : Orange/Deep Orange
- **Icône** : `local_pizza`
- **Particularité** : Peut avoir des ingrédients de base

#### 🍽️ Menus
- **Catégorie** : `Menus`
- **Couleur** : Blue/Indigo
- **Icône** : `restaurant_menu`
- **Particularités** :
  - Compteurs pour nombre de pizzas (0-5)
  - Compteurs pour nombre de boissons (0-5)
  - Composition visible sur la carte

#### 🥤 Boissons
- **Catégorie** : `Boissons`
- **Couleur** : Cyan/Blue
- **Icône** : `local_drink`
- **Exemples** : Coca-Cola, Eau, Jus

#### 🍰 Desserts
- **Catégorie** : `Desserts`
- **Couleur** : Pink/Purple
- **Icône** : `cake`
- **Exemples** : Tiramisu, Mousse au chocolat

---

## ⭐ Système de Mise en Avant

### Qu'est-ce que la "Mise en avant" ?

Le système de "Mise en avant" permet de marquer certains produits pour qu'ils apparaissent en priorité dans l'application. C'est idéal pour :

- 🎯 Promouvoir les nouveautés
- 📢 Mettre en avant les offres spéciales
- 🔥 Valoriser les best-sellers
- 🎉 Créer des campagnes marketing

### Comment mettre un produit en avant ?

#### Méthode 1 : Depuis le formulaire d'édition

1. Ouvrir le formulaire d'ajout/modification d'un produit
2. Activer le toggle **"Mise en avant"** (étoile jaune)
3. Sauvegarder

#### Méthode 2 : Depuis le Page Builder

1. Accéder au **Page Builder** depuis le dashboard
2. Sélectionner l'onglet (Pizzas, Menus, Boissons, ou Desserts)
3. Cliquer sur l'étoile à droite du produit
4. Le changement est immédiat

### Indicateurs Visuels

Les produits mis en avant affichent un **badge jaune** avec une étoile :
```
⭐ Mise en avant
```

---

## 🎨 Page Builder

### Accès
Dashboard Admin → **Page Builder** (carte verte avec icône `dashboard_customize`)

### Fonctionnalités

#### Vue par Catégories
Le Page Builder est organisé en 4 onglets :

1. **Pizzas** 🍕
2. **Menus** 🍽️
3. **Boissons** 🥤
4. **Desserts** 🍰

#### Gestion Rapide

Pour chaque catégorie :
- **Liste triée** : Produits featured apparaissent en premier
- **Toggle rapide** : Clic sur l'étoile pour activer/désactiver
- **Aperçu complet** : Image, nom, description, prix
- **Feedback visuel** : Notifications à chaque changement

#### Cas d'usage

**Exemple : Promotion Pizza du mois**
```
1. Aller dans Page Builder → Pizzas
2. Trouver "Pizza du Chef"
3. Cliquer sur l'étoile
4. ✅ La pizza apparaît maintenant en priorité
```

**Exemple : Menu famille en vedette**
```
1. Page Builder → Menus
2. Activer "Menu Famille"
3. Le menu sera mis en avant sur l'accueil
```

---

## 💾 Stockage des Données

### Système Actuel

Les données sont stockées localement avec **SharedPreferences** :

| Clé | Contenu |
|-----|---------|
| `pizzas_list` | Liste des pizzas au format JSON |
| `menus_list` | Liste des menus au format JSON |
| `drinks_list` | Liste des boissons au format JSON |
| `desserts_list` | Liste des desserts au format JSON |

### Format JSON

```json
{
  "id": "uuid",
  "name": "Nom du produit",
  "description": "Description détaillée",
  "price": 12.50,
  "imageUrl": "https://...",
  "category": "Pizza|Menus|Boissons|Desserts",
  "isMenu": false,
  "baseIngredients": [],
  "pizzaCount": 1,
  "drinkCount": 0,
  "isFeatured": true
}
```

### Migration Future

Le système est prêt pour une migration vers Firebase/Firestore :
- Structure de données compatible
- Service CRUD facilement adaptable
- Pas de dépendance forte au stockage local

---

## 🎨 Design et UX

### Thème Visuel

Chaque catégorie a son propre thème de couleurs :

| Catégorie | Couleurs Principales | Gradient |
|-----------|---------------------|----------|
| Pizzas | Orange/Deep Orange | 🟠 → 🔴 |
| Menus | Blue/Indigo | 🔵 → 🟣 |
| Boissons | Cyan/Blue | 🔵 → 🔵 |
| Desserts | Pink/Purple | 🩷 → 🟣 |
| Page Builder | Green/Teal | 🟢 → 🔵 |

### Éléments Visuels

- **AppBar dégradé** avec icône décorative
- **Cartes avec ombre** et bordure dégradée
- **Formulaires modernes** avec coins arrondis
- **Boutons d'action** colorés et expressifs
- **États vides** informatifs et esthétiques

### Animations et Feedback

- ✅ Snackbars de confirmation
- 🎨 Transitions fluides
- 💫 Effets d'élévation (shadows)
- 🖱️ Hover states sur les cartes

---

## 🔧 Architecture Technique

### Fichiers Principaux

```
lib/src/
├── models/
│   └── product.dart                    # Modèle avec isFeatured
├── services/
│   └── product_crud_service.dart       # CRUD pour tous les types
├── screens/admin/
│   ├── admin_dashboard_screen.dart     # Dashboard principal
│   ├── admin_pizza_screen.dart         # Gestion pizzas
│   ├── admin_menu_screen.dart          # Gestion menus
│   ├── admin_drinks_screen.dart        # Gestion boissons
│   ├── admin_desserts_screen.dart      # Gestion desserts
│   └── admin_page_builder_screen.dart  # Page Builder
└── core/
    └── constants.dart                  # Routes et clés storage
```

### Service CRUD

Le `ProductCrudService` fournit :

```dart
// Pizzas
loadPizzas() → Future<List<Product>>
savePizzas(List<Product>) → Future<bool>
addPizza(Product) → Future<bool>
updatePizza(Product) → Future<bool>
deletePizza(String id) → Future<bool>

// Menus (mêmes méthodes)
// Boissons (mêmes méthodes)
// Desserts (mêmes méthodes)
```

---

## 📱 Workflow Utilisateur

### Scénario Complet : Ajouter une nouvelle boisson

1. **Connexion** → Utiliser les credentials admin
2. **Navigation** → Aller au Dashboard Admin
3. **Sélection** → Cliquer sur la carte "Boissons"
4. **Ajout** → Cliquer sur le bouton "+ Nouvelle Boisson"
5. **Remplissage** du formulaire :
   ```
   Nom: Limonade Artisanale
   Description: Faite maison avec citrons frais
   Prix: 3.50
   URL Image: https://...
   Mise en avant: ✅ Activé
   ```
6. **Sauvegarde** → Cliquer sur "Sauvegarder"
7. **Confirmation** → Message de succès
8. **Résultat** → Boisson visible dans la liste avec badge "⭐ En avant"

### Scénario : Organiser les produits vedettes

1. **Dashboard Admin** → Cliquer sur "Page Builder"
2. **Vue d'ensemble** → Voir tous les produits par catégorie
3. **Pizzas** → Mettre en avant "Margherita" et "4 Fromages"
4. **Menus** → Mettre en avant "Menu Famille"
5. **Boissons** → Mettre en avant "Coca-Cola"
6. **Desserts** → Mettre en avant "Tiramisu"
7. **Résultat** → Ces produits apparaîtront en priorité côté client

---

## 🚀 Avantages du Système

### Pour l'Admin

✅ **Interface intuitive** - Pas de courbe d'apprentissage
✅ **Gestion rapide** - CRUD complet en quelques clics
✅ **Contrôle total** - Sur tous les types de produits
✅ **Organisation facile** - Page Builder pour la mise en avant
✅ **Feedback immédiat** - Notifications à chaque action

### Pour l'Application

✅ **Flexibilité** - Modifier le catalogue à tout moment
✅ **Marketing** - Promouvoir facilement des produits
✅ **Cohérence** - Design unifié pour tous les types
✅ **Performance** - Stockage local rapide
✅ **Évolutivité** - Architecture prête pour le cloud

---

## 🔮 Évolutions Futures

### Fonctionnalités Planifiées

1. **Statistiques** 📊
   - Produits les plus consultés
   - Conversion des produits featured
   - Revenus par catégorie

2. **Gestion d'Images** 📸
   - Upload direct d'images
   - Stockage cloud (Firebase Storage)
   - Redimensionnement automatique

3. **Ordonnancement** 🔢
   - Ordre personnalisé des produits
   - Drag & drop dans le Page Builder
   - Priorités multiples

4. **Promotions** 🎁
   - Prix barrés
   - Pourcentages de réduction
   - Offres limitées dans le temps

5. **Notifications** 🔔
   - Alerter les clients des nouveautés
   - Push pour produits featured
   - Campagnes ciblées

---

## 💡 Bonnes Pratiques

### Gestion des Produits

1. **Images** : Utiliser des URLs d'images de haute qualité
2. **Descriptions** : Être précis et attractif (max 2-3 lignes)
3. **Prix** : Vérifier la cohérence des tarifs
4. **Featured** : Ne pas mettre trop de produits en avant (3-4 par catégorie max)

### Organisation

1. **Révision régulière** : Mettre à jour les produits featured chaque semaine
2. **Rotation** : Varier les produits mis en avant
3. **Saisonnalité** : Adapter selon les saisons
4. **Tests** : Vérifier l'affichage côté client après chaque modification

---

## 🆘 Dépannage

### Problème : Les produits ne s'affichent pas

**Solutions** :
1. Vérifier la connexion admin
2. Recharger la page (pull to refresh)
3. Vérifier le stockage local
4. Nettoyer le cache de l'application

### Problème : Image ne se charge pas

**Solutions** :
1. Vérifier l'URL de l'image
2. S'assurer que l'URL est accessible publiquement
3. Utiliser une URL HTTPS
4. En dernier recours : utiliser l'image placeholder

### Problème : Modifications non sauvegardées

**Solutions** :
1. Vérifier la validation du formulaire (champs requis)
2. Attendre le message de confirmation
3. Rafraîchir la liste pour voir les changements
4. Vérifier les permissions de stockage

---

## 📞 Support

Pour toute question ou problème :
1. Consulter cette documentation
2. Vérifier les autres fichiers MD du projet
3. Ouvrir une issue sur GitHub
4. Contacter l'équipe de développement

---

**Dernière mise à jour** : 11 novembre 2025  
**Version** : 1.1.0  
**Auteur** : GitHub Copilot Workspace
