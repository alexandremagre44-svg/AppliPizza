# 🧪 Publish Page Feature - Test Plan

## Overview
Comprehensive test plan to validate the Publish Page system implementation for Builder B3.

## Pre-Test Setup
1. Ensure Firebase connection is active
2. Access the Builder admin panel
3. Have test data for different page types ready
4. Have WL modules configured in restaurant plan

---

## 📋 Test Cases

### Test Case 1: Publish Button Initial State
**Objective:** Verify button state on page load

**Steps:**
1. Open any page in the editor
2. Observe the publish button in the AppBar

**Expected Results:**
- ✅ Button shows cloud_upload icon (☁️)
- ✅ If page has no changes: Button is disabled (grayed out)
- ✅ If page has changes: Button is enabled with orange dot indicator
- ✅ Tooltip shows appropriate message

**Validation:**
- [ ] Button icon is cloud_upload
- [ ] Button state matches hasUnpublishedChanges
- [ ] Tooltip is correct
- [ ] Orange indicator appears only when changes exist

---

### Test Case 2: Add Block - Button Activation
**Objective:** Verify button activates when content changes

**Steps:**
1. Open a page with no unpublished changes
2. Verify button is disabled
3. Click "Ajouter un bloc"
4. Add a simple text block
5. Observe the publish button

**Expected Results:**
- ✅ Button becomes enabled
- ✅ Orange dot indicator appears
- ✅ Tooltip changes to "Publier"
- ✅ "Modifs" badge appears in AppBar

**Validation:**
- [ ] Button enabled after adding block
- [ ] Orange indicator visible
- [ ] hasUnpublishedChanges = true
- [ ] UI reflects unpublished state

---

### Test Case 3: Publish System Page
**Objective:** Verify publishing works for system pages (home, menu, cart, profile)

**Test 3A: Home Page**
**Steps:**
1. Navigate to Home page editor
2. Add a hero block with title "Test Hero"
3. Click publish button
4. Confirm in dialog
5. Wait for success message

**Expected Results:**
- ✅ Confirmation dialog appears
- ✅ Success message shows "✅ Page publiée avec succès"
- ✅ Button becomes disabled
- ✅ Orange indicator disappears
- ✅ "Modifs" badge disappears
- ✅ hasUnpublishedChanges = false

**Validation:**
- [ ] Dialog shown before publish
- [ ] Success message displayed
- [ ] Button disabled after publish
- [ ] No visual indicators of changes
- [ ] Data saved to pages_published collection

**Test 3B: Menu Page**
- [ ] Repeat for menu page
- [ ] Verify catalog module publishes correctly

**Test 3C: Cart Page**
- [ ] Repeat for cart page  
- [ ] Verify cart module publishes correctly

**Test 3D: Profile Page**
- [ ] Repeat for profile page
- [ ] Verify profile module publishes correctly

---

### Test Case 4: Publish Custom Page
**Objective:** Verify publishing works for custom pages

**Steps:**
1. Create a new custom page (e.g., "Promotions")
2. Add several blocks (banner, text, product list)
3. Click publish button
4. Confirm in dialog
5. Verify success

**Expected Results:**
- ✅ Custom page publishes successfully
- ✅ All blocks appear in published version
- ✅ Button state updates correctly

**Validation:**
- [ ] Custom page can be published
- [ ] pageKey used correctly (not BuilderPageId enum)
- [ ] Data saved to pages_published/{pageKey}
- [ ] Draft updated with published state

---

### Test Case 5: Publish with WL Modules
**Objective:** Verify publishing works with White-Label modules

**Test 5A: Loyalty Module**
**Steps:**
1. Create/open a page
2. Add loyalty_module block
3. Publish the page
4. View in client runtime

**Expected Results:**
- ✅ Module publishes successfully
- ✅ Module appears in client app
- ✅ Module functions correctly

**Validation:**
- [ ] Loyalty module in publishedLayout
- [ ] Module visible in runtime
- [ ] Module is functional

**Test 5B: Newsletter Module**
- [ ] Repeat with newsletter_module
- [ ] Verify subscription works

