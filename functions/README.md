# 📧 Cloud Functions pour le Module Mailing

Ce répertoire contient les Cloud Functions nécessaires pour l'envoi des campagnes d'emailing via Firebase Cloud Functions.

## 🎯 Fonctionnalités

### 1. Fonction `sendCampaign`

Fonction principale pour l'envoi de campagnes d'emailing.

**Déclencheur:** HTTP callable ou Firestore trigger
**Fournisseur d'envoi:** SendGrid ou Brevo (configurable)

#### Paramètres

```typescript
{
  campaignId: string,
  batchSize?: number  // Par défaut: 500
}
```

#### Fonctionnement

1. Récupère la campagne depuis Firestore (collection `campaigns`)
2. Charge le template email associé (collection `email_templates`)
3. Filtre les abonnés selon le segment défini (collection `subscribers`)
4. Compile le template avec les variables
5. Envoie les emails par batch (max 500 par batch)
6. Met à jour les statistiques de la campagne

#### Exemple de code

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// Configuration du fournisseur d'emails
const SENDGRID_API_KEY = functions.config().sendgrid.apikey;
const BREVO_API_KEY = functions.config().brevo.apikey;
const EMAIL_PROVIDER = functions.config().email.provider || 'sendgrid'; // 'sendgrid' ou 'brevo'

