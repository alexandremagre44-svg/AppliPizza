# Checklist de Tests - Mode Cuisine

## ✅ Tests à Effectuer Avant Déploiement

### 1. Tests des Zones de Tap (50% / 50%)

#### Test 1.1: Zone Gauche - Statut Précédent
- [ ] Créer une commande en statut "En préparation"
- [ ] Cliquer sur la moitié GAUCHE de la carte
- [ ] **Vérifier**: Le statut passe à "En attente"
- [ ] **Vérifier**: Vibration haptique ressentie (sur appareil compatible)

#### Test 1.2: Zone Droite - Statut Suivant
- [ ] Avoir une commande en statut "En attente"
- [ ] Cliquer sur la moitié DROITE de la carte
- [ ] **Vérifier**: Le statut passe à "En préparation"
- [ ] **Vérifier**: Vibration haptique ressentie

#### Test 1.3: Limites des Statuts
- [ ] Commande en "En attente": Cliquer GAUCHE
  - [ ] **Vérifier**: Aucun changement (pas de statut avant)
- [ ] Commande en "Prête": Cliquer DROITE
  - [ ] **Vérifier**: Aucun changement (pas de statut après)

#### Test 1.4: Précision de la Zone 50%
- [ ] Cliquer exactement au centre de la carte (sur le séparateur invisible)
- [ ] Répéter 10 fois
- [ ] **Vérifier**: ~5 clics détectés comme gauche, ~5 comme droite
- [ ] **Note**: Il est normal qu'il n'y ait pas de zone "morte" au milieu

### 2. Tests du Double Tap

#### Test 2.1: Double Tap Zone Gauche
- [ ] Double-cliquer rapidement sur la zone GAUCHE
- [ ] **Vérifier**: Le popup de détails s'ouvre
- [ ] **Vérifier**: Le statut n'a PAS changé
- [ ] Fermer le popup

#### Test 2.2: Double Tap Zone Droite
- [ ] Double-cliquer rapidement sur la zone DROITE
- [ ] **Vérifier**: Le popup de détails s'ouvre
- [ ] **Vérifier**: Le statut n'a PAS changé
- [ ] Fermer le popup

#### Test 2.3: Double Tap au Centre
- [ ] Double-cliquer au centre exact de la carte
- [ ] **Vérifier**: Le popup s'ouvre
- [ ] **Vérifier**: Toutes les informations sont affichées:
  - [ ] Numéro de commande
  - [ ] Informations client
  - [ ] Liste complète des items
  - [ ] Personnalisations
  - [ ] Commentaires
  - [ ] Total
  - [ ] Boutons d'action

#### Test 2.4: Rapidité du Double Tap
- [ ] Cliquer 2 fois lentement (>500ms entre clics)
- [ ] **Vérifier**: Le statut change (détecté comme 2 simples taps)
- [ ] Cliquer 2 fois rapidement (<300ms entre clics)
- [ ] **Vérifier**: Le popup s'ouvre (détecté comme double tap)

### 3. Tests de l'Urgence

#### Test 3.1: Commande Urgente (Dans 15 minutes)
- [ ] Créer une commande avec retrait dans 15 minutes
- [ ] **Vérifier**: Bordure ambre épaisse visible
- [ ] **Vérifier**: Badge "URGENT" avec icône ⚠️ affiché
- [ ] **Vérifier**: Effet de glow ambre autour de la carte
- [ ] **Vérifier**: La carte "ressort" visuellement des autres

#### Test 3.2: Commande Normale (Dans 30+ minutes)
- [ ] Créer une commande avec retrait dans 45 minutes
- [ ] **Vérifier**: Pas de bordure ambre
- [ ] **Vérifier**: Pas de badge "URGENT"
- [ ] **Vérifier**: Apparence normale de la carte

#### Test 3.3: Commande Très Urgente (Dans 5 minutes)
- [ ] Créer une commande avec retrait dans 5 minutes
- [ ] **Vérifier**: Bordure ambre présente
- [ ] **Vérifier**: Badge "URGENT" présent
- [ ] **Note**: Les indicateurs sont les mêmes que pour 15 min

#### Test 3.4: Commande en Retard Léger (Retrait passé de 3 min)
- [ ] Créer une commande dont le retrait était il y a 3 minutes
- [ ] **Vérifier**: TOUJOURS marquée comme urgente
- [ ] **Note**: Marge de -5 minutes pour gérer les petits retards

#### Test 3.5: Commande Très en Retard (Retrait passé de 10 min)
- [ ] Créer une commande dont le retrait était il y a 10 minutes
- [ ] **Vérifier**: Plus marquée comme urgente
- [ ] **Note**: Au-delà de -5 minutes, l'urgence disparaît

#### Test 3.6: Commande Sans Heure de Retrait
- [ ] Créer une commande sans spécifier d'heure de retrait
- [ ] **Vérifier**: Pas d'indicateur d'urgence
- [ ] **Vérifier**: La carte s'affiche normalement

### 4. Tests de Tri et Affichage

