/**
 * Cloud Functions for Pizza Deli'Zza Mailing Module
 * 
 * Ce fichier contient les Cloud Functions nécessaires pour:
 * - Envoyer des campagnes d'emailing
 * - Gérer les désinscriptions automatiques
 * - Planifier les envois programmés
 * 
 * Voir functions/README.md pour la documentation complète
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// Configuration du fournisseur d'emails
const SENDGRID_API_KEY = functions.config().sendgrid?.apikey;
const BREVO_API_KEY = functions.config().brevo?.apikey;
const EMAIL_PROVIDER = functions.config().email?.provider || 'sendgrid';

/**
 * Fonction principale pour envoyer une campagne d'emailing
 * 
 * @param data.campaignId - ID de la campagne à envoyer
 * @param data.batchSize - Taille des lots (défaut: 500)
 * @returns Statistiques d'envoi
 */
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
      .doc(campaign!.templateId)
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

    if (campaign!.segment !== 'all') {
      subscribersQuery = subscribersQuery.where('tags', 'array-contains', campaign!.segment);
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
          const compiledHtml = compileTemplate(template!.htmlBody, {
            subject: template!.subject,
            content: campaign!.content || 'Découvrez nos offres',
            product: campaign!.product || 'Pizza Margherita',
            discount: campaign!.discount || '-20%',
            ctaUrl: template!.ctaUrl || 'https://delizza.fr/commander',
            ctaText: template!.ctaText || 'Commander maintenant',
            bannerUrl: template!.bannerUrl || '',
            unsubUrl: `https://delizza.fr/unsubscribe?token=${subscriber.unsubscribeToken}`,
            appDownloadUrl: 'https://play.google.com/store/apps/details?id=fr.delizza'
          });

          // Envoyer l'email via le fournisseur configuré
          if (EMAIL_PROVIDER === 'sendgrid') {
            await sendWithSendGrid(
              subscriber.email,
              template!.subject,
              compiledHtml
            );
          } else if (EMAIL_PROVIDER === 'brevo') {
            await sendWithBrevo(
              subscriber.email,
              template!.subject,
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

    throw new functions.https.HttpsError('internal', (error as Error).message);
  }
});

/**
 * Route HTTP pour gérer les désinscriptions automatiques
 * URL: https://[REGION]-[PROJECT].cloudfunctions.net/unsubscribe?token=TOKEN
 */
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
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
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
          h1 { color: #E63946; margin-bottom: 20px; }
          p { color: #5A6C7D; line-height: 1.6; }
          .icon { font-size: 64px; margin-bottom: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="icon">✓</div>
          <h1>Désinscription réussie</h1>
          <p>Vous ne recevrez plus d'emails promotionnels de Pizza Deli'Zza.</p>
          <p>Nous espérons vous revoir bientôt ! 🍕</p>
        </div>
      </body>
      </html>
    `);

  } catch (error) {
    console.error('Erreur lors de la désinscription:', error);
    res.status(500).send('Erreur lors de la désinscription');
  }
});

/**
 * Fonction planifiée pour vérifier et envoyer les campagnes programmées
 * Exécutée toutes les 15 minutes
 */
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
      try {
        // Déclencher l'envoi de la campagne
        // Note: Dans un environnement réel, utilisez une file d'attente (Pub/Sub)
        console.log(`Envoi de la campagne planifiée: ${doc.id}`);
        
        // Simuler l'envoi (à remplacer par un appel à sendCampaign)
        await doc.ref.update({
          status: 'sending'
        });
        
      } catch (error) {
        console.error(`Erreur lors de l'envoi de la campagne ${doc.id}:`, error);
      }
    }
    
    return null;
  });

// ============= Fonctions helpers =============

/**
 * Compile un template HTML avec les variables fournies
 */
function compileTemplate(html: string, variables: Record<string, string>): string {
  let compiled = html;
  Object.entries(variables).forEach(([key, value]) => {
    compiled = compiled.replace(new RegExp(`{{${key}}}`, 'g'), value);
  });
  return compiled;
}

/**
 * Envoie un email via SendGrid
 */
async function sendWithSendGrid(to: string, subject: string, html: string): Promise<void> {
  if (!SENDGRID_API_KEY) {
    throw new Error('SendGrid API key non configurée');
  }

  const sgMail = require('@sendgrid/mail');
  sgMail.setApiKey(SENDGRID_API_KEY);

  const msg = {
    to,
    from: {
      email: 'contact@delizza.fr',
      name: 'Pizza Deli\'Zza'
    },
    subject,
    html
  };

  await sgMail.send(msg);
}

/**
 * Envoie un email via Brevo (Sendinblue)
 */
async function sendWithBrevo(to: string, subject: string, html: string): Promise<void> {
  if (!BREVO_API_KEY) {
    throw new Error('Brevo API key non configurée');
  }

  const axios = require('axios');

  await axios.post('https://api.brevo.com/v3/smtp/email', {
    sender: { 
      email: 'contact@delizza.fr', 
      name: 'Pizza Deli\'Zza' 
    },
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
