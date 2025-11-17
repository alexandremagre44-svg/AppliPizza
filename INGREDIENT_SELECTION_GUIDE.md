# Guide d'Utilisation: Sélection des Ingrédients pour les Pizzas

## Vue d'ensemble

Ce guide explique comment utiliser le nouveau système de sélection des ingrédients lors de la création et modification de pizzas dans l'interface d'administration.

## Pour les Administrateurs

### Étape 1: Créer ou Modifier des Ingrédients

Avant de créer une pizza, vous devez avoir des ingrédients dans le système.

1. Accédez au **Studio** depuis le menu principal
2. Cliquez sur **"Ingrédients Universels"**
3. Créez les ingrédients nécessaires (Mozzarella, Tomate, Jambon, etc.)
4. Assurez-vous que les ingrédients sont **actifs**

**Conseil**: Organisez vos ingrédients par catégorie (Fromages, Viandes, Légumes, Sauces, Herbes)

### Étape 2: Créer une Nouvelle Pizza

1. Accédez à **"Produits"** → **"Pizzas"**
2. Cliquez sur **"+ Nouveau produit"**
3. Remplissez les informations de base:
   - Nom (ex: "Pizza Reine")
   - Description
   - Prix de base
   - Image URL
   - Catégorie: **Pizza**

### Étape 3: Sélectionner les Ingrédients de Base

Descendez jusqu'à la section **"Ingrédients de base (retirables par le client)"**

**Que sont les ingrédients de base?**
- Ce sont les ingrédients inclus par défaut dans la pizza
- Les clients peuvent les **retirer** lors de la personnalisation
- Exemple pour une Pizza Reine:
  - ✅ Sauce Tomate
  - ✅ Mozzarella
  - ✅ Jambon
  - ✅ Champignons

**Comment sélectionner:**
1. Cliquez sur les chips des ingrédients que vous voulez inclure
2. Les ingrédients sélectionnés apparaissent en couleur primaire
3. Vous pouvez sélectionner autant d'ingrédients que nécessaire
4. Le coût supplémentaire de chaque ingrédient est affiché

**Exemple de sélection:**
```
[✓ Mozzarella]  [✓ Sauce Tomate]  [✓ Jambon]  [✓ Champignons]
[  Olives    ]  [  Poivrons   ]  [  Oignons]  [  Anchois    ]
```

### Étape 4: Sélectionner les Suppléments Autorisés

Descendez jusqu'à la section **"Suppléments autorisés"**

**Que sont les suppléments autorisés?**
- Ce sont les ingrédients que les clients peuvent **ajouter** en plus
- Chaque supplément a un coût additionnel
- Vous contrôlez quels suppléments sont disponibles pour cette pizza
- Exemple pour une Pizza Reine:
  - ✅ Supplément Fromage (+1.50€)
  - ✅ Olives (+1.00€)
  - ✅ Poivrons (+1.00€)
  - ✅ Œuf (+1.50€)
  - ❌ Hareng (pas adapté à une Reine)
  - ❌ Bœuf (pas adapté à une Reine)

**Comment sélectionner:**
1. Cliquez sur les chips des suppléments que vous voulez autoriser
2. Pensez à la cohérence des saveurs
3. N'autorisez que les suppléments qui vont bien avec cette pizza

**Exemple de sélection:**
```
[✓ Mozzarella Extra (+1.50€)]  [✓ Olives (+1.00€)]  [✓ Poivrons (+1.00€)]
[  Hareng (+2.00€)         ]  [  Bœuf (+2.50€) ]  [✓ Œuf (+1.50€)    ]
```

### Étape 5: Sauvegarder

1. Vérifiez vos sélections
2. Cliquez sur **"Créer le produit"** ou **"Enregistrer les modifications"**
3. La pizza est maintenant disponible avec vos choix d'ingrédients

## Pour les Clients

### Personnalisation d'une Pizza

Lorsqu'un client clique sur une pizza pour la personnaliser:

1. **Onglet Ingrédients**:
   - **Ingrédients de base**: Tous sélectionnés par défaut
     - Le client peut les **décocher** pour les retirer
     - Exemple: Retirer les champignons d'une Pizza Reine
   - **Suppléments disponibles**: Organisés par catégorie
     - Le client voit uniquement les suppléments autorisés pour cette pizza
     - Chaque supplément affiche son coût (+X.XX€)
     - Le client peut en ajouter autant qu'il veut

