# Studio Admin V2 - Plan de Tests

## 📋 Tests Manuels Requis (20+)

### Catégorie 1: Tests d'affichage

#### Test 1: Accès au Studio V2
**Objectif**: Vérifier que le Studio V2 est accessible

**Étapes**:
1. Se connecter en tant qu'admin
2. Naviguer vers `/admin/studio/v2`
3. Vérifier que l'écran Studio V2 s'affiche

**Résultat attendu**: 
- ✅ Écran Studio V2 affiché
- ✅ Pas d'erreur de routing
- ✅ Layout 3 colonnes visible (desktop)

**Statut**: ⏳ À tester

---

#### Test 2: Layout desktop (3 colonnes)
**Objectif**: Vérifier le layout 3 colonnes sur desktop

**Étapes**:
1. Ouvrir Studio V2 sur écran desktop (>= 800px)
2. Observer la disposition

**Résultat attendu**:
- ✅ Colonne gauche: Navigation (240px)
- ✅ Colonne centrale: Éditeur (flex: 2)
- ✅ Colonne droite: Prévisualisation (flex: 1)
- ✅ Séparateurs visuels entre colonnes

**Statut**: ⏳ À tester

---

#### Test 3: Layout mobile adaptatif
**Objectif**: Vérifier le layout responsive sur mobile

**Étapes**:
1. Ouvrir Studio V2 sur écran mobile (< 800px) ou resize navigateur
2. Observer la disposition

**Résultat attendu**:
- ✅ Barre de navigation en haut avec menu déroulant
- ✅ Contenu module en pleine largeur
- ✅ Pas de colonne preview visible (optionnel: bouton pour toggle)

**Statut**: ⏳ À tester

---

#### Test 4: Navigation sidebar fonctionnelle
**Objectif**: Vérifier la navigation entre modules

**Étapes**:
1. Cliquer sur "Overview" dans navigation
2. Cliquer sur "Hero"
3. Cliquer sur "Bandeaux"
4. Cliquer sur "Popups"
5. Cliquer sur "Textes dynamiques"
6. Cliquer sur "Paramètres"

**Résultat attendu**:
- ✅ Chaque clic change le module affiché dans colonne centrale
- ✅ Item actif surligné en bleu
- ✅ Pas de rechargement de page
- ✅ Transition fluide

**Statut**: ⏳ À tester

---

#### Test 5: Prévisualisation téléphone
**Objectif**: Vérifier l'affichage du preview mockup

**Étapes**:
1. Ouvrir Studio V2
2. Observer colonne droite

**Résultat attendu**:
- ✅ Mockup de téléphone avec bordure arrondie
- ✅ Ombre portée autour du mockup
- ✅ AppBar rouge simulé
- ✅ Contenu scrollable à l'intérieur

**Statut**: ⏳ À tester

---

### Catégorie 2: Tests de création

#### Test 6: Créer un bandeau
**Objectif**: Vérifier la création d'un bandeau

**Étapes**:
1. Naviguer vers module "Bandeaux"
2. Cliquer sur "Nouveau bandeau"
3. Observer l'état

**Résultat attendu**:
- ✅ Nouveau bandeau apparaît dans la liste
- ✅ ID unique généré
- ✅ État "Désactivé" par défaut
- ✅ Badge "Modifications non publiées" apparaît
- ✅ Bouton "Publier" devient actif

**Statut**: ⏳ À tester

---

#### Test 7: Créer un popup
**Objectif**: Vérifier la création d'un popup V2

**Étapes**:
1. Naviguer vers module "Popups"
2. Cliquer sur "Nouveau popup"
3. Observer l'état

**Résultat attendu**:
- ✅ Nouveau popup apparaît dans la liste
- ✅ Type par défaut: "text"
- ✅ État "Désactivé" par défaut
- ✅ Badge "Modifications non publiées" apparaît

**Statut**: ⏳ À tester

---

#### Test 8: Créer un bloc de texte
**Objectif**: Vérifier la création d'un bloc de texte dynamique

**Étapes**:
1. Naviguer vers module "Textes dynamiques"
2. Cliquer sur "Nouveau bloc"
3. Observer l'état

**Résultat attendu**:
- ✅ Nouveau bloc apparaît dans la liste
- ✅ Nom et displayName générés
- ✅ Type par défaut: "short"
- ✅ Catégorie par défaut: "home"
- ✅ Badge "Modifications non publiées" apparaît

**Statut**: ⏳ À tester

---

### Catégorie 3: Tests d'édition

#### Test 9: Modifier le titre Hero
**Objectif**: Vérifier que les modifications Hero mettent à jour le preview

