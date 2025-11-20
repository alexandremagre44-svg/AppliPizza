# Studio Admin Unifié - Guide des Modules

## Vue d'ensemble

Le Studio Admin Unifié est un système complet de gestion du contenu et de l'apparence de l'application Pizza Deli'Zza. Il permet aux administrateurs de modifier Hero, Bandeaux, Popups, Textes et Paramètres depuis une interface unique et intuitive.

## Architecture

### Structure principale

```
AdminStudioUnified (Écran principal)
├── Navigation (6 modules)
├── Contenu (Module sélectionné)
└── Prévisualisation (Live preview)
```

### Mode Brouillon

**Fonctionnement:**
- Toutes les modifications sont sauvegardées localement dans l'état React
- Aucune modification n'est envoyée à Firestore tant que "Publier" n'est pas cliqué
- Le bouton "Annuler" restore depuis Firestore (dernière version publiée)
- Un avertissement s'affiche si l'utilisateur tente de quitter avec des modifications non sauvegardées

**Avantages:**
- Prévisualisation instantanée sans pollution de la base
- Possibilité d'annuler facilement
- Publication atomique de tous les changements

## Les 6 Modules

### 1. Vue d'ensemble

**Rôle:** Dashboard avec statistiques et actions rapides

**Fonctionnalités:**
- Cartes de statistiques (Studio, Hero, Bandeaux, Popups)
- Bouton "Recharger depuis Firestore"
- Toggle global Studio (activer/désactiver tout)
- Aide et documentation

**Indicateurs:**
- État du Studio (Activé/Désactivé)
- État du Hero (Actif/Inactif)
- Nombre de bandeaux actifs
- Nombre de popups actives

### 2. Module Hero

**Rôle:** Éditer la bannière principale de l'écran d'accueil

**Champs disponibles:**
- **Toggle activation:** Activer/désactiver le Hero
- **URL Image:** Lien vers l'image de fond
- **Titre:** Texte principal (2 lignes max)
- **Sous-titre:** Texte secondaire (2 lignes max)
- **Texte du bouton:** Label du CTA
- **Action du bouton:** Route GoRouter (ex: /menu)

**Validation:**
- Le titre est obligatoire si le Hero est actif

**Métadonnées:**
- updatedAt (DateTime automatique)

### 3. Module Bandeau

**Rôle:** Gérer plusieurs bandeaux programmables

**Fonctionnalités:**
- **CRUD complet:** Créer, éditer, supprimer des bandeaux
- **Planification:** Date de début et de fin
- **Personnalisation:**
  - Texte du bandeau (2 lignes max)
  - Couleur de fond (color picker)
  - Couleur du texte (color picker)
  - Icône (6 options: campaign, star, fire, offer, new, celebration)
- **Ordre:** Drag & drop pour réorganiser
- **Activation:** Toggle individuel par bandeau

**Collection Firestore:** `app_banners`

**Champs du modèle:**
- id, text, icon, backgroundColor, textColor
- startDate, endDate, isEnabled, order
- createdAt, updatedAt, updatedBy

