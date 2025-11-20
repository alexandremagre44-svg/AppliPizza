# Studio Admin Unifié - Plan de Tests

## Objectif

Ce document décrit le plan de tests complet pour valider le bon fonctionnement du Studio Admin Unifié.

## Environnement de test

### Prérequis

- Flutter SDK ≥ 3.0.0
- Firebase configuré avec authentification admin
- Accès Firestore avec permissions admin
- Compte utilisateur avec rôle admin

### Navigateurs testés

- Chrome (desktop)
- Firefox (desktop)  
- Safari (desktop)
- Chrome Mobile (Android)
- Safari Mobile (iOS)

## Tests Fonctionnels

### 1. Navigation et UI

#### Test 1.1: Navigation entre modules
**Objectif:** Vérifier que la navigation fonctionne correctement

**Étapes:**
1. Ouvrir le Studio Admin
2. Cliquer sur chaque module dans la navigation
3. Vérifier que le contenu change

**Résultat attendu:**
- ✅ Le module sélectionné s'affiche
- ✅ L'indicateur de sélection est correct
- ✅ Le contenu précédent est remplacé

#### Test 1.2: Responsive design
**Objectif:** Vérifier le layout responsive

**Étapes:**
1. Ouvrir le Studio sur desktop (>900px)
2. Vérifier la vue 3 colonnes
3. Redimensionner à mobile (<900px)
4. Vérifier la vue mobile avec tabs

**Résultat attendu:**
- ✅ 3 colonnes sur desktop: nav | content | preview
- ✅ Tabs horizontales sur mobile
- ✅ Pas de scrolling horizontal
- ✅ Éléments correctement dimensionnés

#### Test 1.3: Prévisualisation live
**Objectif:** Vérifier la mise à jour en temps réel

**Étapes:**
1. Ouvrir le module Hero
2. Modifier le titre
3. Observer la prévisualisation

**Résultat attendu:**
- ✅ Le titre se met à jour instantanément
- ✅ Pas de lag perceptible
- ✅ Le style est correct

### 2. Mode Brouillon

#### Test 2.1: Sauvegarde locale
**Objectif:** Vérifier que les modifications restent locales

**Étapes:**
1. Modifier plusieurs champs dans différents modules
2. NE PAS cliquer sur "Publier"
3. Vérifier l'état dans Firestore

**Résultat attendu:**
- ✅ Aucune modification dans Firestore
- ✅ Les modifications sont visibles dans le Studio
- ✅ Le bouton "Publier" est actif

#### Test 2.2: Publication
**Objectif:** Vérifier la publication des changements

**Étapes:**
1. Modifier Hero, Banner, et Textes
2. Cliquer sur "Publier"
3. Attendre la confirmation
4. Vérifier Firestore

**Résultat attendu:**
- ✅ Message "✓ Modifications publiées avec succès"
- ✅ Toutes les modifications dans Firestore
- ✅ Le bouton "Publier" se désactive
- ✅ hasUnsavedChanges = false

#### Test 2.3: Annulation
**Objectif:** Vérifier l'annulation des modifications

**Étapes:**
1. Modifier plusieurs champs
2. Cliquer sur "Annuler"
3. Confirmer dans la dialog
4. Vérifier l'état

**Résultat attendu:**
- ✅ Dialog de confirmation s'affiche
- ✅ Toutes les modifications annulées
- ✅ État restauré depuis Firestore
- ✅ Message "Modifications annulées"

#### Test 2.4: Avertissement de sortie
**Objectif:** Vérifier l'avertissement si modifications non sauvegardées

**Étapes:**
1. Modifier un champ
2. Cliquer sur le bouton retour
3. Observer la dialog

**Résultat attendu:**
- ✅ Dialog "Modifications non enregistrées" s'affiche
- ✅ Options "Rester" et "Quitter"
- ✅ "Rester" annule la navigation
- ✅ "Quitter" navigue vers l'écran précédent

### 3. Module Hero

#### Test 3.1: Édition Hero
**Objectif:** Vérifier l'édition complète du Hero

**Étapes:**
1. Ouvrir le module Hero
2. Activer le Hero
3. Remplir tous les champs:
   - Image URL: https://example.com/image.jpg
   - Titre: "Test Hero"
   - Sous-titre: "Description test"
   - Texte bouton: "Action"
   - Action: "/menu"
4. Observer la prévisualisation
5. Publier

**Résultat attendu:**
- ✅ Tous les champs se remplissent correctement
- ✅ Prévisualisation se met à jour
- ✅ Publication réussie
- ✅ Données correctes dans Firestore

#### Test 3.2: Désactivation Hero
**Objectif:** Vérifier la désactivation

**Étapes:**
1. Hero actif dans Firestore
2. Désactiver le toggle
3. Publier
4. Vérifier la prévisualisation et Firestore

**Résultat attendu:**
- ✅ Hero masqué dans la prévisualisation
- ✅ isActive = false dans Firestore
- ✅ Espace Hero disparu de l'écran

### 4. Module Bandeau

#### Test 4.1: Création bandeau
**Objectif:** Créer un nouveau bandeau

