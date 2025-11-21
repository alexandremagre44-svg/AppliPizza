# Checklist de Déploiement - Module HomeContentManager

## 🎯 Objectif
Déployer le module de gestion du contenu d'accueil sans régression sur l'existant.

## ✅ Pré-requis

- [ ] Flutter SDK installé et fonctionnel
- [ ] Accès Firebase au projet
- [ ] Compte admin configuré dans Firestore
- [ ] Firebase CLI installé (`npm install -g firebase-tools`)
- [ ] Firebase CLI authentifié (`firebase login`)

## 📋 Étapes de Déploiement

### 1️⃣ Déployer les Règles Firestore

```bash
# Depuis le répertoire racine du projet
firebase deploy --only firestore:rules
```

**Vérification** :
- Aucune erreur dans la console
- Les règles sont actives dans la console Firebase

### 2️⃣ Initialiser les Collections (Optionnel)

Les collections seront créées automatiquement lors de la première utilisation, mais vous pouvez les pré-créer :

#### Configuration des produits mis en avant
```bash
# Aller dans Firebase Console > Firestore
# Collection: config
# Document: home_featured_products
# Créer avec :
{
  "id": "home_featured_products",
  "isActive": true,
  "productIds": [],
  "displayType": "carousel",
  "position": "before",
  "autoFill": true,
  "updatedAt": "2025-11-21T00:00:00.000Z"
}
```

#### Overrides des catégories
```bash
# Collection: home_category_overrides
# Créer 4 documents (Pizza, Menus, Boissons, Desserts) :

# Document: Pizza
{
  "categoryId": "Pizza",
  "isVisibleOnHome": true,
  "order": 0,
  "updatedAt": "2025-11-21T00:00:00.000Z"
}

# Document: Menus
{
  "categoryId": "Menus",
  "isVisibleOnHome": true,
  "order": 1,
  "updatedAt": "2025-11-21T00:00:00.000Z"
}

# Document: Boissons
{
  "categoryId": "Boissons",
  "isVisibleOnHome": true,
  "order": 2,
  "updatedAt": "2025-11-21T00:00:00.000Z"
}

# Document: Desserts
{
  "categoryId": "Desserts",
  "isVisibleOnHome": true,
  "order": 3,
  "updatedAt": "2025-11-21T00:00:00.000Z"
}
```

**Note** : Si vous ne créez pas ces documents, ils seront générés automatiquement lors du premier accès au module dans Studio V2.

### 3️⃣ Builder et Déployer l'Application

