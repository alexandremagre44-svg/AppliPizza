# Firestore Migration Guide

## Overview

This document describes the Firestore migration system implemented to fix critical database inconsistencies identified during the audit.

## Problems Fixed

### 1. Missing `plan/unified` Documents (CRITICAL)

**Problem:** The document `restaurants/{restaurantId}/plan/unified` doesn't exist for existing restaurants (notably `delizza`).

**Impact:**
- `restaurantPlanUnifiedProvider` returns `null`
- All WL modules are considered disabled
- Builder displays all modules instead of filtering

**Solution:** Migration 1 creates the `plan/unified` document for each existing restaurant with:
- Intelligent module detection based on existing data
- Default branding configuration
- Proper timestamps

### 2. Inconsistent Restaurant Structure

**Problem:** Restaurants use different fields:
- `delizza`: `{ "id": "delizza", "status": "active" }`
- Others: `{ "restaurantId": "resto-xxx", "status": "ACTIVE" }`

**Solution:** Migration 2 normalizes:
- Ensures `id` field exists (= doc.id) in all documents
- Normalizes `status` to uppercase (`ACTIVE`, `INACTIVE`, `PENDING`)

### 3. Misplaced `roulette_settings`

**Problem:** Roulette settings are in `marketing/roulette_settings` instead of:
- At root `roulette_settings/main`
- In `restaurants/{id}/plan/unified.roulette`

**Solution:** Migration 3:
- Copies settings to `plan/unified` of each restaurant
- Keeps old location for backward compatibility (no deletion)

### 4. Inconsistent User Fields

**Problem:** Some users have `name`, others `displayName`.

**Solution:** Migration 4:
- Adds missing field (if `name` exists → copy to `displayName`, and vice versa)
- Ensures `isAdmin` exists for admin users
- Doesn't delete existing data for backward compatibility

## Implementation

### Files Created

1. **`lib/migration/migration_report.dart`**
   - Model for migration report
   - Tracks statistics and errors
   - Supports dry-run mode

2. **`lib/migration/firestore_migration_service.dart`**
   - Core migration service
   - Implements all 4 migrations
   - Idempotent and non-destructive

3. **`lib/superadmin/pages/migration_page.dart`**
   - SuperAdmin UI for running migrations
   - Real-time logs and reports
   - Dry-run toggle

4. **Route Integration**
   - Added `/superadmin/migration` route
   - Added navigation link in sidebar

## Usage

### From SuperAdmin UI

1. Navigate to `/superadmin/migration`
2. Toggle "Dry-Run" mode for simulation (recommended first)
3. Click "Lancer la migration"
4. Review the detailed report
5. If satisfied with dry-run, run in LIVE mode

### Programmatically

```dart
import 'package:pizza_delizza/migration/firestore_migration_service.dart';

final service = FirestoreMigrationService();

// Run in dry-run mode (simulation)
final dryRunReport = await service.runAllMigrations(dryRun: true);
print(dryRunReport.summary);

// Run in live mode
if (dryRunReport.isSuccess) {
  final liveReport = await service.runAllMigrations(dryRun: false);
  print(liveReport.summary);
}
```

## Migration Details

### Migration 1: Create plan/unified

For each restaurant in `restaurants/`:

```dart
// Check if plan/unified already exists
final unifiedDoc = await db.collection('restaurants')
    .doc(restaurantId)
    .collection('plan')
    .doc('unified')
    .get();

if (!unifiedDoc.exists) {
  // Create with default values
  final unifiedPlan = RestaurantPlanUnified(
    restaurantId: restaurantId,
    name: restaurantData['name'] ?? restaurantId,
    slug: restaurantData['slug'] ?? restaurantId,
    templateId: restaurantData['templateId'],
    activeModules: _detectActiveModules(restaurantId),
    branding: BrandingConfig(
      brandName: restaurantData['name'],
      primaryColor: '#D32F2F',
    ),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  
  await unifiedDocRef.set(unifiedPlan.toJson());
}
```

**Intelligent Module Detection:**

```dart
List<String> _detectActiveModules(String restaurantId) {
  final modules = <String>['ordering', 'promotions', 'click_and_collect'];
  
  // If roulette_settings exists → enable roulette
  if (await _hasRouletteSettings()) {
    modules.add('roulette');
  }
  
  // If loyalty_settings exists → enable loyalty
  if (await _hasLoyaltySettings()) {
    modules.add('loyalty');
  }
  
  return modules;
}
```

### Migration 2: Normalize Restaurants

