# Studio Preview Testing Guide

## Overview
This document provides comprehensive test scenarios for the new Studio Admin Preview system. The preview provides a 1:1 representation of the actual HomeScreen with full simulation capabilities.

## Test Environment Setup
1. Navigate to Studio Admin
2. Open any module (Layout, Banners, Popups, Theme)
3. The preview should be visible on the right side with simulation controls on the left

## Test Scenarios

### 1. Theme Change → Preview Change
**Objective**: Verify that theme changes in draft mode immediately reflect in the preview

**Steps**:
1. Open Theme Manager in Studio Admin
2. Change primary color in draft mode
3. Observe preview updates instantly
4. Change from light to dark theme
5. Verify preview switches theme mode

**Expected Result**: Preview reflects all theme changes without page reload

---

### 2. Hour Change → Sections Change
**Objective**: Verify time-based section visibility rules work in preview

**Steps**:
1. Configure a section to show only between 11h-14h
2. Set simulation hour to 12h
3. Verify section appears in preview
4. Set simulation hour to 16h
5. Verify section disappears from preview

**Expected Result**: Sections appear/disappear based on time rules

---

### 3. User Type Change → Popups Change
**Objective**: Verify popup targeting works correctly

**Steps**:
1. Create a popup targeting only "new customers"
2. Set user type to "Nouveau Client" in simulation
3. Verify popup should trigger in preview
4. Switch to "Client VIP" user type
5. Verify popup no longer triggers

**Expected Result**: Popups follow targeting rules based on user type

---

### 4. Cart Change → Sections Change
**Objective**: Verify cart-based conditional sections

**Steps**:
1. Configure a section to show only when cart has items
2. Set cart to 0 items in simulation
3. Verify section is hidden
4. Set cart to 2 items
5. Verify section appears

**Expected Result**: Sections respond to cart state changes

---

### 5. Draft Modified → Preview Updates Instantly
**Objective**: Verify real-time draft preview updates

**Steps**:
1. Open Layout Manager
2. Drag and reorder Hero and Banner sections
3. Observe preview instantly reflects new order
4. Toggle section visibility
5. Verify preview updates immediately

**Expected Result**: All draft changes appear in preview without save

---

### 6. Section Disabled → Preview Hides It
**Objective**: Verify disabled sections don't appear

**Steps**:
1. Enable all sections in layout
2. Verify all appear in preview
3. Disable Hero section
4. Verify Hero disappears from preview
5. Re-enable Hero
6. Verify Hero reappears

**Expected Result**: Section visibility toggles work instantly

---

### 7. Section Moved → Preview Reorders
**Objective**: Verify section order changes

**Steps**:
1. Set order: Hero → Banner → Popups
2. Verify this order in preview
3. Change to: Banner → Hero → Popups
4. Verify preview reflects new order

**Expected Result**: Preview matches exact section order

---

### 8. Popup Activated → Appears in Preview
**Objective**: Verify popup display in preview

**Steps**:
1. Create new popup with delay trigger (2s)
2. Enable the popup
3. Wait 2 seconds after preview loads
4. Verify popup appears with correct style
5. Test all 5 popup types (text, image, coupon, emoji, bigPromo)

**Expected Result**: Popups display with correct timing and styling

---

### 9. Multiple Banners → Loop Correctly
**Objective**: Verify banner carousel works

**Steps**:
1. Create 3 active banners with different text/colors
2. Verify all 3 appear in preview
3. Observe banner rotation/display
4. Disable one banner
5. Verify only 2 banners show

**Expected Result**: Banner system displays all active banners correctly

---

### 10. Day Change → Schedule-Based Sections
**Objective**: Verify day-of-week section rules

**Steps**:
1. Create section visible only on Monday
2. Set simulation day to Monday
3. Verify section appears
4. Change to Tuesday
5. Verify section disappears

**Expected Result**: Day-based visibility rules work correctly

---

### 11. New Customer → Welcome Popup
**Objective**: Verify first-visit popup logic

