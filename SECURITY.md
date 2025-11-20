# Security Implementation Guide

This document describes the security measures implemented in this Flutter + Firebase application and manual steps required to complete the security setup.

## 🔒 Security Features Implemented

### 1. Firebase Security Rules

#### Firestore Rules (`firebase/firestore.rules`)
✅ **COMPLETED** - Comprehensive security rules with:
- Per-document access control (users can only access their own data)
- Admin-only access for management operations
- Read/write restrictions based on user authentication
- Data validation (field types, string lengths, price ranges)
- Rate limiting protection (orders: 1/minute, roulette: 1/30 seconds)
- Input sanitization enforcement
- Abuse prevention (max 50 items per order, reasonable price limits)

**Collections Secured:**
- `users` - User profiles and roles
- `user_profiles` - Extended user information
- `orders` - Customer orders (owner + admin access)
- `products` - Menu items (public read, admin write)
- `ingredients` - Ingredient catalog (public read, admin write)
- `promotions` - Marketing promotions (public read, admin write)
- `roulette_segments` - Roulette configuration (public read, admin write)
- `user_roulette_spins` - Spin history with rate limiting
- `rewardTickets` - Loyalty rewards
- All config collections (admin-only write)

#### Storage Rules (`firebase/storage.rules`)
✅ **COMPLETED** - Secure storage rules with:
- Admin-only upload for product/promotional images
- User-specific folders for profile pictures
- MIME type validation (images only)
- File size limits (max 10MB)
- Public read for public assets
- Admin-only access for sensitive files

**Paths Secured:**
- `/home/*` - Home page assets (admin upload, public read)
- `/products/*` - Product images (admin upload, public read)
- `/promotions/*` - Promotional banners (admin upload, public read)
- `/ingredients/*` - Ingredient images (admin upload, public read)
- `/config/*` - Configuration images (admin upload, public read)
- `/users/{userId}/*` - User profile images (user upload, public read)
- `/user_content/{userId}/*` - User-generated content (user upload, authenticated read)
- `/admin/*` - Admin-only files (admin-only access)

### 2. Firebase App Check

✅ **COMPLETED** - App Check integration:
- Platform-specific attestation:
  - **Android**: Play Integrity API (production) / Debug provider (development)
  - **iOS**: App Attest (production) / Debug provider (development)
  - **Web**: reCAPTCHA v3
- Automatic fallback to debug provider in development mode
- Protects against unauthorized clients and bots

**⚠️ MANUAL SETUP REQUIRED:**
1. Register your app with Firebase App Check in Firebase Console
2. For Android: Enable Play Integrity API in Google Cloud Console
3. For iOS: No additional setup needed (App Attest is automatic)
4. For Web: Create a reCAPTCHA v3 site key and replace `'recaptcha-v3-site-key'` in `lib/main.dart`
5. Add App Check enforcement to Firestore and Storage rules in Firebase Console

### 3. Firebase Crashlytics

✅ **COMPLETED** - Crash reporting integration:
- Automatic crash reporting for all unhandled exceptions
- Flutter framework error capture
- Asynchronous error capture
- Non-fatal error reporting via ErrorHandler utility
- Context-aware error logging

**⚠️ MANUAL SETUP REQUIRED:**
1. Enable Crashlytics in Firebase Console
2. For iOS: Update `ios/Runner/Info.plist` with Crashlytics settings if needed
3. Test crash reporting with a test crash

### 4. Authentication & Authorization

✅ **COMPLETED** - Auth security:
- Firebase Authentication integration
- Role-based access control (admin, client, kitchen)
- Admin screen protection in routing
- Staff tablet (CAISSE) restricted to admin users only
- Firestore rules enforce server-side role checking

**⚠️ MANUAL SETUP REQUIRED - CRITICAL:**

#### Setting Up Admin Custom Claims (Recommended)

Custom claims provide the most secure way to manage admin access. Follow these steps:

1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Initialize Cloud Functions (if not already done):**
   ```bash
   cd /path/to/your/project
   firebase init functions
   ```

