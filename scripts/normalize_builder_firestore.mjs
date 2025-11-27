#!/usr/bin/env node
/**
 * normalize_builder_firestore.mjs
 * 
 * Script to normalize Builder B3 Firestore data for restaurants/{restaurantId}.
 * 
 * Collections processed:
 * - pages_system (navigation config)
 * - pages_published (runtime page content)
 * - pages_draft (editor page content)
 * 
 * Usage:
 *   node scripts/normalize_builder_firestore.mjs [options]
 * 
 * Options:
 *   --dry-run              Preview changes without writing to Firestore (default)
 *   --apply                Apply changes to Firestore (use with caution)
 *   --restaurant=<id>      Target restaurant ID (default: delizza)
 * 
 * Examples:
 *   node scripts/normalize_builder_firestore.mjs                           # Dry run for delizza
 *   node scripts/normalize_builder_firestore.mjs --apply                   # Apply to delizza
 *   node scripts/normalize_builder_firestore.mjs --restaurant=pizza_roma   # Dry run for pizza_roma
 * 
 * Prerequisites:
 *   - Firebase Admin SDK: npm install firebase-admin
 *   - Service account key file at: ./firebase/service-account-key.json
 *     OR set GOOGLE_APPLICATION_CREDENTIALS environment variable
 * 
 * What this script does:
 *   1. pages_system:
 *      - If name absent and title present: copy title → name
 *      - If route absent/empty/'/': set correct route
 *        - System pages: /home, /menu, /cart, /profile, /rewards, /roulette
 *        - Custom pages: /page/<docId>
 *      - If bottomNavIndex absent: use order if 0-4, else null
 *      - Ensure pageId and pageKey are set
 *   
 *   2. pages_published / pages_draft:
 *      - Ensure draftLayout/publishedLayout are arrays (not null/string)
 *      - Ensure each block has an 'id' field (generate if missing)
 *      - Ensure pageId and pageKey are set
 *      - Ensure route follows correct format
 *   
 *   3. Logs all changes clearly (before/after)
 */

import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { readFileSync, existsSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { randomUUID } from 'crypto';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Configuration
// Restaurant ID can be set via --restaurant=<id> argument, defaults to 'delizza'
const restaurantArg = process.argv.find(arg => arg.startsWith('--restaurant='));
const RESTAURANT_ID = restaurantArg ? restaurantArg.split('=')[1] : 'delizza';
const DRY_RUN = !process.argv.includes('--apply');

// Known system pages configuration
const SYSTEM_PAGES = {
  home: {
    name: 'Accueil',
    route: '/home',
    icon: 'home',
    bottomNavIndex: 0,
    order: 0,
  },
  menu: {
    name: 'Menu',
    route: '/menu',
    icon: 'restaurant_menu',
    bottomNavIndex: 1,
    order: 1,
  },
  cart: {
    name: 'Panier',
    route: '/cart',
    icon: 'shopping_cart',
    bottomNavIndex: 2,
    order: 2,
  },
  profile: {
    name: 'Profil',
    route: '/profile',
    icon: 'person',
    bottomNavIndex: 3,
    order: 3,
  },
  roulette: {
    name: 'Roulette',
    route: '/roulette',
    icon: 'casino',
    bottomNavIndex: null,
    order: 10,
  },
  rewards: {
    name: 'Récompenses',
    route: '/rewards',
    icon: 'card_giftcard',
    bottomNavIndex: null,
    order: 11,
  },
};

// Minimal system block for each system page type
const MINIMAL_SYSTEM_BLOCKS = {
  home: [
    {
      id: 'system_hero_home',
      type: 'hero',
      order: 0,
      isActive: true,
      visibility: 'visible',
      config: {
        title: 'Bienvenue',
        subtitle: 'Découvrez nos délicieuses pizzas',
      },
    },
  ],
  menu: [
    {
      id: 'system_menu_catalog',
      type: 'system',
      moduleType: 'menu_catalog',
      order: 0,
      isActive: true,
      visibility: 'visible',
      config: {},
    },
  ],
  cart: [
    {
      id: 'system_cart_module',
      type: 'system',
      moduleType: 'cart_module',
      order: 0,
      isActive: true,
      visibility: 'visible',
      config: {},
    },
  ],
  profile: [
    {
      id: 'system_profile_module',
      type: 'system',
      moduleType: 'profile_module',
      order: 0,
      isActive: true,
      visibility: 'visible',
      config: {},
    },
  ],
  roulette: [
    {
      id: 'system_roulette_module',
      type: 'system',
      moduleType: 'roulette_module',
      order: 0,
      isActive: true,
      visibility: 'visible',
      config: {},
    },
  ],
  rewards: [
    {
      id: 'system_rewards_widget',
      type: 'system',
      moduleType: 'rewards_widget',
      order: 0,
      isActive: true,
      visibility: 'visible',
      config: {},
    },
  ],
};

/**
 * Initialize Firebase Admin SDK
 */
function initFirebase() {
  // Try to load service account key
  const serviceAccountPaths = [
    join(__dirname, '../firebase/service-account-key.json'),
    join(__dirname, '../service-account-key.json'),
  ];

  let serviceAccount = null;
  for (const path of serviceAccountPaths) {
    if (existsSync(path)) {
      try {
        serviceAccount = JSON.parse(readFileSync(path, 'utf8'));
        console.log(`✅ Loaded service account from: ${path}`);
        break;
      } catch (e) {
        console.warn(`⚠️ Could not parse service account at ${path}: ${e.message}`);
      }
    }
  }

  if (serviceAccount) {
    initializeApp({
      credential: cert(serviceAccount),
    });
  } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    console.log('✅ Using GOOGLE_APPLICATION_CREDENTIALS environment variable');
    initializeApp();
  } else {
    console.error('❌ No service account found. Please either:');
    console.error('   1. Place service-account-key.json in firebase/ directory');
    console.error('   2. Set GOOGLE_APPLICATION_CREDENTIALS environment variable');
    process.exit(1);
  }

  return getFirestore();
}

