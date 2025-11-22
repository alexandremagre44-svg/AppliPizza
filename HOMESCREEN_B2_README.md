# HomeScreenB2 - Guide d'utilisation

## 📋 Vue d'ensemble

HomeScreenB2 est la nouvelle implémentation de l'écran d'accueil basée sur l'architecture AppConfig B2. Cette nouvelle version :

- ✅ Utilise `AppConfigService` pour récupérer la configuration
- ✅ Affiche dynamiquement les sections configurées dans Firestore
- ✅ Réagit aux changements en temps réel
- ✅ N'affecte pas l'ancienne HomeScreen

## 🚀 Accès

### Route
```
/home-b2
```

### Dans le code
```dart
context.go('/home-b2');
```

### Depuis le navigateur (en mode web)
```
http://localhost:xxxx/home-b2
```

## 🏗️ Architecture

### Fichier principal
`lib/src/screens/home/home_screen_b2.dart`

### Dépendances
- `AppConfigService` - Gestion de la configuration
- `AppConfig` et modèles - Structure de configuration
- Widgets existants réutilisés :
  - `HeroBanner` - Bannière hero
  - `HomeShimmerLoading` - État de chargement

### Structure
```dart
HomeScreenB2 (StatefulWidget)
  ├─ AppBar (titre de l'app)
  └─ StreamBuilder<AppConfig?>
      ├─ Loading → HomeShimmerLoading
      ├─ Error → État d'erreur avec bouton Réessayer
      ├─ No Data → État sans config avec bouton Initialiser
      └─ Data → CustomScrollView
          ├─ Welcome Header (texts.welcomeTitle/Subtitle)
          └─ Dynamic Sections (triées par order, filtrées par active)
```

## 📦 Types de sections supportés

### 1. Hero Banner (`HomeSectionType.hero`)
Affiche une grande bannière avec image, titre, sous-titre et bouton CTA.

**Données requises :**
```json
{
  "id": "hero_1",
  "type": "hero",
  "order": 1,
  "active": true,
  "data": {
    "title": "Bienvenue chez Pizza Deli'Zza",
    "subtitle": "La pizza 100% appli",
    "imageUrl": "https://...",
    "ctaLabel": "Voir le menu",
    "ctaTarget": "menu"
  }
}
```

**Widget réutilisé :** `HeroBanner` (existant)

### 2. Promo Banner (`HomeSectionType.promoBanner`)
Affiche une bannière promotionnelle horizontale avec icône.

**Données requises :**
```json
{
  "id": "banner_1",
  "type": "promo_banner",
  "order": 2,
  "active": true,
  "data": {
    "text": "−20% le mardi",
    "backgroundColor": "#D62828",
    "textColor": "#FFFFFF"
  }
}
```

### 3. Popup (`HomeSectionType.popup`)
Les popups ne sont pas affichés comme sections inline. Ils sont gérés séparément au démarrage de l'app.

### 4. Product Grid (`HomeSectionType.productGrid`)
Grille de produits (placeholder pour l'instant).

**Données :**
```json
{
  "id": "products_1",
  "type": "product_grid",
  "order": 3,
  "active": true,
  "data": {
    "title": "Nos Pizzas",
    "productIds": ["prod1", "prod2"]
  }
}
```

### 5. Category List (`HomeSectionType.categoryList`)
Liste de catégories (placeholder pour l'instant).

### 6. Custom (`HomeSectionType.custom`)
Section personnalisée avec affichage debug.

## 🎯 Initialisation de la configuration

### Première utilisation

Si aucune configuration n'existe dans Firestore, HomeScreenB2 affiche un écran avec le bouton "Initialiser la configuration".

**Ce bouton crée automatiquement :**
- Une config par défaut avec 2 sections (hero + banner)
- Des textes par défaut
- Un thème par défaut

### Configuration par défaut créée

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
  }
}
```

## 🔄 Mises à jour en temps réel

HomeScreenB2 utilise un `StreamBuilder` qui écoute les changements dans Firestore :

```dart
StreamBuilder<AppConfig?>(
  stream: _configService.watchConfig(appId: _appId, draft: false),
  builder: (context, snapshot) {
    // L'UI se met à jour automatiquement
  },
)
```

**Avantage :** Toute modification dans le Studio V2 (quand il sera migré) sera visible immédiatement dans HomeScreenB2 après publication.

## 🧪 Tester HomeScreenB2

### 1. Via un bouton de navigation

Ajoutez temporairement un bouton dans le profil ou ailleurs :

```dart
ElevatedButton(
  onPressed: () => context.go('/home-b2'),
  child: const Text('Tester HomeScreen B2'),
)
```

### 2. Via la barre d'adresse (Web)

En mode debug web, tapez directement `/home-b2` dans l'URL.

### 3. En remplaçant temporairement la route `/home`

**ATTENTION : Pour test uniquement, ne pas commiter**

Dans `main.dart`, changez temporairement :

```dart
GoRoute(
  path: AppRoutes.home,
  builder: (context, state) => const HomeScreenB2(), // Au lieu de HomeScreen()
),
```

## 📝 Modifier la configuration

### Option 1 : Via Firestore Console (manuel)

1. Ouvrir Firebase Console
2. Aller dans Firestore Database
3. Naviguer vers : `app_configs/pizza_delizza/configs/config`
4. Modifier les sections, textes ou thème
5. HomeScreenB2 se met à jour automatiquement

### Option 2 : Via AppConfigService (code)

```dart
final service = AppConfigService();

