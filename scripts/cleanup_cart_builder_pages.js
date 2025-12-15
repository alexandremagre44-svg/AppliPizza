#!/usr/bin/env node
/**
 * Cleanup Script: Remove Cart Builder Pages from Firestore
 * 
 * This script removes all cart pages from pages_draft and pages_published
 * collections across all restaurants in Firestore.
 * 
 * Cart pages violate the WL Doctrine and should NEVER exist in Builder.
 * 
 * Usage:
 *   node scripts/cleanup_cart_builder_pages.js
 * 
 * Requirements:
 *   - Firebase Admin SDK initialized
 *   - Service account credentials configured
 */

const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
// Make sure you have a service account key file configured
if (!admin.apps.length) {
  try {
    // Try to use default credentials (Cloud Functions, App Engine, etc.)
    admin.initializeApp({
      credential: admin.credential.applicationDefault()
    });
    console.log('✅ Firebase Admin initialized with default credentials');
  } catch (error) {
    console.error('❌ Failed to initialize Firebase Admin:', error.message);
    console.error('Please configure Firebase Admin credentials:');
    console.error('  - Set GOOGLE_APPLICATION_CREDENTIALS environment variable');
    console.error('  - Or provide service account key file');
    process.exit(1);
  }
}

const db = admin.firestore();

/**
 * Main cleanup function
 */
async function cleanupCartPages() {
  console.log('🔍 Starting cart page cleanup...\n');
  
  let totalDeleted = 0;
  let totalChecked = 0;
  const results = {
    draft: [],
    published: [],
    errors: []
  };
  
  try {
    // Get all restaurants
    const restaurantsSnapshot = await db.collection('restaurants').get();
    console.log(`📊 Found ${restaurantsSnapshot.size} restaurants to check\n`);
    
    for (const restaurantDoc of restaurantsSnapshot.docs) {
      const restaurantId = restaurantDoc.id;
      const restaurantName = restaurantDoc.data()?.name || restaurantId;
      totalChecked++;
      
      console.log(`🏪 Checking restaurant: ${restaurantName} (${restaurantId})`);
      
      // Check and delete pages_draft/cart
      try {
        const draftRef = db.doc(`restaurants/${restaurantId}/pages_draft/cart`);
        const draftDoc = await draftRef.get();
        
        if (draftDoc.exists) {
          const data = draftDoc.data();
          await draftRef.delete();
          totalDeleted++;
          results.draft.push({
            restaurantId,
            restaurantName,
            data: {
              name: data?.name,
              route: data?.route,
              createdAt: data?.createdAt,
            }
          });
          console.log(`  ✅ Deleted pages_draft/cart`);
        } else {
          console.log(`  ℹ️  No draft cart page found`);
        }
      } catch (error) {
        console.error(`  ❌ Error deleting draft cart page: ${error.message}`);
        results.errors.push({
          restaurantId,
          type: 'draft',
          error: error.message
        });
      }
      
      // Check and delete pages_published/cart
      try {
        const publishedRef = db.doc(`restaurants/${restaurantId}/pages_published/cart`);
        const publishedDoc = await publishedRef.get();
        
        if (publishedDoc.exists) {
          const data = publishedDoc.data();
          await publishedRef.delete();
          totalDeleted++;
          results.published.push({
            restaurantId,
            restaurantName,
            data: {
              name: data?.name,
              route: data?.route,
              publishedAt: data?.publishedAt,
            }
          });
          console.log(`  ✅ Deleted pages_published/cart`);
        } else {
          console.log(`  ℹ️  No published cart page found`);
        }
      } catch (error) {
        console.error(`  ❌ Error deleting published cart page: ${error.message}`);
        results.errors.push({
          restaurantId,
          type: 'published',
          error: error.message
        });
      }
      
      console.log(''); // Empty line for readability
    }
    
    // Final summary
    console.log('═══════════════════════════════════════════════════════');
    console.log('                  CLEANUP SUMMARY');
    console.log('═══════════════════════════════════════════════════════\n');
    console.log(`📊 Total restaurants checked: ${totalChecked}`);
    console.log(`🗑️  Total pages deleted: ${totalDeleted}`);
    console.log(`   - Draft pages: ${results.draft.length}`);
    console.log(`   - Published pages: ${results.published.length}`);
    console.log(`❌ Errors encountered: ${results.errors.length}\n`);
    
    // Detailed results
    if (results.draft.length > 0) {
      console.log('📋 Draft pages deleted:');
      results.draft.forEach(r => {
        console.log(`   - ${r.restaurantName}: ${r.data.name || 'Unnamed'} (${r.data.route || 'No route'})`);
      });
      console.log('');
    }
    
    if (results.published.length > 0) {
      console.log('📋 Published pages deleted:');
      results.published.forEach(r => {
        console.log(`   - ${r.restaurantName}: ${r.data.name || 'Unnamed'} (${r.data.route || 'No route'})`);
      });
      console.log('');
    }
    
    if (results.errors.length > 0) {
      console.log('⚠️  Errors:');
      results.errors.forEach(e => {
        console.log(`   - ${e.restaurantId} (${e.type}): ${e.error}`);
      });
      console.log('');
    }
    
    // Verification
    console.log('🔍 Running verification...\n');
    await verifyCleanup();
    
    console.log('✅ Cart page cleanup completed successfully!\n');
    
  } catch (error) {
    console.error('❌ Fatal error during cleanup:', error);
    throw error;
  }
}

