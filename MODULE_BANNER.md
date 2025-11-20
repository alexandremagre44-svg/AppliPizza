# Module Bandeau - Documentation

## Vue d'ensemble

Le module Bandeau permet de gérer plusieurs bandeaux promotionnels programmables qui s'affichent sur l'écran d'accueil.

## Fonctionnalités

### Gestion multiple

- **Créer** un nouveau bandeau
- **Éditer** un bandeau existant
- **Supprimer** un bandeau
- **Réorganiser** l'ordre avec drag & drop
- **Activer/Désactiver** individuellement

### Configuration complète

Pour chaque bandeau:
- **Texte:** Message promotionnel (2 lignes max)
- **Icône:** Choix parmi 6 icônes Material
  - campaign (mégaphone)
  - star (étoile)
  - local_fire_department (flamme)
  - local_offer (étiquette)
  - new_releases (nouveau)
  - celebration (fête)
- **Couleurs:**
  - Couleur de fond (color picker)
  - Couleur du texte (color picker)
- **Planification:**
  - Date de début (optionnel)
  - Date de fin (optionnel)
- **Activation:** Toggle on/off

### Drag & Drop

Glissez-déposez les bandeaux pour changer leur ordre d'affichage. Le champ `order` est automatiquement mis à jour.

## Structure de données

### Modèle: BannerConfig

```dart
class BannerConfig {
  final String id;
  final String text;
  final String? icon;
  final String backgroundColor; // Hex color
  final String textColor;       // Hex color
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isEnabled;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;
}
```

### Collection Firestore

**Path:** `app_banners`

**Document ID:** Généré automatiquement (`banner_{timestamp}`)

**Format:**
```json
{
  "id": "banner_1234567890",
  "text": "Offre spéciale : -20% sur toutes les pizzas",
  "icon": "local_fire_department",
  "backgroundColor": "#D32F2F",
  "textColor": "#FFFFFF",
  "startDate": "2024-11-20T00:00:00.000Z",
  "endDate": "2024-11-30T23:59:59.000Z",
  "isEnabled": true,
  "order": 0,
  "createdAt": "2024-11-20T10:00:00.000Z",
  "updatedAt": "2024-11-20T10:00:00.000Z",
  "updatedBy": "admin@example.com"
}
```

## Validation

### Règles

1. Le **texte** est obligatoire
2. Les **couleurs** doivent être au format hex valide
3. **startDate** doit être avant **endDate** (si les deux sont définis)
4. Minimum 1 bandeau actif recommandé

## Logique d'affichage

### Côté client

Un bandeau est affiché uniquement si:
1. `studioEnabled` = true dans home_layout
2. `banner` est dans `enabledSections` de home_layout
3. `isEnabled` = true
4. Date actuelle entre `startDate` et `endDate` (si définis)

### Ordre

Les bandeaux sont affichés selon le champ `order` (ASC):
- order 0 = premier bandeau
- order 1 = deuxième bandeau
- etc.

### Style

- Hauteur: 48-56px
- Padding: 16px horizontal, 12px vertical
- Border radius: 8px
- Icône à gauche (20px)
- Texte sur 2 lignes max avec ellipsis

## Bonnes pratiques

### Nombre de bandeaux

- **Recommandé:** 2-3 bandeaux actifs maximum
- **Maximum:** 5 bandeaux actifs
- **Raison:** Trop de bandeaux surchargent l'écran

### Textes

- **Court et percutant:** Max 60 caractères
- **Action claire:** Indiquer l'offre ou l'information
- **Exemples:**
  - ✅ "Offre spéciale : -20% sur toutes les pizzas"
  - ✅ "Nouveau : Pizza Margherita disponible"
  - ❌ "Nous avons le plaisir de vous annoncer..." (trop long)

### Couleurs

#### Palettes suggérées

**Promotion (rouge):**
- Fond: #D32F2F
- Texte: #FFFFFF

**Info (bleu):**
- Fond: #1976D2
- Texte: #FFFFFF

**Succès (vert):**
- Fond: #388E3C
- Texte: #FFFFFF

