# Dynamic Sections Builder PRO - Module 1 Documentation

## 🎯 Vue d'ensemble

Le **Dynamic Sections Builder PRO** est un module avancé de gestion de sections dynamiques pour Pizza Deli'Zza. Il permet de créer, configurer et gérer des sections personnalisées avec des conditions d'affichage avancées.

## ✨ Fonctionnalités

### 1. Types de Sections Préconstruites

Le module propose **10 types de sections** prêts à l'emploi :

#### 🏞️ Hero
Section principale avec image de fond
- **Champs** : titre, sous-titre, image, CTA
- **Usage** : Bannière d'accueil, campagne principale

#### 🏷️ Promo Simple
Promotion basique
- **Champs** : titre, texte, CTA
- **Usage** : Offres rapides, messages courts

#### 🎁 Promo Avancée
Promotion complète avec visuel
- **Champs** : titre, sous-titre, texte, image, CTA
- **Usage** : Campagnes marketing élaborées

#### 📝 Bloc Texte
Section de contenu textuel
- **Champs** : titre, texte
- **Usage** : Informations, descriptions, articles

#### 🖼️ Bloc Image
Section visuelle
- **Champs** : titre, image
- **Usage** : Galerie, mise en avant visuelle

#### 📊 Grille
Affichage en grille
- **Champs** : titre, sous-titre
- **Usage** : Organisation de contenu structuré

#### 🎠 Carrousel
Défilement d'éléments
- **Champs** : titre, sous-titre
- **Usage** : Showcase de produits/promotions

#### 🗂️ Catégories
Liste de catégories
- **Champs** : titre, sous-titre
- **Usage** : Navigation, organisation du menu

#### 🛍️ Produits
Sélection de produits
- **Champs** : titre, sous-titre
- **Usage** : Mise en avant de produits spécifiques

#### 🎨 Layout Libre
Section personnalisable avec champs illimités
- **Champs** : illimités et personnalisables
- **Usage** : Besoins spécifiques, expérimentation

### 2. Layouts Disponibles

Chaque section peut utiliser **7 layouts** différents :

- **Full** : Pleine largeur
- **Compact** : Version condensée
- **Grid-2** : Grille 2 colonnes
- **Grid-3** : Grille 3 colonnes
- **Row** : Disposition en ligne
- **Card** : Format carte
- **Overlay** : Superposition d'éléments

### 3. Conditions d'Affichage Avancées

#### 📅 Jours de la semaine
Choisissez les jours où la section est visible (Lun-Dim)

#### ⏰ Plage horaire
Définissez une tranche horaire (HH:mm - HH:mm)

#### 👤 Conditions utilisateur

##### Connexion requise
Visible uniquement pour les utilisateurs connectés

##### Nombre minimum de commandes
Afficher après X commandes effectuées
- Exemple : Offre fidélité après 5 commandes

##### Montant minimum du panier
Afficher si panier ≥ X €
- Exemple : Livraison gratuite à partir de 25€

##### Session unique
Afficher une seule fois par session
- Exemple : Popup de bienvenue

### 4. Custom Field Builder (Layout Libre)

Pour les sections en **Layout Libre**, ajoutez des champs illimités :

#### Types de champs disponibles

1. **Texte court** (`text-short`)
   - Une ligne de texte
   - Exemple : titre, label, nom

2. **Texte long** (`text-long`)
   - Multiligne
   - Exemple : description, contenu

3. **Image** (`image`)
   - URL d'image
   - Exemple : bannière, logo, illustration

4. **Couleur** (`color`)
   - Code hexadécimal
   - Exemple : #FF5733

5. **Call-to-Action** (`cta`)
   - JSON : `{"text": "...", "url": "..."}`
   - Exemple : bouton d'action

6. **Liste** (`list`)
   - Array JSON
   - Exemple : `["item1", "item2", "item3"]`

7. **JSON** (`json`)
   - Objet JSON libre
   - Exemple : configuration avancée

#### Fonctionnalités des champs

- ✅ Création illimitée
- ✅ Drag & drop pour réorganiser
- ✅ Clé unique (identifiant)
- ✅ Libellé descriptif
- ✅ Valeur par défaut
- ✅ Validation des doublons

## 🏗️ Architecture

### Structure des fichiers

```
lib/src/studio/
├── models/
│   └── dynamic_section_model.dart       # Modèles de données
├── services/
│   └── dynamic_section_service.dart     # Service Firestore
├── controllers/
│   └── studio_state_controller.dart     # État Riverpod (modifié)
├── screens/
│   └── studio_v2_screen.dart            # Écran principal (modifié)
└── widgets/
    ├── studio_navigation.dart            # Navigation (modifiée)
    └── modules/
        ├── studio_sections_v3.dart       # Gestionnaire de sections
        ├── section_editor_dialog.dart    # Éditeur de section
        └── custom_field_builder.dart     # Constructeur de champs
```