**Étapes:**
1. Ouvrir le module Bandeau
2. Cliquer "Nouveau bandeau"
3. Remplir les champs:
   - Texte: "Promo test"
   - Icône: local_fire_department
   - Couleur fond: #D32F2F
   - Couleur texte: #FFFFFF
4. Enregistrer
5. Publier

**Résultat attendu:**
- ✅ Dialog d'édition s'ouvre
- ✅ Tous les champs se remplissent
- ✅ Color picker fonctionne
- ✅ Bandeau apparaît dans la liste
- ✅ Prévisualisation affiche le bandeau
- ✅ Document créé dans Firestore

#### Test 4.2: Réorganisation bandeaux
**Objectif:** Changer l'ordre avec drag & drop

**Étapes:**
1. Créer 3 bandeaux
2. Glisser le 3ème en position 1
3. Publier
4. Vérifier l'ordre dans Firestore

**Résultat attendu:**
- ✅ Drag & drop fonctionne visuellement
- ✅ Ordre mis à jour dans la liste
- ✅ Champs `order` corrects dans Firestore
- ✅ Ordre respecté côté client

#### Test 4.3: Planification bandeau
**Objectif:** Tester les dates de début et fin

**Étapes:**
1. Créer un bandeau
2. Définir startDate: demain
3. Publier
4. Vérifier la prévisualisation

**Résultat attendu:**
- ✅ Bandeau non visible dans la prévisualisation (pas encore démarré)
- ✅ Dates correctes dans Firestore
- ✅ Bandeau apparaîtra automatiquement demain

#### Test 4.4: Suppression bandeau
**Objectif:** Supprimer un bandeau

**Étapes:**
1. Créer un bandeau
2. Publier
3. Cliquer sur l'icône supprimer
4. Confirmer
5. Publier à nouveau

**Résultat attendu:**
- ✅ Dialog de confirmation s'affiche
- ✅ Bandeau disparaît de la liste
- ✅ Document supprimé de Firestore

### 5. Module Popups

#### Test 5.1: CRUD popup
**Objectif:** Tester création, édition, suppression

**Étapes:**
1. Créer un popup (type: promo)
2. Éditer et changer le type en warning
3. Supprimer le popup
4. Publier après chaque action

**Résultat attendu:**
- ✅ Création réussie avec type correct
- ✅ Édition change le type et la couleur d'indicateur
- ✅ Suppression retire le popup
- ✅ Toutes les actions reflétées dans Firestore

#### Test 5.2: Planification popup
**Objectif:** Tester les dates

**Étapes:**
1. Créer un popup
2. Définir startDate: aujourd'hui, endDate: +7 jours
3. Publier
4. Vérifier l'indicateur "actif"

**Résultat attendu:**
- ✅ Popup affiché comme actif
- ✅ Dates correctes dans Firestore
- ✅ isCurrentlyActive = true

#### Test 5.3: Drag & drop popup
**Objectif:** Changer la priorité

**Étapes:**
1. Créer 3 popups
2. Réorganiser avec drag & drop
3. Publier

**Résultat attendu:**
- ✅ Ordre visuel change
- ✅ Champs `priority` mis à jour
- ✅ Ordre respecté côté client

### 6. Module Textes

#### Test 6.1: Édition textes
**Objectif:** Modifier les textes Home

**Étapes:**
1. Ouvrir le module Textes
2. Modifier appName, title, subtitle
3. Observer la prévisualisation
4. Publier

**Résultat attendu:**
- ✅ Textes se mettent à jour en temps réel
- ✅ Prévisualisation affiche les nouveaux textes
- ✅ Publication réussie
- ✅ Textes corrects dans Firestore

#### Test 6.2: Réinitialisation
**Objectif:** Restaurer valeurs par défaut

**Étapes:**
1. Modifier plusieurs textes
2. Cliquer "Réinitialiser"
3. Confirmer
4. Vérifier les valeurs

**Résultat attendu:**
- ✅ Dialog de confirmation
- ✅ Tous les textes restaurés aux valeurs par défaut
- ✅ Prévisualisation mise à jour

### 7. Module Paramètres

#### Test 7.1: Toggle Studio
**Objectif:** Activer/désactiver le Studio

**Étapes:**
1. Studio actif
2. Désactiver le toggle
3. Publier
4. Vérifier la prévisualisation

**Résultat attendu:**
- ✅ Badge "Studio désactivé" dans la prévisualisation
- ✅ Hero, Bandeaux, Popups masqués
- ✅ studioEnabled = false dans Firestore
- ✅ Configurations préservées

#### Test 7.2: Réorganisation sections
**Objectif:** Changer l'ordre des sections

**Étapes:**
1. Ordre initial: [hero, banner, popups]
2. Glisser popups en position 1
3. Publier
4. Vérifier l'ordre dans la prévisualisation

**Résultat attendu:**
- ✅ Ordre change dans la liste
- ✅ Prévisualisation respecte le nouvel ordre
- ✅ sectionsOrder mis à jour dans Firestore

#### Test 7.3: Activation/Désactivation sections
**Objectif:** Toggle par section

