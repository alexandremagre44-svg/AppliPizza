# System Protection - Builder B3

## Vue d'ensemble

Ce document décrit les règles de protection appliquées aux pages système et aux SystemBlocks dans Builder B3. Ces protections garantissent l'intégrité du système et empêchent les modifications accidentelles qui pourraient casser l'application.

## Règles appliquées

### Pages système

Les pages système (`profile`, `cart`, `rewards`, `roulette`) bénéficient de protections spéciales :

| Protection | Comportement |
|------------|--------------|
| **Suppression** | ❌ Interdite |
| **Modification pageId** | ❌ Interdite |
| **displayLocation** | ⚠️ Limité à `bottomBar` ou `hidden` |
| **Modification des blocs** | ✅ Autorisée |
| **Réorganisation des blocs** | ✅ Autorisée |
| **Modification du titre** | ✅ Autorisée |
| **Modification de l'icône** | ✅ Autorisée |
| **Modification de l'ordre** | ✅ Autorisée (si `displayLocation = bottomBar`) |

### SystemBlocks

Les SystemBlocks (blocs de type `system`) sont protégés contre les modifications de configuration :

| Protection | Comportement |
|------------|--------------|
| **Modification du type** | ❌ Interdite (toujours `system`) |
| **Modification moduleType** | ❌ Interdite |
| **Configuration personnalisée** | ❌ Non disponible |
| **Suppression** | ✅ Autorisée |
| **Réorganisation** | ✅ Autorisée |
| **Duplication** | ⚠️ Conserve le type `system` |

## Comportements bloqués

### Dans l'éditeur (builder_page_editor_screen.dart)

1. **Pages système** :
   - Le bandeau "Page système protégée" s'affiche automatiquement
   - Pas de bouton de suppression de page
   - Le champ pageId est masqué ou désactivé
   - displayLocation limité aux valeurs valides

2. **SystemBlocks** :
   - Le panneau de configuration n'affiche aucun champ éditable
   - Message "Ce module système ne possède aucune configuration"
   - Affichage des restrictions avec icônes visuelles

### Dans la création de page (new_page_dialog.dart)

- Validation empêchant la création avec un ID réservé
- Message d'erreur : "Cet identifiant est réservé aux pages système"
- IDs bloqués : `profile`, `cart`, `rewards`, `roulette`

### Dans Firestore (builder_layout_service.dart)

1. **Correction automatique** :
   - Si `isSystemPage` est manquant sur une page système → corrigé à `true`
   - Si `displayLocation` est invalide sur une page système → corrigé à `hidden`

2. **Protection des données** :
   - Les SystemBlocks conservent toujours `type = system`
   - Les pages système conservent leur `pageId` original

## Comportements autorisés

### Pour les pages système

✅ Actions autorisées :
- Ajouter des blocs (normaux ou SystemBlocks)
- Supprimer des blocs
- Réorganiser les blocs (drag & drop)
- Modifier le contenu des blocs
- Changer le titre de la page
- Changer l'icône de la page
- Changer l'ordre dans la navigation
- Publier/dépublier la page

### Pour les SystemBlocks

✅ Actions autorisées :
- Supprimer le bloc
- Réorganiser le bloc dans la page
- Dupliquer le bloc (conserve le type system)

## Fallbacks utilisés

### Runtime (builder_runtime_renderer.dart)

| Situation | Fallback |
|-----------|----------|
| Module type inconnu | Widget "Module système introuvable" (jaune/ambre) |
| Exception dans un module | Widget "Erreur de rendu" (rouge) avec message debug |
| Bloc système sans moduleType | Widget "Module système introuvable" |

### Preview (system_block_preview.dart)

| Situation | Fallback |
|-----------|----------|
| Module type inconnu | Affiche "[Module système inconnu]" |
| Mode debug | Bordure bleue autour du bloc |

### Chargement de page

| Situation | Comportement |
|-----------|--------------|
| `isSystemPage` manquant | Corrigé automatiquement à `true` + warning console |
| `displayLocation` invalide | Corrigé automatiquement à `hidden` + warning console |
| `icon` manquant | Icône par défaut appliquée selon le type de page |