```dart
// For each restaurant
final updates = <String, dynamic>{};

// Normalize status
final currentStatus = data['status'] as String?;
if (currentStatus != null && currentStatus != currentStatus.toUpperCase()) {
  updates['status'] = currentStatus.toUpperCase();
}

// Ensure 'id' exists (= doc.id)
if (data['id'] == null) {
  updates['id'] = docId;
}

// Apply if changes needed
if (updates.isNotEmpty) {
  await docRef.update(updates);
}
```

### Migration 3: Copy roulette_settings

```dart
// Read from marketing/roulette_settings
final marketingSettings = await db.collection('marketing')
    .doc('roulette_settings')
    .get();

if (marketingSettings.exists) {
  final settings = marketingSettings.data()!;
  
  // For each restaurant, update plan/unified.roulette
  for (final restaurant in restaurants) {
    final unifiedRef = db.collection('restaurants')
        .doc(restaurant.id)
        .collection('plan')
        .doc('unified');
    
    await unifiedRef.update({
      'roulette': {
        'enabled': settings['isEnabled'] ?? true,
        'cooldownHours': settings['cooldownHours'] ?? 24,
        'limitType': settings['limitType'] ?? 'per_day',
        'limitValue': settings['limitValue'] ?? 1,
        'settings': settings,
      },
    });
  }
}
```

### Migration 4: Normalize Users

```dart
for (final userDoc in users) {
  final data = userDoc.data()!;
  final updates = <String, dynamic>{};
  
  // Normalize name/displayName
  if (data['name'] != null && data['displayName'] == null) {
    updates['displayName'] = data['name'];
  } else if (data['displayName'] != null && data['name'] == null) {
    updates['name'] = data['displayName'];
  }
  
  // Ensure isAdmin exists for admins
  if (data['role'] == 'admin' && data['isAdmin'] == null) {
    updates['isAdmin'] = true;
  }
  
  if (updates.isNotEmpty) {
    await userDoc.reference.update(updates);
  }
}
```

## Important Constraints

1. **NEVER delete data** - Only add/modify
2. **Idempotent** - Can be run multiple times without issues
3. **Dry-run** - Simulation mode available
4. **Logged** - Every action is tracked
5. **Backward compatible** - Old code continues to work

## Expected Result After Migration

```
restaurants/
  delizza/
    - id: "delizza"
    - name: "Pizza DeliZza"
    - slug: "delizza"
    - status: "ACTIVE"
    - templateId: "pizzeria-classic"
    - createdAt: ...
    - updatedAt: ...
    
    plan/
      unified/
        - restaurantId: "delizza"
        - name: "Pizza DeliZza"
        - slug: "delizza"
        - templateId: "pizzeria-classic"
        - activeModules: ["ordering", "loyalty", "roulette", "promotions"]
        - branding: { brandName: "Pizza DeliZza", primaryColor: "#D32F2F" }
        - roulette: { enabled: true, cooldownHours: 24, ... }
        - loyalty: { enabled: true, pointsPerEuro: 1 }
        - createdAt: ...
        - updatedAt: ...

users/
  {userId}/
    - name: "..."
    - displayName: "..."  // Copied from name if missing
    - email: "..."
    - role: "..."
    - isAdmin: true/false  // Added if role=admin and missing
```

## Validation Tests

After running the migration, verify:

1. ✅ `restaurantPlanUnifiedProvider` no longer returns `null` for `delizza`
2. ✅ Builder displays only enabled modules
3. ✅ Old collections remain readable
4. ✅ No console errors

## Troubleshooting

### Migration fails with permission errors

**Solution:** Ensure Firestore rules allow SuperAdmin to write to:
- `restaurants/{restaurantId}/plan/unified`
- `restaurants/{restaurantId}` (for field updates)
- `users/{userId}` (for field updates)

### Dry-run shows unexpected module detection

**Solution:** This is normal. The intelligent detection checks for existing data:
- Roulette module: checks `marketing/roulette_settings`
- Loyalty module: checks `restaurants/{id}/loyalty` collection

### Migration runs slowly

**Solution:** The migration processes all restaurants and users. For large databases:
- Use Firebase batched writes (already implemented)
- Run during off-peak hours
- Monitor Firestore quotas

## Testing

Run the test suite:

```bash
flutter test test/migration_service_test.dart
```

Tests cover:
- Migration report tracking
- Error handling
- Dry-run mode
- Normalization logic
- Module detection
- Idempotency

## Rollback Strategy

If migration causes issues:

1. The migration is **non-destructive** - it only adds data
2. Old code paths remain functional
3. If needed, manually delete created `plan/unified` documents
4. Status and user fields can be manually reverted

**Note:** It's recommended to always run in dry-run mode first and backup the database before running in live mode.
