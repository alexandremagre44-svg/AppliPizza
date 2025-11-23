# B3 Phase 7 - Testing Checklist

## Issue Fixed ✅
**Problem**: Les pages B3 (home-b3, menu-b3, categories-b3, cart-b3) étaient des "pages lambda" - elles s'affichaient correctement mais n'étaient pas éditables dans Studio B3.

**Solution**: Intégration Firestore complète avec providers Riverpod pour synchroniser Studio B3 et les pages dynamiques.

## Pre-Testing Setup

### 1. Clean Firestore (Optional - Fresh Start)
If you want to test the auto-initialization from scratch:
```
1. Open Firebase Console
2. Navigate to Firestore Database
3. Delete collection: app_configs/pizza_delizza/configs
4. This will force the app to recreate the default config
```

### 2. Build & Run
```bash
flutter clean
flutter pub get
flutter run
```

## Testing Checklist

### ✅ Phase 1: First Launch (Auto-Initialization)

- [ ] **1.1** App launches without errors
- [ ] **1.2** Check Firestore console:
  - [ ] Collection `app_configs/pizza_delizza/configs` exists
  - [ ] Document `config` (published) exists
  - [ ] Document `config_draft` (draft) exists
  - [ ] Both contain `pages` field with 4 pages

- [ ] **1.3** Navigate to `/home-b3`
  - [ ] Page loads (may show loading spinner briefly)
  - [ ] Hero banner displays with title "Bienvenue chez Pizza Deli'Zza"
  - [ ] Promo banner shows "🎉 Offre Spéciale"
  - [ ] Product slider shows "⭐ Nos Meilleures Ventes"
  - [ ] Category slider shows "📂 Explorez nos catégories"

- [ ] **1.4** Navigate to `/menu-b3`
  - [ ] Page loads successfully
  - [ ] Banner shows "🍕 Notre Menu"
  - [ ] Title shows "Découvrez nos pizzas"
  - [ ] Product list displays (or placeholder if no products)

- [ ] **1.5** Navigate to `/categories-b3`
  - [ ] Page loads successfully
  - [ ] Banner shows "📂 Catégories"
  - [ ] Category list displays (or placeholder)

- [ ] **1.6** Navigate to `/cart-b3`
  - [ ] Page loads successfully
  - [ ] Banner shows "🛒 Votre Panier"
  - [ ] Message shows "Votre panier est vide"
  - [ ] Button "Retour au menu" is visible

### ✅ Phase 2: Studio B3 Visibility

- [ ] **2.1** Login as admin
- [ ] **2.2** Navigate to `/admin/studio-b3`
  - [ ] Studio B3 opens without errors
  - [ ] Page list displays

- [ ] **2.3** Verify page list shows 4 pages:
  - [ ] **Accueil B3** (/home-b3)
    - [ ] Shows 6 bloc(s)
    - [ ] Toggle switch is ON (enabled)
  - [ ] **Menu B3** (/menu-b3)
    - [ ] Shows 3 bloc(s)
    - [ ] Toggle switch is ON (enabled)
  - [ ] **Catégories B3** (/categories-b3)
    - [ ] Shows 3 bloc(s)
    - [ ] Toggle switch is ON (enabled)
  - [ ] **Panier B3** (/cart-b3)
    - [ ] Shows 4 bloc(s)
    - [ ] Toggle switch is ON (enabled)

- [ ] **2.4** Each page card shows:
  - [ ] Page name
  - [ ] Route (in blue monospace)
  - [ ] Block count
  - [ ] "Modifier" button
  - [ ] Delete icon (🗑️)
  - [ ] Enable/disable toggle

### ✅ Phase 3: Edit Workflow - Simple Edit

- [ ] **3.1** Click "Modifier" on **Menu B3**
- [ ] **3.2** Page Editor opens with 3 panels:
  - [ ] Left: Block list (banner_menu, title_menu, products_menu)
  - [ ] Center: Block editor (empty until block selected)
  - [ ] Right: Live preview

- [ ] **3.3** Select the banner block (banner_menu)
  - [ ] Center panel shows properties:
    - [ ] Text field: "🍕 Notre Menu"
    - [ ] Background color: #D62828 (red)
    - [ ] Text color: #FFFFFF (white)
  
- [ ] **3.4** Edit the banner text:
  - [ ] Change "🍕 Notre Menu" to "🍕 Menu du Jour"
  - [ ] Preview updates in real-time on the right
  - [ ] Banner shows new text immediately

- [ ] **3.5** Save changes:
  - [ ] Click "💾 Sauvegarder" button in header
  - [ ] Success message appears
  - [ ] No errors in console

