# 🍕 Pizza Deli'Zza

Application Flutter complète de commande de pizzas en ligne avec interface client et administration.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Status](https://img.shields.io/badge/Status-MVP%20Ready-green.svg)

---

## 📱 Présentation

**Pizza Deli'Zza** est une application mobile de commande de pizzas qui permet aux utilisateurs de parcourir un catalogue, personnaliser leurs pizzas, gérer leur panier et passer des commandes avec sélection de créneaux horaires. L'application inclut également une interface d'administration complète pour gérer les produits.

### ✨ Fonctionnalités Principales

- 🔐 **Authentification** - Connexion client et admin
- 📋 **Catalogue** - Pizzas, menus, boissons, desserts
- 🛒 **Panier intelligent** - Gestion complète avec quantités
- ⏰ **Commande** - Sélection de date et créneaux horaires
- 👤 **Profil** - Informations et historique des commandes
- 👨‍💼 **Admin** - CRUD complet pour pizzas et menus
- ⭐ **Favoris** - Sauvegarde de produits préférés

---

## 🚀 Démarrage Rapide

### Prérequis

- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Git

### Installation

```bash
# Cloner le repository
git clone https://github.com/alexandremagre44-svg/AppliPizza.git
cd AppliPizza

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Premiers Tests

**Compte Client:**
```
Email: client@delizza.com
Password: client123
```

**Compte Admin:**
```
Email: admin@delizza.com
Password: admin123
```

---

## 📚 Documentation

Une documentation complète est disponible dans les fichiers suivants:

### 📖 Documents Principaux

| Document | Description |
|----------|-------------|
| **[ANALYSE_APPLICATION.md](ANALYSE_APPLICATION.md)** | 📊 Analyse complète de l'architecture, des composants et de l'état du projet |
| **[CARTE_NAVIGATION.md](CARTE_NAVIGATION.md)** | 🗺️ Carte visuelle de navigation avec diagrammes et flows utilisateur |
| **[GUIDE_DEMARRAGE.md](GUIDE_DEMARRAGE.md)** | 🚀 Guide pratique de démarrage et recommandations de développement |

### 🎯 Que Lire en Premier ?

1. **Pour comprendre rapidement l'app** → [GUIDE_DEMARRAGE.md](GUIDE_DEMARRAGE.md)
2. **Pour voir l'architecture détaillée** → [ANALYSE_APPLICATION.md](ANALYSE_APPLICATION.md)
3. **Pour comprendre la navigation** → [CARTE_NAVIGATION.md](CARTE_NAVIGATION.md)

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
- ✅ Interface admin (CRUD pizzas et menus)
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
