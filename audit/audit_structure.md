# Audit Technique - Structure du Projet

## Vue d'ensemble

Ce document décrit la structure complète du projet Flutter AppliPizza.

## Arborescence du projet

```
lib/
├── main.dart                          # Point d'entrée de l'application
├── firebase_options.dart              # Configuration Firebase
│
├── builder/                           # Module Builder B3 (éditeur de pages)
│   ├── builder_entry.dart             # Point d'entrée du builder
│   ├── models/                        # Modèles de données du builder
│   ├── services/                      # Services Firestore
│   ├── blocks/                        # Widgets de blocs (preview + runtime)
│   ├── editor/                        # Interface d'édition
│   ├── preview/                       # Prévisualisation
│   ├── runtime/                       # Rendu runtime (app client)
│   ├── providers/                     # Providers Riverpod
│   ├── page_list/                     # Liste des pages
│   ├── utils/                         # Utilitaires
│   └── exceptions/                    # Exceptions personnalisées
│
└── src/                               # Application principale
    ├── core/                          # Constants, chemins Firestore
    ├── models/                        # Modèles métier
    ├── services/                      # Services métier
    ├── providers/                     # Providers Riverpod
    ├── screens/                       # Écrans de l'application
    ├── widgets/                       # Widgets réutilisables
    ├── design_system/                 # Système de design
    ├── theme/                         # Configuration du thème
    ├── kitchen/                       # Module cuisine
    ├── staff_tablet/                  # Module tablette staff
    ├── data/                          # Données mock
    └── repositories/                  # Repositories
```

## Modules principaux

### 1. Builder B3 (`lib/builder/`)
Module d'édition de pages avec :
- Système de blocs modulaires
- Workflow draft/published
- Support multi-restaurant (multi-tenant)
- Preview en temps réel

### 2. Application Client (`lib/src/`)
Application principale avec :
- Écrans métier (home, menu, cart, profile, etc.)
- Gestion des commandes
- Système de fidélité
- Roulette promotionnelle

### 3. Module Cuisine (`lib/src/kitchen/`)
Interface pour la cuisine avec :
- Affichage des commandes en temps réel
- Gestion des statuts de commande

### 4. Module Staff Tablet (`lib/src/staff_tablet/`)
Application tablette pour le personnel avec :
- Passage de commandes
- Historique
- Authentification PIN

## Dépendances externes

### Firebase
- Cloud Firestore (base de données)
- Firebase Auth (authentification)
- Firebase Storage (stockage d'images)

### State Management
- Riverpod (gestion d'état)

### UI
- flutter_hooks
- flutter_fortune_wheel (roulette)

## Fichiers de configuration

| Fichier | Description |
|---------|-------------|
| `pubspec.yaml` | Dépendances du projet |
| `firebase_options.dart` | Configuration Firebase |
| `lib/src/core/constants.dart` | Constantes globales |
| `lib/src/core/firestore_paths.dart` | Chemins Firestore centralisés |

---

*Document généré automatiquement - Audit technique AppliPizza*
