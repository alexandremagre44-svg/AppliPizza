# Testing Guide: Builder B3 Fix

This guide provides step-by-step instructions to verify the Builder B3 fix is working correctly.

## Prerequisites

- [ ] App is built and running
- [ ] You have admin credentials
- [ ] You can access `/admin/studio-b3`

## Test 1: Verify Page Cleanup ✅

**Goal:** Confirm that old duplicate `-b3` pages have been removed.

### Steps:

1. **Run the app**
   ```bash
   flutter run
   ```

2. **Check console logs**
   Look for these messages during startup:
   ```
   🧹 CLEANUP: Starting duplicate -b3 pages cleanup for appId: pizza_delizza
   🧹 CLEANUP: Published config cleaned - removed X duplicate pages
   🧹 CLEANUP: Draft config cleaned - removed X duplicate pages
   ✅ CLEANUP: Duplicate -b3 pages cleanup completed
   ```

3. **On second run, should see:**
   ```
   🧹 CLEANUP: Already completed, skipping
   ```

**Expected Result:**
- ✅ First run removes old pages
- ✅ Second run skips (already cleaned)
- ✅ No errors in console

---

## Test 2: Studio B3 Shows Only Main Routes ✅

**Goal:** Verify that Studio B3 displays only main routes, no duplicates.

### Steps:

1. **Login as admin**
   - Navigate to `/login`
   - Enter admin credentials

2. **Open Studio B3**
   - Navigate to `/admin/studio-b3`

3. **Check page list**
   Should see exactly 4 pages:
   - [ ] **Accueil** (`/home`) [OFF] 🔴
   - [ ] **Menu** (`/menu`) [OFF] 🔴
   - [ ] **Panier** (`/cart`) [OFF] 🔴
   - [ ] **Catégories** (`/categories`) [OFF] 🔴

4. **Verify NO duplicate pages**
   Should NOT see:
   - ❌ Accueil B3 (`/home-b3`)
   - ❌ Menu B3 (`/menu-b3`)
   - ❌ Panier B3 (`/cart-b3`)
   - ❌ Catégories B3 (`/categories-b3`)

**Expected Result:**
- ✅ Exactly 4 pages displayed
- ✅ All using main routes (`/home`, `/menu`, `/cart`, `/categories`)
- ✅ All disabled by default (OFF 🔴)
- ✅ No pages with `-b3` suffix

---

## Test 3: Edit Page in Studio B3 ✅

**Goal:** Verify that editing a page works correctly.

### Steps:

1. **Open page editor**
   - In Studio B3, click "Modifier" on "Accueil (/home)"
   - Should see 3-panel editor:
     - Left: Block list
     - Center: Block properties
     - Right: Preview

2. **Edit the hero block**
   - Click on first block (Hero)
   - Change title to: "🍕 Test Builder B3 Fix"
   - Change subtitle to: "Cette page est éditable!"

3. **Check preview panel**
   - Preview should update in real-time
   - Should show new title and subtitle

4. **Save changes**
   - Click "💾 Sauvegarder" button
   - Should see success message

5. **Publish**
   - Click "Retour" to go back to page list
   - Click "Publier" button
   - Confirm publication

**Expected Result:**
- ✅ Editor opens correctly
- ✅ Can edit block properties
- ✅ Preview updates in real-time
- ✅ Changes save successfully
- ✅ Can publish without errors

---

## Test 4: Page Remains Disabled ✅

**Goal:** Verify that edited page doesn't affect app until explicitly enabled.

### Steps:

1. **Visit home page in app**
   - Navigate to `/home`
   - Should see the static HomeScreen

2. **Check content**
   - Should see original content
   - Should NOT see "Test Builder B3 Fix"
   - Confirms page is disabled

**Expected Result:**
- ✅ App shows static HomeScreen
- ✅ B3 changes are NOT visible
- ✅ No regression in app behavior

---

## Test 5: Enable B3 Page ✅

**Goal:** Verify that enabling the page makes it appear in the app.

### Steps:

1. **Return to Studio B3**
   - Navigate to `/admin/studio-b3`

2. **Enable the page**
   - Find "Accueil (/home)" page
   - Toggle "Enabled" switch to ON 🟢
   - Click "Publier"

3. **Visit home page in app**
   - Navigate to `/home`
   - **Should now see B3 page!**

4. **Verify content**
   - [ ] Title shows: "🍕 Test Builder B3 Fix"
   - [ ] Subtitle shows: "Cette page est éditable!"
   - [ ] All blocks render correctly
   - [ ] Page is functional (buttons work, etc.)

**Expected Result:**
- ✅ App shows B3 page (not static HomeScreen)
- ✅ Changes from Studio B3 are visible
- ✅ Page functions correctly

---

## Test 6: Preview Matches Reality ✅

**Goal:** Verify that preview panel shows exactly what appears in app.

### Steps:

1. **Open page editor again**
   - Studio B3 → Accueil (/home) → Modifier

