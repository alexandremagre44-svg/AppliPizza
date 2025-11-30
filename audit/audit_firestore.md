# Audit Technique - Firestore

## Vue d'ensemble de la structure Firestore

Ce document liste tous les chemins Firestore utilisés dans le projet.

---

## 1. Structure principale

```
restaurants/
└── {appId}/                              # ID restaurant (ex: 'delizza')
    ├── pages_system/                     # ⚠️ DEPRECATED - pages système legacy
    │   └── {pageId}                      # home, menu, cart, etc.
    │
    ├── pages_draft/                      # ✅ Brouillons de pages
    │   └── {pageKey}                     # Identifiant de page
    │
    ├── pages_published/                  # ✅ Pages publiées (source de vérité)
    │   └── {pageKey}                     # Identifiant de page
    │
    ├── builder_pages/                    # Métadonnées pages (legacy?)
    │   └── {pageId}
    │
    ├── builder_blocks/                   # Templates de blocs (legacy?)
    │   └── {blockId}
    │
    ├── builder_settings/                 # Paramètres globaux
    │   ├── home_config                   # Config page d'accueil (legacy)
    │   ├── theme                         # Configuration du thème
    │   ├── app_texts                     # Textes personnalisables
    │   ├── loyalty_settings              # Paramètres fidélité
    │   ├── meta                          # Métadonnées (flags auto-init)
    │   ├── banners/items/                # Bannières
    │   ├── popups/items/                 # Popups
    │   └── promotions/items/             # Promotions
    │
    ├── orders/                           # Commandes
    │   └── {orderId}
    │
    ├── user_profiles/                    # Profils utilisateurs
    │   └── {userId}
    │
    └── order_rate_limit/                 # Rate limiting commandes
        └── {userId}
```

---

## 2. Chemins définis dans `FirestorePaths`

**Fichier:** `lib/src/core/firestore_paths.dart`

### Collections principales

| Méthode | Chemin | Usage |
|---------|--------|-------|
| `restaurantDoc(appId)` | `restaurants/{appId}` | Document racine restaurant |
| `pagesSystem(appId)` | `restaurants/{appId}/pages_system` | Pages système (⚠️ deprecated) |
| `pagesDraft(appId)` | `restaurants/{appId}/pages_draft` | Brouillons |
| `pagesPublished(appId)` | `restaurants/{appId}/pages_published` | Pages publiées |
| `builderPages(appId)` | `restaurants/{appId}/builder_pages` | Métadonnées pages |
| `builderBlocks(appId)` | `restaurants/{appId}/builder_blocks` | Templates blocs |
| `builderSettings(appId)` | `restaurants/{appId}/builder_settings` | Paramètres |
| `orders(appId)` | `restaurants/{appId}/orders` | Commandes |
| `userProfiles(appId)` | `restaurants/{appId}/user_profiles` | Profils |
| `orderRateLimit(appId)` | `restaurants/{appId}/order_rate_limit` | Rate limit |

### Documents spécifiques

| Méthode | Chemin | Usage |
|---------|--------|-------|
| `systemPageDoc(docId, appId)` | `.../pages_system/{docId}` | Page système |
| `draftDoc(docId, appId)` | `.../pages_draft/{docId}` | Brouillon |
| `publishedDoc(docId, appId)` | `.../pages_published/{docId}` | Page publiée |
| `settingsDoc(docId, appId)` | `.../builder_settings/{docId}` | Document settings |
| `homeConfigDoc(appId)` | `.../builder_settings/home_config` | Config accueil |
| `themeDoc(appId)` | `.../builder_settings/theme` | Thème |
| `appTextsDoc(appId)` | `.../builder_settings/app_texts` | Textes |
| `loyaltySettingsDoc(appId)` | `.../builder_settings/loyalty_settings` | Fidélité |
| `metaDoc(appId)` | `.../builder_settings/meta` | Métadonnées |

### Sous-collections

| Méthode | Chemin | Usage |
|---------|--------|-------|
| `banners(appId)` | `.../builder_settings/banners/items` | Bannières |
| `popups(appId)` | `.../builder_settings/popups/items` | Popups |
| `promotions(appId)` | `.../builder_settings/promotions/items` | Promos |

---

## 3. Services et leurs opérations Firestore

### BuilderLayoutService
**Fichier:** `lib/builder/services/builder_layout_service.dart`

