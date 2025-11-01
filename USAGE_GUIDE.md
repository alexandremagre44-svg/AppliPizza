# Guide d'Utilisation - Fonctionnalités Admin

## 🔐 Connexion Admin

Pour accéder aux fonctionnalités admin:
- **Email:** `admin@delizza.com`
- **Mot de passe:** `admin123`

Une fois connecté, un onglet "Admin" apparaît dans la barre de navigation en bas de l'écran.

---

## 📱 Navigation

### Depuis l'écran d'accueil
1. Cliquez sur l'onglet "Admin" dans la barre de navigation (5ème icône)
2. Vous arrivez sur le **Dashboard Admin** avec 8 sections

### Dashboard Admin - Sections Disponibles

```
┌─────────────────┬─────────────────┐
│   🛒 Commandes  │   🍕 Pizzas     │
│   (Rouge)       │   (Orange)      │
├─────────────────┼─────────────────┤
│   📋 Menus      │   👥 Utilisat.  │
│   (Bleu)        │   (Violet)      │
├─────────────────┼─────────────────┤
│   🕐 Horaires   │   ⚙️ Paramètres │
│   (Vert)        │   (Gris)        │
├─────────────────┼─────────────────┤
│   🎁 Promotions │   📊 Statistiques│
│   (Rose)        │   (Teal)        │
└─────────────────┴─────────────────┘
```

---

## 🛒 Gestion des Commandes

### Voir les commandes
1. Tapez sur "Commandes" dans le dashboard
2. Toutes les commandes s'affichent avec:
   - Numéro de commande
   - Date et heure
   - Statut (avec couleur)
   - Montant total
   - Nombre d'articles

### Filtrer les commandes
- **Par statut:** Menu déroulant en haut (Tous, En préparation, En livraison, Livrée)
- **Par date:** Bouton "Date" → Sélectionner une plage de dates
- **Effacer filtre date:** Icône ❌ à droite du bouton

### Changer le statut d'une commande
1. Tapez sur une commande pour voir les détails
2. Descendez en bas de la carte
3. Tapez sur le bouton du nouveau statut désiré:
   - "En préparation" (Orange)
   - "En livraison" (Bleu)
   - "Livrée" (Vert)

### Voir les statistiques
1. Tapez sur l'icône 📊 en haut à droite
2. Modal avec:
   - Commandes totales
   - Revenu total
   - Panier moyen
   - Commandes aujourd'hui
   - Revenu aujourd'hui

---

## 👥 Gestion des Utilisateurs

### Voir les utilisateurs
- Liste de tous les utilisateurs avec:
  - Nom et email
  - Rôle (Admin/Client)
  - Badge "BLOQUÉ" si applicable
  - Avatar avec icône selon le rôle

### Créer un nouvel utilisateur
1. Tapez sur le bouton ➕ (en bas à droite)
2. Remplissez:
   - Nom
   - Email
   - Mot de passe (minimum 6 caractères)
   - Rôle (Client ou Administrateur)
3. Tapez "Sauvegarder"

### Modifier un utilisateur
1. Tapez sur ⋮ (menu) à droite de l'utilisateur
2. Sélectionnez "Modifier"
3. Changez les informations nécessaires
4. "Sauvegarder"

### Bloquer/Débloquer un utilisateur
1. Tapez sur ⋮ (menu)
2. Sélectionnez "Bloquer" ou "Débloquer"

### Voir les détails d'un utilisateur
1. Tapez sur ⋮ (menu)
2. Sélectionnez "Voir détails"
3. Affiche: Email, rôle, statut, date de création, historique

### Supprimer un utilisateur
1. Tapez sur ⋮ (menu)
2. Sélectionnez "Supprimer"
3. Confirmez la suppression

---

## 🕐 Gestion des Horaires

### Modifier les horaires d'un jour
1. Tapez sur l'icône ✏️ à droite du jour
2. Options:
   - Cochez "Fermé" pour marquer le jour comme fermé
   - Sinon, tapez sur les heures pour les modifier
   - Sélectionnez l'heure d'ouverture
   - Sélectionnez l'heure de fermeture
3. "Sauvegarder"

### Ajouter une fermeture exceptionnelle
1. Tapez sur l'icône ➕ en haut à droite de "Fermetures exceptionnelles"
2. Sélectionnez une date dans le calendrier
3. Entrez la raison de la fermeture
4. "Ajouter"

### Supprimer une fermeture exceptionnelle
- Tapez sur l'icône 🗑️ à droite de la fermeture

---

## ⚙️ Paramètres

1. Tapez sur "Paramètres" dans le dashboard
2. Modifiez les valeurs:
   - **Frais de livraison (€):** Montant fixe par livraison
   - **Montant minimum (€):** Commande minimale requise
   - **Temps de livraison (min):** Estimation en minutes
   - **Zone de livraison:** Description textuelle
