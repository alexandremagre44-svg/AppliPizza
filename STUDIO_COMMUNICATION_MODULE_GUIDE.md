# Guide des Modules Studio et Communication - Pizza Deli'Zza

## Vue d'ensemble

Ce document décrit les nouveaux modules **Studio** et **Communication** ajoutés à l'interface d'administration de Pizza Deli'Zza. Ces modules permettent de personnaliser l'application et de gérer les communications marketing sans intervention technique.

## Architecture de l'Admin

L'administration est maintenant organisée en 3 grandes sections :

### 1. Opérations
Gestion quotidienne de la pizzeria :
- **Commandes** : Gestion des commandes clients
- **Cuisine** : Mode cuisine pour la préparation
- **Produits** : Pizzas, Menus, Boissons, Desserts

### 2. Communication
Marketing et relation client :
- **Mailing** : Campagnes email et newsletters
- **Promotions** : Gestion centralisée des offres promotionnelles
- **Fidélité & Segments** : Programme de fidélité et segmentation client

### 3. Studio
Configuration et personnalisation de l'app :
- **Page d'accueil** : Bannières et blocs de contenu
- **Popups & Roulette** : Éléments interactifs
- **Textes & Messages** : Personnalisation des messages
- **Mise en avant** : Tags et mise en avant produits

---

## Module Studio

### 1. Page d'accueil (Home Configuration)

**Route** : `/admin/studio/home-config`

**Fonctionnalités** :
- **Bannière Hero** : Grande bannière principale avec image, titre, sous-titre et bouton CTA
- **Bandeau Promo** : Bandeau texte avec période d'affichage
- **Blocs Dynamiques** : Sections configurables (Spécialités du Chef, Produits Phares, etc.)

**Modèle** : `HomeConfig`
```dart
- HeroConfig (bannière principale)
- PromoBannerConfig (bandeau promo)
- List<ContentBlock> (blocs de contenu)
```

**Service** : `HomeConfigService`
- CRUD complet sur Firestore
- Collection : `app_home_config`
- Stream pour mises à jour temps réel

### 2. Popups & Roulette

**Route** : `/admin/studio/popups-roulette`

**Onglet Popups** :
- Types : promo, info, fidelite, systeme
- Conditions d'affichage : always, oncePerSession, oncePerDay, onceEver
- Ciblage : tous, nouveaux, fidèles, gold
- Période de validité

**Onglet Roulette** :
- Activation/désactivation
- Délai d'apparition
- Max utilisations par jour
- Segments avec poids de probabilité
- Types de gains : pizza, boisson, dessert, points, rien

**Modèles** : `PopupConfig`, `RouletteConfig`

**Services** : `PopupService`, `RouletteService`
- Collections Firestore : `app_popups`, `app_roulette_config`
- Tracking des vues et spins utilisateur

### 3. Textes & Messages

**Route** : `/admin/studio/texts`

**Sections configurables** :
1. **Général**
   - Nom de l'app
   - Slogan
   - Texte intro page d'accueil

2. **Messages Commande**
   - Message succès
   - Message échec
   - Aucun créneau disponible

3. **Messages d'erreur**
   - Erreur réseau
   - Erreur serveur
   - Session expirée

4. **Fidélité**
   - Message de récompense
   - Explication du programme
   - Noms des niveaux (Bronze, Silver, Gold)

**Modèle** : `AppTextsConfig`

**Service** : `AppTextsService`
- Collection : `app_texts_config`
- Config par défaut intégrée

### 4. Mise en avant produits

**Route** : `/admin/studio/featured-products`

**Tags disponibles** :
- `isBestSeller` : Produit best-seller
- `isNew` : Nouveau produit
- `isChefSpecial` : Spécialité du chef
- `isKidFriendly` : Adapté aux enfants

**Fonctionnalités** :
- Gestion par catégorie (Pizzas, Menus, Boissons, Desserts)
- Toggle multiple tags par produit
- Sauvegarde immédiate dans Firestore

**Extension modèle** : `Product` (champs ajoutés)

**Service** : `ProductCrudService` (existant)

---

## Module Communication

### 1. Promotions

**Route** : `/admin/communication/promotions`

**Types de promotions** :
- `fixed_discount` : Remise fixe en €
- `percent_discount` : Remise en %
- `x_for_y` : X achetés = Y offerts
- `bonus_points` : Bonus de points fidélité

