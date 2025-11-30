# 📊 RAPPORT D'ANALYSE COMPLET - COLLECTIONS FIRESTORE
## Application: AppliPizza (Flutter)
**Date de l'analyse:** 2025-11-23  
**Analysé par:** GitHub Copilot Agent

---

## 🎯 RÉSUMÉ EXÉCUTIF

- **Total de collections Firestore actives:** 27
- **Total de services utilisant Firestore:** 33
- **Collections avec sous-collections:** 3 (app_configs, users, config)
- **Services Firebase Storage:** 2
- **Modules détectés:** Studio B2, Studio B3, Roulette, Loyalty, Orders, Media Manager

---

## 📋 1. COLLECTIONS FIRESTORE ACTIVES

### Collections Principales (Top-Level)

1. **`pizzas`** - Produits de type pizza
2. **`menus`** - Menus combinés
3. **`drinks`** - Boissons
4. **`desserts`** - Desserts
5. **`ingredients`** - Ingrédients pour les pizzas
6. **`orders`** - Commandes clients
7. **`users`** - Profils utilisateurs et données de fidélité
8. **`user_profiles`** - Profils utilisateurs détaillés
9. **`promotions`** - Promotions marketing
10. **`app_banners`** - Bannières publicitaires
11. **`app_popups`** - Pop-ups de l'application
12. **`app_texts_config`** - Configuration des textes
13. **`app_home_config`** - Configuration de la page d'accueil
14. **`loyalty_settings`** - Paramètres du système de fidélité
15. **`roulette_segments`** - Segments de la roue de récompense
16. **`roulette_history`** - Historique des tirages de la roulette
17. **`user_roulette_spins`** - Historique des tours de roue par utilisateur
18. **`roulette_rate_limit`** - Limitation de taux pour la roulette
19. **`order_rate_limit`** - Limitation de taux pour les commandes
20. **`user_popup_views`** - Suivi des vues de popups par utilisateur
21. **`studio_media`** - Médias du Studio (images)
22. **`studio_content`** - Contenu du Studio
23. **`dynamic_sections_v3`** - Sections dynamiques V3
24. **`home_custom_sections`** - Sections personnalisées de l'accueil
25. **`home_product_overrides`** - Surcharges de produits pour l'accueil
26. **`home_category_overrides`** - Surcharges de catégories pour l'accueil
27. **`config`** - Collection de configuration générale

### Collections avec Sous-Collections

#### 1. **`app_configs/{appId}/configs/{docId}`**
Structure hiérarchique pour la configuration de l'application:
- **Chemin complet:** `app_configs/pizza_delizza/configs/config` (publié)
- **Chemin complet:** `app_configs/pizza_delizza/configs/config_draft` (brouillon)
- **Usage:** Studio B2, Studio B3, configuration des pages dynamiques
- **Service:** `lib/src/services/app_config_service.dart`
- **Opérations:** read, write, delete

#### 2. **`users/{userId}/rewardTickets/{ticketId}`**
Tickets de récompense par utilisateur:
- **Chemin complet:** `users/{userId}/rewardTickets/{ticketId}`
- **Usage:** Système de récompenses
- **Service:** `lib/src/services/reward_service.dart`
- **Opérations:** read, write, update

#### 3. **`config/{docId}`**
Configuration générale multi-documents:
- **Documents connus:** `theme`, `roulette_rules`, `roulette_settings`, `home_layout`, `text_blocks`, `popups_v2`, `featured_products`
- **Services:** Multiple (7 services)
- **Opérations:** read, write

---

## 📁 2. DÉTAILS PAR COLLECTION

### �� Collections de Produits

#### **`pizzas`**
- **Chemin:** `pizzas/{productId}`
- **Fichiers:** `lib/src/services/firestore_unified_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots)
  - ✅ Écriture (set avec merge)
  - ✅ Suppression (delete)
- **Usage:** Gestion complète des pizzas (CRUD)
- **Écrans admin:** Oui (product_form_screen.dart)

#### **`menus`**
- **Chemin:** `menus/{productId}`
- **Fichiers:** `lib/src/services/firestore_unified_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots)
  - ✅ Écriture (set avec merge)
  - ✅ Suppression (delete)