| Opération | Type | Chemin |
|-----------|------|--------|
| `saveDraft()` | WRITE | `pages_draft/{pageKey}` |
| `loadDraft()` | READ | `pages_draft/{pageKey}` |
| `watchDraft()` | STREAM | `pages_draft/{pageKey}` |
| `deleteDraft()` | DELETE | `pages_draft/{pageKey}` |
| `hasDraft()` | READ | `pages_draft/{pageKey}` |
| `publishPage()` | WRITE | `pages_published/{pageKey}` |
| `loadPublished()` | READ | `pages_published/{pageKey}` |
| `watchPublished()` | STREAM | `pages_published/{pageKey}` |
| `deletePublished()` | DELETE | `pages_published/{pageKey}` |
| `hasPublished()` | READ | `pages_published/{pageKey}` |
| `loadAllPublishedPages()` | READ | `pages_published/*` |
| `loadAllDraftPages()` | READ | `pages_draft/*` |
| `loadSystemPages()` | READ | `pages_published/*` (filtré) |
| `loadSystemPage()` | READ | `pages_system/{pageId}` (⚠️ deprecated) |
| `watchSystemPages()` | STREAM | `pages_system/*` (⚠️ deprecated) |
| `getBottomBarPages()` | READ | `pages_published/*` (filtré) |

### BuilderPageService
**Fichier:** `lib/builder/services/builder_page_service.dart`

| Opération | Type | Chemin |
|-----------|------|--------|
| `loadDraft()` | READ | via BuilderLayoutService |
| `saveDraft()` | WRITE | via BuilderLayoutService |
| `publishPage()` | WRITE | via BuilderLayoutService |
| `updatePageNavigation()` | WRITE | pages_draft + pages_published |

### DynamicPageResolver
**Fichier:** `lib/builder/services/dynamic_page_resolver.dart`

| Opération | Type | Chemin |
|-----------|------|--------|
| `resolve()` | READ | `pages_published/{pageKey}` |

---

## 4. Workflow Draft/Published

```
┌─────────────────┐     saveDraft()      ┌─────────────────┐
│  Editor Screen  │ ──────────────────► │   pages_draft   │
│                 │                      │   /{pageKey}    │
└─────────────────┘                      └─────────────────┘
                                                  │
                                         publishPage()
                                                  │
                                                  ▼
┌─────────────────┐     loadPublished()  ┌─────────────────┐
│  Runtime Client │ ◄─────────────────── │ pages_published │
│                 │                      │   /{pageKey}    │
└─────────────────┘                      └─────────────────┘
```

---

## 5. Collections obsolètes / en migration

### ⚠️ pages_system
- **Statut:** DEPRECATED
- **Raison:** Remplacé par pages_published avec isSystemPage=true
- **Migration:** Les méthodes sont marquées @Deprecated
- **Impact:** Encore utilisé par quelques services legacy

### ⚠️ builder_pages
- **Statut:** Utilisé pour métadonnées
- **Contenu:** Historique des pages créées

### ⚠️ builder_blocks
- **Statut:** Utilisé pour templates
- **Contenu:** Blocs réutilisables

### ⚠️ home_config (builder_settings)
- **Statut:** Legacy
- **Raison:** Remplacé par BuilderPage home
- **Migration:** En cours

---

## 6. Détection de conflits potentiels

### Lecture multiple du même contenu
1. **pages_published** ← Source de vérité pour runtime
2. **pages_system** ← Legacy, peut contenir données obsolètes
3. **builder_settings/home_config** ← Legacy home config

### Recommandations
1. ✅ Utiliser `pages_published` comme source unique pour le runtime
2. ✅ Utiliser `pages_draft` pour l'édition
3. ⚠️ Migrer les données de `pages_system` vers `pages_published`
4. ⚠️ Déprécier complètement `home_config` au profit de `pages_published/home`

---

## 7. Sécurité et règles Firestore

### Accès typique par collection

| Collection | Lecture | Écriture | Conditions |
|------------|---------|----------|------------|
| pages_draft | Admin | Admin | Authentifié + rôle admin |
| pages_published | Tous | Admin | Lecture publique |
| builder_settings | Tous | Admin | Lecture publique |
| orders | User | User | Propriétaire de la commande |
| user_profiles | User | User | Propriétaire du profil |

---

*Document généré automatiquement - Audit technique AppliPizza*
