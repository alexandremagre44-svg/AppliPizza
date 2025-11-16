# Guide de test - Roulette unifiée

## 🎯 Objectif

Vérifier que la configuration unifiée de la roulette fonctionne correctement de bout en bout.

---

## 📋 Prérequis

1. Application déployée avec les dernières modifications
2. Accès admin à l'application
3. Accès Firebase Console (optionnel, pour vérifier Firestore)
4. Au moins 1 compte utilisateur test

---

## 🧪 Tests Admin - Configuration

### Test 1: Accès à l'écran unifié

**Étapes:**
1. Ouvrir l'application en mode admin
2. Aller dans **Studio**
3. Chercher **"Paramètres de la roulette"**

**Résultat attendu:**
- ✅ L'écran s'ouvre sans erreur
- ✅ On voit 4 sections: Activation, Cooldown, Limites, Horaires
- ✅ Les valeurs par défaut sont chargées

**Résultat réel:** _____________

---

### Test 2: Configuration de base

**Étapes:**
1. Dans "Paramètres de la roulette"
2. Activer la roulette (switch ON)
3. Cooldown: 1440 minutes (24h)
4. Limite journalière: 1
5. Limites hebdo/mensuelle: 0 (illimité)
6. Horaires: 9h - 22h
7. Cliquer **"Enregistrer la configuration"**

**Résultat attendu:**
- ✅ Message de succès "Configuration sauvegardée avec succès"
- ✅ Pas d'erreur dans la console

**Résultat réel:** _____________

---

### Test 3: Vérification Firestore

**Étapes:**
1. Ouvrir Firebase Console
2. Aller dans Firestore Database
3. Chercher collection **`config`**
4. Ouvrir document **`roulette_rules`**

**Résultat attendu:**
```json
{
  "enabled": true,
  "minDelayHours": 24,
  "dailyLimit": 1,
  "weeklyLimit": 0,
  "monthlyLimit": 0,
  "allowedStartHour": 9,
  "allowedEndHour": 22
}
```

**Résultat réel:** _____________

---

## 🎨 Tests Admin - Segments

### Test 4: Vérifier les segments

**Étapes:**
1. Dans Studio, aller dans **"Roue de la chance"**
2. Vérifier qu'il y a au moins 1 segment actif

**Résultat attendu:**
- ✅ Liste de segments s'affiche
- ✅ Au moins 1 segment a `isActive = true`

**Résultat réel:** _____________

---

### Test 5: Créer un segment test (optionnel)

**Étapes:**
1. Dans "Roue de la chance"
2. Cliquer **"Ajouter un segment"**
3. Remplir:
   - Label: "Test +50 points"
   - Type: bonus_points
   - Value: 50
   - Probability: 25
   - Active: ON
4. Enregistrer

**Résultat attendu:**
- ✅ Segment créé avec succès
- ✅ Apparaît dans la liste

**Résultat réel:** _____________

---

## 📱 Tests Client - Affichage

### Test 6: Bannière visible (cas nominal)

**Configuration:**
- enabled = true
- Heure actuelle entre 9h et 22h
- Au moins 1 segment actif

**Étapes:**
1. Se connecter en tant qu'utilisateur
2. Aller sur la page d'accueil

**Résultat attendu:**
- ✅ Bannière "Tentez votre chance !" visible
- ✅ Couleur gradient (primary → secondary)
- ✅ Bouton "Jouer" présent

**Résultat réel:** _____________

---

### Test 7: Bannière masquée (roulette désactivée)

**Configuration:**
1. Admin: Désactiver la roulette (switch OFF)
2. Enregistrer

**Étapes:**
1. Utilisateur: Rafraîchir la page d'accueil

**Résultat attendu:**
- ✅ Bannière roulette disparaît
- ✅ Pas d'erreur dans la console

**Résultat réel:** _____________

---

### Test 8: Bannière masquée (hors horaires)

**Configuration:**
1. Admin: Réactiver la roulette
2. Horaires: 9h - 22h
3. Enregistrer

**Étapes:**
1. Utilisateur: Tester à 23h ou 8h (hors plage)

**Résultat attendu:**
- ✅ Bannière masquée
- ✅ Pas d'erreur

**Note:** Pour tester rapidement, modifier temporairement les horaires

**Résultat réel:** _____________

---

## 🎡 Tests Client - Roulette fonctionnelle

### Test 9: Premier tour de roue

**Configuration:**
- enabled = true
- Dans les horaires
- Segments actifs
- Utilisateur n'a jamais joué

**Étapes:**
1. Cliquer sur **"Jouer"** dans la bannière
2. Attendre l'affichage de la roue
3. La roue tourne automatiquement
4. Observer le résultat

**Résultat attendu:**
- ✅ Écran roulette s'ouvre
- ✅ Roue tourne avec animation
- ✅ Résultat s'affiche dans une dialog
- ✅ Message de félicitations (si gain) ou encouragement
- ✅ Pas d'erreur

**Résultat réel:** _____________

---

### Test 10: Vérification du ticket reward

**Après Test 9:**

