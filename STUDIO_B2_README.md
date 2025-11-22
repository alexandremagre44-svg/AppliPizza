# Studio B2 - Guide Complet

## 📋 Vue d'ensemble

Studio B2 est la nouvelle interface d'administration pour gérer la configuration AppConfig B2. Cette interface moderne et intuitive permet de gérer l'écran d'accueil sans toucher à Studio V2 existant.

### Caractéristiques principales
- ✅ Interface à 3 onglets (Sections, Textes, Thème)
- ✅ Gestion des sections avec drag & drop
- ✅ Éditeurs spécialisés par type de section
- ✅ Preview live en temps réel
- ✅ Workflow brouillon/publication
- ✅ Auto-sauvegarde automatique
- ✅ 100% indépendant de Studio V2

## 🚀 Accès

### URL
```
/admin/studio-b2
```

### Prérequis
- Authentification admin requise (même protection que Studio V2)
- Configuration AppConfig B2 existante (ou créer un brouillon)

### Navigation
```dart
context.go('/admin/studio-b2');
```

## 🏗️ Architecture

### Structure des fichiers

```
lib/src/admin/studio_b2/
├── studio_b2_page.dart              # Page principale
├── section_list_widget.dart         # Liste des sections
├── texts_editor.dart                # Éditeur de textes
├── theme_editor.dart                # Éditeur de thème
├── preview_panel.dart               # Panneau de preview
└── section_editor/
    ├── section_editor_dialog.dart   # Dialog d'édition
    ├── hero_section_editor.dart     # Éditeur hero
    ├── promo_banner_editor.dart     # Éditeur banner
    └── popup_editor.dart            # Éditeur popup
```

### Fichiers créés (9 fichiers, ~2100 lignes)

1. **studio_b2_page.dart** (389 lignes)
   - Page principale avec StreamBuilder
   - Gestion des onglets
   - Boutons Publier/Recharger
   - Toggle preview

2. **section_list_widget.dart** (280 lignes)
   - ReorderableListView pour drag & drop
   - Ajout/édition/suppression de sections
   - Toggle actif/inactif

3. **texts_editor.dart** (154 lignes)
   - Édition welcomeTitle et welcomeSubtitle

4. **theme_editor.dart** (245 lignes)
   - Édition des couleurs (primary, secondary, accent)
   - Aperçu couleurs en direct
   - Toggle mode sombre

5. **preview_panel.dart** (318 lignes)
   - Affichage HomeScreenB2 en mode draft
   - Mockup téléphone
   - Mise à jour temps réel

6. **section_editor_dialog.dart** (287 lignes)
   - Dialog modal pour créer/éditer sections
   - Sélecteur de type
   - Champs ID, ordre, actif

7. **hero_section_editor.dart** (135 lignes)
   - Formulaire hero banner

8. **promo_banner_editor.dart** (139 lignes)
   - Formulaire bannière promo

9. **popup_editor.dart** (106 lignes)
   - Formulaire popup

## 🎯 Fonctionnalités

### 1. Gestion des Sections

**Onglet "Sections"**

#### Ajouter une section
1. Cliquer sur "Ajouter une section"
2. Remplir le formulaire :
   - ID unique (ex: hero_1, banner_promo)
   - Type de section (hero, promoBanner, popup, etc.)
   - Ordre d'affichage
   - État actif
   - Données spécifiques au type
3. Cliquer "Enregistrer"

#### Réorganiser les sections
- Glisser-déposer les sections pour les réordonner
- L'ordre est sauvegardé automatiquement

#### Éditer une section
- Cliquer sur l'icône crayon
- Modifier les champs
- Enregistrer

#### Activer/Désactiver
- Utiliser le switch à droite de chaque section
- Les sections désactivées n'apparaissent pas dans l'app

#### Supprimer une section
- Cliquer sur l'icône poubelle
- Confirmer la suppression

### 2. Édition des Textes

**Onglet "Textes"**

Champs disponibles :
- **Titre de bienvenue** : Titre principal de l'écran d'accueil
- **Sous-titre de bienvenue** : Texte secondaire

Les modifications sont visibles immédiatement dans la preview.

### 3. Édition du Thème

**Onglet "Thème"**

Configuration des couleurs :
- **Couleur primaire** : Couleur principale de l'app (hex)
- **Couleur secondaire** : Couleur secondaire (hex)
- **Couleur d'accentuation** : Couleur d'accent (hex)
- **Mode sombre** : Toggle pour activer le mode sombre