- [ ] **3.6** Return to page list (click "←" back button)
  - [ ] Page list shows again
  - [ ] Menu B3 still shows 3 bloc(s)

### ✅ Phase 4: Verify Draft NOT Live Yet

- [ ] **4.1** Open new tab/window
- [ ] **4.2** Navigate to `/menu-b3`
- [ ] **4.3** Verify banner still shows:
  - [ ] **OLD TEXT**: "🍕 Notre Menu" ❌
  - [ ] **NOT NEW TEXT**: "🍕 Menu du Jour" yet
  - [ ] This is correct! Changes are in draft, not published

### ✅ Phase 5: Publish Changes

- [ ] **5.1** Back to Studio B3 tab
- [ ] **5.2** On page list, click "Publier" button
- [ ] **5.3** Confirmation dialog appears
  - [ ] Click "Publier" to confirm
  - [ ] Success message appears
  - [ ] Publishing indicator shows briefly

- [ ] **5.4** Check Firestore console:
  - [ ] Published config (`config`) updated
  - [ ] `pages[1]` (Menu B3) has new banner text

### ✅ Phase 6: Verify Changes are Live

- [ ] **6.1** Switch to tab with `/menu-b3` open
- [ ] **6.2** Refresh the page
- [ ] **6.3** Verify banner NOW shows:
  - [ ] **NEW TEXT**: "🍕 Menu du Jour" ✅
  - [ ] Text color is white
  - [ ] Background is red

**SUCCESS!** Changes from Studio B3 are now visible in the live page! 🎉

### ✅ Phase 7: Test Toggle Enable/Disable

- [ ] **7.1** In Studio B3, on page list
- [ ] **7.2** Click toggle switch to disable "Menu B3"
  - [ ] Toggle turns OFF (gray)
  - [ ] Message appears: "Page désactivée"

