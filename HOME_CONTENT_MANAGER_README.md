# Module de Gestion du Contenu d'Accueil (HomeContentManager)

## 📋 Vue d'ensemble

Le **HomeContentManager** est un module PRO complet pour gérer dynamiquement le contenu de la page d'accueil de l'application Pizza Deli'Zza. Il offre une expérience similaire à Shopify, Webflow, ou UberEats pour organiser et personnaliser l'affichage des produits et sections.

## ✨ Fonctionnalités

### 1️⃣ Layout Général
- **Réorganisation des sections** : Glisser-déposer pour modifier l'ordre d'affichage des sections (Hero, Bannières, Produits mis en avant, etc.)
- **Activation/désactivation** : Contrôle de la visibilité de chaque section
- **Prévisualisation en temps réel** : Les modifications sont visibles immédiatement

### 2️⃣ Gestion des Catégories
- **Afficher/masquer** : Contrôle de la visibilité des catégories sur la page d'accueil
- **Réordonnancement** : Drag & drop pour modifier l'ordre d'affichage
- **Indépendance du menu** : Les modifications n'affectent pas le menu principal

### 3️⃣ Produits Mis en Avant
- **Sélection multiple** : Choisissez les produits à mettre en avant
- **Types d'affichage** : 
  - Carrousel (défilement horizontal)
  - Hero (grande image vedette)
  - Cartes horizontales (liste)
- **Position** : Avant ou après les catégories
- **Auto-remplissage** : Remplissage automatique avec les produits featured si vide

### 4️⃣ Sections Personnalisées
- **Création de sections thématiques** : Ex: "Top ventes", "Nouveautés", "Été 2025"
- **Champs configurables** :
  - Titre et sous-titre
  - Type d'affichage (carrousel, grille, grande bannière)
  - Mode de contenu (manuel ou automatique)
- **Mode manuel** : Sélection manuelle des produits
- **Mode automatique** : Tri selon critères (best-seller, prix, nouveauté, promo)
- **Drag & drop** : Réorganisation facile de l'ordre des sections

### 5️⃣ Gestion Fine des Produits (Future)
- **Réordonnancement par catégorie** : Modifier l'ordre des produits dans chaque catégorie
- **Épinglage** : Mettre en avant certains produits en haut de catégorie
- **Visibilité sélective** : Masquer certains produits sur l'accueil sans les supprimer

## 🗂️ Structure des Collections Firestore

### `home_custom_sections`
Stocke les sections personnalisées créées par l'admin.

```typescript
{
  id: string,
  title: string,
  subtitle?: string,
  displayType: 'carousel' | 'grid' | 'large-banner',
  contentMode: 'manual' | 'auto',
  autoSortType?: 'best-seller' | 'price' | 'newest' | 'promo',
  productIds: string[],
  backgroundColor?: string,
  isActive: boolean,
  order: number,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### `config/home_featured_products`
Configuration des produits mis en avant.

```typescript
{
  id: 'home_featured_products',
  isActive: boolean,
  productIds: string[],
  displayType: 'carousel' | 'hero' | 'horizontal-cards',
  position: 'before' | 'after',
  autoFill: boolean,
  title?: string,
  subtitle?: string,
  updatedAt: timestamp
}
```

### `home_category_overrides`
Contrôle l'affichage et l'ordre des catégories.

```typescript
{
  categoryId: string, // 'Pizza', 'Menus', 'Boissons', 'Desserts'
  isVisibleOnHome: boolean,
  order: number,
  updatedAt: timestamp
}
```

### `home_product_overrides`
Gestion fine des produits par catégorie (future implémentation complète).

```typescript
{
  productId: string,
  categoryId: string,
  isVisibleOnHome: boolean,
  isPinned: boolean,
  order: number,
  updatedAt: timestamp
}
```

## 🔐 Règles Firestore

Les règles Firestore ont été ajoutées au fichier `firebase/firestore.rules`. Elles suivent le principe :
- **Lecture publique** : Tous les utilisateurs (même non authentifiés) peuvent lire les configurations
- **Écriture admin** : Seuls les administrateurs peuvent modifier les configurations
- **Validation stricte** : Les données sont validées côté serveur

### Déploiement des règles

Pour déployer les nouvelles règles Firestore :

```bash
# Depuis le répertoire racine du projet
firebase deploy --only firestore:rules
```

⚠️ **Important** : Les règles ont été ajoutées de manière non-destructive. Elles s'intègrent avec les règles existantes.

## 🎨 Architecture des Fichiers

```
lib/src/studio/content/
├── models/
│   ├── content_section_model.dart       # Modèle sections personnalisées
│   ├── featured_products_model.dart     # Modèle produits mis en avant
│   ├── category_override_model.dart     # Modèle gestion catégories
│   └── product_override_model.dart      # Modèle gestion produits
├── services/
│   ├── content_section_service.dart     # Service CRUD sections
│   ├── featured_products_service.dart   # Service produits vedettes
│   ├── category_override_service.dart   # Service catégories
│   └── product_override_service.dart    # Service produits
├── providers/
│   └── content_providers.dart           # Providers Riverpod
├── widgets/
│   ├── content_section_layout_editor.dart    # Éditeur layout
│   ├── content_category_manager.dart         # Gestion catégories
│   ├── content_featured_products.dart        # Produits vedettes
│   ├── content_custom_sections.dart          # Sections custom
│   └── content_product_reorder.dart          # Réordonnancement (placeholder)
└── screens/
    └── studio_content_screen.dart       # Écran principal avec tabs

