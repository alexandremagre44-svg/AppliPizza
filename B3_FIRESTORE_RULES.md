# B3 Firestore Rules - Configuration Temporaire

## ⚠️ Important

Ce fichier contient les **règles Firestore temporaires** nécessaires pour permettre l'initialisation automatique des pages B3 (home-b3, menu-b3, categories-b3, cart-b3).

**Ces règles NE sont PAS appliquées automatiquement** - vous devez les configurer manuellement dans la Firebase Console.

## Contexte

L'application Pizza Deli'Zza utilise Firestore pour stocker la configuration des pages dynamiques B3. Au premier lancement, l'application tente de créer automatiquement les pages B3 obligatoires.

Si vous voyez le message suivant dans les logs :

```
╔═══════════════════════════════════════════════════════════════╗
║  ⚠️  FIRESTORE PERMISSION DENIED                              ║
╠═══════════════════════════════════════════════════════════════╣
║  Les règles Firestore actuelles bloquent l'écriture.         ║
║  ...                                                          ║
╚═══════════════════════════════════════════════════════════════╝
```

Cela signifie que les règles Firestore doivent être mises à jour.

## Règles Temporaires à Appliquer

### Option 1: Règles Ouvertes pour le Développement (⚠️ Temporaire uniquement)

Ces règles permettent à tous les utilisateurs authentifiés de lire et écrire dans Firestore :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ IMPORTANT** : Ces règles sont **très permissives** et ne doivent être utilisées que :
- En phase de développement
- Temporairement pour l'initialisation
- Sur un projet de test/développement uniquement

### Option 2: Règles Ciblées pour B3 (Plus sécurisé)

Ces règles permettent l'accès uniquement aux collections nécessaires pour B3 :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Collection B3 test (pour vérification des permissions)
    match /_b3_test/{document} {
      allow read, write: if request.auth != null;
    }
    
    // Collections B3 AppConfig (pages dynamiques)
    match /app_configs/{appId}/configs/{configDoc} {
      allow read: if true;  // Lecture publique
      allow write: if request.auth != null;  // Écriture authentifiée
    }
    
    // Autres collections selon vos besoins
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // ... autres règles pour vos collections spécifiques
  }
}
```

## Comment Appliquer les Règles

### Étape 1 : Accéder à la Firebase Console

1. Ouvrez [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet Pizza Deli'Zza
3. Dans le menu de gauche, cliquez sur **Firestore Database**
4. Allez dans l'onglet **Règles**

### Étape 2 : Modifier les Règles

1. Supprimez les règles existantes dans l'éditeur
2. Copiez-collez l'une des options ci-dessus (Option 1 ou Option 2)
3. Cliquez sur **Publier**

### Étape 3 : Vérifier

1. Attendez quelques secondes que les règles se propagent
2. Relancez votre application
3. Vérifiez les logs - vous devriez voir :
   ```
   ✅ B3 Init: Pages auto-créées avec succès
   ```

## Règles de Production

Une fois l'initialisation B3 terminée, vous devriez mettre en place des règles plus strictes pour la production.

### Exemple de Règles de Production

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Collection B3 test - Admin uniquement en production
    match /_b3_test/{document} {
      allow read, write: if isAdmin();
    }
    
    // Collections B3 AppConfig
    match /app_configs/{appId}/configs/{configDoc} {
      allow read: if true;  // Lecture publique pour affichage
      allow write: if isAdmin();  // Écriture réservée aux admins
    }
    
    // Profils utilisateurs
    match /users/{userId} {
      allow read: if isAuthenticated() && request.auth.uid == userId;
      allow write: if isAuthenticated() && request.auth.uid == userId;
      allow read, write: if isAdmin();  // Admin peut tout gérer
    }
    
    // Produits
    match /products/{productId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // Catégories
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // Commandes
    match /orders/{orderId} {
      allow read: if isAuthenticated() && 
                     (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if isAuthenticated();
      allow update: if isAdmin();
    }
    
    // ... autres règles selon vos besoins
  }
}
```

## Dépannage

### Erreur : "Permission denied" persiste

1. Vérifiez que les règles ont bien été publiées dans Firebase Console
2. Attendez 1-2 minutes pour la propagation
3. Assurez-vous qu'un utilisateur est connecté (vérifiez l'authentification)
4. Vérifiez que l'utilisateur a le rôle approprié si vous utilisez des règles basées sur les rôles

### L'initialisation ne se lance jamais

Si `autoInitializeB3IfNeeded()` ne se lance jamais :

1. Vérifiez les logs de la console
2. Supprimez les données de l'application (pour réinitialiser le flag)
3. Ou supprimez manuellement la clé `b3_auto_initialized` dans SharedPreferences

### Forcer une nouvelle initialisation

Pour forcer une nouvelle initialisation B3 :

```dart
// Dans votre code de debug/développement
final prefs = await SharedPreferences.getInstance();
await prefs.remove('b3_auto_initialized');
// Relancez l'application
```

## Sécurité

⚠️ **Règles importantes de sécurité** :

1. **Ne jamais** utiliser `allow read, write: if true;` en production (accès public total)
2. **Toujours** valider l'authentification avec `request.auth != null`
3. **Utiliser** des règles basées sur les rôles pour les opérations admin
4. **Limiter** l'accès en écriture aux utilisateurs appropriés
5. **Tester** vos règles avant de les déployer en production

## Support

Pour plus d'informations sur les règles Firestore :
- [Documentation Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Guide des bonnes pratiques](https://firebase.google.com/docs/firestore/security/rules-conditions)

---

**Dernière mise à jour** : 2025-11-23  
**Version** : 1.0
