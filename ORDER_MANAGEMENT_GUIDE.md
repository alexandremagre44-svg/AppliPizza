# Guide du Module de Gestion des Commandes

## 📋 Vue d'ensemble

Le module de gestion des commandes offre une interface complète pour suivre et gérer les commandes clients en temps réel depuis l'interface admin.

## 🎯 Fonctionnalités principales

### 1. Vue d'ensemble des commandes

#### Deux modes d'affichage
- **Vue tableau** : Affichage dense avec colonnes triables
  - N° commande
  - Client
  - Heure
  - Total
  - Statut
  - Actions
  
- **Vue cartes** : Affichage visuel optimal pour tablettes
  - Cartes avec informations essentielles
  - Badge de statut coloré
  - Indicateur de commandes non vues

#### Fonctionnalités de recherche et filtrage
- **Recherche textuelle** : Par n° commande, nom client, téléphone
- **Filtre par statut** :
  - 🕓 En attente
  - 🧑‍🍳 En préparation
  - ✅ Prête
  - 📦 Livrée
  - ❌ Annulée
  
- **Filtre par période** :
  - Aujourd'hui
  - Cette semaine
  - Ce mois
  - Période personnalisée

- **Tri dynamique** :
  - Par date (ascendant/descendant)
  - Par montant
  - Par statut
  - Par client

### 2. Détails d'une commande

#### Informations affichées
- Numéro et date de commande
- Informations client (nom, téléphone, email)
- Créneau de retrait prévu
- Liste détaillée des produits
- Commentaire client
- Total de la commande
- Historique des changements de statut

#### Actions disponibles
- **Changer le statut** :
  - Marquer en préparation (depuis "En attente")
  - Marquer prête (depuis "En préparation")
  - Marquer livrée (depuis "Prête")
  
- **Annuler la commande** : Avec confirmation
- **Imprimer** : Stub préparé pour intégration future
- **Marquer comme vue** : Automatique à l'ouverture

### 3. Notifications en temps réel

#### Alertes visuelles
- Popup animé en haut de l'écran
- Badge rouge avec nombre de commandes non vues
- Bordure rouge sur les cartes de commandes non vues
- Mise en évidence dans le tableau

#### Son de notification
- Joué automatiquement lors d'une nouvelle commande
- Configurable (actuellement en mode console log)
- Compatible avec fichiers audio personnalisés

### 4. Export de données

#### Format CSV
- Export des commandes filtrées actuelles
- Colonnes exportées :
  - N° Commande, Date, Heure
  - Client, Téléphone, Email
  - Statut, Produits, Quantité
  - Total, Commentaire
  - Date et créneau de retrait
  
- Nom de fichier automatique avec timestamp
- Téléchargement direct dans le navigateur

### 5. Responsive Design

#### Desktop (écran large)
- Vue split : Liste + détail côte à côte en mode paysage
- Table complète avec toutes les colonnes
- Grille 3 colonnes en mode cartes

#### Tablette
- Vue overlay : Détail en plein écran avec slide animation
- Table scrollable horizontalement
- Grille 2 colonnes en mode cartes

## 🚀 Utilisation

### Accès au module
1. Connectez-vous en tant qu'admin
2. Allez sur le Dashboard Admin
3. Cliquez sur la carte "Commandes"

### Générer des données de test
1. Sur l'écran des commandes
2. Cliquez sur le bouton flottant "Test Data"
3. 10 commandes de test sont générées automatiquement

### Changer le statut d'une commande
1. Cliquez sur une commande pour ouvrir le détail
2. Utilisez les boutons en bas :
   - "Préparer" pour passer en préparation
   - "Prête" pour marquer comme prête
   - "Livrée" pour marquer comme livrée
3. Le changement est enregistré instantanément

### Filtrer les commandes
1. Cliquez sur l'icône de filtre dans l'app bar
2. Sélectionnez un statut ou une période
3. Les filtres actifs s'affichent sous la barre de recherche
4. Cliquez sur "Effacer" pour réinitialiser

### Exporter en CSV
1. Appliquez les filtres souhaités (optionnel)
2. Cliquez sur l'icône de téléchargement
3. Le fichier CSV est téléchargé automatiquement

## 🔧 Architecture technique

### Structure des fichiers