2. **Prix Total**: Mis à jour en temps réel
   - Prix de base de la pizza
   - + Coût des suppléments ajoutés
   - + Ajustement selon la taille

### Exemple Concret

**Pizza Reine (12.90€)**

**Ingrédients de base** (retirables):
- ✓ Sauce Tomate
- ✓ Mozzarella
- ✗ Jambon (retiré)
- ✓ Champignons

**Suppléments ajoutés**:
- + Olives (+1.00€)
- + Œuf (+1.50€)

**Prix total**: 12.90€ + 1.00€ + 1.50€ = **15.40€**

## Cas d'Usage

### Cas 1: Pizza Classique avec Options Variées

**Pizza Margherita**
- Ingrédients de base: Sauce Tomate, Mozzarella, Basilic
- Suppléments autorisés: Tous les fromages, légumes, herbes
- Raison: Pizza simple qui accepte beaucoup de personnalisations

### Cas 2: Pizza Spécialisée avec Options Limitées

**Pizza au Saumon**
- Ingrédients de base: Crème fraîche, Mozzarella, Saumon fumé, Aneth
- Suppléments autorisés: Câpres, Citron, Oignons rouges, Crème supplémentaire
- Raison: Saveurs délicates qui ne vont pas avec tous les ingrédients

### Cas 3: Pizza Végétarienne

**Pizza Végétarienne**
- Ingrédients de base: Sauce Tomate, Mozzarella, Poivrons, Oignons, Champignons, Olives
- Suppléments autorisés: UNIQUEMENT légumes et fromages (pas de viandes)
- Raison: Maintenir le caractère végétarien

### Cas 4: Pizza de Signature

**Pizza du Chef**
- Ingrédients de base: Recette secrète du chef
- Suppléments autorisés: Aucun ou très limités
- Raison: Préserver l'intégrité de la recette

## Bonnes Pratiques

### ✅ À Faire

1. **Cohérence des saveurs**: N'autorisez que les suppléments qui vont bien ensemble
2. **Options variées**: Offrez au moins 5-10 suppléments par pizza
3. **Prix justes**: Assurez-vous que les coûts supplémentaires reflètent les coûts réels
4. **Documentation**: Notez pourquoi vous limitez certains suppléments
5. **Test client**: Demandez l'avis de vos clients sur les options

### ❌ À Éviter

1. **Trop de restrictions**: Ne limitez pas trop les options (clients frustrés)
2. **Combinaisons étranges**: Évitez d'autoriser des mélanges qui ne fonctionnent pas
3. **Prix incohérents**: Gardez les prix supplémentaires cohérents entre pizzas
4. **Oublier les ingrédients de base**: Toujours définir les ingrédients de base
5. **Aucun supplément**: Chaque pizza devrait avoir au moins quelques options

## Questions Fréquentes

**Q: Que se passe-t-il si je ne sélectionne pas de suppléments autorisés?**
R: Les clients ne pourront rien ajouter à cette pizza, seulement retirer des ingrédients de base.

**Q: Puis-je modifier les ingrédients d'une pizza existante?**
R: Oui, éditez simplement la pizza et modifiez les sélections.

**Q: Les anciennes pizzas continueront-elles de fonctionner?**
R: Oui, elles auront une liste vide de suppléments autorisés par défaut.

**Q: Comment gérer une pizza "personnalisable à volonté"?**
R: Sélectionnez tous les ingrédients dans les suppléments autorisés.

**Q: Puis-je avoir le même ingrédient dans base ET suppléments?**
R: Oui, utile pour "Extra Fromage" par exemple (base: Mozzarella, supplément: Mozzarella Extra).

**Q: Comment empêcher les clients de retirer certains ingrédients essentiels?**
R: Actuellement, tous les ingrédients de base sont retirables. Si un ingrédient est vraiment essentiel, ne le mettez pas dans les ingrédients de base - incluez-le dans le nom/description de la pizza.

**Q: Que se passe-t-il si je supprime un ingrédient utilisé dans une pizza?**
R: La pizza affichera l'ID de l'ingrédient au lieu du nom. Il est recommandé de désactiver plutôt que supprimer.

## Support

Pour toute question:
- Consultez `INGREDIENT_MANAGEMENT_GUIDE.md`
- Consultez `PIZZA_INGREDIENT_MANAGEMENT_IMPLEMENTATION.md`
- Contactez le support technique

## Mise à Jour

**Version**: 1.0  
**Date**: 2025-11-17  
**Auteur**: Système de gestion des ingrédients
