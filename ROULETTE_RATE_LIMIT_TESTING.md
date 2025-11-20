# Checklist de Test - Configuration de la Limite de Rate Limit de la Roulette

## Pré-requis

- [ ] Le code Flutter est déployé
- [ ] Les règles Firestore sont déployées : `firebase deploy --only firestore:rules`
- [ ] Un compte admin est disponible pour accéder à l'interface

## Test 1 : Vérifier l'interface admin

### Étapes
1. [ ] Se connecter en tant qu'admin
2. [ ] Naviguer vers **Studio → Paramètres & Règles de la Roulette**
3. [ ] Vérifier que la section **"Limite de Rate Limit (Sécurité)"** est visible
4. [ ] Vérifier que le champ affiche une valeur (par défaut: 10 secondes)
5. [ ] Vérifier la présence du message informatif sur la sécurité serveur

### Résultat attendu
- ✅ Section visible avec icône de sécurité 🔒
- ✅ Champ pré-rempli avec la valeur actuelle
- ✅ Message d'information présent et clair

---

## Test 2 : Modifier la configuration (valeur valide)

### Étapes
1. [ ] Entrer une nouvelle valeur valide (ex: 3 secondes)
2. [ ] Cliquer sur **"Enregistrer la configuration"**
3. [ ] Attendre le message de confirmation

### Résultat attendu
- ✅ Message "Configuration sauvegardée avec succès" (vert)
- ✅ Pas d'erreur dans la console
- ✅ Le champ conserve la nouvelle valeur

### Vérification Firestore
1. [ ] Ouvrir la console Firestore
2. [ ] Naviguer vers `/config/roulette_settings`
3. [ ] Vérifier que `limitSeconds = 3`
4. [ ] Vérifier que `updatedAt` est un timestamp récent

---

## Test 3 : Tester les validations

### Test 3.1 : Valeur trop basse
1. [ ] Entrer `0` dans le champ
2. [ ] Cliquer sur "Enregistrer"
3. [ ] **Attendu** : Message d'erreur "Valeur invalide (1-3600)"

### Test 3.2 : Valeur trop haute
1. [ ] Entrer `3601` dans le champ
2. [ ] Cliquer sur "Enregistrer"
3. [ ] **Attendu** : Message d'erreur "Valeur invalide (1-3600)"

### Test 3.3 : Valeur vide
1. [ ] Vider le champ
2. [ ] Cliquer sur "Enregistrer"
3. [ ] **Attendu** : Message d'erreur "Requis"

### Test 3.4 : Valeur non-numérique
1. [ ] Entrer du texte (ex: "abc")
2. [ ] **Attendu** : Le champ ne permet que les chiffres (FilteringTextInputFormatter)

---

## Test 4 : Enforcement côté Firestore (rate limit = 3 secondes)

### Configuration
1. [ ] Configurer la limite à **3 secondes**
2. [ ] Enregistrer et vérifier le succès

### Test du rate limit
1. [ ] Se connecter avec un compte utilisateur (non-admin)
2. [ ] Naviguer vers la roulette
3. [ ] **Premier tour** : Faire tourner la roulette
   - [ ] **Attendu** : ✅ Succès, gain enregistré
4. [ ] **Immédiatement** : Essayer de refaire tourner (< 3 sec)
   - [ ] **Attendu** : ❌ Erreur Firestore (permission denied)
   - [ ] Message d'erreur côté client
5. [ ] **Attendre 3 secondes**
6. [ ] **Après 3 secondes** : Refaire tourner
   - [ ] **Attendu** : ✅ Succès, nouveau gain

### Vérification des logs
- [ ] Vérifier que l'erreur vient de Firestore (pas du client)
- [ ] Vérifier que le document `roulette_rate_limit/{userId}` est mis à jour

---

## Test 5 : Changement dynamique de la limite

### Étapes
1. [ ] Configurer la limite à **5 secondes**
2. [ ] Enregistrer
3. [ ] Faire tourner la roulette en tant qu'utilisateur
4. [ ] **Immédiatement** : Revenir à l'admin et changer à **20 secondes**
5. [ ] Enregistrer
6. [ ] Essayer de faire tourner à nouveau (après 6 secondes mais < 20)
   - [ ] **Attendu** : ❌ Erreur (nouvelle limite de 20 sec appliquée)
7. [ ] Attendre 20 secondes depuis le dernier tour
8. [ ] Refaire tourner
   - [ ] **Attendu** : ✅ Succès