lib/src/screens/home/
├── home_screen.dart                     # HomeScreen modifié
└── home_content_helper.dart             # Helper pour rendu client
```

## 📱 Accès dans Studio V2

1. Connectez-vous en tant qu'admin
2. Accédez au **Studio V2**
3. Dans le menu de gauche, section **MODULES**
4. Cliquez sur **📦 Contenu d'accueil**

Vous accédez alors à 4 onglets :
- **Layout général** : Organisation des sections
- **Catégories** : Gestion des catégories
- **Produits mis en avant** : Configuration des produits vedettes
- **Sections personnalisées** : Création de sections thématiques

## 🔄 Comportement Fallback

Le module est conçu pour ne jamais casser l'existant :

1. **Si les collections n'existent pas** → Comportement par défaut (actuel)
2. **Si une configuration est manquante** → Valeurs par défaut utilisées
3. **Si un produit référencé n'existe plus** → Ignoré silencieusement
4. **Si une section est désactivée** → Non affichée sur l'accueil

## 🚀 Guide d'utilisation rapide

### Créer une section "Top Ventes"

1. Allez dans **Studio V2 > Contenu d'accueil > Sections personnalisées**
2. Cliquez sur **Nouvelle section**
3. Remplissez :
   - Titre : "🔥 Top Ventes"
   - Sous-titre : "Les pizzas les plus commandées"
   - Type d'affichage : Carrousel
   - Mode de contenu : Automatique
   - Tri automatique : Meilleures ventes
4. Cliquez sur **Confirmer**
5. La section apparaît immédiatement sur la page d'accueil

### Mettre en avant 3 produits spécifiques

1. Allez dans **Studio V2 > Contenu d'accueil > Produits mis en avant**
2. Configurez :
   - Activé : ON
   - Type d'affichage : Carrousel
   - Position : Avant les catégories
3. Cliquez sur **Ajouter** pour sélectionner les produits
4. Cochez les 3 produits souhaités
5. Cliquez sur **Confirmer** puis **Sauvegarder la configuration**

### Masquer une catégorie

1. Allez dans **Studio V2 > Contenu d'accueil > Catégories**
2. Trouvez la catégorie à masquer (ex: Desserts)
3. Désactivez l'interrupteur
4. Cliquez sur **Sauvegarder les catégories**
5. La catégorie disparaît de la page d'accueil (mais reste dans le menu)

## ⚠️ Points d'attention

### Ce qui N'EST PAS impacté
- ✅ Les produits existants
- ✅ Le menu principal
- ✅ Les commandes
- ✅ La caisse
- ✅ Les autres modules Studio (Hero, Bannières, Popups, Textes)
- ✅ La roulette
- ✅ Le système de fidélité

### Limitations actuelles
- Le réordonnancement des produits au sein d'une catégorie est prévu mais non implémenté
- L'épinglage de produits individuels est prévu mais non implémenté
- La prévisualisation temps réel dans Studio est limitée (utilise le preview panel existant)

## 🐛 Dépannage

### La section ne s'affiche pas
- Vérifiez que la section est **active** (interrupteur ON)
- Vérifiez que des **produits sont sélectionnés** (mode manuel) ou disponibles (mode auto)
- Vérifiez que les **règles Firestore sont déployées**

### Les produits ne s'affichent pas
- Vérifiez que les produits sélectionnés sont **actifs** dans la base
- Vérifiez que les IDs des produits sont **corrects**
- Consultez la console du navigateur pour les erreurs éventuelles

### Erreur de permissions
- Vérifiez que vous êtes connecté en tant qu'**admin**
- Vérifiez que les **règles Firestore sont bien déployées**

## 📚 Ressources techniques

### Providers Riverpod disponibles
```dart
customSectionsProvider          // Stream<List<ContentSection>>
featuredProductsProvider        // Stream<FeaturedProductsConfig>
categoryOverridesProvider       // Stream<List<CategoryOverride>>
productOverridesProvider        // Stream<List<ProductOverride>>
```

### Services disponibles
```dart
ContentSectionService()
FeaturedProductsService()
CategoryOverrideService()
ProductOverrideService()
```

## 🎯 Prochaines étapes (optionnelles)

1. **Prévisualisation avancée** : Améliorer le preview panel pour montrer les changements en temps réel
2. **Drag & drop produits** : Implémenter complètement le réordonnancement des produits par catégorie
3. **Analytics** : Ajouter des statistiques d'affichage par section
4. **A/B Testing** : Permettre de tester plusieurs layouts
5. **Planification** : Programmer l'activation/désactivation de sections

## 💡 Support

Pour toute question ou problème, consultez :
- Les logs dans la console du navigateur
- Les logs Firestore dans la console Firebase
- Le code source dans `lib/src/studio/content/`

---

**Version** : 1.0  
**Date** : 2025-11-21  
**Auteur** : GitHub Copilot pour Pizza Deli'Zza