/**
 * Log a field change
 */
function logChange(docId, field, before, after) {
  const beforeStr = JSON.stringify(before);
  const afterStr = JSON.stringify(after);
  if (beforeStr !== afterStr) {
    console.log(`  📝 ${docId}.${field}: ${beforeStr} → ${afterStr}`);
    return true;
  }
  return false;
}

/**
 * Generate a unique block ID
 */
function generateBlockId() {
  return `block_${Date.now()}_${randomUUID().substring(0, 8)}`;
}

/**
 * Normalize layout array and ensure blocks have IDs
 */
function normalizeLayout(layout, docId, layoutName) {
  if (!layout) {
    return { normalized: [], changed: false };
  }
  
  // If not an array, convert to empty array
  if (!Array.isArray(layout)) {
    console.log(`  ⚠️ ${docId}.${layoutName}: Converting non-array to empty array`);
    return { normalized: [], changed: true };
  }
  
  let changed = false;
  const normalized = layout.map((block, index) => {
    if (!block || typeof block !== 'object') {
      console.log(`  ⚠️ ${docId}.${layoutName}[${index}]: Skipping invalid block`);
      changed = true;
      return null;
    }
    
    // Ensure block has an id
    if (!block.id) {
      const newId = generateBlockId();
      console.log(`  🔧 ${docId}.${layoutName}[${index}]: Generating block id: ${newId}`);
      changed = true;
      return { ...block, id: newId };
    }
    
    return block;
  }).filter(Boolean);
  
  return { normalized, changed };
}

/**
 * Normalize a pages_system document
 */