3. **Create an Admin Cloud Function:**
   
   Create `functions/src/index.ts`:
   ```typescript
   import * as functions from 'firebase-functions';
   import * as admin from 'firebase-admin';

   admin.initializeApp();

   // SECURITY: Only call this function from a secure admin panel or Firebase Console
   export const setAdminClaim = functions.https.onCall(async (data, context) => {
     // Verify the caller is authenticated
     if (!context.auth) {
       throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
     }

     // SECURITY: Add additional verification here
     // For example, check if the caller is already an admin
     const callerUid = context.auth.uid;
     const callerDoc = await admin.firestore().collection('users').doc(callerUid).get();
     if (callerDoc.data()?.role !== 'admin') {
       throw new functions.https.HttpsError('permission-denied', 'Only admins can grant admin access');
     }

     // Get target user ID
     const uid = data.uid;

     // Set custom claim
     await admin.auth().setCustomUserClaims(uid, { admin: true });

     // Update Firestore role
     await admin.firestore().collection('users').doc(uid).update({
       role: 'admin',
       updatedAt: admin.firestore.FieldValue.serverTimestamp(),
     });

     return { message: `Admin claim set for user ${uid}` };
   });

   // Initialize first admin (call once, then disable)
   export const initFirstAdmin = functions.https.onRequest(async (req, res) => {
     // SECURITY: Add a secret token check here
     const secret = req.query.secret;
     if (secret !== 'YOUR_SECRET_TOKEN_HERE') {
       res.status(403).send('Forbidden');
       return;
     }

     const email = req.query.email as string;
     if (!email) {
       res.status(400).send('Email required');
       return;
     }

     // Find user by email
     const user = await admin.auth().getUserByEmail(email);

     // Set admin claim
     await admin.auth().setCustomUserClaims(user.uid, { admin: true });

     // Update Firestore
     await admin.firestore().collection('users').doc(user.uid).set({
       email: user.email,
       role: 'admin',
       createdAt: admin.firestore.FieldValue.serverTimestamp(),
       updatedAt: admin.firestore.FieldValue.serverTimestamp(),
     }, { merge: true });

     res.send(`Admin claim set for ${email}`);
   });
   ```

4. **Deploy the functions:**
   ```bash
   firebase deploy --only functions
   ```

5. **Set your first admin:**
   ```bash
   # Method 1: Using initFirstAdmin function (one-time use)
   curl "https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/initFirstAdmin?email=admin@example.com&secret=YOUR_SECRET_TOKEN_HERE"

   # Method 2: Using Firebase CLI
   firebase functions:config:set admin.email="admin@example.com"
   ```

6. **After setting first admin, disable initFirstAdmin function for security**

#### Alternative: Manual Firestore Role Setup (Less Secure Fallback)

If you cannot use custom claims immediately:

1. Sign up as a user in your app
2. Go to Firebase Console → Firestore Database
3. Find your user document in the `users` collection
4. Manually change the `role` field to `'admin'`
5. ⚠️ **WARNING**: This method is less secure as it relies on Firestore for auth checks, which adds latency

### 5. Rate Limiting & Abuse Protection

✅ **COMPLETED** - Client-side rate limiting:
- **Orders**: Max 1 order per minute (for client orders, not CAISSE)
- **Roulette spins**: Max 1 spin per 30 seconds
- Rate limit tracking in dedicated Firestore collections
- Server-validated via Firestore rules

✅ **COMPLETED** - Input validation:
- Order item count: Max 50 items
- Order total: Max €10,000
- String sanitization (names, phone, comments)
- Email format validation
- Price validation

### 6. Build Security & Optimization

✅ **COMPLETED** - Android:
- **R8 Code Shrinking**: Enabled in release builds
- **Resource Shrinking**: Removes unused resources
- **Code Obfuscation**: ProGuard rules configured
- **Network Security Config**: Enforces HTTPS, allows localhost for emulators
- **Secure Manifest**: Disabled backup, disabled cleartext traffic
- **ProGuard Rules**: Firebase-compatible rules included

✅ **COMPLETED** - iOS:
- **App Transport Security**: HTTPS enforced, localhost exception for emulators
- **Privacy Descriptions**: Camera and photo library usage descriptions

### 7. Firestore Query Security

✅ **VERIFIED** - All queries reviewed:
- Composite indexes defined in `firebase/firestore.indexes.json`
- No unsafe multi-orderBy patterns
- All queries use proper indexes:
  - `orders`: (uid + createdAt), (status + createdAt), (isViewed + createdAt)
  - `user_roulette_spins`: (userId + spunAt)

**Indexes Required:**
All necessary composite indexes are defined in `firestore.indexes.json`. Deploy them with:
```bash
firebase deploy --only firestore:indexes
```

## 📋 Manual Setup Checklist

### Firebase Console Setup