### Résultat attendu
- ✅ La nouvelle limite est appliquée immédiatement
- ✅ Pas besoin de redémarrer l'application

---

## Test 6 : Fallback par défaut

### Pré-requis
- [ ] Supprimer manuellement le document `config/roulette_settings` dans Firestore

### Test
1. [ ] Essayer de faire tourner la roulette
2. [ ] **Attendu** : Fallback à 10 secondes (valeur par défaut)
3. [ ] Vérifier dans l'admin que le champ affiche "10"

### Recréer la configuration
1. [ ] Dans l'admin, modifier la valeur à 15 secondes
2. [ ] Enregistrer
3. [ ] **Attendu** : Le document est recréé dans Firestore
4. [ ] Vérifier que la nouvelle limite de 15 secondes fonctionne

---

## Test 7 : Isolation des utilisateurs

### Configuration
1. [ ] Configurer la limite à **10 secondes**

### Test multi-utilisateurs
1. [ ] **Utilisateur A** : Faire tourner la roulette
2. [ ] **Immédiatement** : **Utilisateur B** : Faire tourner la roulette
   - [ ] **Attendu** : ✅ Succès (utilisateurs différents = rate limits indépendants)
3. [ ] **Utilisateur A** : Essayer de refaire tourner (< 10 sec)
   - [ ] **Attendu** : ❌ Erreur (rate limit personnel)
4. [ ] **Utilisateur B** : Essayer de refaire tourner (< 10 sec)
   - [ ] **Attendu** : ❌ Erreur (rate limit personnel)

### Résultat attendu
- ✅ Chaque utilisateur a son propre compteur de rate limit
- ✅ Les utilisateurs ne s'influencent pas mutuellement

---

## Test 8 : Permissions admin

### Test en tant que non-admin
1. [ ] Se connecter avec un compte utilisateur standard
2. [ ] Essayer d'accéder à `/config/roulette_settings` via la console ou l'API
3. [ ] Essayer de modifier le document
   - [ ] **Attendu** : ❌ Permission denied (seuls les admins peuvent écrire)

### Test en tant qu'admin
1. [ ] Se connecter en tant qu'admin
2. [ ] Modifier la configuration depuis l'interface
3. [ ] **Attendu** : ✅ Succès

---

## Test 9 : Performance (optionnel)

### Objectif
Vérifier que les lectures de configuration dans les règles Firestore n'impactent pas les performances.

### Test de charge
1. [ ] Configurer la limite à 5 secondes
2. [ ] Avec plusieurs utilisateurs, faire tourner la roulette en séquence
3. [ ] **Attendu** : Pas de latence notable

### Vérification
- [ ] Consulter la console Firestore pour les opérations de lecture
- [ ] Vérifier que chaque spin lit bien `config/roulette_settings`
- [ ] S'assurer que le coût de lecture est acceptable

**Note** : Pour de très hauts volumes (> 1000 spins/seconde), considérer un cache ou une valeur fixe.

---

## Résumé des résultats

| Test | Statut | Notes |
|------|--------|-------|
| Interface admin | ⬜ | |
| Modification valide | ⬜ | |
| Validations | ⬜ | |
| Enforcement Firestore | ⬜ | |
| Changement dynamique | ⬜ | |
| Fallback défaut | ⬜ | |
| Isolation utilisateurs | ⬜ | |
| Permissions | ⬜ | |
| Performance | ⬜ | |

**Légende** : ⬜ Non testé | ✅ Réussi | ❌ Échoué | ⚠️ À améliorer

---

## Dépannage

### Problème : La limite n'est pas appliquée
- **Cause possible** : Règles Firestore non déployées
- **Solution** : `firebase deploy --only firestore:rules`

### Problème : Erreur "Permission denied" en lecture
- **Cause possible** : Configuration `/config` non lisible
- **Solution** : Vérifier les règles Firestore (lecture doit être publique pour `/config`)

### Problème : Changement non pris en compte
- **Cause possible** : Cache côté client
- **Solution** : Redémarrer l'application ou vider le cache Firestore

### Problème : Document n'existe pas
- **Cause possible** : Première utilisation
- **Solution** : Le fallback à 10 secondes s'applique automatiquement. Modifier la valeur dans l'admin pour créer le document.

---

## Notes finales

- La configuration est stockée dans `/config/roulette_settings`
- Le rate limit est différent du cooldown (heures) défini dans `roulette_rules`
- La sécurité est garantie côté serveur, impossible de contourner
- Les modifications prennent effet immédiatement (pas de cache)
