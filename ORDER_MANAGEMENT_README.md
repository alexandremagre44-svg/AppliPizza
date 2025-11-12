# Module de Gestion des Commandes - Démarrage Rapide

## 🎯 Accès

1. **Connexion Admin**
   - Email : `admin@delizza.com`
   - Password : `admin123`

2. **Navigation**
   - Dashboard Admin → Carte "Commandes"
   - Ou directement : `/admin/orders`

## 🧪 Test Rapide

### Étape 1 : Générer des données de test
```
1. Ouvrez l'écran "Gestion des Commandes"
2. Cliquez sur le bouton flottant bleu "Test Data" en bas à droite
3. ✅ 10 commandes de test sont créées automatiquement
```

### Étape 2 : Explorer les fonctionnalités
```
✅ Toggle vue table/cartes (icône en haut à droite)
✅ Rechercher une commande (barre de recherche)
✅ Filtrer par statut ou période (icône filtre)
✅ Cliquer sur une commande pour voir le détail
✅ Changer le statut d'une commande
✅ Exporter en CSV (icône téléchargement)
```

## 🎨 Vues disponibles

### Vue Tableau (desktop)
- Colonnes triables : N° commande, Client, Heure, Total, Statut
- Cliquez sur les en-têtes pour trier
- Les commandes non vues sont surlignées

### Vue Cartes (tablette)
- Cartes visuelles avec informations essentielles
- Bordure rouge pour commandes non vues
- Layout responsive automatique

## 🔔 Notifications

Les nouvelles commandes déclenchent :
- 🎨 Popup animé en haut de l'écran
- 🔔 Son de notification (à configurer)
- 🔴 Badge rouge avec compteur
- ⚠️ Bordure rouge sur la carte

## 📊 Statuts et Actions

| Depuis | Action | Vers |
|--------|--------|------|
| 🕓 En attente | Bouton "Préparer" | 🧑‍🍳 En préparation |
| 🧑‍🍳 En préparation | Bouton "Prête" | ✅ Prête |
| ✅ Prête | Bouton "Livrée" | 📦 Livrée |
| Toute commande | Bouton "Annuler" | ❌ Annulée |

## 🔍 Filtres

### Statut
- En attente
- En préparation
- Prête
- Livrée
- Annulée

### Période
- Aujourd'hui
- Cette semaine
- Ce mois

### Recherche
- N° commande
- Nom client
- Téléphone

## 📥 Export CSV

1. Appliquez les filtres souhaités (optionnel)
2. Cliquez sur l'icône de téléchargement
3. Le fichier `commandes_YYYY-MM-DD_HH-mm.csv` est téléchargé

Colonnes exportées :
- N° Commande, Date, Heure
- Client, Téléphone, Email
- Statut, Produits, Quantité, Total
- Commentaire, Date retrait, Créneau

## 🎮 Commandes Clavier

| Touche | Action |
|--------|--------|
| `F5` | Rafraîchir |
| `Esc` | Fermer le détail |
| `Ctrl+F` | Focus recherche |

## 💡 Astuces

### Créer une vraie commande
1. Passez en mode client (bottom navigation)
2. Ajoutez des pizzas au panier
3. Allez au checkout
4. Sélectionnez date + créneau
5. Confirmez
6. → La commande apparaît instantanément dans l'admin !

### Tester les notifications
1. Créez une commande depuis le client
2. La notification popup apparaît dans l'admin
3. Badge rouge sur "Commandes" dans le dashboard
4. Cliquez sur la notification ou la commande pour la marquer comme vue

### Mode responsive
- **Desktop** : Vue split (liste + détail côte à côte en paysage)
- **Tablette** : Vue overlay (détail en plein écran)
- **Toggle automatique** selon l'orientation

## 🐛 Problèmes courants

**Aucune commande affichée ?**
→ Cliquez sur "Test Data" ou créez-en via le checkout client

**Notification ne s'affiche pas ?**
→ Vérifiez que la commande est bien "non vue" (bordure rouge)

**Export CSV ne fonctionne pas ?**
→ Fonctionne uniquement sur navigateur web (pas mobile actuellement)

**Le son ne joue pas ?**
→ Fichier audio à ajouter dans `assets/sounds/notification.mp3`

## 📚 Documentation complète

Voir `ORDER_MANAGEMENT_GUIDE.md` pour :
- Architecture technique détaillée
- Flux de données
- Personnalisation
- Améliorations futures

## ⚡ Checklist de test

- [ ] Générer des données de test
- [ ] Basculer entre vue table et cartes
- [ ] Rechercher une commande par nom
- [ ] Filtrer par statut "En attente"
- [ ] Filtrer par période "Aujourd'hui"
- [ ] Cliquer sur une commande pour voir le détail
- [ ] Changer le statut d'une commande
- [ ] Annuler une commande (avec confirmation)
- [ ] Créer une commande réelle depuis le checkout
- [ ] Vérifier que la notification apparaît
- [ ] Exporter les commandes en CSV
- [ ] Tester en mode tablette/mobile

## 🎉 Fonctionnalités bonus

- Historique complet des changements de statut
- Informations client complètes
- Commentaires clients affichés
- Total calculé automatiquement
- Images des produits dans le détail
- Animations fluides et professionnelles
- Design cohérent avec le thème Pizza Deli'Zza

---

**Besoin d'aide ?** Consultez `ORDER_MANAGEMENT_GUIDE.md`
