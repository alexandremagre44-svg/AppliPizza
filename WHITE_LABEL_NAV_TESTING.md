# White-Label Navigation Testing Guide

## Testing Checklist

### 1. Unit Tests (Automated)

The existing test suite already covers the NavbarModuleAdapter functionality:
- ✅ `test/navbar_module_adapter_test.dart` - Tests module filtering logic

### 2. Integration Tests (Manual)

#### Test Scenario 1: Restaurant with All Modules Active

**Setup in Firestore:**
```javascript
restaurants/{restaurantId}/plan
{
  "restaurantId": "test-resto-1",
  "name": "Test Restaurant 1",
  "activeModules": ["ordering", "delivery", "loyalty", "roulette"]
}
```

**Expected Result:**
- Navigation bar shows: Menu, Rewards, Roulette, Cart, Profile
- Console logs: `[WL NAV] Modules actifs: ["ordering", "delivery", "loyalty", "roulette"]`
- All pages are accessible

#### Test Scenario 2: Restaurant with Selective Modules

**Setup in Firestore:**
```javascript
restaurants/{restaurantId}/plan
{
  "restaurantId": "test-resto-2",
  "name": "Test Restaurant 2",
  "activeModules": ["ordering", "delivery", "loyalty"]
}
```

**Expected Result:**
- Navigation bar shows: Menu, Rewards, Cart, Profile (no Roulette)
- Console logs: `[WL NAV] Modules actifs: ["ordering", "delivery", "loyalty"]`
- Console logs: `[WL NAV] ✗ Page roulette excluded - module roulette is disabled`
- Attempting to navigate to `/roulette` should redirect or show error

#### Test Scenario 3: Restaurant with No Optional Modules

**Setup in Firestore:**
```javascript
restaurants/{restaurantId}/plan
{
  "restaurantId": "test-resto-3",
  "name": "Test Restaurant 3",
  "activeModules": ["ordering"] // Only core module
}
```

**Expected Result:**
- Navigation bar shows: Menu, Cart, Profile (minimum set)
- System pages always visible regardless of modules
- Console logs: `[WL NAV] Modules actifs: ["ordering"]`

#### Test Scenario 4: Legacy Restaurant (No Unified Plan)

**Setup in Firestore:**
```javascript
restaurants/{restaurantId}/
// NO 'plan' document
```

**Expected Result:**
- Falls back to feature flags system
- Console logs: `[WL NAV] No plan loaded - returning all pages`
- Console logs: `[WL NAV] Legacy filter: ...`
- All pages show by default (backward compatibility)

#### Test Scenario 5: Admin User

**Setup:**
- User with `isAdmin: true`
- Any restaurant plan

**Expected Result:**
- Admin tab appears at the end of navigation bar
- Console logs: `[WL NAV] Added admin tab`
- Admin tab always visible regardless of modules

### 3. Edge Cases

#### Edge Case 1: Empty Active Modules List

**Setup:**
```javascript
{
  "activeModules": []
}
```

**Expected Result:**
- Shows only system pages (Menu, Cart, Profile)
- Minimum 2 items check prevents crash
- Falls back to safe navigation

#### Edge Case 2: Invalid Module IDs

**Setup:**
```javascript
{
  "activeModules": ["ordering", "invalid_module", "loyalty"]
}
```

**Expected Result:**
- Valid modules work normally
- Invalid modules are ignored
- No crashes or errors

#### Edge Case 3: Module Route Mismatch

**Test:** Builder B3 defines a page for `/rewards` but loyalty module is disabled

**Expected Result:**
- Page is filtered out by `buildPagesFromPlan()`
- Tab does not appear in navigation
- Route is inaccessible

### 4. Performance Tests

#### Test: Navigation Build Performance

**Metrics to check:**
- Time to build navigation with 10 pages
- Time to filter with multiple modules
- Memory usage with large plans

**Expected:**
- Build time < 16ms (one frame)
- No memory leaks
- Efficient filtering

### 5. Regression Tests

#### Test: Existing Functionality Preserved

