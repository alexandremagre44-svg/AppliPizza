# 📝 Guide - Création de compte administrateur

## ✅ Problème résolu

**Avant:** 
- L'écran de connexion affichait des identifiants de test qui ne fonctionnaient pas
- Impossible de créer un compte administrateur via l'interface
- Les utilisateurs devaient créer les comptes manuellement dans la console Firebase

**Maintenant:**
- Nouvel écran d'inscription accessible depuis l'écran de connexion
- Possibilité de créer des comptes administrateurs directement dans l'application
- Message clair sur l'écran de connexion pour guider les nouveaux utilisateurs

## 🚀 Comment créer un compte administrateur

### Pour le premier compte administrateur :

1. **Lancez l'application**
   - Vous arriverez sur l'écran de connexion

2. **Cliquez sur "Pas de compte ? Créer un compte"**
   - Cela vous amènera sur l'écran d'inscription

3. **Remplissez le formulaire :**
   - **Nom** (optionnel) : Votre nom d'affichage
   - **Email** : Votre adresse email (ex: admin@delizza.com)
   - **Mot de passe** : Minimum 6 caractères
   - **Confirmer le mot de passe** : Retapez le même mot de passe

4. **Cochez la case "Créer un compte administrateur"**
   - ⚠️ Cette option doit être utilisée uniquement pour créer le premier compte admin
   - Une fois créé, utilisez ce compte admin pour gérer les autres utilisateurs

5. **Cliquez sur "Créer le compte"**
   - Le compte sera créé dans Firebase Authentication
   - Un document utilisateur sera automatiquement créé dans Firestore avec le rôle `admin`

6. **Retournez à l'écran de connexion**
   - Vous pouvez maintenant vous connecter avec vos identifiants

### Pour les comptes clients :

1. Suivez les mêmes étapes que ci-dessus
2. **Ne cochez PAS** la case "Créer un compte administrateur"
3. Le compte sera créé avec le rôle `client` par défaut

## 🔐 Sécurité

### Rôles disponibles :
- **Client** : Peut passer des commandes et voir ses propres commandes
- **Admin** : Accès complet à toutes les fonctionnalités (gestion des produits, commandes, utilisateurs)
- **Cuisine** : Peut voir et gérer toutes les commandes (mode cuisine)

### Règles de sécurité Firestore :

Les règles de sécurité empêchent :
- Les utilisateurs de modifier leur propre rôle
- Les clients de voir les commandes des autres
- Les non-administrateurs de modifier les rôles des autres utilisateurs
- La modification des montants des commandes après création

## 📋 Création de comptes supplémentaires

### Méthode 1 : Via l'application
- Les nouveaux utilisateurs peuvent s'inscrire via l'écran d'inscription
- Par défaut, ils auront le rôle `client`
- Un administrateur peut ensuite modifier leur rôle si nécessaire

### Méthode 2 : Via Firebase Console
1. Allez dans **Authentication** > **Users**
2. Cliquez sur "Add user"
3. Entrez l'email et le mot de passe
4. Allez dans **Firestore Database** > **users**
5. Créez un document avec l'UID de l'utilisateur
6. Ajoutez les champs :
   ```json
   {
     "email": "user@example.com",
     "role": "admin",
     "displayName": "Nom de l'utilisateur",
     "createdAt": "timestamp",
     "updatedAt": "timestamp"
   }
   ```

## ⚠️ Bonnes pratiques

### Pour les administrateurs :

1. **Protégez vos identifiants**
   - Utilisez un mot de passe fort et unique
   - Ne partagez jamais vos identifiants admin

2. **Limitez le nombre d'administrateurs**
   - Ne créez des comptes admin que pour les personnes de confiance
   - Utilisez le rôle `kitchen` pour le personnel de cuisine

3. **Surveillez les accès**
   - Vérifiez régulièrement les logs Firebase
   - Désactivez les comptes inutilisés

4. **Ne cochez pas "Créer un compte administrateur" pour chaque compte**
   - Cette option est réservée à la création initiale ou exceptionnelle
   - Les comptes admin doivent être limités

## 🔄 Migration des anciens comptes de test

Les anciens identifiants de test (`admin@delizza.com` / `admin123` et `client@delizza.com` / `client123`) n'existent plus automatiquement.

**Pour continuer à les utiliser :**
1. Créez ces comptes via l'écran d'inscription
2. Utilisez les mêmes emails
3. Choisissez de nouveaux mots de passe (les anciens ne fonctionneront pas)
4. Cochez "Créer un compte administrateur" pour l'admin

## 🆘 Dépannage

### "Email déjà utilisé"
- Ce compte existe déjà dans Firebase
- Utilisez l'écran de connexion ou réinitialisez votre mot de passe

### "Mot de passe trop faible"
- Utilisez minimum 6 caractères
- Firebase recommande des mots de passe plus longs et complexes

### "Erreur de connexion"
- Vérifiez que Firebase est correctement configuré
- Consultez `FIREBASE_SETUP.md` pour la configuration

### Le compte admin n'a pas les bonnes permissions
- Vérifiez dans Firestore que le champ `role` est bien `admin`
- Déconnectez-vous et reconnectez-vous

## 📚 Documentation liée

- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Configuration Firebase complète
- [FIREBASE_MIGRATION_SUMMARY.md](FIREBASE_MIGRATION_SUMMARY.md) - Résumé de la migration
- [SECURITY_SUMMARY.md](SECURITY_SUMMARY.md) - Détails sur la sécurité

## ✨ Nouvelles fonctionnalités

### Écran d'inscription
- Interface intuitive et cohérente avec le design de l'application
- Validation des champs en temps réel
- Messages d'erreur clairs
- Option pour créer un compte administrateur

### Écran de connexion mis à jour
- Suppression des identifiants de test déroutants
- Ajout d'un lien vers l'inscription
- Message informatif pour les nouveaux utilisateurs

## 🎯 Prochaines étapes

Pour améliorer encore l'expérience :
1. ✅ Création de comptes via l'application (Fait)
2. 🔄 Réinitialisation de mot de passe (Disponible via Firebase)
3. 📧 Vérification par email (Peut être activée dans Firebase)
4. 🔐 Authentification à deux facteurs (Future amélioration)

---

**Note :** Cette solution permet de créer facilement des comptes administrateurs tout en maintenant la sécurité via les règles Firestore. Le premier administrateur peut ensuite gérer les autres utilisateurs selon les besoins de l'entreprise.
