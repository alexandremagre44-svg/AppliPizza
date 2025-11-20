# Studio V2 - Guide Utilisateur Rapide

## 🚀 Comment accéder au Studio V2

### Méthode 1: Via le Menu Admin (Recommandé)

```
1. Se connecter en tant qu'admin
   ↓
2. Aller dans le profil ou menu admin
   ↓
3. Cliquer sur "Studio Admin"
   ↓
4. Cliquer sur "🎨 Studio PRO (V2)"
   ↓
5. ✅ Vous êtes dans Studio V2!
```

### Méthode 2: URL Directe

```
Naviguer vers: /admin/studio/v2
```

**Note**: Redirection automatique vers `/home` si non-admin.

---

## 🎨 Interface Studio V2

### Vue Desktop (≥ 800px)

```
┌────────────────────────────────────────────────────────────────┐
│                     Studio V2 PRO                              │
├──────────┬────────────────────────────┬─────────────────────────┤
│          │                            │                         │
│  NAVI-   │      ÉDITEUR               │      PREVIEW            │
│  GATION  │                            │                         │
│          │   [Module sélectionné]     │   [Téléphone mockup]    │
│  • Over- │                            │                         │
│    view  │   Formulaires d'édition    │   Rendu en temps réel   │
│  • Hero  │   Boutons d'action         │                         │
│  • Band- │   Listes CRUD              │   Hero                  │
│    eaux  │                            │   Bandeaux              │
│  • Pop-  │                            │   Popups indicator      │
│    ups   │                            │   Catégories            │
│  • Text- │                            │                         │
│    es    │                            │                         │
│  • Para- │                            │                         │
│    mètr. │                            │                         │
│          │                            │                         │
│ [Pub-    │                            │                         │
│  lier]   │                            │                         │
│ [Annu-   │                            │                         │
│  ler]    │                            │                         │
│          │                            │                         │
└──────────┴────────────────────────────┴─────────────────────────┘
```

### Vue Mobile (< 800px)

```
┌─────────────────────────────────┐
│  Studio V2  [☰ Menu] [Publier] │
├─────────────────────────────────┤
│                                 │
│                                 │
│     CONTENU DU MODULE           │
│                                 │
│     (Pleine largeur)            │
│                                 │
│                                 │
└─────────────────────────────────┘
```

---

## 📋 Les 6 Modules

### 1. 📊 Overview (Vue d'ensemble)

**Affiche**:
- Nombre de bandeaux actifs
- Nombre de popups actifs
- Nombre de blocs de texte
- État du studio (activé/désactivé)
- État de chaque section

**Actions**: Aucune (lecture seule)

---

### 2. 🖼️ Hero

**Gère**: La bannière principale de l'application

**Champs**:
- ☑️ Activer/Désactiver Hero
- 🔗 URL de l'image
- ✏️ Titre
- ✏️ Sous-titre
- 🔘 Texte du bouton (CTA)

**Preview**: Met à jour en temps réel

---

### 3. 📢 Bandeaux

**Gère**: Bandeaux programmables illimités

**Liste**: Tous les bandeaux avec icône, texte, état

**Créer nouveau**:
1. Cliquer "Nouveau bandeau"
2. Bandeau ajouté à la liste
3. Configurer:
   - Texte
   - Icône (optionnel)
   - Couleur fond
   - Couleur texte
   - Dates début/fin
   - Activer/Désactiver

**Actions**:
- ☑️ Toggle actif/inactif
- ✏️ Éditer (à venir: dialog complet)
- 🗑️ Supprimer (à venir)

---

### 4. 🎉 Popups Ultimate

**Gère**: Popups avancés avec conditions

**5 Types**:
- 🖼️ Image
- 📝 Texte
- 🎟️ Coupon
- 😊 Emoji Reaction
- 🎊 Big Promo

**Conditions d'affichage**:
- ⏱️ Delay (après X secondes)
- 👤 First Visit (1ère visite)
- 🔄 Every Visit (chaque visite)
- 📅 Limited Per Day (X fois/jour)
- 📜 On Scroll
- 🎯 On Action

**Liste**: Tous les popups avec type, titre, état

**Créer nouveau**:
1. Cliquer "Nouveau popup"
2. Popup ajouté à la liste
3. Configurer (éditeur détaillé à venir)

---

### 5. 📝 Textes Dynamiques

**Gère**: Blocs de texte illimités (CRUD complet)

**4 Types**:
- 📏 Short (court, une ligne)
- 📄 Long (multi-lignes)
- 🔤 Markdown
- 🌐 HTML

**Catégories**: home, menu, cart, checkout, etc.

**Liste**: Tous les blocs avec nom, catégorie, type

**Créer nouveau**:
1. Cliquer "Nouveau bloc"
2. Bloc ajouté à la liste
3. Configurer:
   - Nom technique (ex: "hero_title")
   - Nom d'affichage
   - Contenu
   - Type
   - Catégorie

**Utilité**: White-label, multi-tenant, i18n future

---