```bash
# Web
flutter build web --release

# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### 4️⃣ Tests Fonctionnels

#### Test 1 : Accès au Module
- [ ] Se connecter en tant qu'admin
- [ ] Aller dans Studio V2
- [ ] Vérifier que "Contenu d'accueil" apparaît dans le menu
- [ ] Cliquer dessus et vérifier les 4 onglets

#### Test 2 : Layout Général
- [ ] Ouvrir l'onglet "Layout général"
- [ ] Glisser-déposer une section
- [ ] Cliquer sur "Sauvegarder le layout"
- [ ] Vérifier la confirmation

#### Test 3 : Gestion des Catégories
- [ ] Ouvrir l'onglet "Catégories"
- [ ] Désactiver une catégorie (ex: Desserts)
- [ ] Cliquer sur "Sauvegarder les catégories"
- [ ] Aller sur la page d'accueil
- [ ] Vérifier que la catégorie est masquée

#### Test 4 : Produits Mis en Avant
- [ ] Ouvrir l'onglet "Produits mis en avant"
- [ ] Activer la section
- [ ] Cliquer sur "Ajouter"
- [ ] Sélectionner 3 produits
- [ ] Confirmer
- [ ] Cliquer sur "Sauvegarder la configuration"
- [ ] Aller sur la page d'accueil
- [ ] Vérifier que les produits s'affichent

#### Test 5 : Sections Personnalisées
- [ ] Ouvrir l'onglet "Sections personnalisées"
- [ ] Cliquer sur "Nouvelle section"
- [ ] Remplir :
  - Titre: "Test Section"
  - Type: Carrousel
  - Mode: Automatique
  - Tri: Meilleures ventes
- [ ] Confirmer
- [ ] Aller sur la page d'accueil
- [ ] Vérifier que la section s'affiche

#### Test 6 : Non-Régression
- [ ] Vérifier que le Hero fonctionne toujours
- [ ] Vérifier que les Bannières fonctionnent
- [ ] Vérifier que les Popups fonctionnent
- [ ] Vérifier que le menu principal fonctionne
- [ ] Vérifier que les commandes fonctionnent
- [ ] Vérifier que la caisse fonctionne
- [ ] Vérifier que la roulette fonctionne

### 5️⃣ Tests de Fallback

#### Test 1 : Collections vides
- [ ] Vider les collections `home_custom_sections`
- [ ] Recharger la page d'accueil
- [ ] Vérifier que l'application fonctionne normalement

#### Test 2 : Configuration manquante
- [ ] Supprimer `config/home_featured_products`
- [ ] Recharger la page d'accueil
- [ ] Vérifier que l'application fonctionne normalement

#### Test 3 : Produit manquant
- [ ] Créer une section avec un ID de produit invalide
- [ ] Recharger la page d'accueil
- [ ] Vérifier que la section s'affiche sans erreur (produit ignoré)

### 6️⃣ Performance

- [ ] Vérifier le temps de chargement de la page d'accueil
- [ ] Vérifier qu'il n'y a pas de requêtes Firestore excessives
- [ ] Vérifier que le scroll est fluide
- [ ] Vérifier le temps de réponse du drag & drop

### 7️⃣ Sécurité

- [ ] Se déconnecter
- [ ] Essayer d'accéder au Studio V2
- [ ] Vérifier que l'accès est refusé
- [ ] Vérifier que la page d'accueil fonctionne pour les utilisateurs non connectés

## 🐛 Problèmes Connus et Solutions

### Problème 1 : "Permission denied" lors de la sauvegarde
**Solution** : Vérifier que les règles Firestore sont déployées et que l'utilisateur est admin

### Problème 2 : Les sections ne s'affichent pas
**Solution** : Vérifier que les sections sont actives et contiennent des produits valides

### Problème 3 : Erreur de build Flutter
**Solution** : Exécuter `flutter clean` puis `flutter pub get`

### Problème 4 : Layout général vide
**Solution** : Les sections seront créées automatiquement. Attendre quelques secondes et rafraîchir.

## 📊 Monitoring Post-Déploiement

### Jour 1
- [ ] Vérifier les logs d'erreurs Firebase
- [ ] Vérifier l'utilisation des collections Firestore
- [ ] Vérifier les retours utilisateurs

### Semaine 1
- [ ] Analyser les performances
- [ ] Vérifier les patterns d'utilisation
- [ ] Collecter les retours admin

### Mois 1
- [ ] Évaluer l'adoption du module
- [ ] Identifier les améliorations possibles
- [ ] Planifier les nouvelles fonctionnalités

## 🔄 Rollback (Si nécessaire)

Si un problème critique survient :

### Option 1 : Désactiver les nouvelles sections
```bash
# Dans Firestore Console
# Collection: config
# Document: home_featured_products
# Modifier: isActive = false

# Pour chaque section personnalisée
# Collection: home_custom_sections
# Pour chaque document: isActive = false
```

### Option 2 : Retour version précédente
```bash
# Checkout de la version précédente
git checkout <commit-avant-module>

# Rebuilder et redéployer
flutter build web --release
```

### Option 3 : Restaurer les règles Firestore
```bash
# Restaurer le fichier firestore.rules depuis Git
git checkout HEAD~1 -- firebase/firestore.rules

# Redéployer
firebase deploy --only firestore:rules
```

## 📞 Contact Support

En cas de problème :
1. Vérifier ce document
2. Consulter `HOME_CONTENT_MANAGER_README.md`
3. Vérifier les logs Firebase Console
4. Vérifier les logs dans la console du navigateur

## ✅ Validation Finale

Avant de considérer le déploiement comme réussi :

- [ ] Tous les tests fonctionnels passent
- [ ] Tous les tests de fallback passent
- [ ] Aucune régression détectée
- [ ] Performance acceptable
- [ ] Sécurité validée
- [ ] Documentation à jour
- [ ] Équipe informée

---

**Date de déploiement** : ________________  
**Déployé par** : ________________  
**Version** : 1.0  
**Statut** : [ ] Réussi / [ ] Échec / [ ] Rollback