**Test 5C: Promotions Module**
- [ ] Repeat with promotions_module
- [ ] Verify promotions display correctly

**Test 5D: Multiple Modules**
- [ ] Add all three modules to same page
- [ ] Publish
- [ ] Verify all appear in correct order

---

### Test Case 6: Modify Published Page
**Objective:** Verify re-publishing after modifications

**Steps:**
1. Open an already-published page
2. Verify button is disabled
3. Edit an existing block (change text)
4. Observe button state
5. Publish again
6. Verify changes appear in runtime

**Expected Results:**
- ✅ Button disabled initially
- ✅ Button enables after edit
- ✅ Re-publish works correctly
- ✅ Changes appear in runtime

**Validation:**
- [ ] Button reactivates on edit
- [ ] Second publish succeeds
- [ ] Runtime shows updated content
- [ ] hasUnpublishedChanges cycles correctly

---

### Test Case 7: Cancel Publish
**Objective:** Verify canceling publish dialog

**Steps:**
1. Make changes to a page
2. Click publish button
3. Click "Annuler" in dialog
4. Verify button state

**Expected Results:**
- ✅ Dialog closes without publishing
- ✅ Button remains enabled
- ✅ Orange indicator still visible
- ✅ Changes not published

**Validation:**
- [ ] Cancel works correctly
- [ ] No data written to Firestore
- [ ] Button state unchanged
- [ ] hasUnpublishedChanges still true

---

### Test Case 8: Publish Empty Page
**Objective:** Verify behavior with empty draftLayout

**Steps:**
1. Create a new blank page
2. Don't add any blocks
3. Attempt to publish

**Expected Results:**
- ⚠️ May be blocked by safety check
- OR publishes empty layout if no existing content

**Validation:**
- [ ] Safety check works if applicable
- [ ] No data loss
- [ ] Appropriate error/warning message

---

### Test Case 9: Draft/Published Preview Toggle
**Objective:** Verify preview toggle after publishing

