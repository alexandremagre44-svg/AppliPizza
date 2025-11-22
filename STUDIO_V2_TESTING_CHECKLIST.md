# Studio V2 - Liste de Vérification des Tests

**Date:** 2025-11-22  
**Version:** 2.1  
**Statut:** 📋 Guide de Test Complet

---

## 🎯 Objectif

Cette checklist permet de vérifier que tous les bugs du Studio V2 ont bien été corrigés et que toutes les fonctionnalités marchent correctement.

---

## ✅ Tests Fonctionnels

### Test 1: Preview Temps Réel - Hero Titre
- [ ] Ouvrir Studio V2 (`/admin/studio/v2`)
- [ ] Ouvrir console navigateur (F12)
- [ ] Cliquer sur "Hero" dans navigation
- [ ] Cliquer dans le champ "Titre principal"
- [ ] Taper lentement: "P", "i", "z", "z", "a"
- [ ] **Vérifier:** Preview affiche chaque lettre immédiatement
- [ ] **Vérifier:** Console affiche les logs `STUDIO HERO: _updateConfig`
- [ ] **Vérifier:** Console affiche `PREVIEW: Forcing rebuild`

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 2: Preview Temps Réel - Hero Sous-titre
- [ ] Dans module Hero, cliquer dans "Sous-titre"
- [ ] Taper: "Les meilleures pizzas"
- [ ] **Vérifier:** Preview affiche le sous-titre en temps réel
- [ ] **Vérifier:** Badge orange "Modifications non publiées" visible

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 3: Preview Temps Réel - Hero Image
- [ ] Dans module Hero, coller une URL d'image dans "URL de l'image"
- [ ] Exemple: `https://images.unsplash.com/photo-1513104890138-7c749659a591`
- [ ] **Vérifier:** Preview affiche l'image immédiatement
- [ ] **Vérifier:** Message "Prévisualisation disponible" s'affiche

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 4: Preview Temps Réel - Hero Toggle
- [ ] Dans module Hero, désactiver "Afficher la section Hero"
- [ ] **Vérifier:** Preview masque le hero immédiatement
- [ ] Réactiver le toggle
- [ ] **Vérifier:** Preview affiche le hero à nouveau

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 5: Annulation des Modifications
- [ ] Noter le titre actuel (ex: "Bienvenue chez Pizza Deli'Zza")
- [ ] Modifier le titre à "Test Cancel 123"
- [ ] **Vérifier:** Preview affiche "Test Cancel 123"
- [ ] **Vérifier:** Badge orange visible
- [ ] Cliquer "Annuler" dans navigation
- [ ] Confirmer dans le dialog
- [ ] **Vérifier:** Champ revient au titre original
- [ ] **Vérifier:** Preview revient au titre original
- [ ] **Vérifier:** Badge orange disparaît
- [ ] **Vérifier:** Console affiche `STUDIO HERO: _updateControllers`

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 6: Publication vers Firestore
- [ ] Modifier titre à "Test Publication $(date +%s)"
- [ ] **Vérifier:** Preview affiche le nouveau titre
- [ ] Cliquer "Publier"
- [ ] **Vérifier:** Snackbar vert "✓ Modifications publiées"
- [ ] **Vérifier:** Badge orange disparaît
- [ ] **Vérifier:** Console affiche `STUDIO V2 PUBLISH → ✓ All changes published`
- [ ] Ouvrir Firebase Console → Firestore
- [ ] Naviguer vers `app_home_config/main`
- [ ] **Vérifier:** `hero/title` contient le nouveau titre
- [ ] **Vérifier:** `updatedAt` est récent (< 1 minute)

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 7: Application Réelle Après Publication
- [ ] Ouvrir nouvel onglet
- [ ] Naviguer vers `/` ou `/home`
- [ ] Hard refresh (Ctrl+Shift+R ou Cmd+Shift+R)
- [ ] **Vérifier:** Hero affiche le titre publié
- [ ] **Vérifier:** Toutes les modifications sont visibles
- [ ] Retourner au Studio V2
- [ ] **Vérifier:** Aucun badge orange (pas de modifications)

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 8: Persistence Après Reload
- [ ] Dans Studio V2, recharger la page (F5)
- [ ] Attendre le chargement complet
- [ ] Aller dans module Hero
- [ ] **Vérifier:** Tous les champs affichent les valeurs publiées
- [ ] **Vérifier:** Preview affiche les valeurs publiées
- [ ] **Vérifier:** Aucun badge orange

**Résultat:** ✅ PASS / ❌ FAIL

---

## 🔄 Tests des Autres Modules

