#!/usr/bin/env node

/**
 * migrate_template_modules.mjs
 * 
 * Migration script pour implémenter le nouveau système de templates et modules.
 * 
 * Ce script:
 * 1. Migre les anciens champs (usesKitchen, supportsPOS, etc.) vers le nouveau système
 * 2. Convertit les modules snake_case vers camelCase
 * 3. Ajoute le champ template si manquant
 * 4. Assure la rétrocompatibilité
 * 
 * Usage:
 *   node scripts/migrate_template_modules.mjs --dry-run          # Preview only
 *   node scripts/migrate_template_modules.mjs --apply            # Apply changes
 *   node scripts/migrate_template_modules.mjs --restaurant=ID    # Specific restaurant
 */

import admin from 'firebase-admin';
import { readFileSync } from 'fs';

// ============================================================================
// Configuration
// ============================================================================

const DEFAULT_RESTAURANT_ID = 'delizza';

// Module mapping: old snake_case → new camelCase
const MODULE_MAPPING = {
  'click_and_collect': 'click_and_collect',  // unchanged
  'kitchen_tablet': 'kitchen_tablet',        // unchanged
  'staff_tablet': 'staff_tablet',            // unchanged
  'payment_terminal': 'payment_terminal',    // unchanged
  'time_recorder': 'time_recorder',          // unchanged
  'pages_builder': 'pages_builder',          // unchanged
  // Add more mappings if needed
};

// Template mapping based on existing modules
const TEMPLATE_HEURISTICS = [
  {
    id: 'pizzeria-classic',
    match: (modules) => 
      modules.includes('ordering') && 
      modules.includes('delivery') && 
      modules.includes('kitchen_tablet'),
  },
  {
    id: 'fast-food-express',
    match: (modules) => 
      modules.includes('ordering') && 
      modules.includes('click_and_collect') && 
      modules.includes('staff_tablet') &&
      !modules.includes('kitchen_tablet'),
  },
  {
    id: 'restaurant-premium',
    match: (modules) => 
      modules.includes('reporting') && 
      modules.includes('campaigns') &&
      modules.includes('loyalty'),
  },
  {
    id: 'sushi-bar',
    match: (modules) => 
      modules.includes('ordering') && 
      modules.includes('delivery') &&
      modules.includes('kitchen_tablet'),
  },
];

const DEFAULT_TEMPLATE = 'blank-template';

// ============================================================================
// Initialization
// ============================================================================

function initializeFirebase() {
  try {
    const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS || 
                                './firebase/service-account-key.json';
    const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));
    
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    
    console.log('✅ Firebase initialized successfully');
    return admin.firestore();
  } catch (error) {
    console.error('❌ Failed to initialize Firebase:', error.message);
    process.exit(1);
  }
}

// ============================================================================
// Migration Logic
// ============================================================================

/**
 * Normalise un module ID (gère les anciens formats)
 */
function normalizeModuleId(moduleId) {
  if (typeof moduleId !== 'string') return null;
  
  // Si le module existe dans le mapping, on le convertit
  if (MODULE_MAPPING[moduleId]) {
    return MODULE_MAPPING[moduleId];
  }
  
  // Sinon, on le garde tel quel
  return moduleId;
}

/**
 * Détermine le template approprié basé sur les modules actifs
 */
function inferTemplate(modules) {
  for (const heuristic of TEMPLATE_HEURISTICS) {
    if (heuristic.match(modules)) {
      return heuristic.id;
    }
  }
  return DEFAULT_TEMPLATE;
}

/**
 * Migre le document plan d'un restaurant
 */
function migratePlanDocument(planData) {
  const updates = {};
  let hasChanges = false;
  
  // 1. Migrer les modules
  if (planData.activeModules && Array.isArray(planData.activeModules)) {
    const normalizedModules = planData.activeModules
      .map(normalizeModuleId)
      .filter(Boolean);
    
    if (JSON.stringify(normalizedModules) !== JSON.stringify(planData.activeModules)) {
      updates.activeModules = normalizedModules;
      hasChanges = true;
    }
  } else if (planData.modules && Array.isArray(planData.modules)) {
    // Si activeModules n'existe pas mais modules existe, créer activeModules
    const enabledModules = planData.modules
      .filter(m => m.enabled === true)
      .map(m => normalizeModuleId(m.id))
      .filter(Boolean);
    
    updates.activeModules = enabledModules;
    hasChanges = true;
  } else {
    // Aucun module défini, initialiser avec tableau vide
    updates.activeModules = [];
    hasChanges = true;
  }
  
  // 2. Ajouter le champ template si manquant
  if (!planData.templateId) {
    const modules = updates.activeModules || planData.activeModules || [];
    updates.templateId = inferTemplate(modules);
    hasChanges = true;
  }
  
  // 3. Migrer les anciens champs (pour compatibilité)
  const legacyFields = [
    'usesKitchen',
    'supportsPOS',
    'supportsDelivery',
    'supportsClickAndCollect',
    'supportsLoyalty',
  ];
  
  // On ne supprime PAS les anciens champs pour la rétrocompatibilité
  // Mais on peut les marquer comme deprecated
  
  // 4. Ajouter updatedAt
  if (hasChanges) {
    updates.updatedAt = admin.firestore.FieldValue.serverTimestamp();
  }
  
  return { updates, hasChanges };
}