function normalizeSystemPage(docId, data) {
  const changes = {};
  let hasChanges = false;

  // Get system config if this is a known system page
  const systemConfig = SYSTEM_PAGES[docId];
  const isSystemPage = !!systemConfig;

  // Add pageKey if missing (source of truth = docId)
  if (!data.pageKey) {
    hasChanges = logChange(docId, 'pageKey', undefined, docId) || hasChanges;
    changes.pageKey = docId;
  }

  // Normalize name: if name absent and title present, copy title → name
  if (!data.name && data.title) {
    hasChanges = logChange(docId, 'name', data.name, data.title) || hasChanges;
    changes.name = data.title;
  } else if (!data.name) {
    const expectedName = systemConfig?.name || docId;
    hasChanges = logChange(docId, 'name', undefined, expectedName) || hasChanges;
    changes.name = expectedName;
  }

  // Normalize route
  const currentRoute = data.route;
  let expectedRoute;
  if (isSystemPage) {
    // System page: use known route
    expectedRoute = systemConfig.route;
  } else if (!currentRoute || currentRoute === '/' || currentRoute === '') {
    // Custom page: use /page/<docId>
    expectedRoute = `/page/${docId}`;
  } else {
    expectedRoute = currentRoute;
  }
  
  if (currentRoute !== expectedRoute) {
    hasChanges = logChange(docId, 'route', currentRoute, expectedRoute) || hasChanges;
    changes.route = expectedRoute;
  }

  // Normalize icon
  const currentIcon = data.icon;
  const expectedIcon = systemConfig?.icon || currentIcon || 'help_outline';
  if (!currentIcon) {
    hasChanges = logChange(docId, 'icon', currentIcon, expectedIcon) || hasChanges;
    changes.icon = expectedIcon;
  }

  // Normalize bottomNavIndex: if absent, use order if 0-4, else null
  if (data.bottomNavIndex === undefined || data.bottomNavIndex === null) {
    let expectedBottomNavIndex;
    if (systemConfig?.bottomNavIndex !== undefined) {
      expectedBottomNavIndex = systemConfig.bottomNavIndex;
    } else if (data.order !== undefined && data.order >= 0 && data.order <= 4) {
      expectedBottomNavIndex = data.order;
    } else {
      expectedBottomNavIndex = null;
    }
    
    if (expectedBottomNavIndex !== null) {
      hasChanges = logChange(docId, 'bottomNavIndex', data.bottomNavIndex, expectedBottomNavIndex) || hasChanges;
      changes.bottomNavIndex = expectedBottomNavIndex;
    }
  }

  // Add pageId if missing
  if (!data.pageId) {
    hasChanges = logChange(docId, 'pageId', undefined, docId) || hasChanges;
    changes.pageId = docId;
  }

  // Add updatedAt timestamp
  if (hasChanges) {
    changes.updatedAt = Timestamp.now();
  }

  return { hasChanges, changes };
}

/**
 * Normalize a pages_published or pages_draft document
 */
function normalizePageContent(docId, data, collectionName) {
  const changes = {};
  let hasChanges = false;

  // Get system config if this is a known system page
  const systemConfig = SYSTEM_PAGES[docId];
  const isSystemPage = !!systemConfig;

  // Add pageKey if missing (source of truth = docId)
  if (!data.pageKey) {
    hasChanges = logChange(docId, 'pageKey', undefined, docId) || hasChanges;
    changes.pageKey = docId;
  }

  // Add pageId if missing
  if (!data.pageId) {
    hasChanges = logChange(docId, 'pageId', undefined, docId) || hasChanges;
    changes.pageId = docId;
  }

  // Normalize name: if name absent and title present, copy title → name
  if (!data.name && data.title) {
    hasChanges = logChange(docId, 'name', data.name, data.title) || hasChanges;
    changes.name = data.title;
  }

  // Normalize route for custom pages
  const currentRoute = data.route;
  if (!isSystemPage && (!currentRoute || currentRoute === '/' || currentRoute === '')) {
    const expectedRoute = `/page/${docId}`;
    hasChanges = logChange(docId, 'route', currentRoute, expectedRoute) || hasChanges;
    changes.route = expectedRoute;
  }

  // Normalize draftLayout (ensure it's an array with block IDs)
  const draftResult = normalizeLayout(data.draftLayout, docId, 'draftLayout');
  if (draftResult.changed) {
    hasChanges = true;
    changes.draftLayout = draftResult.normalized;
  }

  // Normalize publishedLayout (ensure it's an array with block IDs)
  const publishedResult = normalizeLayout(data.publishedLayout, docId, 'publishedLayout');
  if (publishedResult.changed) {
    hasChanges = true;
    changes.publishedLayout = publishedResult.normalized;
  }

  // Normalize legacy 'blocks' field
  const blocksResult = normalizeLayout(data.blocks, docId, 'blocks');
  if (blocksResult.changed) {
    hasChanges = true;
    changes.blocks = blocksResult.normalized;
  }

  // Add updatedAt timestamp
  if (hasChanges) {
    changes.updatedAt = Timestamp.now();
  }

  return { hasChanges, changes };
}