**Ciblage multi-canal** :
- `showOnHomeBanner` : Bannière page d'accueil
- `showInPromoBlock` : Bloc promotions
- `useInRoulette` : Utilisable dans la roulette
- `useInPopup` : Affichable dans popup
- `useInMailing` : Mise en avant email

**Options** :
- Période de validité
- Montant minimum de commande
- Catégories applicables

**Modèle** : `Promotion`

**Service** : `PromotionService`
- Collection : `promotions`
- Méthodes de filtrage par canal
- Vérification période active

### 2. Fidélité & Segments

**Route** : `/admin/communication/loyalty`

**Onglet Clients** :
- Liste des clients avec points de fidélité
- Niveau de chaque client (Bronze/Silver/Gold)
- Tri par points décroissants

**Onglet Paramètres** :
- Configuration du programme
  - Points par € dépensé
  - Seuils des niveaux
- Liste des segments disponibles
  - Tous les clients
  - Par niveau de fidélité

**Niveaux de fidélité** :
- **Bronze** : Niveau par défaut (0-499 points)
- **Silver** : 500-999 points
- **Gold** : 1000+ points

**Service** : `UserProfileService` (existant)
- Collection : `users_profile`

---

## Stockage Firestore

### Collections créées/utilisées

```
app_home_config/
  main/
    - hero: {}
    - promoBanner: {}
    - blocks: []

app_popups/
  {popup_id}/
    - type, title, message, conditions...

app_roulette_config/
  main/
    - isActive, segments[], settings...

promotions/
  {promo_id}/
    - name, type, value, channels...

app_texts_config/
  main/
    - general: {}
    - orderMessages: {}
    - errorMessages: {}
    - loyaltyTexts: {}

user_popup_views/
  {userId}_{popupId}/
    - lastViewedAt, viewCount

user_roulette_spins/
  {spin_id}/
    - userId, segmentId, spunAt
```

---

## Intégration Client (À venir)

Les fonctionnalités suivantes nécessiteront des modifications côté client :

1. **HomePage** : Affichage des configs (hero, bandeau, blocs)
2. **Popups** : Système d'affichage conditionnel
3. **Roulette** : Modal interactive avec animation
4. **Product Cards** : Affichage des badges (nouveau, best-seller, etc.)
5. **Messages** : Utilisation des textes configurables

---

## Points d'attention

### Sécurité Firestore
- Ajouter des règles de sécurité appropriées
- Limiter l'accès admin aux collections de configuration
- Protéger les données utilisateurs

### Performance
- Les configs sont chargées au besoin
- Utilisation de streams pour les mises à jour temps réel
- Cache local recommandé pour les textes

### Compatibilité
- Tous les modèles incluent des valeurs par défaut
- Rétrocompatibilité avec les produits existants
- Les nouveaux champs sont optionnels

---

## Tests recommandés

### Tests fonctionnels
1. Navigation entre toutes les sections admin
2. Création/modification de chaque type de config
3. Vérification de la persistance Firestore
4. Test des conditions d'affichage (popups, roulette)

### Tests d'intégration
1. Modification d'un produit avec tags
2. Création d'une promotion multi-canal
3. Vérification du programme de fidélité
4. Envoi de campagne mailing avec promotion

### Tests de régression
1. Vérifier que les écrans admin existants fonctionnent
2. Tester la création/modification de produits
3. Vérifier le système de commandes
4. Tester l'authentification

---

## Prochaines étapes

1. **Phase 1 - Validation** (en cours)
   - Test de la navigation
   - Validation des models et services
   - Vérification UI/UX

2. **Phase 2 - Intégration Client**
   - Affichage home config
   - Système de popups
   - Roulette interactive
   - Badges produits

3. **Phase 3 - Optimisation**
   - Cache et performance
   - Analytics
   - A/B testing
   - Reporting

---

## Support

Pour toute question sur ces modules :
- Documentation inline dans le code
- Exemples d'utilisation dans les services
- Modèles avec valeurs par défaut

---

## Changelog

### Version 1.0.0 (2025-01-13)
- ✅ Ajout module Studio (4 écrans)
- ✅ Ajout module Communication (2 écrans)
- ✅ 5 nouveaux modèles de données
- ✅ 5 nouveaux services Firestore
- ✅ Extension modèle Product avec tags
- ✅ Réorganisation dashboard admin
- ✅ Navigation complète
- ✅ Design system respecté
