# Architecture B2 - Configuration Unifiée

## Vue d'ensemble

Cette architecture centralise toute la configuration de l'application dans un système unifié et propre, permettant la gestion de brouillons et la publication de configurations pour un support white-label.

## Structure des fichiers

### Modèles (`lib/src/models/app_config.dart`)

Contient tous les modèles de configuration :

- **AppConfig** : Configuration principale de l'application
- **HomeConfigV2** : Configuration de l'écran d'accueil
- **HomeSectionConfig** : Configuration d'une section individuelle de l'accueil
- **HomeSectionType** : Enum pour les types de sections (hero, promo_banner, popup, etc.)
- **TextsConfig** : Configuration des textes de l'application
- **ThemeConfigV2** : Configuration du thème (couleurs, mode sombre)
- **MenuConfig** : Configuration du menu
- **BrandingConfig** : Configuration du branding (logos)
- **LegalConfig** : Configuration des mentions légales
- **ModulesConfig** : Configuration des modules
- **RouletteModuleConfig** : Configuration du module roulette

### Service (`lib/src/services/app_config_service.dart`)

Service centralisé pour gérer les configurations dans Firestore :

#### Méthodes principales

- `watchConfig()` : Stream pour écouter les changements en temps réel
- `getConfig()` : Récupérer une configuration
- `saveDraft()` : Sauvegarder un brouillon
- `publishDraft()` : Publier un brouillon vers la production
- `initializeDefaultConfig()` : Initialiser une configuration par défaut
- `deleteDraft()` : Supprimer un brouillon
- `createDraftFromPublished()` : Créer un brouillon depuis la config publiée
- `hasDraft()` : Vérifier l'existence d'un brouillon
- `getConfigVersion()` : Obtenir le numéro de version

### Exemple (`lib/src/services/app_config_service_example.dart`)

Fichier d'exemples démontrant toutes les utilisations possibles du service.

## Structure Firestore

```
app_configs/
  {appId}/              # Ex: pizza_delizza
    configs/
      config            # Configuration publiée (utilisée par l'app client)
      config_draft      # Configuration brouillon (utilisée par le Studio)
```

### Avantages de cette structure

- **Séparation claire** : Brouillon vs Production
- **Support multi-tenant** : Un appId par restaurant
- **Versioning automatique** : Incrémentation à chaque publication
- **Sécurité** : Les modifications ne sont pas directement en production

## Structure JSON de la configuration

```json
{
  "appId": "pizza_delizza",
  "version": 1,
  "home": {
    "sections": [
      {
        "id": "hero_1",
        "type": "hero",
        "order": 1,
        "active": true,
        "data": {
          "title": "Bienvenue chez Pizza Deli'Zza",
          "subtitle": "La pizza 100% appli",
          "imageUrl": "",
          "ctaLabel": "Voir le menu",
          "ctaTarget": "menu"
        }
      },
      {
        "id": "banner_1",
        "type": "promo_banner",
        "order": 2,
        "active": false,
        "data": {
          "text": "−20% le mardi",
          "backgroundColor": "#D62828"
        }
      },
      {
        "id": "popup_1",
        "type": "popup",
        "order": 0,
        "active": true,
        "data": {
          "title": "Info allergènes",
          "content": "Nos pizzas peuvent contenir...",
          "showOnAppStart": true
        }
      }
    ],
    "texts": {
      "welcomeTitle": "Bienvenue chez Pizza Deli'Zza",
      "welcomeSubtitle": "La pizza 100% appli"
    },
    "theme": {
      "primaryColor": "#D62828",
      "secondaryColor": "#000000",
      "accentColor": "#FFFFFF",
      "darkMode": false
    }
  },
  "menu": {
    "categories": [],
    "featuredItems": []
  },
  "branding": {
    "logoUrl": "",
    "faviconUrl": ""
  },
  "legal": {
    "cgv": "",
    "mentionsLegales": ""
  },
  "modules": {
    "roulette": {
      "enabled": true,
      "config": {}
    }
  },
  "createdAt": "2025-11-22T15:00:00Z",
  "updatedAt": "2025-11-22T15:00:00Z"
}
```

## Exemples d'utilisation

### 1. Initialiser la configuration par défaut

```dart
final configService = AppConfigService();
await configService.initializeDefaultConfig(appId: 'pizza_delizza');
```

### 2. Écouter les changements en temps réel

```dart
configService.watchConfig(appId: 'pizza_delizza').listen((config) {
  if (config != null) {
    print('Config mise à jour: ${config.home.texts.welcomeTitle}');
    // Mettre à jour l'UI
  }
});
```

### 3. Créer et modifier un brouillon

