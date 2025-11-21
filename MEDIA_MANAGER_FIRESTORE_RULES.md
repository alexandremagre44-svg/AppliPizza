# Media Manager PRO - Firestore Security Rules

## Overview

This document describes the Firestore security rules needed for the Media Manager PRO module.

## Collection: studio_media

**Path:** `studio_media/{assetId}`

### Security Rules

```javascript
match /studio_media/{assetId} {
  // Read: All authenticated users (needed to display images in app)
  allow read: if request.auth != null;
  
  // Write: Admins only
  allow create, update: if request.auth != null 
    && request.auth.token.admin == true
    && request.resource.data.keys().hasAll([
      'id', 'originalFilename', 'folder', 'urlSmall', 'urlMedium', 
      'urlFull', 'sizeBytes', 'width', 'height', 'mimeType', 
      'uploadedAt', 'uploadedBy', 'tags', 'usedIn'
    ])
    && request.resource.data.id is string
    && request.resource.data.originalFilename is string
    && request.resource.data.folder in ['hero', 'promos', 'produits', 'studio', 'misc']
    && request.resource.data.urlSmall is string
    && request.resource.data.urlMedium is string
    && request.resource.data.urlFull is string
    && request.resource.data.sizeBytes is int
    && request.resource.data.sizeBytes >= 0
    && request.resource.data.width is int
    && request.resource.data.width >= 0
    && request.resource.data.height is int
    && request.resource.data.height >= 0
    && request.resource.data.mimeType is string
    && request.resource.data.uploadedAt is string
    && request.resource.data.uploadedBy is string
    && request.resource.data.tags is list
    && request.resource.data.usedIn is list;
  
  // Delete: Admins only, and only if not in use
  allow delete: if request.auth != null 
    && request.auth.token.admin == true
    && (!resource.data.keys().hasAny(['usedIn']) 
        || resource.data.usedIn.size() == 0);
}
```

## Firebase Storage Rules

### Security Rules

**Path:** `studio/media/{folder}/{size}/{filename}`

```javascript
match /studio/media/{folder}/{size}/{filename} {
  // Read: All authenticated users
  allow read: if request.auth != null;
  
  // Write: Admins only
  allow write: if request.auth != null 
    && request.auth.token.admin == true
    && folder in ['hero', 'promos', 'produits', 'studio', 'misc']
    && size in ['small', 'medium', 'full']
    && request.resource.size < 10 * 1024 * 1024  // Max 10MB
    && request.resource.contentType.matches('image/.*');
  
  // Delete: Admins only
  allow delete: if request.auth != null 
    && request.auth.token.admin == true;
}
```

## Implementation Steps

1. **Add Firestore Rules:**
   - Open Firebase Console
   - Navigate to Firestore Database > Rules
   - Add the `studio_media` collection rules
   - Publish the rules

2. **Add Storage Rules:**
   - Navigate to Storage > Rules
   - Add the `studio/media` path rules
   - Publish the rules

3. **Verify:**
   - Test image upload as admin (should succeed)
   - Test image read as regular user (should succeed)
   - Test image write as regular user (should fail)
   - Test delete of in-use image (should fail)

## Security Considerations

1. **Read Access:** All authenticated users can read media to display images in the app
2. **Write Access:** Only admins can upload, update, or delete media
3. **Usage Tracking:** The `usedIn` array prevents deletion of images still referenced
4. **File Size Limit:** Maximum 10MB per image file
5. **File Type Validation:** Only image/* MIME types are allowed
6. **Folder Restriction:** Only predefined folders are allowed

## Integration with Existing Rules

These rules should be added to your existing `firestore.rules` file alongside other Studio rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ... existing rules ...
    
    // Media Manager PRO rules
    match /studio_media/{assetId} {
      // ... rules from above ...
    }
    
    // ... other rules ...
  }
}
```

And in your `storage.rules`:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // ... existing rules ...
    
    // Media Manager PRO storage rules
    match /studio/media/{folder}/{size}/{filename} {
      // ... rules from above ...
    }
    
    // ... other rules ...
  }
}
```

## Testing

Use Firebase Emulator Suite to test rules before deployment:

```bash
firebase emulators:start --only firestore,storage
```

Then run integration tests to verify:
- Admin can upload images
- Admin can delete unused images
- Admin cannot delete in-use images
- Regular users can read but not write
- File size and type restrictions work