**Steps:**
1. Edit a page and publish it
2. Toggle between "Brouillon" and "Publié" tabs
3. Make a new edit (don't publish)
4. Toggle again

**Expected Results:**
- ✅ "Brouillon" shows current draftLayout
- ✅ "Publié" shows last published version
- ✅ After edit, brouillon != publié

**Validation:**
- [ ] Toggle works correctly
- [ ] Brouillon shows draftLayout
- [ ] Publié shows publishedLayout
- [ ] Content differs when expected

---

### Test Case 10: Multiple Block Operations
**Objective:** Verify hasUnpublishedChanges updates for all operations

**Test 10A: Add Block**
- [ ] Add block → hasUnpublishedChanges = true

**Test 10B: Remove Block**
- [ ] Remove block → hasUnpublishedChanges = true

**Test 10C: Edit Block**
- [ ] Edit block config → hasUnpublishedChanges = true

**Test 10D: Reorder Blocks**
- [ ] Reorder blocks → hasUnpublishedChanges = true

**Test 10E: Publish All**
- [ ] Publish → hasUnpublishedChanges = false

---

### Test Case 11: Runtime Verification
**Objective:** Verify client runtime reads only publishedLayout

**Steps:**
1. Create a page with specific content
2. Publish it
3. View in client app
4. Return to editor, make changes (don't publish)
5. View in client app again

**Expected Results:**
- ✅ After publish: content appears in client
- ✅ After edit (no publish): client shows old content
- ✅ Client never sees draftLayout

**Validation:**
- [ ] Client shows published version
- [ ] Draft edits not visible until published
- [ ] Runtime reads pages_published only

---

### Test Case 12: Auto-Save vs Publish
**Objective:** Verify auto-save doesn't affect published state

**Steps:**
1. Make changes to a page
2. Wait for auto-save (2 seconds)
3. Verify button still enabled
4. Check hasUnpublishedChanges

**Expected Results:**
- ✅ Auto-save writes to pages_draft
- ✅ Button remains enabled
- ✅ hasUnpublishedChanges still true
- ✅ Published version unchanged

**Validation:**
- [ ] Auto-save doesn't clear hasUnpublishedChanges
- [ ] Button stays enabled
- [ ] pages_published not modified by auto-save

---

### Test Case 13: Error Handling
**Objective:** Verify graceful error handling

**Test 13A: Network Error**
**Steps:**
1. Simulate network disconnection
2. Make changes
3. Try to publish

**Expected Results:**
- ✅ Error message shown
- ✅ Button remains enabled
- ✅ Can retry after reconnection

**Test 13B: Permission Error**
- [ ] Test with restricted permissions
- [ ] Verify appropriate error message

---

### Test Case 14: French Typography
**Objective:** Verify proper French character usage

**Steps:**
1. Click publish button
2. Read confirmation dialog
3. Check tooltip messages

**Expected Results:**
- ✅ Proper apostrophes (') used
- ✅ No escaped characters visible
- ✅ Proper French grammar

**Validation:**
- [ ] Dialog text uses proper apostrophes
- [ ] Tooltip text correct
- [ ] No \' escapes visible

---

## 🔍 Regression Tests

### No Modifications to Runtime Files
**Objective:** Verify runtime files unchanged

**Files to Check:**
- [ ] `lib/builder/runtime/dynamic_builder_page_screen.dart`
- [ ] `lib/builder/runtime/builder_page_loader.dart`
- [ ] Runtime renderer components
- [ ] Preview components

**Validation:**
- [ ] Git diff shows no changes to these files
- [ ] Runtime behavior unchanged
- [ ] Client apps work as before

---

## 📊 Success Criteria

### Functional Requirements
- [ ] Publish button exists in UI
- [ ] Button disables when no changes
- [ ] Button enables when changes exist
- [ ] Visual indicator (orange dot) shows pending changes
- [ ] Confirmation dialog before publish
- [ ] draftLayout copied to publishedLayout on publish
- [ ] Firestore write to pages_published
- [ ] Local state updated after publish
- [ ] hasUnpublishedChanges flag correct
- [ ] Client runtime unchanged

### Performance Requirements
- [ ] Publish operation < 3 seconds
- [ ] UI responsive during publish
- [ ] No lag when toggling button state

### UX Requirements
- [ ] Clear visual feedback
- [ ] Appropriate tooltips
- [ ] Success/error messages clear
- [ ] French text properly formatted

---

## 🐛 Known Issues / Limitations

1. **Auth TODO**: userId hardcoded to 'admin' (pre-existing pattern)
2. **Offline Mode**: Not tested with offline persistence
3. **Concurrent Edits**: Not tested with multiple editors

---

## 📝 Test Execution Log

**Date:** _____________
**Tester:** _____________
**Environment:** _____________

| Test Case | Status | Notes |
|-----------|--------|-------|
| TC1 | ☐ Pass ☐ Fail | |
| TC2 | ☐ Pass ☐ Fail | |
| TC3A | ☐ Pass ☐ Fail | |
| TC3B | ☐ Pass ☐ Fail | |
| TC3C | ☐ Pass ☐ Fail | |
| TC3D | ☐ Pass ☐ Fail | |
| TC4 | ☐ Pass ☐ Fail | |
| TC5A | ☐ Pass ☐ Fail | |
| TC5B | ☐ Pass ☐ Fail | |
| TC5C | ☐ Pass ☐ Fail | |
| TC5D | ☐ Pass ☐ Fail | |
| TC6 | ☐ Pass ☐ Fail | |
| TC7 | ☐ Pass ☐ Fail | |
| TC8 | ☐ Pass ☐ Fail | |
| TC9 | ☐ Pass ☐ Fail | |
| TC10 | ☐ Pass ☐ Fail | |
| TC11 | ☐ Pass ☐ Fail | |
| TC12 | ☐ Pass ☐ Fail | |
| TC13 | ☐ Pass ☐ Fail | |
| TC14 | ☐ Pass ☐ Fail | |

**Overall Result:** ☐ All Pass ☐ Some Failures

**Notes:**
_____________________________________________________________
_____________________________________________________________
_____________________________________________________________

---

**Implementation Status:** ✅ READY FOR TESTING
**Confidence Level:** HIGH
**Risk Level:** LOW
