# Staff Tablet Module - Testing Guide

## Testing Checklist

### ✅ Phase 1: PIN Authentication

#### Test 1.1: Initial PIN Entry
- [ ] Navigate to `/staff-tablet`
- [ ] PIN screen displays with number pad
- [ ] Enter default PIN: `1234`
- [ ] Auto-validates after 4 digits
- [ ] Redirects to catalog screen

#### Test 1.2: Wrong PIN
- [ ] Navigate to `/staff-tablet`
- [ ] Enter incorrect PIN (e.g., `0000`)
- [ ] Red error message appears
- [ ] PIN dots turn red
- [ ] PIN is cleared
- [ ] Can retry

#### Test 1.3: Session Persistence
- [ ] Log in with correct PIN
- [ ] Navigate away from staff tablet
- [ ] Return to `/staff-tablet/catalog` within session timeout
- [ ] Should remain authenticated (no PIN required)

#### Test 1.4: Logout
- [ ] Access catalog screen
- [ ] Click logout button (top right)
- [ ] Redirects to home
- [ ] Next access to staff tablet requires PIN

### ✅ Phase 2: Product Catalog

#### Test 2.1: Category Display
- [ ] All 4 categories visible: Pizzas, Menus, Boissons, Desserts
- [ ] Category chips are large and touch-friendly
- [ ] Selected category is highlighted in orange
- [ ] Products from selected category display in grid

#### Test 2.2: Product Grid
- [ ] Products display in 3-column grid
- [ ] Product images load correctly
- [ ] Product names and prices are visible
- [ ] Add button (+) is visible on each card

#### Test 2.3: Category Switching
- [ ] Click each category tab
- [ ] Products update to show only that category
- [ ] Empty categories show "no products" message
- [ ] Switching is smooth without lag

#### Test 2.4: Product Addition
- [ ] Click a product card
- [ ] Product added to cart (right panel)
- [ ] Green snackbar confirms addition
- [ ] Cart total updates

### ✅ Phase 3: Cart Management

#### Test 3.1: Cart Display
- [ ] Cart panel always visible on right side
- [ ] Shows "Panier vide" when empty
- [ ] Cart header shows item count
- [ ] Total displays at bottom

#### Test 3.2: Adding Products
- [ ] Add same product multiple times
- [ ] Quantity increments instead of duplicating
- [ ] Add different products
- [ ] Each appears as separate line item

#### Test 3.3: Quantity Controls
- [ ] Click + button on cart item
- [ ] Quantity increases
- [ ] Subtotal updates
- [ ] Total updates
- [ ] Click - button
- [ ] Quantity decreases
- [ ] When quantity reaches 0, item is removed

#### Test 3.4: Clear Cart
- [ ] Add multiple items
- [ ] Click "Vider le panier"
- [ ] Confirmation dialog appears
- [ ] Click "Vider"
- [ ] All items removed
- [ ] Total resets to 0

#### Test 3.5: Cart Summary
- [ ] Product images display
- [ ] Product names display
- [ ] Quantities display correctly
- [ ] Individual totals are correct
- [ ] Grand total is correct

### ✅ Phase 4: Checkout Flow

#### Test 4.1: Access Checkout
- [ ] Empty cart → "Valider" button is disabled
- [ ] Add items to cart
- [ ] "Valider la commande" button becomes active
- [ ] Click button
- [ ] Redirects to checkout screen

#### Test 4.2: Order Summary
- [ ] All cart items listed
- [ ] Quantities and prices correct
- [ ] Total matches cart total

#### Test 4.3: Customer Name (Optional)
- [ ] Field is optional (can leave blank)
- [ ] Can enter customer name
- [ ] Field accepts text input
- [ ] No validation errors when empty

#### Test 4.4: Pickup Time Selection
- [ ] "Dès que possible" is selected by default
- [ ] Can select "Créneau spécifique"
- [ ] Time slots display
- [ ] Can select a specific time slot
- [ ] Selection is highlighted

#### Test 4.5: Payment Method
- [ ] "Espèces" is selected by default
- [ ] Can select "Carte bancaire"
- [ ] Can select "Autre"
- [ ] Only one option can be selected

#### Test 4.6: Order Validation
- [ ] Fill all optional fields
- [ ] Click "Valider la commande"
- [ ] Processing indicator shows
- [ ] Success dialog appears
- [ ] Order details displayed in dialog

#### Test 4.7: Order Creation
- [ ] Create order
- [ ] Verify order appears in Firestore
- [ ] Check `source` field = "staff_tablet"
- [ ] Check `paymentMethod` is set
- [ ] Check `pickupTimeSlot` if scheduled

### ✅ Phase 5: Order History

#### Test 5.1: Access History
- [ ] Click history icon in catalog
- [ ] History screen loads
- [ ] Statistics card displays

#### Test 5.2: Statistics
- [ ] Order count is correct
- [ ] Revenue total is correct
- [ ] Values update in real-time

