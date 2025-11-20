# Firebase Cloud Functions for Admin Management

This document provides the Cloud Functions code needed to securely manage admin users with custom claims.

## Prerequisites

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. Initialize Cloud Functions in your project:
   ```bash
   cd /path/to/your/project
   firebase init functions
   ```

3. Choose TypeScript when prompted

## Cloud Functions Code

Create or update `functions/src/index.ts` with the following code:

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// ============================================================================
// SECURITY: Admin Management Functions
// ============================================================================

/**
 * Set admin custom claim for a user
 * 
 * SECURITY: Only existing admins can call this function
 * This function should be called from a secure admin panel
 * 
 * Usage from Flutter:
 * ```dart
 * final result = await FirebaseFunctions.instance
 *   .httpsCallable('setAdminClaim')
 *   .call({'uid': targetUserId});
 * ```
 */
export const setAdminClaim = functions.https.onCall(async (data, context) => {
  // Verify the caller is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to call this function'
    );
  }

  // SECURITY: Verify the caller is already an admin
  const callerUid = context.auth.uid;
  const callerToken = context.auth.token;
  
  // Check custom claim first, then fallback to Firestore
  let isCallerAdmin = callerToken.admin === true;
  
  if (!isCallerAdmin) {
    const callerDoc = await admin.firestore()
      .collection('users')
      .doc(callerUid)
      .get();
    
    isCallerAdmin = callerDoc.exists && callerDoc.data()?.role === 'admin';
  }

  if (!isCallerAdmin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can grant admin access'
    );
  }

  // Get target user ID
  const targetUid = data.uid as string;
  
  if (!targetUid) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'User ID is required'
    );
  }

  try {
    // Set custom claim
    await admin.auth().setCustomUserClaims(targetUid, { admin: true });

    // Update Firestore role
    await admin.firestore()
      .collection('users')
      .doc(targetUid)
      .set({
        role: 'admin',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

    console.log(`Admin claim set for user ${targetUid} by ${callerUid}`);

    return {
      success: true,
      message: `Admin claim set for user ${targetUid}`,
    };
  } catch (error) {
    console.error('Error setting admin claim:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to set admin claim',
      error
    );
  }
});

/**
 * Remove admin custom claim from a user
 * 
 * SECURITY: Only existing admins can call this function
 * Prevents users from removing their own admin status
 */
export const removeAdminClaim = functions.https.onCall(async (data, context) => {
  // Verify the caller is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  // SECURITY: Verify the caller is an admin
  const callerUid = context.auth.uid;
  const callerToken = context.auth.token;
  
  let isCallerAdmin = callerToken.admin === true;
  
  if (!isCallerAdmin) {
    const callerDoc = await admin.firestore()
      .collection('users')
      .doc(callerUid)
      .get();
    
    isCallerAdmin = callerDoc.exists && callerDoc.data()?.role === 'admin';
  }

  if (!isCallerAdmin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can revoke admin access'
    );
  }

  const targetUid = data.uid as string;
  
  if (!targetUid) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'User ID is required'
    );
  }

  // SECURITY: Prevent self-demotion
  if (targetUid === callerUid) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Cannot remove your own admin status'
    );
  }

  try {
    // Remove custom claim
    await admin.auth().setCustomUserClaims(targetUid, { admin: false });

    // Update Firestore role
    await admin.firestore()
      .collection('users')
      .doc(targetUid)
      .update({
        role: 'client',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    console.log(`Admin claim removed from user ${targetUid} by ${callerUid}`);

    return {
      success: true,
      message: `Admin claim removed from user ${targetUid}`,
    };
  } catch (error) {
    console.error('Error removing admin claim:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to remove admin claim',
      error
    );
  }
});

/**
 * Initialize first admin (ONE-TIME USE ONLY)
 * 
 * SECURITY: This function should be disabled after first use
 * It requires a secret token to prevent unauthorized access
 * 
 * Usage:
 * ```
 * curl "https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/initFirstAdmin?email=admin@example.com&secret=YOUR_SECRET_TOKEN"
 * ```
 */
export const initFirstAdmin = functions.https.onRequest(async (req, res) => {
  // ⚠️ SECURITY: Change this secret or disable this function after first use
  const INIT_SECRET = process.env.ADMIN_INIT_SECRET || 'CHANGE_ME_BEFORE_DEPLOY';
  
  const secret = req.query.secret as string;
  if (secret !== INIT_SECRET) {
    res.status(403).send('Forbidden: Invalid secret');
    return;
  }

  const email = req.query.email as string;
  if (!email) {
    res.status(400).send('Bad Request: Email required');
    return;
  }

  try {
    // Find user by email
    const user = await admin.auth().getUserByEmail(email);

    // Set admin claim
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });

    // Create/update Firestore document
    await admin.firestore()
      .collection('users')
      .doc(user.uid)
      .set({
        email: user.email,
        role: 'admin',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

    console.log(`First admin initialized: ${email} (${user.uid})`);

    res.status(200).json({
      success: true,
      message: `Admin claim set for ${email}`,
      uid: user.uid,
    });
  } catch (error) {
    console.error('Error initializing first admin:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to initialize admin',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * Get user's custom claims (for debugging)
 * 
 * SECURITY: Only admins can call this function
 */
export const getUserClaims = functions.https.onCall(async (data, context) => {
  // Verify the caller is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  // SECURITY: Verify the caller is an admin
  const callerToken = context.auth.token;
  if (callerToken.admin !== true) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can view custom claims'
    );
  }

  const targetUid = data.uid as string;
  
  if (!targetUid) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'User ID is required'
    );
  }

  try {
    const user = await admin.auth().getUser(targetUid);
    
    return {
      success: true,
      uid: user.uid,
      email: user.email,
      customClaims: user.customClaims || {},
    };
  } catch (error) {
    console.error('Error getting user claims:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to get user claims',
      error
    );
  }
});

