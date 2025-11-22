# Guide de démarrage rapide - AppConfig B2

## 🚀 Démarrage en 5 minutes

### Pour l'app cliente (Mobile)

#### 1. Initialiser la configuration (une seule fois)
```dart
import 'package:pizza_delizza/src/services/app_config_service.dart';

final configService = AppConfigService();
await configService.initializeDefaultConfig(appId: 'pizza_delizza');
```

#### 2. Lire la configuration
```dart
final config = await configService.getConfig(appId: 'pizza_delizza');
if (config != null) {
  print('Titre: ${config.home.texts.welcomeTitle}');
  print('Couleur principale: ${config.home.theme.primaryColor}');
  print('Nombre de sections: ${config.home.sections.length}');
}
```

#### 3. Écouter les changements en temps réel
```dart
configService.watchConfig(appId: 'pizza_delizza').listen((config) {
  if (config != null) {
    // Mettre à jour l'UI automatiquement
    setState(() {
      _welcomeTitle = config.home.texts.welcomeTitle;
      _primaryColor = config.home.theme.primaryColor;
    });
  }
});
```

---

### Pour le Studio V2 (Admin)

#### 1. Créer un brouillon depuis la version publiée
```dart
await configService.createDraftFromPublished(appId: 'pizza_delizza');
```

#### 2. Récupérer et modifier le brouillon
```dart
// Récupérer
var draft = await configService.getConfig(
  appId: 'pizza_delizza',
  draft: true,
);

// Modifier
draft = draft.copyWith(
  home: draft.home.copyWith(
    texts: TextsConfig(
      welcomeTitle: 'Nouveau Titre',
      welcomeSubtitle: 'Nouveau sous-titre',
    ),
    theme: draft.home.theme.copyWith(
      primaryColor: '#FF5722',
    ),
  ),
);

// Sauvegarder
await configService.saveDraft(appId: 'pizza_delizza', config: draft);
```

#### 3. Publier le brouillon
```dart
await configService.publishDraft(appId: 'pizza_delizza');
// La version est automatiquement incrémentée
```

---

## 📋 Exemples pratiques

### Ajouter une section popup
```dart
import 'package:pizza_delizza/src/models/app_config.dart';

// Récupérer le brouillon
var draft = await configService.getConfig(
  appId: 'pizza_delizza',
  draft: true,
);

// Créer la nouvelle section
final newSection = HomeSectionConfig(
  id: 'popup_allergens',
  type: HomeSectionType.popup,
  order: 0,
  active: true,
  data: {
    'title': 'Allergènes',
    'content': 'Nos pizzas peuvent contenir des traces d\'allergènes...',
    'showOnAppStart': true,
  },
);

// Ajouter aux sections existantes
final updatedSections = [...draft.home.sections, newSection];

// Mettre à jour la config
draft = draft.copyWith(
  home: draft.home.copyWith(sections: updatedSections),
);

// Sauvegarder
await configService.saveDraft(appId: 'pizza_delizza', config: draft);
```

### Modifier le thème
```dart
var draft = await configService.getConfig(
  appId: 'pizza_delizza',
  draft: true,
);

draft = draft.copyWith(
  home: draft.home.copyWith(
    theme: ThemeConfigV2(
      primaryColor: '#3F51B5',
      secondaryColor: '#FF4081',
      accentColor: '#FFFFFF',
      darkMode: true,
    ),
  ),
);

await configService.saveDraft(appId: 'pizza_delizza', config: draft);
```

### Modifier une section existante
```dart
var draft = await configService.getConfig(
  appId: 'pizza_delizza',
  draft: true,
);

// Trouver et modifier la section hero
final updatedSections = draft.home.sections.map((section) {
  if (section.id == 'hero_1') {
    return section.copyWith(
      data: {
        ...section.data,
        'title': 'Nouveau titre hero',
        'imageUrl': 'https://example.com/hero.jpg',
      },
    );
  }
  return section;
}).toList();

draft = draft.copyWith(
  home: draft.home.copyWith(sections: updatedSections),
);

await configService.saveDraft(appId: 'pizza_delizza', config: draft);
```

---

## 🎯 Types de sections disponibles

### 1. Hero Banner
```dart
HomeSectionConfig(
  id: 'hero_1',
  type: HomeSectionType.hero,
  order: 1,
  active: true,
  data: {
    'title': 'Bienvenue',
    'subtitle': 'La meilleure pizza',
    'imageUrl': 'https://...',
    'ctaLabel': 'Commander',
    'ctaTarget': 'menu',
  },
)
```

### 2. Promo Banner
```dart
HomeSectionConfig(
  id: 'banner_1',
  type: HomeSectionType.promoBanner,
  order: 2,
  active: true,
  data: {
    'text': '−20% le mardi',
    'backgroundColor': '#D62828',
    'textColor': '#FFFFFF',
  },
)
```