**Checklist:**
- [ ] Cart badge shows item count
- [ ] Navigation highlights current page
- [ ] Tapping tabs navigates correctly
- [ ] Admin tab shows for admins only
- [ ] Custom Builder B3 pages work
- [ ] System pages always accessible
- [ ] Icons display correctly (outlined/filled)
- [ ] Labels display correctly

### 6. Console Log Verification

#### Expected Logs (Debug Mode)

When app loads with plan:
```
[WL NAV] Modules actifs: ["ordering", "delivery", "loyalty", "roulette"]
📱 [BottomNav] Loaded 6 pages: ...
[WL NAV] No plan loaded - returning all pages
[WL NAV] ✓ Page menu included - no module requirement
[WL NAV] ✓ Page rewards included - module loyalty is enabled
[WL NAV] ✗ Page roulette excluded - module roulette is disabled
[WL NAV] Filtered pages: 6 → 5
[WL NAV] Building nav items for 5 pages
[WL NAV] Generated route for custom_page: /page/custom_page
[WL NAV] Added admin tab
[WL NAV] Built 6 navigation items
📱 [BottomNav] Module filtering: 6 → 5 items
[BottomNav] Rendered 5 items (after module filtering)
```

### 7. Visual Validation

#### Screenshots to Take

1. **All modules active** - Full navigation bar
2. **Selective modules** - Partial navigation bar
3. **Minimum modules** - Basic navigation bar
4. **Admin view** - Navigation with admin tab
5. **Legacy mode** - Fallback navigation

### 8. Database Validation

#### Firestore Queries to Run

```javascript
// Get restaurant plan
db.collection('restaurants').doc(restaurantId).collection('plan').doc('plan').get()

// Verify active modules
plan.data().activeModules

// Check if module is enabled
plan.data().activeModules.includes('roulette')
```

### 9. Code Review Checklist

- [x] New functions are documented
- [x] Backward compatibility maintained
- [x] No breaking changes to existing code
- [x] Error handling in place
- [x] Logging is informative
- [x] Code follows project conventions
- [x] No security vulnerabilities introduced
- [x] Performance is acceptable

### 10. Pre-Deployment Validation

Before deploying to production:

1. Run full test suite: `flutter test`
2. Run static analysis: `flutter analyze`
3. Check for breaking changes in API
4. Verify database migration is not needed
5. Test with real restaurant data
6. Verify rollback procedure
7. Monitor logs in staging environment
8. Performance profiling with Flutter DevTools

## Test Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/navbar_module_adapter_test.dart

# Run with coverage
flutter test --coverage

# Run in debug mode with logs
flutter run --debug
```

## Success Criteria

✅ All unit tests pass
✅ Manual scenarios work as expected
✅ No regressions in existing functionality
✅ Logs are clear and helpful
✅ Performance is acceptable
✅ No breaking changes
✅ Documentation is complete

## Known Limitations

1. **Module filtering is applied twice**: Once in `buildPagesFromPlan()` and once in `_applyModuleFiltering()`. This is intentional for safety but could be optimized in future.

2. **Route mapping is hardcoded**: The `_getRequiredModuleForRoute()` function has a switch statement. Consider using a registry pattern in future.

3. **No hot-reload for plan changes**: Changing the plan in Firestore requires app restart. Future: Add real-time plan updates.

## Troubleshooting

### Issue: Navigation shows all pages despite modules being disabled

**Solution:** Check if RestaurantPlanUnified is loading correctly. Enable debug logs and verify:
- `[WL NAV] Modules actifs: ...` appears in logs
- Plan is not null in `buildPagesFromPlan()`

### Issue: Console shows "Legacy filter" messages

**Solution:** This means unified plan is not loading. Check:
- Firestore document exists at `restaurants/{restaurantId}/plan`
- RestaurantPlanRuntimeService is configured correctly
- Provider is properly injected

### Issue: App crashes with "items.length >= 2" error

**Solution:** The minimum items check should prevent this. If it happens:
- Check if Builder B3 is returning valid pages
- Verify fallback navigation has at least 2 items
- Check console logs for filtering issues

## Next Steps

1. Run manual testing scenarios 1-5
2. Verify console logs match expected output
3. Take screenshots for documentation
4. Validate with different restaurant configurations
5. Deploy to staging for real-world testing
6. Monitor production after deployment