### Test 9: Module Banners
- [ ] Cliquer sur "Bandeaux" dans navigation
- [ ] Créer un nouveau bandeau
- [ ] Modifier le texte
- [ ] **Vérifier:** Preview se met à jour (si applicable)
- [ ] Publier
- [ ] **Vérifier:** Sauvegarde réussie

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 10: Module Popups
- [ ] Cliquer sur "Popups" dans navigation
- [ ] Créer un nouveau popup
- [ ] Modifier les paramètres
- [ ] **Vérifier:** Interface réactive
- [ ] Publier
- [ ] **Vérifier:** Sauvegarde réussie

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 11: Module Textes Dynamiques
- [ ] Cliquer sur "Textes dynamiques" dans navigation
- [ ] Créer un nouveau bloc de texte
- [ ] Modifier le contenu
- [ ] **Vérifier:** Interface réactive
- [ ] Publier
- [ ] **Vérifier:** Sauvegarde réussie

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 12: Module Contenu d'Accueil
- [ ] Cliquer sur "Contenu d'accueil" dans navigation
- [ ] **Vérifier:** Module charge correctement
- [ ] Explorer les différents onglets
- [ ] **Vérifier:** Tous les onglets fonctionnent
- [ ] **Vérifier:** Pas d'erreurs console

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 13: Module Sections V3
- [ ] Cliquer sur "Sections V3" dans navigation
- [ ] **Vérifier:** Module charge correctement
- [ ] Créer une nouvelle section
- [ ] **Vérifier:** Dialog s'ouvre
- [ ] **Vérifier:** Peut créer et modifier sections

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 14: Module Settings
- [ ] Cliquer sur "Paramètres" dans navigation
- [ ] Modifier un paramètre (ex: ordre des sections)
- [ ] **Vérifier:** Interface réactive
- [ ] Publier
- [ ] **Vérifier:** Sauvegarde réussie

**Résultat:** ✅ PASS / ❌ FAIL

---

## 📱 Tests Responsive

### Test 15: Mobile - Navigation
- [ ] Réduire largeur navigateur < 800px
- [ ] **Vérifier:** Navigation passe en mode dropdown
- [ ] **Vérifier:** Boutons "Publier" et "Annuler" visibles
- [ ] **Vérifier:** Peut naviguer entre modules

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 16: Mobile - Édition
- [ ] En mode mobile, aller dans Hero
- [ ] Modifier le titre
- [ ] **Vérifier:** Champs accessibles
- [ ] **Vérifier:** Peut taper et éditer
- [ ] **Vérifier:** Pas de problème de layout

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 17: Mobile - Publication
- [ ] En mode mobile, publier des modifications
- [ ] **Vérifier:** Snackbar visible et lisible
- [ ] **Vérifier:** Retour visuel approprié

**Résultat:** ✅ PASS / ❌ FAIL

---

## 🔍 Tests de Debug et Logs

### Test 18: Logs Preview Rebuild
- [ ] Ouvrir console, filtrer par "PREVIEW"
- [ ] Modifier un champ dans Hero
- [ ] **Vérifier:** Logs `PREVIEW: Forcing rebuild #X`
- [ ] **Vérifier:** Logs indiquent ce qui a changé
- [ ] **Vérifier:** Compteur de rebuild s'incrémente

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 19: Logs Hero Module
- [ ] Ouvrir console, filtrer par "STUDIO HERO"
- [ ] Modifier titre et sous-titre
- [ ] **Vérifier:** Logs `_updateConfig called`
- [ ] **Vérifier:** Logs affichent les nouvelles valeurs
- [ ] **Vérifier:** Logs `_updateConfig done`

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 20: Logs Draft State
- [ ] Ouvrir console, filtrer par "DRAFT STATE"
- [ ] Modifier n'importe quel champ
- [ ] **Vérifier:** Logs `setHomeConfig called`
- [ ] **Vérifier:** Logs affichent les valeurs mises à jour
- [ ] **Vérifier:** Logs `State updated`

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 21: Logs Publication
- [ ] Ouvrir console, filtrer par "STUDIO V2 PUBLISH"
- [ ] Publier des modifications
- [ ] **Vérifier:** Logs détaillés avec toutes les valeurs
- [ ] **Vérifier:** Confirmation de sauvegarde pour chaque élément
- [ ] **Vérifier:** Message final "✓ All changes published"

**Résultat:** ✅ PASS / ❌ FAIL

---

## 🛡️ Tests de Régression