- [ ] **Firestore Rules**: Deploy rules with `firebase deploy --only firestore:rules`
- [ ] **Storage Rules**: Deploy rules with `firebase deploy --only storage:rules`
- [ ] **Firestore Indexes**: Deploy indexes with `firebase deploy --only firestore:indexes`
- [ ] **App Check**: Enable App Check in Firebase Console
  - [ ] Register Android app
  - [ ] Register iOS app  
  - [ ] Register Web app (if applicable)
  - [ ] Enable App Check enforcement for Firestore
  - [ ] Enable App Check enforcement for Storage
- [ ] **Crashlytics**: Enable Crashlytics in Firebase Console
- [ ] **Authentication**: Enable Email/Password authentication
- [ ] **Custom Claims**: Set up Cloud Functions for admin management (see above)
- [ ] **First Admin**: Create first admin user using Cloud Function or manual Firestore edit

### Google Cloud Console Setup

- [ ] **Play Integrity API**: Enable for Android App Check
- [ ] **App Attest**: Already enabled for iOS (no action needed)
- [ ] **reCAPTCHA**: Create v3 site key for Web (if using web platform)

### Code Updates Required

- [ ] **Web reCAPTCHA Key**: Replace `'recaptcha-v3-site-key'` in `lib/main.dart` with your actual key
- [ ] **Test Credentials**: Remove or secure test admin credentials in production

### Android Specific

- [ ] **Release Signing**: Configure proper signing keys for release builds (replace debug signing)
- [ ] **ProGuard Testing**: Test release build thoroughly to ensure ProGuard doesn't break functionality
- [ ] **App Check Debug Token**: Generate debug token for development devices

### iOS Specific

- [ ] **App Attest**: Verify App Attest is working (automatic for iOS 14+)
- [ ] **App Check Debug Token**: Generate debug token for development devices

## 🧪 Testing Security

### Test Firestore Rules
```bash
# Install Firebase emulators
firebase init emulators

# Start emulators
firebase emulators:start

# Run tests (create tests in test/ directory)
npm test
```

### Test App Check
1. Enable App Check in Firebase Console
2. Run app in debug mode
3. Check logs for App Check token acquisition
4. Verify requests to Firestore/Storage succeed

### Test Crashlytics
1. Add a test crash button in debug mode
2. Trigger a crash
3. Restart app
4. Check Firebase Console → Crashlytics for the crash report

### Test Rate Limiting
1. Try to create multiple orders within 60 seconds (should fail after first)
2. Try to spin roulette multiple times within 30 seconds (should fail after first)
3. Check Firestore for rate limit documents being created

### Test ProGuard
```bash
# Build release APK
flutter build apk --release

# Install and test thoroughly
# Check that obfuscation doesn't break functionality
```

## 🔐 Security Best Practices

### For Developers

1. **Never commit secrets** to version control
2. **Use environment variables** for sensitive configuration
3. **Test security rules** before deploying to production
4. **Keep dependencies updated** regularly
5. **Review Crashlytics** reports weekly
6. **Monitor Firestore usage** for unusual patterns
7. **Regularly audit user roles** and permissions
8. **Use custom claims** for admin users (not Firestore roles)

### For Deployment

1. **Deploy rules before app** to prevent window of vulnerability
2. **Test in staging** environment first
3. **Enable App Check enforcement** gradually (monitor impact)
4. **Set up alerts** for security rule violations
5. **Configure backup** strategy for Firestore data
6. **Document admin procedures** for team

## 📞 Security Incident Response

If you discover a security vulnerability:

1. **Do not** disclose publicly
2. **Immediately revoke** compromised credentials
3. **Update security rules** to patch vulnerability
4. **Review access logs** in Firebase Console
5. **Notify affected users** if data was compromised
6. **Document the incident** and response

## 🔄 Regular Security Maintenance

### Monthly
- [ ] Review Crashlytics reports
- [ ] Check for dependency updates
- [ ] Audit user roles and admin access
- [ ] Review Firestore usage patterns

### Quarterly
- [ ] Full security audit
- [ ] Update dependencies
- [ ] Review and update security rules
- [ ] Test disaster recovery procedures

### Annually
- [ ] Comprehensive penetration testing
- [ ] Security training for team
- [ ] Review and update security documentation

## 📚 Additional Resources

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/rules)
- [Firebase App Check Documentation](https://firebase.google.com/docs/app-check)
- [Firebase Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/security)
- [ProGuard Documentation](https://www.guardsquare.com/manual/home)

---

**Last Updated**: 2025-11-20
**Security Review Status**: ✅ Implementation Complete - Manual Setup Required