### 3. Popup
```dart
HomeSectionConfig(
  id: 'popup_1',
  type: HomeSectionType.popup,
  order: 0,
  active: true,
  data: {
    'title': 'Info',
    'content': 'Contenu du popup...',
    'showOnAppStart': true,
    'imageUrl': 'https://...',  // optionnel
  },
)
```

### 4. Product Grid
```dart
HomeSectionConfig(
  id: 'products_1',
  type: HomeSectionType.productGrid,
  order: 3,
  active: true,
  data: {
    'title': 'Nos Pizzas',
    'productIds': ['prod1', 'prod2', 'prod3'],
    'columns': 2,
  },
)
```

---

## 🔧 Utilitaires

### Vérifier si un brouillon existe
```dart
final hasDraft = await configService.hasDraft(appId: 'pizza_delizza');
if (!hasDraft) {
  // Créer un nouveau brouillon
  await configService.createDraftFromPublished(appId: 'pizza_delizza');
}
```

### Obtenir la version
```dart
final publishedVersion = await configService.getConfigVersion(
  appId: 'pizza_delizza',
  draft: false,
);
final draftVersion = await configService.getConfigVersion(
  appId: 'pizza_delizza',
  draft: true,
);
print('Published: v$publishedVersion, Draft: v$draftVersion');
```

### Supprimer un brouillon
```dart
await configService.deleteDraft(appId: 'pizza_delizza');
```

---

## 📱 Intégration dans un widget

### Exemple avec StatefulWidget
```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _configService = AppConfigService();
  AppConfig? _config;
  
  @override
  void initState() {
    super.initState();
    _loadConfig();
    _watchConfig();
  }
  
  void _loadConfig() async {
    final config = await _configService.getConfig(appId: 'pizza_delizza');
    setState(() => _config = config);
  }
  
  void _watchConfig() {
    _configService.watchConfig(appId: 'pizza_delizza').listen((config) {
      if (mounted && config != null) {
        setState(() => _config = config);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_config == null) {
      return CircularProgressIndicator();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_config!.home.texts.welcomeTitle),
      ),
      body: ListView.builder(
        itemCount: _config!.home.sections.length,
        itemBuilder: (context, index) {
          final section = _config!.home.sections[index];
          if (!section.active) return SizedBox.shrink();
          
          switch (section.type) {
            case HomeSectionType.hero:
              return _buildHeroSection(section);
            case HomeSectionType.promoBanner:
              return _buildPromoBanner(section);
            case HomeSectionType.popup:
              // Les popups sont gérés séparément
              return SizedBox.shrink();
            default:
              return SizedBox.shrink();
          }
        },
      ),
    );
  }
  
  Widget _buildHeroSection(HomeSectionConfig section) {
    return Container(
      child: Column(
        children: [
          Text(section.data['title'] ?? ''),
          Text(section.data['subtitle'] ?? ''),
          // ... etc
        ],
      ),
    );
  }
  
  Widget _buildPromoBanner(HomeSectionConfig section) {
    return Container(
      color: Color(int.parse(
        section.data['backgroundColor'].replaceAll('#', 'FF'),
        radix: 16,
      )),
      child: Text(section.data['text'] ?? ''),
    );
  }
}
```

---

## 🎓 Pour aller plus loin

- **Architecture complète** : `APPCONFIG_B2_ARCHITECTURE.md`
- **Résumé d'implémentation** : `APPCONFIG_B2_IMPLEMENTATION_SUMMARY.md`
- **Exemples avancés** : `lib/src/services/app_config_service_example.dart`
- **Code des modèles** : `lib/src/models/app_config.dart`
- **Code du service** : `lib/src/services/app_config_service.dart`

---

## ❓ FAQ

**Q: Où est stockée la configuration ?**  
R: Dans Firestore, sous `app_configs/{appId}/configs/config` (publiée) et `config_draft` (brouillon).

**Q: Comment gérer plusieurs restaurants ?**  
R: Utilisez un appId différent pour chaque restaurant : `'pizza_delizza'`, `'restaurant_mario'`, etc.

**Q: Que se passe-t-il si je modifie le brouillon ?**  
R: Rien ! Les modifications du brouillon n'affectent pas l'app en production jusqu'à publication.

**Q: Comment revenir en arrière après une publication ?**  
R: Utilisez `createDraftFromPublished()` pour créer un brouillon de l'ancienne version, modifiez-le, puis republiez.

**Q: Puis-je ajouter mes propres types de sections ?**  
R: Oui ! Utilisez `HomeSectionType.custom` et définissez vos propres champs dans le `data`.

---

## 🆘 Aide

En cas de problème :
1. Vérifiez les logs (tous les appels sont loggés)
2. Consultez les exemples dans `app_config_service_example.dart`
3. Vérifiez que Firebase est bien initialisé
4. Vérifiez les règles Firestore (à venir dans une prochaine PR)
