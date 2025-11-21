# Studio V2 - Guide de Test Post-Correction

## Date: 2025-01-21
## Version: 1.0

Ce document explique comment tester les corrections apportées au pipeline Studio V2 → Firestore → HomeScreen.

---

## 🎯 Objectifs de Test

Valider que:
1. La preview reflète immédiatement les modifications (mode brouillon)
2. Le bouton "Publier" enregistre correctement dans Firestore
3. L'application réelle (HomeScreen) affiche les modifications après publication
4. Les logs aident au debugging

---

## ✅ Test Cas 1: Modification du Titre Hero

### Étape par étape

1. **Ouvrir Studio V2**
   ```
   Route: /admin/studio/v2
   Pré-requis: Être connecté en tant qu'administrateur
   ```

2. **Naviguer vers le module Hero**
   - Cliquer sur "Hero" dans la navigation gauche
   - L'éditeur Hero doit s'afficher au centre

3. **Modifier le titre**
   - Champ: "Titre principal"
   - Remplacer par: "🍕 Nouvelle Pizza Delizza!"
   - Observer le panneau de preview à droite

4. **Vérification Preview (TEMPS RÉEL)**
   ```
   ✅ Attendu: Le titre change IMMÉDIATEMENT dans la preview
   ✅ Attendu: Badge orange "Mode brouillon" visible
   ✅ Attendu: Badge "Modifications non publiées" dans la navigation
   ```

5. **Modifier le sous-titre**
   - Champ: "Sous-titre"
   - Remplacer par: "Les meilleures pizzas artisanales"
   - Observer à nouveau la preview

6. **Vérification Preview (TEMPS RÉEL)**
   ```
   ✅ Attendu: Le sous-titre change IMMÉDIATEMENT dans la preview
   ```

7. **Publier les modifications**
   - Cliquer sur le bouton "Publier" (en bas de la navigation gauche)
   - Attendre le snackbar vert "✓ Modifications publiées avec succès"

8. **Vérification Console (LOGS)**
   Ouvrir la console développeur et chercher:
   ```
   ═══════════════════════════════════════════════════════
   STUDIO V2 PUBLISH → Starting publication process...
     Hero Title: "🍕 Nouvelle Pizza Delizza!"
     Hero Subtitle: "Les meilleures pizzas artisanales"
     Hero CTA Text: "..."
     Hero Image URL: "..."
     Hero Enabled: true
     ✓ HomeConfig saved successfully
   STUDIO V2 PUBLISH → ✓ All changes published successfully!
   ═══════════════════════════════════════════════════════
   ```

9. **Recharger l'application**
   - Naviguer vers la page d'accueil `/` ou `/home`
   - Presser F5 pour forcer un rechargement

10. **Vérification HomeScreen (APP RÉELLE)**
    ```
    ✅ Attendu: Le Hero Banner affiche "🍕 Nouvelle Pizza Delizza!"
    ✅ Attendu: Le Hero Banner affiche "Les meilleures pizzas artisanales"
    ```

### ✅ Critères de Réussite

- [ ] Preview reflète les changements en temps réel (sans publier)
- [ ] Badge "Modifications non publiées" apparaît quand on modifie
- [ ] Logs dans la console montrent les valeurs publiées
- [ ] HomeScreen réel affiche les nouvelles valeurs après publication
- [ ] Pas d'erreurs dans la console

---

## ✅ Test Cas 2: Activation/Désactivation du Hero

### Étape par étape

1. **Dans Studio V2 → Module Hero**

2. **Désactiver le Hero**
   - Toggle "Afficher la section Hero" → OFF
   - Observer la preview

3. **Vérification Preview**
   ```
   ✅ Attendu: Le Hero disparaît de la preview
   ```

4. **Publier et recharger**
   - Cliquer "Publier"
   - Recharger la page d'accueil

5. **Vérification HomeScreen**
   ```
   ✅ Attendu: Le Hero Banner n'est plus affiché sur la page d'accueil
   ```

6. **Réactiver le Hero**
   - Toggle "Afficher la section Hero" → ON
   - Publier et recharger

7. **Vérification HomeScreen**
   ```
   ✅ Attendu: Le Hero Banner réapparaît sur la page d'accueil
   ```

---

## ✅ Test Cas 3: Modification de l'Image Hero

### Étape par étape

1. **Dans Studio V2 → Module Hero**

2. **Option A: Sélectionner depuis Media Manager**
   - Cliquer sur "Sélectionner depuis la bibliothèque"
   - Choisir une image dans le dossier "Hero"
   - Observer la preview

3. **Option B: Coller une URL**
   - Copier une URL d'image dans le presse-papier
   - Cliquer sur l'icône "Coller depuis le presse-papier"
   - L'URL doit s'auto-remplir
   - Observer la preview

4. **Vérification Preview**
   ```
   ✅ Attendu: L'image du Hero change dans la preview
   ```

5. **Publier et vérifier**
   - Publier les modifications
   - Recharger la page d'accueil
   - Vérifier que l'image est bien affichée

---

## ✅ Test Cas 4: Annulation des Modifications

### Étape par étape

1. **Faire des modifications**
   - Modifier le titre Hero
   - Modifier le sous-titre
   - NE PAS PUBLIER