**Attention (orange):**
- Fond: #F57C00
- Texte: #FFFFFF

**Contraste:** Toujours vérifier le contraste (min 4.5:1) pour accessibilité

### Icônes

Choisir l'icône selon le type de message:
- **campaign:** Promo, annonce
- **star:** Nouveauté, vedette
- **local_fire_department:** Offre limitée, urgent
- **local_offer:** Réduction, offre
- **new_releases:** Nouveau produit
- **celebration:** Événement, fête

### Planification

#### Usage typique

- **Promo week-end:** startDate vendredi, endDate dimanche
- **Offre du mois:** startDate 1er du mois, endDate dernier jour
- **Annonce permanente:** Pas de dates (toujours actif si enabled)

#### Conseils

- Définir les dates à minuit pour simplicité
- Vérifier régulièrement les bandeaux expirés
- Désactiver plutôt que supprimer (réutilisable)

## Exemples

### Bandeau promo classique

```json
{
  "text": "Offre du moment : -15% avec le code PIZZA15",
  "icon": "local_offer",
  "backgroundColor": "#D32F2F",
  "textColor": "#FFFFFF",
  "startDate": "2024-11-20T00:00:00.000Z",
  "endDate": "2024-11-27T23:59:59.000Z",
  "isEnabled": true,
  "order": 0
}
```

### Bandeau info

```json
{
  "text": "Livraison gratuite dès 20€ de commande",
  "icon": "campaign",
  "backgroundColor": "#1976D2",
  "textColor": "#FFFFFF",
  "startDate": null,
  "endDate": null,
  "isEnabled": true,
  "order": 1
}
```

### Bandeau nouveauté

```json
{
  "text": "Nouvelle pizza : La Quatre Fromages est arrivée !",
  "icon": "new_releases",
  "backgroundColor": "#388E3C",
  "textColor": "#FFFFFF",
  "startDate": "2024-11-15T00:00:00.000Z",
  "endDate": "2024-11-30T23:59:59.000Z",
  "isEnabled": true,
  "order": 2
}
```

## Service: BannerService

### Méthodes disponibles

```dart
// Récupérer tous les bandeaux
Future<List<BannerConfig>> getAllBanners()

// Récupérer uniquement les bandeaux actifs
Future<List<BannerConfig>> getActiveBanners()

// Écouter les changements en temps réel
Stream<List<BannerConfig>> watchBanners()

// Récupérer un bandeau par ID
Future<BannerConfig?> getBannerById(String id)

// Créer un nouveau bandeau
Future<bool> createBanner(BannerConfig banner)

// Mettre à jour un bandeau
Future<bool> updateBanner(BannerConfig banner)

// Supprimer un bandeau
Future<bool> deleteBanner(String id)

// Mettre à jour l'ordre de plusieurs bandeaux
Future<bool> updateBannersOrder(List<BannerConfig> banners)

// Activer/désactiver un bandeau
Future<bool> toggleBanner(String id, bool isEnabled)
```

## Dépannage

### Les bandeaux ne s'affichent pas

**Vérifier:**
1. `studioEnabled` = true
2. 'banner' dans `enabledSections` avec valeur true
3. Au moins un bandeau avec `isEnabled` = true
4. Dates valides (si définies)

### L'ordre ne se met pas à jour

**Solution:**
- Faire un drag & drop dans le Studio
- Cliquer sur "Publier" pour enregistrer
- Vérifier le champ `order` dans Firestore

### Les couleurs ne s'affichent pas

**Vérifier:**
- Format hex valide (#RRGGBB ou #AARRGGBB)
- Pas d'espaces dans le code couleur

## Performance

- **Limite recommandée:** 10 bandeaux max en base
- **Cache:** Les bandeaux actifs sont mis en cache côté client
- **Query:** Index Firestore sur `isEnabled` et `order`

## Évolutions futures

- [ ] Support multi-langues
- [ ] Animation d'entrée/sortie
- [ ] Click tracking (analytics)
- [ ] Lien vers page spécifique
- [ ] Templates prédéfinis
- [ ] Duplication de bandeau
- [ ] Archivage automatique des bandeaux expirés