- **Usage:** Gestion des menus combinés
- **Écrans admin:** Oui

#### **`drinks`**
- **Chemin:** `drinks/{productId}`
- **Fichiers:** `lib/src/services/firestore_unified_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots)
  - ✅ Écriture (set avec merge)
  - ✅ Suppression (delete)
- **Usage:** Gestion des boissons
- **Écrans admin:** Oui

#### **`desserts`**
- **Chemin:** `desserts/{productId}`
- **Fichiers:** `lib/src/services/firestore_unified_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots)
  - ✅ Écriture (set avec merge)
  - ✅ Suppression (delete)
- **Usage:** Gestion des desserts
- **Écrans admin:** Oui

#### **`ingredients`**
- **Chemin:** `ingredients/{ingredientId}`
- **Fichiers:** `lib/src/services/firestore_ingredient_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots, where)
  - ✅ Écriture (add, set)
  - ✅ Suppression (delete)
- **Usage:** Gestion des ingrédients pour personnalisation des pizzas
- **Filtres:** `isActive`, `category`

---

### 🛒 Collections de Commandes

#### **`orders`**
- **Chemin:** `orders/{orderId}`
- **Fichiers:** `lib/src/services/firebase_order_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots, where, orderBy)
  - ✅ Écriture (add, set)
  - ✅ Mise à jour (update - status, seenByKitchen, isViewed)
  - ✅ Suppression (delete)
- **Champs principaux:**
  - `uid`, `customerName`, `customerEmail`, `customerPhone`
  - `status`, `items`, `total`, `total_cents`
  - `createdAt`, `statusChangedAt`, `statusHistory`
  - `pickupDate`, `pickupTimeSlot`, `comment`
  - `seenByKitchen`, `isViewed`, `viewedAt`
  - `source` (client/caisse), `paymentMethod`
- **Indexes requis:** `createdAt DESC`, `uid + createdAt DESC`, `status + createdAt DESC`, `isViewed + createdAt DESC`

#### **`order_rate_limit`**
- **Chemin:** `order_rate_limit/{userId}`
- **Fichiers:** `lib/src/services/firebase_order_service.dart`
- **Opérations:** 
  - ✅ Lecture (get)
  - ✅ Écriture (set)
- **Usage:** Limitation de taux pour prévenir le spam de commandes (1 commande/minute)
- **Champs:** `lastActionAt` (timestamp)

---

### 👤 Collections Utilisateurs

#### **`users`**
- **Chemin:** `users/{userId}`
- **Fichiers:** 
  - `lib/src/services/firebase_auth_service.dart`
  - `lib/src/services/loyalty_service.dart`
  - `lib/src/services/roulette_rules_service.dart`
- **Opérations:** 
  - ✅ Lecture (get)
  - ✅ Écriture (set)
  - ✅ Mise à jour (update)
- **Champs principaux:**
  - `email`, `role` (admin/kitchen/client)
  - `loyaltyPoints`, `lifetimePoints`, `vipTier`
  - `rewards`, `availableSpins`
  - `createdAt`, `updatedAt`
- **Sous-collections:** `rewardTickets`

#### **`users/{userId}/rewardTickets/{ticketId}`**
- **Chemin:** `users/{userId}/rewardTickets/{ticketId}`
- **Fichiers:** `lib/src/services/reward_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots, orderBy)
  - ✅ Écriture (set)
  - ✅ Mise à jour (update - isUsed, usedAt)
- **Champs:** `id`, `userId`, `action`, `createdAt`, `expiresAt`, `isUsed`, `usedAt`
- **Index requis:** `createdAt DESC`

#### **`user_profiles`**
- **Chemin:** `user_profiles/{userId}`
- **Fichiers:** `lib/src/services/user_profile_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots)
  - ✅ Écriture (set avec merge)
  - ✅ Mise à jour (update - favoriteProducts, address, imageUrl)
  - ✅ Suppression (delete)