#### Test 4.1: Tri par Heure de Retrait
- [ ] Créer 3 commandes avec retraits à 12h00, 13h00, 11h30
- [ ] **Vérifier**: Ordre d'affichage: 11h30, 12h00, 13h00
- [ ] **Note**: Les plus urgentes en premier

#### Test 4.2: Tri Sans Heure de Retrait
- [ ] Créer 2 commandes sans heure de retrait
- [ ] **Vérifier**: Triées par heure de création
- [ ] **Note**: Plus anciennes en premier

#### Test 4.3: Mélange avec et Sans Retrait
- [ ] Créer 2 commandes avec retrait
- [ ] Créer 2 commandes sans retrait
- [ ] **Vérifier**: Commandes avec retrait en premier
- [ ] **Vérifier**: Puis commandes sans retrait par ordre de création

#### Test 4.4: Fenêtre de Planning
- [ ] Créer une commande avec retrait dans 2 heures
- [ ] **Vérifier**: Elle N'apparaît PAS dans la liste
- [ ] **Note**: Fenêtre par défaut = +45 minutes
- [ ] Attendre que le retrait soit dans 30 minutes
- [ ] Rafraîchir
- [ ] **Vérifier**: Elle APPARAÎT maintenant

### 5. Tests de Feedback

#### Test 5.1: Retour Haptique
- [ ] Sur un appareil mobile/tablette
- [ ] Taper zone gauche
- [ ] **Vérifier**: Vibration légère ressentie
- [ ] Taper zone droite
- [ ] **Vérifier**: Vibration légère ressentie
- [ ] **Note**: Peut ne pas fonctionner sur tous les appareils

#### Test 5.2: Changement Visuel Immédiat
- [ ] Taper pour changer le statut
- [ ] **Vérifier**: Le badge de statut change instantanément
- [ ] **Vérifier**: La couleur de la carte change instantanément
- [ ] **Note**: Pas de délai perceptible

#### Test 5.3: Badge "NOUVELLE"
- [ ] Créer une nouvelle commande
- [ ] **Vérifier**: Badge "NOUVELLE" ou animation visible
- [ ] Cliquer dessus (simple ou double tap)
- [ ] **Vérifier**: Le badge disparaît après interaction

### 6. Tests de Performance

#### Test 6.1: Grille avec Beaucoup de Commandes
- [ ] Créer 20+ commandes
- [ ] **Vérifier**: Le scroll est fluide
- [ ] **Vérifier**: Les taps sont réactifs
- [ ] **Note**: Toutes les cartes doivent rester interactives

#### Test 6.2: Rafraîchissement
- [ ] Cliquer sur le bouton rafraîchir
- [ ] **Vérifier**: Les commandes se rechargent
- [ ] **Vérifier**: Les urgences sont recalculées
- [ ] **Vérifier**: Pas de lag perceptible

#### Test 6.3: Mises à Jour en Temps Réel
- [ ] Ouvrir le mode cuisine sur un appareil
- [ ] Créer une commande depuis un autre appareil/navigateur
- [ ] **Vérifier**: La nouvelle commande apparaît automatiquement
- [ ] **Note**: Devrait être quasi-instantané

### 7. Tests Multi-Écrans

#### Test 7.1: Tablette Paysage (1920x1080)
- [ ] Ouvrir sur tablette en mode paysage
- [ ] **Vérifier**: 3-4 colonnes de cartes
- [ ] **Vérifier**: Les zones 50/50 fonctionnent
- [ ] **Vérifier**: Le texte est lisible

#### Test 7.2: Tablette Portrait (1080x1920)
- [ ] Tourner la tablette en portrait
- [ ] **Vérifier**: 2 colonnes de cartes
- [ ] **Vérifier**: Les zones 50/50 fonctionnent
- [ ] **Vérifier**: Le texte est lisible

#### Test 7.3: Mobile (375x667)
- [ ] Ouvrir sur un téléphone
- [ ] **Vérifier**: 1 colonne de cartes
- [ ] **Vérifier**: Les zones 50/50 fonctionnent
- [ ] **Vérifier**: Le texte reste lisible

#### Test 7.4: Grand Écran (2560x1440)
- [ ] Ouvrir sur un grand écran
- [ ] **Vérifier**: 4+ colonnes de cartes
- [ ] **Vérifier**: Les cartes ne sont pas étirées
- [ ] **Vérifier**: L'espacement reste cohérent

### 8. Tests de Cas Limites

#### Test 8.1: Commande Sans Items
- [ ] Créer une commande vide (si possible)
- [ ] **Vérifier**: La carte s'affiche sans crasher
- [ ] **Vérifier**: Un message approprié est affiché

#### Test 8.2: Commande avec Beaucoup d'Items
- [ ] Créer une commande avec 20+ items
- [ ] **Vérifier**: Seuls les 4 premiers sont affichés sur la carte
- [ ] **Vérifier**: Un indicateur "+X éléments" est présent
- [ ] Double-cliquer pour ouvrir
- [ ] **Vérifier**: Tous les items sont visibles dans le popup