### Modèle de données

#### DynamicSection
```dart
class DynamicSection {
  final String id;
  final DynamicSectionType type;
  final DynamicSectionLayout layout;
  final int order;
  final bool active;
  final Map<String, dynamic> content;
  final SectionConditions conditions;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### SectionConditions
```dart
class SectionConditions {
  final List<int>? days;                // 1-7 (Lun-Dim)
  final String? hoursStart;             // "HH:mm"
  final String? hoursEnd;               // "HH:mm"
  final bool requireLoggedIn;
  final int? requireOrdersMin;
  final double? requireCartMin;
  final bool applyOncePerSession;
}
```

#### CustomField
```dart
class CustomField {
  final String key;                     // Identifiant unique
  final String label;                   // Libellé
  final CustomFieldType type;           // Type de champ
  final dynamic value;                  // Valeur
}
```

### Firestore

#### Collection
`dynamic_sections_v3`

#### Structure d'un document
```json
{
  "id": "abc123",
  "type": "hero",
  "layout": "full",
  "order": 0,
  "active": true,
  "content": {
    "title": "Bienvenue chez Pizza Deli'Zza",
    "subtitle": "Les meilleures pizzas de la ville",
    "imageUrl": "https://...",
    "ctaText": "Commander",
    "ctaUrl": "/menu"
  },
  "conditions": {
    "days": [1, 2, 3, 4, 5],
    "hoursStart": "11:00",
    "hoursEnd": "22:00",
    "requireLoggedIn": false,
    "requireOrdersMin": null,
    "requireCartMin": null,
    "applyOncePerSession": false
  },
  "createdAt": "2025-01-20T10:00:00Z",
  "updatedAt": "2025-01-20T15:30:00Z"
}
```

## 🎮 Utilisation

### Accès au module

1. Naviguer vers `/admin/studio/v2`
2. Cliquer sur **"Sections V3"** dans le menu

### Créer une section

1. Cliquer sur **"Nouvelle section"**
2. **Étape 1** : Choisir le type et le layout
   - Sélectionner un type de section
   - Choisir un layout
   - Activer/désactiver la section
3. **Étape 2** : Configurer le contenu
   - Remplir les champs selon le type
   - Pour Layout Libre : ajouter des champs personnalisés
4. **Étape 3** : Définir les conditions
   - Sélectionner les jours
   - Définir les horaires
   - Configurer les conditions utilisateur
5. Cliquer sur **"Enregistrer"**

### Éditer une section

1. Cliquer sur une carte de section
2. Modifier les paramètres
3. Cliquer sur **"Enregistrer"**

### Réorganiser les sections

- Utiliser le handle de drag (☰) pour réorganiser
- L'ordre est sauvegardé automatiquement en mode brouillon

### Dupliquer une section

- Cliquer sur l'icône de duplication (📋)
- Une copie est créée avec `order + 1`

### Supprimer une section

- Cliquer sur l'icône de suppression (🗑️)
- Confirmer la suppression

### Activer/Désactiver

- Utiliser le switch sur chaque carte
- Les sections inactives sont masquées mais conservées

## 🔄 Workflow Brouillon/Publication

### Mode Brouillon (Draft)

Toutes les modifications sont **locales** jusqu'à publication :
- ✅ Créer des sections
- ✅ Modifier le contenu
- ✅ Réorganiser
- ✅ Activer/désactiver
- ✅ Supprimer

### Publier les modifications

1. Le badge orange indique des modifications non publiées
2. Cliquer sur **"Publier"** dans la navigation
3. Toutes les sections sont sauvegardées dans Firestore
4. L'application cliente verra les changements

### Annuler les modifications

1. Cliquer sur **"Annuler"**
2. Confirmer
3. Retour à l'état publié

## 🎨 Interface

### Liste des sections

- **Carte par section** avec informations clés
- **Drag handle** pour réorganisation
- **Icône colorée** selon le type
- **Badge de layout**
- **Switch actif/inactif**
- **Actions** : dupliquer, supprimer

### Éditeur de section

- **Stepper 3 étapes** clair et guidé
- **Validation** des champs requis
- **Prévisualisation** des choix
- **Navigation** fluide entre étapes

### Custom Field Builder

- **Liste réorganisable** des champs
- **Dialog modal** pour ajout/édition
- **Types visuels** avec icônes
- **Validation** des clés uniques

## 🔍 Validation et Logique

### Validation des conditions

La méthode `shouldBeVisible()` vérifie :
1. Section active
2. Jour de la semaine
3. Tranche horaire
4. Utilisateur connecté (si requis)
5. Nombre de commandes minimum
6. Montant panier minimum
7. Affichage unique par session

### Exemple d'utilisation
```dart
final section = DynamicSection(...);
final isVisible = section.shouldBeVisible(
  now: DateTime.now(),
  isLoggedIn: true,
  userOrdersCount: 3,
  cartTotal: 25.0,
  hasSeenInSession: false,
);
```

## 🚀 Évolutions Futures

### Phase 2 (Court terme)
- [ ] Media Manager pour upload d'images
- [ ] Color picker visuel
- [ ] Preview panel avec rendu des sections
- [ ] Templates prédéfinis (Quick start)

### Phase 3 (Moyen terme)
- [ ] A/B Testing intégré
- [ ] Analytics par section
- [ ] Duplication de conditions entre sections
- [ ] Import/Export de sections

### Phase 4 (Long terme)
- [ ] Sections conditionnelles avancées (géolocalisation)
- [ ] Personnalisation par segment utilisateur
- [ ] Planification de campagnes
- [ ] Historique et versioning

## 📊 Métriques

### Couverture fonctionnelle

| Fonctionnalité | Statut |
|---|---|
| Modèles de données | ✅ 100% |
| Service Firestore | ✅ 100% |
| Contrôleur Riverpod | ✅ 100% |
| UI Liste sections | ✅ 100% |
| Éditeur de section | ✅ 100% |
| Templates préconçus | ✅ 100% |
| Custom Field Builder | ✅ 100% |
| Conditions avancées | ✅ 100% |
| Draft/Publish | ✅ 100% |
| Drag & Drop | ✅ 100% |
| Preview panel | ⏳ 0% |
| Media Manager | ⏳ 0% |

### Statistiques code

- **Fichiers créés** : 4
- **Fichiers modifiés** : 3
- **Lignes de code** : ~1,500
- **Modèles** : 4 (DynamicSection, SectionConditions, CustomField, enums)
- **Services** : 1 (DynamicSectionService)
- **Widgets** : 3 (StudioSectionsV3, SectionEditorDialog, CustomFieldBuilder)

## 🔒 Sécurité

### Firestore Rules (à implémenter)

```javascript
match /dynamic_sections_v3/{sectionId} {
  // Lecture publique pour l'app
  allow read: if true;
  
  // Écriture réservée aux admins
  allow write: if request.auth != null 
    && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

### Validation côté serveur

- Vérifier les permissions admin
- Valider la structure des sections
- Sanitiser le contenu
- Limiter la taille des champs JSON

## 🐛 Dépannage

### Les sections ne s'affichent pas
1. Vérifier que les sections sont **actives**
2. Vérifier que les **conditions** sont remplies
3. Consulter la console pour erreurs Firestore

### L'éditeur ne s'ouvre pas
1. Vérifier les erreurs console
2. S'assurer d'avoir les permissions admin
3. Vérifier la connexion Firestore

### Les modifications ne sont pas publiées
1. Cliquer sur **"Publier"** (pas de sauvegarde auto)
2. Vérifier la connexion réseau
3. Consulter les logs Firestore

### Drag & drop ne fonctionne pas
1. S'assurer d'utiliser le handle (☰)
2. Vérifier que la liste n'est pas vide
3. Tester sur desktop (meilleur support)

## 📝 Bonnes Pratiques

### Nommage des sections
- Utiliser des noms descriptifs dans les contenus
- Préfixer les clés pour les sections liées
- Exemple : `promo_noel_`, `hero_accueil_`

### Organisation des sections
- Mettre les sections importantes en premier (order: 0, 1, 2)
- Grouper les sections similaires
- Désactiver plutôt que supprimer (réutilisation)

### Conditions d'affichage
- Tester les conditions avant publication
- Éviter les conditions trop restrictives
- Documenter les conditions complexes

### Custom Fields
- Utiliser des clés en camelCase
- Préfixer par catégorie : `hero_`, `promo_`, etc.
- Ajouter des valeurs par défaut
- Documenter les champs JSON complexes

## 📚 Ressources

### Documentation Flutter
- [Riverpod](https://riverpod.dev/)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Material Design](https://m3.material.io/)

### Documentation interne
- [STUDIO_V2_README.md](./STUDIO_V2_README.md)
- [STUDIO_V2_DELIVERABLES.md](./STUDIO_V2_DELIVERABLES.md)
- [STUDIO_V2_TESTING.md](./STUDIO_V2_TESTING.md)

---

**Version** : 3.0.0  
**Date** : 2025-01-20  
**Statut** : ✅ Fonctionnel  
**Module** : Dynamic Sections Builder PRO