**Steps**:
1. Create popup with "firstVisit" trigger
2. Set user type to "Nouveau Client"
3. Verify popup appears
4. Set user type to "Client Habituel"
5. Verify popup doesn't appear

**Expected Result**: First-visit popups only show for new users

---

### 12. VIP User → Loyalty Section Visible
**Objective**: Verify user-segmented content

**Steps**:
1. Create VIP-only section
2. Set user to "Nouveau Client"
3. Verify section hidden
4. Set user to "Client VIP"
5. Verify section appears

**Expected Result**: User segmentation works correctly

---

### 13. Cart Combo → Special Offer Banner
**Objective**: Verify combo-specific content

**Steps**:
1. Create banner for combo orders
2. Enable "Combo/Menu" in cart simulation
3. Verify banner appears
4. Disable combo
5. Verify banner disappears

**Expected Result**: Combo-conditional content displays correctly

---

### 14. Order History → Loyalty Promotion
**Objective**: Verify content based on order count

**Steps**:
1. Create section for users with 5+ orders
2. Set previous orders to 3
3. Verify section hidden
4. Set previous orders to 6
5. Verify section appears

**Expected Result**: Order history rules work correctly

---

### 15. Multiple Conditions → AND Logic
**Objective**: Verify multiple condition handling

**Steps**:
1. Create section requiring: VIP + Cart > 0 + Monday
2. Set user to VIP, cart to 0, day to Monday
3. Verify section hidden (cart condition fails)
4. Set cart to 1
5. Verify section appears (all conditions met)

**Expected Result**: Multiple conditions use AND logic correctly

---

### 16. Theme Dark → All Colors Adjust
**Objective**: Verify dark theme propagation

**Steps**:
1. Set theme to Dark in simulation
2. Verify all preview elements use dark theme
3. Check text readability
4. Verify button colors invert properly
5. Check banner contrast

**Expected Result**: Complete dark theme support

---

### 17. Responsive Preview → Different Screen Sizes
**Objective**: Verify preview adapts to viewport

**Steps**:
1. Resize browser window to narrow width
2. Verify preview uses 16:9 ratio
3. Resize to wide width
4. Verify preview uses 19.5:9 ratio
5. Check all content remains visible

**Expected Result**: Preview adapts responsively

---

### 18. Banner Scheduling → Date Range
**Objective**: Verify banner date-based visibility

**Steps**:
1. Create banner with start/end dates
2. Simulate date within range
3. Verify banner visible
4. Simulate date outside range
5. Verify banner hidden

**Expected Result**: Date-based banner scheduling works

---

### 19. Popup Priority → Correct Order
**Objective**: Verify popup priority system

**Steps**:
1. Create 3 popups with priorities: 1, 5, 10
2. All enabled with same trigger
3. Verify highest priority (10) shows first
4. Dismiss and verify priority 5 next
5. Dismiss and verify priority 1 last

**Expected Result**: Popups follow priority order

---

### 20. Full Integration Test → Complex Scenario
**Objective**: Verify complete system integration

**Steps**:
1. Set user to VIP
2. Set time to 12h Monday
3. Set cart to 2 items
4. Set 10 previous orders
5. Enable 3 banners, 2 popups, custom layout
6. Verify all elements display correctly
7. Change each parameter individually
8. Verify preview updates smoothly

**Expected Result**: All features work together seamlessly

---

## Success Criteria

✅ All 20 tests pass without errors  
✅ Preview updates instantly on all changes  
✅ No console errors during testing  
✅ Performance remains smooth (< 100ms update time)  
✅ Preview matches real app 100%  

## Reporting Issues

If any test fails:
1. Note the exact steps to reproduce
2. Capture screenshot of preview state
3. Check browser console for errors
4. Document expected vs actual behavior
5. Report in GitHub issues with "preview" tag

## Additional Notes

- Preview uses real HomeScreen component (not a mock)
- All providers are overridden in preview scope
- Simulation state is local (doesn't affect live app)
- Draft changes are not saved until explicit publish
- Preview is fully isolated from production data
