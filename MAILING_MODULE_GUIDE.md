# 📧 Guide du Module Mailing Marketing - Pizza Deli'Zza

## 📋 Vue d'ensemble

Le module Mailing Marketing permet aux administrateurs de Pizza Deli'Zza de créer, gérer et envoyer des campagnes d'emailing professionnelles directement depuis l'interface admin de l'application.

### ✨ Fonctionnalités principales

- 📄 **Modèles d'emails** : Création et gestion de templates HTML personnalisables
- 📬 **Campagnes** : Création, planification et envoi de campagnes d'emailing
- 👥 **Abonnés** : Gestion complète de la liste d'abonnés avec segmentation
- 🎨 **Design cohérent** : Templates en harmonie avec la charte graphique de l'app
- 🔒 **Conformité RGPD** : Système de consentement et désinscription

---

## 🎯 Accès au module

1. Connectez-vous avec un compte administrateur
2. Accédez au **Dashboard Admin**
3. Cliquez sur la carte **"Mailing - Marketing & Newsletters"**

---

## 📄 1. Gestion des Modèles d'emails

### Créer un nouveau modèle

1. Allez dans l'onglet **"Modèles"**
2. Cliquez sur **"Nouveau"**
3. Remplissez les champs :
   - **Nom du template** : Identifiant interne (ex: "Promo Weekend")
   - **Sujet de l'email** : Objet visible par les destinataires
   - **Texte du bouton CTA** : Texte du call-to-action
   - **URL du bouton CTA** : Lien de redirection
   - **URL de la bannière** : Image d'en-tête (optionnel)
   - **Code HTML** : Template complet avec variables

### Variables disponibles

Les templates supportent les variables suivantes :

| Variable | Description | Exemple |
|----------|-------------|---------|
| `{{subject}}` | Sujet de l'email | "Offre spéciale -20%" |
| `{{content}}` | Contenu principal | Texte descriptif |
| `{{product}}` | Nom du produit | "Pizza Margherita" |
| `{{discount}}` | Réduction | "-20%" |
| `{{ctaUrl}}` | URL du bouton | "https://delizza.fr/commander" |
| `{{ctaText}}` | Texte du bouton | "Commander maintenant" |
| `{{bannerUrl}}` | URL de la bannière | URL d'image |
| `{{unsubUrl}}` | Lien de désinscription | Généré automatiquement |
| `{{appDownloadUrl}}` | Lien vers l'app | Play Store / App Store |

### Templates prédéfinis

Le module inclut 3 templates prêts à l'emploi :

#### 1. **Template Standard**
- Design classique avec logo, bannière et CTA
- Adapté pour les newsletters générales
- Structure : Header rouge + Contenu + CTA + Footer

#### 2. **Template Promo**
- Mise en avant d'une réduction
- Badge de réduction visible (ex: "-20%")
- Design accrocheur pour les promotions

#### 3. **Template Nouveauté**
- Badge "NOUVEAUTÉ" mis en avant
- Image produit centrale
- Idéal pour lancer de nouveaux produits

### Prévisualiser un modèle

1. Cliquez sur l'icône **👁️ Prévisualiser**
2. Le template s'affiche avec des données de test
3. Vérifiez le rendu avant utilisation

### Modifier / Supprimer

- **Modifier** : Cliquez sur l'icône crayon ✏️
- **Supprimer** : Cliquez sur l'icône corbeille 🗑️

---

## 📬 2. Gestion des Campagnes

### Créer une campagne

1. Allez dans l'onglet **"Campagnes"**
2. Cliquez sur **"Nouvelle"**
3. Configurez la campagne :

#### Paramètres de base
- **Nom de la campagne** : Identifiant interne
- **Modèle d'email** : Sélectionnez un template
- **Segment de destinataires** :
  - `Tous les abonnés actifs` : Envoi à tous
  - `Clients VIP` : Uniquement les VIP
  - `Intéressés par les nouveautés` : Segment spécifique

#### Planification
- **Envoi immédiat** : La campagne part dès la création
- **Planification** : Choisissez une date et heure d'envoi

### États d'une campagne

| Statut | Description | Couleur |
|--------|-------------|---------|
| 🟦 Brouillon | En cours de création | Gris |
| 🔵 Planifiée | Programmée pour envoi futur | Bleu |
| 🟠 Envoi en cours | En cours d'envoi | Orange |
| 🟢 Envoyée | Envoi terminé avec succès | Vert |
| 🔴 Échouée | Erreur lors de l'envoi | Rouge |

### Statistiques de campagne

Pour les campagnes envoyées, consultez :
- **Envoyés** : Nombre d'emails délivrés
- **Ouverts** : Taux d'ouverture (future intégration)
- **Clics** : Clics sur les CTA (future intégration)

