# Firestore Migration Guide - Phase 1

## Overview

This document describes the Firestore data structure changes needed to support the Phase 1 module completion.

## RestaurantPlanUnified Structure Changes

The `RestaurantPlanUnified` model has been extended to support all ModuleId entries.

### New Fields Added

The following module configuration fields have been added to the restaurant plan document:

```
restaurants/{restaurantId}/plan
├── campaigns (Map)           # CampaignsModuleConfig
├── payments (Map)            # PaymentsModuleConfig
├── paymentTerminal (Map)     # PaymentTerminalModuleConfig
├── wallet (Map)              # WalletModuleConfig
├── reporting (Map)           # ReportingModuleConfig
├── exports (Map)             # ExportsModuleConfig
├── kitchenTablet (Map)       # KitchenTabletModuleConfig
├── staffTablet (Map)         # StaffTabletModuleConfig
└── timeRecorder (Map)        # TimeRecorderModuleConfig
```

### Module Config Structure

Each module config follows this structure:

```json
{
  "enabled": false,
  "settings": {}
}
```

### Example Restaurant Plan Document

```json
{
  "restaurantId": "resto123",
  "name": "Pizza Delizza",
  "slug": "pizza-delizza",
  "activeModules": ["ordering", "delivery", "loyalty"],
  
  // Existing modules
  "delivery": {
    "enabled": true,
    "settings": { ... }
  },
  "ordering": {
    "enabled": true,
    "settings": { ... }
  },
  "loyalty": {
    "enabled": true,
    "settings": { ... }
  },
  
  // New modules (Phase 1)
  "campaigns": {
    "enabled": false,
    "settings": {}
  },
  "payments": {
    "enabled": true,
    "settings": {
      "stripePublicKey": "pk_test_...",
      "currency": "EUR"
    }
  },
  "paymentTerminal": {
    "enabled": false,
    "settings": {}
  },
  "wallet": {
    "enabled": false,
    "settings": {}
  },
  "reporting": {
    "enabled": true,
    "settings": {}
  },
  "exports": {
    "enabled": false,
    "settings": {}
  },
  "kitchenTablet": {
    "enabled": false,
    "settings": {}
  },
  "staffTablet": {
    "enabled": false,
    "settings": {}
  },
  "timeRecorder": {
    "enabled": false,
    "settings": {}
  }
}
```

## Migration Steps

### 1. Backward Compatibility

The `fromJson` method handles missing fields gracefully:
- All new fields are optional
- Missing fields default to `null`
- Existing restaurants without these fields will continue to work

### 2. Updating Existing Documents

For existing restaurant documents, you have two options:

**Option A: No action required**
- The app will work without the new fields
- New fields will be added automatically when a restaurant plan is updated

**Option B: Batch update (recommended)**
- Add default values for new fields to all existing restaurant plans
- Use a Firestore migration script

**Note:** This script uses Firebase Admin SDK (Node.js) for server-side administration.
For Flutter/Dart implementation, use the Firestore Flutter plugin with similar logic.

```javascript
// Firebase Admin SDK migration script (Node.js)
const admin = require('firebase-admin');
const db = admin.firestore();

async function migrateRestaurantPlans() {
  const batch = db.batch();
  const restaurants = await db.collection('restaurants').get();
  
  restaurants.forEach(doc => {
    const planRef = doc.ref.collection('plan').doc('config');
    batch.update(planRef, {
      'campaigns': { enabled: false, settings: {} },
      'payments': { enabled: false, settings: {} },
      'paymentTerminal': { enabled: false, settings: {} },
      'wallet': { enabled: false, settings: {} },
      'reporting': { enabled: false, settings: {} },
      'exports': { enabled: false, settings: {} },
      'kitchenTablet': { enabled: false, settings: {} },
      'staffTablet': { enabled: false, settings: {} },
      'timeRecorder': { enabled: false, settings: {} },
    });
  });
  
  await batch.commit();
  console.log('Migration complete');
}
```

### 3. Firestore Security Rules

Ensure your security rules allow these new fields:

```javascript
match /restaurants/{restaurantId}/plan/{document} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && 
    request.auth.token.role == 'admin' || 
    request.auth.token.restaurantId == restaurantId;
}
```

## Testing Checklist

- [ ] Create new restaurant with all fields
- [ ] Update existing restaurant plan
- [ ] Verify backward compatibility with old documents
- [ ] Test module enable/disable in SuperAdmin
- [ ] Verify module filtering in Builder
- [ ] Test runtime module visibility

## Module Registry Alignment

All modules are registered in:
- `lib/white_label/core/module_id.dart` - Enum definitions
- `lib/white_label/core/module_registry.dart` - Module metadata
- `lib/white_label/restaurant/restaurant_plan_unified.dart` - Configuration model

These three files are now fully aligned with complete coverage of all modules.
