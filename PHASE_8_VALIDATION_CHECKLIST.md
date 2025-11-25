# Phase 8 - Checklist de Validation

Cette checklist permet de vérifier que l'implémentation Phase 8 (SystemBlocks + Pages système + Actions système + Protections) est complète et fonctionnelle.

---

## Section A — SystemBlocks

### Ajout des blocs

- [ ] **A1.** Les 4 SystemBlocks peuvent être ajoutés via le panneau "Modules système"
  - [ ] Module Roulette (icône 🎰)
  - [ ] Module Fidélité (icône 🎁)
  - [ ] Module Récompenses (icône ⭐)
  - [ ] Module Activité du compte (icône 📊)

- [ ] **A2.** Les SystemBlocks apparaissent dans la liste des blocs après ajout

- [ ] **A3.** Les SystemBlocks peuvent être réorganisés par glisser-déposer

- [ ] **A4.** Les SystemBlocks peuvent être supprimés

### Preview

- [ ] **A5.** Le preview affiche un placeholder gris de 120px de hauteur

- [ ] **A6.** Le nom du module est affiché au format `[Module: Roulette]`

- [ ] **A7.** L'icône du module est affichée dans le preview

- [ ] **A8.** La bordure est bleue en mode debug (`kDebugMode`)

- [ ] **A9.** Les widgets système réels ne sont jamais exécutés en preview

### Runtime

- [ ] **A10.** Le runtime affiche les widgets système réels
  - [ ] Roulette : Carte d'accès avec bouton "Jouer"
  - [ ] Loyalty : Points et progression
  - [ ] Rewards : Liste des tickets ou placeholder
  - [ ] AccountActivity : Statistiques commandes/favoris

- [ ] **A11.** Les widgets s'affichent en pleine largeur

- [ ] **A12.** Le padding/margin s'applique via BlockConfigHelper

- [ ] **A13.** La hauteur s'adapte au contenu (pas fixe comme en preview)

### Protection

- [ ] **A14.** Le panneau de configuration affiche "Ce module système ne possède aucune configuration"

- [ ] **A15.** Aucun champ éditable n'est disponible pour les SystemBlocks

- [ ] **A16.** La duplication conserve le type `system`

### Gestion d'erreurs

- [ ] **A17.** Un module type inconnu affiche "Module système introuvable"

- [ ] **A18.** Une exception dans un module affiche un fallback propre

- [ ] **A19.** Aucun plantage de l'application en cas d'erreur module

---

## Section B — Pages système

### Création automatique

- [ ] **B1.** Les pages système sont créées automatiquement si manquantes
  - [ ] profile
  - [ ] cart
  - [ ] rewards
  - [ ] roulette

- [ ] **B2.** Les pages créées ont `isSystemPage: true`

- [ ] **B3.** Les pages créées ont `displayLocation: "hidden"`

- [ ] **B4.** Les pages créées ont `blocks: []` (vide)

- [ ] **B5.** La création est journalisée dans la console debug

### Contenu personnalisable

- [ ] **B6.** Des blocs normaux peuvent être ajoutés aux pages système

- [ ] **B7.** Des SystemBlocks peuvent être ajoutés aux pages système

- [ ] **B8.** Les blocs peuvent être réorganisés librement

- [ ] **B9.** Le contenu des blocs peut être modifié

### Protection

- [ ] **B10.** Le bandeau "Page système protégée" s'affiche

- [ ] **B11.** Le bouton de suppression de page est absent/désactivé

- [ ] **B12.** Le champ pageId est non modifiable

- [ ] **B13.** displayLocation est limité à `bottomBar` ou `hidden`

### Validation création

- [ ] **B14.** La création manuelle avec un ID réservé est refusée
  - [ ] profile → refusé
  - [ ] cart → refusé
  - [ ] rewards → refusé
  - [ ] roulette → refusé

- [ ] **B15.** Le message "Cet identifiant est réservé aux pages système" s'affiche

---

## Section C — Navigation

### Action openSystemPage

- [ ] **C1.** L'action "openSystemPage" apparaît dans le dropdown des actions

- [ ] **C2.** Le dropdown de sélection de page système est disponible
  - [ ] Page Profil
  - [ ] Page Panier
  - [ ] Page Récompenses
  - [ ] Page Roulette

- [ ] **C3.** L'action est stockée correctement en Firestore
  ```json
  { "tapAction": "openSystemPage", "tapActionTarget": "profile" }
  ```

- [ ] **C4.** L'action fonctionne en runtime (navigation effective)

- [ ] **C5.** L'action ne s'exécute pas en preview (permet la sélection)

### Navigation dynamique bottomBar

- [ ] **C6.** Les pages système avec `displayLocation: "bottomBar"` apparaissent dans la barre

- [ ] **C7.** Les pages système avec `displayLocation: "hidden"` n'apparaissent pas

- [ ] **C8.** L'ordre des pages est respecté selon le champ `order`

### Fallback legacy

- [ ] **C9.** Si la page profile Builder n'existe pas → ProfileScreen legacy

- [ ] **C10.** Si la page cart Builder n'existe pas → CartScreen legacy

- [ ] **C11.** Si la page rewards Builder n'existe pas → RewardsScreen legacy

- [ ] **C12.** Si la page roulette Builder n'existe pas → RouletteScreen legacy

