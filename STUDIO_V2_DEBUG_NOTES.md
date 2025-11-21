# Studio V2 - Audit Technique et Corrections

## Date: 2025-01-21
## Objectif: Fixer le pipeline Studio V2 → Firestore → HomeScreen → Preview

---

## 1. LOCALISATION DU STUDIO V2 OFFICIEL ✅

### Écran principal
**Fichier:** `/lib/src/studio/screens/studio_v2_screen.dart`
**Route:** `/admin/studio/v2`

### Contrôleur / Provider
**Fichier:** `/lib/src/studio/controllers/studio_state_controller.dart`

**Provider principal:** `studioDraftStateProvider`
- Type: `StateNotifierProvider<StudioDraftStateNotifier, StudioDraftState>`
- Gère l'état brouillon (draft) local avant publication

**État géré:**
```dart
class StudioDraftState {
  final HomeConfig? homeConfig;           // Hero: titre, sous-titre, image, CTA
  final HomeLayoutConfig? layoutConfig;   // Layout: sections order, thème
  final List<BannerConfig> banners;
  final List<PopupV2Model> popupsV2;
  final List<TextBlockModel> textBlocks;
  final List<DynamicSection> dynamicSections;
  final bool hasUnsavedChanges;
}
```

### Modules disponibles
1. **Overview** (`studio_overview_v2.dart`) - Dashboard
2. **Hero** (`studio_hero_v2.dart`) - Section hero (titre, sous-titre, image, CTA)
3. **Banners** (`studio_banners_v2.dart`) - Bandeaux info
4. **Popups** (`studio_popups_v2.dart`) - Popups V2
5. **Texts** (`studio_texts_v2.dart`) - Blocs de texte dynamiques
6. **Settings** (`studio_settings_v2.dart`) - Paramètres globaux et ordre des sections

---

## 2. PIPELINE "PUBLISH" → FIRESTORE ✅

### Fonction de publication
**Fichier:** `/lib/src/studio/screens/studio_v2_screen.dart`
**Fonction:** `_publishChanges()` (ligne 117)

### Documents Firestore écrits

#### A. Hero (titre, sous-titre, image, CTA)
- **Collection:** `app_home_config`
- **Document:** `main`
- **Service:** `HomeConfigService` (`/lib/src/services/home_config_service.dart`)
- **Méthode:** `saveHomeConfig(HomeConfig config)`
- **Champs:**
  ```json
  {
    "hero": {
      "title": "Texte du titre",
      "subtitle": "Texte du sous-titre",
      "imageUrl": "https://...",
      "ctaText": "Texte du bouton",
      "ctaAction": "/menu",
      "isActive": true
    },
    "updatedAt": "2025-01-21T..."
  }
  ```

#### B. Layout (sections order, thème)
- **Collection:** `config`
- **Document:** `home_layout`
- **Service:** `HomeLayoutService` (`/lib/src/services/home_layout_service.dart`)
- **Méthode:** `saveHomeLayout(HomeLayoutConfig config)`
- **Champs:**
  ```json
  {
    "studioEnabled": true,
    "sectionsOrder": ["hero", "banner", "popups"],
    "sectionsEnabled": {
      "hero": true,
      "banner": true,
      "popups": true
    },
    "updatedAt": "2025-01-21T..."
  }
  ```
  **NOTE:** Pas de champ `darkMode` ou `themeMode` dans `HomeLayoutConfig` actuellement

#### C. Banners
- **Collection:** `app_banners`
- **Documents:** `{bannerId}` (multiples)
- **Service:** `BannerService` (`/lib/src/services/banner_service.dart`)
- **Méthode:** `saveAllBanners(List<BannerConfig> banners)`

#### D. Text Blocks
- **Collection:** `config`
- **Document:** `text_blocks`
- **Service:** `TextBlockService` (`/lib/src/studio/services/text_block_service.dart`)

#### E. Popups V2
- **Collection:** `config`
- **Document:** `popups_v2`
- **Service:** `PopupV2Service` (`/lib/src/studio/services/popup_v2_service.dart`)

### Logs ajoutés lors de la publication
```dart
// STUDIO V2 PUBLISH → Saving to Firestore
print('STUDIO V2 PUBLISH → Saving homeConfig to app_home_config/main');
print('STUDIO V2 PUBLISH → Saving layoutConfig to config/home_layout');
print('STUDIO V2 PUBLISH → Hero title: ${draftState.homeConfig?.heroTitle}');
print('STUDIO V2 PUBLISH → Hero subtitle: ${draftState.homeConfig?.heroSubtitle}');
```

---

## 3. LECTURE DANS HOMESCREEN (APP RÉELLE) ✅

### Écran HomeScreen
**Fichier:** `/lib/src/screens/home/home_screen.dart`

### Providers utilisés par HomeScreen

#### A. homeConfigProvider
- **Fichier:** `/lib/src/providers/home_config_provider.dart`
- **Type:** `StreamProvider<HomeConfig?>`
- **Lecture:** Collection `app_home_config`, document `main` ✅ MATCH
- **Usage:**
  ```dart
  final homeConfigAsync = ref.watch(homeConfigProvider);
  ```

#### B. homeLayoutProvider
- **Fichier:** `/lib/src/providers/home_layout_provider.dart`
- **Type:** `StreamProvider<HomeLayoutConfig?>`
- **Lecture:** Collection `config`, document `home_layout` ✅ MATCH
- **Usage:**
  ```dart
  final homeLayoutAsync = ref.watch(homeLayoutProvider);
  ```

