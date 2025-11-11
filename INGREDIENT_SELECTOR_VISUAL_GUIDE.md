# 🍕 Guide Visuel - Widget IngredientSelector

## Aperçu Général

Le widget `IngredientSelector` offre une interface moderne et intuitive pour gérer les ingrédients d'une pizza dans l'interface d'administration.

---

## 📱 Interface du Widget

### Structure Globale

```
┌─────────────────────────────────────────────────┐
│  🍕 Ingrédients                            [3]  │  ← En-tête avec compteur
├─────────────────────────────────────────────────┤
│                                                 │
│  Ingrédients sélectionnés:                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Tomate ×│  │Mozzarella×│  │ Basilic ×│       │  ← Chips supprimables
│  └──────────┘ └──────────┘ └──────────┘       │
│                                                 │
│  Ingrédients disponibles:                      │
│  ☑ Tomate      ☑ Mozzarella   ☑ Basilic       │
│  ☐ Jambon      ☐ Champignons  ☐ Oignons       │  ← Checkboxes
│  ☐ Poivrons    ☐ Olives       ☐ Pepperoni     │
│  ☐ Chorizo     ☐ Poulet       ☐ Bacon         │
│  ☐ Chèvre      ☐ Parmesan     ☐ Roquette      │
│  ☐ Origan                                      │
│                                                 │
│  Ajouter un ingrédient personnalisé:           │
│  ┌─────────────────────────────────┐  ┌───┐   │
│  │ Ex: Roquette, Gorgonzola...    │  │ + │   │  ← Champ + bouton
│  └─────────────────────────────────┘  └───┘   │
│                                                 │
│  ℹ️ Les ingrédients sont propres à cette      │  ← Note informative
│     pizza et n'affectent pas les autres.      │
└─────────────────────────────────────────────────┘
```

---

## 🎨 Design et Couleurs

### Palette de Couleurs

| Élément | Couleur | Usage |
|---------|---------|-------|
| Fond général | Orange clair (5% opacité) | Conteneur principal |
| Bordure | Orange (30% opacité) | Délimitation |
| En-tête icône | Orange #FF6D00 | Icône pizza |
| Badge compteur | Orange solid | Nombre d'ingrédients |
| Chip sélectionné | Orange (20% opacité) | Fond des chips |
| Texte chip | Orange foncé | Texte des chips actifs |
| Checkbox active | Orange | Checkbox cochée |
| Bouton "+" | Orange solid | Bouton d'ajout |
| Note info | Bleu clair | Fond de la note |

### Typographie

- **En-tête** : 16px, Weight 900 (Extra Bold)
- **Sous-titres** : 13px, Weight 600 (Semi-Bold)
- **Labels** : 13px, Weight 500-600
- **Note** : 11px, Weight 400

---

## 🔄 États et Interactions

### 1. État Vide (Aucun Ingrédient)

```
┌─────────────────────────────────────────────────┐
│  🍕 Ingrédients                            [0]  │
├─────────────────────────────────────────────────┤
│                                                 │
│  Ingrédients disponibles:                      │
│  ☐ Tomate      ☐ Mozzarella   ☐ Basilic       │
│  ☐ Jambon      ☐ Champignons  ☐ Oignons       │
│  ...                                            │
└─────────────────────────────────────────────────┘
```

### 2. État avec Sélection

```
┌─────────────────────────────────────────────────┐
│  🍕 Ingrédients                            [4]  │
├─────────────────────────────────────────────────┤
│                                                 │
│  Ingrédients sélectionnés:                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Tomate ×│  │Mozzarella×│  │ Jambon  ×│       │
│  └──────────┘ └──────────┘ └──────────┘       │
│  ┌──────────┐                                  │
│  │Champignons×│                                 │
│  └──────────┘                                  │
│                                                 │
│  Ingrédients disponibles:                      │
│  ☑ Tomate      ☑ Mozzarella   ☐ Basilic       │
│  ☑ Jambon      ☑ Champignons  ☐ Oignons       │
│  ...                                            │
└─────────────────────────────────────────────────┘
```

### 3. État avec Ingrédient Personnalisé

```
┌─────────────────────────────────────────────────┐
│  🍕 Ingrédients                            [5]  │
├─────────────────────────────────────────────────┤
│                                                 │
│  Ingrédients sélectionnés:                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Tomate ×│  │Mozzarella×│  │Roquette ×│  ← Personnalisé !
│  └──────────┘ └──────────┘ └──────────┘       │
│  ┌──────────┐ ┌──────────┐                    │
│  │Gorgonzola×│  │ Miel    ×│  ← Personnalisés !
│  └──────────┘ └──────────┘                    │
└─────────────────────────────────────────────────┘
```

---

## 🎬 Animations et Transitions

### Ajout d'un Ingrédient

1. L'utilisateur clique sur une checkbox
2. **Animation** : Fade-in d'un nouveau chip en haut
3. **Durée** : 200ms
4. **Badge compteur** : Update avec animation (+1)

### Retrait d'un Ingrédient

