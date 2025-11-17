# Guide de Gestion des Ingrédients Universels

## Vue d'ensemble

Ce guide explique comment utiliser le système de gestion des ingrédients universels pour l'application Pizza Deli'Zza. Ce système permet aux administrateurs de créer et gérer une liste centralisée d'ingrédients qui sera utilisée pour la personnalisation de toutes les pizzas.

## Fonctionnalités

### Pour les Administrateurs

Le système d'ingrédients universels permet de :

- **Créer** de nouveaux ingrédients avec nom, prix, catégorie et ordre d'affichage
- **Modifier** les ingrédients existants
- **Activer/Désactiver** des ingrédients sans les supprimer
- **Supprimer** des ingrédients de la base de données
- **Organiser** les ingrédients par catégories pour une meilleure expérience utilisateur

### Pour les Clients

Les clients peuvent :

- Voir tous les ingrédients actifs lors de la personnalisation d'une pizza
- Les ingrédients sont organisés par catégorie (Fromages, Viandes, Légumes, etc.)
- Ajouter des ingrédients supplémentaires avec le prix affiché
- Voir le prix total mis à jour en temps réel

## Accès à la Gestion des Ingrédients

1. Connectez-vous en tant qu'administrateur
2. Accédez au **Studio** depuis le menu principal
3. Cliquez sur **"Ingrédients Universels"**

## Catégories d'Ingrédients

Le système organise les ingrédients en 6 catégories :

- **Fromages** - Mozzarella, Cheddar, Chèvre, Parmesan, etc.
- **Viandes** - Jambon, Poulet, Chorizo, Pepperoni, etc.
- **Légumes** - Oignons, Champignons, Poivrons, Olives, etc.
- **Sauces** - Tomate, BBQ, Crème fraîche, etc.
- **Herbes & Épices** - Basilic, Origan, Ail, etc.
- **Autres** - Tout ingrédient ne correspondant pas aux catégories ci-dessus

## Créer un Nouvel Ingrédient

1. Dans l'écran **Gestion des Ingrédients**, cliquez sur le bouton **"+ Nouvel ingrédient"**
2. Remplissez le formulaire :
   - **Nom** : Nom de l'ingrédient (ex: "Mozzarella Fraîche")
   - **Prix supplémentaire** : Coût en euros si ajouté en supplément (ex: 1.50)
   - **Catégorie** : Sélectionnez la catégorie appropriée
   - **Ordre d'affichage** : Numéro pour définir la priorité d'affichage (0 = premier)
   - **Ingrédient actif** : Cochez pour rendre l'ingrédient visible aux clients
3. Cliquez sur **"Créer l'ingrédient"**

### Exemple de Création

```
Nom: Mozzarella di Bufala
Prix: 2.50 €
Catégorie: Fromages
Ordre: 1
Actif: ✓
```

## Modifier un Ingrédient

1. Dans la liste des ingrédients, cliquez sur l'ingrédient à modifier
2. OU cliquez sur le menu ⋮ et sélectionnez **"Modifier"**
3. Modifiez les champs souhaités
4. Cliquez sur **"Enregistrer les modifications"**

## Activer/Désactiver un Ingrédient

Pour désactiver temporairement un ingrédient sans le supprimer :

1. Cliquez sur le menu ⋮ de l'ingrédient
2. Sélectionnez **"Désactiver"**

L'ingrédient restera dans la base de données mais ne sera plus visible pour les clients lors de la personnalisation.

Pour réactiver :
1. Cliquez sur le menu ⋮ de l'ingrédient
2. Sélectionnez **"Activer"**

## Supprimer un Ingrédient

⚠️ **Attention** : La suppression est définitive !

1. Cliquez sur le menu ⋮ de l'ingrédient
2. Sélectionnez **"Supprimer"**
3. Confirmez la suppression dans la boîte de dialogue

**Note** : Les pizzas existantes conserveront leur configuration, mais l'ingrédient ne sera plus disponible pour les nouvelles personnalisations.