Chaque champ couleur affiche un aperçu visuel.

### 4. Preview Live

**Panneau de droite**

- Affiche HomeScreenB2 en mode **draft**
- Mise à jour en temps réel
- Mockup téléphone pour visualisation
- Badge "DRAFT" pour indiquer le mode
- Toggle avec icône œil pour masquer/afficher

### 5. Workflow Brouillon/Publication

#### Cycle de travail

1. **Chargement** : Studio B2 charge `config_draft`
2. **Édition** : Modifications sauvegardées automatiquement dans `config_draft`
3. **Preview** : Visualisation en temps réel
4. **Publication** : Bouton "Publier" copie draft → production
5. **Recharger** : Bouton "Recharger" copie production → draft

#### Bouton "Publier"
```dart
- Action : publishDraft(appId: 'pizza_delizza')
- Effet : Copie config_draft vers config
- Version : Auto-incrémente la version
- Feedback : SnackBar de confirmation
```

#### Bouton "Recharger"
```dart
- Action : createDraftFromPublished(appId: 'pizza_delizza')
- Effet : Copie config vers config_draft
- Confirmation : Dialog pour éviter perte de données
- Feedback : SnackBar de confirmation
```

## 📝 Types de Sections

### 1. Hero Banner

**Type** : `hero`

**Champs** :
- `title` : Titre principal
- `subtitle` : Sous-titre
- `imageUrl` : URL de l'image (optionnel)
- `ctaLabel` : Texte du bouton
- `ctaTarget` : Route de navigation (ex: menu, /products)

**Exemple JSON** :
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

### 2. Bannière Promo

**Type** : `promo_banner`

**Champs** :
- `text` : Message promotionnel
- `backgroundColor` : Couleur de fond (hex)
- `textColor` : Couleur du texte (hex)

**Exemple JSON** :
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

### 3. Popup

**Type** : `popup`

**Champs** :
- `title` : Titre du popup
- `content` : Contenu du message
- `showOnAppStart` : Afficher au démarrage (bool)

**Exemple JSON** :
```json
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
```

### 4. Grille de Produits

**Type** : `product_grid`

**Status** : Placeholder (à implémenter)

### 5. Liste de Catégories

**Type** : `category_list`

**Status** : Placeholder (à implémenter)

### 6. Section Personnalisée

**Type** : `custom`

**Status** : Pour extensions futures

## 🔄 Flux de Données

### Architecture

```
Studio B2
    ↓
AppConfigService.watchConfig(draft: true)
    ↓
StreamBuilder (mise à jour automatique)
    ↓
Modifications utilisateur
    ↓
AppConfigService.saveDraft()
    ↓
Firestore: app_configs/pizza_delizza/configs/config_draft
    ↓
Preview Panel (mise à jour automatique)
```

### Publication

```
Studio B2 - Bouton "Publier"
    ↓
AppConfigService.publishDraft()
    ↓
1. Lit config_draft
2. Incrémente version
3. Écrit dans config
    ↓
Firestore: app_configs/pizza_delizza/configs/config
    ↓
HomeScreenB2 (mise à jour automatique)
```

## 🧪 Guide de Test

### Premier lancement

1. **Accéder à Studio B2**
   ```
   /admin/studio-b2
   ```

2. **Si aucun brouillon**
   - Message : "Aucun brouillon"
   - Cliquer : "Créer un brouillon"
   - Studio copie la config publiée → draft

3. **Interface principale**
   - 3 onglets disponibles
   - Preview panel à droite
   - Boutons Publier/Recharger en haut

### Tester les sections

1. **Ajouter une section hero**
   - Onglet Sections → "Ajouter une section"
   - Type : Hero Banner
   - ID : hero_test
   - Remplir les champs
   - Enregistrer
   - Vérifier dans la preview

2. **Réorganiser**
   - Glisser-déposer les sections
   - Observer la preview se mettre à jour

3. **Désactiver une section**
   - Toggle le switch
   - La section disparaît de la preview

### Tester textes et thème

1. **Modifier les textes**
   - Onglet Textes
   - Changer le titre
   - Cliquer "Enregistrer"
   - Observer la preview

2. **Modifier les couleurs**
   - Onglet Thème
   - Changer la couleur primaire
   - Observer le preview de couleur
   - Enregistrer

### Tester publication