### Routes explicites

- [ ] **C13.** Route `/profile` fonctionne (Builder ou legacy)

- [ ] **C14.** Route `/cart` fonctionne (Builder ou legacy)

- [ ] **C15.** Route `/rewards` fonctionne (Builder ou legacy)

- [ ] **C16.** Route `/roulette` fonctionne (Builder ou legacy)

---

## Section D — Firestore

### Sauvegarde brouillon

- [ ] **D1.** Les SystemBlocks sont sauvegardés dans le draft

- [ ] **D2.** Les pages système conservent `isSystemPage: true`

- [ ] **D3.** La sauvegarde automatique fonctionne normalement

### Publication

- [ ] **D4.** Les SystemBlocks sont publiés correctement

- [ ] **D5.** Les pages système peuvent être publiées

- [ ] **D6.** La version published est identique au draft

### Rechargement

- [ ] **D7.** Les SystemBlocks sont rechargés correctement depuis Firestore

- [ ] **D8.** Les pages système conservent leurs propriétés au rechargement

- [ ] **D9.** L'ordre des blocs est préservé

### Protection des types

- [ ] **D10.** Le type `system` est conservé lors de la sauvegarde

- [ ] **D11.** `isSystemPage` est corrigé automatiquement si manquant

- [ ] **D12.** `displayLocation` invalide est corrigé automatiquement

---

## Section E — Runtime

### Stabilité

- [ ] **E1.** Aucun crash si un module système est indisponible

- [ ] **E2.** Aucun crash si une page système est absente

- [ ] **E3.** L'application reste fonctionnelle en cas d'erreur

### Gestion d'erreurs

- [ ] **E4.** Module type inconnu → widget "Module système introuvable"

- [ ] **E5.** Exception dans module → widget "Erreur de rendu"

- [ ] **E6.** Page système absente → écran legacy

### Compatibilité

- [ ] **E7.** Compatible mobile (Android/iOS)

- [ ] **E8.** Compatible web

- [ ] **E9.** Compatible desktop (si applicable)

- [ ] **E10.** Responsive design fonctionnel

---

## Section F — Régression

### Blocs existants

- [ ] **F1.** Les blocs `hero` fonctionnent normalement

- [ ] **F2.** Les blocs `text` fonctionnent normalement

- [ ] **F3.** Les blocs `image` fonctionnent normalement

- [ ] **F4.** Les blocs `button` fonctionnent normalement

- [ ] **F5.** Les blocs `banner` fonctionnent normalement

- [ ] **F6.** Les blocs `spacer` fonctionnent normalement

### Services

- [ ] **F7.** Le service de publication fonctionne

- [ ] **F8.** Le service de sauvegarde automatique fonctionne

- [ ] **F9.** Le service de chargement de pages fonctionne

- [ ] **F10.** Le theme manager fonctionne

### Navigation dynamique

- [ ] **F11.** Les pages normales restent navigables

- [ ] **F12.** L'action `openPage` fonctionne toujours

- [ ] **F13.** L'action `openUrl` fonctionne toujours

- [ ] **F14.** La navigation par route fonctionne

### Autres fonctionnalités

- [ ] **F15.** L'authentification n'est pas impactée

- [ ] **F16.** Le panier n'est pas impacté

- [ ] **F17.** La roulette legacy fonctionne toujours

- [ ] **F18.** Les récompenses legacy fonctionnent toujours

---

## Résumé de validation

| Section | Items | Validés | % |
|---------|-------|---------|---|
| A - SystemBlocks | 19 | _ | _ |
| B - Pages système | 15 | _ | _ |
| C - Navigation | 16 | _ | _ |
| D - Firestore | 12 | _ | _ |
| E - Runtime | 10 | _ | _ |
| F - Régression | 18 | _ | _ |
| **TOTAL** | **90** | _ | _ |

---

## Instructions de validation

### Préparation

1. Avoir un environnement de développement fonctionnel
2. Avoir accès à Firebase/Firestore en mode test
3. Activer le mode debug pour voir les bordures bleues

### Exécution

1. Parcourir chaque section dans l'ordre
2. Cocher chaque item validé
3. Noter les problèmes rencontrés
4. Calculer le pourcentage de validation

### Critères de succès

- **100%** : Phase 8 complètement validée
- **90-99%** : Quelques ajustements mineurs nécessaires
- **<90%** : Problèmes à corriger avant déploiement

---

## Documents de référence

- 📄 [PHASE_8_DOCUMENTATION.md](./PHASE_8_DOCUMENTATION.md) - Documentation consolidée
- 📄 [SYSTEM_BLOCKS.md](./SYSTEM_BLOCKS.md) - Documentation des SystemBlocks
- 📄 [SYSTEM_PAGES.md](./SYSTEM_PAGES.md) - Documentation des pages système
- 📄 [SYSTEM_PROTECTION.md](./SYSTEM_PROTECTION.md) - Règles de protection

---

## Notes de validation

_Espace pour noter les observations lors de la validation :_

```
Date de validation : ____/____/____
Validateur : _____________________

Observations :
_________________________________________
_________________________________________
_________________________________________
_________________________________________

Problèmes identifiés :
_________________________________________
_________________________________________
_________________________________________

Actions correctives :
_________________________________________
_________________________________________
_________________________________________
```