## Tableau des pages système

| Page ID | Titre par défaut | Route | Icône par défaut | displayLocation valides |
|---------|------------------|-------|------------------|------------------------|
| `profile` | Profil | `/profile` | `person` | `bottomBar`, `hidden` |
| `cart` | Panier | `/cart` | `shopping_cart` | `bottomBar`, `hidden` |
| `rewards` | Récompenses | `/rewards` | `card_giftcard` | `bottomBar`, `hidden` |
| `roulette` | Roulette | `/roulette` | `casino` | `bottomBar`, `hidden` |

## Tableau des actions possibles

### Pages système

| Action | Autorisée | Notes |
|--------|-----------|-------|
| Créer manuellement | ❌ | Création automatique uniquement |
| Supprimer | ❌ | Protection permanente |
| Modifier pageId | ❌ | Fixé à la création |
| Modifier name | ✅ | - |
| Modifier icon | ✅ | - |
| Modifier order | ✅ | Si displayLocation = bottomBar |
| Modifier displayLocation | ⚠️ | Limité à bottomBar/hidden |
| Ajouter blocs | ✅ | - |
| Modifier blocs | ✅ | - |
| Supprimer blocs | ✅ | - |
| Réorganiser blocs | ✅ | - |
| Publier | ✅ | - |

### SystemBlocks

| Action | Autorisée | Notes |
|--------|-----------|-------|
| Ajouter à une page | ✅ | Via "Modules système" |
| Supprimer | ✅ | - |
| Réorganiser | ✅ | - |
| Dupliquer | ✅ | Conserve type = system |
| Modifier type | ❌ | Toujours system |
| Modifier moduleType | ❌ | Fixé à la création |
| Ajouter config | ❌ | Non supporté |

## Indicateurs visuels

### Bandeau de protection (pages système)

```
┌──────────────────────────────────────────────────┐
│ 🛡️ Page système protégée                      ℹ️ │
│                                                  │
│ 🚫 Suppression  🚫 ID  ✅ Blocs  ✅ Ordre        │
└──────────────────────────────────────────────────┘
```

### Panneau de configuration (SystemBlocks)

```
┌──────────────────────────────────────────────────┐
│ 🎰  [Module: Roulette]                           │
│      Type: roulette                              │
│                                                  │
│ 🔒 Module système protégé                        │
│                                                  │
│ ℹ️ Ce module système ne possède aucune           │
│    configuration.                                │
│                                                  │
│ Restrictions:                                    │
│ 🚫 Pas de configuration personnalisée            │
│ 🚫 Type de bloc non modifiable                   │
│ ✅ Suppression autorisée                         │
│ ✅ Réorganisation autorisée                      │
└──────────────────────────────────────────────────┘
```

## Journalisation

### Messages de debug

Les protections génèrent des warnings dans la console debug :

```
⚠️ Warning: Correcting isSystemPage for system page profile
⚠️ Warning: Correcting displayLocation for system page cart
⚠️ Warning: Unknown module type "invalid" in SystemBlock
✅ Auto-correcting system page rewards
```

### Niveau de journalisation

| Type | Niveau | Quand |
|------|--------|-------|
| Correction automatique | DEBUG | `isSystemPage` ou `displayLocation` corrigé |
| Module inconnu | DEBUG | Type de module non reconnu |
| Erreur de rendu | DEBUG | Exception dans un widget système |

## Bonnes pratiques

1. **Ne jamais modifier manuellement** les documents Firestore des pages système
2. **Toujours utiliser l'interface Builder** pour modifier les pages système
3. **Tester en mode debug** pour voir les corrections automatiques
4. **Surveiller les warnings** dans la console pour détecter les problèmes

## Évolutions futures

- [ ] Blocage des modifications Firestore au niveau des règles de sécurité
- [ ] Audit trail des modifications sur les pages système
- [ ] Interface admin pour réinitialiser les pages système
- [ ] Validation côté serveur des pages système
