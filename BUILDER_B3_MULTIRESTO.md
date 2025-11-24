# Builder B3 - Multi-Resto & Role-Based Access Control

Complete guide for the multi-restaurant system with role-based access control in Builder B3.

## Table of Contents
- [Overview](#overview)
- [Roles](#roles)
- [Architecture](#architecture)
- [Setup](#setup)
- [Usage](#usage)
- [Firestore Structure](#firestore-structure)
- [Security](#security)

## Overview

Builder B3 now supports multiple restaurants (multi-resto) with granular role-based access control. This allows:
- **Super admins** to manage multiple restaurants
- **Restaurant admins** to manage only their restaurant
- **Studio users** to have limited access to specific restaurants
- Automatic security checks to prevent unauthorized access

## Roles

### BuilderRole Definitions

```dart
class BuilderRole {
  static const String superAdmin = 'super_admin';  // Full access to all restaurants
  static const String adminResto = 'admin_resto';  // Access to specific restaurant
  static const String studio = 'studio';            // Limited access (optional)
  static const String admin = 'admin';              // Legacy admin (treated as admin_resto)
  static const String kitchen = 'kitchen';          // No Builder access
  static const String client = 'client';            // No Builder access
}
```

### Role Capabilities

| Role | Builder Access | Can Switch Apps | Can Edit Pages | Can Publish |
|------|---------------|-----------------|----------------|-------------|
| super_admin | ✅ All restaurants | ✅ Yes | ✅ Yes | ✅ Yes |
| admin_resto | ✅ Assigned restaurant | ❌ No | ✅ Yes | ✅ Yes |
| studio | ✅ Assigned restaurant | ❌ No | ✅ Limited | ❌ No |
| admin (legacy) | ✅ pizza_delizza | ❌ No | ✅ Yes | ✅ Yes |
| kitchen | ❌ No | ❌ No | ❌ No | ❌ No |
| client | ❌ No | ❌ No | ❌ No | ❌ No |

## Architecture

### AppContext System

The multi-resto system is built around `AppContext`:

```dart
// Core state
class AppContextState {
  final String currentAppId;           // Currently active restaurant
  final List<AppInfo> accessibleApps;  // Restaurants user can access
  final String userRole;               // User's role
  final String? userId;                // Firebase Auth UID
  final bool hasBuilderAccess;         // Can access Builder B3
}

// Helper getters
bool get isSuperAdmin;      // Is super admin
bool get isAdminResto;      // Is restaurant admin
bool get isStudio;          // Is studio user
bool get canSwitchApps;     // Can switch between restaurants
```

### Providers

```dart
// Main app context provider
final appContextProvider = StateNotifierProvider<AppContextNotifier, AppContextState>(...);

// Helper providers
final currentAppIdProvider = Provider<String>(...);          // Get current appId
final hasBuilderAccessProvider = Provider<bool>(...);        // Check Builder access
```

### Restaurant Info

```dart
class AppInfo {
  final String appId;          // Unique identifier (e.g., 'pizza_delizza')
  final String name;           // Display name (e.g., 'Pizza Delizza')
  final String description;    // Description
  final bool isActive;         // Is restaurant active
}
```

## Setup

### 1. User Profile in Firestore

Store user role and assigned restaurant in Firestore:

```javascript
// Firestore: users/{userId}
{
  "email": "admin@restaurant.com",
  "displayName": "Restaurant Admin",
  "role": "admin_resto",           // or "super_admin", "studio"
  "appId": "pizza_delizza",        // Required for admin_resto and studio
  "createdAt": "2024-01-15T10:00:00Z",
  "isActive": true
}
```

### 2. Restaurant Configuration

Create restaurant entries in Firestore (for super admin):

```javascript
// Firestore: apps/pizza_delizza
{
  "name": "Pizza Delizza",
  "description": "Restaurant principal - Paris",
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z"
}

// Firestore: apps/pizza_roma
{
  "name": "Pizza Roma",
  "description": "Deuxième restaurant - Lyon",
  "isActive": true,
  "createdAt": "2024-02-01T00:00:00Z"
}
```

### 3. Initialize AppContext

The context loads automatically when BuilderStudioScreen opens:

```dart
// In your app
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BuilderStudioScreen(),
  ),
);

// AppContext loads automatically:
// 1. Gets current Firebase Auth user
// 2. Loads user profile from Firestore
// 3. Determines role and accessible apps
// 4. Sets default appId
```

## Usage

### For Super Admin

1. **Access Builder Studio:**
   - Login with super_admin account
   - Navigate to Admin Menu → "🎨 Builder B3"

2. **Switch Restaurants:**
   - See dropdown at top of BuilderStudioScreen
   - Select restaurant from accessible list
   - All edits apply to selected restaurant

3. **Edit Pages:**
   - Click "Éditer" on any page
   - Opens BuilderPageEditorScreen with selected restaurant
   - Save and publish changes

### For Restaurant Admin

1. **Access Builder Studio:**
   - Login with admin_resto account
   - Navigate to Admin Menu → "🎨 Builder B3"

2. **Edit Pages:**
   - See only your assigned restaurant
   - Cannot switch to other restaurants
   - Edit any page for your restaurant
   - Save and publish changes

### For Studio User (Optional)

1. **Access Builder Studio:**
   - Login with studio account
   - Navigate to Admin Menu → "🎨 Builder B3"

2. **Limited Editing:**
   - See only assigned restaurant
   - Can edit pages (same as admin_resto)
   - May have publish restrictions (if implemented)

### Access Control in Code

```dart
// Check if user has Builder access
final hasAccess = ref.watch(hasBuilderAccessProvider);
if (!hasAccess) {
  // Show error or redirect
}

// Get current appId
final appId = ref.watch(currentAppIdProvider);

// Use in BuilderLayoutService
await BuilderLayoutService().saveDraft(page);  // Uses context appId

// Manual appId verification
final context = ref.watch(appContextProvider);
if (!service.canAccessApp(context, 'other_restaurant')) {
  // Access denied
}
```

## Firestore Structure

### User Profiles
```
users/
  └── {userId}/
      ├── email: string
      ├── displayName: string
      ├── role: string              // "super_admin" | "admin_resto" | "studio" | "admin" | "kitchen" | "client"
      ├── appId: string?            // Required for admin_resto and studio
      ├── createdAt: timestamp
      └── isActive: boolean
```

### Restaurants
```
apps/
  ├── pizza_delizza/
  │   ├── name: "Pizza Delizza"
  │   ├── description: "Restaurant principal"
  │   ├── isActive: true
  │   └── createdAt: timestamp
  └── pizza_roma/
      ├── name: "Pizza Roma"
      ├── description: "Second restaurant"
      ├── isActive: true
      └── createdAt: timestamp
```

### Builder Layouts (Per Restaurant)
```
apps/
  └── {appId}/
      └── builder/
          └── pages/
              ├── home/
              │   ├── draft
              │   └── published
              ├── menu/
              │   ├── draft
              │   └── published
              └── ...
```

## Security

### Firestore Rules

Add these rules to secure multi-resto access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    
    function isSuperAdmin() {
      return isAuthenticated() && getUserData().role == 'super_admin';
    }
    
    function isAdminForApp(appId) {
      return isAuthenticated() && (
        isSuperAdmin() ||
        (getUserData().role in ['admin_resto', 'studio', 'admin'] && getUserData().appId == appId)
      );
    }
    
    // Apps collection (restaurant metadata)
    match /apps/{appId} {
      // Anyone can read active restaurants
      allow read: if isAuthenticated() && resource.data.isActive == true;
      
      // Only super admin can create/update/delete restaurants
      allow create, update, delete: if isSuperAdmin();
    }
    
    // Builder pages (per restaurant)
    match /apps/{appId}/builder/pages/{pageId}/{document=**} {
      // Read: Any authenticated user (for published pages)
      allow read: if isAuthenticated();
      
      // Write: Only admins of this restaurant
      allow write: if isAdminForApp(appId);
    }
    
    // User profiles
    match /users/{userId} {
      // Users can read their own profile
      allow read: if isAuthenticated() && request.auth.uid == userId;
      
      // Only super admin can create/update user profiles
      allow create, update: if isSuperAdmin();
      
      // Users cannot delete profiles
      allow delete: if false;
    }
  }
}
```

### Code-Level Security

1. **Access Checks:**
   ```dart
   // Always use app context for appId
   final appId = ref.watch(currentAppIdProvider);
   
   // Verify access before operations
   final context = ref.watch(appContextProvider);
   if (!service.canAccessApp(context, targetAppId)) {
     throw SecurityException('Access denied');
   }
   ```

2. **UI Guards:**
   ```dart
   // Hide Builder menu for non-authorized users
   if (ref.watch(hasBuilderAccessProvider)) {
     // Show Builder B3 button
   }
   ```

3. **Route Protection:**
   ```dart
   // In GoRouter or Navigator guards
   if (!hasBuilderAccess) {
     return '/access-denied';
   }
   ```

## Testing

### Test Accounts

Create test accounts for each role:

```javascript
// Super Admin
{
  "email": "superadmin@test.com",
  "password": "test123",
  "role": "super_admin"
}

// Restaurant Admin (Pizza Delizza)
{
  "email": "admin.delizza@test.com",
  "password": "test123",
  "role": "admin_resto",
  "appId": "pizza_delizza"
}

// Restaurant Admin (Pizza Roma)
{
  "email": "admin.roma@test.com",
  "password": "test123",
  "role": "admin_resto",
  "appId": "pizza_roma"
}

// Studio User
{
  "email": "studio@test.com",
  "password": "test123",
  "role": "studio",
  "appId": "pizza_delizza"
}
```

### Test Scenarios

1. **Super Admin:**
   - ✅ Can see app switcher
   - ✅ Can switch between restaurants
   - ✅ Can edit all pages for all restaurants
   - ✅ Can publish all pages

2. **Restaurant Admin:**
   - ❌ Cannot see app switcher
   - ✅ Can only see their restaurant
   - ✅ Can edit all pages for their restaurant
   - ✅ Can publish pages
   - ❌ Cannot access other restaurants

3. **Studio User:**
   - ❌ Cannot see app switcher
   - ✅ Can only see their restaurant
   - ✅ Can edit pages
   - Implementation-dependent publish access

4. **Kitchen/Client:**
   - ❌ Cannot access Builder B3
   - See "Access denied" message

## Migration

### From Single-Resto to Multi-Resto

1. **Existing users:**
   - Admins: Add role "admin" (auto-mapped to pizza_delizza)
   - Kitchen: Add role "kitchen" (no Builder access)
   - Clients: Add role "client" (no Builder access)

2. **Existing data:**
   - No migration needed
   - All existing layouts remain at `apps/pizza_delizza/builder/pages/`

3. **Add new restaurants:**
   - Create entry in `apps/{newAppId}`
   - Create admin users with appId assignment
   - Start building layouts for new restaurant

## Troubleshooting

### Access Denied

**Problem:** User sees "Access denied" in Builder B3

**Solutions:**
1. Check user role in Firestore `users/{userId}`
2. Verify role is one of: super_admin, admin_resto, studio, admin
3. For admin_resto/studio: verify `appId` field exists
4. Check Firestore security rules

### Cannot Switch Apps

**Problem:** Super admin cannot see app switcher

**Solutions:**
1. Verify role is exactly "super_admin" (not "super admin")
2. Check multiple apps exist in `apps/` collection
3. Verify apps have `isActive: true`
4. Refresh app context: Click refresh button

### Wrong Restaurant Showing

**Problem:** Admin sees wrong restaurant

**Solutions:**
1. Check `appId` in user profile matches restaurant ID
2. Verify restaurant exists in `apps/{appId}`
3. Clear app cache and reload
4. Check Firestore console for correct data

## Best Practices

1. **Role Assignment:**
   - Use super_admin sparingly (only for owners)
   - Assign admin_resto to restaurant managers
   - Use studio for content editors (if needed)

2. **Restaurant IDs:**
   - Use clear, consistent naming (e.g., pizza_delizza, pizza_roma)
   - Avoid special characters
   - Keep it short and memorable

3. **Security:**
   - Always use AppContext providers for appId
   - Never hardcode appId in Builder operations
   - Verify access before sensitive operations
   - Keep Firestore rules updated

4. **User Management:**
   - Create users through admin interface (future feature)
   - Document role assignments
   - Review access regularly

## Future Enhancements

- [ ] Admin interface for user management
- [ ] Bulk app operations (publish all pages)
- [ ] App cloning/templating
- [ ] Granular page-level permissions
- [ ] Audit logs for Builder changes
- [ ] App-level settings and configuration

---

**Result**: Complete multi-resto system with role-based access control, secure by default, ready for production use.