/**
 * Verify that no cart pages remain in Firestore
 */
async function verifyCleanup() {
  try {
    // Use collectionGroup to search across all restaurants
    const draftPages = await db.collectionGroup('pages_draft')
      .where('pageId', '==', 'cart')
      .get();
    
    const publishedPages = await db.collectionGroup('pages_published')
      .where('pageId', '==', 'cart')
      .get();
    
    console.log(`   Cart draft pages remaining: ${draftPages.size}`);
    console.log(`   Cart published pages remaining: ${publishedPages.size}\n`);
    
    if (draftPages.size > 0 || publishedPages.size > 0) {
      console.error('⚠️  WARNING: Some cart pages still exist in Firestore!');
      console.error('   Manual cleanup may be required.');
      
      if (draftPages.size > 0) {
        console.error('\n   Remaining draft pages:');
        draftPages.forEach(doc => {
          console.error(`     - ${doc.ref.path}`);
        });
      }
      
      if (publishedPages.size > 0) {
        console.error('\n   Remaining published pages:');
        publishedPages.forEach(doc => {
          console.error(`     - ${doc.ref.path}`);
        });
      }
      
      return false;
    } else {
      console.log('   ✅ Verification passed: No cart pages found\n');
      return true;
    }
  } catch (error) {
    console.error('❌ Error during verification:', error.message);
    return false;
  }
}

/**
 * Dry run mode - check what would be deleted without actually deleting
 */
async function dryRun() {
  console.log('🔍 Running in DRY RUN mode (no changes will be made)...\n');
  
  try {
    const restaurantsSnapshot = await db.collection('restaurants').get();
    console.log(`📊 Found ${restaurantsSnapshot.size} restaurants\n`);
    
    let draftCount = 0;
    let publishedCount = 0;
    
    for (const restaurantDoc of restaurantsSnapshot.docs) {
      const restaurantId = restaurantDoc.id;
      const restaurantName = restaurantDoc.data()?.name || restaurantId;
      
      const draftRef = db.doc(`restaurants/${restaurantId}/pages_draft/cart`);
      const publishedRef = db.doc(`restaurants/${restaurantId}/pages_published/cart`);
      
      const [draftDoc, publishedDoc] = await Promise.all([
        draftRef.get(),
        publishedRef.get()
      ]);
      
      if (draftDoc.exists || publishedDoc.exists) {
        console.log(`🏪 ${restaurantName} (${restaurantId})`);
        if (draftDoc.exists) {
          console.log(`   - Would delete: pages_draft/cart`);
          draftCount++;
        }
        if (publishedDoc.exists) {
          console.log(`   - Would delete: pages_published/cart`);
          publishedCount++;
        }
      }
    }
    
    console.log('\n═══════════════════════════════════════════════════════');
    console.log(`📊 Total pages that would be deleted: ${draftCount + publishedCount}`);
    console.log(`   - Draft: ${draftCount}`);
    console.log(`   - Published: ${publishedCount}`);
    console.log('═══════════════════════════════════════════════════════\n');
    
  } catch (error) {
    console.error('❌ Error during dry run:', error);
    throw error;
  }
}

// Main execution
const args = process.argv.slice(2);
const isDryRun = args.includes('--dry-run') || args.includes('-d');

if (isDryRun) {
  dryRun()
    .then(() => process.exit(0))
    .catch(error => {
      console.error('Script failed:', error);
      process.exit(1);
    });
} else {
  console.log('⚠️  WARNING: This script will DELETE cart pages from Firestore!');
  console.log('   Use --dry-run flag to preview changes without deleting.\n');
  console.log('⚠️  IMPORTANT: Before running in production:');
  console.log('   1. Create a backup of your Firestore database');
  console.log('   2. Test the script on a non-production environment first');
  console.log('   3. Review the dry-run output carefully');
  console.log('   4. Have a rollback plan ready\n');
  console.log('   Firestore backups: https://console.firebase.google.com/project/_/firestore/backups\n');
  
  cleanupCartPages()
    .then(() => process.exit(0))
    .catch(error => {
      console.error('Script failed:', error);
      process.exit(1);
    });
}