### Affichage du Hero dans HomeScreen
**Méthode:** `_buildHeroSection()` (ligne 368)
```dart
HeroBanner(
  title: homeConfig?.hero?.title,      // ← Lit depuis Firestore
  subtitle: homeConfig?.hero?.subtitle,
  buttonText: homeConfig?.hero?.ctaText,
  imageUrl: homeConfig?.hero?.imageUrl,
  ...
)
```

### Vérification: ✅ HARMONISATION OK
- Studio V2 écrit dans `app_home_config/main` et `config/home_layout`
- HomeScreen lit depuis `app_home_config/main` et `config/home_layout`
- **Pas de désynchronisation entre Studio V2 et HomeScreen**

---

## 4. ALIGNER LA PREVIEW SUR HOMESCREEN ⚠️ PROBLÈME TROUVÉ

### Preview actuelle
**Fichier:** `/lib/src/studio/widgets/studio_preview_panel.dart`

**Problème identifié:**
- La preview utilise un widget **simplifié** et **custom**
- Elle ne réutilise **PAS** le widget `HomeScreen` réel
- Elle reconstruit manuellement la UI (ligne 112-185)
- **Conséquence:** Preview ≠ Rendu réel

### Solution requise
Il existe déjà un widget avancé: `/lib/src/studio/preview/admin_home_preview_advanced.dart`
- Ce widget utilise `ProviderScope` avec overrides
- Il affiche le **vrai** `HomeScreen`
- Il permet de simuler l'état draft

**Action à faire:**
1. Remplacer `StudioPreviewPanel` par `AdminHomePreviewAdvanced` dans Studio V2
2. Passer les données draft via les overrides de providers
3. Utiliser `PreviewStateOverrides.createOverrides()` pour injecter l'état brouillon

---

## 5. FIX DES PROBLÈMES RIVERPOD / LIFECYCLES ✅

### Studio V2 Screen (DÉJÀ CORRIGÉ)
**Fichier:** `/lib/src/studio/screens/studio_v2_screen.dart`

**Ligne 67-69:**
```dart
@override
void initState() {
  super.initState();
  // FIX: Riverpod provider updates must be deferred using Future.microtask
  // to avoid "Modifying a provider inside widget lifecycle" error
  Future.microtask(() => _loadAllData());
}
```

**Ligne 99-107:**
```dart
// Initialize draft state
// FIX: This provider update is safe because it's called via Future.microtask
ref.read(studioDraftStateProvider.notifier).loadInitialState(
  homeConfig: _publishedHomeConfig,
  layoutConfig: _publishedLayoutConfig,
  ...
);
```

### Modules à vérifier
- ✅ `studio_hero_v2.dart` - Utilise uniquement callbacks (`onUpdate`), pas d'écritures dans build/initState
- ✅ `studio_banners_v2.dart` - Utilise callbacks
- ✅ `studio_popups_v2.dart` - Utilise callbacks
- ✅ `studio_texts_v2.dart` - Utilise callbacks
- ✅ `studio_settings_v2.dart` - Utilise callbacks

**Conclusion:** Tous les modules suivent le pattern correct

---

## 6. TESTS À EFFECTUER APRÈS CORRECTION

### Test Cas 1: Titre Hero
1. Ouvrir Studio V2 (`/admin/studio/v2`)
2. Aller dans module "Hero"
3. Changer le titre de "Bienvenue" → "Nouvelle Pizza!"
4. **Vérifier:** Preview affiche "Nouvelle Pizza!" immédiatement ✅
5. Cliquer "Publier"
6. **Vérifier:** Console log: `STUDIO V2 PUBLISH → Hero title: Nouvelle Pizza!`
7. Recharger l'app (F5)
8. **Vérifier:** HomeScreen affiche "Nouvelle Pizza!" ✅

### Test Cas 2: Mode sombre / Thème
⚠️ **PROBLÈME TROUVÉ:** `HomeLayoutConfig` ne contient PAS de champ `darkMode`

**Structure actuelle:**
```dart
class HomeLayoutConfig {
  final bool studioEnabled;
  final List<String> sectionsOrder;
  final Map<String, bool> sectionsEnabled;
  final DateTime updatedAt;
}
```

**Action requise:**
- Ajouter un champ `themeMode` dans `HomeLayoutConfig`
- Ajouter un toggle dans module Settings
- Appliquer le thème dans HomeScreen via un provider

---

## RÉSUMÉ DES PROBLÈMES TROUVÉS

### ✅ Fonctionnels
1. Pipeline Studio V2 → Firestore → HomeScreen est correct
2. Riverpod lifecycles sont gérés correctement
3. Services écrivent et lisent depuis les mêmes collections

### ⚠️ À corriger
1. **Preview n'utilise pas le vrai HomeScreen**
   - Solution: Intégrer `AdminHomePreviewAdvanced` avec overrides
2. **Pas de gestion du thème sombre**
   - Solution: Ajouter `themeMode` dans `HomeLayoutConfig`
3. **Logs manquants pour debugging**
   - Solution: Ajouter des logs détaillés dans publish pipeline

---

## PROCHAINES ÉTAPES

1. ✅ Créer ce document d'audit
2. ⏳ Ajouter logs détaillés dans `_publishChanges()`
3. ⏳ Remplacer preview par `AdminHomePreviewAdvanced`
4. ⏳ Ajouter support thème sombre (si demandé)
5. ⏳ Tester le cycle complet publish → reload

---

**Auteur:** Copilot Agent  
**Date:** 2025-01-21  
**Version:** 1.0