- **Champs principaux:**
  - `id`, `name`, `email`, `imageUrl`, `address`
  - `favoriteProducts` (array max 50)
  - `loyaltyPoints`, `loyaltyLevel`
  - `updatedAt`
- **Sanitization:** name max 100 chars, address max 200 chars

---

### 🎡 Collections Roulette

#### **`roulette_segments`**
- **Chemin:** `roulette_segments/{segmentId}`
- **Fichiers:** `lib/src/services/roulette_segment_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots, orderBy)
  - ✅ Écriture (set)
  - ✅ Suppression (delete)
- **Champs:** `id`, `label`, `probability`, `value`, `type`, `rewardId`, `order`
- **Index requis:** `order ASC`

#### **`user_roulette_spins`**
- **Chemin:** `user_roulette_spins/{spinId}`
- **Fichiers:** 
  - `lib/src/services/roulette_service.dart`
  - `lib/src/services/roulette_rules_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, where, orderBy)
  - ✅ Écriture (add)
- **Champs:** `userId`, `segmentId`, `segmentType`, `segmentLabel`, `value`, `spunAt`
- **Index requis:** `userId + spunAt DESC`

#### **`roulette_rate_limit`**
- **Chemin:** `roulette_rate_limit/{userId}`
- **Fichiers:** `lib/src/services/roulette_service.dart`
- **Opérations:** 
  - ✅ Lecture (get)
  - ✅ Écriture (set)
- **Usage:** Limitation de taux pour les tours de roue (configurable)
- **Champs:** `lastActionAt` (timestamp)

#### **`roulette_history`**
- **Chemin:** `roulette_history/{historyId}`
- **Fichiers:** `lib/src/services/roulette_rules_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, where, orderBy)
  - ✅ Écriture (add)
- **Champs:** `userId`, `reward`, `timestamp`
- **Index requis:** `userId + timestamp DESC`

#### **`config/roulette_rules`**
- **Chemin:** `config/roulette_rules`
- **Fichiers:** `lib/src/services/roulette_rules_service.dart`
- **Opérations:** 
  - ✅ Lecture (get)
  - ✅ Écriture (set avec merge)
- **Champs:** Règles de la roulette (à documenter)

#### **`config/roulette_settings`**
- **Chemin:** `config/roulette_settings`
- **Fichiers:** `lib/src/services/roulette_settings_service.dart`
- **Opérations:** 
  - ✅ Lecture (get)
  - ✅ Écriture (set avec merge)
- **Champs:** Paramètres de la roulette

---

### 🎨 Collections Studio B2 / B3

#### **`app_configs/{appId}/configs/config`**
- **Chemin complet:** `app_configs/pizza_delizza/configs/config`
- **Fichiers:** `lib/src/services/app_config_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots)
  - ✅ Écriture (set avec merge)
- **Usage:** Configuration publiée de l'application (Studio B3)
- **Contenu:** Pages dynamiques B3, theme, textes, sections
- **Pages B3 obligatoires:** `/home-b3`, `/menu-b3`, `/categories-b3`, `/cart-b3`

#### **`app_configs/{appId}/configs/config_draft`**
- **Chemin complet:** `app_configs/pizza_delizza/configs/config_draft`
- **Fichiers:** `lib/src/services/app_config_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots)
  - ✅ Écriture (set avec merge)
  - ✅ Suppression (delete)
- **Usage:** Brouillon de configuration (éditeur Studio B3)
- **Workflow:** Édition en draft → Publication vers config

#### **`config/theme`**
- **Chemin:** `config/theme`
- **Fichiers:** `lib/src/services/theme_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots)
  - ✅ Écriture (set avec merge)
- **Usage:** Configuration du thème de l'application

