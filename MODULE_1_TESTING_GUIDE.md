# Module 1 Studio Builder - Guide de Test

## 🧪 Guide Complet de Validation des Corrections

Ce document fournit un protocole détaillé pour tester toutes les corrections et améliorations du Module 1.

---

## ⚙️ Pré-requis

### 1. Configuration Firebase
Assurez-vous que:
- ✅ Firebase est configuré et connecté
- ✅ Firestore Database est activé
- ✅ Firebase Storage est activé
- ✅ Un utilisateur admin est authentifié

### 2. Règles Firestore
Vérifiez que les règles sont correctes:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /app_home_config/{document} {
      allow read: if true;  // Lecture publique
      allow write: if request.auth != null;  // Écriture authentifiée
    }
  }
}
```

### 3. Règles Storage
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /home/{imageId} {
      allow read: if true;  // Images publiques
      allow write: if request.auth != null;  // Upload authentifié
    }
  }
}
```

---

## 🔴 TEST 1: Correction du Bug Critique

### Objectif
Valider que l'ajout/modification/suppression de contenu fonctionne et persiste correctement.

### A. Ajout d'un Bloc Dynamique

**Étapes:**
1. Ouvrir l'application en tant qu'admin
2. Naviguer vers: Dashboard Admin → Studio → Page d'accueil
3. Aller dans l'onglet "Blocs"
4. Cliquer sur le bouton "+" (en haut à droite)
5. Dans le dialog:
   - Sélectionner "Produits en vedette"
   - Titre: "Nos Spécialités"
   - Nombre max: 6
   - Position: 0
   - Activer "Bloc visible"
6. Cliquer sur "Ajouter"

**Résultat Attendu:**
- ✅ Un SnackBar apparaît: "Bloc ajouté avec succès"
- ✅ Le nouveau bloc apparaît **immédiatement** dans la liste
- ✅ Le compteur indique "1 bloc(s) configuré(s)"
- ✅ Le bloc est visible avec tous les détails corrects

**Validation Firestore:**
1. Ouvrir Firebase Console → Firestore
2. Collection: `app_home_config` → Document: `main`
3. Vérifier que le tableau `blocks` contient le nouveau bloc:
```json
{
  "blocks": [
    {
      "id": "uuid-généré",
      "type": "featuredProducts",
      "title": "Nos Spécialités",
      "maxItems": 6,
      "order": 0,
      "isActive": true
    }
  ]
}
```

### B. Modification d'un Bloc

**Étapes:**
1. Dans la liste des blocs, développer le bloc créé
2. Cliquer sur "Modifier"
3. Changer le titre: "Nos Pizzas Signature"
4. Changer maxItems: 4
5. Cliquer sur "Enregistrer"

**Résultat Attendu:**
- ✅ SnackBar: "Bloc modifié avec succès"
- ✅ Le titre est **mis à jour immédiatement** dans la liste
- ✅ Les modifications persistent dans Firestore

### C. Suppression d'un Bloc

**Étapes:**
1. Développer le bloc dans la liste
2. Cliquer sur "Supprimer"
3. Confirmer la suppression

**Résultat Attendu:**
- ✅ Dialog de confirmation apparaît
- ✅ Après confirmation, SnackBar: "Bloc supprimé avec succès"
- ✅ Le bloc **disparaît immédiatement** de la liste
- ✅ Compteur mis à jour: "0 bloc(s) configuré(s)"
- ✅ Le bloc est supprimé de Firestore

### D. Modification Hero Banner

**Étapes:**
1. Aller dans l'onglet "Hero"
2. Activer le switch "Activer le Hero"
3. Cliquer sur "Modifier"
4. Remplir:
   - Titre: "Bienvenue chez Pizza Deli'Zza"
   - Sous-titre: "Les meilleures pizzas artisanales"
   - Texte du bouton: "Commander"
   - Action: "/menu"
5. Cliquer sur "Enregistrer"

**Résultat Attendu:**
- ✅ SnackBar: "Hero mis à jour avec succès"
- ✅ Les informations sont **mises à jour immédiatement** dans l'aperçu
- ✅ Switch reste activé
- ✅ Données persistées dans Firestore

### E. Modification Bandeau Promo

**Étapes:**
1. Aller dans l'onglet "Bandeau"
2. Activer le switch
3. Cliquer sur "Modifier"
4. Texte: "🔥 -20% sur toutes les pizzas aujourd'hui!"
5. Choisir des couleurs
6. Cliquer sur "Enregistrer"

