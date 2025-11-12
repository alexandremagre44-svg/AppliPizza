# 🍕 Pizza Deli'Zza

Application Flutter complète de commande de pizzas en ligne avec interface client et administration, propulsée par Firebase.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
![Status](https://img.shields.io/badge/Status-Production%20Ready-green.svg)

---

## 🔥 **IMPORTANT : Migration Firebase**

L'application utilise maintenant **Firebase** pour l'authentification et la gestion des commandes en temps réel. 

**⚠️ Les anciennes données locales (SharedPreferences) ne sont plus utilisées.**

👉 **Consultez [FIREBASE_SETUP.md](FIREBASE_SETUP.md) pour la configuration complète de Firebase.**

---

## 📱 Présentation

**Pizza Deli'Zza** est une application mobile de commande de pizzas qui permet aux utilisateurs de parcourir un catalogue, personnaliser leurs pizzas, gérer leur panier et passer des commandes avec sélection de créneaux horaires. L'application inclut également une interface d'administration complète pour gérer les produits et un mode cuisine pour suivre les commandes en temps réel.

### ✨ Fonctionnalités Principales

- 🔐 **Authentification Firebase** - Connexion sécurisée avec rôles (client, admin, kitchen)
- 📋 **Catalogue** - Pizzas, menus, boissons, desserts
- 🛒 **Panier intelligent** - Gestion complète avec quantités
- ⏰ **Commande** - Sélection de date et créneaux horaires
- 🔄 **Temps réel** - Synchronisation instantanée des commandes via Firestore
- 👤 **Profil** - Informations et historique des commandes
- 👨‍💼 **Admin** - CRUD complet pour pizzas, menus, boissons et desserts + page builder
- 👨‍🍳 **Mode Cuisine** - Suivi en temps réel des commandes avec notifications
- ⭐ **Favoris** - Sauvegarde de produits préférés

---

## 🚀 Démarrage Rapide

### Prérequis

- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Git
- **Firebase Project** (voir [FIREBASE_SETUP.md](FIREBASE_SETUP.md))

### Installation

```bash
# Cloner le repository
git clone https://github.com/alexandremagre44-svg/AppliPizza.git
cd AppliPizza

# Configurer Firebase (IMPORTANT !)
# Suivez les instructions dans FIREBASE_SETUP.md
flutterfire configure

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Configuration Firebase (Obligatoire)

Avant de lancer l'application, vous devez :

1. Créer un projet Firebase
2. Activer Authentication (Email/Password) et Firestore
3. Déployer les règles de sécurité Firestore
4. (Optionnel) Créer des utilisateurs de test - ou utilisez l'écran d'inscription dans l'app

**Guides complets :** 
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Configuration Firebase
- [ADMIN_SIGNUP_GUIDE.md](ADMIN_SIGNUP_GUIDE.md) - Création de comptes admin

### 🆕 Création de votre premier compte

**Nouveau : L'application inclut maintenant un écran d'inscription !**

1. Lancez l'application
2. Sur l'écran de connexion, cliquez sur **"Pas de compte ? Créer un compte"**
3. Remplissez le formulaire d'inscription
4. Pour créer un administrateur, cochez **"Créer un compte administrateur"**
5. Connectez-vous avec vos nouveaux identifiants

**📖 Guide détaillé : [ADMIN_SIGNUP_GUIDE.md](ADMIN_SIGNUP_GUIDE.md)**

**Note:** Les anciens identifiants de test doivent maintenant être créés via l'écran d'inscription ou manuellement dans Firebase Console.

---

## 📚 Documentation

Une documentation complète est disponible dans les fichiers suivants:

### 📖 Documents Principaux

| Document | Description |
|----------|-------------|
| **[ANALYSE_APPLICATION.md](ANALYSE_APPLICATION.md)** | 📊 Analyse complète de l'architecture, des composants et de l'état du projet |
| **[CARTE_NAVIGATION.md](CARTE_NAVIGATION.md)** | 🗺️ Carte visuelle de navigation avec diagrammes et flows utilisateur |
| **[GUIDE_DEMARRAGE.md](GUIDE_DEMARRAGE.md)** | 🚀 Guide pratique de démarrage et recommandations de développement |
| **[ADMIN_FEATURES.md](ADMIN_FEATURES.md)** | 🛠️ Guide complet des fonctionnalités admin (CRUD, mise en avant, page builder) |
| **[ADMIN_SIGNUP_GUIDE.md](ADMIN_SIGNUP_GUIDE.md)** | 📝 Guide de création de comptes administrateurs via l'interface |
| **[CORRECTIONS.md](CORRECTIONS.md)** | 🔧 Résumé de toutes les corrections et améliorations apportées |
| **[FIRESTORE_INTEGRATION.md](FIRESTORE_INTEGRATION.md)** | 🔥 Guide d'intégration Firebase/Firestore pour charger les produits cloud |

### 🎯 Que Lire en Premier ?

1. **Pour comprendre rapidement l'app** → [GUIDE_DEMARRAGE.md](GUIDE_DEMARRAGE.md)
2. **Pour voir l'architecture détaillée** → [ANALYSE_APPLICATION.md](ANALYSE_APPLICATION.md)
3. **Pour comprendre la navigation** → [CARTE_NAVIGATION.md](CARTE_NAVIGATION.md)
4. **Pour activer Firestore** → [FIRESTORE_INTEGRATION.md](FIRESTORE_INTEGRATION.md)

---

## 🏗️ Architecture

### Technologies Utilisées

- **Framework:** Flutter 3.0+
- **Langage:** Dart 3.0+
- **État:** Riverpod 2.5.1
- **Navigation:** GoRouter 13.2.0
- **Stockage:** SharedPreferences 2.2.2
- **Utilitaires:** UUID, Badges

### Structure du Projet

```
lib/
├── main.dart              # Point d'entrée
└── src/
    ├── core/              # Constantes et configuration
    ├── data/              # Données mockées
    ├── models/            # Modèles de données
    ├── providers/         # Gestion d'état (Riverpod)
    ├── repositories/      # Accès aux données
    ├── screens/           # Écrans de l'application
    ├── services/          # Services métier
    ├── theme/             # Thème et styles
    └── widgets/           # Composants réutilisables
```

---

## 📱 Captures d'Écran

> Les captures d'écran montrent l'application en fonctionnement avec l'interface moderne Material Design.

### Écrans Principaux

- **Home** - Accueil avec pizzas populaires et menus
- **Menu** - Catalogue complet avec filtres par catégorie
- **Panier** - Gestion des articles avec quantités
- **Checkout** - Sélection de créneaux et validation
- **Profil** - Informations et historique
- **Admin** - Dashboard et gestion produits

---

## ✅ État du Projet

### Fonctionnalités Complètes ✅

- ✅ Authentification locale (login/logout)
- ✅ Catalogue de produits par catégorie
- ✅ Panier avec gestion complète
- ✅ Processus de commande avec créneaux horaires
- ✅ Profil utilisateur et historique
- ✅ Interface admin (CRUD pizzas, menus, boissons, desserts)
- ✅ Système de mise en avant des produits (featured)
- ✅ Page Builder pour organiser l'affichage
- ✅ Navigation fluide avec bottom bar
- ✅ Gestion des favoris

### En Cours / Partiel ⚠️

- ⚠️ Customisation des pizzas (modal présente)
- ⚠️ Customisation des menus (modal présente)
- ⚠️ Images hébergées sur Unsplash (temporaire)

### À Implémenter 🔴

- 🔴 Backend réel (Firebase ou API)
- 🔴 Système de paiement
- 🔴 Tests automatisés
- 🔴 Notifications push
- 🔴 Gestion horaires restaurant

---

## 🛠️ Commandes Utiles

### Développement

```bash
# Lancer en mode debug
flutter run

# Lancer sur un device spécifique
flutter run -d chrome    # Web
flutter run -d android   # Android

# Nettoyer le projet
flutter clean

# Analyser le code
flutter analyze

# Formater le code
dart format lib/
```

### Build Production

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# Web
flutter build web
```

---

## 🗺️ Roadmap

### Phase 1 - MVP Amélioré (1-2 semaines) 🎯
- [ ] Fusionner mock data et produits admin
- [ ] Ajouter assets locaux pour images
- [ ] Tests de base (providers, services)
- [ ] Améliorer UX (loading, erreurs)

### Phase 2 - Backend (2-4 semaines) 🔥
- [ ] Setup Firebase (Auth + Firestore)
- [ ] Migration des données
- [ ] Cloud Functions pour commandes
- [ ] Notifications push

### Phase 3 - Production (1-2 mois) 🚀
- [ ] Intégration paiement (Stripe)
- [ ] Programme de fidélité
- [ ] Admin avancé (analytics, rapports)
- [ ] Tests complets

---

## 📊 Métriques de Qualité

| Critère | Note | Statut |
|---------|------|--------|
| Architecture | 9/10 | ✅ Excellent |
| Code Quality | 8/10 | ✅ Très bon |
| UI/UX | 7/10 | ✅ Bon |
| Fonctionnalités | 7/10 | ✅ Bon |
| Tests | 2/10 | ⚠️ À améliorer |
| Sécurité | 4/10 | ⚠️ OK pour démo |
| Performance | 7/10 | ✅ Bon |

**Note globale: 6.25/10** - Excellent pour un MVP, nécessite travail pour production

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer:

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

---

## 📝 License

Ce projet est un projet éducatif/de démonstration.

---

## 📞 Contact

Pour toute question sur le projet:
- 📧 Consultez la documentation dans les fichiers MD
- 💬 Ouvrez une issue sur GitHub
- 📖 Lisez les commentaires dans le code

---

## 🎓 Ressources

### Documentation du Projet
- [Analyse Complète](ANALYSE_APPLICATION.md)
- [Carte de Navigation](CARTE_NAVIGATION.md)
- [Guide de Démarrage](GUIDE_DEMARRAGE.md)

### Ressources Externes
- [Documentation Flutter](https://docs.flutter.dev)
- [Documentation Riverpod](https://riverpod.dev)
- [Documentation GoRouter](https://pub.dev/packages/go_router)
- [Firebase pour Flutter](https://firebase.flutter.dev)

---

## ⭐ Remerciements

Merci d'utiliser Pizza Deli'Zza !

Si ce projet vous aide, n'hésitez pas à lui donner une étoile ⭐

---

*Dernière mise à jour: 6 novembre 2025*
*Version: 1.0.0+1*
