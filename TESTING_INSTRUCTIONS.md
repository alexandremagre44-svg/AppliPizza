# Testing Instructions - Home Page Refactor

## Prerequisites

1. Flutter SDK installed (version 3.0.0 or higher)
2. Valid Android/iOS emulator or physical device
3. Clean build environment

## Setup

```bash
cd /path/to/AppliPizza
flutter clean
flutter pub get
flutter pub upgrade
```

## Running the Application

### Desktop (for quick testing)
```bash
flutter run -d macos  # or linux, windows
```

### Mobile Emulator
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Web (limited testing)
```bash
flutter run -d chrome
```

## Test Checklist

### 1. Build & Compilation ✅

#### Test Steps:
1. Run `flutter analyze` - Should have 0 errors
2. Run `flutter pub get` - Should succeed
3. Run `flutter run` - Should compile without errors

#### Expected Results:
- No compilation errors
- No missing imports
- No null-safety issues
- App starts successfully

#### Failure Indicators:
- ❌ Compilation error
- ❌ Missing package error
- ❌ Import not found
- ❌ Widget not found

---

### 2. Home Page Display ✅

#### Test Steps:
1. Launch the app
2. Wait for home page to load
3. Observe layout

#### Expected Results:
- Hero banner displays at top
- "Bienvenue chez Pizza Deli'Zza" title visible
- "Voir le menu" button present
- Sections load in order:
  1. Hero Banner
  2. Promos (if available)
  3. Best-sellers
  4. Category shortcuts
  5. Info banner

#### Failure Indicators:
- ❌ Blank screen
- ❌ Error message
- ❌ Sections out of order
- ❌ Missing sections

---

### 3. Hero Banner Functionality ✅

#### Test Steps:
1. Verify hero banner displays
2. Read title and subtitle
3. Tap "Voir le menu" button

#### Expected Results:
- Button responds to tap
- Navigates to Menu page
- Menu page loads correctly
- Can navigate back to Home

#### Failure Indicators:
- ❌ Button doesn't respond
- ❌ Wrong page loads
- ❌ Navigation crash
- ❌ Can't go back

---

### 4. Promos Section ✅

#### Test Steps:
1. Check if "🔥 Promos du moment" section appears
2. Scroll horizontally through promo cards
3. Tap on a promo card

#### Expected Results:
- Section shows if promos available
- Section hidden if no promos
- Cards scroll smoothly left/right
- Tapping card opens customization modal
- Modal displays correctly
- Can add to cart from modal

#### Failure Indicators:
- ❌ Section shows when no promos
- ❌ Can't scroll
- ❌ Tap doesn't work
- ❌ Modal doesn't open
- ❌ Modal crashes

---

### 5. Best Sellers Grid ✅

#### Test Steps:
1. Scroll to "⭐ Best-sellers" section
2. View grid of products
3. Tap on a product card
4. Add item to cart

#### Expected Results:
- Shows 4 products in 2x2 grid
- Products have images, names, prices
- "Personnaliser" badge on pizzas
- Tapping opens customization modal
- Can add to cart
- SnackBar shows confirmation
- Cart count updates

#### Failure Indicators:
- ❌ Empty grid
- ❌ Wrong number of items
- ❌ Missing images
- ❌ Tap doesn't work
- ❌ Cart doesn't update

---

### 6. Category Shortcuts ✅

#### Test Steps:
1. Scroll to "Nos catégories" section
2. View 4 category buttons
3. Tap each button:
   - Pizzas
   - Menus
   - Boissons
   - Desserts

#### Expected Results:
- 4 buttons visible in a row
- Each has icon and label
- Tapping navigates to Menu page
- Menu page maintains its functionality
- Can navigate back

#### Failure Indicators:
- ❌ Buttons missing
- ❌ Wrong number of buttons
- ❌ Tap doesn't work
- ❌ Wrong navigation

---

### 7. Info Banner ✅

#### Test Steps:
1. Scroll to bottom
2. Read info banner

#### Expected Results:
- Banner displays: "À emporter uniquement — 11h–21h (Mar→Dim)"
- Light gray background
- Centered text
- Info icon visible

#### Failure Indicators:
- ❌ Banner missing
- ❌ Wrong text
- ❌ Styling broken

---

### 8. Navigation Flow ✅