## Filtrage par Catégorie

L'écran de gestion affiche des onglets pour chaque catégorie :

- **Tous** : Affiche tous les ingrédients
- **Fromages** : Affiche uniquement les fromages
- **Viandes** : Affiche uniquement les viandes
- Etc.

Cliquez sur un onglet pour filtrer la liste.

## Organisation et Bonnes Pratiques

### Ordre d'Affichage

- Utilisez des numéros d'ordre pour contrôler l'affichage
- Les ingrédients avec un ordre plus bas apparaissent en premier
- Exemple : Ordre 0, 1, 2, 3...

### Prix

- Définissez des prix cohérents pour chaque catégorie
- Exemple de tarification recommandée :
  - Fromages premium : 1.50 - 2.50 €
  - Viandes : 1.50 - 2.00 €
  - Légumes : 0.50 - 1.00 €
  - Herbes : Gratuit (0.00 €)

### Nommage

- Utilisez des noms clairs et descriptifs
- Évitez les abréviations
- Exemples corrects :
  - ✓ "Mozzarella di Bufala"
  - ✓ "Jambon de Parme"
  - ✓ "Champignons de Paris"
- Exemples à éviter :
  - ✗ "Mozza"
  - ✗ "Jambon"
  - ✗ "Champi"

### Gestion du Stock

Si un ingrédient est temporairement indisponible :
1. Ne le supprimez pas
2. Désactivez-le simplement
3. Réactivez-le quand il est de nouveau disponible

## Architecture Technique

### Stockage

Les ingrédients sont stockés dans Firestore dans la collection `ingredients` :

```json
{
  "id": "auto-generated-id",
  "name": "Mozzarella Fraîche",
  "extraCost": 1.50,
  "category": "fromage",
  "isActive": true,
  "order": 1
}
```

### Sécurité

Les règles Firestore garantissent que :
- Tous les utilisateurs authentifiés peuvent **lire** les ingrédients
- Seuls les **administrateurs** peuvent créer, modifier ou supprimer des ingrédients

### Temps Réel

Les modifications d'ingrédients sont synchronisées en temps réel :
- Les clients voient immédiatement les nouveaux ingrédients
- Les ingrédients désactivés disparaissent instantanément des menus de personnalisation

## Intégration avec la Personnalisation de Pizza

Les ingrédients sont automatiquement intégrés dans :

1. **Modal de personnalisation client** (`pizza_customization_modal.dart`)
   - Affichage par catégorie
   - Prix calculé automatiquement
   - Interface Material 3

2. **Modal Staff Tablet** (`staff_pizza_customization_modal.dart`)
   - Interface optimisée pour tablette
   - Même logique de catégorisation

3. **Modal Élégant** (`elegant_pizza_customization_modal.dart`)
   - Fallback sur mock data pour compatibilité

## Dépannage

### Les ingrédients n'apparaissent pas

1. Vérifiez que l'ingrédient est **actif**
2. Vérifiez que Firebase est correctement configuré
3. Vérifiez les règles de sécurité Firestore

### Les prix ne se mettent pas à jour

1. Actualisez l'application
2. Vérifiez que le prix est bien sauvegardé dans Firestore
3. Vérifiez les logs pour des erreurs de connexion

### Erreur lors de la sauvegarde

1. Vérifiez votre connexion Internet
2. Vérifiez que vous êtes connecté en tant qu'administrateur
3. Vérifiez les logs de la console pour plus de détails

## Support

Pour toute question ou problème, consultez :
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Configuration Firebase
- [GUIDE_UTILISATION_ADMIN.md](GUIDE_UTILISATION_ADMIN.md) - Guide admin général
- README.md - Documentation générale

## Changelog

### Version 1.0.0 (2024)
- Création du système d'ingrédients universels
- 6 catégories d'ingrédients
- Interface d'administration complète
- Intégration temps réel avec Firestore
- Support multi-modal (client, staff, élégant)
