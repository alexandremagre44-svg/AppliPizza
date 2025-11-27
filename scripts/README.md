# Scripts Utility

This directory contains utility scripts for managing the AppliPizza application.

## normalize_builder_firestore.mjs

Script to normalize Builder B3 Firestore data for the `delizza` restaurant.

### What it does

1. **pages_system** (navigation config):
   - If `name` absent and `title` present: copy `title` → `name`
   - If `route` absent/empty/`'/'`: set correct route
     - System pages: `/home`, `/menu`, `/cart`, `/profile`, `/rewards`, `/roulette`
     - Custom pages: `/page/<docId>`
   - If `bottomNavIndex` absent: use `order` if 0-4, else `null`
   - Ensures `pageId` and `pageKey` are set

2. **pages_published / pages_draft** (page content):
   - Ensures `draftLayout` and `publishedLayout` are arrays (not null/string)
   - Ensures each block has an `id` field (generates if missing)
   - Ensures `pageId` and `pageKey` are set
   - Ensures custom pages use `/page/<pageKey>` route format

### Prerequisites

1. Install Firebase Admin SDK:
   ```bash
   npm install firebase-admin
   ```

2. Download service account key:
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save the JSON file as `firebase/service-account-key.json`

   OR set environment variable:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="./path/to/serviceAccountKey.json"
   ```

### Usage

**Preview changes (dry-run, default):**
```bash
node scripts/normalize_builder_firestore.mjs
# or explicitly:
node scripts/normalize_builder_firestore.mjs --dry-run
```

**Apply changes to Firestore:**
```bash
node scripts/normalize_builder_firestore.mjs --apply
```

### Example Output

```
═══════════════════════════════════════════════════════════════
  BUILDER B3 FIRESTORE NORMALIZATION SCRIPT
═══════════════════════════════════════════════════════════════
  Restaurant ID: delizza
  Mode: 🔍 DRY RUN (preview only)
═══════════════════════════════════════════════════════════════

📂 Processing pages_system...

🔧 pages_system/home:
  ✅ Already normalized

🔧 pages_system/promo_noel:
  📝 promo_noel.route: "/" → "/page/promo_noel"
  📝 promo_noel.pageKey: undefined → "promo_noel"
  🔍 Would update (dry-run)
```

---

## set_admin_claim.js

Script to set Firebase Auth custom claims for admin users.

### Prerequisites

1. Install Firebase Admin SDK:
   ```bash
   npm install firebase-admin
   ```

2. Download service account key:
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save the JSON file to your project root (e.g., `serviceAccountKey.json`)

3. Set environment variable:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="./serviceAccountKey.json"
   ```

### Usage

**Set admin claim for a user:**
```bash
node scripts/set_admin_claim.js <USER_UID>
```

Example:
```bash
node scripts/set_admin_claim.js dbmnp2DdyJaURWJO4YEE5fgv3002
```

**List all admin users:**
```bash
node scripts/set_admin_claim.js list
```

**Remove admin claim from a user:**
```bash
node scripts/set_admin_claim.js remove <USER_UID>
```

### Important Notes

- Users must logout and login again after claims are set
- Or force token refresh in the app
- Custom claims are required for Builder B3 access
- Without admin claim, users will get permission-denied errors

### Security

⚠️ **IMPORTANT:** Never commit the service account key file to version control!

Add to `.gitignore`:
```
serviceAccountKey.json
*-firebase-adminsdk-*.json
```
