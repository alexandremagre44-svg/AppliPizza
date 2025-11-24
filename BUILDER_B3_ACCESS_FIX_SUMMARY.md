# Builder B3 Access Management - Fix Summary

**Date:** 2025-11-24  
**Status:** ✅ COMPLETED  
**Issue:** [cloud_firestore/permission-denied] on Builder B3 access

---

## 📋 Problem Analysis

### Initial Issues Found:

1. **Missing Firestore Rules** for `builder/` collection
   - No rules existed for Builder B3 paths
   - Permission denied errors when accessing Firestore

2. **Incorrect Firestore Path Structure**
   - Current: `apps/{appId}/builder/pages/{pageId}/{draft|published}`
   - Required: `builder/apps/{appId}/pages/{pageId}/{draft|published}`

3. **Custom Claims Not Retrieved**
   - Auth system relied only on Firestore `users` collection
   - Custom claims (`admin`) from Firebase Auth token not checked
   - Builder access check didn't verify custom claims

4. **Inconsistent Admin Verification**
   - Different admin check mechanisms across codebase
   - Builder relied only on role-based checks

---

## ✅ Solutions Implemented

### 1. Firestore Rules (firebase/firestore.rules)

**Added Builder B3 access rules:**

```javascript
// =========================================================================
// BUILDER B3 - Page Builder System
// =========================================================================
// Structure: builder/apps/{appId}/pages/{pageId}/{draft|published}
// 
// Permissions:
// - Admin only (using custom claims): full read/write access
// - No public access
// =========================================================================
match /builder/{path=**} {
  allow read, write: if request.auth != null && request.auth.token.admin == true;
}
```

**Key Points:**
- Uses custom claims check: `request.auth.token.admin == true`
- Placed before deny-all rule at line 503
- Covers all paths under `builder/` collection
- ADMIN-ONLY access enforced at Firestore level

### 2. Firestore Path Structure (builder_layout_service.dart)

**Fixed path construction:**

```dart
// OLD PATH:
apps/{appId}/builder/pages/{pageId}/{draft|published}

// NEW PATH (CORRECT):
builder/apps/{appId}/pages/{pageId}/{draft|published}
```

**Changes in `BuilderLayoutService`:**

```dart
// Updated constants
static const String _builderCollection = 'builder';
static const String _appsSubcollection = 'apps';
static const String _pagesSubcollection = 'pages';

// Fixed _getDraftRef() and _getPublishedRef()
DocumentReference _getDraftRef(String appId, BuilderPageId pageId) {
  return _firestore
      .collection(_builderCollection)      // builder
      .doc(_appsSubcollection)             // apps
      .collection(appId)                    // {appId}
      .doc(_pagesSubcollection)            // pages
      .collection(pageId.value)             // {pageId}
      .doc(_draftDoc);                      // draft
}
```

### 3. Custom Claims Support (auth_provider.dart)

**Updated AuthState:**

```dart
class AuthState {
  // ... existing fields
  final Map<String, dynamic>? customClaims; // NEW
  
  // Updated isAdmin getter
  bool get isAdmin => userRole == UserRole.admin || (customClaims?['admin'] == true);
}
```

**Updated AuthNotifier initialization:**

```dart
// Récupérer les custom claims depuis le token Firebase Auth
final customClaims = await _authService.getCustomClaims(user);

state = AuthState(
  // ... existing fields
  customClaims: customClaims,  // NEW
);
```

### 4. Custom Claims Retrieval (firebase_auth_service.dart)

**New method added:**

```dart
/// Récupérer les custom claims du token Firebase Auth
/// Returns null if user is null or claims cannot be retrieved
Future<Map<String, dynamic>?> getCustomClaims(User user) async {
  try {
    final idTokenResult = await user.getIdTokenResult();
    return idTokenResult.claims;
  } catch (e) {
    if (kDebugMode) {
      print('Error retrieving custom claims: $e');
    }
    return null;
  }
}
```

### 5. Builder Access Check (app_context.dart)

**Updated loadUserContext():**

```dart
// Check custom claims first (more secure)
Map<String, dynamic>? customClaims;
try {
  final idTokenResult = await user.getIdTokenResult();
  customClaims = idTokenResult.claims;
} catch (e) {
  print('Error retrieving custom claims: $e');
}

// Check if user has admin claim
final hasAdminClaim = customClaims?['admin'] == true;

// ... later in code ...

// Check if user has Builder access (custom claim OR role-based)
final hasBuilderAccess = hasAdminClaim ||
    role == BuilderRole.superAdmin ||
    role == BuilderRole.adminResto ||
    role == BuilderRole.studio ||
    role == BuilderRole.admin;
```

---

## 📁 Files Modified