**Tri:** Par champ `order` (ordre d'affichage)

### 4. Module Popups

**Rôle:** Gérer les popups et notifications

**Fonctionnalités:**
- **CRUD complet:** Créer, éditer, supprimer des popups
- **Types:** info (bleu), promo (vert), warning (rouge)
- **Planification:** Date de début et de fin
- **Contenu:**
  - Titre
  - Message (3 lignes)
  - Image (optionnel)
  - Bouton avec texte et lien
- **Ordre:** Drag & drop pour priorité d'affichage
- **Activation:** Toggle individuel

**Collection Firestore:** `app_popups`

**Champs du modèle:**
- id, title, message, type, imageUrl
- buttonText, buttonLink
- startDate, endDate, isEnabled, priority
- trigger, audience
- createdAt

**Tri:** Par champ `priority` (DESC)

### 5. Module Textes

**Rôle:** Éditer tous les textes de l'application (focus Home)

**Textes Home disponibles:**
1. **appName** - Nom de l'application
2. **slogan** - Slogan
3. **title** - Titre principal
4. **subtitle** - Sous-titre
5. **ctaViewMenu** - Bouton voir le menu
6. **welcomeMessage** - Message de bienvenue
7. **categoriesTitle** - Titre des catégories
8. **promosTitle** - Titre des promos
9. **bestSellersTitle** - Titre best-sellers
10. **featuredTitle** - Titre produits phares
11. **retryButton** - Bouton réessayer
12. **productAddedToCart** - Message ajout panier (avec placeholder {name})

**Fonctionnalités:**
- Édition en direct avec mise à jour automatique
- Bouton "Réinitialiser aux valeurs par défaut"
- Validation automatique

**Collection Firestore:** `config/app_texts`

### 6. Module Paramètres

**Rôle:** Configuration globale du Studio

**A. Activation du Studio**
- Toggle global pour activer/désactiver tout le Studio
- Explication de l'impact (masque Hero + Bandeaux + Popups)
- Les configurations restent sauvegardées

**B. Paramètres généraux du layout**
- Information sur l'organisation des sections

**C. Ordre et visibilité des sections**
- Liste des sections: Hero, Banner, Popups
- Drag & drop pour réorganiser l'ordre d'affichage
- Toggle par section pour activer/désactiver
- Indicateurs visuels (couleur selon état)

**Collection Firestore:** `config/home_layout`

**Champs:**
- studioEnabled (bool)
- sectionsOrder (List<String>)
- enabledSections (Map<String, bool>)
- updatedAt

## Prévisualisation

### Fonctionnement

La prévisualisation affiche en temps réel l'apparence exacte de l'écran d'accueil avec les modifications en cours (mode brouillon).

**Éléments affichés:**
- App bar avec nom et slogan
- Hero (si actif et activé)
- Bandeaux (tous les bandeaux actifs, dans l'ordre)
- Indicateur de popups actives
- Placeholder pour les catégories

**Responsive:**
- Desktop: Panneau de droite fixe
- Mobile: Pas de prévisualisation (gain de place)

**Indicateurs:**
- Badge "Studio désactivé" si studioEnabled = false
- Sections affichées selon sectionsOrder et enabledSections

## Compatibilité et Fallback

### Si config/home_layout n'existe pas

Le système utilise la configuration par défaut:
```dart
HomeLayoutConfig.defaultConfig()
- studioEnabled: true
- sectionsOrder: ['hero', 'banner', 'popups']
- enabledSections: {'hero': true, 'banner': true, 'popups': true}
```

### Si pas de banners

Le système affiche l'ancien PromoBanner de `home_config` (backward compatibility).

## Navigation et Routing

### Intégration

Le Studio doit être accessible via le routing existant de l'application.

**Route suggérée:** `/admin/studio`

**Import:**
```dart
import 'package:pizza_delizza/src/screens/admin/studio/admin_studio_unified.dart';
```

**Utilisation:**
```dart
GoRoute(
  path: '/admin/studio',
  builder: (context, state) => const AdminStudioUnified(),
),
```

## Sécurité

### Règles Firestore

Voir le fichier `FIRESTORE_RULES.md` pour les règles de sécurité à ajouter.

**Collections concernées:**
- `config/home_layout`
- `app_banners`
- `app_popups` (existant)
- `config/app_texts` (existant)

## Performance

### Optimisations

1. **Chargement initial:** Tous les configs chargés en une seule fois
2. **Mode brouillon:** Pas de requêtes Firestore pendant l'édition
3. **Publication:** Batch update pour cohérence atomique
4. **Prévisualisation:** Rebuilt uniquement sur changement de draft

### Considérations

- **Taille des images:** Vérifier la taille des URLs Hero et Popup
- **Nombre de banners:** Limiter à 5-10 maximum
- **Nombre de popups:** Limiter à 10-15 maximum

## Tests

Voir le fichier `STUDIO_TEST_PLAN.md` pour le plan de tests complet.

## Support

Pour plus de détails sur chaque module, consulter:
- `MODULE_HERO.md`
- `MODULE_BANNER.md`
- `MODULE_POPUPS.md`
- `MODULE_TEXTS.md`
- `MODULE_SETTINGS.md`