2. **Vérification**
   ```
   ✅ Attendu: Badge "Modifications non publiées" visible
   ✅ Attendu: Bouton "Annuler" activé
   ```

3. **Cliquer "Annuler"**
   - Confirmer l'annulation dans le dialog

4. **Vérification**
   ```
   ✅ Attendu: Les modifications sont annulées
   ✅ Attendu: Les valeurs reviennent à l'état publié
   ✅ Attendu: Badge "Modifications non publiées" disparaît
   ✅ Attendu: Preview montre les anciennes valeurs
   ```

---

## ✅ Test Cas 5: Ordre des Sections (Settings)

### Étape par étape

1. **Naviguer vers Settings**
   - Cliquer sur "Paramètres" dans la navigation

2. **Modifier l'ordre des sections**
   - Drag & drop (si implémenté) ou utiliser les contrôles d'ordre
   - Exemple: Mettre "banner" avant "hero"

3. **Vérification Preview**
   ```
   ✅ Attendu: L'ordre change dans la preview
   ✅ Attendu: Le banner apparaît maintenant au-dessus du hero
   ```

4. **Publier et vérifier HomeScreen**
   ```
   ✅ Attendu: HomeScreen respecte le nouvel ordre
   ```

---

## 🐛 Debugging avec les Logs

### Logs disponibles

#### 1. Chargement initial (LOAD)
```
STUDIO V2 LOAD → Loading published data from Firestore...
  Hero Title: "..."
  Hero Subtitle: "..."
  Hero Enabled: true/false
  Studio Enabled: true/false
  Sections Order: [hero, banner, popups]
  Loaded X banners
  Loaded Y text blocks
  Loaded Z popups
```

#### 2. Publication (PUBLISH)
```
STUDIO V2 PUBLISH → Starting publication process...
  Hero Title: "..."
  Hero Subtitle: "..."
  Hero CTA Text: "..."
  Hero Image URL: "..."
  Hero Enabled: true/false
  ✓ HomeConfig saved successfully
  ✓ LayoutConfig saved successfully
  ✓ Banners saved successfully
```

### Problèmes courants et solutions

#### Problème: Preview ne se met pas à jour
**Solution:**
- Vérifier la console pour des erreurs Riverpod
- Vérifier que `StudioPreviewPanelV2` est bien utilisé
- Vérifier que les providers sont correctement overridés

#### Problème: HomeScreen ne reflète pas les changements après publication
**Solution:**
1. Vérifier les logs PUBLISH dans la console
2. Vérifier Firestore directement:
   - Collection: `app_home_config`
   - Document: `main`
   - Champ: `hero.title`, `hero.subtitle`, etc.
3. Vérifier que HomeScreen lit bien depuis `homeConfigProvider`
4. Forcer un rechargement complet (Ctrl+Shift+R ou Cmd+Shift+R)

#### Problème: Erreur "Modifying a provider inside widget lifecycle"
**Solution:**
- Vérifier que `Future.microtask()` est utilisé dans `initState()`
- Vérifier qu'aucun module n'écrit dans un provider pendant `build()`

---

## 📊 Collections Firestore à Surveiller

Pendant les tests, surveiller ces documents dans Firestore:

### 1. app_home_config/main
```json
{
  "hero": {
    "title": "...",
    "subtitle": "...",
    "imageUrl": "...",
    "ctaText": "...",
    "ctaAction": "...",
    "isActive": true/false
  },
  "updatedAt": "..."
}
```

### 2. config/home_layout
```json
{
  "studioEnabled": true/false,
  "sectionsOrder": ["hero", "banner", "popups"],
  "enabledSections": {
    "hero": true/false,
    "banner": true/false,
    "popups": true/false
  },
  "updatedAt": "..."
}
```

---

## 🎓 Points Clés de l'Architecture

### Pipeline Complet
```
Studio V2 (Draft State)
    ↓
  Preview (Provider Overrides)
    ↓
  Publier (Button Click)
    ↓
  Services (saveHomeConfig, saveHomeLayout, etc.)
    ↓
  Firestore (app_home_config/main, config/home_layout)
    ↓
  Providers (homeConfigProvider, homeLayoutProvider)
    ↓
  HomeScreen (Real App)
```

### Preview vs HomeScreen Réel

**Preview (Mode Brouillon):**
- Utilise `StudioPreviewPanelV2`
- Wrap HomeScreen dans `ProviderScope` avec overrides
- Lit l'état brouillon (non publié)
- Mise à jour en temps réel

**HomeScreen (Mode Publié):**
- Utilise les providers normaux
- Lit depuis Firestore directement
- Affiche les données publiées
- Mise à jour après rechargement

---

## ✅ Checklist de Validation Finale

- [ ] Test Cas 1: Modification titre Hero ✅
- [ ] Test Cas 2: Activation/Désactivation Hero ✅
- [ ] Test Cas 3: Modification image Hero ✅
- [ ] Test Cas 4: Annulation modifications ✅
- [ ] Test Cas 5: Ordre des sections ✅
- [ ] Logs affichés correctement dans console ✅
- [ ] Pas d'erreurs Riverpod ✅
- [ ] Firestore mis à jour correctement ✅
- [ ] Performance acceptable (< 2s pour publish) ✅
- [ ] Preview réactive en temps réel ✅

---

**Auteur:** Copilot Agent  
**Date:** 2025-01-21  
**Version:** 1.0
