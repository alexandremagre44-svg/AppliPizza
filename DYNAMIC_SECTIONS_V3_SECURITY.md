# Dynamic Sections V3 - Security & Deployment Guide

## 🔒 Firestore Security Rules

### Required Rules Configuration

Add these rules to your `firestore.rules` file:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null 
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Dynamic Sections V3
    match /dynamic_sections_v3/{sectionId} {
      // Public read access for app clients
      allow read: if true;
      
      // Write access restricted to admins only
      allow create, update, delete: if isAdmin();
      
      // Validation rules
      allow write: if request.resource.data.keys().hasAll(['id', 'type', 'layout', 'order', 'active', 'content', 'conditions', 'createdAt', 'updatedAt'])
        && request.resource.data.type is string
        && request.resource.data.layout is string
        && request.resource.data.order is int
        && request.resource.data.active is bool
        && request.resource.data.content is map
        && request.resource.data.conditions is map;
    }
  }
}
```

### Advanced Security Rules (Optional)

For more granular control:

```javascript
match /dynamic_sections_v3/{sectionId} {
  // Read rules
  allow read: if true;
  
  // Write rules with validation
  allow create: if isAdmin()
    && validateSection(request.resource.data);
    
  allow update: if isAdmin()
    && validateSection(request.resource.data)
    && resource.data.id == request.resource.data.id; // Prevent ID changes
    
  allow delete: if isAdmin();
  
  // Validation function
  function validateSection(section) {
    return section.keys().hasAll(['id', 'type', 'layout', 'order', 'active', 'content', 'conditions', 'createdAt', 'updatedAt'])
      && section.id is string
      && section.type in ['hero', 'promo-simple', 'promo-advanced', 'text', 'image', 'grid', 'carousel', 'categories', 'products', 'free-layout']
      && section.layout in ['full', 'compact', 'grid-2', 'grid-3', 'row', 'card', 'overlay']
      && section.order >= 0
      && section.active is bool
      && section.content is map
      && section.conditions is map
      && validateConditions(section.conditions);
  }
  
  // Validate conditions structure
  function validateConditions(conditions) {
    return (!('days' in conditions) || conditions.days is list)
      && (!('hoursStart' in conditions) || conditions.hoursStart is string)
      && (!('hoursEnd' in conditions) || conditions.hoursEnd is string)
      && conditions.requireLoggedIn is bool
      && (!('requireOrdersMin' in conditions) || conditions.requireOrdersMin is int)
      && (!('requireCartMin' in conditions) || conditions.requireCartMin is number)
      && conditions.applyOncePerSession is bool;
  }
}
```

## 🛡️ Content Validation

### Client-Side Validation

The application already includes:

1. **Type Safety**
   - Dart type system enforces model structure
   - Enums prevent invalid type/layout values

2. **Field Validation**
   - Required fields are enforced in UI
   - Duplicate key detection for custom fields
   - Null safety throughout

3. **Size Limits**
   - Consider adding max length for text fields
   - Limit number of custom fields per section

### Server-Side Validation (Recommended)

Create Cloud Functions for additional validation:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.validateSectionWrite = functions.firestore
  .document('dynamic_sections_v3/{sectionId}')
  .onWrite(async (change, context) => {
    const newData = change.after.exists ? change.after.data() : null;
    
    if (!newData) return; // Document deleted
    
    // Validate content size
    const contentSize = JSON.stringify(newData.content).length;
    if (contentSize > 10000) { // 10KB limit
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Section content exceeds size limit'
      );
    }
    
    // Validate custom fields count
    if (newData.type === 'free-layout' && newData.content.customFields) {
      if (newData.content.customFields.length > 50) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Too many custom fields (max: 50)'
        );
      }
    }
    
    // Sanitize HTML in text fields
    if (newData.content.text) {
      // Use a library like DOMPurify or sanitize-html
      // newData.content.text = sanitize(newData.content.text);
    }
    
    return null;
  });
```

## 🔐 Input Sanitization

### Image URLs

```dart
bool isValidImageUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  
  // Only allow HTTPS
  if (uri.scheme != 'https') return false;
  
  // Whitelist approved domains
  final allowedDomains = [
    'firebasestorage.googleapis.com',
    'storage.googleapis.com',
    'images.yoursite.com',
  ];
  
  return allowedDomains.any((domain) => uri.host.endsWith(domain));
}
```

### Text Content

For sections that might contain HTML or rich text:

```dart
import 'package:html/parser.dart' as html_parser;

String sanitizeHtml(String input) {
  final document = html_parser.parse(input);
  
  // Remove all script tags
  document.querySelectorAll('script').forEach((element) {
    element.remove();
  });
  
  // Remove dangerous attributes
  final dangerousAttrs = ['onclick', 'onerror', 'onload'];
  document.querySelectorAll('*').forEach((element) {
    dangerousAttrs.forEach((attr) {
      element.attributes.remove(attr);
    });
  });
  
  return document.body?.innerHtml ?? '';
}
```

## 🚨 Rate Limiting

### Firestore Write Rate Limits

Implement rate limiting for section updates:

