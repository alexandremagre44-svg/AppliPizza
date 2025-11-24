# Scripts Utility

This directory contains utility scripts for managing the AppliPizza application.

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