### Test 22: Navigation Sans Modifications
- [ ] Ouvrir Studio V2
- [ ] Cliquer sur différents modules sans rien modifier
- [ ] **Vérifier:** Pas de badge orange
- [ ] **Vérifier:** Peut naviguer librement
- [ ] **Vérifier:** Preview affiche toujours les bonnes données

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 23: Modifications Multiples Avant Publication
- [ ] Modifier le titre Hero
- [ ] Aller dans Banners, modifier un bandeau
- [ ] Aller dans Settings, modifier un paramètre
- [ ] **Vérifier:** Badge orange persiste
- [ ] Revenir à Hero
- [ ] **Vérifier:** Modifications Hero toujours présentes
- [ ] Publier tout
- [ ] **Vérifier:** Toutes les modifications sauvegardées

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 24: Annulation Après Modifications Multiples
- [ ] Modifier plusieurs champs dans Hero
- [ ] Modifier des éléments dans d'autres modules
- [ ] Cliquer Annuler
- [ ] **Vérifier:** TOUTES les modifications annulées
- [ ] **Vérifier:** Tous les modules revenus à l'état original

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 25: Publication Puis Modification Immédiate
- [ ] Modifier et publier un titre
- [ ] Immédiatement modifier à nouveau
- [ ] **Vérifier:** Badge orange réapparaît
- [ ] **Vérifier:** Preview se met à jour
- [ ] Annuler
- [ ] **Vérifier:** Revient à la dernière version publiée (pas l'originale)

**Résultat:** ✅ PASS / ❌ FAIL

---

## 🚨 Tests d'Erreurs

### Test 26: Erreurs Firestore (Simulées)
- [ ] Couper la connexion réseau
- [ ] Modifier des champs
- [ ] **Vérifier:** Preview fonctionne toujours (mode offline)
- [ ] Essayer de publier
- [ ] **Vérifier:** Message d'erreur approprié
- [ ] Restaurer connexion
- [ ] Publier à nouveau
- [ ] **Vérifier:** Publication réussie

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 27: Champs Vides
- [ ] Vider complètement le titre Hero
- [ ] **Vérifier:** Message d'erreur affiché
- [ ] **Vérifier:** Preview affiche titre vide
- [ ] Essayer de publier
- [ ] **Vérifier:** Validation appropriée

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 28: URL Image Invalide
- [ ] Entrer une URL d'image invalide
- [ ] **Vérifier:** Preview affiche placeholder ou erreur
- [ ] **Vérifier:** Peut quand même publier
- [ ] **Vérifier:** Pas de crash de l'application

**Résultat:** ✅ PASS / ❌ FAIL

---

## 🎨 Tests UI/UX

### Test 29: Feedback Visuel
- [ ] Vérifier badge orange apparaît lors de modifications
- [ ] Vérifier badge disparaît après publication
- [ ] Vérifier badge disparaît après annulation
- [ ] Vérifier snackbar de succès après publication
- [ ] Vérifier dialog de confirmation pour annulation

**Résultat:** ✅ PASS / ❌ FAIL

---

### Test 30: Performance
- [ ] Taper rapidement dans un champ texte (ex: coller un long texte)
- [ ] **Vérifier:** Preview se met à jour sans lag
- [ ] **Vérifier:** Interface reste responsive
- [ ] **Vérifier:** Pas de freeze ou ralentissement

**Résultat:** ✅ PASS / ❌ FAIL

---

## 📊 Résumé des Tests

**Tests Réussis:** ___ / 30  
**Tests Échoués:** ___ / 30  
**Taux de Réussite:** ____%

---

## 🐛 Bugs Trouvés

Si des tests échouent, documenter ici:

### Bug #1
- **Test:** #___
- **Symptôme:** 
- **Étapes pour reproduire:**
- **Logs/Screenshots:**

### Bug #2
- **Test:** #___
- **Symptôme:** 
- **Étapes pour reproduire:**
- **Logs/Screenshots:**

---

## ✅ Critères de Validation

Pour que Studio V2 soit considéré comme "prêt pour production":

- [ ] Au moins 27/30 tests passent (90%)
- [ ] TOUS les tests critiques passent (1-8)
- [ ] Aucun bug bloquant trouvé
- [ ] Performance acceptable (Test 30)
- [ ] Logs appropriés dans la console

---

## 📞 Prochaines Étapes

Si **TOUS les tests passent:**
1. ✅ Marquer le Studio V2 comme "Production Ready"
2. ✅ Communiquer aux utilisateurs
3. ✅ Surveiller les logs en production

Si **des tests échouent:**
1. ❌ Documenter les bugs dans la section ci-dessus
2. ❌ Créer des issues GitHub avec détails
3. ❌ Corriger les bugs critiques
4. ❌ Re-tester

---

**Testeur:** _______________  
**Date du Test:** _______________  
**Version Testée:** 2.1  
**Navigateur:** _______________  
**Résolution:** _______________  

---

**Auteur:** Copilot Agent  
**Dernière Mise à Jour:** 2025-11-22
