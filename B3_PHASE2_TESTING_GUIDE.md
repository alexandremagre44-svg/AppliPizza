# B3 Phase 2 - Testing Guide

## Quick Start Testing

This guide helps you validate all the B3 Phase 2 stabilization improvements.

## Prerequisites

1. **Admin Account**: You need an admin account to test Studio B3
2. **Firebase Setup**: Firestore must be configured and accessible
3. **App Running**: Flutter app must be running in debug or release mode

## Test Suite

### 1. Auto-Page Verification (5 min)

#### Test 1.1: Fresh Install
**Objective**: Verify pages auto-create on first launch

**Steps**:
1. Clear Firestore data for `app_configs/pizza_delizza/configs/`
2. Launch the app
3. Login as admin
4. Navigate to `/admin/studio-b3`

**Expected Result**:
- ✅ 4 pages should appear: home-b3, menu-b3, categories-b3, cart-b3
- ✅ No errors in console
- ✅ All pages have default blocks

**Log Output**:
```
AppConfigService: Checking mandatory B3 pages for appId: pizza_delizza
AppConfigService: All mandatory B3 pages exist
```

#### Test 1.2: Missing Page Recovery
**Objective**: Verify auto-healing of deleted pages

**Steps**:
1. In Firestore, delete the `menu-b3` page from the config
2. Restart the app
3. Navigate to `/admin/studio-b3`

**Expected Result**:
- ✅ menu-b3 page is recreated automatically
- ✅ Other pages remain unchanged
- ✅ Page appears in list with default content

**Log Output**:
```
AppConfigService: Missing B3 pages: [/menu-b3]
AppConfigService: Adding missing page: Menu B3 (/menu-b3)
AppConfigService: Published config updated with missing B3 pages
AppConfigService: Draft config updated with missing B3 pages
```

### 2. Deep Linking Navigation (3 min)

#### Test 2.1: Direct Page Access
**Objective**: Verify deep linking to specific pages

**Steps**:
1. Navigate to `/admin/studio-b3/home-b3` (type in browser or use context.go())
2. Verify page editor opens with home-b3 loaded
3. Navigate to `/admin/studio-b3/menu-b3`
4. Verify page editor opens with menu-b3 loaded

**Expected Result**:
- ✅ Editor opens directly without showing page list first
- ✅ Correct page is loaded and displayed
- ✅ Blocks are visible in left panel
- ✅ Preview shows page content

#### Test 2.2: Invalid Route Handling
**Objective**: Verify graceful handling of non-existent pages

**Steps**:
1. Navigate to `/admin/studio-b3/non-existent-page`
2. Observe behavior

**Expected Result**:
- ✅ Returns to page list view
- ✅ Shows SnackBar: "Page '/non-existent-page' non trouvée"
- ✅ No crash or error screen
- ✅ Can continue working normally

### 3. PreviewPanel Robustness (5 min)

#### Test 3.1: Normal Preview
**Objective**: Verify preview works with valid pages

**Steps**:
1. Navigate to `/admin/studio-b3`
2. Click on any page (e.g., home-b3)
3. Observe preview panel on the right

**Expected Result**:
- ✅ Preview displays correctly
- ✅ Phone mockup visible
- ✅ Page content renders
- ✅ "LIVE" badge shows

#### Test 3.2: Malformed Block Handling
**Objective**: Verify preview doesn't crash with bad data

**Steps**:
1. In Studio B3, edit a block
2. Manually modify properties to invalid values (if possible via console)
3. Or create a block with missing required properties
4. Observe preview panel

**Expected Result**:
- ✅ Preview shows error widget instead of crashing
- ✅ Error message: "Impossible d'afficher l'aperçu"
- ✅ Error details displayed in dev-friendly format
- ✅ Can continue editing other blocks
- ✅ App doesn't crash

**Note**: This is hard to test manually. The error boundary is primarily for safety.

### 4. DynamicPageScreen Robustness (5 min)

#### Test 4.1: Normal Page Display
**Objective**: Verify live pages display correctly

**Steps**:
1. Navigate to `/home-b3`
2. Navigate to `/menu-b3`
3. Navigate to `/categories-b3`
4. Navigate to `/cart-b3`

**Expected Result**:
- ✅ All pages load without errors
- ✅ Content displays correctly
- ✅ Blocks render as expected
- ✅ No console errors

#### Test 4.2: Non-Existent Page
**Objective**: Verify PageNotFoundScreen displays

**Steps**:
1. Navigate to `/some-page-that-does-not-exist-b3`
2. Observe screen

**Expected Result**:
- ✅ PageNotFoundScreen displays
- ✅ Icon: 🔍 search_off
- ✅ Title: "Page B3 non trouvée"
- ✅ Message shows the route
- ✅ "Retour" button works

### 5. Edit → Publish → View Workflow (10 min)

