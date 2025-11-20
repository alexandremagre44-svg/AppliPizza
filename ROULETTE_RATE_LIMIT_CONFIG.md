# Configuration de la Limite de Rate Limit de la Roulette

## Vue d'ensemble

Ce système permet de configurer dynamiquement la limite de cooldown de la roulette depuis l'interface d'administration, tout en maintenant la sécurité côté serveur (Firestore).

## Architecture

### 1. Stockage de la Configuration
- **Collection**: `/config`
- **Document**: `roulette_settings`
- **Champ**: `limitSeconds` (nombre de secondes entre deux tours)

```json
{
  "limitSeconds": 10,
  "updatedAt": "2024-01-01T12:00:00Z"
}
```

### 2. Sécurité Firestore

Les règles Firestore lisent cette configuration pour appliquer le rate limit côté serveur :

```javascript
function getRouletteLimit() {
  return exists(/databases/$(database)/documents/config/roulette_settings)
    ? get(/databases/$(database)/documents/config/roulette_settings).data.limitSeconds
    : 10; // fallback par défaut
}
```

Cette approche garantit que :
- ✅ La limite ne peut pas être contournée côté client
- ✅ Les modifications prennent effet immédiatement
- ✅ Un fallback existe si la configuration n'est pas définie

### 3. Service Flutter

Le service `RouletteSettingsService` gère la configuration :

```dart
// Lire la limite actuelle
int limit = await settingsService.getLimitSeconds();

// Mettre à jour la limite (1-3600 secondes)
await settingsService.updateLimitSeconds(30);
```

### 4. Interface Admin

L'écran `RouletteAdminSettingsScreen` affiche une section dédiée :
- **Validation**: 1 à 3600 secondes (1 heure max)
- **Feedback**: Message de succès/erreur après mise à jour
- **Info**: Explication que la limite est appliquée côté serveur

## Utilisation

### Pour l'administrateur

1. Aller dans **Studio → Paramètres & Règles de la Roulette**
2. Trouver la section **"Limite de Rate Limit (Sécurité)"**
3. Entrer la nouvelle valeur en secondes (ex: 10, 30, 60)
4. Cliquer sur **"Enregistrer la configuration"**
5. La nouvelle limite est appliquée immédiatement

### Valeurs recommandées

- **10 secondes** : Rate limit strict (anti-spam)
- **30 secondes** : Rate limit modéré
- **60 secondes** : Rate limit souple
- **300 secondes (5 min)** : Rate limit très souple

## Tests

### Test 1 : Créer la configuration
```dart
final service = RouletteSettingsService();
await service.updateLimitSeconds(3);
```

### Test 2 : Vérifier l'enforcement Firestore
1. Configurer la limite à 3 secondes
2. Faire tourner la roulette → ✅ Succès
3. Essayer immédiatement → ❌ Erreur Firestore
4. Attendre 3 secondes → ✅ Succès

### Test 3 : Modifier la limite
1. Configurer à 20 secondes
2. Faire tourner la roulette → ✅ Succès
3. Essayer après 5 secondes → ❌ Erreur
4. Essayer après 20 secondes → ✅ Succès

## Différence avec le Cooldown

⚠️ **Important** : Cette limite de rate limit (secondes) est différente du cooldown (heures/minutes) :

| Paramètre | Rate Limit (Sécurité) | Cooldown (Règles métier) |
|-----------|----------------------|--------------------------|
| **Unité** | Secondes | Heures/Minutes |
| **Application** | Firestore (serveur) | Application (client + serveur) |
| **Usage** | Anti-spam technique | Règles business |
| **Valeurs typiques** | 3-30 secondes | 24 heures |
| **Contournable** | ❌ Non (serveur) | ⚠️ Potentiellement (client) |

## Migration

### Première utilisation

Si le document `config/roulette_settings` n'existe pas :
- Le fallback par défaut est **10 secondes**
- L'admin peut créer la configuration en modifiant la valeur

### Déploiement

1. Déployer le code Flutter
2. Déployer les règles Firestore : `firebase deploy --only firestore:rules`
3. Créer la configuration initiale depuis l'admin

## Dépannage

### La limite n'est pas appliquée
- Vérifier que les règles Firestore sont déployées
- Vérifier que le document existe dans Firestore
- Vérifier les logs côté client pour les erreurs Firestore

### Erreur "limitSeconds must be between 1 and 3600"
- La valeur doit être entre 1 seconde et 3600 secondes (1 heure)
- Utiliser une valeur dans cette plage

### Le document n'existe pas
- Le fallback à 10 secondes s'applique automatiquement
- Créer la configuration depuis l'admin pour personnaliser

## Sécurité

✅ **Points de sécurité** :
- La configuration est stockée dans `/config` (lecture publique, écriture admin uniquement)
- Les règles Firestore lisent directement cette valeur (pas de manipulation possible)
- Le service client ne peut que lire la valeur (pas de contournement)
- Les erreurs Firestore sont propagées correctement

⚠️ **Limitations** :
- La lecture de la config dans les règles Firestore compte comme une opération de lecture
- Pour de très hauts volumes, considérer un cache ou une valeur fixe

## Fichiers modifiés

1. **Nouveau** : `lib/src/services/roulette_settings_service.dart`
2. **Modifié** : `firebase/firestore.rules`
3. **Modifié** : `lib/src/screens/admin/studio/roulette_admin_settings_screen.dart`
4. **Modifié** : `lib/src/services/roulette_service.dart`
