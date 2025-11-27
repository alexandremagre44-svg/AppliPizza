#!/usr/bin/env node
/**
 * normalize_builder_firestore.mjs
 * 
 * Script to normalize Builder B3 Firestore data for restaurants/{restaurantId}/pages_system
 * and restaurants/{restaurantId}/pages_published collections.
 * 
 * Usage:
 *   node scripts/normalize_builder_firestore.mjs [--dry-run]
 * 
 * Options:
 *   --dry-run   Preview changes without writing to Firestore
 * 
 * Prerequisites:
 *   - Firebase Admin SDK: npm install firebase-admin
 *   - Service account key file at: ./firebase/service-account-key.json
 *     OR set GOOGLE_APPLICATION_CREDENTIALS environment variable
 * 
 * What this script does:
 *   1. Normalizes pages_system documents (navigation config)
 *   2. Normalizes pages_published documents (page content)
 *   3. Ensures system pages have minimal publishedLayout
 *   4. Logs all changes (before/after)
 */

import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { readFileSync, existsSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Configuration
const RESTAURANT_ID = 'delizza';
const DRY_RUN = process.argv.includes('--dry-run');

// System pages configuration
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
    bottomNavIndex: null, // Not in bottom nav by default
    order: 10,
  },
  rewards: {
    name: 'Récompenses',
    route: '/rewards',
    icon: 'card_giftcard',
    bottomNavIndex: null, // Not in bottom nav by default
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
 * Normalize a pages_system document
 */
function normalizeSystemPage(docId, data) {
  const changes = {};
  let hasChanges = false;

  // Get system config if this is a known system page
  const systemConfig = SYSTEM_PAGES[docId];

  // Normalize name (fallback: title → system default → docId)
  const currentName = data.name || data.title;
  const expectedName = systemConfig?.name || currentName || docId;
  if (currentName !== expectedName) {
    hasChanges = logChange(docId, 'name', currentName, expectedName) || hasChanges;
    changes.name = expectedName;
  }

  // Normalize route (must not be '/' or empty)
  const currentRoute = data.route;
  const expectedRoute = systemConfig?.route || (currentRoute && currentRoute !== '/' ? currentRoute : `/${docId}`);
  if (currentRoute !== expectedRoute) {
    hasChanges = logChange(docId, 'route', currentRoute, expectedRoute) || hasChanges;
    changes.route = expectedRoute;
  }

  // Normalize icon
  const currentIcon = data.icon;
  const expectedIcon = systemConfig?.icon || currentIcon || 'help_outline';
  if (currentIcon !== expectedIcon) {
    hasChanges = logChange(docId, 'icon', currentIcon, expectedIcon) || hasChanges;
    changes.icon = expectedIcon;
  }

  // Normalize bottomNavIndex (0-4 for visible, null/999 for hidden)
  const currentBottomNavIndex = data.bottomNavIndex;
  const expectedBottomNavIndex = systemConfig?.bottomNavIndex ?? currentBottomNavIndex;
  if (currentBottomNavIndex !== expectedBottomNavIndex && expectedBottomNavIndex !== undefined) {
    hasChanges = logChange(docId, 'bottomNavIndex', currentBottomNavIndex, expectedBottomNavIndex) || hasChanges;
    changes.bottomNavIndex = expectedBottomNavIndex;
  }

  // Normalize order
  const currentOrder = data.order;
  const expectedOrder = systemConfig?.order ?? currentOrder ?? 999;
  if (currentOrder !== expectedOrder) {
    hasChanges = logChange(docId, 'order', currentOrder, expectedOrder) || hasChanges;
    changes.order = expectedOrder;
  }

  // Normalize isActive (default true for system pages)
  const currentIsActive = data.isActive;
  const expectedIsActive = systemConfig ? true : (currentIsActive ?? true);
  if (currentIsActive !== expectedIsActive) {
    hasChanges = logChange(docId, 'isActive', currentIsActive, expectedIsActive) || hasChanges;
    changes.isActive = expectedIsActive;
  }

  // Normalize displayLocation (bottomBar for nav items, hidden otherwise)
  const currentDisplayLocation = data.displayLocation;
  const expectedDisplayLocation = (expectedBottomNavIndex !== null && expectedBottomNavIndex >= 0 && expectedBottomNavIndex <= 4) 
    ? 'bottomBar' 
    : (currentDisplayLocation || 'hidden');
  if (currentDisplayLocation !== expectedDisplayLocation) {
    hasChanges = logChange(docId, 'displayLocation', currentDisplayLocation, expectedDisplayLocation) || hasChanges;
    changes.displayLocation = expectedDisplayLocation;
  }

  // Ensure isSystemPage is true for known system pages
  if (systemConfig && data.isSystemPage !== true) {
    hasChanges = logChange(docId, 'isSystemPage', data.isSystemPage, true) || hasChanges;
    changes.isSystemPage = true;
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
 * Normalize a pages_published document
 */
function normalizePublishedPage(docId, data) {
  const changes = {};
  let hasChanges = false;

  // Get system config if this is a known system page
  const systemConfig = SYSTEM_PAGES[docId];

  // Normalize name (same logic as system page)
  const currentName = data.name || data.title;
  const expectedName = systemConfig?.name || currentName || docId;
  if (currentName !== expectedName) {
    hasChanges = logChange(docId, 'name', currentName, expectedName) || hasChanges;
    changes.name = expectedName;
  }

  // Normalize route
  const currentRoute = data.route;
  const expectedRoute = systemConfig?.route || (currentRoute && currentRoute !== '/' ? currentRoute : `/${docId}`);
  if (currentRoute !== expectedRoute) {
    hasChanges = logChange(docId, 'route', currentRoute, expectedRoute) || hasChanges;
    changes.route = expectedRoute;
  }

  // Check publishedLayout for system pages
  const currentLayout = data.publishedLayout;
  const minimalLayout = MINIMAL_SYSTEM_BLOCKS[docId];
  
  if (systemConfig && minimalLayout) {
    // If publishedLayout is empty or missing, add minimal system blocks
    if (!currentLayout || !Array.isArray(currentLayout) || currentLayout.length === 0) {
      console.log(`  📦 ${docId}: Adding minimal publishedLayout (${minimalLayout.length} blocks)`);
      hasChanges = true;
      changes.publishedLayout = minimalLayout.map(block => ({
        ...block,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      }));
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
 * Main function
 */
async function main() {
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('  BUILDER B3 FIRESTORE NORMALIZATION SCRIPT');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log(`  Restaurant ID: ${RESTAURANT_ID}`);
  console.log(`  Mode: ${DRY_RUN ? '🔍 DRY RUN (no writes)' : '✏️ LIVE (will write to Firestore)'}`);
  console.log('═══════════════════════════════════════════════════════════════\n');

  const db = initFirebase();
  
  let totalChanges = 0;
  let systemPagesProcessed = 0;
  let publishedPagesProcessed = 0;

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
    const { hasChanges, changes } = normalizePublishedPage(docId, data);

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

  // Create missing system pages in pages_published if they don't exist
  console.log('\n\n📂 Checking for missing system pages in pages_published...\n');
  for (const [pageId, config] of Object.entries(SYSTEM_PAGES)) {
    const docRef = publishedPagesRef.doc(pageId);
    const doc = await docRef.get();

    if (!doc.exists) {
      console.log(`\n🆕 Creating pages_published/${pageId}:`);
      const newDoc = {
        pageId,
        name: config.name,
        route: config.route,
        icon: config.icon,
        order: config.order,
        bottomNavIndex: config.bottomNavIndex,
        isActive: true,
        isSystemPage: true,
        displayLocation: config.bottomNavIndex !== null ? 'bottomBar' : 'hidden',
        publishedLayout: (MINIMAL_SYSTEM_BLOCKS[pageId] || []).map(block => ({
          ...block,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        })),
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      };

      totalChanges++;
      if (!DRY_RUN) {
        await docRef.set(newDoc);
        console.log(`  ✅ Created with minimal layout`);
      } else {
        console.log(`  🔍 Would create (dry-run)`);
      }
    }
  }

  // Summary
  console.log('\n═══════════════════════════════════════════════════════════════');
  console.log('  SUMMARY');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log(`  System pages processed: ${systemPagesProcessed}`);
  console.log(`  Published pages processed: ${publishedPagesProcessed}`);
  console.log(`  Total changes: ${totalChanges}`);
  console.log(`  Mode: ${DRY_RUN ? '🔍 DRY RUN (no writes made)' : '✅ LIVE (changes applied)'}`);
  console.log('═══════════════════════════════════════════════════════════════\n');

  if (DRY_RUN && totalChanges > 0) {
    console.log('💡 To apply these changes, run without --dry-run flag:');
    console.log('   node scripts/normalize_builder_firestore.mjs\n');
  }
}

main().catch((error) => {
  console.error('❌ Script failed:', error);
  process.exit(1);
});