1. **Publier**
   - Cliquer "Publier"
   - Attendre confirmation
   - Vérifier que HomeScreenB2 (production) a changé

2. **Recharger**
   - Modifier le draft
   - Cliquer "Recharger"
   - Confirmer
   - Les modifications sont perdues

## 🐛 Debugging

### Vérifier l'état du brouillon

```dart
final service = AppConfigService();
final draft = await service.getConfig(appId: 'pizza_delizza', draft: true);
print('Draft exists: ${draft != null}');
print('Sections: ${draft?.home.sections.length}');
```

### Vérifier la version

```dart
final draftVersion = await service.getConfigVersion(appId: 'pizza_delizza', draft: true);
final prodVersion = await service.getConfigVersion(appId: 'pizza_delizza', draft: false);
print('Draft: v$draftVersion, Prod: v$prodVersion');
```

### Logs dans la console

Studio B2 logue tous les événements importants :
- `AppConfigService: Draft saved successfully...`
- `AppConfigService: Draft published successfully...`
- `AppConfigService: Draft created from published...`

### États visuels

Studio B2 affiche clairement son état :
- **Loading** : CircularProgressIndicator
- **No Draft** : Message + bouton "Créer un brouillon"
- **Error** : Icône d'erreur + message + bouton Réessayer
- **Success** : Interface complète avec onglets

## 🎨 Personnalisation

### Ajouter un nouvel éditeur de section

1. Créer `lib/src/admin/studio_b2/section_editor/my_section_editor.dart`

```dart
class MySectionEditor extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;
  
  // Implémenter l'éditeur
}
```

2. Ajouter dans `section_editor_dialog.dart`

```dart
case HomeSectionType.myType:
  return MySectionEditor(
    data: _data,
    onDataChanged: (newData) {
      setState(() {
        _data = newData;
      });
    },
  );
```

### Modifier les couleurs du Studio

Modifier dans `studio_b2_page.dart` :

```dart
AppBar(
  backgroundColor: AppColors.primaryRed, // Changer ici
  // ...
)
```

## ❓ FAQ

**Q: Studio B2 affiche "Aucun brouillon", que faire ?**  
R: Cliquez sur "Créer un brouillon". Studio B2 copiera automatiquement la configuration publiée.

**Q: Les modifications ne se reflètent pas dans HomeScreenB2 production**  
R: C'est normal ! Studio B2 modifie le **brouillon**. Utilisez le bouton "Publier" pour envoyer vers la production.

**Q: Comment annuler mes modifications ?**  
R: Cliquez sur "Recharger". Cela recharge le brouillon depuis la version publiée (vos modifications seront perdues).

**Q: Puis-je utiliser Studio B2 et Studio V2 en même temps ?**  
R: Oui ! Ils sont complètement indépendants. Studio V2 gère les anciennes collections, Studio B2 gère AppConfig.

**Q: Comment ajouter un nouveau type de section ?**  
R: Ajoutez le type dans `HomeSectionType` enum, puis créez un éditeur dans `section_editor/`.

**Q: La preview ne se met pas à jour**  
R: Vérifiez que vous êtes bien en mode "draft" et que StreamBuilder fonctionne. Regardez les logs console.

## 🚀 Prochaines Étapes

### Court terme
1. ✅ Studio B2 créé et fonctionnel
2. ⏳ Implémenter éditeurs productGrid et categoryList
3. ⏳ Ajouter filtres et recherche dans sections
4. ⏳ Historique des versions

### Moyen terme
1. Ajouter preview responsive (différentes tailles)
2. Export/Import de configuration
3. Templates de sections
4. Validation avancée

### Long terme
1. Migration complète vers Studio B2
2. Suppression de Studio V2
3. Multi-tenant complet (plusieurs restaurants)
4. Analytics d'utilisation des sections

## 📚 Ressources

- **AppConfig B2** : `APPCONFIG_B2_ARCHITECTURE.md`
- **HomeScreenB2** : `HOMESCREEN_B2_README.md`
- **Quick Start** : `APPCONFIG_B2_QUICKSTART.md`

## 🎉 Conclusion

Studio B2 est opérationnel et prêt pour la gestion complète de l'écran d'accueil !

**Pour commencer :**
1. Naviguez vers `/admin/studio-b2`
2. Créez un brouillon si nécessaire
3. Ajoutez/modifiez des sections
4. Visualisez dans la preview
5. Publiez quand vous êtes satisfait

**Bon studio ! 🎨**