1. L'utilisateur clique sur le "×" d'un chip
2. **Animation** : Fade-out + scale down
3. **Durée** : 200ms
4. **Badge compteur** : Update avec animation (-1)

### Ajout Personnalisé

1. L'utilisateur tape un nom et clique "+"
2. **Validation** : Vérification pas de doublon
3. **Animation** : Nouveau chip apparaît avec bounce effect
4. **Feedback** : Champ se vide automatiquement

---

## 💡 Exemples d'Utilisation

### Exemple 1 : Pizza Margherita

**Ingrédients sélectionnés :**
- Tomate
- Mozzarella
- Basilic
- Origan

**Affichage Client :**
> Ingrédients de Base  
> `Tomate` `Mozzarella` `Basilic` `Origan`

### Exemple 2 : Pizza 4 Fromages

**Ingrédients sélectionnés :**
- Mozzarella
- Chèvre
- Parmesan
- Gorgonzola (personnalisé)

**Affichage Client :**
> Ingrédients de Base  
> `Mozzarella` `Chèvre` `Parmesan` `Gorgonzola`

### Exemple 3 : Pizza Créative

**Ingrédients sélectionnés :**
- Tomate
- Mozzarella
- Roquette (personnalisé)
- Jambon de Parme (personnalisé)
- Copeaux de Parmesan (personnalisé)
- Huile de truffe (personnalisé)

**Affichage Client :**
> Ingrédients de Base  
> `Tomate` `Mozzarella` `Roquette` `Jambon de Parme` `Copeaux de Parmesan` `Huile de truffe`

---

## 🖱️ Interactions Utilisateur

### Actions Disponibles

| Action | Méthode | Résultat |
|--------|---------|----------|
| Cocher checkbox | Clic | Ingrédient ajouté |
| Décocher checkbox | Clic | Ingrédient retiré |
| Cliquer sur chip | Pas d'action | (Optionnel: tooltip) |
| Cliquer sur "×" | Clic | Ingrédient retiré |
| Taper + Enter | Validation | Ajout personnalisé |
| Cliquer sur "+" | Clic | Ajout personnalisé |
| Taper doublon | Validation | Rejeté silencieusement |

### Feedback Visuel

- **Hover sur checkbox** : Légère surbrillance
- **Hover sur chip** : Curseur pointer + légère élévation
- **Hover sur "×"** : Curseur pointer + couleur plus foncée
- **Focus sur champ** : Bordure orange épaisse
- **Validation** : Chip apparaît avec animation

---

## 📐 Dimensions et Espacements

### Conteneur Principal

- **Padding** : 16px tous côtés
- **Border-radius** : 16px
- **Border** : 1px solid orange (30% opacité)

### En-tête

- **Icône** : 24px × 24px
- **Espacement icône-texte** : 12px
- **Badge compteur** : padding 12px horizontal, 6px vertical
- **Badge border-radius** : 12px

### Section Ingrédients Sélectionnés

- **Espacement chips** : 8px horizontal, 8px vertical (Wrap)
- **Chip padding** : auto (Material Design)
- **Chip border-radius** : 8px
- **Icône "×"** : 18px

### Section Ingrédients Disponibles

- **Espacement items** : 8px horizontal, 4px vertical (Wrap)
- **Item padding** : 12px horizontal, 8px vertical
- **Item border-radius** : 8px
- **Icône checkbox** : 18px
- **Espacement icône-texte** : 6px

### Section Ajout

- **Champ texte height** : Auto (Material Design)
- **Champ border-radius** : 12px
- **Champ padding** : 16px horizontal, 12px vertical
- **Bouton "+" size** : 24px × 24px (icône)
- **Bouton padding** : 16px tous côtés
- **Espacement champ-bouton** : 12px

### Note Info

- **Padding** : 12px tous côtés
- **Border-radius** : 8px
- **Icône** : 18px
- **Espacement icône-texte** : 8px

---

## 🔧 Personnalisation

### Props Disponibles

```dart
IngredientSelector(
  // Props obligatoires
  selectedIngredients: List<String>,        // Liste initiale
  onIngredientsChanged: Function(List<String>), // Callback
  
  // Props optionnelles
  availableIngredients: List<String>,       // Liste personnalisée (défaut: 16 ingrédients)
  primaryColor: Color,                      // Couleur principale (défaut: orange)
)
```

### Exemple de Personnalisation

```dart
// Pour une pizza rouge (tomate)
IngredientSelector(
  selectedIngredients: ['Tomate', 'Mozzarella'],
  onIngredientsChanged: (ingredients) { ... },
  primaryColor: Colors.red.shade600,
)

// Pour une pizza verte (pesto)
IngredientSelector(
  selectedIngredients: ['Pesto', 'Mozzarella'],
  onIngredientsChanged: (ingredients) { ... },
  primaryColor: Colors.green.shade600,
)

// Avec liste d'ingrédients personnalisée
IngredientSelector(
  selectedIngredients: [],
  onIngredientsChanged: (ingredients) { ... },
  availableIngredients: [
    'Nutella',
    'Banane',
    'Fraises',
    'Chantilly',
  ], // Pour une pizza dessert !
)
```