export const sendCampaign = functions.https.onCall(async (data, context) => {
  // Vérification de l'authentification admin
  if (!context.auth || context.auth.token.role !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Seuls les administrateurs peuvent envoyer des campagnes'
    );
  }

  const { campaignId, batchSize = 500 } = data;

  try {
    // 1. Récupérer la campagne
    const campaignDoc = await admin.firestore()
      .collection('campaigns')
      .doc(campaignId)
      .get();

    if (!campaignDoc.exists) {
      throw new Error('Campagne non trouvée');
    }

    const campaign = campaignDoc.data();

    // 2. Récupérer le template
    const templateDoc = await admin.firestore()
      .collection('email_templates')
      .doc(campaign.templateId)
      .get();

    if (!templateDoc.exists) {
      throw new Error('Template non trouvé');
    }

    const template = templateDoc.data();

    // 3. Récupérer les abonnés selon le segment
    let subscribersQuery = admin.firestore()
      .collection('subscribers')
      .where('status', '==', 'active')
      .where('consent', '==', true);

    if (campaign.segment !== 'all') {
      subscribersQuery = subscribersQuery.where('tags', 'array-contains', campaign.segment);
    }

    const subscribersSnapshot = await subscribersQuery.get();
    const subscribers = subscribersSnapshot.docs.map(doc => doc.data());

    // 4. Mettre à jour le statut de la campagne
    await campaignDoc.ref.update({
      status: 'sending',
      stats: {
        totalRecipients: subscribers.length,
        sent: 0,
        failed: 0,
        opened: 0,
        clicked: 0
      }
    });

    // 5. Envoyer les emails par batch
    let sentCount = 0;
    let failedCount = 0;

    for (let i = 0; i < subscribers.length; i += batchSize) {
      const batch = subscribers.slice(i, i + batchSize);

      for (const subscriber of batch) {
        try {
          // Compiler le template avec les variables
          const compiledHtml = compileTemplate(template.htmlBody, {
            subject: template.subject,
            content: campaign.content || 'Découvrez nos offres',
            product: campaign.product || 'Pizza Margherita',
            discount: campaign.discount || '-20%',
            ctaUrl: template.ctaUrl || 'https://delizza.fr/commander',
            ctaText: template.ctaText || 'Commander maintenant',
            bannerUrl: template.bannerUrl || '',
            unsubUrl: `https://delizza.fr/unsubscribe/${subscriber.unsubscribeToken}`,
            appDownloadUrl: 'https://play.google.com/store/apps/details?id=fr.delizza'
          });

          // Envoyer l'email via le fournisseur configuré
          if (EMAIL_PROVIDER === 'sendgrid') {
            await sendWithSendGrid(
              subscriber.email,
              template.subject,
              compiledHtml
            );
          } else if (EMAIL_PROVIDER === 'brevo') {
            await sendWithBrevo(
              subscriber.email,
              template.subject,
              compiledHtml
            );
          }

          sentCount++;
        } catch (error) {
          console.error(`Erreur envoi à ${subscriber.email}:`, error);
          failedCount++;
        }
      }

      // Pause entre les batches pour éviter les limites de taux
      await new Promise(resolve => setTimeout(resolve, 1000));
    }

    // 6. Mettre à jour les statistiques finales
    await campaignDoc.ref.update({
      status: 'sent',
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      'stats.sent': sentCount,
      'stats.failed': failedCount
    });

    return {
      success: true,
      sent: sentCount,
      failed: failedCount,
      total: subscribers.length
    };

  } catch (error) {
    console.error('Erreur lors de l\'envoi de la campagne:', error);
    
    // Mettre à jour le statut en cas d'erreur
    await admin.firestore()
      .collection('campaigns')
      .doc(campaignId)
      .update({ status: 'failed' });

    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Fonction helper pour compiler le template
function compileTemplate(html: string, variables: Record<string, string>): string {
  let compiled = html;
  Object.entries(variables).forEach(([key, value]) => {
    compiled = compiled.replace(new RegExp(`{{${key}}}`, 'g'), value);
  });
  return compiled;
}

// Fonction d'envoi avec SendGrid
async function sendWithSendGrid(to: string, subject: string, html: string) {
  const sgMail = require('@sendgrid/mail');
  sgMail.setApiKey(SENDGRID_API_KEY);

  const msg = {
    to,
    from: 'contact@delizza.fr',
    subject,
    html
  };

  await sgMail.send(msg);
}

// Fonction d'envoi avec Brevo
async function sendWithBrevo(to: string, subject: string, html: string) {
  const axios = require('axios');

  await axios.post('https://api.brevo.com/v3/smtp/email', {
    sender: { email: 'contact@delizza.fr', name: 'Pizza Deli\'Zza' },
    to: [{ email: to }],
    subject,
    htmlContent: html
  }, {
    headers: {
      'api-key': BREVO_API_KEY,
      'Content-Type': 'application/json'
    }
  });
}
```

### 2. Route `unsubscribe`

Route HTTP pour gérer les désinscriptions automatiques.

**URL:** `https://[REGION]-[PROJECT].cloudfunctions.net/unsubscribe?token=TOKEN`

#### Exemple de code

```typescript
export const unsubscribe = functions.https.onRequest(async (req, res) => {
  const token = req.query.token as string;

  if (!token) {
    res.status(400).send('Token manquant');
    return;
  }

  try {
    // Rechercher l'abonné par token
    const subscribersSnapshot = await admin.firestore()
      .collection('subscribers')
      .where('unsubscribeToken', '==', token)
      .limit(1)
      .get();

    if (subscribersSnapshot.empty) {
      res.status(404).send('Abonné non trouvé');
      return;
    }

    const subscriberDoc = subscribersSnapshot.docs[0];

    // Mettre à jour le statut
    await subscriberDoc.ref.update({
      status: 'unsubscribed',
      consent: false,
      unsubscribedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Page de confirmation
    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Désinscription réussie</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
            background-color: #f5f5f5;
          }
          .container {
            max-width: 500px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
          }
          h1 { color: #E63946; }
          p { color: #5A6C7D; line-height: 1.6; }
          .icon { font-size: 48px; margin-bottom: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="icon">✓</div>
          <h1>Désinscription réussie</h1>
          <p>Vous ne recevrez plus d'emails promotionnels de Pizza Deli'Zza.</p>
          <p>Vous nous manquerez ! 🍕</p>
        </div>
      </body>
      </html>
    `);

  } catch (error) {
    console.error('Erreur lors de la désinscription:', error);
    res.status(500).send('Erreur lors de la désinscription');
  }
});
```

## 🚀 Déploiement

### 1. Installation des dépendances

```bash
cd functions
npm install
```

### 2. Configuration des variables d'environnement

#### Option A: SendGrid

```bash
firebase functions:config:set sendgrid.apikey="YOUR_SENDGRID_API_KEY"
firebase functions:config:set email.provider="sendgrid"
```

#### Option B: Brevo (Sendinblue)

```bash
firebase functions:config:set brevo.apikey="YOUR_BREVO_API_KEY"
firebase functions:config:set email.provider="brevo"
```

### 3. Déployer les fonctions

```bash
firebase deploy --only functions
```

## 📦 Dépendances requises

Fichier `package.json`:

```json
{
  "name": "functions",
  "description": "Cloud Functions for Pizza Delizza Mailing",
  "scripts": {
    "build": "tsc",
    "serve": "npm run build && firebase emulators:start --only functions",
    "shell": "npm run build && firebase functions:shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "engines": {
    "node": "18"
  },
  "main": "lib/index.js",
  "dependencies": {
    "firebase-admin": "^11.8.0",
    "firebase-functions": "^4.3.1",
    "@sendgrid/mail": "^7.7.0",
    "axios": "^1.4.0"
  },
  "devDependencies": {
    "typescript": "^4.9.5",
    "@typescript-eslint/eslint-plugin": "^5.12.0",
    "@typescript-eslint/parser": "^5.12.0",
    "eslint": "^8.9.0",
    "eslint-config-google": "^0.14.0",
    "eslint-plugin-import": "^2.25.4"
  },
  "private": true
}
```

## 🔒 Sécurité

### Règles Firestore recommandées

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Abonnés: lecture publique pour vérification, écriture admin uniquement
    match /subscribers/{subscriberId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.role == 'admin';
    }
    
    // Templates: admin uniquement
    match /email_templates/{templateId} {
      allow read, write: if request.auth.token.role == 'admin';
    }
    
    // Campagnes: admin uniquement
    match /campaigns/{campaignId} {
      allow read, write: if request.auth.token.role == 'admin';
    }
  }
}
```