**Étapes:**
1. Toutes les sections actives
2. Désactiver "banner"
3. Publier
4. Vérifier

**Résultat attendu:**
- ✅ Bandeau masqué dans la prévisualisation
- ✅ enabledSections.banner = false dans Firestore
- ✅ Hero et Popups toujours visibles

## Tests d'Intégration

### Test I.1: Rechargement depuis Firestore
**Objectif:** Vérifier la synchronisation

**Étapes:**
1. Modifier des données directement dans Firestore
2. Cliquer "Recharger depuis Firestore" dans le Studio
3. Vérifier que les changements apparaissent

**Résultat attendu:**
- ✅ Toutes les données rechargées
- ✅ Prévisualisation mise à jour
- ✅ Mode brouillon réinitialisé

### Test I.2: Multi-onglets
**Objectif:** Comportement avec plusieurs onglets ouverts

**Étapes:**
1. Ouvrir le Studio dans 2 onglets
2. Publier des modifications dans l'onglet 1
3. Recharger l'onglet 2

**Résultat attendu:**
- ✅ Modifications visibles dans l'onglet 2 après rechargement
- ⚠️ Pas de conflit de données

### Test I.3: Publication batch
**Objectif:** Vérifier que toutes les modifications sont publiées ensemble

**Étapes:**
1. Modifier Hero, Banner, Popup, Textes, Settings
2. Cliquer "Publier" une seule fois
3. Vérifier Firestore

**Résultat attendu:**
- ✅ Toutes les modifications publiées
- ✅ Atomicité (tout ou rien)
- ✅ Pas de modifications partielles

## Tests de Régression

### Test R.1: Anciens écrans non affectés
**Objectif:** Vérifier qu'aucune régression

**Modules à tester:**
- ✅ Caisse: Fonctionnel
- ✅ Commandes: Fonctionnel
- ✅ Produits: Fonctionnel
- ✅ Roulette: Fonctionnel
- ✅ Fidélité: Fonctionnel
- ✅ Auth: Fonctionnel
- ✅ Panier: Fonctionnel
- ✅ Navigation: Fonctionnel

### Test R.2: Backward compatibility
**Objectif:** Vérifier la compatibilité si home_layout n'existe pas

**Étapes:**
1. Supprimer le document `config/home_layout` dans Firestore
2. Recharger l'écran d'accueil
3. Vérifier l'affichage

**Résultat attendu:**
- ✅ Configuration par défaut appliquée
- ✅ Hero, Bandeaux, Popups affichés (si configurés)
- ✅ Pas d'erreur console

## Tests de Performance

### Test P.1: Temps de chargement
**Objectif:** Vérifier la rapidité

**Métrique:**
- Chargement initial du Studio: < 2 secondes
- Switch entre modules: < 100ms
- Publication: < 3 secondes

### Test P.2: Nombre de bandeaux
**Objectif:** Tester avec beaucoup de bandeaux

**Étapes:**
1. Créer 10 bandeaux
2. Tester le drag & drop
3. Publier

**Résultat attendu:**
- ✅ Interface fluide
- ✅ Drag & drop fonctionnel
- ✅ Publication réussie

### Test P.3: Mise à jour prévisualisation
**Objectif:** Vérifier la performance de la preview

**Étapes:**
1. Modifier rapidement plusieurs champs
2. Observer la prévisualisation

**Résultat attendu:**
- ✅ Pas de lag
- ✅ Rendu fluide
- ✅ Pas de flickering

## Tests de Sécurité

### Test S.1: Permissions Firestore
**Objectif:** Vérifier que seuls les admins peuvent écrire

**Étapes:**
1. Se connecter avec un compte non-admin
2. Tenter d'accéder au Studio
3. Tenter d'écrire dans Firestore

**Résultat attendu:**
- ⛔ Accès refusé au Studio
- ⛔ Écriture Firestore bloquée
- ✅ Lecture autorisée

### Test S.2: Validation des entrées
**Objectif:** Tester la sécurité des inputs

**Étapes:**
1. Injecter du HTML/JS dans les champs texte
2. Publier
3. Afficher côté client

**Résultat attendu:**
- ✅ Pas d'exécution de script
- ✅ Texte affiché sans interprétation
- ✅ Sanitization correcte

## Rapports de Bugs

### Format

Pour chaque bug trouvé:
```markdown
**Bug #XX**
- Module: [Hero/Banner/Popup/Textes/Settings]
- Sévérité: [Critique/Haute/Moyenne/Basse]
- Description: ...
- Étapes de reproduction: ...
- Résultat attendu: ...
- Résultat obtenu: ...
- Screenshot: [optionnel]
```

## Critères de Validation

### Acceptation

Le Studio est considéré comme validé si:
- ✅ 100% des tests fonctionnels passent
- ✅ 0 bug critique
- ✅ 0 régression sur les modules existants
- ✅ Performance acceptable (< 2s chargement)
- ✅ Sécurité validée

### Suivi

- Tests manuels: 1 passage complet
- Tests automatisés: À implémenter (optionnel)
- Re-test après correction de bug: Obligatoire
