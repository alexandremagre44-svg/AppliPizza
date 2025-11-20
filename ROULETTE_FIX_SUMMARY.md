# Fix: Firestore Permission Denied for Roulette Spins

## Problème Identifié

L'erreur `[cloud_firestore/permission-denied] Missing or insufficient permissions` se produisait lors de la création d'un document dans `user_roulette_spins`.

### Cause Racine

Le problème était dans l'ordre des opérations dans la fonction `recordSpin()` du fichier `lib/src/services/roulette_service.dart`.

**Ancien flux (CASSÉ):**
1. ❌ Mise à jour de `roulette_rate_limit/{userId}` avec le timestamp ACTUEL
2. ❌ Tentative de création du document `user_roulette_spins`
3. ❌ La règle Firestore vérifie `timeSinceLastAction()` et lit le timestamp JUSTE MIS À JOUR
4. ❌ La règle calcule: `request.time - MAINTENANT < limite` → FALSE → PERMISSION REFUSÉE

**Nouveau flux (CORRIGÉ):**
1. ✅ Création du document `user_roulette_spins` EN PREMIER
2. ✅ La règle Firestore vérifie `timeSinceLastAction()` et lit l'ANCIEN timestamp
3. ✅ Si suffisamment de temps s'est écoulé: spin créé avec succès
4. ✅ PUIS mise à jour de `roulette_rate_limit/{userId}` avec le timestamp actuel (pour le prochain spin)

## Corrections Apportées

### 1. Code Flutter (`lib/src/services/roulette_service.dart`)

**Changement principal:** Inversion de l'ordre des opérations dans `recordSpin()`

```dart
// AVANT (ligne 30-43)
await rateLimitDoc.set({'lastActionAt': FieldValue.serverTimestamp()});  // ❌ Mise à jour AVANT
await _firestore.collection('user_roulette_spins').add({...});           // ❌ Création APRÈS

// APRÈS (ligne 30-47)
await _firestore.collection('user_roulette_spins').add({...});           // ✅ Création D'ABORD
await rateLimitDoc.set({'lastActionAt': FieldValue.serverTimestamp()});  // ✅ Mise à jour APRÈS
```

**Commentaires ajoutés:**
- Explication claire de pourquoi l'ordre est critique
- Documentation du fonctionnement du rate limit

### 2. Règles Firestore (`firebase/firestore.rules`)

**Amélioration:** Commentaires détaillés ajoutés (lignes 229-234)

```javascript
// Roulette dynamic rate-limit enforced from admin settings
// Users can record their own spins with dynamic rate limiting.
// The limit is configured by admins in /config/roulette_settings (fallback: 10 seconds)
// This check reads the CURRENT roulette_rate_limit timestamp (from the previous spin)
// and validates enough time has passed before allowing the new spin.
// After the spin is created, the client updates roulette_rate_limit for the next check.
```

**Aucune modification de la logique des règles:** Les règles étaient déjà correctes, seul l'ordre dans le code client était problématique.

## Vérifications Effectuées

✅ **Règle unique:** Une seule règle `match /user_roulette_spins/{spinId}` - aucun conflit
✅ **Fonction dynamique:** `getRouletteLimit()` lit correctement depuis `/config/roulette_settings`
✅ **Accès config:** Collection `/config` permet la lecture publique (ligne 283)
✅ **Pas de rate limit codé en dur:** Utilise `getRouletteLimit()` dynamique
✅ **Permissions rate_limit:** Collection `roulette_rate_limit` permet l'écriture utilisateur (ligne 243)
✅ **Validations en place:** Vérification auth, userId, champs requis

## Comportement Attendu Après Correction

| Scénario | Résultat Attendu |
|----------|------------------|
| 1er spin (pas de rate_limit existant) | ✅ Succès |
| 2ème spin immédiat (< limite) | ❌ Rejet Firestore |
| Spin après attente (≥ limite) | ✅ Succès |
| Admin change la limite | ✅ Application immédiate |
| Document créé avec bons champs | ✅ userId, segmentId, spunAt |

## Tests Recommandés