3. "Sauvegarder les paramètres"

---

## 🎁 Gestion des Promotions

### Créer un code promo
1. Tapez sur le bouton ➕ (en bas à droite)
2. Remplissez:
   - **Code:** Ex: "BIENVENUE10" (obligatoire)
   - **Réduction (%):** Ex: 10 pour 10%
   - **OU Réduction fixe (€):** Ex: 5 pour 5€ de réduction
   - **Limite d'utilisation:** Nombre max d'utilisations (optionnel)
   - **Date d'expiration:** Tapez sur la date pour sélectionner (optionnel)
   - **Actif:** Cochez pour activer le code
3. "Sauvegarder"

### Modifier un code promo
1. Tapez sur l'icône ✏️ à droite du code
2. Modifiez les informations
3. "Sauvegarder"

### Désactiver un code promo
1. Tapez sur ✏️
2. Décochez "Actif"
3. "Sauvegarder"

### Supprimer un code promo
1. Tapez sur l'icône 🗑️ à droite du code
2. Confirmez la suppression

### Indicateurs visuels
- 🟢 Vert = Code valide et actif
- 🔴 "EXPIRÉ" = Code expiré ou limite atteinte
- Compteur d'utilisations affiché sous chaque code

---

## 📊 Statistiques

### Vue d'ensemble
Cartes affichant:
- **Commandes totales:** Nombre total depuis le début
- **Revenu total:** Montant cumulé en euros
- **Panier moyen:** Valeur moyenne par commande
- **Aujourd'hui:** Nombre de commandes du jour

### Produits les plus vendus
Liste des 10 produits les plus commandés avec:
- Nom du produit
- Badge avec quantité totale vendue
- Icône pizza

### Actualiser les données
- Tirez vers le bas (pull-to-refresh) pour recharger

---

## 🍕 Gestion des Pizzas

### Créer une pizza
1. Tapez sur ➕
2. Remplissez:
   - Nom
   - Description
   - Prix (€)
   - URL de l'image (optionnel)
3. "Sauvegarder"

### Modifier/Supprimer
- ✏️ pour modifier
- 🗑️ pour supprimer

---

## 📋 Gestion des Menus

### Créer un menu
1. Tapez sur ➕
2. Remplissez:
   - Nom
   - Description
   - **Composition:** Nombre de pizzas et boissons
   - Prix (€)
   - URL de l'image (optionnel)
3. "Sauvegarder"

### Composer un menu
- Utilisez ➖/➕ pour ajuster le nombre de pizzas (0-5)
- Utilisez ➖/➕ pour ajuster le nombre de boissons (0-5)

---

## 💡 Astuces

1. **Pull-to-refresh:** Tirez vers le bas sur les listes pour actualiser
2. **Filtres:** Combinez les filtres de statut et de date pour trouver des commandes spécifiques
3. **Validation:** Tous les formulaires ont une validation en temps réel
4. **Confirmations:** Les suppressions demandent toujours confirmation
5. **États vides:** Des messages informatifs s'affichent quand les listes sont vides
6. **Loading:** Des indicateurs de chargement apparaissent pendant les opérations

---

## 🔄 Flux de Travail Typique

### Gestion quotidienne des commandes
1. Ouvrir "Statistiques" → Voir les chiffres du jour
2. Ouvrir "Commandes" → Filtrer par "En préparation"
3. Préparer les commandes → Changer statut à "En livraison"
4. Une fois livrées → Changer statut à "Livrée"

### Gestion hebdomadaire
1. Vérifier les "Statistiques" → Identifier les produits populaires
2. Ajuster le stock de pizzas si nécessaire
3. Créer des "Promotions" pour les produits moins vendus
4. Vérifier les "Horaires" pour la semaine suivante

### Gestion mensuelle
1. Analyser les "Statistiques" sur 30 jours
2. Créer de nouveaux "Menus" selon les tendances
3. Mettre à jour les "Paramètres" si nécessaire
4. Gérer les "Utilisateurs" (créer admins, bloquer si besoin)

---

## ⚠️ Important

- Les données sont sauvegardées localement (SharedPreferences)
- Les modifications sont immédiates et permanentes
- Pas de connexion internet requise
- Seuls les admins peuvent accéder à ces fonctionnalités
- Le badge "ADMIN" est visible sur le profil des administrateurs

---

## 📞 Identifiants de Test

### Admin
- Email: `admin@delizza.com`
- Mot de passe: `admin123`

### Client
- Email: `client@delizza.com`
- Mot de passe: `client123`

---

**Note:** Ce guide couvre toutes les fonctionnalités admin implémentées. Pour des détails techniques, consultez `ADMIN_FEATURES.md`.