#### **`config/text_blocks`**
- **Chemin:** `config/text_blocks`
- **Fichiers:** `lib/src/studio/services/text_block_service.dart`
- **Opérations:** read, write
- **Usage:** Blocs de texte réutilisables

#### **`config/popups_v2`**
- **Chemin:** `config/popups_v2`
- **Fichiers:** `lib/src/studio/services/popup_v2_service.dart`
- **Opérations:** read, write
- **Usage:** Popups version 2

#### **`config/home_layout`**
- **Chemin:** `config/home_layout`
- **Fichiers:** `lib/src/services/home_layout_service.dart`
- **Opérations:** read, update
- **Usage:** Layout de la page d'accueil

#### **`config/featured_products`**
- **Chemin:** `config/featured_products`
- **Fichiers:** `lib/src/studio/content/services/featured_products_service.dart`
- **Opérations:** read, write
- **Usage:** Produits mis en avant

#### **`app_texts_config`**
- **Chemin:** `app_texts_config/{configDocId}`
- **Fichiers:** `lib/src/services/app_texts_service.dart`
- **Opérations:** 
  - ✅ Lecture (get)
  - ✅ Écriture (set)
  - ✅ Mise à jour (update - multiple champs)
- **Usage:** Textes de l'application (multilingue potentiel)

#### **`app_home_config`**
- **Chemin:** `app_home_config/{docId}`
- **Fichiers:** `lib/src/services/home_config_service.dart`
- **Opérations:** read, update
- **Usage:** Configuration de la page d'accueil V2

#### **`app_banners`**
- **Chemin:** `app_banners/{bannerId}`
- **Fichiers:** `lib/src/services/banner_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots, where, orderBy)
  - ✅ Écriture (set)
  - ✅ Mise à jour (update - isActive)
  - ✅ Suppression (delete)
- **Champs:** `id`, `title`, `imageUrl`, `targetUrl`, `isActive`, `order`, `startDate`, `endDate`
- **Index requis:** `order ASC`, `isActive + order ASC`

#### **`app_popups`**
- **Chemin:** `app_popups/{popupId}`
- **Fichiers:** `lib/src/services/popup_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots, where, orderBy)
  - ✅ Écriture (set)
  - ✅ Suppression (delete)
- **Champs:** `id`, `title`, `message`, `imageUrl`, `isActive`, `priority`, `startDate`, `endDate`
- **Index requis:** `priority ASC`

#### **`user_popup_views`**
- **Chemin:** `user_popup_views/{viewId}`
- **Fichiers:** `lib/src/services/popup_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, where)
  - ✅ Écriture (set)
  - ✅ Suppression (delete)
- **Champs:** `userId`, `popupId`, `viewedAt`
- **Usage:** Suivi des popups déjà vus par utilisateur (évite les doublons)
- **Index requis:** `userId + popupId`

#### **`dynamic_sections_v3`**
- **Chemin:** `dynamic_sections_v3/{sectionId}`
- **Fichiers:** `lib/src/studio/services/dynamic_section_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots, orderBy)
  - ✅ Écriture (set)
  - ✅ Mise à jour (update)
  - ✅ Suppression (delete)
- **Champs:** `id`, `type`, `order`, `visible`, `content`, `updatedAt`
- **Index requis:** `order ASC`

#### **`home_custom_sections`**
- **Chemin:** `home_custom_sections/{sectionId}`
- **Fichiers:** `lib/src/studio/content/services/content_section_service.dart`
- **Opérations:** read, write, delete
- **Usage:** Sections personnalisées de l'accueil

#### **`home_product_overrides`**
- **Chemin:** `home_product_overrides/{overrideId}`
- **Fichiers:** `lib/src/studio/content/services/product_override_service.dart`
- **Opérations:** read, write, delete
- **Usage:** Surcharges de produits pour l'affichage accueil