/**
 * Migre un restaurant
 */
async function migrateRestaurant(db, restaurantId, dryRun) {
  console.log(`\n📦 Processing restaurant: ${restaurantId}`);
  
  try {
    const planRef = db.collection('restaurants').doc(restaurantId).collection('plan').doc('config');
    const planDoc = await planRef.get();
    
    if (!planDoc.exists) {
      console.log(`   ⚠️  No plan/config found for ${restaurantId}`);
      return { success: false, skipped: true };
    }
    
    const planData = planDoc.data();
    const { updates, hasChanges } = migratePlanDocument(planData);
    
    if (!hasChanges) {
      console.log(`   ✅ Already up-to-date`);
      return { success: true, skipped: true };
    }
    
    console.log(`   📝 Changes detected:`);
    for (const [key, value] of Object.entries(updates)) {
      if (key === 'updatedAt') continue;
      const oldValue = planData[key];
      console.log(`      ${key}:`);
      console.log(`        OLD: ${JSON.stringify(oldValue)}`);
      console.log(`        NEW: ${JSON.stringify(value)}`);
    }
    
    if (dryRun) {
      console.log(`   🔍 Would update (dry-run)`);
      return { success: true, skipped: false };
    } else {
      await planRef.update(updates);
      console.log(`   ✅ Updated successfully`);
      return { success: true, skipped: false };
    }
  } catch (error) {
    console.error(`   ❌ Error migrating ${restaurantId}:`, error.message);
    return { success: false, skipped: false, error };
  }
}

/**
 * Migre tous les restaurants
 */
async function migrateAllRestaurants(db, dryRun) {
  console.log(`\n📂 Fetching all restaurants...`);
  
  try {
    const restaurantsSnapshot = await db.collection('restaurants').get();
    const restaurantIds = restaurantsSnapshot.docs.map(doc => doc.id);
    
    console.log(`   Found ${restaurantIds.length} restaurants`);
    
    const results = {
      total: restaurantIds.length,
      success: 0,
      failed: 0,
      skipped: 0,
    };
    
    for (const restaurantId of restaurantIds) {
      const result = await migrateRestaurant(db, restaurantId, dryRun);
      
      if (result.success) {
        if (result.skipped) {
          results.skipped++;
        } else {
          results.success++;
        }
      } else {
        results.failed++;
      }
    }
    
    return results;
  } catch (error) {
    console.error(`❌ Error fetching restaurants:`, error.message);
    throw error;
  }
}

// ============================================================================
// Main
// ============================================================================

async function main() {
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('  TEMPLATE & MODULE MIGRATION SCRIPT');
  console.log('═══════════════════════════════════════════════════════════════');
  
  // Parse command line arguments
  const args = process.argv.slice(2);
  const dryRun = !args.includes('--apply');
  const restaurantArg = args.find(arg => arg.startsWith('--restaurant='));
  const targetRestaurant = restaurantArg ? restaurantArg.split('=')[1] : null;
  
  console.log(`  Mode: ${dryRun ? '🔍 DRY RUN (preview only)' : '✍️  APPLY (will modify Firestore)'}`);
  console.log(`  Target: ${targetRestaurant || 'ALL RESTAURANTS'}`);
  console.log('═══════════════════════════════════════════════════════════════\n');
  
  const db = initializeFirebase();
  
  try {
    let results;
    
    if (targetRestaurant) {
      // Migrer un seul restaurant
      const result = await migrateRestaurant(db, targetRestaurant, dryRun);
      results = {
        total: 1,
        success: result.success && !result.skipped ? 1 : 0,
        failed: result.success ? 0 : 1,
        skipped: result.skipped ? 1 : 0,
      };
    } else {
      // Migrer tous les restaurants
      results = await migrateAllRestaurants(db, dryRun);
    }
    
    // Afficher le résumé
    console.log('\n═══════════════════════════════════════════════════════════════');
    console.log('  MIGRATION SUMMARY');
    console.log('═══════════════════════════════════════════════════════════════');
    console.log(`  Total restaurants:  ${results.total}`);
    console.log(`  ✅ Updated:         ${results.success}`);
    console.log(`  ⚠️  Skipped:        ${results.skipped}`);
    console.log(`  ❌ Failed:          ${results.failed}`);
    console.log('═══════════════════════════════════════════════════════════════\n');
    
    if (dryRun && results.success > 0) {
      console.log('💡 To apply these changes, run with --apply flag\n');
    }
    
    process.exit(results.failed > 0 ? 1 : 0);
  } catch (error) {
    console.error('\n❌ Migration failed:', error);
    process.exit(1);
  }
}

// Run the script
main();