**Étapes**:
1. Naviguer vers module "Hero"
2. Activer la section Hero
3. Modifier le champ "Titre"
4. Observer la colonne preview

**Résultat attendu**:
- ✅ Titre dans preview mis à jour en temps réel
- ✅ Badge "Modifications non publiées" apparaît
- ✅ Bouton "Publier" devient actif

**Statut**: ⏳ À tester

---

#### Test 10: Modifier un bandeau
**Objectif**: Vérifier l'édition d'un bandeau existant

**Étapes**:
1. Créer un bandeau
2. Cliquer sur le bandeau (édition)
3. Modifier le texte
4. Observer preview

**Résultat attendu**:
- ✅ Bandeau mis à jour dans la liste
- ✅ Preview affiche nouveau texte si bandeau activé
- ✅ Badge "Modifications non publiées" apparaît

**Statut**: ⏳ À tester

---

#### Test 11: Activer/désactiver une section
**Objectif**: Vérifier le toggle de sections dans Settings

**Étapes**:
1. Naviguer vers "Paramètres"
2. Désactiver "HERO"
3. Observer preview
4. Réactiver "HERO"
5. Observer preview

**Résultat attendu**:
- ✅ Section disparaît du preview quand désactivée
- ✅ Section réapparaît quand réactivée
- ✅ Badge "Modifications non publiées" apparaît

**Statut**: ⏳ À tester

---

### Catégorie 4: Tests de suppression

#### Test 12: Supprimer un bandeau
**Objectif**: Vérifier la suppression d'un bandeau

**Étapes**:
1. Créer un bandeau
2. Cliquer sur "Supprimer" (icône trash)
3. Confirmer la suppression
4. Observer l'état