## 📊 Monitoring

### Logs Cloud Functions

```bash
# Voir les logs en temps réel
firebase functions:log --only sendCampaign

# Voir les logs d'une période spécifique
firebase functions:log --since 1d
```

### Métriques à surveiller

- Taux de succès d'envoi (sent / total)
- Temps d'exécution moyen
- Erreurs de fournisseur d'email
- Limites de quota atteintes

## 🔄 Planification des campagnes

Pour les campagnes planifiées, utiliser Firebase Cloud Scheduler:

```typescript
export const checkScheduledCampaigns = functions.pubsub
  .schedule('every 15 minutes')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    
    const scheduledCampaigns = await admin.firestore()
      .collection('campaigns')
      .where('status', '==', 'scheduled')
      .where('scheduleAt', '<=', now.toDate())
      .get();

    for (const doc of scheduledCampaigns.docs) {
      // Déclencher l'envoi de la campagne
      await sendCampaign({ campaignId: doc.id }, { auth: { token: { role: 'admin' } } });
    }
  });
```

## 📝 Notes importantes

1. **Limites SendGrid gratuit:** 100 emails/jour
2. **Limites Brevo gratuit:** 300 emails/jour
3. **Batch size recommandé:** 500 emails pour éviter les timeouts
4. **Timeout Cloud Functions:** Augmenter à 540s pour les grandes campagnes
5. **RGPD:** Toujours inclure un lien de désinscription fonctionnel

## 🧪 Tests

Pour tester localement avec l'émulateur Firebase:

```bash
npm run serve
```

Puis appeler la fonction:

```javascript
// Dans votre app Flutter
final callable = FirebaseFunctions.instance.httpsCallable('sendCampaign');
final result = await callable.call({
  'campaignId': 'test-campaign-id',
  'batchSize': 100
});
```

## 📚 Ressources

- [Documentation SendGrid](https://docs.sendgrid.com/api-reference)
- [Documentation Brevo](https://developers.brevo.com/)
- [Firebase Cloud Functions](https://firebase.google.com/docs/functions)
- [Firebase Cloud Scheduler](https://firebase.google.com/docs/functions/schedule-functions)