**Résultat Attendu:**
- ✅ SnackBar: "Bandeau mis à jour avec succès"
- ✅ Preview mis à jour avec les nouvelles couleurs
- ✅ Persistance confirmée

---

## 🎨 TEST 2: Améliorations UI/UX

### A. Effet Shimmer au Chargement

**Étapes:**
1. Ouvrir l'application (pas en mode admin)
2. Aller sur la page d'accueil
3. Si déjà chargée, tirer vers le bas pour rafraîchir (pull-to-refresh)

**Résultat Attendu:**
- ✅ Au lieu du CircularProgressIndicator basique, un **effet shimmer** apparaît
- ✅ Des rectangles gris scintillants miment la structure:
  - Un grand rectangle pour le Hero Banner
  - Des cartes pour les produits (grille 2 colonnes)
  - Des petits rectangles pour les catégories
- ✅ Animation fluide et professionnelle
- ✅ Transition douce vers le contenu réel

**Validation Visuelle:**
- [ ] Les placeholders ressemblent à la structure finale
- [ ] L'animation shimmer est visible (scintillement)
- [ ] Pas de saut brusque entre loading et contenu

### B. Animations Fade-In

**Étapes:**
1. Page d'accueil déjà chargée
2. Tirer vers le bas pour rafraîchir
3. Observer attentivement l'apparition du contenu

**Résultat Attendu:**
- ✅ Le contenu apparaît en **fondu progressif** (opacity 0 → 1)
- ✅ Légère **translation verticale** (monte légèrement)
- ✅ Animation douce de 500ms
- ✅ Effet subtil et élégant

**Validation:**
- [ ] Pas d'apparition brusque
- [ ] Transition fluide et naturelle
- [ ] Effet visible mais pas exagéré

### C. Preview d'Image avec Upload

**Étapes:**
1. Mode admin → Studio → Page d'accueil → Onglet "Hero"
2. Cliquer sur "Modifier"
3. Observer la section "Image de la bannière"

**État Initial (Aucune Image):**
- ✅ Rectangle gris avec icône d'image
- ✅ Texte: "Aucune image sélectionnée"
- ✅ Bouton: "Choisir une image"

**Upload d'Image:**
4. Cliquer sur "Choisir une image"
5. Sélectionner une image depuis la galerie

**Pendant l'Upload:**
- ✅ Bouton change: "Upload en cours... X%"
- ✅ CircularProgressIndicator avec progression
- ✅ Pourcentage augmente progressivement

**Après l'Upload:**
- ✅ Image apparaît en **preview grande taille** (150px hauteur)
- ✅ Icône "X" en haut à droite pour supprimer
- ✅ Bouton change: "Changer l'image"
- ✅ SnackBar: "Image téléchargée avec succès"

**Test de Suppression:**
6. Cliquer sur le "X" en haut à droite de l'image

**Résultat:**
- ✅ Image disparaît
- ✅ Retour à l'état initial (placeholder)
- ✅ Bouton redevient: "Choisir une image"

**Validation:**
- [ ] Preview affiche l'image correctement (pas déformée)
- [ ] Barre de progression est visible
- [ ] Bouton "X" est facile à cliquer
- [ ] Texte du bouton s'adapte au contexte

### D. Drag & Drop pour Réorganiser

**Configuration Préalable:**
1. Créer au moins 3 blocs différents:
   - Bloc A: "Produits en vedette" (ordre 0)
   - Bloc B: "Best-sellers" (ordre 1)
   - Bloc C: "Catégories" (ordre 2)

**Test de Drag & Drop:**
2. Dans l'onglet "Blocs", observer la liste
3. Vérifier la présence de:
   - ✅ Icône `≡` (drag_handle) à gauche de chaque bloc
   - ✅ Message: "Glissez-déposez pour réorganiser"
4. Appuyer longuement sur le Bloc B
5. Glisser vers le haut, au-dessus du Bloc A
6. Relâcher

**Résultat Attendu:**
- ✅ Le bloc se déplace visuellement pendant le drag
- ✅ Les autres blocs s'écartent pour faire de la place
- ✅ Après le drop:
  - L'ordre visuel est mis à jour immédiatement
  - SnackBar: "Blocs réorganisés avec succès"
  - Les positions numériques sont recalculées automatiquement

