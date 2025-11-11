# 🎨 Guide du Page Builder - Pizza Deli'Zza

## 📋 Vue d'ensemble

Le **Page Builder** est un outil d'administration qui vous permet de mettre en avant vos produits préférés sur la page d'accueil de l'application. Les produits marqués comme "featured" apparaîtront dans une section premium appelée **"⭐ Sélection du Chef"**.

## 🚀 Comment utiliser le Page Builder

### 1. Accès au Page Builder

1. Connectez-vous en tant qu'administrateur
2. Accédez au **Dashboard Admin**
3. Cliquez sur la carte **"Page Builder"** (icône verte avec dashboard_customize)

### 2. Mettre un produit en avant

Le Page Builder est organisé en **4 onglets** :
- 🍕 **Pizzas**
- 🍽️ **Menus**
- 🥤 **Boissons**
- 🍰 **Desserts**

Pour mettre un produit en avant :

1. Sélectionnez l'onglet correspondant à votre produit
2. Trouvez le produit que vous souhaitez mettre en avant
3. **Cliquez sur l'étoile** à droite du produit
4. Une notification confirmera : *"[Produit] mis en avant ! Apparaîtra dans 'Sélection du Chef' sur l'accueil"*

### 3. Retirer un produit de la mise en avant

1. Les produits mis en avant apparaissent **en haut de la liste** avec une étoile pleine (⭐)
2. Cliquez à nouveau sur l'étoile du produit
3. Le produit sera retiré de la section "Sélection du Chef"

## 📊 Suivi de vos produits featured

### Compteur par catégorie
Chaque onglet affiche un **badge doré** indiquant le nombre de produits mis en avant dans cette catégorie :
- Exemple : "⭐ 3 produits mis en avant"

### Tri automatique
Les produits mis en avant sont automatiquement **triés en haut** de chaque liste pour faciliter leur gestion.

## 🌟 Affichage sur la page d'accueil

### Section "⭐ Sélection du Chef"

Les produits marqués comme "featured" apparaissent dans une section spéciale sur l'accueil :

- **Position** : Juste après le message de bienvenue, **avant** les autres sections
- **Design premium** : 
  - Bordure dorée avec effet d'ombre ambrée
  - Badge "Coup de ❤️" sur chaque produit
  - Fond dégradé doré/orangé
- **Affichage** : Carousel horizontal (scroll horizontal)
- **Limite** : Maximum **5 produits** affichés dans cette section

### Comportement dynamique

- ✅ Si **aucun produit** n'est mis en avant : la section n'apparaît pas
- ✅ Si **1 à 5 produits** sont mis en avant : section affichée avec tous les produits
- ✅ Si **plus de 5 produits** sont mis en avant : seuls les 5 premiers sont affichés

## 💡 Bonnes pratiques

### Combien de produits mettre en avant ?

Recommandations :
- **Idéal** : 3 à 5 produits
- **Minimum** : 1 produit (pour avoir une section visible)
- **Maximum technique** : illimité, mais seuls 5 s'affichent sur l'accueil

### Quels produits choisir ?

Mettez en avant :
- ✨ Vos **nouveautés** du moment
- 🔥 Vos **meilleures ventes**
- 🎉 Produits en **promotion**
- 👨‍🍳 **Spécialités** du chef
- 🎯 Produits **saisonniers**

### Rotation régulière

Pour maintenir l'intérêt des clients :
- 🔄 Changez les produits featured **régulièrement** (ex: chaque semaine)
- 📊 Suivez les performances dans les statistiques
- 🎨 Variez les catégories (pizzas, menus, desserts...)

## 🎯 Cas d'usage

### Exemple 1 : Lancement d'une nouvelle pizza

```
1. Allez dans Page Builder → Pizzas
2. Trouvez votre nouvelle pizza "Truffe & Parmesan"
3. Cliquez sur l'étoile
4. La pizza apparaît maintenant en "Sélection du Chef" sur l'accueil
```

### Exemple 2 : Promotion sur les menus

```
1. Allez dans Page Builder → Menus
2. Mettez en avant 2-3 menus en promo
3. Les clients verront ces menus en premier sur l'accueil
4. Retirez-les de la mise en avant une fois la promo terminée
```

### Exemple 3 : Mise en avant mixte

```
1. 2 pizzas signature (onglet Pizzas)
2. 1 menu complet (onglet Menus)
3. 1 dessert maison (onglet Desserts)
4. Total : 4 produits variés dans "Sélection du Chef"
```