#### Test 5.3: Order List
- [ ] Only today's orders shown
- [ ] Only staff_tablet source orders shown
- [ ] Orders sorted by time (newest first)
- [ ] Each order shows:
  - [ ] Time
  - [ ] Customer name (if provided)
  - [ ] Item count
  - [ ] Payment method
  - [ ] Status badge
  - [ ] Total

#### Test 5.4: Order Details
- [ ] Click on an order
- [ ] Details dialog opens
- [ ] Complete order information shown
- [ ] Can close dialog

#### Test 5.5: Real-time Updates
- [ ] Open history screen
- [ ] Create new order from another session
- [ ] Order appears automatically in list
- [ ] Statistics update
- [ ] Change order status in kitchen module
- [ ] Status badge updates in history

### ✅ Phase 6: Integration Tests

#### Test 6.1: Firestore Integration
- [ ] Create order from staff tablet
- [ ] Check Firestore console
- [ ] Order exists in `orders` collection
- [ ] All fields are correctly saved
- [ ] Timestamps are set

#### Test 6.2: Kitchen Module Integration
- [ ] Create order from staff tablet
- [ ] Open kitchen module
- [ ] Order appears in kitchen view
- [ ] Can update status from kitchen
- [ ] Status updates visible in staff tablet history

#### Test 6.3: Admin Integration
- [ ] Access admin orders screen
- [ ] Staff tablet orders visible
- [ ] Can filter by source
- [ ] Order details accessible

#### Test 6.4: Multiple Concurrent Orders
- [ ] Create order from staff tablet
- [ ] Create order from client app (if available)
- [ ] Both appear correctly in their respective histories
- [ ] Kitchen sees both orders
- [ ] No conflicts or data corruption

### ✅ Phase 7: Edge Cases

#### Test 7.1: Empty States
- [ ] View catalog with no products
- [ ] View history with no orders
- [ ] Each shows appropriate message

#### Test 7.2: Network Issues
- [ ] Simulate offline mode
- [ ] Try to create order
- [ ] Error handling is graceful
- [ ] User is informed

#### Test 7.3: Session Timeout
- [ ] Log in
- [ ] Wait 8+ hours (or modify timeout for testing)
- [ ] Try to access protected route
- [ ] Redirects to PIN screen

#### Test 7.4: Invalid Product Images
- [ ] Product with invalid image URL
- [ ] Placeholder icon displays
- [ ] No crash or error

#### Test 7.5: Very Large Cart
- [ ] Add 20+ different items
- [ ] Cart scrolls properly
- [ ] Performance is acceptable
- [ ] Checkout processes correctly

### ✅ Phase 8: UI/UX Tests

#### Test 8.1: Touch Targets
- [ ] All buttons are easy to tap
- [ ] No accidental taps on nearby buttons
- [ ] Buttons respond to touch (visual feedback)

#### Test 8.2: Tablet Layout (10-11")
- [ ] Layout looks good on 10" tablet
- [ ] Layout looks good on 11" tablet
- [ ] Grid columns appropriate
- [ ] Text is readable
- [ ] No horizontal scrolling (except time slots)

#### Test 8.3: Orientation
- [ ] Test in landscape (primary)
- [ ] Test in portrait (if needed)
- [ ] Layout adapts appropriately

#### Test 8.4: Visual Feedback
- [ ] Button presses show feedback
- [ ] Loading states are visible
- [ ] Success messages are clear
- [ ] Error messages are clear

#### Test 8.5: Navigation Flow
- [ ] All back buttons work
- [ ] Navigation is intuitive
- [ ] No dead ends
- [ ] Can return to catalog from any screen

### ✅ Phase 9: Performance Tests

#### Test 9.1: Load Time
- [ ] PIN screen loads quickly
- [ ] Catalog screen loads products in < 2s
- [ ] History screen loads orders quickly

#### Test 9.2: Real-time Updates
- [ ] Order status updates appear without refresh
- [ ] New orders appear automatically
- [ ] Updates are smooth (no UI freezing)

#### Test 9.3: Memory Usage
- [ ] Extended use doesn't cause memory leaks
- [ ] App remains responsive after many orders
- [ ] Images are properly cached

## Test Results Template

### Test Session: [Date]
**Tester:** [Name]
**Device:** [Tablet Model]
**Screen Size:** [10" / 11"]
**OS Version:** [iOS/Android version]

#### Results Summary
- Total Tests: [X]
- Passed: [X]
- Failed: [X]
- Blocked: [X]

#### Failed Tests
1. [Test ID]: [Description]
   - Expected: [Expected behavior]
   - Actual: [Actual behavior]
   - Priority: [High/Medium/Low]

#### Notes
[Any additional observations or comments]

## Known Limitations (V1)

1. No TPE integration - payment method is manual only
2. No custom pizza builder - standard products only
3. No loyalty points - staff orders don't earn points
4. No multi-staff PIN - single PIN for all staff
5. No ticket printing - digital only
6. History limited to today - no date range selector

## Future Enhancements (V2)

See STAFF_TABLET_MODULE.md for planned features.