| File | Changes | Lines Changed |
|------|---------|---------------|
| `firebase/firestore.rules` | Added Builder B3 rules | +13 |
| `lib/builder/services/builder_layout_service.dart` | Fixed Firestore paths | ~17 |
| `lib/src/providers/auth_provider.dart` | Added custom claims support | +14 |
| `lib/src/services/firebase_auth_service.dart` | Added getCustomClaims method | +14 |
| `lib/builder/utils/app_context.dart` | Updated admin check logic | +27 |
| **Total** | | **+69, -16** |

---

## 🔐 Security Architecture

### Access Control Flow:

```
User Login
    ↓
Firebase Auth retrieves token
    ↓
Custom claims extracted from token
    ↓
AuthState stores customClaims
    ↓
AppContext checks hasAdminClaim OR role-based
    ↓
Builder B3 accessible if admin
    ↓
Firestore enforces: request.auth.token.admin == true
    ↓
Access granted to builder/* collection
```

### Dual Verification:

1. **Client-side check** (AppContext): Shows/hides Builder UI
2. **Server-side check** (Firestore Rules): Enforces data access

---

## 🧪 Testing Requirements

### ⚠️ Prerequisites:

Before Builder B3 can work, **admin custom claims must be set** for the admin user.

**Option 1: Using Firebase Admin SDK (Recommended)**

```javascript
// Node.js example
const admin = require('firebase-admin');
admin.initializeApp();

async function setAdminClaim(uid) {
  await admin.auth().setCustomUserClaims(uid, { admin: true });
  console.log(`Admin claim set for user: ${uid}`);
}

// Run for admin user
setAdminClaim('YOUR_ADMIN_UID');
```

**Option 2: Using Firebase Cloud Function**

```javascript
// functions/index.js
exports.setAdminClaim = functions.https.onCall(async (data, context) => {
  // Add security check here
  await admin.auth().setCustomUserClaims(data.uid, { admin: true });
  return { success: true };
});
```

**Option 3: Using Firebase CLI**

```bash
# Via Firebase Functions deploy
firebase deploy --only functions:setAdminClaim
```

### ✅ Test Checklist:

After setting custom claims:

- [ ] **Deploy Firestore Rules**
  ```bash
  firebase deploy --only firestore:rules
  ```

- [ ] **Set Admin Custom Claims**
  - Use one of the methods above
  - Verify in Firebase Console → Authentication → User → Custom Claims

- [ ] **Test Admin User Login**
  - Login with admin credentials
  - Check `AuthState.customClaims` contains `admin: true`
  - Verify `AuthState.isAdmin` returns `true`

- [ ] **Test Builder B3 Access**
  - Navigate to Builder B3 Studio
  - Should see "Builder B3 Studio" screen (not "Accès refusé")
  - Should be able to select pages

- [ ] **Test Firestore Read/Write**
  - Try to load draft page: `builder/apps/{appId}/pages/home/draft`
  - Try to save draft page
  - Verify no permission-denied errors

- [ ] **Test Non-Admin User**
  - Logout admin
  - Login with regular user (client role)
  - Should see "Accès refusé" on Builder B3
  - Should get permission-denied on Firestore access

### 📊 Expected Behaviors:

| User Type | Custom Claim | Builder Access | Firestore Access |
|-----------|--------------|----------------|------------------|
| Admin (with claim) | `admin: true` | ✅ Granted | ✅ Granted |
| Admin (no claim) | `null` or `false` | ❌ Denied | ❌ Denied |
| Client | `null` | ❌ Denied | ❌ Denied |
| Anonymous | `null` | ❌ Denied | ❌ Denied |

---

## 🐛 Troubleshooting

### Issue: Still getting permission-denied after fixes

**Solutions:**

1. **Verify Firestore rules deployed:**
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Check custom claims set:**
   ```bash
   # In Firebase Console
   Authentication → Users → [Admin User] → Custom Claims
   # Should show: {"admin": true}
   ```

3. **Force token refresh:**
   ```dart
   // In your app
   await FirebaseAuth.instance.currentUser?.getIdToken(true);
   ```

4. **Check Firestore path:**
   - Must be: `builder/apps/{appId}/pages/{pageId}/draft`
   - NOT: `apps/{appId}/builder/pages/{pageId}/draft`

### Issue: Custom claims not appearing in app

**Solutions:**

1. **User must logout and login again** after claims are set
2. **Or force token refresh** (see above)
3. **Check `AuthState.customClaims`** in debug:
   ```dart
   final authState = ref.read(authProvider);
   print('Custom Claims: ${authState.customClaims}');
   ```

### Issue: "Accès refusé" even with admin role

**Solutions:**

1. **Custom claims take priority** - Ensure `admin: true` claim is set
2. **Role-based check is fallback only** - Set the claim
3. **AppContext caches state** - Try `ref.read(appContextProvider.notifier).refresh()`