// ============================================================================
// OPTIONAL: Firestore Triggers for Security Auditing
// ============================================================================

/**
 * Log admin role changes for security auditing
 */
export const onAdminRoleChange = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const beforeRole = change.before.data()?.role;
    const afterRole = change.after.data()?.role;
    
    // Only log if role changed to/from admin
    if (beforeRole !== afterRole && (beforeRole === 'admin' || afterRole === 'admin')) {
      const userId = context.params.userId;
      const userEmail = change.after.data()?.email || 'unknown';
      
      // Log to a security audit collection
      await admin.firestore()
        .collection('security_audit_logs')
        .add({
          type: 'admin_role_change',
          userId: userId,
          userEmail: userEmail,
          beforeRole: beforeRole,
          afterRole: afterRole,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      
      console.log(`Admin role change: ${userEmail} (${userId}) from ${beforeRole} to ${afterRole}`);
    }
  });
```

## Deployment Steps

1. **Set the init secret as an environment variable:**
   ```bash
   firebase functions:config:set admin.init_secret="YOUR_SECURE_RANDOM_STRING"
   ```

2. **Deploy the functions:**
   ```bash
   firebase deploy --only functions
   ```

3. **Initialize your first admin:**
   ```bash
   # Replace with your actual values
   curl "https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/initFirstAdmin?email=admin@example.com&secret=YOUR_SECURE_RANDOM_STRING"
   ```

4. **⚠️ IMPORTANT: After creating your first admin, comment out or delete the `initFirstAdmin` function and redeploy for security**

## Using from Flutter App

### Add Firebase Functions dependency:

```yaml
# pubspec.yaml
dependencies:
  cloud_functions: ^5.1.3
```

### Call functions from Flutter:

```dart
import 'package:cloud_functions/cloud_functions.dart';

// Set a user as admin
Future<void> setUserAsAdmin(String targetUserId) async {
  try {
    final result = await FirebaseFunctions.instance
      .httpsCallable('setAdminClaim')
      .call({'uid': targetUserId});
    
    print('Success: ${result.data['message']}');
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

// Remove admin from a user
Future<void> removeAdminFromUser(String targetUserId) async {
  try {
    final result = await FirebaseFunctions.instance
      .httpsCallable('removeAdminClaim')
      .call({'uid': targetUserId});
    
    print('Success: ${result.data['message']}');
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

// Get user's custom claims (debugging)
Future<void> checkUserClaims(String targetUserId) async {
  try {
    final result = await FirebaseFunctions.instance
      .httpsCallable('getUserClaims')
      .call({'uid': targetUserId});
    
    print('Custom claims: ${result.data['customClaims']}');
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
```

## Alternative: Manual Setup via Firebase CLI

If you prefer not to use Cloud Functions, you can manually set admin claims:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Set custom claim
firebase auth:export users.json --project YOUR_PROJECT_ID
# Edit users.json to add customClaims: {"admin": true}
firebase auth:import users.json --project YOUR_PROJECT_ID
```

Or use the Firebase Admin SDK from Node.js:

```javascript
const admin = require('firebase-admin');
admin.initializeApp();

async function setAdminClaim(email) {
  const user = await admin.auth().getUserByEmail(email);
  await admin.auth().setCustomUserClaims(user.uid, { admin: true });
  
  // Also update Firestore
  await admin.firestore().collection('users').doc(user.uid).set({
    role: 'admin',
    email: user.email,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
  
  console.log(`Admin claim set for ${email}`);
}

setAdminClaim('admin@example.com')
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
```

## Security Best Practices

1. **Never** expose the `initFirstAdmin` function in production
2. **Always** require authentication before checking admin status
3. **Never** trust client-side role checking alone (use custom claims)
4. **Always** verify admin status in both custom claims and Firestore rules
5. **Log** all admin role changes for security auditing
6. **Rotate** secrets regularly
7. **Monitor** Cloud Functions logs for suspicious activity
8. **Limit** the number of admin users
9. **Review** admin access regularly

## Testing

1. Create a test user in Firebase Console
2. Use `initFirstAdmin` to make them admin
3. Sign in as that user in the app
4. Verify they can access admin screens
5. Try to access admin screens as a regular user (should fail)
6. Check custom claims with `getUserClaims` function

## Troubleshooting

**Problem:** "User doesn't have admin access" even after setting claim
- **Solution:** User needs to sign out and sign in again for new claims to take effect

**Problem:** Cloud Functions not deploying
- **Solution:** Check Node.js version (requires Node 18+), check Firebase CLI version

**Problem:** "Permission denied" in Firestore
- **Solution:** Redeploy Firestore rules with `firebase deploy --only firestore:rules`

**Problem:** Custom claims not working
- **Solution:** Check that user has signed out and back in, verify claims with `getUserClaims`

## Monitoring

Check Cloud Functions logs:
```bash
firebase functions:log --only setAdminClaim,removeAdminClaim
```

View security audit logs in Firestore Console:
- Collection: `security_audit_logs`
- Filter by `type: 'admin_role_change'`

---

**Last Updated**: 2025-11-20
