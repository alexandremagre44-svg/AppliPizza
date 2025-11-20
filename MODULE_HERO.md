# Module Hero - Documentation

## Vue d'ensemble

Le module Hero permet de configurer la bannière principale affichée en haut de l'écran d'accueil de l'application Pizza Deli'Zza.

## Fonctionnalités

### Édition complète

- **Activation/Désactivation:** Toggle pour activer ou désactiver le Hero
- **Image de fond:** URL de l'image (format recommandé: 1200x400px)
- **Titre:** Texte principal affiché en gras (2 lignes max)
- **Sous-titre:** Texte descriptif sous le titre (2 lignes max)
- **Bouton CTA:**
  - Texte du bouton (ex: "Voir le menu")
  - Action: Route GoRouter (ex: "/menu", "/products")

### Mode brouillon

Toutes les modifications sont sauvegardées localement et visibles dans la prévisualisation en temps réel. Cliquez sur "Publier" pour enregistrer dans Firestore.

## Structure de données

### Modèle: HeroConfig

```dart
class HeroConfig {
  final bool isActive;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String ctaText;
  final String ctaAction;
}
```

### Collection Firestore

**Path:** `config/home_config` (champ `hero`)

**Format:**
```json
{
  "hero": {
    "isActive": true,
    "imageUrl": "https://...",
    "title": "Bienvenue chez Pizza Deli'Zza",
    "subtitle": "Découvrez nos pizzas artisanales",
    "ctaText": "Voir le menu",
    "ctaAction": "/menu"
  }
}
```

## Validation

### Règles

1. Le **titre** est obligatoire si le Hero est actif
2. L'**imageUrl** doit être une URL valide (optionnel)
3. Le **ctaAction** doit être une route valide GoRouter

### Messages d'erreur

- Titre vide avec Hero actif: Le Hero sera masqué côté client

## Rendu côté client

### Affichage

Le Hero est affiché en haut de l'écran d'accueil, après l'AppBar, uniquement si:
1. `studioEnabled` = true (dans home_layout)
2. `hero.isActive` = true
3. Section 'hero' est dans `enabledSections` de home_layout

### Style

- Hauteur: 150-200px (responsive)
- Image en fond avec gradient overlay
- Titre en blanc, bold
- Sous-titre en blanc 70% opacity
- Bouton CTA en bas à gauche

## Bonnes pratiques

### Images

- **Format:** JPG ou PNG
- **Dimensions recommandées:** 1200x400px (ratio 3:1)
- **Poids max:** < 300KB
- **Hébergement:** Firebase Storage, Cloudinary, ou CDN

### Textes

- **Titre:** 
  - Court et percutant (max 50 caractères)
  - Utiliser des retours à la ligne si nécessaire
- **Sous-titre:**
  - Descriptif mais concis (max 80 caractères)
  - Éviter les phrases trop longues

### CTA

- **Texte du bouton:**
  - Action claire (ex: "Voir le menu", "Commander")
  - Max 20 caractères
- **Action:**
  - Toujours vérifier que la route existe
  - Routes courantes: /menu, /products, /promo

## Exemples

### Hero classique

```json
{
  "isActive": true,
  "imageUrl": "https://example.com/pizza-hero.jpg",
  "title": "Bienvenue chez\nPizza Deli'Zza",
  "subtitle": "Découvrez nos pizzas artisanales faites maison",
  "ctaText": "Voir le menu",
  "ctaAction": "/menu"
}
```

### Hero promotionnel

```json
{
  "isActive": true,
  "imageUrl": "https://example.com/promo-hero.jpg",
  "title": "Offre spéciale du moment",
  "subtitle": "2 pizzas achetées = 1 dessert offert",
  "ctaText": "Profiter de l'offre",
  "ctaAction": "/promo"
}
```

### Hero désactivé

```json
{
  "isActive": false,
  "imageUrl": "",
  "title": "",
  "subtitle": "",
  "ctaText": "",
  "ctaAction": ""
}
```

## Dépannage

### Le Hero ne s'affiche pas

**Vérifier:**
1. `isActive` = true dans la config
2. `studioEnabled` = true dans home_layout
3. 'hero' est dans `enabledSections` avec valeur true
4. L'image URL est accessible (test dans le navigateur)

### L'image ne charge pas

**Causes possibles:**
- URL invalide ou inaccessible
- Image supprimée de l'hébergement
- CORS bloqué

**Solution:**
- Vérifier l'URL dans un navigateur
- Utiliser Firebase Storage pour plus de fiabilité
- Configurer les CORS si nécessaire

### Le bouton ne fonctionne pas

**Vérifier:**
- La route existe dans le router de l'app
- Le format est correct (commence par "/")
- Pas de caractères spéciaux

## Métadonnées

### Tracking

Le Hero est sauvegardé avec:
- `updatedAt`: DateTime de la dernière modification
- `updatedBy`: Email de l'administrateur (à implémenter)

### Historique

Pour garder un historique des modifications, implémenter un système de versioning dans une sous-collection `hero_history`.

## Accessibilité

- Le titre doit être descriptif pour les screen readers
- L'image doit avoir un alt text (à ajouter au modèle)
- Le bouton CTA doit avoir un label explicite

## Performance

- **Lazy loading:** L'image Hero doit être chargée avec lazy loading
- **Optimisation:** Utiliser des images optimisées (WebP recommandé)
- **Cache:** Activer le cache des images pour performance

## Évolutions futures

- [ ] Support multi-langues
- [ ] Alt text pour l'image
- [ ] Animation d'entrée personnalisable
- [ ] Support vidéo en fond
- [ ] A/B testing intégré
- [ ] Analytics (impressions, clics CTA)