---

## 📱 Responsive Design

### Mobile (< 600px)

- Les checkboxes s'affichent sur 2-3 colonnes
- Le champ d'ajout prend toute la largeur
- Le bouton "+" reste à droite

### Tablet (600px - 900px)

- Les checkboxes s'affichent sur 3-4 colonnes
- Disposition identique au mobile

### Desktop (> 900px)

- Les checkboxes s'affichent sur 4-5 colonnes
- Plus d'espace horizontal pour le champ

---

## ✅ Validation et Sécurité

### Règles de Validation

1. **Pas de doublons** : Un ingrédient ne peut être ajouté qu'une fois
2. **Trim des espaces** : Les espaces avant/après sont retirés
3. **Vide rejeté** : Impossible d'ajouter un ingrédient vide
4. **Sensibilité casse** : "Tomate" ≠ "tomate" (2 ingrédients différents)

### Sécurité

- Pas d'injection possible (Flutter sécurisé par défaut)
- Les données sont stockées en tant que `List<String>` simple
- Validation côté client uniquement (validation serveur recommandée)

---

## 🎯 Avantages UX

### Pour l'Admin

✅ **Rapidité** : Cocher/décocher en 1 clic  
✅ **Flexibilité** : Ajouter des ingrédients non listés  
✅ **Clarté** : Voir immédiatement les ingrédients sélectionnés  
✅ **Correction** : Retirer facilement un ingrédient  
✅ **Feedback** : Compteur visible en temps réel

### Pour le Développeur

✅ **Réutilisable** : Widget autonome  
✅ **Personnalisable** : Couleur et liste modifiables  
✅ **Simple** : API claire avec 3 props  
✅ **Type-safe** : TypeScript-like avec Dart  
✅ **Testable** : Logique isolée dans le widget

### Pour l'Application

✅ **Cohérent** : Design uniforme avec le reste de l'app  
✅ **Performant** : Pas de requêtes réseau lors des changements  
✅ **Accessible** : Support des labels et focus  
✅ **Maintenable** : Code propre et commenté

---

## 🚀 Intégration Complète

### Dans le Formulaire Admin Pizza

```
┌─────────────────────────────────────────────────┐
│              Nouvelle Pizza                     │ ← Dialog header
├─────────────────────────────────────────────────┤
│  Nom *                                          │
│  ┌─────────────────────────────────────────┐   │
│  │ Ex: Margherita                          │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  Description *                                  │
│  ┌─────────────────────────────────────────┐   │
│  │ Ex: Tomate, Mozzarella, Basilic        │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  Prix (€) *                                     │
│  ┌─────────────────────────────────────────┐   │
│  │ Ex: 12.50                               │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  URL Image (optionnel)                          │
│  ┌─────────────────────────────────────────┐   │
│  │ https://...                             │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ╔═══════════════════════════════════════════╗ │
│  ║  🍕 Ingrédients                      [3] ║ │ ← IngredientSelector
│  ║                                           ║ │
│  ║  Ingrédients sélectionnés:               ║ │
│  ║  [Tomate ×] [Mozzarella ×] [Basilic ×]  ║ │
│  ║                                           ║ │
│  ║  ... (reste du widget)                   ║ │
│  ╚═══════════════════════════════════════════╝ │
│                                                 │
│  ⭐ Mise en avant                    [ON/OFF]  │
│  ✅ Produit actif                    [ON/OFF]  │
│  📍 Zone d'affichage                [Partout]  │
│                                                 │
│                          [Annuler] [Sauvegarder] │
└─────────────────────────────────────────────────┘
```

---

## 📊 Comparaison Avant/Après

### ❌ Avant (Sans IngredientSelector)

```
Description *
┌───────────────────────────────────────┐
│ Tomate, Mozzarella, Basilic          │  ← Texte libre non structuré
└───────────────────────────────────────┘
```

**Problèmes :**
- Pas de liste structurée
- Typos possibles (Mozarella, Basilique...)
- Pas de suggestion
- Difficile à modifier
- Pas de validation

### ✅ Après (Avec IngredientSelector)

```
Ingrédients
╔═════════════════════════════════════╗
║ 🍕 Ingrédients                 [3] ║
║                                     ║
║ [Tomate ×] [Mozzarella ×] [Basilic ×] ║  ← Liste structurée
║                                     ║
║ ☑ Tomate  ☑ Mozzarella  ☑ Basilic ║  ← Checkboxes
║ ☐ Jambon  ☐ Champignons ...        ║
╚═════════════════════════════════════╝
```

**Avantages :**
- Liste structurée (`List<String>`)
- Pas de typos (sélection)
- Suggestions disponibles
- Facile à modifier (1 clic)
- Validation automatique

---

## 🎉 Conclusion

Le widget `IngredientSelector` transforme la gestion des ingrédients en une expérience moderne et intuitive, tout en garantissant la cohérence des données.

**Résultat :** Admin heureux, données propres, clients satisfaits ! 🍕

---

*Dernière mise à jour : 11 novembre 2025*
