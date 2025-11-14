# Module Tablette Staff - Guide d'utilisation

## Vue d'ensemble

Le module Tablette Staff est un système de prise de commande à emporter optimisé pour une utilisation sur tablette 10-11 pouces au comptoir de la pizzeria. Il permet au personnel de prendre rapidement des commandes sans nécessiter de compte client.

## Caractéristiques principales

### 🔐 Sécurité
- **Accès protégé par PIN** : Code à 4 chiffres pour limiter l'accès au personnel
- **PIN par défaut** : `1234` (modifiable)
- **Session persistante** : 8 heures avant expiration automatique
- **Déconnexion manuelle** : Bouton de déconnexion disponible dans toutes les vues

### 🛒 Prise de commande
- **Catalogue complet** : Accès à tous les produits actifs (pizzas, menus, boissons, desserts)
- **Navigation par catégories** : Onglets larges et clairs
- **Ajout rapide au panier** : Un clic pour ajouter un produit
- **Gestion des quantités** : Boutons +/- intuitifs
- **Panier en temps réel** : Affichage permanent du panier sur la droite

### 📝 Informations de commande
- **Nom du client** : Champ optionnel
- **Créneau de retrait** :
  - "Dès que possible" (par défaut)
  - Créneaux horaires prédéfinis (11h30-21h00)
- **Mode de paiement** :
  - Espèces
  - Carte bancaire
  - Autre

### 📊 Historique et statistiques
- **Commandes du jour** : Liste de toutes les commandes passées depuis la tablette aujourd'hui
- **Statistiques en temps réel** :
  - Nombre de commandes
  - Chiffre d'affaires du jour
- **Suivi des statuts** : Mise à jour en temps réel (en attente, préparation, prêt, livré)

## Accès au module

### URL directe
```
/staff-tablet
```

### Depuis l'application
1. Depuis la page d'accueil, cliquer sur "Mode Caisse" (si ajouté au menu)
2. Entrer le code PIN (par défaut : 1234)
3. Accéder au catalogue

## Workflow de prise de commande

### 1. Connexion
1. Accéder à `/staff-tablet`
2. Entrer le code PIN à 4 chiffres
3. Le code est automatiquement validé après 4 chiffres

### 2. Sélection des produits
1. Choisir une catégorie (Pizzas, Menus, Boissons, Desserts)
2. Cliquer sur un produit pour l'ajouter au panier
3. Le panier se met à jour automatiquement à droite

### 3. Gestion du panier
- **Modifier la quantité** : Utiliser les boutons +/- sur chaque article
- **Supprimer un article** : Réduire la quantité à 0
- **Vider le panier** : Bouton "Vider le panier" en bas

### 4. Validation de la commande
1. Cliquer sur "Valider la commande"
2. Remplir les informations :
   - Nom du client (optionnel)
   - Heure de retrait (ASAP ou créneau spécifique)
   - Mode de paiement
3. Confirmer avec "Valider la commande"
4. La commande est créée et envoyée automatiquement en cuisine

### 5. Commande suivante
- Après validation, possibilité de créer une nouvelle commande immédiatement
- Le panier est automatiquement vidé

## Historique des commandes

### Accéder à l'historique
- Cliquer sur l'icône d'historique (⏰) dans la barre supérieure

### Informations affichées
- **Heure de la commande**
- **Nom du client** (si renseigné)
- **Nombre d'articles**
- **Mode de paiement**
- **Statut actuel** (avec badge coloré)
- **Total de la commande**

### Statistiques du jour
- **Commandes** : Nombre total de commandes passées aujourd'hui
- **Chiffre d'affaires** : Total des ventes de la journée

### Détails d'une commande
- Cliquer sur une commande pour voir les détails complets
- Liste des articles avec quantités et prix
- Informations complètes du client

## Intégration avec le système

### Synchronisation Firestore
- Les commandes sont enregistrées dans la collection `orders` de Firestore
- Marquées avec `source: "staff_tablet"`
- Synchronisation en temps réel avec le module cuisine
- Visible dans l'admin avec filtre par source

