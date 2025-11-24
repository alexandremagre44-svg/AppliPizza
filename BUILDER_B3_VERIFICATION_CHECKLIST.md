# Builder B3 Access Fix - Verification Checklist

Use this checklist to verify that the Builder B3 access management fix is working correctly.

---

## 📋 Pre-Deployment Checklist

### 1. Review Changes

- [ ] Review all modified files in the PR
- [ ] Verify Firestore rules syntax is correct
- [ ] Check that path structure is `builder/apps/{appId}/pages/{pageId}/{draft|published}`
- [ ] Confirm no other collections were modified

### 2. Code Quality Checks

- [x] Code review completed (minor nitpicks only)
- [x] Security scan passed (no vulnerabilities)
- [ ] Manual code review by team lead
- [ ] Approved for deployment

---

## 🚀 Deployment Steps

### Step 1: Deploy Firestore Rules

```bash
# Navigate to project directory
cd /path/to/AppliPizza

# Deploy only Firestore rules
firebase deploy --only firestore:rules

# Expected output:
# ✔ Deploy complete!
```

**Verification:**
- [ ] Rules deployed successfully
- [ ] No deployment errors
- [ ] Check Firebase Console → Firestore → Rules → Version history

### Step 2: Set Admin Custom Claims

#### Option A: Using Provided Script (Recommended)

```bash
# Install Firebase Admin SDK (if not already installed)
npm install firebase-admin

# Download service account key from Firebase Console
# Project Settings → Service Accounts → Generate New Private Key

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS="./serviceAccountKey.json"

# Run the script with your admin user UID
node scripts/set_admin_claim.js YOUR_ADMIN_UID

# Example:
node scripts/set_admin_claim.js dbmnp2DdyJaURWJO4YEE5fgv3002
```

**Expected Output:**
```
✅ Firebase Admin initialized
🔧 Setting admin claim for user: dbmnp2DdyJaURWJO4YEE5fgv3002
✅ User found: admin@delizza.com
✅ Admin claim set successfully!

📋 Current custom claims: { admin: true }

✅ SUCCESS: Admin claim is now active!

⚠️  Important:
   - User must logout and login again for changes to take effect
   - Or force token refresh in the app
```

**Verification:**
- [ ] Script ran without errors
- [ ] Custom claims shown as `{ admin: true }`
- [ ] Success message displayed

#### Option B: Using Firebase Console (Alternative)

⚠️ Note: Firebase Console doesn't support custom claims directly. Use Option A or Firebase Admin SDK.

#### Option C: Using Firebase Cloud Function

Create a Cloud Function to set claims (see documentation for details).

### Step 3: Verify Custom Claims in Firebase Console

```bash
# List all admin users (using script)
node scripts/set_admin_claim.js list
```

**Verification:**
- [ ] Admin user appears in list
- [ ] Custom claims show `{ admin: true }`
- [ ] Email matches expected admin user

---

## ✅ Functional Testing

### Test 1: Admin User Access

**Prerequisites:**
- [ ] Admin custom claim set
- [ ] User logged out and logged back in (or token refreshed)

**Steps:**
1. Login with admin credentials
2. Navigate to Builder B3 Studio
3. Verify access granted (no "Accès refusé" message)
4. Check that all pages are listed (Home, Menu, Promo, About, Contact)
5. Try to edit a page
6. Verify no permission-denied errors

**Expected Results:**
- [ ] ✅ Login successful
- [ ] ✅ Builder B3 Studio accessible
- [ ] ✅ All pages listed
- [ ] ✅ Can open page editor
- [ ] ✅ No Firestore permission errors

**Actual Results:**
```
[Write your observations here]
```

### Test 2: Non-Admin User Access

**Steps:**
1. Logout admin user
2. Login with regular client account (no admin claim)
3. Try to access Builder B3 Studio

**Expected Results:**
- [ ] ✅ Login successful
- [ ] ✅ "Accès refusé" message displayed
- [ ] ✅ Cannot access Builder B3
- [ ] ✅ No crashes or errors

**Actual Results:**
```
[Write your observations here]
```

### Test 3: Firestore Read Operations

**Steps:**
1. Login as admin
2. Navigate to Builder B3
3. Try to load a page (e.g., Home)
4. Check browser console for errors

**Expected Results:**
- [ ] ✅ Page data loads successfully
- [ ] ✅ No permission-denied errors in console
- [ ] ✅ Draft/published status displayed correctly

**Actual Results:**
```
[Write your observations here]
```

### Test 4: Firestore Write Operations

**Steps:**
1. Login as admin
2. Navigate to Builder B3
3. Edit a page (add/remove a block)
4. Save draft
5. Try to publish

**Expected Results:**
- [ ] ✅ Can add/remove blocks
- [ ] ✅ Can save draft
- [ ] ✅ Can publish page
- [ ] ✅ No permission-denied errors

**Actual Results:**
```
[Write your observations here]
```

### Test 5: Token Refresh

**Steps:**
1. Set admin claim for a user
2. Login with that user (without logout/login)
3. Try to access Builder B3 (should fail)
4. Force token refresh in app
5. Try again

**Expected Results:**
- [ ] ✅ Access denied before token refresh
- [ ] ✅ Access granted after token refresh

**Actual Results:**
```
[Write your observations here]
```

---

## 🐛 Troubleshooting Tests