```javascript
// functions/index.js
const rateLimit = require('express-rate-limit');

exports.createSection = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be authenticated'
    );
  }
  
  // Check if user is admin
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .get();
    
  if (userDoc.data()?.role !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Must be admin'
    );
  }
  
  // Check rate limit (max 10 writes per minute per user)
  const recentWrites = await admin.firestore()
    .collection('section_write_logs')
    .where('userId', '==', context.auth.uid)
    .where('timestamp', '>', Date.now() - 60000)
    .get();
    
  if (recentWrites.size >= 10) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Rate limit exceeded'
    );
  }
  
  // Log the write
  await admin.firestore().collection('section_write_logs').add({
    userId: context.auth.uid,
    timestamp: Date.now(),
  });
  
  // Proceed with section creation
  return admin.firestore()
    .collection('dynamic_sections_v3')
    .add(data);
});
```

## 📊 Monitoring & Logging

### Audit Trail

Track all section modifications:

```javascript
exports.logSectionChanges = functions.firestore
  .document('dynamic_sections_v3/{sectionId}')
  .onWrite(async (change, context) => {
    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;
    
    let action = 'unknown';
    if (!before && after) action = 'create';
    else if (before && !after) action = 'delete';
    else if (before && after) action = 'update';
    
    await admin.firestore().collection('section_audit_logs').add({
      sectionId: context.params.sectionId,
      action: action,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      userId: context.auth?.uid || 'system',
      before: before,
      after: after,
    });
  });
```

### Analytics

Track section visibility and performance:

```dart
void logSectionView(DynamicSection section) {
  FirebaseAnalytics.instance.logEvent(
    name: 'section_view',
    parameters: {
      'section_id': section.id,
      'section_type': section.type.value,
      'section_layout': section.layout.value,
    },
  );
}

void logSectionInteraction(DynamicSection section, String action) {
  FirebaseAnalytics.instance.logEvent(
    name: 'section_interaction',
    parameters: {
      'section_id': section.id,
      'section_type': section.type.value,
      'action': action, // 'click', 'view_cta', etc.
    },
  );
}
```

## 🔄 Backup & Recovery

### Automated Backups

```javascript
// Schedule daily backups
exports.scheduledFirestoreExport = functions.pubsub
  .schedule('every 24 hours')
  .onRun((context) => {
    const projectId = process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT;
    const databaseName = admin.firestore().databaseId;

    const client = new FirestoreAdminClient();
    const bucket = `gs://${projectId}-firestore-backups`;

    return client.exportDocuments({
      name: client.databasePath(projectId, databaseName),
      outputUriPrefix: bucket,
      collectionIds: ['dynamic_sections_v3'],
    });
  });
```

### Manual Export

Add admin function to export sections:

```dart
Future<void> exportSections() async {
  final sections = await DynamicSectionService().getAllSections();
  final json = sections.map((s) => s.toJson()).toList();
  
  // Save to file or send to email
  final jsonString = jsonEncode(json);
  // ... implement save/send logic
}
```

## 🧪 Security Testing Checklist

Before deploying to production:

- [ ] Test Firestore rules with Firebase Emulator
- [ ] Verify admin-only write access
- [ ] Test with non-admin users
- [ ] Test SQL injection attempts in text fields
- [ ] Test XSS attempts in HTML content
- [ ] Verify image URL validation
- [ ] Test rate limiting
- [ ] Review all error messages (no sensitive data leaks)
- [ ] Test with malformed JSON in custom fields
- [ ] Verify HTTPS-only enforcement
- [ ] Test with oversized content
- [ ] Verify proper session handling
- [ ] Test concurrent modifications
- [ ] Review Cloud Function permissions
- [ ] Test backup/restore procedures

## 🚀 Deployment Steps

1. **Update Firestore Rules**
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Deploy Cloud Functions** (if using)
   ```bash
   firebase deploy --only functions
   ```

3. **Test in Staging**
   - Create test sections
   - Verify conditions work correctly
   - Test all CRUD operations
   - Check permissions

4. **Deploy to Production**
   - Use blue-green deployment if possible
   - Monitor error logs closely
   - Have rollback plan ready

5. **Post-Deployment**
   - Verify Firestore rules are active
   - Check Cloud Function logs
   - Monitor performance metrics
   - Test from multiple devices

## 📱 Client-Side Security

### Secure Storage

Don't store sensitive section data in local storage:

```dart
// ❌ Bad
SharedPreferences.setString('sections', jsonEncode(sections));

// ✅ Good - use draft state in memory only
ref.read(studioDraftStateProvider.notifier).setDynamicSections(sections);
```

### Network Security

Ensure all Firestore connections use SSL:

```dart
// Already configured by default in Firebase SDK
// No action needed if using latest firebase_core
```

## 🔍 Vulnerability Scan

Regular security audits:

```bash
# Run security audit
npm audit

# Check for outdated packages
flutter pub outdated

# Run static analysis
flutter analyze

# Check for security issues in dependencies
dart pub global activate pana
pana .
```

## 📞 Incident Response

If a security issue is discovered:

1. **Immediate Actions**
   - Disable affected sections via `active: false`
   - Revoke suspicious admin access
   - Check audit logs for unauthorized changes

2. **Investigation**
   - Review Firestore security rules
   - Check Cloud Function logs
   - Analyze network traffic
   - Review affected sections

3. **Remediation**
   - Apply security patches
   - Update vulnerable dependencies
   - Rotate credentials if needed
   - Update documentation

4. **Communication**
   - Notify stakeholders
   - Document incident
   - Update security procedures

---

**Security Contact:** security@yourcompany.com  
**Last Updated:** 2025-01-20  
**Version:** 3.0.0