#### **`home_category_overrides`**
- **Chemin:** `home_category_overrides/{overrideId}`
- **Fichiers:** `lib/src/studio/content/services/category_override_service.dart`
- **Opérations:** read, write, delete
- **Usage:** Surcharges de catégories pour l'affichage accueil

---

### 📸 Collections Média

#### **`studio_media`**
- **Chemin:** `studio_media/{assetId}`
- **Fichiers:** `lib/src/studio/services/media_manager_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, where, orderBy)
  - ✅ Écriture (set)
  - ✅ Suppression (delete)
- **Champs:** `id`, `folder`, `fileName`, `uploadedBy`, `uploadedAt`, `urls` (small/medium/full), `metadata`
- **Folders:** hero, promos, produits, studio, misc
- **Index requis:** `uploadedAt DESC`, `folder + uploadedAt DESC`
- **Lien avec Storage:** Oui (stocke metadata + URLs)

#### **`studio_content`**
- **Chemin:** `studio_content/{contentId}`
- **Fichiers:** `lib/src/features/content/data/content_service.dart`
- **Opérations:** read, write
- **Usage:** Contenu du Studio

---

### 🎯 Collections Marketing

#### **`promotions`**
- **Chemin:** `promotions/{promoId}`
- **Fichiers:** `lib/src/services/promotion_service.dart`
- **Opérations:** 
  - ✅ Lecture (get, snapshots, where, orderBy)
  - ✅ Écriture (set)
  - ✅ Mise à jour (update)
  - ✅ Suppression (delete)
- **Champs:** `id`, `title`, `description`, `discountPercent`, `code`, `isActive`, `startDate`, `endDate`
- **Index requis:** `isActive + startDate DESC`

#### **`loyalty_settings`**
- **Chemin:** `loyalty_settings/{settingsId}`
- **Fichiers:** `lib/src/services/loyalty_settings_service.dart`
- **Opérations:** read, write
- **Usage:** Paramètres du programme de fidélité

---

## 🗂️ 3. FIREBASE STORAGE - CHEMINS DÉTECTÉS

### Structure de Storage

#### **Dossiers Média Studio**
Tous les médias du Studio sont organisés sous: `studio/media/{folder}/{size}/{fileId}.{format}`

- **`studio/media/hero/`** - Images pour sections hero
  - `studio/media/hero/small/{id}.webp` (200px, 80% qualité)
  - `studio/media/hero/medium/{id}.webp` (600px, 80% qualité)
  - `studio/media/hero/full/{id}.webp` (1920px, 90% qualité)

- **`studio/media/promos/`** - Images promotionnelles
  - `studio/media/promos/small/`, `medium/`, `full/`

- **`studio/media/produits/`** - Images de produits
  - `studio/media/produits/small/`, `medium/`, `full/`

- **`studio/media/studio/`** - Images générales du studio
  - `studio/media/studio/small/`, `medium/`, `full/`

- **`studio/media/misc/`** - Images diverses
  - `studio/media/misc/small/`, `medium/`, `full/`

#### **Service d'Upload Générique**
Le service `image_upload_service.dart` permet d'uploader vers des chemins personnalisés:
- Format: `{path}/{uuid}.{extension}`
- Metadata: `contentType`, `uploadedAt`
- Exemples de chemins:
  - `home/hero/`
  - `products/pizza/`
  - Tout chemin personnalisé fourni

### Formats d'Image
- **Format privilégié:** WebP (si supporté par la plateforme)
- **Format fallback:** JPEG
- **Tailles générées automatiquement:**
  1. Small (200px) - 80% qualité
  2. Medium (600px) - 80% qualité
  3. Full (1920px) - 90% qualité

### Services Utilisant Firebase Storage
1. **`lib/src/services/image_upload_service.dart`**
   - Upload générique d'images
   - Suppression d'images
   - Compression automatique

2. **`lib/src/studio/services/media_manager_service.dart`**
   - Upload multi-tailles avec compression
   - Gestion des assets média
   - Organisation par dossiers
   - Metadata stockée dans Firestore (`studio_media`)

---

## 🔍 4. COLLECTIONS CRÉÉES PAR LES MODULES ROULETTE

Le module Roulette crée et gère **6 collections/documents**:

### Collections Principales
1. **`roulette_segments`** - Définition des segments de la roue
2. **`user_roulette_spins`** - Historique des tours par utilisateur
3. **`roulette_rate_limit`** - Limitation de taux des tours
4. **`roulette_history`** - Historique global des récompenses

### Documents de Configuration
5. **`config/roulette_rules`** - Règles du jeu de la roulette
6. **`config/roulette_settings`** - Paramètres configurables

### Intégrations avec d'Autres Collections
- **`users`** - Champ `availableSpins` pour les tours gratuits
- **`users/{userId}/rewardTickets`** - Création de tickets après un gain

---

## 🚫 5. COLLECTIONS POTENTIELLEMENT OBSOLÈTES

Après analyse du code, **AUCUNE collection obsolète n'a été détectée**.

Toutes les 27 collections identifiées sont:
- ✅ Référencées dans au moins un service
- ✅ Utilisées activement dans le code
- ✅ Documentées avec des opérations CRUD

### Collections Candidates pour Révision Future

#### **Collections "config/{docId}" multiples**
- **Raison:** 7 documents différents dans la même collection `config`
- **Recommandation:** Vérifier si une consolidation est possible
- **Impact:** Faible - structure fonctionnelle actuelle

#### **Duplication apparente: `user_profiles` vs `users`**
- **`users`:** Données de fidélité et authentification
- **`user_profiles`:** Profil détaillé utilisateur
- **Statut:** NON obsolète - usages complémentaires
- **Recommandation:** Documenter clairement la séparation des responsabilités

---

## 📌 6. ARCHITECTURE APP_CONFIGS

### Studio V2 vs Studio B2 vs Studio B3

#### **Studio V2** (Legacy - en migration)
- Configuration dans `app_home_config`
- Sections statiques: hero, promo banner, popup
- Migration vers B3 en cours

#### **Studio B2**
- Configuration dans `app_configs/{appId}/configs/config`
- Sections dynamiques basiques
- Cohabitation avec B3

#### **Studio B3** (Actuel)
- Configuration dans `app_configs/{appId}/configs/config` (publié)
- Configuration dans `app_configs/{appId}/configs/config_draft` (brouillon)
- **Pages dynamiques:**
  - `/home-b3` - Page d'accueil avec hero, promos, produits
  - `/menu-b3` - Page menu avec liste de produits
  - `/categories-b3` - Page catégories
  - `/cart-b3` - Page panier
- **Blocs widgets:** heroAdvanced, promoBanner, productList, categorySlider, etc.
- **Workflow:** Édition en draft → Prévisualisation → Publication

### Chemins Exacts
```
app_configs/
└── pizza_delizza/
    └── configs/
        ├── config        # Configuration publiée (production)
        └── config_draft  # Brouillon (édition)