## 🔧 Fonctionnalités techniques

### Persistance des données

Les produits marqués comme "featured" sont :
- ✅ Sauvegardés dans le **stockage local** (SharedPreferences)
- ✅ Synchronisés avec **Firestore** (si configuré)
- ✅ Conservés entre les sessions

### Rafraîchissement

- L'accueil se rafraîchit automatiquement après modification dans le Page Builder
- Vous pouvez aussi tirer vers le bas sur l'accueil pour **rafraîchir manuellement**

## ❓ Questions fréquentes

### Q : Combien de temps faut-il pour voir les changements sur l'accueil ?
**R :** Les changements sont **immédiats**. Retournez simplement à l'accueil ou rafraîchissez la page.

### Q : Puis-je mettre en avant des produits de différentes catégories ?
**R :** Oui ! Vous pouvez mélanger pizzas, menus, boissons et desserts dans la "Sélection du Chef".

### Q : Que se passe-t-il si je mets en avant plus de 5 produits ?
**R :** Seuls les **5 premiers** apparaîtront sur l'accueil. Privilégiez la qualité à la quantité !

### Q : Les produits featured affectent-ils le reste de l'application ?
**R :** Non, ils apparaissent uniquement dans la section "Sélection du Chef" sur l'accueil. Les autres sections (Pizzas Populaires, Menus, etc.) ne sont pas affectées.

### Q : Comment savoir quels produits sont actuellement en featured ?
**R :** Ouvrez le Page Builder : les produits featured apparaissent en haut de chaque liste avec une étoile pleine (⭐) et le compteur vous indique le total.

## 📱 Interface utilisateur

### Dans le Page Builder (Admin)

```
┌─────────────────────────────────┐
│ 🌟 Page Builder                 │
│ ┌─── Tabs ───┐                  │
│ │ 🍕 Pizzas  │ 🍽️ Menus │       │
│ └────────────┘                  │
│                                 │
│ ℹ️ Activez l'étoile pour mettre │
│    un produit en avant          │
│ ⭐ 2 produits mis en avant      │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ ⭐ Pizza 4 Fromages     12€  │ │
│ │ Description...               │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ ☆ Pizza Margherita     10€  │ │
│ │ Description...               │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### Sur l'accueil (Client)

```
┌─────────────────────────────────┐
│ 🏠 Pizza Deli'Zza               │
│                                 │
│ 👋 Bienvenue !                  │
│                                 │
│ ⭐ Sélection du Chef    Voir ➜ │
│                                 │
│ ┌──────┐ ┌──────┐ ┌──────┐     │
│ │ ⭐   │ │ ⭐   │ │ ⭐   │ →   │
│ │Coup ❤│ │Coup ❤│ │Coup ❤│     │
│ │Pizza │ │Menu  │ │Pizza │     │
│ └──────┘ └──────┘ └──────┘     │
│                                 │
│ 🍕 Pizzas Populaires    Voir ➜ │
│ ...                             │
└─────────────────────────────────┘
```

## 🎨 Design & Couleurs

### Section "Sélection du Chef"
- **Bordure** : Doré (Amber 300)
- **Ombre** : Ambrée avec opacité 30%
- **Badge** : Gradient Amber 400 → Orange 600
- **Fond** : Dégradé Amber 50 → Orange 50

### Cohérence visuelle
Le design doré/ambré est choisi pour :
- ✨ Se démarquer du reste de l'interface
- 🌟 Évoquer la qualité et l'exclusivité
- 👁️ Attirer l'attention sans être intrusif

## 🔄 Workflow complet

```
Admin                           Client
  │                              │
  ├─► Ouvre Page Builder         │
  │                              │
  ├─► Clique sur ⭐              │
  │   (produit featured)         │
  │                              │
  ├─► ✅ Confirmation            │
  │   "Apparaîtra sur l'accueil" │
  │                              │
  └─────────────────────────────►├─► Ouvre l'accueil
                                 │
                                 ├─► Voit "⭐ Sélection du Chef"
                                 │
                                 ├─► Découvre les produits premium
                                 │
                                 └─► Ajoute au panier
```

## 📞 Support

Pour toute question ou problème :
1. Consultez ce guide
2. Vérifiez la section "Questions fréquentes"
3. Contactez le support technique

---

**Version** : 1.0  
**Dernière mise à jour** : Novembre 2025  
**Auteur** : Équipe Pizza Deli'Zza