#### Test Steps:
1. From Home, tap "Voir le menu" → Should go to Menu
2. From Menu, tap back → Should return to Home
3. From Home, tap category shortcut → Should go to Menu
4. From Menu, tap back → Should return to Home
5. From Home, tap Cart icon → Should go to Cart
6. From Cart, tap back → Should return to Home
7. From Home, tap Profile icon → Should go to Profile
8. From Profile, tap back → Should return to Home

#### Expected Results:
- All navigation works
- Back button works everywhere
- No navigation loops
- No crashes

#### Failure Indicators:
- ❌ Navigation stuck
- ❌ Back button broken
- ❌ App crashes
- ❌ Wrong page loads

---

### 9. Cart Integration ✅

#### Test Steps:
1. Add product from Home page
2. Check cart icon badge
3. Navigate to Cart
4. Verify item is there

#### Expected Results:
- SnackBar shows: "🍕 [Product] ajouté au panier !"
- Cart icon shows item count
- Cart page shows added item
- Quantity is correct

#### Failure Indicators:
- ❌ No SnackBar
- ❌ Cart count wrong
- ❌ Item not in cart
- ❌ Cart crash

---

### 10. Menu Page Regression ✅

#### Test Steps:
1. Navigate to Menu page
2. Use category tabs
3. Use search
4. Use filters
5. Add items to cart
6. Check customization modals

#### Expected Results:
- All Menu features work as before
- No visual changes to Menu
- No functionality changes
- No new bugs

#### Failure Indicators:
- ❌ Menu broken
- ❌ Features missing
- ❌ New bugs
- ❌ Visual changes

---

### 11. Responsive Layout ✅

#### Test Steps:
1. Run on iPhone SE (small screen)
2. Run on iPhone 14 (medium screen)
3. Run on iPad (large screen)
4. Rotate device (portrait/landscape)

#### Expected Results:
- No overflow errors
- All content visible
- Scrolling works
- Buttons reachable
- Text readable

#### Failure Indicators:
- ❌ Overflow warning
- ❌ Content cut off
- ❌ Can't scroll
- ❌ Text too small

---

### 12. Pull to Refresh ✅

#### Test Steps:
1. On Home page, pull down from top
2. Wait for loading indicator
3. Wait for data to reload

#### Expected Results:
- Pull gesture works
- Loading indicator shows (red color)
- Data refreshes
- Page updates

#### Failure Indicators:
- ❌ Gesture doesn't work
- ❌ No loading indicator
- ❌ Data doesn't refresh
- ❌ App crashes

---

### 13. Error Handling ✅

#### Test Steps:
1. Simulate no internet (airplane mode)
2. Launch app
3. Try to load home page
4. Tap "Réessayer"

#### Expected Results:
- Error state displays
- Error icon shows
- Error message clear
- Retry button works
- Data loads on retry (with internet)

#### Failure Indicators:
- ❌ App crashes
- ❌ Blank screen
- ❌ No error message
- ❌ Retry doesn't work

---

### 14. Loading States ✅

#### Test Steps:
1. Launch app (first time)
2. Observe loading indicator
3. Wait for data to load

#### Expected Results:
- CircularProgressIndicator shows
- Red color (brand color)
- Centered on screen
- Disappears when loaded

#### Failure Indicators:
- ❌ No loading indicator
- ❌ Wrong color
- ❌ Hangs forever
- ❌ Crashes

---

### 15. Product Modals ✅

#### Test Steps:
1. Tap pizza → Should open ElegantPizzaCustomizationModal
2. Tap menu → Should open MenuCustomizationModal
3. Tap drink → Should add directly + show SnackBar
4. Tap dessert → Should add directly + show SnackBar

#### Expected Results:
- Correct modal for each product type
- Modals display properly
- Can customize (pizza/menu)
- Can add to cart
- Modal closes after add

#### Failure Indicators:
- ❌ Wrong modal
- ❌ Modal doesn't open
- ❌ Can't customize
- ❌ Can't add to cart
- ❌ Modal doesn't close

---

## Performance Tests

### 16. Scroll Performance ✅

#### Test Steps:
1. Scroll Home page top to bottom
2. Scroll fast
3. Scroll slow
4. Fling scroll