/**
 * Main function
 */
async function main() {
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('  BUILDER B3 FIRESTORE NORMALIZATION SCRIPT');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log(`  Restaurant ID: ${RESTAURANT_ID}`);
  console.log(`  Mode: ${DRY_RUN ? '🔍 DRY RUN (preview only)' : '✏️ APPLY (will write to Firestore)'}`);
  console.log('═══════════════════════════════════════════════════════════════\n');

  const db = initFirebase();
  
  let totalChanges = 0;
  let systemPagesProcessed = 0;
  let publishedPagesProcessed = 0;
  let draftPagesProcessed = 0;

  // Process pages_system
  console.log('\n📂 Processing pages_system...\n');
  const systemPagesRef = db.collection('restaurants').doc(RESTAURANT_ID).collection('pages_system');
  const systemSnapshot = await systemPagesRef.get();

  for (const doc of systemSnapshot.docs) {
    const docId = doc.id;
    const data = doc.data();
    systemPagesProcessed++;

    console.log(`\n🔧 pages_system/${docId}:`);
    const { hasChanges, changes } = normalizeSystemPage(docId, data);

    if (hasChanges) {
      totalChanges++;
      if (!DRY_RUN) {
        await doc.ref.update(changes);
        console.log(`  ✅ Updated`);
      } else {
        console.log(`  🔍 Would update (dry-run)`);
      }
    } else {
      console.log(`  ✅ Already normalized`);
    }
  }

  // Process pages_published
  console.log('\n\n📂 Processing pages_published...\n');
  const publishedPagesRef = db.collection('restaurants').doc(RESTAURANT_ID).collection('pages_published');
  const publishedSnapshot = await publishedPagesRef.get();

  for (const doc of publishedSnapshot.docs) {
    const docId = doc.id;
    const data = doc.data();
    publishedPagesProcessed++;

    console.log(`\n🔧 pages_published/${docId}:`);
    const { hasChanges, changes } = normalizePageContent(docId, data, 'pages_published');

    if (hasChanges) {
      totalChanges++;
      if (!DRY_RUN) {
        await doc.ref.update(changes);
        console.log(`  ✅ Updated`);
      } else {
        console.log(`  🔍 Would update (dry-run)`);
      }
    } else {
      console.log(`  ✅ Already normalized`);
    }
  }

  // Process pages_draft
  console.log('\n\n📂 Processing pages_draft...\n');
  const draftPagesRef = db.collection('restaurants').doc(RESTAURANT_ID).collection('pages_draft');
  const draftSnapshot = await draftPagesRef.get();

  for (const doc of draftSnapshot.docs) {
    const docId = doc.id;
    const data = doc.data();
    draftPagesProcessed++;

    console.log(`\n🔧 pages_draft/${docId}:`);
    const { hasChanges, changes } = normalizePageContent(docId, data, 'pages_draft');

    if (hasChanges) {
      totalChanges++;
      if (!DRY_RUN) {
        await doc.ref.update(changes);
        console.log(`  ✅ Updated`);
      } else {
        console.log(`  🔍 Would update (dry-run)`);
      }
    } else {
      console.log(`  ✅ Already normalized`);
    }
  }

  // Summary
  console.log('\n═══════════════════════════════════════════════════════════════');
  console.log('  SUMMARY');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log(`  System pages processed: ${systemPagesProcessed}`);
  console.log(`  Published pages processed: ${publishedPagesProcessed}`);
  console.log(`  Draft pages processed: ${draftPagesProcessed}`);
  console.log(`  Total changes: ${totalChanges}`);
  console.log(`  Mode: ${DRY_RUN ? '🔍 DRY RUN (no writes made)' : '✅ APPLY (changes applied)'}`);
  console.log('═══════════════════════════════════════════════════════════════\n');

  if (DRY_RUN && totalChanges > 0) {
    console.log('💡 To apply these changes, run with --apply flag:');
    console.log('   node scripts/normalize_builder_firestore.mjs --apply\n');
  }
}

main().catch((error) => {
  console.error('❌ Script failed:', error);
  process.exit(1);
});