// Récupérer la config actuelle
final config = await service.getConfig(appId: 'pizza_delizza');

// Modifier
final updatedConfig = config.copyWith(
  home: config.home.copyWith(
    texts: TextsConfig(
      welcomeTitle: 'Nouveau titre',
      welcomeSubtitle: 'Nouveau sous-titre',
    ),
  ),
);

// Sauvegarder (production directe)
// Pour l'instant, pas de workflow brouillon sur HomeScreenB2
// On sauvegarde directement en prod pour les tests
await service.saveDraft(appId: 'pizza_delizza', config: updatedConfig);
await service.publishDraft(appId: 'pizza_delizza');
```

### Option 3 : Via Studio V2 (futur)

Quand le Studio V2 sera migré vers AppConfig B2, vous pourrez :
1. Modifier la config en mode brouillon
2. Prévisualiser
3. Publier
4. HomeScreenB2 se mettra à jour automatiquement

## 🔍 Debugging

### Vérifier si la config existe

```dart
final config = await AppConfigService().getConfig(appId: 'pizza_delizza');
print('Config exists: ${config != null}');
if (config != null) {
  print('Sections: ${config.home.sections.length}');
  print('Welcome: ${config.home.texts.welcomeTitle}');
}
```

### Logs dans la console

HomeScreenB2 et AppConfigService loggent les événements importants :
- `AppConfigService: Config not found...`
- `AppConfigService: Error parsing config...`
- `AppConfigService: Draft saved successfully...`

### États visuels

HomeScreenB2 affiche clairement son état :
- **Loading** : HomeShimmerLoading avec animations
- **Error** : Icône d'erreur + message + bouton Réessayer
- **No Config** : Icône settings + bouton Initialiser
- **Success** : Sections affichées dynamiquement

## 🚀 Prochaines étapes

### Court terme
1. ✅ HomeScreenB2 créé et fonctionnel
2. ⏳ Implémenter productGrid avec vrais produits
3. ⏳ Implémenter categoryList avec vraies catégories
4. ⏳ Gérer les popups au démarrage

### Moyen terme
1. Migrer Studio V2 pour éditer AppConfig
2. Ajouter workflow brouillon/publication dans Studio
3. Ajouter preview dans Studio

### Long terme
1. Remplacer HomeScreen par HomeScreenB2
2. Supprimer ancienne HomeScreen
3. Nettoyer anciennes collections Firestore

## 📚 Documentation complémentaire

- **Architecture** : `APPCONFIG_B2_ARCHITECTURE.md`
- **Quick Start** : `APPCONFIG_B2_QUICKSTART.md`
- **Résumé** : `APPCONFIG_B2_IMPLEMENTATION_SUMMARY.md`
- **Exemples** : `lib/src/services/app_config_service_example.dart`

## ❓ FAQ

**Q: HomeScreenB2 affiche "Configuration non trouvée", que faire ?**  
R: Cliquez sur "Initialiser la configuration" ou appelez `initializeDefaultConfig()` via code.

**Q: Les changements Firestore ne se reflètent pas**  
R: Vérifiez que vous modifiez bien `app_configs/pizza_delizza/configs/config` (et pas `config_draft`). HomeScreenB2 lit uniquement la config publiée.

**Q: Comment ajouter une nouvelle section ?**  
R: Modifiez la config via Firestore ou code, ajoutez un objet dans `home.sections` avec un `id` unique, `type`, `order`, et `data` approprié.

**Q: Puis-je utiliser HomeScreenB2 en production ?**  
R: Oui, mais attendez que productGrid et categoryList soient implémentés pour avoir toutes les fonctionnalités. Pour l'instant, c'est une version de test/preview.

**Q: Comment désactiver une section ?**  
R: Mettez `active: false` dans la section. HomeScreenB2 ne l'affichera pas.

## 🎉 Conclusion

HomeScreenB2 est opérationnel et prêt pour les tests ! 

**Pour tester immédiatement :**
1. Naviguez vers `/home-b2`
2. Cliquez sur "Initialiser la configuration"
3. Explorez les sections dynamiques
4. Modifiez la config dans Firestore pour voir les changements en temps réel

**Bon test ! 🚀**