#### Expected Results:
- Smooth scrolling
- No lag
- No frame drops
- No crashes

#### Failure Indicators:
- ❌ Stuttering
- ❌ Lag
- ❌ Frame drops
- ❌ Crashes

---

### 17. Memory Usage ✅

#### Test Steps:
1. Navigate: Home → Menu → Home → Cart → Home
2. Repeat 10 times
3. Check memory usage (DevTools)

#### Expected Results:
- Memory usage stable
- No memory leaks
- No crashes
- App remains responsive

#### Failure Indicators:
- ❌ Memory increasing
- ❌ App slows down
- ❌ Crashes
- ❌ Out of memory error

---

## Edge Cases

### 18. Empty Data ✅

#### Test Steps:
1. Modify mock data to have no products
2. Launch app

#### Expected Results:
- No crash
- Empty state shows
- Message: "Aucun produit disponible"
- App remains usable

#### Failure Indicators:
- ❌ Crash
- ❌ Blank screen
- ❌ No message

---

### 19. No Promos ✅

#### Test Steps:
1. Modify mock data to have no promo products
2. Launch app

#### Expected Results:
- Promos section hidden
- No empty space
- Other sections show normally

#### Failure Indicators:
- ❌ Empty section shows
- ❌ Crash
- ❌ Layout broken

---

### 20. No Featured Products ✅

#### Test Steps:
1. Modify mock data to have no featured products
2. Launch app

#### Expected Results:
- Best sellers shows first 4 pizzas (fallback)
- Section displays normally

#### Failure Indicators:
- ❌ Empty section
- ❌ Crash
- ❌ No fallback

---

### 21. Image Loading Failures ✅

#### Test Steps:
1. Use invalid image URLs in products
2. Launch app

#### Expected Results:
- Placeholder icons show
- No crashes
- Pizza icon displays instead
- App remains functional

#### Failure Indicators:
- ❌ Crash
- ❌ Blank images
- ❌ Error widgets

---

## Regression Tests

### 22. Authentication Flow ✅

#### Test Steps:
1. Logout from Profile
2. Should redirect to Login
3. Login again
4. Should show Home page

#### Expected Results:
- Auth flow unchanged
- All pages protected
- Login works
- Logout works

#### Failure Indicators:
- ❌ Auth broken
- ❌ Can access without login
- ❌ Login fails
- ❌ Logout fails

---

### 23. Admin Features ✅

#### Test Steps:
1. Login as admin
2. Navigate to Admin pages
3. Add/edit/delete products
4. Return to Home
5. Verify changes reflect

#### Expected Results:
- Admin features work
- Product CRUD works
- Changes visible on Home
- No regressions

#### Failure Indicators:
- ❌ Admin pages broken
- ❌ CRUD fails
- ❌ Changes not reflected

---

## Automated Tests (Optional)

### Widget Tests
```bash
flutter test
```

Expected: All tests pass (if tests exist)

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

Expected: All integration tests pass (if they exist)

---

## Known Issues / Limitations

1. **Flutter SDK required**: Cannot test without Flutter installed
2. **No visual regression tests**: Manual visual verification needed
3. **No automated UI tests**: Manual testing required
4. **Device-specific issues**: Test on multiple devices recommended

---

## Success Criteria

✅ All 23 test sections pass
✅ No crashes or errors
✅ Menu page unchanged
✅ Cart works correctly
✅ Navigation flows correctly
✅ Responsive on all screen sizes
✅ Performance acceptable

---

## Failure Recovery

If tests fail:

1. **Compilation errors**: Check imports, run `flutter pub get`
2. **Navigation issues**: Verify routes in `main.dart`
3. **Widget not found**: Check widget imports
4. **Data issues**: Check Product model fields
5. **Styling issues**: Check AppTheme constants
6. **Modal issues**: Check customization modal imports

---

## Reporting Issues

When reporting issues, include:

1. Device/Emulator details
2. Flutter version (`flutter --version`)
3. Steps to reproduce
4. Expected vs actual behavior
5. Screenshots/screen recordings
6. Error logs (`flutter logs`)

---

## Contact

For questions about these tests:
- Review `HOME_PAGE_REFACTOR.md` for technical details
- Review `HOME_PAGE_VISUAL_GUIDE.md` for visual specifications
- Check Git history for implementation details