#### Test 8.3: Nom de Produit Très Long
- [ ] Créer un item avec un nom de 100+ caractères
- [ ] **Vérifier**: Le texte est tronqué avec "..."
- [ ] **Vérifier**: La carte ne déborde pas

#### Test 8.4: Changements Rapides de Statut
- [ ] Taper rapidement 5x sur zone droite
- [ ] **Vérifier**: Le statut change correctement à chaque tap
- [ ] **Vérifier**: Pas de "lag" ou de sauts de statut

#### Test 8.5: Heure de Retrait Mal Formatée
- [ ] Injecter une commande avec pickupTimeSlot = "invalid"
- [ ] **Vérifier**: L'app ne crash pas
- [ ] **Vérifier**: L'heure s'affiche telle quelle ou un placeholder

### 9. Tests d'Accessibilité

#### Test 9.1: Taille des Zones Tactiles
- [ ] Mesurer visuellement les zones de tap
- [ ] **Vérifier**: Chaque zone fait au moins 200px de large
- [ ] **Note**: Recommandation: minimum 48dp = ~70px

#### Test 9.2: Contraste des Couleurs
- [ ] Vérifier toutes les combinaisons texte/fond:
  - [ ] Texte blanc sur fond bleu (#0D47A1)
  - [ ] Texte blanc sur fond magenta (#AD1457)
  - [ ] Texte blanc sur fond orange (#E65100)
  - [ ] Texte blanc sur fond vert (#1B5E20)
- [ ] **Vérifier**: Ratio de contraste ≥ 4.5:1 (WCAG AA)

#### Test 9.3: Lisibilité à Distance
- [ ] Se placer à 2 mètres de l'écran
- [ ] **Vérifier**: Le numéro de commande est lisible
- [ ] **Vérifier**: Le statut est lisible
- [ ] **Vérifier**: Les indicateurs d'urgence sont visibles

### 10. Tests de Régression

#### Test 10.1: Toutes les Autres Fonctionnalités
- [ ] Badge de notifications (nombre de nouvelles commandes)
- [ ] Bouton d'impression
- [ ] Bouton de rafraîchissement
- [ ] Bouton de sortie
- [ ] Timer de temps écoulé (mise à jour toutes les 30s)

#### Test 10.2: Intégration avec le Reste de l'App
- [ ] Navigation depuis la page Profil
- [ ] Retour à la page d'accueil
- [ ] Déconnexion depuis le mode cuisine
- [ ] Changement de rôle utilisateur

## 📊 Résumé des Tests

```
Total de tests: ~60
Temps estimé: 45-60 minutes
```

### Critères de Succès
- ✅ 100% des tests de zones de tap passent
- ✅ 100% des tests de double tap passent
- ✅ 100% des tests d'urgence passent
- ✅ ≥95% des autres tests passent
- ✅ Aucun crash ou comportement bloquant

### Bugs Critiques (Bloquants)
Si l'un de ces tests échoue, NE PAS déployer:
- [ ] Zones de tap ne fonctionnent pas du tout
- [ ] Double tap ouvre le popup mais change aussi le statut
- [ ] App crash lors de l'ouverture du mode cuisine
- [ ] Commandes ne s'affichent pas

### Bugs Majeurs (À corriger rapidement)
- [ ] Urgence ne s'affiche pas correctement
- [ ] Tri des commandes incorrect
- [ ] Retour haptique ne fonctionne pas
- [ ] Performance dégradée avec beaucoup de commandes

### Bugs Mineurs (À corriger mais non-bloquant)
- [ ] Badge "URGENT" légèrement mal aligné
- [ ] Couleurs légèrement différentes de la spec
- [ ] Animations pas parfaitement fluides

## 🔧 Debugging

### Si les zones de tap ne fonctionnent pas
1. Vérifier que `HitTestBehavior.opaque` est présent
2. Vérifier qu'il n'y a pas d'overlay au-dessus
3. Activer le mode debug Flutter pour voir les zones

### Si le double tap ne fonctionne pas
1. Vérifier le timing entre les 2 clics (<300ms)
2. Vérifier que les 2 clics sont au même endroit
3. Tester sur un vrai appareil (pas seulement simulateur)

### Si l'urgence ne s'affiche pas
1. Vérifier que `pickupDate` et `pickupTimeSlot` sont définis
2. Vérifier le format: date = "DD/MM/YYYY", time = "HH:MM"
3. Vérifier que l'heure système est correcte
4. Logs: Imprimer `minutesUntilPickup` pour debug

## 📝 Notes Importantes

1. **Tous les tests doivent être effectués sur un vrai appareil**, pas seulement un émulateur
2. **Tester avec différents rôles**: kitchen, admin
3. **Tester en conditions réelles**: environnement bruyant, mains mouillées, etc.
4. **Documenter tous les bugs** trouvés avec screenshots
5. **Refaire les tests** après chaque correction de bug

---

**Version**: 1.0  
**Date**: 2025-11-12  
**Status**: Ready for Testing
