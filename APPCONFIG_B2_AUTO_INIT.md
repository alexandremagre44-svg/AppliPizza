# AppConfig B2 - Auto-Initialisation

## 📋 Vue d'ensemble

AppConfigService gère automatiquement la création de configurations par défaut lorsqu'aucune configuration n'existe dans Firestore. Ce mécanisme élimine les erreurs au premier lancement et simplifie l'initialisation.

## 🎯 Problème résolu

**Avant** :
```
Error: No published configuration found for appId: pizza_delizza
```

**Après** :
- Création automatique de la configuration par défaut
- Aucune erreur, workflow fluide
- Studio B2 fonctionne immédiatement

## 🔧 Nouvelles Méthodes

### 1. `getDefaultConfig(String appId)`

Retourne une configuration complète et minimale.

```dart
final service = AppConfigService();
final defaultConfig = service.getDefaultConfig('pizza_delizza');
```

**Contenu de la config par défaut** :
- **Section hero** : "Bienvenue chez Pizza Deli'Zza"
- **Section banner** : "−20% le mardi" (inactive)
- **Textes** : welcomeTitle + welcomeSubtitle
- **Thème** : Couleurs Pizza Deli'Zza (#D62828)
- **Menu** : Vide
- **Branding** : Vide
- **Legal** : Vide
- **Modules** : Roulette désactivée

### 2. `ensurePublishedExists(String appId)`

Crée la configuration publiée si elle n'existe pas.

```dart
await service.ensurePublishedExists(appId: 'pizza_delizza');
```

**Comportement** :
- Si config existe → Ne fait rien (safe)
- Si config n'existe pas → Crée config par défaut dans `config`
- Idempotent : peut être appelé plusieurs fois sans danger

### 3. `ensureDraftExists(String appId)`

Crée le brouillon si il n'existe pas. **Méthode recommandée pour Studio B2**.

```dart
await service.ensureDraftExists(appId: 'pizza_delizza');
```

**Comportement intelligent** :

| Situation | Action |
|-----------|--------|
| Draft existe | ✅ Ne fait rien |
| Draft absent, Published existe | ✅ Copie published → draft |
| Draft absent, Published absent | ✅ Crée défaut dans les 2 |

**Avantages** :
- Une seule méthode pour tous les cas
- Jamais d'erreur
- Toujours un draft disponible après l'appel

## 🔄 Modifications Existantes

### `getConfig()` - Enhanced

Nouveau paramètre optionnel `autoCreate` (default: `true`).

```dart
// Auto-création activée (défaut)
final config = await service.getConfig(appId: 'pizza_delizza');
// Retourne toujours une config, crée si nécessaire

// Sans auto-création
final config = await service.getConfig(
  appId: 'pizza_delizza',
  autoCreate: false,
);
// Retourne null si config n'existe pas
```

**Logique** :
```
1. Cherche config dans Firestore
2. Si trouvée → retourne
3. Si pas trouvée ET autoCreate=true :
   - Pour published : crée config par défaut
   - Pour draft : copie published OU crée par défaut
4. Si pas trouvée ET autoCreate=false : retourne null
```

### `createDraftFromPublished()` - Safe

Ne lance plus d'exception si la config publiée n'existe pas.

```dart
await service.createDraftFromPublished(appId: 'pizza_delizza');
// Fonctionne toujours, même si published n'existe pas
```

**Nouveau comportement** :
```
1. Cherche published config
2. Si trouvée → copie vers draft
3. Si pas trouvée → crée défaut dans published ET draft
4. Jamais d'erreur
```

## 🎨 Utilisation dans Studio B2

### Avant (problématique)

```dart
// Pouvait crasher si published n'existait pas
await _configService.createDraftFromPublished(appId: _appId);
```

### Après (safe)

```dart
// Toujours safe, gère tous les cas
await _configService.ensureDraftExists(appId: _appId);
```

### Bouton "Créer un brouillon"

```dart
Future<void> _handleCreateDraft() async {
  try {
    // Une seule ligne, gère tout automatiquement
    await _configService.ensureDraftExists(appId: _appId);
    
    // Success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Brouillon créé avec succès'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  } catch (e) {
    // Erreur très improbable maintenant
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur: $e'),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }
}
```

### Bouton "Recharger"

```dart
Future<void> _handleRevertToPublished() async {
  // Confirmation dialog...
  
  if (confirmed) {
    try {
      // Supprime le draft existant
      await _configService.deleteDraft(appId: _appId);
      
      // Recrée depuis published (ou crée par défaut si absent)
      await _configService.ensureDraftExists(appId: _appId);
      
      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brouillon rechargé'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      // Gestion erreur...
    }
  }
}
```

## 📱 Utilisation dans HomeScreenB2

HomeScreenB2 bénéficie automatiquement de l'auto-création.

```dart
StreamBuilder<AppConfig?>(
  stream: _configService.watchConfig(appId: _appId, draft: false),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      // Pas de config → Affiche bouton initialisation
      return _buildNoConfigState();
    }
    
    // Config existe (créée automatiquement si besoin)
    return _buildContent(snapshot.data!);
  },
)
```

Avec le bouton d'initialisation :

```dart
ElevatedButton(
  onPressed: () async {
    // Crée config published si absente
    await _configService.ensurePublishedExists(appId: _appId);
    setState(() {}); // Refresh
  },
  child: const Text('Initialiser la configuration'),
)
```