### Modifier / Supprimer

- **Modifier** : Cliquez sur l'icône crayon ✏️
- **Supprimer** : Cliquez sur l'icône corbeille 🗑️
- ⚠️ Les campagnes envoyées ne peuvent plus être modifiées

---

## 👥 3. Gestion des Abonnés

### Ajouter un abonné

1. Allez dans l'onglet **"Abonnés"**
2. Cliquez sur **"Nouveau"**
3. Renseignez :
   - **Email** : Adresse email valide
   - **Statut** : Actif / Désinscrit
   - **Tags** : Catégorisez l'abonné
   - **Consentement** : Opt-in obligatoire

### Tags disponibles

Les tags permettent de segmenter vos abonnés :

- `client` : Client standard
- `vip` : Client VIP / Premium
- `nouveautes` : Intéressé par les nouveautés
- `promotions` : Intéressé par les promotions

Vous pouvez assigner plusieurs tags à un même abonné.

### Filtrer les abonnés

Utilisez les filtres en haut de l'onglet :
- **Tous** : Affiche tous les abonnés
- **Actifs** : Uniquement les abonnés actifs
- **Désinscrits** : Ceux qui se sont désinscrits

### Statuts des abonnés

| Statut | Description | Icône |
|--------|-------------|-------|
| ✅ Actif | Reçoit les emails | 🟢 |
| ❌ Désinscrit | Ne reçoit plus d'emails | 🔴 |

### Désinscription

Les abonnés peuvent se désinscrire via :
1. Le lien "Se désinscrire" dans chaque email
2. Modification manuelle de leur statut par l'admin

⚠️ **Important RGPD** : Toujours respecter les demandes de désinscription.

---

## 🎨 Design des Emails

### Palette de couleurs

Les templates utilisent la charte graphique de Pizza Deli'Zza :

| Élément | Couleur | Usage |
|---------|---------|-------|
| Header | #E63946 (Rouge principal) | Logo et titre |
| Dégradé | #D62828 (Rouge foncé) | Effets visuels |
| CTA | #E63946 → #D62828 | Bouton d'action |
| Texte principal | #1D2D3D (Bleu foncé) | Contenu |
| Texte secondaire | #5A6C7D (Gris-bleu) | Descriptions |
| Background | #FFFFFF (Blanc) | Fond de l'email |

### Structure standard

```
┌─────────────────────────────┐
│  Header Rouge avec Logo     │
├─────────────────────────────┤
│  Bannière d'image (opt.)    │
├─────────────────────────────┤
│                             │
│  Titre principal            │
│  Contenu texte              │
│                             │
│  [ Bouton CTA Rouge ]       │
│                             │
├─────────────────────────────┤
│  Footer gris avec mentions  │
│  Lien de désinscription     │
└─────────────────────────────┘
```

### Responsive design

Les templates sont optimisés pour :
- 📱 **Mobile** : Largeur max 600px
- 💻 **Desktop** : Affichage optimal sur tous les écrans
- ✉️ **Clients email** : Compatible Gmail, Outlook, Apple Mail

---

## 🚀 Workflow d'utilisation

### Scénario 1 : Envoyer une promotion

1. **Créer le template**
   - Utilisez le "Template Promo"
   - Personnalisez le sujet et le CTA

2. **Ajouter des abonnés**
   - Importez vos contacts
   - Assignez le tag "promotions"

3. **Créer la campagne**
   - Sélectionnez le template
   - Choisissez le segment "promotions"
   - Envoi immédiat ou planifié

4. **Suivre les résultats**
   - Consultez les statistiques
   - Analysez le taux d'envoi

### Scénario 2 : Newsletter mensuelle

1. **Préparer le template**
   - Utilisez le "Template Standard"
   - Ajoutez le contenu du mois

2. **Définir l'audience**
   - Segment : "Tous les abonnés actifs"

3. **Planifier l'envoi**
   - Date : 1er du mois à 10h00
   - Statut : "Planifiée"

4. **Validation automatique**
   - L'envoi se fait automatiquement
   - Vérifiez les stats après envoi

---

## 🔧 Configuration technique

### Stockage des données

Les données sont stockées localement via SharedPreferences :

```
subscribers_list      → Liste des abonnés
email_templates_list  → Liste des templates
campaigns_list        → Liste des campagnes
```

### Collections Firestore (future)

Pour l'intégration Firebase :

