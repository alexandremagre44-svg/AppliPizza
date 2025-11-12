# 🔍 Firebase Migration - Validation Checklist

## Pre-Deployment Checklist

Before deploying this Firebase-powered version to production, complete the following validations:

---

## 🔐 Firebase Configuration

### Firebase Console Setup
- [ ] Firebase project created
- [ ] Authentication enabled (Email/Password method)
- [ ] Cloud Firestore database created
- [ ] Firestore security rules deployed from `firestore.rules`
- [ ] Firebase billing enabled (if needed for production quotas)

### App Configuration
- [ ] `firebase_options.dart` generated with correct project credentials
- [ ] Web configuration complete (if deploying to web)
- [ ] Android `google-services.json` added (if deploying to Android)
- [ ] iOS `GoogleService-Info.plist` added (if deploying to iOS)

### Test Users Created
- [ ] Admin user created in Firebase Auth
- [ ] Kitchen user created in Firebase Auth
- [ ] Client user created in Firebase Auth
- [ ] User profiles created in Firestore `users` collection with correct roles
- [ ] All user passwords are strong and secure

---

## 🧪 Functional Testing

### Authentication Flow
- [ ] User can sign in with email/password
- [ ] Correct role is loaded from Firestore
- [ ] Auth state persists across app restarts
- [ ] User can sign out successfully
- [ ] Password reset flow works (if implemented)
- [ ] Error messages are user-friendly