### Test 1: Premier Spin
```
1. Utilisateur authentifié lance la roulette
2. ATTENDU: ✅ Succès, document créé dans user_roulette_spins
3. ATTENDU: ✅ Document rate_limit créé avec lastActionAt
```

### Test 2: Rate Limit Enforcement
```
1. Configuration admin: limite = 10 secondes
2. Premier spin → ✅ Succès
3. Immédiatement après (< 10 sec) → ❌ Permission denied
4. Console log: "Error recording spin: [cloud_firestore/permission-denied]"
5. Attendre 10+ secondes
6. Nouveau spin → ✅ Succès
```

### Test 3: Changement Dynamique
```
1. Admin change limite à 30 secondes
2. Faire un spin → ✅ Succès
3. Essayer après 15 secondes → ❌ Rejet (nouvelle limite de 30s appliquée)
4. Essayer après 30+ secondes → ✅ Succès
```

### Test 4: Fallback Par Défaut
```
1. Supprimer config/roulette_settings dans Firestore console
2. Faire un spin → ✅ Succès (fallback à 10 secondes)
3. Spin immédiat → ❌ Rejet après 10 secondes par défaut
```

## Déploiement

### Étapes Nécessaires

1. **Déployer le code Flutter:**
   ```bash
   flutter build [platform]
   # Déployer l'application
   ```

2. **Déployer les règles Firestore:**
   ```bash
   firebase deploy --only firestore:rules
   ```

3. **Vérifier la configuration:**
   - S'assurer que `/config/roulette_settings` existe dans Firestore
   - Champ `limitSeconds` défini (ex: 10, 30, 60)
   - Si absent, le fallback de 10 secondes s'applique

### Ordre Recommandé
1. Déployer d'abord les règles Firestore (pas de breaking change)
2. Puis déployer l'application Flutter avec le fix

## Structure des Données

### Document `/config/roulette_settings`
```json
{
  "limitSeconds": 10,
  "updatedAt": "2024-01-01T12:00:00Z"
}
```

### Document `/roulette_rate_limit/{userId}`
```json
{
  "lastActionAt": Timestamp
}
```

### Document `/user_roulette_spins/{spinId}`
```json
{
  "userId": "user123",
  "segmentId": "segment456",
  "segmentType": "points",
  "segmentLabel": "10 points",
  "value": 10,
  "spunAt": "2024-01-01T12:00:00.000Z"
}
```

## Points de Sécurité Maintenus

✅ **Rate limit côté serveur:** Impossible de contourner via le client
✅ **Validation userId:** Le spin ne peut être créé que par l'utilisateur authentifié
✅ **Champs requis:** userId, segmentId, spunAt obligatoires
✅ **Lecture config sécurisée:** Admin seul peut modifier, tout le monde peut lire
✅ **Pas de mise à jour/suppression:** Spins immuables une fois créés

## Limitations Connues

⚠️ **Opération de lecture:** Chaque spin lit `/config/roulette_settings` (1 lecture Firestore)
- Pour de très hauts volumes (>1000 spins/seconde), considérer un cache
- Pour l'usage normal, l'impact est négligeable

## Fichiers Modifiés

1. ✏️ **lib/src/services/roulette_service.dart** - Inversion ordre opérations + commentaires
2. ✏️ **firebase/firestore.rules** - Ajout commentaires explicatifs
3. 📝 **ROULETTE_FIX_SUMMARY.md** - Ce document (nouveau)

## Aucune Modification de

❌ Collections existantes
❌ Noms ou chemins de documents
❌ Autres règles Firestore (commandes, produits, users)
❌ Logique métier de la roulette
❌ Interface utilisateur

## Résumé

**Problème:** Permission denied lors de la création d'un spin
**Cause:** Mise à jour du rate limit AVANT la création du spin
**Solution:** Inverser l'ordre: créer le spin D'ABORD, puis mettre à jour le rate limit
**Impact:** Minimal - 2 fichiers modifiés, aucune breaking change
**Tests:** À effectuer après déploiement pour validation complète

---

**Date de correction:** 2025-11-20
**Auteur:** GitHub Copilot Agent
**Statut:** ✅ CORRIGÉ - En attente de déploiement et tests