**Validation Firestore:**
1. Vérifier dans Firestore → `app_home_config` → `main` → `blocks`
2. L'ordre des blocs dans le tableau doit correspondre à l'ordre visuel
3. Les propriétés `order` doivent être: 0, 1, 2, etc.

**Tests Supplémentaires:**
- [ ] Déplacer le dernier bloc en premier
- [ ] Déplacer le premier bloc en dernier
- [ ] Déplacer un bloc du milieu
- [ ] Avec 5+ blocs, tester plusieurs réorganisations

**Validation:**
- [ ] Drag fluide et naturel
- [ ] Feedback visuel clair pendant le drag
- [ ] Sauvegarde automatique fonctionne
- [ ] Ordre client reflète les changements (vérifier page d'accueil)

---

## 🔄 TEST 3: Synchronisation Temps Réel

### Objectif
Valider que les modifications dans l'admin apparaissent **instantanément** dans l'interface et sur la page client.

### Scénario Multi-Tab

**Configuration:**
1. Ouvrir 2 onglets/fenêtres:
   - **Tab 1:** Interface Admin (Studio → Page d'accueil)
   - **Tab 2:** Page d'accueil client

**Test A: Ajout de Bloc**
1. Dans Tab 1 (Admin), ajouter un nouveau bloc
2. Observer **simultanément** les deux onglets

**Résultat Attendu:**
- ✅ Tab 1: Le bloc apparaît immédiatement dans la liste admin
- ✅ Tab 2: Le nouveau bloc apparaît sur la page client en temps réel

**Test B: Modification Hero**
1. Dans Tab 1, modifier le titre du Hero: "NOUVEAU TITRE"
2. Observer Tab 2

**Résultat Attendu:**
- ✅ Le titre sur la page client se met à jour **sans rafraîchir**

**Test C: Activation/Désactivation**
1. Dans Tab 1, désactiver un bloc (switch)
2. Observer Tab 2

**Résultat Attendu:**
- ✅ Le bloc disparaît de la page client instantanément

**Validation:**
- [ ] Pas besoin de rafraîchir manuellement
- [ ] Délai < 1 seconde
- [ ] Pas d'erreur dans la console

---

## 📱 TEST 4: Validation Page Client

### Objectif
Vérifier que tous les éléments configurés s'affichent correctement côté client.

### A. Hero Banner

**Configuration Admin:**
- Activer le Hero
- Titre: "Bienvenue chez Pizza Deli'Zza"
- Sous-titre: "Les meilleures pizzas"
- CTA: "Commander" → "/menu"
- Image uploadée

**Validation Client:**
1. Aller sur la page d'accueil
2. Vérifier:
   - ✅ Hero Banner est visible en haut
   - ✅ Image de fond affichée correctement
   - ✅ Titre et sous-titre visibles et lisibles
   - ✅ Bouton "Commander" présent
   - ✅ Clic sur le bouton → redirige vers /menu

### B. Bandeau Promo

**Configuration Admin:**
- Activer le bandeau
- Texte: "🔥 -20% sur toutes les pizzas!"
- Couleur de fond: Rouge (#D32F2F)
- Couleur texte: Blanc (#FFFFFF)

**Validation Client:**
- ✅ Bandeau affiché sous le Hero
- ✅ Texte correct avec emoji
- ✅ Couleurs appliquées correctement
- ✅ Icône présente (local_offer)

### C. Blocs Dynamiques

**Configuration Admin:**
Créer 3 blocs:
1. "Nos Spécialités" (featuredProducts, ordre 0)
2. "Best-sellers" (bestSellers, ordre 1)
3. "Catégories" (categories, ordre 2)

**Validation Client:**
1. Vérifier que les blocs apparaissent dans l'ordre correct
2. Pour "Nos Spécialités":
   - ✅ Section avec titre "Nos Spécialités"
   - ✅ Produits marqués comme featured affichés
   - ✅ Grille 2 colonnes
3. Pour "Best-sellers":
   - ✅ Section avec titre "Best-sellers"
   - ✅ Produits affichés (featured ou pizzas par défaut)
4. Pour "Catégories":
   - ✅ Section avec titre "Catégories"
   - ✅ Widget CategoryShortcuts affiché

### D. Animations et Loading

**Test Loading:**
1. Fermer et rouvrir l'app
2. Observer le chargement initial

**Validation:**
- ✅ Shimmer effect affiché (pas CircularProgressIndicator)
- ✅ Structure de la page visible pendant loading
- ✅ Transition douce vers contenu réel
- ✅ Fade-in des éléments

---

## 🐛 TEST 5: Gestion d'Erreur

### A. Image Upload Invalide

**Test:**
1. Admin → Hero → Modifier
2. Essayer d'uploader un fichier > 10MB ou format invalide

**Résultat Attendu:**
- ✅ SnackBar rouge: "Image invalide. Formats acceptés: JPG, PNG, WEBP (max 10MB)"
- ✅ Pas de crash
- ✅ Image actuelle reste inchangée

### B. Perte de Connexion

**Test:**
1. Couper la connexion internet
2. Essayer de modifier un bloc

**Résultat Attendu:**
- ✅ SnackBar: "Erreur lors de la modification"
- ✅ Logs dans la console avec détails de l'erreur
- ✅ Pas de crash

### C. Firestore Règles

**Test:**
1. Se déconnecter (devenir utilisateur anonyme)
2. Essayer d'accéder à Studio → Page d'accueil

**Résultat Attendu:**
- ✅ Redirection vers login ou erreur d'autorisation
- ✅ Pas d'accès à l'édition

**Test Lecture:**
3. En tant qu'utilisateur non-auth, visiter la page d'accueil

**Résultat Attendu:**
- ✅ Page s'affiche normalement (lecture publique)

---

## 📊 Checklist Finale de Validation

### Fonctionnalités Core
- [ ] Ajout de bloc → Fonctionne et persiste
- [ ] Modification de bloc → Fonctionne et persiste
- [ ] Suppression de bloc → Fonctionne et persiste
- [ ] Drag & Drop → Réorganisation fluide et sauvegardée
- [ ] Modification Hero → Fonctionne et persiste
- [ ] Modification Bandeau → Fonctionne et persiste
- [ ] Upload d'image → Fonctionne avec progression
- [ ] Suppression d'image → Fonctionne

### Temps Réel
- [ ] Admin → Modifications visibles immédiatement
- [ ] Client → Changements reflétés en temps réel
- [ ] Multi-tab → Synchronisation instantanée

### UI/UX
- [ ] Shimmer loading → Affiché correctement
- [ ] Animations fade-in → Visibles et fluides
- [ ] Preview d'image → Fonctionne avec contrôles
- [ ] Drag & Drop → Visuel et intuitif
- [ ] Messages feedback → Clairs et visibles
- [ ] Gestion d'erreur → Robuste et informative

### Page Client
- [ ] Hero Banner → Affiché avec image et textes
- [ ] Bandeau Promo → Affiché avec couleurs
- [ ] Blocs dynamiques → Dans le bon ordre
- [ ] Animations → Fade-in visible
- [ ] Loading → Shimmer au lieu de spinner

### Technique
- [ ] Pas de memory leaks
- [ ] Pas d'erreurs dans la console
- [ ] Logs de débogage présents
- [ ] Performance acceptable

---

## 🚨 Problèmes Connus et Solutions

### Problème: Le bloc n'apparaît pas après ajout

**Diagnostic:**
1. Vérifier la console pour les logs:
   ```
   HomeConfigService: Starting addContentBlock...
   HomeConfigService: Current blocks count: X
   HomeConfigService: Save result: true/false
   ```
2. Vérifier Firestore manuellement

**Solutions:**
- Si `Save result: false` → Vérifier les règles Firestore
- Si pas de logs → Vérifier l'authentification
- Essayer de rafraîchir avec `ref.invalidate(homeConfigProvider)`

### Problème: Shimmer ne s'affiche pas

**Cause possible:** Package `shimmer` non installé

**Solution:**
```bash
flutter pub get
flutter clean
flutter run
```

### Problème: Drag & Drop ne fonctionne pas

**Cause possible:** Clé unique manquante

**Vérification:**
```dart
// Dans _buildBlockCard, vérifier:
Widget _buildBlockCard(ContentBlock block, {Key? key}) {
  return Card(
    key: key,  // ← Doit être présent
    // ...
  );
}
```

---

## ✅ Validation Complète

Une fois tous les tests passés:

1. **Créer des captures d'écran** pour la documentation
2. **Exporter une configuration exemple** depuis Firestore
3. **Documenter les cas d'usage** typiques
4. **Préparer une démo** pour les stakeholders

---

**Date de création:** 2025-11-13
**Version:** 1.0.0
**Auteur:** Copilot Coding Agent