### Issue 1: Permission Denied After Setting Claims

**Test Steps:**
1. Verify claims are set: `node scripts/set_admin_claim.js list`
2. Check if user logged out and back in
3. Force token refresh: `await FirebaseAuth.instance.currentUser?.getIdToken(true)`

**Resolution:**
- [ ] Claims verified in Firebase
- [ ] User logged out/in
- [ ] Token refreshed
- [ ] Issue resolved

### Issue 2: Wrong Firestore Path

**Test Steps:**
1. Check BuilderLayoutService code
2. Verify path is: `builder/apps/{appId}/pages/{pageId}/draft`
3. Check browser network tab for Firestore requests

**Resolution:**
- [ ] Path verified in code
- [ ] Path correct in network requests
- [ ] Issue resolved

### Issue 3: Rules Not Deployed

**Test Steps:**
1. Check Firebase Console → Firestore → Rules
2. Verify `match /builder/{path=**}` exists
3. Check version history for latest deployment

**Resolution:**
- [ ] Rules verified in console
- [ ] Latest version deployed
- [ ] Issue resolved

---

## 📊 Performance Testing

### Test 1: Load Time

**Steps:**
1. Login as admin
2. Navigate to Builder B3
3. Measure time to load page list
4. Measure time to load page editor

**Expected Results:**
- [ ] Page list loads in < 2 seconds
- [ ] Page editor loads in < 3 seconds
- [ ] No significant performance degradation

**Actual Results:**
```
[Write your measurements here]
```

### Test 2: Concurrent Access

**Steps:**
1. Have 2 admin users access Builder B3 simultaneously
2. Both edit different pages
3. Verify no conflicts

**Expected Results:**
- [ ] ✅ Both users can access Builder B3
- [ ] ✅ No conflicts or errors
- [ ] ✅ Changes saved independently

**Actual Results:**
```
[Write your observations here]
```

---

## 🔐 Security Testing

### Test 1: Unauthorized Access Attempt

**Steps:**
1. Try to access Firestore directly via browser console
2. Try to read `builder/apps/pizza_delizza/pages/home/draft` without auth
3. Try to write without admin claim

**Expected Results:**
- [ ] ✅ Permission denied for unauthenticated
- [ ] ✅ Permission denied for non-admin
- [ ] ✅ No data leakage

**Actual Results:**
```
[Write your observations here]
```

### Test 2: Token Manipulation

**Steps:**
1. Try to modify custom claims in browser
2. Verify changes rejected by Firestore

**Expected Results:**
- [ ] ✅ Client-side changes have no effect
- [ ] ✅ Firestore validates token on server

**Actual Results:**
```
[Write your observations here]
```

---

## 📝 Regression Testing

### Test 1: Other Collections Unaffected

**Steps:**
1. Login as client
2. Try to access products, orders, user profile
3. Verify normal functionality

**Expected Results:**
- [ ] ✅ Products load normally
- [ ] ✅ Orders accessible
- [ ] ✅ User profile works
- [ ] ✅ No side effects from Builder changes

**Actual Results:**
```
[Write your observations here]
```

### Test 2: Existing Admin Functions

**Steps:**
1. Login as admin
2. Test other admin functions (product management, orders, etc.)
3. Verify no regressions

**Expected Results:**
- [ ] ✅ All admin functions work
- [ ] ✅ No regressions introduced

**Actual Results:**
```
[Write your observations here]
```

---

## ✅ Sign-Off

### Development Team

- [ ] All tests passed
- [ ] No blocking issues
- [ ] Ready for staging deployment

**Tested by:** _______________  
**Date:** _______________  
**Signature:** _______________

### QA Team

- [ ] All tests passed
- [ ] No critical issues
- [ ] Ready for production deployment

**Tested by:** _______________  
**Date:** _______________  
**Signature:** _______________

---

## 📈 Final Summary

### Test Results

| Test Category | Total Tests | Passed | Failed | Blocked |
|---------------|-------------|--------|--------|---------|
| Pre-Deployment | 7 | __ | __ | __ |
| Functional | 5 | __ | __ | __ |
| Troubleshooting | 3 | __ | __ | __ |
| Performance | 2 | __ | __ | __ |
| Security | 2 | __ | __ | __ |
| Regression | 2 | __ | __ | __ |
| **TOTAL** | **21** | __ | __ | __ |

### Issues Found

| Issue ID | Severity | Description | Status |
|----------|----------|-------------|--------|
| | | | |
| | | | |

### Deployment Decision

- [ ] ✅ **APPROVED FOR PRODUCTION**
- [ ] ⚠️ **APPROVED WITH CONDITIONS** (specify conditions)
- [ ] ❌ **NOT APPROVED** (specify blockers)

**Decision by:** _______________  
**Date:** _______________  

---

## 📚 Additional Resources

- [BUILDER_B3_ACCESS_FIX_SUMMARY.md](./BUILDER_B3_ACCESS_FIX_SUMMARY.md) - Complete fix documentation
- [scripts/README.md](./scripts/README.md) - Script usage guide
- [BUILDER_B3_COMPLETE_GUIDE.md](./BUILDER_B3_COMPLETE_GUIDE.md) - Builder B3 documentation
- [Firebase Custom Claims](https://firebase.google.com/docs/auth/admin/custom-claims)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

**End of Checklist**