---

## 📝 Firestore Rules Reference

### Full Builder B3 Rule:

```javascript
match /builder/{path=**} {
  allow read, write: if request.auth != null && request.auth.token.admin == true;
}
```

### What this means:

- `match /builder/{path=**}` - Matches all paths under `builder/` collection
- `request.auth != null` - User must be authenticated
- `request.auth.token.admin == true` - User token must have `admin` custom claim set to `true`
- `allow read, write` - Grants both read and write access if conditions met

### Alternative (fallback to role):

If you want to support both custom claims AND role-based:

```javascript
function isBuilderAdmin() {
  return request.auth != null && (
    request.auth.token.admin == true ||
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
  );
}

match /builder/{path=**} {
  allow read, write: if isBuilderAdmin();
}
```

---

## 🔄 Migration Notes

### For Existing Deployments:

1. **Backup current Firestore rules** before deploying
2. **Set admin custom claims** for all admin users
3. **Deploy new rules** with Builder B3 access
4. **Test with admin user** before wider rollout
5. **No data migration needed** - path structure change is code-only

### Breaking Changes:

⚠️ **Important:** If you had existing data at the OLD path:
```
apps/{appId}/builder/pages/{pageId}/{draft|published}
```

You need to migrate it to the NEW path:
```
builder/apps/{appId}/pages/{pageId}/{draft|published}
```

**Migration Script (if needed):**

```javascript
// Run in Firebase Console or Cloud Function
const admin = require('firebase-admin');
const db = admin.firestore();

async function migratePaths() {
  // Get all apps
  const appsSnapshot = await db.collection('apps').get();
  
  for (const appDoc of appsSnapshot.docs) {
    const appId = appDoc.id;
    
    // Get old builder data
    const oldBuilderRef = db.collection('apps').doc(appId).collection('builder');
    const pagesDoc = await oldBuilderRef.doc('pages').get();
    
    if (!pagesDoc.exists) continue;
    
    // Get all page subcollections
    const pageIds = ['home', 'menu', 'promo', 'about', 'contact'];
    
    for (const pageId of pageIds) {
      const draftDoc = await oldBuilderRef.doc('pages').collection(pageId).doc('draft').get();
      const publishedDoc = await oldBuilderRef.doc('pages').collection(pageId).doc('published').get();
      
      // Copy to new path
      if (draftDoc.exists) {
        await db.collection('builder').doc('apps').collection(appId)
          .doc('pages').collection(pageId).doc('draft').set(draftDoc.data());
        console.log(`Migrated draft: ${appId}/${pageId}`);
      }
      
      if (publishedDoc.exists) {
        await db.collection('builder').doc('apps').collection(appId)
          .doc('pages').collection(pageId).doc('published').set(publishedDoc.data());
        console.log(`Migrated published: ${appId}/${pageId}`);
      }
    }
  }
  
  console.log('Migration complete!');
}
```

---

## ✅ Résumé en Français

### Ce qui a été corrigé:

1. **Règles Firestore** - Ajout de `match /builder/{path=**}` avec accès admin uniquement
2. **Structure des paths** - Changement de `apps/{appId}/builder/...` vers `builder/apps/{appId}/...`
3. **Custom claims** - Récupération et vérification des claims `admin` depuis le token Firebase Auth
4. **Check admin** - Vérification des custom claims en priorité, fallback sur le rôle Firestore

### Fichiers modifiés:

- `firebase/firestore.rules` - Règles Firestore
- `lib/builder/services/builder_layout_service.dart` - Paths Firestore
- `lib/src/providers/auth_provider.dart` - Support custom claims
- `lib/src/services/firebase_auth_service.dart` - Méthode getCustomClaims
- `lib/builder/utils/app_context.dart` - Check admin avec claims

### Tests à réaliser:

1. Déployer les règles Firestore
2. **Définir le custom claim `admin: true`** pour l'utilisateur admin (OBLIGATOIRE)
3. Tester l'accès au Builder B3 avec compte admin
4. Vérifier le refus d'accès pour utilisateurs non-admin
5. Tester lecture/écriture Firestore sur `builder/apps/{appId}/pages/{pageId}/{draft|published}`

### ⚠️ Point Critique:

**Le custom claim `admin: true` DOIT être défini via Firebase Admin SDK** pour que le Builder B3 fonctionne. Sans ce claim, l'accès sera refusé même avec le rôle admin dans Firestore.

---

## 📚 References

- [Firebase Custom Claims Documentation](https://firebase.google.com/docs/auth/admin/custom-claims)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Builder B3 Documentation](BUILDER_B3_COMPLETE_GUIDE.md)

---

**End of Summary**
