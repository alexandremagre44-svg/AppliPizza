#!/usr/bin/env node

/**
 * Script to set admin custom claim for a Firebase user
 * 
 * Usage:
 *   node scripts/set_admin_claim.js <USER_UID>
 * 
 * Example:
 *   node scripts/set_admin_claim.js dbmnp2DdyJaURWJO4YEE5fgv3002
 * 
 * Requirements:
 *   - Firebase Admin SDK installed: npm install firebase-admin
 *   - Service account key JSON file in project root
 *   - Environment variable GOOGLE_APPLICATION_CREDENTIALS set
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin
try {
  admin.initializeApp({
    credential: admin.credential.applicationDefault()
  });
  console.log('✅ Firebase Admin initialized');
} catch (error) {
  console.error('❌ Error initializing Firebase Admin:', error.message);
  console.log('\nMake sure to:');
  console.log('1. Install firebase-admin: npm install firebase-admin');
  console.log('2. Download service account key from Firebase Console');
  console.log('3. Set GOOGLE_APPLICATION_CREDENTIALS environment variable');
  process.exit(1);
}

// Get UID from command line
const uid = process.argv[2];

if (!uid) {
  console.error('❌ Error: USER_UID is required');
  console.log('\nUsage: node scripts/set_admin_claim.js <USER_UID>');
  console.log('Example: node scripts/set_admin_claim.js dbmnp2DdyJaURWJO4YEE5fgv3002');
  process.exit(1);
}

/**
 * Set admin custom claim for a user
 */
async function setAdminClaim(userId) {
  try {
    console.log(`\n🔧 Setting admin claim for user: ${userId}`);
    
    // Check if user exists
    const user = await admin.auth().getUser(userId);
    console.log(`✅ User found: ${user.email || 'No email'}`);
    
    // Set custom claim
    await admin.auth().setCustomUserClaims(userId, { admin: true });
    console.log('✅ Admin claim set successfully!');
    
    // Verify the claim was set
    const updatedUser = await admin.auth().getUser(userId);
    console.log('\n📋 Current custom claims:', updatedUser.customClaims);
    
    if (updatedUser.customClaims?.admin === true) {
      console.log('\n✅ SUCCESS: Admin claim is now active!');
      console.log('\n⚠️  Important:');
      console.log('   - User must logout and login again for changes to take effect');
      console.log('   - Or force token refresh in the app');
    } else {
      console.log('\n⚠️  WARNING: Admin claim was not set correctly');
    }
    
  } catch (error) {
    console.error('\n❌ Error setting admin claim:', error.message);
    
    if (error.code === 'auth/user-not-found') {
      console.log('\n💡 User not found. Make sure the UID is correct.');
    }
    
    process.exit(1);
  }
}

/**
 * Remove admin custom claim for a user (optional utility)
 */
async function removeAdminClaim(userId) {
  try {
    await admin.auth().setCustomUserClaims(userId, { admin: false });
    console.log(`✅ Admin claim removed for user: ${userId}`);
  } catch (error) {
    console.error('❌ Error removing admin claim:', error.message);
    process.exit(1);
  }
}

/**
 * List all users with admin claim (optional utility)
 */
async function listAdminUsers() {
  try {
    console.log('\n📋 Listing all users with admin claim...\n');
    
    const listUsersResult = await admin.auth().listUsers(1000);
    const adminUsers = listUsersResult.users.filter(
      user => user.customClaims?.admin === true
    );
    
    if (adminUsers.length === 0) {
      console.log('No users with admin claim found.');
    } else {
      console.log(`Found ${adminUsers.length} admin user(s):\n`);
      adminUsers.forEach(user => {
        console.log(`- UID: ${user.uid}`);
        console.log(`  Email: ${user.email || 'No email'}`);
        console.log(`  Claims: ${JSON.stringify(user.customClaims)}\n`);
      });
    }
  } catch (error) {
    console.error('❌ Error listing admin users:', error.message);
    process.exit(1);
  }
}

// Main execution
(async () => {
  const command = process.argv[2];
  
  if (command === 'list') {
    await listAdminUsers();
  } else if (command === 'remove' && process.argv[3]) {
    await removeAdminClaim(process.argv[3]);
  } else {
    await setAdminClaim(uid);
  }
  
  process.exit(0);
})();