- [ ] **7.3** Click "Publier" to publish the change
- [ ] **7.4** Navigate to `/menu-b3`
  - [ ] Verify behavior (implementation decides if disabled pages show 404 or just aren't listed)

- [ ] **7.5** Re-enable Menu B3 and publish

### ✅ Phase 8: Test Revert Changes

- [ ] **8.1** Make an edit in Studio B3 (but don't publish)
  - [ ] Edit a block
  - [ ] Click "Sauvegarder"

- [ ] **8.2** Click "Annuler" button in header
- [ ] **8.3** Confirmation dialog appears
- [ ] **8.4** Click "Oui, annuler"
  - [ ] Draft is reverted to published version
  - [ ] Your unsaved edit is gone

### ✅ Phase 9: Test Complex Edit (Home Page)

- [ ] **9.1** Open "Accueil B3" in editor
- [ ] **9.2** Verify 6 blocks are shown:
  - [ ] hero_home (heroAdvanced)
  - [ ] promo_home (promoBanner)
  - [ ] bestsellers_slider (productSlider)
  - [ ] categories_slider (categorySlider)
  - [ ] sticky_cart_cta (stickyCta)
  - [ ] welcome_popup (popup)

- [ ] **9.3** Edit hero block:
  - [ ] Change title
  - [ ] Preview updates immediately

- [ ] **9.4** Test drag & drop:
  - [ ] Drag promo_home above hero_home
  - [ ] Order updates in preview
  - [ ] Save and verify new order persists

- [ ] **9.5** Toggle block visibility:
  - [ ] Hide welcome_popup (toggle OFF)
  - [ ] Preview doesn't show popup
  - [ ] Save, publish, verify

### ✅ Phase 10: Test Real-Time Updates (Advanced)

- [ ] **10.1** Open two browser windows:
  - [ ] Window A: Studio B3 editor
  - [ ] Window B: `/menu-b3` page

- [ ] **10.2** In Window A (Studio):
  - [ ] Edit banner color to blue (#2196F3)
  - [ ] Save and publish

- [ ] **10.3** In Window B (Page):
  - [ ] Refresh page
  - [ ] Verify banner is now blue ✅

### ✅ Phase 11: Test Error Handling

- [ ] **11.1** Simulate Firestore connection error:
  - [ ] Go offline or block Firestore in browser
  - [ ] Navigate to `/menu-b3`
  - [ ] Verify fallback works:
    - [ ] Either shows error with retry
    - [ ] OR shows default config from code

- [ ] **11.2** Restore connection
  - [ ] Page should reload successfully

### ✅ Phase 12: Test New Page Creation

- [ ] **12.1** In Studio B3, click "Ajouter une page"
- [ ] **12.2** New page created:
  - [ ] ID: page_[timestamp]
  - [ ] Name: "Nouvelle Page"
  - [ ] Route: "/new-page"
  - [ ] Enabled: OFF
  - [ ] 0 blocks

- [ ] **12.3** Editor opens automatically
- [ ] **12.4** Add blocks, edit, save
- [ ] **12.5** Enable page and publish
- [ ] **12.6** Navigate to `/new-page`
  - [ ] Page displays your content ✅

### ✅ Phase 13: Test Delete Page

- [ ] **13.1** Delete the test page you created
- [ ] **13.2** Confirmation dialog appears
- [ ] **13.3** Confirm deletion
- [ ] **13.4** Page removed from list
- [ ] **13.5** Publish changes
- [ ] **13.6** Navigate to deleted route
  - [ ] Shows PageNotFoundScreen

## Performance Tests

### ✅ Loading Performance
- [ ] **P1** First load of `/menu-b3`:
  - [ ] Loading spinner shows briefly (< 1 second)
  - [ ] Page renders smoothly
  - [ ] No lag or freeze

- [ ] **P2** Navigate between B3 pages:
  - [ ] home-b3 → menu-b3: Smooth transition
  - [ ] menu-b3 → cart-b3: Smooth transition
  - [ ] No rebuild delays

### ✅ Studio B3 Performance
- [ ] **P3** Opening Studio B3:
  - [ ] Page list loads in < 2 seconds
  - [ ] All 4 pages displayed

- [ ] **P4** Opening Page Editor:
  - [ ] Editor opens in < 1 second
  - [ ] Preview renders immediately

- [ ] **P5** Editing blocks:
  - [ ] Real-time preview updates instantly
  - [ ] No input lag in text fields

## Browser Compatibility

Test on multiple browsers:

### Chrome
- [ ] All features work
- [ ] No console errors

### Firefox
- [ ] All features work
- [ ] No console errors

### Safari (if available)
- [ ] All features work
- [ ] No console errors

### Mobile (if available)
- [ ] Pages render correctly
- [ ] Studio B3 usable on tablet

## Regression Tests

Verify nothing broke:

### ✅ Other Pages Still Work
- [ ] `/home` (Home V1) - unchanged
- [ ] `/home-b2` (Home B2) - unchanged
- [ ] `/menu` (Menu V1) - unchanged
- [ ] `/cart` (Cart V1) - unchanged

### ✅ Studio B2 Still Works
- [ ] `/admin/studio-b2` opens
- [ ] Can edit sections
- [ ] Can publish changes
- [ ] HomeScreenB2 reflects changes

### ✅ Authentication Still Works
- [ ] Login works
- [ ] Admin pages require admin role
- [ ] Non-admin redirected from Studio B3

## Known Limitations (Expected)

These are NOT bugs, just not yet implemented:

- [ ] DataSources show placeholders (productList, categoryList)
  - Will be connected in Phase 8
- [ ] Some advanced block types may not render
  - Will be implemented in future phases
- [ ] No undo/redo in editor
  - Use draft/revert workflow instead

## Success Criteria ✅

All of the following must be TRUE:

1. ✅ B3 pages appear in Studio B3 list
2. ✅ Pages are editable in Studio B3 editor
3. ✅ Changes saved to draft work correctly
4. ✅ Publish workflow works (draft → published)
5. ✅ Live pages show published content
6. ✅ Real-time updates work after publish
7. ✅ No regressions in other parts of app
8. ✅ No console errors during normal use
9. ✅ Firestore rules allow proper access
10. ✅ Performance is acceptable (< 2s loads)

## If Tests Fail

### Common Issues & Fixes

**Issue**: Studio B3 shows "Aucune page dynamique"
- **Fix**: Check Firestore, click "Créer la configuration par défaut"

**Issue**: Changes not reflected after publish
- **Fix**: Hard refresh page (Ctrl+Shift+R), check Firestore for updates

**Issue**: "Permission denied" error
- **Fix**: Check Firestore rules, ensure admin authentication

**Issue**: Loading spinner forever
- **Fix**: Check console for errors, verify Firestore connection, check network

**Issue**: Preview not updating in editor
- **Fix**: Click "Sauvegarder" first, then preview updates

## Reporting Results

After testing, report:

1. **Pass/Fail**: Overall result
2. **Passed Tests**: Count (e.g., 42/45)
3. **Failed Tests**: List with details
4. **Bugs Found**: Description + steps to reproduce
5. **Performance**: Any slowness or issues
6. **Browser Compatibility**: Which browsers tested

## Next Steps After Testing

If all tests pass:
- ✅ Merge PR
- ✅ Deploy to production
- ✅ Monitor for issues
- ✅ Plan Phase 8 (DataSource connections)

If tests fail:
- ❌ Document failures
- ❌ Create fix tickets
- ❌ Re-test after fixes