### Client Role Testing
- [ ] Client can view menu/products
- [ ] Client can add items to cart
- [ ] Client can create an order
- [ ] Order appears in client's order list immediately
- [ ] Client can only see their own orders (not others')
- [ ] Client CANNOT modify order after creation
- [ ] Client can see real-time status updates from kitchen/admin

### Kitchen Role Testing
- [ ] Kitchen user can access kitchen mode
- [ ] Kitchen sees ALL orders in real-time
- [ ] New orders appear immediately without refresh
- [ ] Kitchen can mark orders as viewed
- [ ] Kitchen can update order status (pending → preparing → baking → ready)
- [ ] Status changes are reflected in client view immediately
- [ ] Kitchen CANNOT modify order total or items
- [ ] Kitchen receives visual/audio notifications for new orders

### Admin Role Testing
- [ ] Admin can access admin dashboard
- [ ] Admin sees ALL orders in real-time
- [ ] Admin can view order details
- [ ] Admin can update order status
- [ ] Admin can mark orders as viewed
- [ ] Admin can filter and search orders
- [ ] Admin CANNOT modify order total or items after creation
- [ ] Test data button is disabled (no local test data)

---

## 🔒 Security Validation

### Firestore Rules Testing
Use Firebase Emulator Suite or manual testing:

#### User Access
- [ ] User can read their own profile
- [ ] User CANNOT read other users' profiles
- [ ] User can update their own profile (except role field)
- [ ] User CANNOT update their role field
- [ ] Admin can read all user profiles
- [ ] Admin can update any user's role

#### Order Access - Client
- [ ] Client can create orders with their uid
- [ ] Client CANNOT create orders with another user's uid
- [ ] Client can read only their own orders
- [ ] Client CANNOT read other users' orders
- [ ] Client CANNOT update any order fields after creation
- [ ] Client CANNOT delete orders

#### Order Access - Kitchen
- [ ] Kitchen can read all orders
- [ ] Kitchen can update order status
- [ ] Kitchen can mark orders as viewed/seenByKitchen
- [ ] Kitchen CANNOT modify uid, total_cents, items, createdAt
- [ ] Kitchen CANNOT delete orders

#### Order Access - Admin
- [ ] Admin can read all orders
- [ ] Admin can update order status
- [ ] Admin can mark orders as viewed
- [ ] Admin CANNOT modify uid, total_cents, items, createdAt
- [ ] Admin can delete orders

### Field Immutability
- [ ] Order `uid` cannot be changed after creation
- [ ] Order `total_cents` cannot be changed after creation
- [ ] Order `items` array cannot be modified after creation
- [ ] Order `createdAt` cannot be modified
- [ ] Only status-related fields can be updated

---

## 🔄 Real-Time Synchronization

### Multi-Device Testing
- [ ] Open app on two devices as client
- [ ] Create order on device 1
- [ ] Verify order appears on device 2 immediately
- [ ] Update status from kitchen on device 3
- [ ] Verify status updates on both client devices immediately

### Performance
- [ ] Orders load within 2 seconds on fast connection
- [ ] Real-time updates have < 1 second latency
- [ ] App handles 10+ simultaneous orders smoothly
- [ ] No memory leaks during extended use
- [ ] Firestore quotas are within limits

---

## 📱 Platform-Specific Testing

### Web
- [ ] App loads and initializes Firebase correctly
- [ ] Authentication works on web
- [ ] Orders sync in real-time on web
- [ ] No console errors in browser DevTools
- [ ] Responsive design works on different screen sizes

### Android (if applicable)
- [ ] Firebase initializes correctly
- [ ] Authentication works
- [ ] Orders sync in real-time
- [ ] No crashes or ANRs
- [ ] Proper permissions requested

### iOS (if applicable)
- [ ] Firebase initializes correctly
- [ ] Authentication works
- [ ] Orders sync in real-time
- [ ] No crashes
- [ ] Proper permissions requested

---

## 🛡️ Error Handling

### Network Errors
- [ ] App shows appropriate error when offline
- [ ] App recovers gracefully when connection restored
- [ ] User-friendly error messages for network issues

### Authentication Errors
- [ ] Clear error message for wrong password
- [ ] Clear error message for non-existent user
- [ ] Clear error message for weak password (during signup)
- [ ] Clear error message for existing email (during signup)

### Firestore Errors
- [ ] Permission denied errors are handled gracefully
- [ ] Clear error messages when operations fail
- [ ] App doesn't crash on Firestore errors

---

## 📊 Data Integrity

### Order Creation
- [ ] All required fields are populated
- [ ] Total is calculated correctly
- [ ] total_cents matches total (cents = total * 100)
- [ ] Items array contains all cart items
- [ ] Customer information is correct
- [ ] Timestamps are accurate
- [ ] Status history is initialized correctly

### Status Updates
- [ ] Status changes are logged in statusHistory
- [ ] statusChangedAt timestamp updates correctly
- [ ] Status transitions follow logical flow
- [ ] Notes/comments are preserved

---

## 🧹 Code Quality

### Deprecated Code
- [ ] Old AuthService is not being used
- [ ] Old OrderService is not being used
- [ ] No active code references deprecated services
- [ ] Test credentials are not used in production

### Best Practices
- [ ] No hardcoded credentials in code
- [ ] No Firebase secrets in version control
- [ ] Error handling is consistent
- [ ] Loading states are shown to users
- [ ] No console.log/print statements in production code

---

## 📚 Documentation

- [ ] FIREBASE_SETUP.md is complete and accurate
- [ ] FIREBASE_MIGRATION_SUMMARY.md is up to date
- [ ] README.md mentions Firebase requirements
- [ ] Code comments are clear and helpful
- [ ] Security rules are documented

---

## 🚀 Pre-Production

### Performance Optimization
- [ ] Firestore indexes are created for common queries
- [ ] Unnecessary data fetching is avoided
- [ ] Images are optimized
- [ ] Bundle size is reasonable

### Monitoring Setup
- [ ] Firebase Analytics configured (optional)
- [ ] Crashlytics configured (optional)
- [ ] Error reporting in place
- [ ] Usage metrics being tracked

### Backup & Recovery
- [ ] Firestore backup strategy defined
- [ ] Data export process documented
- [ ] Rollback plan in place

---

## ✅ Final Sign-Off

**Date Tested:** __________________

**Tested By:** __________________

**Issues Found:** __________________

**Issues Resolved:** __________________

**Ready for Production:** [ ] YES  [ ] NO

**Additional Notes:**

---

---

## 🆘 Common Issues & Solutions

### Issue: "FirebaseOptions not configured"
**Solution:** Run `flutterfire configure` to generate firebase_options.dart

### Issue: "Permission denied" on Firestore
**Solution:** 
1. Check that user profile exists in Firestore `users` collection
2. Verify user has correct `role` field
3. Verify security rules are deployed

### Issue: Orders not appearing
**Solution:**
1. Check Firebase Console → Firestore to see if orders are being created
2. Verify security rules allow reading
3. Check console for errors

### Issue: Real-time updates not working
**Solution:**
1. Check internet connection
2. Verify Firestore is enabled
3. Check for listener errors in console
4. Verify streams are being watched correctly

### Issue: Can't sign in
**Solution:**
1. Verify user exists in Firebase Authentication
2. Check that Email/Password provider is enabled
3. Verify user profile exists in Firestore with correct role
4. Try password reset

---

## 📞 Support Contacts

**Firebase Console:** https://console.firebase.google.com

**Firebase Support:** https://firebase.google.com/support

**Project Repository:** https://github.com/alexandremagre44-svg/AppliPizza

---

**Remember:** Test thoroughly on a development Firebase project before deploying to production!