```

---

## 🌐 7. PAGES DYNAMIQUES DÉTECTÉES

### Pages B3 (Studio B3)
Toutes créées automatiquement via `app_config_service.dart`:

1. **`/home-b3`** (Accueil B3)
   - Hero section
   - Promo banner
   - Product slider (meilleures ventes)
   - Category slider
   - Popup optionnel

2. **`/menu-b3`** (Menu B3)
   - Banner
   - Title
   - Product list (toutes les pizzas)

3. **`/categories-b3`** (Catégories B3)
   - Banner
   - Title
   - Category list

4. **`/cart-b3`** (Panier B3)
   - Banner
   - Empty state message
   - Back to menu button

### Méthodes de Création
- **Auto-initialization:** `autoInitializeB3IfNeeded()`
- **Force initialization:** `forceB3InitializationForDebug()`
- **Manual rebuild:** `forceRebuildAllB3Pages()`
- **Migration V2→B3:** `migrateExistingPagesToB3()`

---

## 📊 8. RÉSUMÉ DES OPÉRATIONS PAR COLLECTION

| Collection | Read | Write | Update | Delete | Index Requis |
|-----------|------|-------|--------|--------|--------------|
| pizzas | ✅ | ✅ | ✅ | ✅ | - |
| menus | ✅ | ✅ | ✅ | ✅ | - |
| drinks | ✅ | ✅ | ✅ | ✅ | - |
| desserts | ✅ | ✅ | ✅ | ✅ | - |
| ingredients | ✅ | ✅ | - | ✅ | isActive, category |
| orders | ✅ | ✅ | ✅ | ✅ | createdAt DESC, uid, status, isViewed |
| order_rate_limit | ✅ | ✅ | ✅ | ✅ | - |
| users | ✅ | ✅ | ✅ | - | - |
| users/.../rewardTickets | ✅ | ✅ | ✅ | - | createdAt DESC |
| user_profiles | ✅ | ✅ | ✅ | ✅ | - |
| roulette_segments | ✅ | ✅ | - | ✅ | order ASC |
| user_roulette_spins | ✅ | ✅ | - | - | userId + spunAt DESC |
| roulette_rate_limit | ✅ | ✅ | - | - | - |
| roulette_history | ✅ | ✅ | - | - | userId + timestamp DESC |
| app_configs/.../configs | ✅ | ✅ | - | ✅ | - |
| app_banners | ✅ | ✅ | ✅ | ✅ | order ASC, isActive |
| app_popups | ✅ | ✅ | - | ✅ | priority ASC |
| user_popup_views | ✅ | ✅ | ✅ | ✅ | userId + popupId |
| promotions | ✅ | ✅ | ✅ | ✅ | isActive + startDate DESC |
| studio_media | ✅ | ✅ | - | ✅ | uploadedAt DESC, folder |
| dynamic_sections_v3 | ✅ | ✅ | ✅ | ✅ | order ASC |
| home_product_overrides | ✅ | ✅ | - | ✅ | - |
| home_category_overrides | ✅ | ✅ | - | ✅ | - |
| config/* | ✅ | ✅ | ✅ | - | (dépend du document) |

---

## 🔧 9. RECOMMANDATIONS POUR NETTOYAGE

### ✅ Aucun nettoyage urgent requis

Toutes les collections sont activement utilisées. Cependant, voici des suggestions d'amélioration:

### Optimisations Suggérées

1. **Consolidation de la collection `config`**
   - Actuellement: 7 documents différents dans `config/`
   - Suggestion: Évaluer si regroupement possible dans `app_configs`
   - Priorité: **Basse** (fonctionne bien actuellement)

2. **Indexes Firestore**
   - Vérifier que tous les indexes composites sont créés
   - Collections critiques: `orders`, `user_roulette_spins`, `roulette_history`
   - Priorité: **Moyenne**

3. **Documentation des Sous-Collections**
   - Documenter clairement `users/{userId}/rewardTickets`
   - Ajouter des exemples de requêtes
   - Priorité: **Basse**

4. **Separation `users` vs `user_profiles`**
   - Clarifier dans la documentation le rôle de chaque collection
   - `users`: Auth + Loyalty + Rewards
   - `user_profiles`: Profile détaillé + Favoris + Adresse
   - Priorité: **Basse** (documentation uniquement)

---

## 📋 10. INDEX FIRESTORE RECOMMANDÉS

### Index Composites Requis

```javascript
// orders
orders: {
  uid: ASC,
  createdAt: DESC
}