### Statuts des commandes
Les commandes suivent le même cycle que les commandes client :
1. **En attente** (pending) - Commande créée
2. **En préparation** (preparing) - Prise en charge par la cuisine
3. **En cuisson** (baking) - Phase de cuisson
4. **Prête** (ready) - À retirer
5. **Livrée** (delivered) - Commande remise au client

### Module cuisine
- Les commandes apparaissent automatiquement dans le module cuisine
- Badge "Tablette" pour identifier la source
- Même workflow de traitement que les commandes en ligne

## Configuration

### Changer le code PIN
Le code PIN peut être modifié programmatiquement via le provider :
```dart
await ref.read(staffTabletAuthProvider.notifier).changePin(currentPin, newPin);
```

### Personnaliser les créneaux horaires
Modifier le tableau `_timeSlots` dans `staff_tablet_checkout_screen.dart` :
```dart
final List<String> _timeSlots = [
  '11:30', '12:00', '12:30', // ... vos créneaux
];
```

### Timeout de session
Modifier la constante dans `staff_tablet_auth_provider.dart` :
```dart
static const int sessionTimeout = 480; // en minutes (8 heures par défaut)
```

## Interface utilisateur

### Optimisations tablette
- **Layout 10-11 pouces** : Interface adaptée aux tablettes moyennes
- **Boutons larges** : Facilité de toucher (minimum 50px de hauteur)
- **Grille 3 colonnes** : Affichage optimal des produits
- **Contraste élevé** : Lisibilité en environnement lumineux
- **Couleur principale** : Orange (couleur de la marque)

### Navigation
- **Catalogue** : Vue principale avec produits et panier
- **Checkout** : Formulaire de finalisation
- **Historique** : Liste des commandes du jour
- **Déconnexion** : Retour à l'écran PIN

## Avantages

### Pour le staff
- ✅ Prise de commande rapide et intuitive
- ✅ Pas besoin de créer un compte client
- ✅ Suivi en temps réel des commandes
- ✅ Accès à l'historique immédiat
- ✅ Interface adaptée à un usage intensif

### Pour les clients
- ✅ Service plus rapide au comptoir
- ✅ Moins d'erreurs de commande
- ✅ Visibilité sur le statut de préparation
- ✅ Options de paiement flexibles

### Pour la gestion
- ✅ Traçabilité complète des commandes tablette
- ✅ Statistiques séparées par source
- ✅ Synchronisation automatique avec la cuisine
- ✅ Données en temps réel
- ✅ Aucune modification nécessaire aux modules existants

## Support et maintenance

### Dépendances
- `flutter_riverpod` : Gestion d'état
- `go_router` : Navigation
- `shared_preferences` : Stockage du PIN
- `cloud_firestore` : Synchronisation
- `intl` : Formatage des dates

### Structure des fichiers
```
lib/src/staff_tablet/
├── providers/
│   ├── staff_tablet_auth_provider.dart
│   ├── staff_tablet_cart_provider.dart
│   └── staff_tablet_orders_provider.dart
├── screens/
│   ├── staff_tablet_pin_screen.dart
│   ├── staff_tablet_catalog_screen.dart
│   ├── staff_tablet_checkout_screen.dart
│   └── staff_tablet_history_screen.dart
└── widgets/
    └── staff_tablet_cart_summary.dart
```

### Logs et debugging
Les commandes tablette peuvent être identifiées dans Firestore par :
```
source == "staff_tablet"
```

## Évolutions futures (V2)

Fonctionnalités envisagées :
- ⏭️ Intégration TPE pour paiements CB automatiques
- ⏭️ Impression automatique de tickets
- ⏭️ Customisation de pizzas depuis la tablette
- ⏭️ Scan de codes de fidélité
- ⏭️ Gestion multi-PIN (plusieurs membres du staff)
- ⏭️ Statistiques détaillées par période
- ⏭️ Export des données comptables