2. **Compare preview to app**
   - Open app in another window: `/home`
   - Compare side-by-side

3. **Check visual consistency**
   - [ ] Same title
   - [ ] Same subtitle
   - [ ] Same colors
   - [ ] Same layout
   - [ ] Same images

**Expected Result:**
- ✅ Preview matches app exactly
- ✅ No visual differences
- ✅ "What you see is what you get"

---

## Test 7: Disable Page (Rollback) ✅

**Goal:** Verify that disabling returns to static page.

### Steps:

1. **Disable the page**
   - Studio B3 → Accueil (/home)
   - Toggle "Enabled" switch to OFF 🔴
   - Click "Publier"

2. **Visit home page**
   - Navigate to `/home`
   - Should return to static HomeScreen

3. **Verify rollback**
   - [ ] Shows original static content
   - [ ] No longer shows "Test Builder B3 Fix"
   - [ ] App works normally

**Expected Result:**
- ✅ App returns to static HomeScreen
- ✅ B3 changes are hidden
- ✅ Seamless rollback

---

## Test 8: Backward Compatibility ✅

**Goal:** Verify that old `-b3` URLs still work.

### Steps:

1. **Test old URL redirects**
   Visit each old URL and verify redirection:

   - [ ] `/home-b3` → redirects to `/home` ✅
   - [ ] `/menu-b3` → redirects to `/menu` ✅
   - [ ] `/cart-b3` → redirects to `/cart` ✅
   - [ ] `/categories-b3` → shows categories page ✅

2. **Check browser URL**
   After redirect, URL should change to main route

**Expected Result:**
- ✅ All old `-b3` URLs work
- ✅ Redirects happen automatically
- ✅ No broken links

---

## Test 9: Multiple Pages ✅

**Goal:** Verify that multiple pages can be edited independently.

### Steps:

1. **Edit Menu page**
   - Studio B3 → Menu (/menu) → Modifier
   - Change banner text to: "🍕 Notre Carte Éditable"
   - Save & Publish

2. **Enable Menu page**
   - Toggle "Enabled" to ON 🟢
   - Publish

3. **Verify both pages**
   - [ ] `/home` shows HomeScreen (disabled) OR custom B3 page (if enabled)
   - [ ] `/menu` shows B3 menu with "Notre Carte Éditable"

**Expected Result:**
- ✅ Can edit multiple pages independently
- ✅ Each page can be enabled/disabled separately
- ✅ No interference between pages

---

## Test 10: Navigation Actions ✅

**Goal:** Verify that navigation within B3 pages works correctly.

### Steps:

1. **Edit home page**
   - Studio B3 → Accueil (/home) → Modifier

2. **Add a button with navigation**
   - Add new button block
   - Set action to: `navigate:/menu`
   - Save & Publish

3. **Enable and test**
   - Enable home page
   - Visit `/home` in app
   - Click the button

4. **Verify navigation**
   - [ ] Button click navigates to `/menu`
   - [ ] Navigation is smooth
   - [ ] No errors in console

**Expected Result:**
- ✅ Navigation actions work correctly
- ✅ Routes use main paths (not `-b3`)
- ✅ User flow is seamless

---

## Test Summary Checklist

After completing all tests, verify:

- [ ] **Cleanup executed successfully** (Test 1)
- [ ] **Only 4 main pages in Studio B3** (Test 2)
- [ ] **Can edit pages** (Test 3)
- [ ] **Disabled pages don't affect app** (Test 4)
- [ ] **Enabled pages appear in app** (Test 5)
- [ ] **Preview matches reality** (Test 6)
- [ ] **Can rollback by disabling** (Test 7)
- [ ] **Old URLs redirect correctly** (Test 8)
- [ ] **Multiple pages work independently** (Test 9)
- [ ] **Navigation actions work** (Test 10)

## Success Criteria

All tests should pass with:
- ✅ No console errors
- ✅ No visual glitches
- ✅ Smooth user experience
- ✅ Expected behavior matches actual behavior

## If Tests Fail

### Common Issues:

1. **Cleanup didn't run**
   - Check console for error messages
   - Verify SharedPreferences is accessible
   - Try clearing app data and restarting

2. **Duplicate pages still appear**
   - Verify cleanup completed successfully
   - Check Firestore directly
   - May need to manually remove old pages

3. **Preview doesn't match app**
   - Check that same config is loaded
   - Verify published vs draft distinction
   - Check console for config loading errors

4. **Navigation doesn't work**
   - Verify routes are defined in main.dart
   - Check navigation action format
   - Look for routing errors in console

### Getting Help

If issues persist:
1. Check console logs for detailed errors
2. Review `B3_DUPLICATE_PAGES_FIX.md` for architecture details
3. Review `B3_FIX_SUMMARY.md` for overview
4. Check Firestore data directly in Firebase Console

---

**Test Version:** 1.0  
**Last Updated:** November 23, 2024  
**Status:** Ready for Testing