orders: {
  status: ASC,
  createdAt: DESC
}

orders: {
  isViewed: ASC,
  createdAt: DESC
}

// user_roulette_spins
user_roulette_spins: {
  userId: ASC,
  spunAt: DESC
}

// roulette_history
roulette_history: {
  userId: ASC,
  timestamp: DESC
}

// app_banners
app_banners: {
  isActive: ASC,
  order: ASC
}

// promotions
promotions: {
  isActive: ASC,
  startDate: DESC
}

// studio_media
studio_media: {
  folder: ASC,
  uploadedAt: DESC
}

// user_popup_views
user_popup_views: {
  userId: ASC,
  popupId: ASC
}
```

### Index Simples (Single Field)

```javascript
// Collections avec tri par ordre
roulette_segments: order ASC
dynamic_sections_v3: order ASC
app_banners: order ASC
app_popups: priority ASC

// Collections avec timestamp
orders: createdAt DESC
user_roulette_spins: spunAt DESC
roulette_history: timestamp DESC
studio_media: uploadedAt DESC
users/.../rewardTickets: createdAt DESC
```

---

## 🔐 11. SÉCURITÉ ET RATE LIMITING

### Collections de Rate Limiting

1. **`order_rate_limit`** - Limite: 1 commande/minute par utilisateur
2. **`roulette_rate_limit`** - Limite configurable pour tours de roue

### Sanitization Appliquée

- **`orders`**: name max 100, phone max 20, comment max 500, items max 50, total max 10000€
- **`user_profiles`**: name max 100, address max 200, favoriteProducts max 50

### Validation Firestore Rules

Collections nécessitant des règles strictes:
- ✅ `orders` - Vérifier uid de l'utilisateur
- ✅ `user_roulette_spins` - Rate limiting server-side
- ✅ `order_rate_limit` - Vérifier timestamp
- ✅ `roulette_rate_limit` - Vérifier timestamp
- ✅ `users/.../rewardTickets` - Vérifier ownership

---

## 📈 12. STATISTIQUES FINALES

### Par Type de Collection
- **Produits:** 5 collections (pizzas, menus, drinks, desserts, ingredients)
- **Commandes:** 2 collections (orders, order_rate_limit)
- **Utilisateurs:** 3 collections + 1 sous-collection (users, user_profiles, users/.../rewardTickets)
- **Roulette:** 6 collections/documents
- **Studio/CMS:** 13 collections
- **Marketing:** 4 collections (promotions, app_banners, app_popups, user_popup_views)
- **Configuration:** 3 collections (config, loyalty_settings, app_texts_config)

### Par Service
- **Services avec Firestore:** 33 fichiers
- **Services avec Storage:** 2 fichiers
- **Collections top-level:** 24
- **Sous-collections:** 2 (rewardTickets, configs)
- **Documents config:** 7+ dans `config/`

### Modules Actifs
1. ✅ **Studio B3** - Pages dynamiques
2. ✅ **Roulette** - Système de récompenses
3. ✅ **Loyalty** - Programme de fidélité
4. ✅ **Orders** - Gestion des commandes
5. ✅ **Products** - Gestion du catalogue
6. ✅ **Media Manager** - Gestion des images
7. ✅ **Promotions** - Marketing

---

## ✅ CONCLUSION

### Santé du Projet
**🟢 EXCELLENT** - Le projet est bien structuré avec:
- Séparation claire des responsabilités
- Pas de collections obsolètes
- Architecture modulaire
- Rate limiting en place
- Sanitization des inputs
- Documentation dans le code

### Actions Recommandées
1. ✅ **Aucune action urgente**
2. 📝 Créer la documentation des indexes Firestore
3. 📝 Documenter la séparation `users` vs `user_profiles`
4. �� Ajouter des exemples de requêtes dans les services

### Prochaines Étapes Suggérées
1. Vérifier que tous les indexes composites sont déployés dans Firebase
2. Auditer les règles Firestore Security Rules
3. Considérer l'ajout de tests d'intégration pour les opérations CRUD critiques
4. Documenter les workflows Studio B3 (draft → publish)

---

**📅 Date du rapport:** 2025-11-23  
**🔍 Analyse effectuée par:** GitHub Copilot Agent  
**📊 Fichiers analysés:** 33 services, 27 collections, 2 services Storage  
**✅ Statut:** Analyse complète terminée