## 🧪 Scénarios de Test

### Scénario 1 : Firestore vide (première installation)

**Actions** :
1. Naviguer vers `/admin/studio-b2`
2. Cliquer "Créer un brouillon"

**Résultat** :
- ✅ Config publiée créée dans `app_configs/pizza_delizza/configs/config`
- ✅ Config draft créée dans `app_configs/pizza_delizza/configs/config_draft`
- ✅ Studio B2 charge et affiche le draft
- ✅ Preview affiche le contenu par défaut

**Vérification Firestore** :
```
app_configs/
  pizza_delizza/
    configs/
      config         ← Créé avec version: 1
      config_draft   ← Créé avec version: 1
```

### Scénario 2 : Config publiée existe, pas de draft

**État initial** :
- `config` existe
- `config_draft` n'existe pas

**Actions** :
1. Naviguer vers `/admin/studio-b2`
2. Cliquer "Créer un brouillon"

**Résultat** :
- ✅ Config publiée préservée
- ✅ Draft créé en copiant published
- ✅ Studio charge le draft

### Scénario 3 : Les deux existent

**État initial** :
- `config` existe
- `config_draft` existe

**Actions** :
1. Naviguer vers `/admin/studio-b2`

**Résultat** :
- ✅ Charge directement le draft
- ✅ Aucun bouton "Créer un brouillon"
- ✅ Interface prête à éditer

### Scénario 4 : HomeScreenB2 avec Firestore vide

**Actions** :
1. Naviguer vers `/home-b2`
2. Pas de config → Affiche "Configuration non trouvée"
3. Cliquer "Initialiser la configuration"

**Résultat** :
- ✅ Config publiée créée
- ✅ HomeScreenB2 se refresh et affiche le contenu
- ✅ Sections par défaut visibles

## 🔐 Sécurité et Performance

### Idempotence

Toutes les méthodes `ensure*` sont idempotentes :

```dart
// Appeler plusieurs fois est safe
await service.ensureDraftExists(appId: 'pizza_delizza');
await service.ensureDraftExists(appId: 'pizza_delizza');
await service.ensureDraftExists(appId: 'pizza_delizza');
// Résultat : une seule config créée
```

### Performance

- Vérification d'existence avant création (pas d'écriture inutile)
- Logs clairs pour debugging
- Pas de boucle infinie possible

### Gestion d'erreurs

```dart
try {
  await service.ensureDraftExists(appId: 'pizza_delizza');
} catch (e) {
  // Erreur réseau Firestore, permissions, etc.
  print('Error: $e');
  // Gérer l'erreur...
}
```

Les seules erreurs possibles maintenant :
- Erreurs réseau
- Erreurs de permissions Firestore
- Erreurs de sérialisation (très improbable)

**Plus d'erreur "No published configuration found"** ✅

## 📊 Configuration par Défaut Détaillée

### Structure complète

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
      "enabled": false,
      "config": {}
    }
  },
  "createdAt": "2025-11-22T...",
  "updatedAt": "2025-11-22T..."
}
```

### Pourquoi ces valeurs par défaut ?

- **Hero actif** : Toujours utile d'avoir une bannière d'accueil
- **Banner inactif** : Optionnel, à activer selon promo
- **Textes Pizza Deli'Zza** : Nom du projet, facile à changer
- **Thème rouge** : Couleur signature pizzeria
- **Roulette désactivée** : Module optionnel, activer manuellement

## 🎯 Migrations et Compatibilité

### Depuis Studio V2

L'auto-initialisation ne touche **pas** aux collections Studio V2 existantes.

**Collections préservées** :
- `home_config`
- `home_layout_config`
- `app_texts`
- `theme_config`
- Etc.

**Nouvelle collection** :
- `app_configs` (utilisée uniquement par B2)

### Compatibilité ascendante

Le paramètre `autoCreate` permet de désactiver l'auto-création :

```dart
// Comportement ancien (retourne null si absent)
final config = await service.getConfig(
  appId: 'pizza_delizza',
  autoCreate: false,
);

if (config == null) {
  // Gérer absence manuellement
}
```

## ❓ FAQ

**Q: Que se passe-t-il si je supprime les configs Firestore ?**  
R: Elles seront recréées automatiquement au prochain accès (published) ou au prochain draft (draft).

**Q: Puis-je personnaliser la config par défaut ?**  
R: Oui, modifiez `AppConfig.initial()` dans `app_config.dart` ou appelez `getDefaultConfig()` et modifiez avant de sauvegarder.

**Q: L'auto-création affecte-t-elle les performances ?**  
R: Non. Vérification d'existence avant création, et création unique (idempotent).

**Q: Puis-je forcer la recréation d'une config ?**  
R: Supprimez-la dans Firestore ou appelez `deleteDraft()` puis `ensureDraftExists()`.

**Q: Est-ce safe en production ?**  
R: Oui. Testé, idempotent, gestion d'erreurs complète, logs détaillés.

## 🚀 Conclusion

L'auto-initialisation simplifie grandement le workflow :

**Avant** :
1. Vérifier si config existe
2. Si non, initialiser manuellement
3. Gérer les erreurs
4. Retenter
5. Frustration 😤

**Après** :
1. Appeler `ensureDraftExists()`
2. Ça marche ✨

**Résultat** : Studio B2 "just works", même sur Firestore vide. Expérience développeur améliorée, moins d'erreurs, workflow fluide.