#### Test 5.1: Complete Workflow
**Objective**: Verify full edit-publish-view cycle

**Steps**:
1. Navigate to `/admin/studio-b3`
2. Open home-b3 page
3. Edit a text block (change text content)
4. Click "Sauvegarder"
5. Click "Publier" in top-right
6. Navigate to `/home-b3` (live page)
7. Verify change is visible
8. Go back to Studio B3
9. Edit menu-b3 page
10. Add a new block
11. Save and publish
12. Navigate to `/menu-b3`
13. Verify new block appears

**Expected Result**:
- ✅ Changes saved successfully (green SnackBar)
- ✅ Publish successful (green SnackBar)
- ✅ Live page reflects changes immediately
- ✅ Multiple pages can be edited independently
- ✅ No data loss or corruption

**Log Output**:
```
AppConfigService: Draft saved successfully for appId: pizza_delizza
AppConfigService: Draft published successfully for appId: pizza_delizza (version: X)
```

#### Test 5.2: Revert Changes
**Objective**: Verify revert functionality

**Steps**:
1. Edit a page (make changes)
2. DON'T publish
3. Click "Annuler" in top-right
4. Confirm revert
5. Reopen the page

**Expected Result**:
- ✅ Confirmation dialog appears
- ✅ Changes are discarded
- ✅ Page returns to last published state
- ✅ SnackBar: "Modifications annulées"

### 6. Error Handling (3 min)

#### Test 6.1: Network Error Simulation
**Objective**: Verify graceful handling of network issues

**Steps**:
1. Disable network or Firestore connection
2. Try to save/publish in Studio B3
3. Observe behavior

**Expected Result**:
- ✅ Error SnackBar with meaningful message
- ✅ App doesn't crash
- ✅ Can retry after network restored

#### Test 6.2: Invalid Config Handling
**Objective**: Verify app handles corrupted data

**Steps**:
1. In Firestore, corrupt a page config (invalid JSON structure)
2. Try to load the page in Studio B3

**Expected Result**:
- ✅ Error state displayed
- ✅ Option to create default config
- ✅ No crash

### 7. Multi-Page Editing (5 min)

#### Test 7.1: Switch Between Pages
**Objective**: Verify smooth page switching