**Résultat attendu**:
- ✅ Bandeau disparaît de la liste
- ✅ Preview mis à jour (bandeau n'apparaît plus)
- ✅ Badge "Modifications non publiées" visible
- ✅ Bandeau supprimé uniquement en brouillon (pas encore Firestore)

**Statut**: ⏳ À tester

---

#### Test 13: Supprimer un popup
**Objectif**: Vérifier la suppression d'un popup

**Étapes**:
1. Créer un popup
2. Supprimer le popup
3. Confirmer
4. Observer l'état

**Résultat attendu**:
- ✅ Popup disparaît de la liste
- ✅ Compteur de popups actifs décrémenté
- ✅ Badge "Modifications non publiées" visible

**Statut**: ⏳ À tester

---

#### Test 14: Supprimer un bloc de texte
**Objectif**: Vérifier la suppression d'un bloc de texte

**Étapes**:
1. Créer un bloc de texte
2. Supprimer le bloc
3. Confirmer
4. Observer l'état

**Résultat attendu**:
- ✅ Bloc disparaît de la liste
- ✅ Badge "Modifications non publiées" visible

**Statut**: ⏳ À tester

---

### Catégorie 5: Tests drag & drop (à implémenter)

#### Test 15: Réordonner bandeaux
**Objectif**: Vérifier le drag & drop pour l'ordre des bandeaux

**Étapes**:
1. Créer 3 bandeaux
2. Drag bandeau 3 vers position 1
3. Observer preview

**Résultat attendu**:
- ✅ Ordre changé dans la liste
- ✅ Preview affiche bandeaux dans nouvel ordre
- ✅ Badge "Modifications non publiées" apparaît

**Statut**: ⏳ À implémenter puis tester

---

#### Test 16: Réordonner popups
**Objectif**: Vérifier le drag & drop pour l'ordre des popups

**Étapes**:
1. Créer 3 popups
2. Drag popup 3 vers position 1
3. Observer l'état

**Résultat attendu**:
- ✅ Ordre changé dans la liste
- ✅ Champ `order` mis à jour
- ✅ Badge "Modifications non publiées" apparaît

**Statut**: ⏳ À implémenter puis tester

---

#### Test 17: Réordonner sections dans Settings
**Objectif**: Vérifier le drag & drop des sections (hero, banner, popups)

**Étapes**:
1. Naviguer vers "Paramètres"
2. Drag "POPUPS" avant "HERO"
3. Observer preview

**Résultat attendu**:
- ✅ Ordre changé dans Settings
- ✅ Preview affiche sections dans nouvel ordre
- ✅ Badge "Modifications non publiées" apparaît

**Statut**: ⏳ À implémenter puis tester

---

### Catégorie 6: Tests preview

#### Test 18: Preview affiche hero si activé
**Objectif**: Vérifier l'affichage du hero dans preview

**Étapes**:
1. Activer section Hero dans Settings
2. Configurer titre, image dans module Hero
3. Observer preview

**Résultat attendu**:
- ✅ Hero visible dans preview avec image de fond
- ✅ Titre et sous-titre affichés
- ✅ Overlay gradient visible

**Statut**: ✅ Implémenté, à tester

---

#### Test 19: Preview affiche bandeaux actifs
**Objectif**: Vérifier l'affichage des bandeaux dans preview

**Étapes**:
1. Créer 2 bandeaux
2. Activer les 2 bandeaux
3. Observer preview

**Résultat attendu**:
- ✅ Les 2 bandeaux visibles dans preview
- ✅ Couleurs de fond/texte respectées
- ✅ Icônes affichées si configurées
- ✅ Ordre respecté

**Statut**: ✅ Implémenté, à tester

---

#### Test 20: Preview indique nb popups actifs
**Objectif**: Vérifier l'indicateur de popups dans preview

**Étapes**:
1. Créer 3 popups
2. Activer 2 popups sur 3
3. Observer preview

**Résultat attendu**:
- ✅ Badge bleu indiquant "2 popup(s) actif(s)"
- ✅ Compteur correct
- ✅ Badge disparaît si 0 popups actifs

**Statut**: ✅ Implémenté, à tester

---

### Catégorie 7: Tests publication/brouillon

#### Test 21: Bouton "Publier" visible si modifications
**Objectif**: Vérifier l'affichage conditionnel du bouton Publier

**Étapes**:
1. Ouvrir Studio V2 (aucune modification)
2. Observer navigation
3. Modifier un élément
4. Observer navigation

**Résultat attendu**:
- ✅ Avant modification: pas de badge orange, boutons grisés
- ✅ Après modification: badge orange "Modifications non publiées"
- ✅ Boutons "Publier" et "Annuler" actifs et visibles

**Statut**: ✅ Implémenté, à tester

---

#### Test 22: Publier sauvegarde dans Firestore
**Objectif**: Vérifier que "Publier" écrit dans Firestore

**Étapes**:
1. Créer un bandeau
2. Cliquer sur "Publier"
3. Attendre confirmation
4. Vérifier Firestore console

**Résultat attendu**:
- ✅ Snackbar vert "✓ Modifications publiées avec succès"
- ✅ Badge orange disparaît
- ✅ Boutons "Publier"/"Annuler" deviennent inactifs
- ✅ Firestore: document créé dans `app_banners/{id}`

**Statut**: ✅ Implémenté, à tester

---

#### Test 23: Annuler reset vers état publié
**Objectif**: Vérifier que "Annuler" réinitialise les modifications

**Étapes**:
1. Créer un bandeau
2. Cliquer sur "Annuler"
3. Confirmer dans dialog
4. Observer l'état

**Résultat attendu**:
- ✅ Dialog de confirmation affiché
- ✅ Après confirmation: bandeau créé disparaît
- ✅ Badge orange disparaît
- ✅ État revient à l'état publié
- ✅ Snackbar "Modifications annulées"

**Statut**: ✅ Implémenté, à tester

---

#### Test 24: Recharger page perd draft
**Objectif**: Vérifier que le draft n'est pas persisté entre sessions

**Étapes**:
1. Créer un bandeau (ne pas publier)
2. Recharger la page (F5)
3. Observer l'état

**Résultat attendu**:
- ✅ Bandeau créé a disparu (draft perdu)
- ✅ État chargé depuis Firestore (published state)
- ✅ Aucun badge "Modifications non publiées"

**Statut**: ⏳ À tester

---

### Catégorie 8: Tests rétro-compatibilité

#### Test 25: Ancien studio toujours accessible
**Objectif**: Vérifier que l'ancien studio n'est pas cassé

**Étapes**:
1. Naviguer vers `/admin/studio`
2. Observer l'affichage

**Résultat attendu**:
- ✅ Ancien AdminStudioScreen s'affiche
- ✅ Pas d'erreur
- ✅ Liens vers produits/promotions/mailing fonctionnent

**Statut**: ⏳ À tester

---

#### Test 26: Données existantes non affectées
**Objectif**: Vérifier qu'aucune donnée existante n'est modifiée/supprimée

**Étapes**:
1. Vérifier Firestore console avant Studio V2
2. Ouvrir Studio V2
3. Naviguer entre modules (sans publier)
4. Vérifier Firestore console après

**Résultat attendu**:
- ✅ Aucun document modifié
- ✅ Aucun document supprimé
- ✅ Seuls nouveaux documents: `text_blocks`, `popups_v2` si créés

**Statut**: ⏳ À tester

---

#### Test 27: Autres sections admin intactes
**Objectif**: Vérifier que produits/commandes/fidélité/roulette fonctionnent

**Étapes**:
1. Naviguer vers différentes sections:
   - Produits admin
   - Promotions admin
   - Mailing admin
   - Kitchen
   - Roulette (client)
2. Vérifier fonctionnement normal

**Résultat attendu**:
- ✅ Toutes sections fonctionnent normalement
- ✅ Pas de régression
- ✅ Données intactes

**Statut**: ⏳ À tester

---

## 🧪 Tests Additionnels Recommandés

### Test 28: Performance - Chargement initial
**Objectif**: Vérifier temps de chargement

**Étapes**:
1. Ouvrir Studio V2
2. Mesurer temps de chargement (network tab)

**Résultat attendu**:
- ✅ Chargement < 2 secondes (avec cache)
- ✅ Pas de requêtes inutiles
- ✅ Streams optimisés

**Statut**: ⏳ À tester

---

### Test 29: Performance - Draft updates
**Objectif**: Vérifier que draft updates sont instantanés

**Étapes**:
1. Modifier rapidement plusieurs champs Hero
2. Observer réactivité

**Résultat attendu**:
- ✅ Preview mis à jour sans lag
- ✅ Pas de ralentissement
- ✅ UI reste responsive

**Statut**: ⏳ À tester

---

### Test 30: Erreur - Publication échoue
**Objectif**: Vérifier gestion d'erreur si Firestore inaccessible

**Étapes**:
1. Simuler erreur Firestore (réseau coupé)
2. Tenter de publier
3. Observer comportement

**Résultat attendu**:
- ✅ Snackbar rouge avec message d'erreur
- ✅ État draft préservé
- ✅ Possibilité de ré-essayer

**Statut**: ⏳ À tester

---

### Test 31: Sécurité - Non-admin bloqué
**Objectif**: Vérifier que seuls les admins accèdent au Studio V2

**Étapes**:
1. Se connecter en tant que client (non-admin)
2. Tenter de naviguer vers `/admin/studio/v2`
3. Observer comportement

**Résultat attendu**:
- ✅ Redirection automatique vers `/home`
- ✅ Pas d'accès au Studio V2
- ✅ Message ou loader temporaire

**Statut**: ⏳ À tester

---

### Test 32: Multi-onglets - État synchronisé
**Objectif**: Vérifier comportement avec plusieurs onglets

**Étapes**:
1. Ouvrir Studio V2 dans onglet 1
2. Ouvrir Studio V2 dans onglet 2
3. Publier dans onglet 1
4. Observer onglet 2

**Résultat attendu**:
- ✅ Onglet 2 reste sur son draft (pas de sync auto)
- ✅ Recharger onglet 2 charge nouvel état publié
- ⚠️ Pas de conflit de données

**Statut**: ⏳ À tester

---

## 📊 Résumé des Tests

### Par statut
- ✅ **Implémenté et prêt**: 6 tests
- ⏳ **À tester manuellement**: 26 tests
- 🔨 **À implémenter puis tester**: 3 tests (drag & drop)

### Par catégorie
- **Affichage**: 5 tests
- **Création**: 3 tests
- **Édition**: 3 tests
- **Suppression**: 3 tests
- **Drag & drop**: 3 tests
- **Preview**: 3 tests
- **Publication/Brouillon**: 4 tests
- **Rétro-compatibilité**: 3 tests
- **Additionnels**: 5 tests

**Total**: 32 tests manuels

## 🚀 Exécution des Tests

### Prérequis
1. ✅ Firebase configuré et accessible
2. ✅ Compte admin créé dans Firestore
3. ✅ Application démarrée: `flutter run`
4. ✅ Navigateur ouvert sur localhost

### Instructions
1. Se connecter en tant qu'admin
2. Naviguer vers `/admin/studio/v2`
3. Suivre chaque test dans l'ordre
4. Cocher ✅ les tests réussis
5. Documenter ❌ les tests échoués avec détails

### Rapport de bugs
Pour chaque bug trouvé:
- **Test #**: Numéro du test
- **Description**: Ce qui ne fonctionne pas
- **Étapes pour reproduire**: Liste précise
- **Résultat attendu vs obtenu**
- **Captures d'écran**: Si applicable
- **Console errors**: Logs d'erreur

---

**Version**: 1.0  
**Date**: 2025-01-20  
**Statut**: 🧪 Tests prêts à exécuter