**Étapes:**
1. Fermer la dialog de résultat
2. Aller dans **Profil** → **Mes tickets**

**Résultat attendu:**
- ✅ Un nouveau ticket apparaît
- ✅ Type correspond au segment gagné
- ✅ Statut = "Disponible" ou "Non utilisé"
- ✅ Date d'expiration affichée

**Résultat réel:** _____________

---

### Test 11: Cooldown respecté

**Configuration:**
- Cooldown = 1440 minutes (24h)
- L'utilisateur vient de jouer (Test 9)

**Étapes:**
1. Retourner sur la page d'accueil
2. Essayer de cliquer sur **"Jouer"** à nouveau

**Résultat attendu:**
- ✅ Bannière peut être masquée ou
- ✅ Bouton "Jouer" désactivé ou
- ✅ Message "Prochain tirage disponible dans X heures"

**Note:** Pour tester rapidement, mettre cooldown = 1 minute

**Résultat réel:** _____________

---

### Test 12: Limite journalière

**Configuration:**
- dailyLimit = 1
- L'utilisateur a joué 1 fois aujourd'hui

**Étapes:**
1. Le lendemain, revenir sur l'app
2. Vérifier que la bannière réapparaît

**Résultat attendu:**
- ✅ Nouveau spin disponible après minuit
- ✅ Compteur remis à zéro

**Note:** Pour tester rapidement, modifier dailyLimit = 2 et essayer 2 spins

**Résultat réel:** _____________

---

## 🔧 Tests Edge Cases

### Test 13: Segments tous inactifs

**Configuration:**
1. Admin: Désactiver tous les segments
2. Garder enabled = true

**Étapes:**
1. Utilisateur: Aller sur page d'accueil

**Résultat attendu:**
- ✅ Bannière masquée ou message "Roulette non disponible"
- ✅ Pas de crash

**Résultat réel:** _____________

---

### Test 14: Horaires qui traversent minuit

**Configuration:**
1. Admin: allowedStartHour = 22, allowedEndHour = 2
2. Enregistrer

**Étapes:**
1. Tester à 23h → Bannière visible
2. Tester à 1h → Bannière visible
3. Tester à 3h → Bannière masquée

**Résultat attendu:**
- ✅ Logic de plage horaire fonctionne même en traversant minuit

**Résultat réel:** _____________

---

### Test 15: Cooldown court

**Configuration:**
1. Admin: Cooldown = 1 minute
2. Enregistrer

**Étapes:**
1. Utilisateur: Jouer une fois
2. Attendre 1 minute
3. Essayer de rejouer

**Résultat attendu:**
- ✅ Après 1 minute, nouveau spin disponible
- ✅ Cooldown fonctionne correctement

**Résultat réel:** _____________

---

## 📊 Résumé des tests

| Test | Résultat | Notes |
|------|----------|-------|
| 1. Accès écran unifié | ☐ Pass ☐ Fail | |
| 2. Configuration de base | ☐ Pass ☐ Fail | |
| 3. Firestore correct | ☐ Pass ☐ Fail | |
| 4. Segments visibles | ☐ Pass ☐ Fail | |
| 5. Créer segment | ☐ Pass ☐ Fail | |
| 6. Bannière visible | ☐ Pass ☐ Fail | |
| 7. Bannière masquée (disabled) | ☐ Pass ☐ Fail | |
| 8. Bannière masquée (horaires) | ☐ Pass ☐ Fail | |
| 9. Premier tour | ☐ Pass ☐ Fail | |
| 10. Ticket créé | ☐ Pass ☐ Fail | |
| 11. Cooldown | ☐ Pass ☐ Fail | |
| 12. Limite journalière | ☐ Pass ☐ Fail | |
| 13. Segments inactifs | ☐ Pass ☐ Fail | |
| 14. Horaires minuit | ☐ Pass ☐ Fail | |
| 15. Cooldown court | ☐ Pass ☐ Fail | |

**Total Pass:** ___ / 15

---

## 🐛 Bugs identifiés

| # | Description | Sévérité | Statut |
|---|-------------|----------|--------|
| 1 | | ☐ Bloquant ☐ Majeur ☐ Mineur | |
| 2 | | ☐ Bloquant ☐ Majeur ☐ Mineur | |
| 3 | | ☐ Bloquant ☐ Majeur ☐ Mineur | |

---

## ✅ Validation finale

**La roulette est considérée comme fonctionnelle si:**

- [ ] Configuration admin sauvegarde correctement
- [ ] Bannière s'affiche quand toutes les conditions sont remplies
- [ ] Bannière se masque quand une condition n'est pas remplie
- [ ] La roue tourne et affiche un résultat
- [ ] Le ticket reward est créé
- [ ] Le cooldown est respecté
- [ ] Les limites sont respectées
- [ ] Aucun crash ni erreur bloquante

**Validation:** ☐ OUI ☐ NON

**Commentaires:**
_______________________________________________
_______________________________________________
_______________________________________________

---

## 📝 Notes complémentaires

- Tests effectués le: _____________
- Version de l'app: _____________
- Testeur: _____________
- Environnement: ☐ Dev ☐ Staging ☐ Production