**Steps**:
1. Open home-b3
2. Make changes (don't save)
3. Click back arrow
4. Open menu-b3
5. Observe behavior

**Expected Result**:
- ✅ "Modifications non sauvegardées" dialog appears
- ✅ Options: Annuler, Ignorer, Sauvegarder
- ✅ Choosing "Ignorer" loses changes
- ✅ Choosing "Sauvegarder" saves first

#### Test 7.2: Multiple Tabs (if supported)
**Objective**: Test concurrent editing

**Steps**:
1. Open Studio B3 in two browser tabs
2. Edit different pages in each tab
3. Save/publish from both

**Expected Result**:
- ✅ Both tabs work independently
- ✅ Changes from both tabs are saved
- ✅ Real-time updates via Firestore streams
- ✅ No conflicts (last write wins)

### 8. Block Operations (5 min)

#### Test 8.1: Add All Block Types
**Objective**: Verify all 14 block types work

**Steps**:
1. Open a page in Studio B3
2. Click "Ajouter un bloc"
3. Try adding each block type:
   - text
   - image
   - button
   - banner
   - productList
   - categoryList
   - heroAdvanced
   - carousel
   - popup
   - productSlider
   - categorySlider
   - promoBanner
   - stickyCta
   - custom

**Expected Result**:
- ✅ All blocks can be added
- ✅ Default properties are set
- ✅ Preview renders each type
- ✅ No crashes or errors

#### Test 8.2: Block Reordering
**Objective**: Verify drag & drop works

**Steps**:
1. Create multiple blocks
2. Drag blocks to reorder
3. Save and publish
4. View live page

**Expected Result**:
- ✅ Blocks reorder in editor
- ✅ Preview updates immediately
- ✅ Live page shows new order
- ✅ Order persists after refresh

### 9. Mobile Responsiveness (3 min)

#### Test 9.1: Preview Phone Mockup
**Objective**: Verify preview looks like mobile

**Steps**:
1. Open Studio B3 page editor
2. Observe preview panel

**Expected Result**:
- ✅ Preview width: 375px (iPhone width)
- ✅ Status bar shows "9:41"
- ✅ Content scrollable
- ✅ Looks like phone screen

#### Test 9.2: Live Page on Mobile
**Objective**: Test actual mobile display

**Steps**:
1. Open live B3 page on mobile device or responsive mode
2. Test all 4 pages

**Expected Result**:
- ✅ Pages render correctly on mobile
- ✅ No horizontal scroll
- ✅ Touch interactions work
- ✅ Blocks responsive

### 10. Performance (3 min)

#### Test 10.1: Page Load Time
**Objective**: Verify pages load quickly

**Steps**:
1. Clear browser cache
2. Navigate to `/home-b3`
3. Measure load time

**Expected Result**:
- ✅ Page loads in < 2 seconds
- ✅ No loading spinner hang
- ✅ Smooth rendering

#### Test 10.2: Studio B3 Responsiveness
**Objective**: Verify editor is fast

**Steps**:
1. Open page with many blocks (10+)
2. Edit blocks
3. Observe preview updates

**Expected Result**:
- ✅ Preview updates instantly
- ✅ No lag when typing
- ✅ Smooth scrolling
- ✅ No frame drops

## Test Results Template

Use this template to record your test results:

```markdown
## Test Session: [Date]
**Tester**: [Name]
**Environment**: [Dev/Staging/Prod]
**Browser**: [Chrome/Safari/Firefox]
**Device**: [Desktop/Mobile]

### Test Results

| Test ID | Test Name | Result | Notes |
|---------|-----------|--------|-------|
| 1.1 | Fresh Install | ✅/❌ | |
| 1.2 | Missing Page Recovery | ✅/❌ | |
| 2.1 | Direct Page Access | ✅/❌ | |
| 2.2 | Invalid Route Handling | ✅/❌ | |
| 3.1 | Normal Preview | ✅/❌ | |
| 3.2 | Malformed Block Handling | ✅/❌ | |
| 4.1 | Normal Page Display | ✅/❌ | |
| 4.2 | Non-Existent Page | ✅/❌ | |
| 5.1 | Complete Workflow | ✅/❌ | |
| 5.2 | Revert Changes | ✅/❌ | |
| 6.1 | Network Error Simulation | ✅/❌ | |
| 6.2 | Invalid Config Handling | ✅/❌ | |
| 7.1 | Switch Between Pages | ✅/❌ | |
| 7.2 | Multiple Tabs | ✅/❌ | |
| 8.1 | Add All Block Types | ✅/❌ | |
| 8.2 | Block Reordering | ✅/❌ | |
| 9.1 | Preview Phone Mockup | ✅/❌ | |
| 9.2 | Live Page on Mobile | ✅/❌ | |
| 10.1 | Page Load Time | ✅/❌ | |
| 10.2 | Studio B3 Responsiveness | ✅/❌ | |

### Issues Found
[List any issues discovered]

### Overall Assessment
[Pass/Fail with summary]
```

## Automated Testing (Future)

For CI/CD integration, consider:

1. **Unit Tests**:
   - `ensureMandatoryB3Pages()` idempotency
   - `getPage()` route validation
   - Error boundary widget tests

2. **Integration Tests**:
   - Full edit-publish-view workflow
   - Page auto-creation on startup
   - Deep linking navigation

3. **E2E Tests** (using flutter_driver or integration_test):
   - Complete user journeys
   - Multi-page editing
   - Error scenarios

## Troubleshooting

### Issue: Pages don't auto-create
**Symptom**: Empty page list in Studio B3  
**Solution**:
1. Check Firestore connection
2. Verify `AppConstants.appId` is correct
3. Check console logs for errors
4. Manually run `ensureMandatoryB3Pages()`

### Issue: Preview shows error
**Symptom**: "Impossible d'afficher l'aperçu"  
**Solution**:
1. Check page schema JSON structure
2. Verify block properties are valid
3. Check console for specific error
4. Try creating a new simple page

### Issue: Deep linking doesn't work
**Symptom**: URL doesn't open specific page  
**Solution**:
1. Verify page exists in Firestore
2. Check route matches exactly (case-sensitive)
3. Ensure logged in as admin
4. Clear browser cache

### Issue: Changes not reflected in live
**Symptom**: Published changes not visible  
**Solution**:
1. Verify publish succeeded (check SnackBar)
2. Refresh live page (hard refresh: Cmd+Shift+R)
3. Check Firestore published config
4. Verify `appConfigProvider` is watching published config

## Success Criteria

All tests should pass with:
- ✅ 0 crashes
- ✅ 0 unhandled exceptions
- ✅ 0 broken workflows
- ✅ All pages accessible
- ✅ All features working as documented

## Reporting Issues

If you find issues during testing:

1. **Capture Details**:
   - Exact steps to reproduce
   - Expected vs actual behavior
   - Screenshots/videos
   - Console logs
   - Environment details

2. **Check Existing Issues**:
   - Review known limitations in docs
   - Check if issue already reported

3. **Report**:
   - Create GitHub issue
   - Use template above
   - Tag with `B3 Phase 2` label

## Contact

For questions about this testing guide:
- Review `B3_PHASE2_STABILIZATION_SUMMARY.md`
- Review `B3_PHASE2_SECURITY_SUMMARY.md`
- Check code comments in modified files