```dart
// Récupérer la config publiée
final published = await configService.getConfig(appId: 'pizza_delizza');

// Modifier
final draft = published.copyWith(
  home: published.home.copyWith(
    texts: TextsConfig(
      welcomeTitle: 'Nouveau Titre',
      welcomeSubtitle: 'Nouveau sous-titre',
    ),
  ),
);

// Sauvegarder le brouillon
await configService.saveDraft(appId: 'pizza_delizza', config: draft);
```

### 4. Publier un brouillon

```dart
await configService.publishDraft(appId: 'pizza_delizza');
```

### 5. Ajouter une section à l'accueil

```dart
// Récupérer ou créer un brouillon
var draft = await configService.getConfig(appId: 'pizza_delizza', draft: true);
if (draft == null) {
  await configService.createDraftFromPublished(appId: 'pizza_delizza');
  draft = await configService.getConfig(appId: 'pizza_delizza', draft: true);
}

// Ajouter une nouvelle section
final newSection = HomeSectionConfig(
  id: 'popup_allergens',
  type: HomeSectionType.popup,
  order: 0,
  active: true,
  data: {
    'title': 'Allergènes',
    'content': 'Nos pizzas peuvent contenir...',
    'showOnAppStart': true,
  },
);

final updatedSections = [...draft.home.sections, newSection];
final updatedDraft = draft.copyWith(
  home: draft.home.copyWith(sections: updatedSections),
);

await configService.saveDraft(appId: 'pizza_delizza', config: updatedDraft);
```

## Workflow de développement

### Pour le Studio V2 (Admin)

1. **Charger la configuration publiée**
   - Utiliser `getConfig(appId: 'pizza_delizza', draft: false)`
   
2. **Créer un brouillon**
   - Utiliser `createDraftFromPublished(appId: 'pizza_delizza')`
   
3. **Modifier le brouillon**
   - Charger avec `getConfig(draft: true)`
   - Modifier les valeurs nécessaires
   - Sauvegarder avec `saveDraft()`
   
4. **Prévisualiser**
   - Le Studio peut afficher le brouillon côte à côte avec la version publiée
   
5. **Publier**
   - Utiliser `publishDraft(appId: 'pizza_delizza')`
   - La version est automatiquement incrémentée

### Pour l'app cliente (Mobile)

1. **Charger la configuration au démarrage**
   ```dart
   final config = await configService.getConfig(appId: 'pizza_delizza');
   ```

2. **Écouter les mises à jour**
   ```dart
   configService.watchConfig(appId: 'pizza_delizza').listen((config) {
     // Mettre à jour l'UI en temps réel
   });
   ```

## Types de sections disponibles

L'enum `HomeSectionType` définit les types de sections disponibles :

- **hero** : Bannière principale avec image, titre, CTA
- **promo_banner** : Bannière promotionnelle horizontale
- **popup** : Popup d'information ou promo
- **product_grid** : Grille de produits
- **category_list** : Liste de catégories
- **custom** : Section personnalisée

## Avantages de cette architecture

### 1. Centralisation
- Une seule source de vérité pour toute la configuration
- Fin de l'éclatement en multiples collections Firestore

### 2. White-label ready
- Support natif du multi-tenant via `appId`
- Facile d'ajouter de nouveaux restaurants

### 3. Workflow sûr
- Modifications en brouillon
- Validation avant publication
- Versioning automatique

### 4. Flexibilité
- Structure JSON extensible dans le champ `data` des sections
- Facile d'ajouter de nouveaux types de sections

### 5. Type-safe
- Modèles Dart typés
- Null-safety activée
- Méthodes `copyWith` pour modifications immutables

## Prochaines étapes (hors de cette PR)

Cette PR pose les fondations. Les étapes suivantes seront :

1. **Migrer le Studio V2** pour utiliser AppConfigService
2. **Migrer la HomeScreen** pour lire depuis AppConfig
3. **Créer des règles Firestore** pour sécuriser l'accès
4. **Migrer les données existantes** des anciennes collections
5. **Supprimer les anciennes collections** une fois la migration terminée

## Notes importantes

- ⚠️ Cette PR **N'AJOUTE QUE** les nouveaux fichiers
- ⚠️ Aucune modification des fichiers existants
- ⚠️ HomeScreen et Studio V2 continuent de fonctionner normalement
- ⚠️ Les anciennes collections Firestore restent intactes

## Support et questions

Pour toute question sur cette architecture :
1. Consulter le fichier d'exemples : `app_config_service_example.dart`
2. Vérifier la documentation des méthodes dans `app_config_service.dart`
3. Consulter les modèles dans `app_config.dart`
