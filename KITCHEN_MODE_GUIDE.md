# Guide du Mode Cuisine (Kitchen Mode)

## Vue d'ensemble

Le Mode Cuisine est une interface spécialisée pour la gestion des commandes en cuisine. Il offre une vue en temps réel des commandes à préparer avec un affichage optimisé pour tablette et un environnement de travail tactile.

## Accès au Mode Cuisine

### Connexion
Utilisez les identifiants suivants pour accéder au mode cuisine :
- **Email** : `kitchen@delizza.com`
- **Mot de passe** : `kitchen123`

### Navigation
Une fois connecté avec un compte cuisine ou admin :
1. Accédez à l'écran "Profil"
2. Cliquez sur le bouton "ACCÉDER AU MODE CUISINE"
3. Ou naviguez directement vers `/kitchen`

## Caractéristiques

### Interface
- **Fond noir** (000000) pour réduire la fatigue oculaire
- **Textes haute contraste** blancs et couleurs vives
- **Grille de cartes** : minimum 6 cartes visibles (2x3 ou 3x2)
- **Typographie grande** et espaces généreux pour faciliter la lecture

### Codes Couleur des Statuts

| Statut | Couleur | Code Hex |
|--------|---------|----------|
| En attente | Bleu | #2196F3 |
| En préparation | Rose/Magenta | #E91E63 |
| En cuisson | Rouge | #F44336 |
| Prête | Vert | #4CAF50 |
| Annulée | Gris | #757575 |

### Flux de Travail

Le flux de statut par défaut est :
```
En attente → En préparation → En cuisson → Prête
```

### Gestes et Interactions

#### Sur la Carte de Commande
- **Clic au centre** : Ouvre le détail complet de la commande
- **Zone gauche (50%)** : Passer à l'état précédent
- **Zone droite (50%)** : Passer à l'état suivant

#### Dans le Détail de Commande
- Bouton "État Précédent" : Recule d'un statut
- Bouton "État Suivant" : Avance d'un statut
- Bouton "Imprimer Ticket Cuisine" : Envoie à l'imprimante (stub)
- Bouton "Fermer" : Retourne à la grille

### Informations Affichées sur Chaque Carte

- **Numéro de commande** : 8 premiers caractères de l'ID (ex: #ABC12345)
- **Heure de création** : Format HH:mm
- **Chronomètre** : Temps écoulé depuis la création (mis à jour toutes les 30s)
- **Statut** : Badge coloré avec animation pour nouvelles commandes
- **Heure de retrait** : Si spécifiée
- **Aperçu des items** : Liste des produits avec quantités
- **Indicateur "NOUVELLE"** : Pour les commandes non vues

### Détail Complet de Commande

Le modal de détail affiche :
- Numéro de commande et statut
- Informations temporelles (création, durée, retrait prévu)
- Informations client (nom, téléphone)
- Liste complète des items avec :
  - Quantité
  - Nom du produit
  - Prix unitaire
  - Personnalisations/ingrédients
  - Total par ligne
- Commentaires du client
- Total général de la commande

### Notifications

#### Alertes Visuelles
- **Badge dans l'en-tête** : Affiche le nombre de nouvelles commandes
- **Animation sur les cartes** : Pulsation légère sur les commandes non vues
- **Indicateur "NOUVELLE"** : Badge bleu sur chaque nouvelle carte

#### Alertes Sonores
- **Bip court** à l'arrivée d'une nouvelle commande
- **Répétition** toutes les 12 secondes tant qu'il reste des commandes non vues
- **Arrêt automatique** dès qu'on clique sur une nouvelle commande

### Logique de Planning

#### Fenêtre d'Affichage
Les commandes affichées sont filtrées selon leur heure de retrait :
- **Plage passée** : -15 minutes (PLANNING_WINDOW_PAST_MIN)
- **Plage future** : +45 minutes (PLANNING_WINDOW_FUTURE_MIN)
- **Maximum visible** : 7 commandes en backlog (BACKLOG_MAX_VISIBLE)

#### Tri des Commandes
1. Priorité à l'heure de retrait (pickupAt) si disponible
2. Sinon, tri par heure de création
3. Les commandes les plus urgentes apparaissent en premier

### Actions de l'En-tête

- **Badge Notifications** : Affiche le nombre de nouvelles commandes
- **Bouton Imprimer Tout** : Imprime tous les tickets des nouvelles commandes
- **Bouton Actualiser** : Force un rafraîchissement manuel
- **Bouton Quitter** : Retourne à l'écran d'accueil

## Impression

### Service d'Impression (Stub)
Le service d'impression est actuellement un stub prêt pour intégration :

```dart
KitchenPrintService().printKitchenTicket(order);
```

### Format du Ticket
Le ticket contient :
- ID et numéro de commande
- Date et heure
- Heure de retrait prévue
- Statut
- Informations client
- Liste complète des items avec personnalisations
- Commentaires
- Total
- Timestamp d'impression

### TODO : Intégration Future
Pour connecter une vraie imprimante réseau :
1. Ouvrir `lib/src/kitchen/services/kitchen_print_stub.dart`
2. Implémenter la méthode `_sendToNetworkPrinter(ticketData)`
3. Configurer l'adresse IP et le port de l'imprimante