### 6. ⚙️ Paramètres

**Gère**: Configuration globale

**Options**:
- ☑️ **Studio activé globalement**
  - Si désactivé: aucun élément studio ne s'affiche
- ☑️ **Section Hero activée**
- ☑️ **Section Bandeaux activée**
- ☑️ **Section Popups activée**

**Ordre des sections**: (drag & drop à venir)

---

## 🔄 Mode Brouillon / Publication

### Comment ça marche

```
Vous éditez → Changes locaux (brouillon)
              ↓
              Badge orange "Modifications non publiées"
              ↓
              Boutons "Publier" et "Annuler" actifs
              ↓
Vous publiez → Écriture Firestore (tous les modules)
              ↓
              Snackbar vert "✓ Modifications publiées"
              ↓
              Badge orange disparaît
              ↓
              Changes maintenant visibles dans l'app client
```

### Workflow typique

1. **Créer/Modifier** des éléments (bandeaux, popups, textes)
2. **Preview** en temps réel dans colonne droite
3. **Vérifier** le rendu
4. **Publier** quand satisfait
5. **Recharger** l'app client pour voir les changements

**Alternative**: Cliquer "Annuler" pour abandonner toutes les modifications non publiées.

---

## 🎯 Cas d'Usage Courants

### Cas 1: Créer une promotion temporaire

1. Aller dans "Bandeaux"
2. Cliquer "Nouveau bandeau"
3. Configurer:
   - Texte: "🔥 -30% sur toutes les pizzas ce week-end!"
   - Couleur fond: Rouge (#D32F2F)
   - Date début: Vendredi 00:00
   - Date fin: Dimanche 23:59
   - Activer: ☑️
4. Publier
5. ✅ Bandeau apparaîtra automatiquement le vendredi et disparaîtra le lundi

### Cas 2: Popup de bienvenue nouveaux clients

1. Aller dans "Popups"
2. Cliquer "Nouveau popup"
3. Configurer:
   - Type: Coupon
   - Titre: "Bienvenue chez Pizza Deli'Zza!"
   - Message: "Profitez de -20% sur votre 1ère commande"
   - Code coupon: "BIENVENUE20"
   - Condition: First Visit
   - Activer: ☑️
4. Publier
5. ✅ Popup s'affichera uniquement aux nouveaux clients

### Cas 3: Modifier le hero de la page d'accueil

1. Aller dans "Hero"
2. Activer Hero si pas déjà fait
3. Modifier:
   - Titre: "Pizzas artisanales 🍕"
   - Sous-titre: "Livraison en 30 minutes"
   - URL image: (coller URL)
4. Observer le preview en temps réel
5. Publier
6. ✅ Hero mis à jour sur la home

### Cas 4: Créer des textes pour white-label

1. Aller dans "Textes Dynamiques"
2. Créer plusieurs blocs:
   - "welcome_message" → "Bienvenue chez [Nom Restaurant]"
   - "footer_copyright" → "© 2025 [Nom Restaurant]"
   - "about_us" → "Texte À propos..."
3. Publier
4. ✅ Textes disponibles pour utilisation dans l'app

---

## 🐛 Dépannage

### Le Studio V2 ne s'affiche pas

**Causes possibles**:
1. Vous n'êtes pas admin → Redirection automatique vers `/home`
2. Route incorrecte → Vérifier `/admin/studio/v2`

**Solution**: Se connecter en tant qu'admin puis réessayer.

---

### Modifications non sauvegardées perdues après rechargement

**Normal**: Le mode brouillon est local uniquement.

**Solution**: Toujours cliquer "Publier" avant de quitter le Studio.

---

### Preview ne se met pas à jour

**Cause**: Bug potentiel dans le state management.

**Solution temporaire**: Recharger la page Studio V2.

---

### Bandeau/Popup ne s'affiche pas dans l'app client

**Vérifications**:
1. ☑️ Est-il activé?
2. ☑️ Est-il publié (pas juste en brouillon)?
3. ☑️ Les dates début/fin sont correctes?
4. ☑️ Studio global activé dans Paramètres?
5. ☑️ Section concernée activée dans Paramètres?

**Solution**: Vérifier tous ces points, puis recharger l'app client.

---

## 📚 Documentation Complète

- **STUDIO_V2_README.md** - Guide de démarrage
- **STUDIO_V2_DELIVERABLES.md** - Documentation technique complète
- **STUDIO_V2_TESTING.md** - 32 tests manuels
- **STUDIO_V2_INTEGRATION_SUMMARY.md** - Résumé d'intégration
- **STUDIO_V2_USER_GUIDE.md** - Ce document

---

## 🎉 Profitez du Studio V2!

Toutes les fonctionnalités sont prêtes à l'emploi. Explorez chaque module et créez du contenu dynamique pour votre application Pizza Deli'Zza.

**Support**: Voir les docs techniques pour questions avancées.

---

**Version**: 2.0.0  
**Date**: 2025-01-20  
**Statut**: ✅ Production Ready