```
/subscribers/{subscriberId}
  - email: string
  - status: 'active' | 'unsubscribed'
  - tags: string[]
  - consent: boolean
  - dateInscription: timestamp
  - unsubscribeToken: string

/email_templates/{templateId}
  - name: string
  - subject: string
  - htmlBody: string
  - variables: string[]
  - createdAt: timestamp
  - updatedAt: timestamp

/campaigns/{campaignId}
  - name: string
  - templateId: string
  - segment: string
  - scheduleAt: timestamp
  - status: string
  - stats: {
      totalRecipients: number
      sent: number
      failed: number
      opened: number
      clicked: number
    }
```

---

## 🔒 Sécurité et conformité RGPD

### Consentement (Opt-in)

- ✅ Case à cocher obligatoire lors de l'inscription
- ✅ Consentement explicite pour recevoir des emails
- ✅ Possibilité de retirer le consentement à tout moment

### Désinscription (Opt-out)

- ✅ Lien "Se désinscrire" dans chaque email
- ✅ Token unique par abonné pour sécurité
- ✅ Confirmation de désinscription automatique
- ✅ Impossible de réinscrire sans nouveau consentement

### Données stockées

Conformément au RGPD, nous stockons uniquement :
- Email (donnée personnelle minimale)
- Statut d'abonnement
- Tags de segmentation
- Date d'inscription
- Consentement explicite

### Droits des utilisateurs

Les abonnés peuvent :
- ✅ Accéder à leurs données
- ✅ Modifier leurs préférences
- ✅ Se désinscrire à tout moment
- ✅ Demander la suppression de leurs données

---

## 📊 Bonnes pratiques

### Fréquence d'envoi

- 🟢 **Recommandé** : 1-2 emails par semaine maximum
- ⚠️ **À éviter** : Plus de 3 emails par semaine
- ❌ **Spam** : Envois quotidiens

### Contenu des emails

1. **Objet accrocheur**
   - Court (< 50 caractères)
   - Clair et explicite
   - Incluez des emojis pertinents 🍕

2. **Contenu principal**
   - Message concis
   - Valeur ajoutée claire
   - Call-to-action visible

3. **Design**
   - Images optimisées (< 200 KB)
   - Texte lisible (min 14px)
   - Boutons cliquables (min 44x44px)

### Segmentation

Utilisez les tags pour cibler :
- **Nouveaux clients** : Offre de bienvenue
- **Clients VIP** : Offres exclusives
- **Inactifs** : Email de réengagement

### Tests

Avant chaque campagne :
1. ✅ Prévisualisez le template
2. ✅ Vérifiez tous les liens
3. ✅ Testez sur mobile
4. ✅ Envoyez-vous un email test

---

## 🆘 Dépannage

### Problème : "Template non trouvé"

**Solution** : Vérifiez que le template existe dans l'onglet Modèles.

### Problème : "Aucun abonné actif"

**Solution** : Ajoutez des abonnés ou vérifiez les filtres de segment.

### Problème : "Campagne échouée"

**Causes possibles** :
- Template invalide
- Segment vide
- Erreur de configuration

**Solution** : Vérifiez les logs et recréez la campagne.

### Problème : "Email non reçu"

**Vérifications** :
1. L'abonné est-il actif ?
2. Le consentement est-il donné ?
3. L'email est-il dans les spams ?

---

## 🔮 Futures améliorations

### En cours de développement

- [ ] Intégration Firebase Cloud Functions
- [ ] Envoi réel via SendGrid/Brevo
- [ ] Tracking d'ouverture des emails
- [ ] Tracking des clics sur les liens
- [ ] A/B testing des sujets
- [ ] Statistiques détaillées
- [ ] Import CSV d'abonnés
- [ ] Éditeur WYSIWYG pour templates

### Intégration stores

- [ ] Lien automatique Play Store
- [ ] Lien automatique App Store
- [ ] Deep links vers l'app

---

## 📞 Support

Pour toute question sur le module Mailing :

1. Consultez cette documentation
2. Vérifiez le fichier `functions/README.md` pour les Cloud Functions
3. Ouvrez une issue sur GitHub

---

## 📝 Changelog

### Version 1.0.0 (Novembre 2025)

#### ✅ Ajouté
- Module complet de mailing marketing
- 3 onglets : Modèles, Campagnes, Abonnés
- CRUD complet pour chaque section
- 3 templates prédéfinis
- Système de segmentation
- Prévisualisation des emails
- Système de tokens de désinscription
- Design cohérent avec l'app
- Documentation complète

#### 🎨 Design
- Palette de couleurs Pizza Deli'Zza
- Templates responsive
- Interface admin moderne
- Gradients et ombres

#### 🔒 Sécurité
- Consentement opt-in
- Liens de désinscription
- Tokens uniques par abonné
- Conformité RGPD

---

**Pizza Deli'Zza** - La meilleure pizza, les meilleurs emails ! 🍕📧