## Configuration

### Constantes Modifiables
Fichier : `lib/src/kitchen/kitchen_constants.dart`

```dart
// Fenêtre de planning
static const int planningWindowPastMin = 15;
static const int planningWindowFutureMin = 45;
static const int backlogMaxVisible = 7;

// Notifications
static const int notificationRepeatSeconds = 12;

// Grille
static const int gridCrossAxisCount = 2;
static const double gridChildAspectRatio = 1.3;
```

## Temps Réel

Le mode cuisine utilise un `StreamBuilder` connecté à `OrderService.ordersStream` :
- **Mises à jour automatiques** lors de changements de commandes
- **Pas de polling** : événements push uniquement
- **Rafraîchissement manuel** disponible via le bouton

## Tests

### Test Manuel - Scénario Basique
1. Connectez-vous avec le compte cuisine
2. Accédez au Mode Cuisine
3. Créez une nouvelle commande depuis l'interface client
4. Vérifiez que :
   - La commande apparaît dans la grille
   - Le badge "NOUVELLE" est visible
   - L'animation de pulsation fonctionne
   - Un son est joué (si disponible)
5. Cliquez sur la zone droite de la carte
6. Vérifiez que le statut passe de "En attente" à "En préparation"
7. Cliquez sur la carte pour ouvrir le détail
8. Vérifiez que toutes les informations sont affichées
9. Testez les boutons d'état suivant/précédent
10. Testez le bouton d'impression

### Test Manuel - Scénario Planning
1. Créez plusieurs commandes avec différentes heures de retrait
2. Vérifiez que les commandes sont triées par heure de retrait
3. Créez une commande avec un retrait dans 2 heures
4. Vérifiez qu'elle n'apparaît pas (hors fenêtre de planning)

## Accessibilité

- **Boutons tactiles** : Minimum 48dp de hauteur
- **Contrastes élevés** : Ratio WCAG AA+ sur fond noir
- **Zones tactiles larges** : Zones gauche/droite = 30% de la largeur de la carte
- **Pas de scrollbars imbriquées** : Une seule zone de scroll principale
- **Textes lisibles** : Taille minimum 14px, poids semi-bold pour les infos importantes

## Sécurité et Rôles

### Contrôle d'Accès
- L'accès est vérifié via `authState.userRole`
- Seuls les rôles `kitchen` et `admin` peuvent accéder au mode cuisine
- En développement, un avertissement est affiché si le rôle n'est pas `kitchen`

### Production
Pour la production, il est recommandé de :
1. Rediriger automatiquement les utilisateurs non autorisés
2. Logger les tentatives d'accès non autorisées
3. Implémenter une authentification plus robuste (Firebase Auth, JWT, etc.)

## Dépannage

### Les commandes n'apparaissent pas
- Vérifiez que des commandes existent dans l'OrderService
- Vérifiez les filtres de statut (pas annulées, pas livrées)
- Vérifiez la fenêtre de planning (heures de retrait)

### Les notifications ne fonctionnent pas
- Vérifiez que l'audioplayer est correctement configuré
- Ajoutez un fichier audio dans `assets/sounds/notification.mp3`
- Mettez à jour `pubspec.yaml` pour inclure les assets

### L'interface est trop petite/grande
- Ajustez `gridCrossAxisCount` dans `kitchen_constants.dart`
- Ajustez `gridChildAspectRatio` pour modifier la hauteur des cartes

## Architecture Technique

### Structure des Fichiers
```
lib/src/kitchen/
├── kitchen_constants.dart          # Constantes et configuration
├── kitchen_page.dart                # Page principale
├── services/
│   ├── kitchen_notifications.dart  # Gestion des alertes
│   └── kitchen_print_stub.dart     # Service d'impression
└── widgets/
    ├── kitchen_order_card.dart     # Carte de commande
    ├── kitchen_order_detail.dart   # Modal de détail
    └── kitchen_status_badge.dart   # Badge de statut
```

### Dépendances
Aucune nouvelle dépendance ajoutée. Utilise :
- `flutter_riverpod` : Gestion d'état
- `go_router` : Navigation
- `audioplayers` : Sons (déjà présent)
- `intl` : Formatage des dates
- `shared_preferences` : Stockage local

## Évolutions Futures

### Priorité Haute
- [ ] Intégration imprimante réseau réelle
- [ ] Fichier audio pour notifications
- [ ] Mode plein écran automatique (F11)
- [ ] Feedback haptique sur gestes

### Priorité Moyenne
- [ ] Filtres avancés (par type de produit, client, etc.)
- [ ] Statistiques temps réel (commandes/heure, temps moyen)
- [ ] Historique des changements de statut par commande
- [ ] Mode sombre/clair (actuellement fixe noir)

### Priorité Basse
- [ ] Export des données journalières
- [ ] Graphiques de performance
- [ ] Intégration avec système de caisse
- [ ] Support multi-écrans

## Support

Pour toute question ou problème :
1. Consultez ce guide
2. Vérifiez les logs de l'application
3. Contactez l'équipe de développement

---

**Version** : 1.0.0  
**Dernière mise à jour** : 2025-11-12