```
lib/src/
├── models/
│   └── order.dart                    # Modèle Order avec OrderStatus et OrderStatusHistory
├── services/
│   └── order_service.dart            # Service CRUD avec StreamController
├── providers/
│   └── order_provider.dart           # Providers Riverpod pour state management
├── screens/admin/
│   └── admin_orders_screen.dart      # Écran principal de gestion
├── widgets/
│   ├── order_status_badge.dart       # Badge coloré de statut
│   ├── order_detail_panel.dart       # Panneau de détail animé
│   └── new_order_notification.dart   # Notification popup + son
└── utils/
    ├── order_test_data.dart          # Générateur de données de test
    └── order_export.dart             # Export CSV
```

### Flux de données

```
Order created (checkout) 
  → OrderService.addOrder()
  → SharedPreferences save
  → StreamController notify
  → OrderProvider update
  → UI rebuild (real-time)
  → Notification if unviewed
```

### State Management

- **ordersStreamProvider** : Stream des commandes depuis OrderService
- **filteredOrdersProvider** : Commandes filtrées selon les critères
- **unviewedOrdersProvider** : Commandes non vues
- **unviewedOrdersCountProvider** : Compteur de notifications
- **ordersViewProvider** : État des filtres et options d'affichage

## 📊 Statuts des commandes

| Statut | Icône | Couleur | Description |
|--------|-------|---------|-------------|
| En attente | 🕓 | Orange | Nouvelle commande reçue |
| En préparation | 🧑‍🍳 | Bleu | Commande en cours de préparation |
| Prête | ✅ | Vert | Prête pour le retrait |
| Livrée | 📦 | Gris | Remise au client |
| Annulée | ❌ | Rouge | Commande annulée |

## 🎨 Design System

### Couleurs utilisées
- Rouge principal : `#B00020` (AppColors.primaryRed)
- Rouge clair : `#E53935` (AppColors.primaryRedLight)
- Vert succès : `#4CAF50` (AppColors.successGreen)
- Orange alerte : `#FF9800` (AppColors.warningOrange)
- Bleu info : `#2196F3` (AppColors.infoBlue)

### Animations
- Slide transition : 300ms (détail panel)
- Scale animation : 400ms avec elastic curve (notification)
- Fade in : 400ms (cartes admin)

## 🔮 Améliorations futures

### Court terme
- [ ] Intégration son notification (fichier audio)
- [ ] Intégration imprimante réseau
- [ ] Notifications push serveur
- [ ] Statistiques temps réel (CA du jour, moyenne panier)

### Moyen terme
- [ ] Intégration Firebase/Firestore pour sync cloud
- [ ] Multi-utilisateurs avec permissions
- [ ] Historique d'archivage automatique
- [ ] Rapport PDF détaillé

### Long terme
- [ ] Application mobile dédiée pour tablette cuisine
- [ ] Écran client pour suivi de commande
- [ ] Intégration système de paiement
- [ ] API REST pour intégration externe

## 🐛 Dépannage

### Les commandes ne s'affichent pas
- Vérifiez que des commandes ont été créées (utiliser "Test Data")
- Rafraîchissez avec le bouton refresh
- Vérifiez les filtres actifs (bouton "Effacer")

### Les notifications ne fonctionnent pas
- Le son nécessite un fichier audio dans les assets (actuellement en console.log)
- Vérifiez les permissions du navigateur pour les notifications
- Les notifications apparaissent uniquement pour les nouvelles commandes non vues

### L'export CSV ne fonctionne pas
- Fonctionne uniquement sur navigateur web (dart:html)
- Pour mobile, implémenter avec package path_provider
- Vérifiez qu'il y a des commandes à exporter

## 📝 Notes de développement

### Stockage local
Le module utilise SharedPreferences pour le stockage local :
- Clé : `orders_list`
- Format : JSON array d'objets Order
- Limite : ~10MB (suffisant pour milliers de commandes)

### Performance
- StreamController broadcast pour multiple listeners
- Cache local pour éviter lectures répétées
- Filtres et tris en mémoire (optimisé pour <1000 commandes)

### Compatibilité
- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Android
- ✅ iOS
- ✅ Desktop (Windows, macOS, Linux)

## 👥 Support

Pour toute question ou amélioration :
1. Consultez ce guide
2. Vérifiez les commentaires dans le code
3. Testez avec les données de test
4. Contactez l'équipe de développement

---

**Version** : 1.0.0  
**Date** : Novembre 2024  
**Auteur** : Pizza Deli'Zza Development Team
